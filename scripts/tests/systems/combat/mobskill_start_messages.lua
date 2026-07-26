local arkAngelHMCircleBlade = 938
local arkAngelEVVorpalBlade = 943
local mineBlast             = 1838

local function actionsMatching(player, category, argument)
    local matches = {}

    for _, action in pairs(player.packets:actionPackets()) do
        if
            action.cmd_no == category and
            (argument == nil or action.cmd_arg == argument)
        then
            table.insert(matches, action)
        end
    end

    return matches
end

local function countBasicMessages(player, messageId)
    local count = 0

    for _, packet in pairs(player.packets:getIncoming()) do
        if packet.type == 0x029 then
            local receivedMessageId = packet.data[24] + packet.data[25] * 256
            if receivedMessageId == messageId then
                count = count + 1
            end
        end
    end

    return count
end

local function assertStartAction(action, actor, target, skillId, messageId)
    assert(action.m_uID == actor:getID(), 'SkillStart actor was incorrect')
    assert(action.cmd_no == xi.action.category.WEAPONSKILL_START, 'action was not SkillStart')
    assert(action.cmd_arg == xi.action.fourCC.SKILL_USE, 'SkillStart action ID was incorrect')
    assert(#action.target == 1, 'SkillStart must have exactly one presentation target')
    assert(action.target[1].m_uID == target:getID(), 'SkillStart presentation target was incorrect')
    assert(#action.target[1].result == 1, 'SkillStart must have exactly one result')
    assert(action.target[1].result[1].value == skillId, 'SkillStart skill parameter was incorrect')
    assert(action.target[1].result[1].message == messageId, 'SkillStart message was incorrect')
end

describe('Mob-skill start messages', function()
    ---@type CClientEntityPair
    local player
    ---@type CTestEntity
    local mob

    before_each(function()
        xi.test.world:setSeed(1)

        player = xi.test.world:spawnPlayer(
            {
                job   = xi.job.WAR,
                level = 99,
                zone  = xi.zone.QUFIM_ISLAND,
            })

        mob = player.entities:moveTo('Clipper')
        mob:respawn()
        mob:setMagicCastingEnabled(false)
        mob:setAutoAttackEnabled(false)
        player.packets:clear()
    end)

    it('does not emit packets while an out-of-range humanoid skill list is repeatedly considered', function()
        mob:setMobMod(xi.mobMod.SKILL_LIST, 146) -- Gowam: only migrated zero-time humanoid weapon skills.
        mob:updateEnmity(player)
        xi.test.world:tickEntity(mob)

        mob:setTP(3000)
        player.packets:clear()

        for _ = 1, 4 do
            player.actions:move(mob:getXPos() + 10, mob:getYPos(), mob:getZPos())
            xi.test.world:tickEntity(mob)
        end

        assert(#actionsMatching(player, xi.action.category.WEAPONSKILL_START) == 0,
            'out-of-range skill consideration emitted SkillStart')
        assert(#actionsMatching(player, xi.action.category.MOBABILITY_FINISH) == 0,
            'out-of-range skill consideration executed a skill')
        assert(countBasicMessages(player, xi.msg.basic.READIES_WS) == 0,
            'skill consideration emitted a fake basic ready message')
        assert(mob:getTP() == 3000, 'rejected skill consideration spent TP')
    end)

    it('emits one proper start before one immediate Ark Angel finish', function()
        mob:updateEnmity(player)
        xi.test.world:tickEntity(mob)
        mob:setTP(3000)
        player.packets:clear()
        mob:useMobAbility(arkAngelEVVorpalBlade, player, nil, true)
        xi.test.world:tickEntity(mob)

        local actions = player.packets:actionPackets()
        assert(#actions == 2, string.format('expected start and finish, got %d actions', #actions))
        local expectedTarget = xi.settings.map.HIDE_READIES_TARGET and mob or player
        assertStartAction(actions[1], mob, expectedTarget, arkAngelEVVorpalBlade, xi.msg.basic.READIES_WS)
        assert(actions[2].cmd_no == xi.action.category.MOBABILITY_FINISH,
            string.format('zero-time skill did not finish second (actor %d, category %d, argument %d, targets %d)',
                actions[2].m_uID, actions[2].cmd_no, actions[2].cmd_arg, actions[2].trg_sum))
        assert(actions[2].cmd_arg == arkAngelEVVorpalBlade, 'finish action used the wrong skill')
        assert(countBasicMessages(player, xi.msg.basic.READIES_WS) == 0,
            'zero-time skill emitted a fake basic ready message')
        local remainingTP = mob:getTP()
        assert(remainingTP < 3000, 'zero-time skill did not spend TP')

        xi.test.world:tickEntity(mob)
        assert(#actionsMatching(player, xi.action.category.MOBABILITY_FINISH, arkAngelEVVorpalBlade) == 1,
            'zero-time state emitted a repeated finish action')
        assert(mob:getTP() == remainingTP, 'zero-time state changed TP again on its next tick')
    end)

    it('executes a zero-time no-ready Ark Angel skill without a start action', function()
        mob:setTP(2000)
        mob:useMobAbility(xi.mobSkill.SHIELD_STRIKE, player, nil, true)
        xi.test.world:tickEntity(mob)

        assert(#actionsMatching(player, xi.action.category.WEAPONSKILL_START, xi.action.fourCC.SKILL_USE) == 0,
            'Shield Strike unexpectedly emitted SkillStart')
        assert(#actionsMatching(player, xi.action.category.MOBABILITY_FINISH, xi.mobSkill.SHIELD_STRIKE) == 1,
            'Shield Strike did not finish exactly once')
        assert(mob:getTP() >= 2000,
            string.format('no-TP-cost Shield Strike deducted TP (remaining %d)', mob:getTP()))
    end)

    it('preserves positive-time preparation, completion, and interruption', function()
        mob:setTP(3000)
        mob:useMobAbility(xi.mobSkill.SONIC_BOOM_1, player, 2000, true)
        xi.test.world:tickEntity(mob)

        local starts = actionsMatching(player, xi.action.category.WEAPONSKILL_START, xi.action.fourCC.SKILL_USE)
        assert(#starts == 1, 'positive-time skill did not emit exactly one start')
        assert(#actionsMatching(player, xi.action.category.MOBABILITY_FINISH, xi.mobSkill.SONIC_BOOM_1) == 0,
            'positive-time skill finished on entry')

        xi.test.world:skipTime(1)
        assert(#actionsMatching(player, xi.action.category.MOBABILITY_FINISH, xi.mobSkill.SONIC_BOOM_1) == 0,
            'positive-time skill finished before its preparation time')

        xi.test.world:skipTime(2)
        assert(#actionsMatching(player, xi.action.category.MOBABILITY_FINISH, xi.mobSkill.SONIC_BOOM_1) == 1,
            'positive-time skill did not finish exactly once')

        mob:respawn()
        mob:setTP(3000)
        player.packets:clear()
        mob:useMobAbility(xi.mobSkill.SONIC_BOOM_1, player, 2000, true)
        xi.test.world:tickEntity(mob)
        mob:addStatusEffect(xi.effect.STUN, { power = 1, duration = 10, origin = mob })
        xi.test.world:skipTime(3)

        assert(#actionsMatching(player, xi.action.category.WEAPONSKILL_START, xi.action.fourCC.SKILL_USE) == 1,
            'interrupted skill did not emit exactly one start')
        assert(#actionsMatching(player, xi.action.category.WEAPONSKILL_START, xi.action.fourCC.SKILL_INTERRUPT) == 1,
            'interrupted skill did not emit exactly one interrupt')
        assert(#actionsMatching(player, xi.action.category.MOBABILITY_FINISH, xi.mobSkill.SONIC_BOOM_1) == 0,
            'interrupted skill emitted a finish action')
    end)

    it('emits no start action for a positive-time NO_START_MSG skill', function()
        mob:setTP(3000)
        mob:useMobAbility(mineBlast, player, nil, true)
        xi.test.world:tickEntity(mob)

        assert(#actionsMatching(player, xi.action.category.WEAPONSKILL_START, xi.action.fourCC.SKILL_USE) == 0,
            'NO_START_MSG skill emitted a start action')
        assert(mob:getTP() == 0, 'NO_START_MSG state was not entered')

        xi.test.world:skipTime(3)
        assert(#actionsMatching(player, xi.action.category.MOBABILITY_FINISH, mineBlast) == 1,
            'NO_START_MSG skill did not retain its finish action')
    end)

    it('uses self for a true self-target ready action', function()
        mob:setHP(1)
        mob:setTP(3000)
        mob:useMobAbility(xi.mobSkill.NOTT, mob, nil, true)
        xi.test.world:tickEntity(mob)

        local starts = actionsMatching(player, xi.action.category.WEAPONSKILL_START, xi.action.fourCC.SKILL_USE)
        assert(#starts == 1, 'Nott did not emit exactly one start')
        assertStartAction(starts[1], mob, mob, xi.mobSkill.NOTT, xi.msg.basic.READIES_WS)
        assert(#actionsMatching(player, xi.action.category.WEAPONSKILL_FINISH) == 1,
            'Nott did not retain its scripted finish category')
    end)

    it('uses the battle target for attacker-centered AoE and safely falls back to self', function()
        mob:updateEnmity(player)
        mob:setTP(3000)
        mob:useMobAbility(arkAngelHMCircleBlade, player, nil, true)
        xi.test.world:tickEntity(mob)

        local starts = actionsMatching(player, xi.action.category.WEAPONSKILL_START, xi.action.fourCC.SKILL_USE)
        assert(#starts == 1, 'engaged attacker-centered AoE did not emit one start')
        local expectedTarget = xi.settings.map.HIDE_READIES_TARGET and mob or player
        assertStartAction(starts[1], mob, expectedTarget, arkAngelHMCircleBlade, xi.msg.basic.READIES_WS)

        mob:respawn()
        mob:setTP(3000)
        player.packets:clear()
        mob:useMobAbility(arkAngelHMCircleBlade, player, nil, true)
        xi.test.world:tickEntity(mob)

        starts = actionsMatching(player, xi.action.category.WEAPONSKILL_START, xi.action.fourCC.SKILL_USE)
        assert(#starts == 1, 'fallback attacker-centered AoE did not emit one start')
        assertStartAction(starts[1], mob, mob, arkAngelHMCircleBlade, xi.msg.basic.READIES_WS)
    end)

    it('preserves the configured ready-target presentation', function()
        mob:setTP(3000)
        mob:useMobAbility(xi.mobSkill.FAST_BLADE_1, player, nil, true)
        xi.test.world:tickEntity(mob)

        local starts = actionsMatching(player, xi.action.category.WEAPONSKILL_START, xi.action.fourCC.SKILL_USE)
        assert(#starts == 1, 'hidden-target skill did not emit one start')
        local expectedTarget = xi.settings.map.HIDE_READIES_TARGET and mob or player
        assertStartAction(starts[1], mob, expectedTarget, xi.mobSkill.FAST_BLADE_1, xi.msg.basic.READIES_WS)
    end)

    it('emits no action and spends no TP when state construction fails', function()
        mob:setTP(3000)
        mob:addStatusEffect(xi.effect.AMNESIA, { power = 1, duration = 10, origin = mob })
        player.packets:clear()

        mob:useMobAbility(arkAngelHMCircleBlade, player, nil, true)
        xi.test.world:tickEntity(mob)

        assert(#player.packets:actionPackets() == 0, 'failed state construction emitted an action')
        assert(mob:getTP() == 3000, 'failed state construction spent TP')
    end)
end)
