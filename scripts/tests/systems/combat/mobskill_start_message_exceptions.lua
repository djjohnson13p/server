local function skillStarts(player)
    local matches = {}

    for _, action in pairs(player.packets:actionPackets()) do
        if
            action.cmd_no == xi.action.category.WEAPONSKILL_START and
            action.cmd_arg == xi.action.fourCC.SKILL_USE
        then
            table.insert(matches, action)
        end
    end

    return matches
end

local function countPackets(player, packetType)
    local count = 0

    for _, packet in pairs(player.packets:getIncoming()) do
        if packet.type == packetType then
            count = count + 1
        end
    end

    return count
end

local function getMobByName(player, name)
    for _, entity in ipairs(player:getZone():queryEntitiesByName(name)) do
        if entity:getObjType() == xi.objType.MOB then
            return entity
        end
    end

    return nil
end

describe('Mob-skill start-message encounter exceptions', function()
    ---@type CClientEntityPair
    local player

    it('preserves Trion custom dialogue without a generic ready action', function()
        player = xi.test.world:spawnPlayer(
            {
                job   = xi.job.WAR,
                level = 75,
                zone  = xi.zone.SOUTHERN_SAN_DORIA,
            })
        player:setNation(xi.nation.SANDORIA)
        player:addMission(xi.mission.log_id.SANDORIA, xi.mission.id.sandoria.THE_HEIR_TO_THE_LIGHT)
        player:setMissionStatus(xi.mission.log_id.SANDORIA, 3)
        player:gotoZone(xi.zone.QUBIA_ARENA)
        player.bcnm:enter('BC_Entrance', xi.battlefield.id.HEIR_TO_THE_LIGHT)

        player.bcnm:killMobs()
        player.events:expect({ eventId = 32004 })

        local trion = getMobByName(player, 'Trion')
        local target = player.entities:get(zones[xi.zone.QUBIA_ARENA].mob.WARLORD_ROJGNOJ)
        assert(trion and trion:isSpawned(), 'phase-two Trion did not spawn')
        assert(target and target:isSpawned(), 'phase-two Trion target did not spawn')

        trion:setMagicCastingEnabled(false)
        trion:setAutoAttackEnabled(false)
        player.packets:clear()
        trion:useMobAbility(xi.mobSkill.TRION_RED_LOTUS_BLADE, target, nil, true)
        xi.test.world:tickEntity(trion)

        assert(#skillStarts(player) == 0, 'Trion emitted an unwanted generic ready action')
        assert(countPackets(player, 0x02A) == 1, 'Trion custom ready dialogue was not preserved')
    end)

    it('preserves Volker custom dialogue without a generic ready action', function()
        player = xi.test.world:spawnPlayer(
            {
                job   = xi.job.WAR,
                level = 75,
                zone  = xi.zone.METALWORKS,
            })
        player:setNation(xi.nation.BASTOK)
        player:addMission(xi.mission.log_id.BASTOK, xi.mission.id.bastok.WHERE_TWO_PATHS_CONVERGE)
        player:setMissionStatus(xi.mission.log_id.BASTOK, 1)
        player:gotoZone(xi.zone.THRONE_ROOM)
        player.bcnm:enter('_4l1', xi.battlefield.id.WHERE_TWO_PATHS_CONVERGE)

        local zeid = getMobByName(player, 'Zeid')
        assert(zeid and zeid:isSpawned(), 'phase-one Zeid did not spawn')
        zeid:setHP(math.floor(zeid:getMaxHP() * 0.69))
        zeid:updateEnmity(player)
        xi.test.world:tickEntity(zeid)
        player.events:expect({ eventId = 32004 })

        local volker = getMobByName(player, 'Volker')
        local target = getMobByName(player, 'Zeid_2')
        assert(volker and volker:isSpawned(), 'phase-two Volker did not spawn')
        assert(target and target:isSpawned(), 'phase-two Volker target did not spawn')

        volker:setMagicCastingEnabled(false)
        volker:setAutoAttackEnabled(false)
        player.packets:clear()
        volker:useMobAbility(xi.mobSkill.VOLKER_RED_LOTUS_BLADE, target, nil, true)
        xi.test.world:tickEntity(volker)

        assert(#skillStarts(player) == 0, 'Volker emitted an unwanted generic ready action')
        assert(countPackets(player, 0x02A) == 1, 'Volker custom ready dialogue was not preserved')
    end)
end)
