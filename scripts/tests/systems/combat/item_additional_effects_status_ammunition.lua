describe('Vanilla and Zilart status ammunition ranged actions', function()
    local player
    local target

    local cases =
    {
        {
            name      = 'Kabura Arrow',
            itemId    = xi.item.KABURA_ARROW,
            weaponId  = xi.item.POWER_BOW,
            effectId  = xi.effect.SILENCE,
            subEffect = xi.subEffect.SILENCE,
            power     = 1,
            duration  = 60,
        },
        {
            name      = 'Patriarch Protector Arrow',
            itemId    = xi.item.PATRIARCH_PROTECTORS_ARROW,
            weaponId  = xi.item.POWER_BOW,
            effectId  = xi.effect.PARALYSIS,
            subEffect = xi.subEffect.PARALYSIS,
            power     = 30,
            duration  = 30,
        },
        {
            name      = 'Blind Bolt',
            itemId    = xi.item.BLIND_BOLT,
            weaponId  = xi.item.LIGHT_CROSSBOW,
            effectId  = xi.effect.BLINDNESS,
            subEffect = xi.subEffect.BLIND,
            power     = 10,
            duration  = 30,
        },
        {
            name      = 'Venom Bolt',
            itemId    = xi.item.VENOM_BOLT,
            weaponId  = xi.item.LIGHT_CROSSBOW,
            effectId  = xi.effect.POISON,
            subEffect = xi.subEffect.POISON,
            power     = 4,
            duration  = 30,
        },
        {
            name      = 'Poison Arrow',
            itemId    = xi.item.POISON_ARROW,
            weaponId  = xi.item.POWER_BOW,
            effectId  = xi.effect.POISON,
            subEffect = xi.subEffect.POISON,
            power     = 4,
            duration  = 30,
        },
        {
            name      = 'Sleep Arrow',
            itemId    = xi.item.SLEEP_ARROW,
            weaponId  = xi.item.POWER_BOW,
            effectId  = xi.effect.SLEEP_I,
            subEffect = xi.subEffect.SLEEP,
            power     = 0,
            duration  = 25,
        },
        {
            name      = 'Demon Arrow',
            itemId    = xi.item.DEMON_ARROW,
            weaponId  = xi.item.POWER_BOW,
            effectId  = xi.effect.ATTACK_DOWN,
            subEffect = xi.subEffect.ATTACK_DOWN,
            power     = 12,
            duration  = 60,
        },
        {
            name      = 'Spartan Bullet',
            itemId    = xi.item.SPARTAN_BULLET,
            weaponId  = xi.item.ARQUEBUS,
            effectId  = xi.effect.STUN,
            subEffect = xi.subEffect.STUN,
            power     = 10,
            duration  = 5,
        },
    }

    local function allowStatusResolution()
        stub('xi.data.statusEffect.isTargetImmune', false)
        stub('xi.data.statusEffect.isTargetResistant', false)
        stub('xi.data.statusEffect.isEffectNullified', false)
        stub('xi.combat.magicHitRate.calculateResistRate', 1)
        stub('math.randomInt', 1)
    end

    local function equipAmmunition(case, quantity)
        player:addItem(case.weaponId)
        player:addItem({ id = case.itemId, quantity = quantity })
        player:equipItem(case.weaponId, nil, xi.slot.RANGED)
        player:equipItem(case.itemId, nil, xi.slot.AMMO)
        assert(player:getEquippedItem(xi.slot.AMMO):getID() == case.itemId)
    end

    local function startRangedAttack()
        player.packets:clear()
        player.actions:engage(target)
        player.actions:rangedAttack(target)
    end

    local function startUnengagedRangedAttack()
        player.packets:clear()
        player.actions:rangedAttack(target)
    end

    local function completeRangedAttack(seed)
        xi.test.world:advanceTime(10)
        xi.test.world:setSeed(seed or 1)
        xi.test.world:tickEntity(player)
        xi.test.world:processClientUpdates()
    end

    local function rangedFinishResults()
        local results = {}
        for _, action in pairs(player.packets:actionPackets()) do
            if action.cmd_no == xi.action.category.RANGED_FINISH then
                table.insert(results, action.target[1].result[1])
            end
        end

        return results
    end

    before_each(function()
        xi.test.world:setSeed(1)

        player = xi.test.world:spawnPlayer(
            {
                zone  = xi.zone.WEST_RONFAURE,
                job   = xi.job.RNG,
                level = 99,
            })
        player:setMod(xi.mod.RACC, 1000)
        player:setMod(xi.mod.RECYCLE, 0)

        target = player.entities:moveTo('Wild_Rabbit')
        target:despawn()
        target:respawn()
        target:setMobLevel(99, true)
        target:setMaxHP(100000)
        target:setHP(target:getMaxHP())
        target:setUnkillable(true)
    end)

    for _, case in ipairs(cases) do
        it(string.format('serializes one %s status through a real ranged action', case.name), function()
            allowStatusResolution()
            local resolver = spy('xi.additionalEffect.profile.resolve')
            local applier = spy('xi.additionalEffect.applyStatus')
            equipAmmunition(case, 3)

            startRangedAttack()
            completeRangedAttack()

            local results = rangedFinishResults()
            assert(#results == 1, string.format('expected one ranged finish, got %u', #results))
            local result = results[1]
            local effect = target:getStatusEffect(case.effectId)
            assert(result.has_proc, string.format('%s had no additional effect', case.name))
            assert(result.proc_kind == case.subEffect)
            assert(result.proc_message == xi.msg.basic.ADD_EFFECT_STATUS_2)
            assert(result.proc_value == case.effectId)
            assert(effect, string.format('%s status was not retained', case.name))
            assert(effect:getPower() == case.power)
            assert(effect:getDuration() == case.duration * 1000)
            assert(player:getItemCount(case.itemId) == 2)
            resolver:called(1)
            applier:called(1)
            assert(resolver.calls[1].returned.itemId == case.itemId)
            assert(resolver.calls[1].returned.profileFamily == 'VZ_STATUS_AMMUNITION')
        end)

        it(string.format('does not execute %s after a physical miss', case.name), function()
            allowStatusResolution()
            local applier = spy('xi.additionalEffect.applyStatus')
            equipAmmunition(case, 3)
            player:setMod(xi.mod.RACC, -10000)
            target:setMod(xi.mod.EVA, 10000)

            startRangedAttack()
            completeRangedAttack(2)

            local results = rangedFinishResults()
            assert(#results == 1)
            assert(not results[1].has_proc)
            assert(results[1].message == xi.msg.basic.RANGED_ATTACK_MISS)
            assert(player:getItemCount(case.itemId) == 2)
            applier:called(0)
        end)
    end

    it('does not execute or consume status ammunition when starting out of range', function()
        allowStatusResolution()
        local applier = spy('xi.additionalEffect.applyStatus')
        local case = cases[1]
        equipAmmunition(case, 3)

        player:setPos(-100, -100, -100)
        xi.test.world:tickEntity(player)
        assert(player:checkDistance(target) > 25)
        player:lookAt(target:getPos())
        startUnengagedRangedAttack()
        completeRangedAttack()

        assert(#rangedFinishResults() == 0)
        assert(player:getItemCount(case.itemId) == 3)
        applier:called(0)
    end)

    it('does not execute status ammunition after target despawn', function()
        allowStatusResolution()
        local applier = spy('xi.additionalEffect.applyStatus')
        local case = cases[3]
        equipAmmunition(case, 3)

        startRangedAttack()
        xi.test.world:skipTime(1)
        target:setUnkillable(false)
        target:despawn()
        completeRangedAttack()

        for _, result in ipairs(rangedFinishResults()) do
            assert(not result.has_proc)
        end

        applier:called(0)
    end)

    it('suppresses the item effect below level while preserving the physical shot', function()
        allowStatusResolution()
        local resolver = spy('xi.additionalEffect.profile.resolve')
        local case = cases[1]
        equipAmmunition(case, 3)
        player:levelRestriction(69)
        player:setMod(xi.mod.RACC, 1000)
        player:setMod(xi.mod.RECYCLE, 0)

        startRangedAttack()
        completeRangedAttack()

        local results = rangedFinishResults()
        assert(#results == 1 and not results[1].has_proc)
        assert(player:getItemCount(case.itemId) == 2)
        resolver:called(0)
    end)

    it('inherits longer valid range without an independent status-distance pass', function()
        allowStatusResolution()
        local distance = spy('xi.combat.ranged.attackDistancePenalty')
        local case = cases[4]
        equipAmmunition(case, 3)

        target:setPos(0, 0, 0)
        player:setPos(0, 0, 15)
        xi.test.world:tickEntity(player)
        player:lookAt(target:getPos())
        assert(player:checkDistance(target) > 10 and player:checkDistance(target) < 25)

        startUnengagedRangedAttack()
        completeRangedAttack()

        local results = rangedFinishResults()
        assert(#results == 1 and results[1].has_proc)
        distance:called(2)
    end)

    it('preserves status ammunition through the ordinary Recycle path', function()
        allowStatusResolution()
        local case = cases[5]
        equipAmmunition(case, 3)
        player:setMod(xi.mod.RECYCLE, 100)

        startRangedAttack()
        completeRangedAttack()

        local results = rangedFinishResults()
        assert(#results == 1 and results[1].has_proc)
        assert(player:getItemCount(case.itemId) == 3)
    end)

    it('preserves status ammunition through Unlimited Shot without duplication', function()
        allowStatusResolution()
        local applier = spy('xi.additionalEffect.applyStatus')
        local case = cases[6]
        equipAmmunition(case, 3)
        player:addStatusEffect(xi.effect.UNLIMITED_SHOT, { duration = 60, origin = player })

        startRangedAttack()
        completeRangedAttack()

        local results = rangedFinishResults()
        assert(#results == 1 and results[1].has_proc)
        assert(player:getItemCount(case.itemId) == 3)
        assert(not player:hasStatusEffect(xi.effect.UNLIMITED_SHOT))
        applier:called(1)
    end)
end)
