describe('Attack while fishing transition', function()
    local player
    local target

    local checkHookMode   = 2
    local endMiniGameMode = 3
    local releaseMode     = 4
    local timeoutMode     = 5

    local smallFishCatch = 1
    local mobCatch       = 4

    local function moveTargetNearPlayer(mob)
        local pos = player:getPos()
        mob:setPos(pos.x + 1, pos.y, pos.z)
    end

    local function resetMob(name)
        local mob = player.entities:get(name)
        mob:despawn()
        mob:respawn()
        moveTargetNearPlayer(mob)

        return mob
    end

    local function startFishing()
        player.actions:fish()

        local state = player:fishingState()
        assert(state.active, 'fishing did not start')
        assert(state.animation == xi.animation.NEW_FISHING_START, 'character is not in the fishing start animation')
        assert(state.token > 0, 'fishing session has no token')
        assert(state.hasResponse, 'fishing session has no response owner')
        assert(state.responseToken == state.token, 'waiting response does not own the current token')
        assert(not state.hooked, 'waiting response is already hooked')

        return state
    end

    local function assertFishingStopped()
        local state = player:fishingState()
        assert(not state.active, 'fishing session is still active')
        assert(state.token == 0, 'cancelled fishing token was not invalidated')
        assert(not state.hasResponse, 'cancelled fishing response survived')
    end

    local function countFishingReleasePackets()
        local count = 0

        for _, packet in pairs(player.packets:getIncoming()) do
            if packet.type == 0x052 and packet.data[4] == 4 then
                count = count + 1
            end
        end

        return count
    end

    before_each(function()
        player = xi.test.world:spawnPlayer(
            {
                zone  = xi.zone.WEST_RONFAURE,
                job   = xi.job.WAR,
                level = 75,
            })

        target = resetMob('Wild_Rabbit')

        player:addItem(xi.item.WILLOW_FISHING_ROD)
        player:addItem(xi.item.LITTLE_WORM, 12)
        player:equipItem(xi.item.WILLOW_FISHING_ROD, nil, xi.slot.RANGED)
        player:equipItem(xi.item.LITTLE_WORM, nil, xi.slot.AMMO)
    end)

    it('interrupts a waiting cast once before ordinary engagement', function()
        local waiting   = startFishing()
        local baitCount = player:getItemCount(xi.item.LITTLE_WORM)
        local rodCount  = player:getItemCount(xi.item.WILLOW_FISHING_ROD)

        player.packets:clear()
        player.actions:attack(target)

        assert(player:isEngaged(), 'valid attack did not engage')
        assert(player:getAnimation() == xi.animation.ATTACK, 'fishing animation survived engagement')
        assertFishingStopped()
        assert(player:getItemCount(xi.item.LITTLE_WORM) == baitCount, 'waiting interruption consumed bait')
        assert(player:getItemCount(xi.item.WILLOW_FISHING_ROD) == rodCount, 'waiting interruption changed the rod')
        assert(countFishingReleasePackets() == 1, 'fishing release was not sent exactly once')

        player.actions:attack(target)
        assert(countFishingReleasePackets() == 1, 'duplicate attack repeated fishing cleanup')

        player.actions:fishingAction(checkHookMode, 0, 0)
        player.actions:fishingAction(endMiniGameMode, 0, 0)
        player.actions:fishingAction(releaseMode, 0, 0)

        assert(player:isEngaged(), 'late fishing input ended combat')
        assertFishingStopped()
        assert(player:getItemCount(xi.item.LITTLE_WORM) == baitCount, 'late fishing input consumed bait')
        assert(waiting.token > 0, 'test precondition: initial token was invalid')
    end)

    it('invalidates a hooked fish and cannot award its result afterward', function()
        startFishing()
        player:setFishingHookForTest(smallFishCatch, xi.item.MOAT_CARP_1, 11, 123)

        local hooked     = player:fishingState()
        local baitCount  = player:getItemCount(xi.item.LITTLE_WORM)
        local rodCount   = player:getItemCount(xi.item.WILLOW_FISHING_ROD)
        local skillLevel = player:getSkillLevel(xi.skill.FISHING)

        assert(hooked.hooked, 'test fixture did not reach the hooked phase')
        assert(hooked.responseToken == hooked.token, 'hooked response token is stale')

        player.actions:attack(target)

        assert(player:isEngaged(), 'hooked-phase attack did not engage')
        assertFishingStopped()
        assert(player:getItemCount(xi.item.LITTLE_WORM) == baitCount - 1, 'hooked interruption did not apply existing bait-loss semantics once')
        assert(player:getItemCount(xi.item.WILLOW_FISHING_ROD) == rodCount, 'hooked interruption changed the rod')
        assert(player:getItemCount(xi.item.MOAT_CARP_1) == 0, 'interrupted hook granted a fish')
        assert(player:getSkillLevel(xi.skill.FISHING) == skillLevel, 'interrupted hook granted a skill-up')

        player.actions:fishingAction(endMiniGameMode, 0, 123)
        player.actions:fishingAction(releaseMode, 0, 0)
        player.actions:attack(target)

        assert(player:getItemCount(xi.item.LITTLE_WORM) == baitCount - 1, 'late or duplicate input consumed bait twice')
        assert(player:getItemCount(xi.item.MOAT_CARP_1) == 0, 'late completion granted a fish')
        assert(player:getSkillLevel(xi.skill.FISHING) == skillLevel, 'late release granted a skill-up')
    end)

    it('unhooks a pending fishing monster and blocks stale spawning', function()
        local fishingMob = player.entities:get('Tree_Crab')
        fishingMob:despawn()

        startFishing()
        player:setFishingHookForTest(mobCatch, fishingMob:getID(), 10, 91)
        assert(fishingMob:getLocalVar('hooked') == 1, 'test fixture did not reserve the fishing monster')

        player.actions:attack(target)

        assert(player:isEngaged(), 'monster-hook attack did not engage')
        assertFishingStopped()
        assert(fishingMob:getLocalVar('hooked') == 0, 'cancelled fishing monster stayed reserved')
        assert(not fishingMob:isSpawned(), 'cancelled fishing monster spawned')

        player.actions:fishingAction(endMiniGameMode, 0, 91)
        player.actions:fishingAction(releaseMode, 0, 0)

        assert(fishingMob:getLocalVar('hooked') == 0, 'stale completion re-reserved the fishing monster')
        assert(not fishingMob:isSpawned(), 'stale completion spawned the fishing monster')
    end)

    it('preserves fishing when ordinary attack validation rejects the target', function()
        local waiting = startFishing()

        player.actions:attackById(0, 0x7FF)
        local state = player:fishingState()
        assert(state.active and state.token == waiting.token, 'invalid entity index damaged fishing state')

        player.actions:attack(player)
        state = player:fishingState()
        assert(state.active and state.token == waiting.token, 'self attack damaged fishing state')

        local pos = player:getPos()
        target:setPos(pos.x + 31, pos.y, pos.z)
        player.actions:attack(target)
        state = player:fishingState()
        assert(state.active and state.token == waiting.token, 'out-of-range attack damaged fishing state')

        moveTargetNearPlayer(target)
        target:despawn()
        player.actions:attack(target)
        state = player:fishingState()
        assert(state.active and state.token == waiting.token, 'despawned-target attack damaged fishing state')
        assert(not player:isEngaged(), 'invalid attack unexpectedly engaged')
    end)

    it('rejects crafted fishing packets outside their lifecycle phase', function()
        local waiting   = startFishing()
        local baitCount = player:getItemCount(xi.item.LITTLE_WORM)

        player.actions:fishingAction(endMiniGameMode, 0, 0)
        player.actions:fishingAction(timeoutMode, 5, 0)
        player.actions:fishingAction(checkHookMode, 1, 0)

        local state = player:fishingState()
        assert(state.active and state.token == waiting.token, 'wrong-phase packet changed the waiting session')
        assert(state.animation == xi.animation.NEW_FISHING_START, 'wrong-phase packet changed the waiting animation')
        assert(player:getItemCount(xi.item.LITTLE_WORM) == baitCount, 'wrong-phase packet consumed bait')

        player:setFishingHookForTest(smallFishCatch, xi.item.MOAT_CARP_1, 11, 77)
        player.actions:fishingAction(checkHookMode, 0, 0)
        player.actions:fishingAction(endMiniGameMode, 301, 77)

        state = player:fishingState()
        assert(state.active and state.hooked, 'duplicate or malformed hook input changed the active mini-game')
        assert(state.token == waiting.token, 'malformed mini-game input changed the token')
        assert(player:getItemCount(xi.item.LITTLE_WORM) == baitCount, 'malformed mini-game input consumed bait')
    end)

    it('keeps ordinary release idempotent and issues a fresh recovery token', function()
        local first     = startFishing()
        local baitCount = player:getItemCount(xi.item.LITTLE_WORM)

        player.actions:fishingAction(releaseMode, 0, 0)
        assertFishingStopped()
        assert(player:getAnimation() == xi.animation.NONE, 'ordinary release did not clear animation')
        assert(player:getItemCount(xi.item.LITTLE_WORM) == baitCount, 'waiting release consumed bait')

        player.actions:fishingAction(releaseMode, 0, 0)
        player.actions:fishingAction(checkHookMode, 0, 0)
        assertFishingStopped()

        xi.test.world:skipTime(1)
        local second = startFishing()
        assert(second.token ~= first.token, 'new fishing session reused the cancelled token')
        assert(second.responseToken == second.token, 'new session response does not own its token')
    end)

    it('can fish again after attack interruption and later disengagement', function()
        local first = startFishing()
        player.actions:attack(target)
        assert(player:isEngaged(), 'test precondition: player did not engage')

        player.actions:disengage()
        xi.test.world:skipTime(1)
        assert(not player:isEngaged(), 'ordinary disengagement did not complete')

        local second = startFishing()
        assert(second.token ~= first.token, 'post-combat fishing reused the interrupted token')

        player.actions:fishingAction(endMiniGameMode, 0, 0)
        local state = player:fishingState()
        assert(state.active and state.token == second.token, 'stale completion affected the new waiting session')
    end)

    it('keeps non-attack actions blocked and ordinary non-fishing attacks unchanged', function()
        local waiting = startFishing()

        player.actions:useSpell(player, xi.magic.spell.CURE)
        player.actions:useAbility(player, xi.jobAbility.BERSERK)
        player.actions:rangedAttack(target)
        player.actions:useWeaponskill(target, xi.weaponskill.FAST_BLADE)
        player.actions:fish()

        local state = player:fishingState()
        assert(state.active and state.token == waiting.token, 'a non-attack action ended fishing')
        assert(state.animation == xi.animation.NEW_FISHING_START, 'a non-attack action changed fishing animation')
        assert(not player:isEngaged(), 'a blocked action engaged the player')

        player.actions:fishingAction(releaseMode, 0, 0)
        player.actions:attack(target)
        assert(player:isEngaged(), 'ordinary non-fishing attack regressed')
    end)
end)
