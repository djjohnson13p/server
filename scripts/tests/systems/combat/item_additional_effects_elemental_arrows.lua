describe('Fire, Ice, and Lightning Arrow additional effects', function()
    local player
    local target

    local arrowCases =
    {
        {
            name      = 'Fire Arrow',
            itemId    = xi.item.FIRE_ARROW,
            subEffect = xi.subEffect.FIRE_DAMAGE,
        },
        {
            name      = 'Ice Arrow',
            itemId    = xi.item.ICE_ARROW,
            subEffect = xi.subEffect.ICE_DAMAGE,
        },
        {
            name      = 'Lightning Arrow',
            itemId    = xi.item.LIGHTNING_ARROW,
            subEffect = xi.subEffect.LIGHTNING_DAMAGE,
        },
    }

    local function isolateCompatibilityFormula(basePower)
        stub('math.random', basePower)
        stub('math.randomInt', 1)
        stub('xi.combat.magicHitRate.calculateResistRate', 1)
        stub('xi.spells.damage.calculateNullification', 1)
        stub('xi.spells.damage.calculateAbsorption', 1)
        stub('xi.combat.damage.calculateDamageAdjustment', 1)
        stub('xi.combat.damage.physicalElementSDT', 1)
        stub('xi.combat.damage.magicalElementSDT', 1)
        stub('xi.spells.damage.calculateElementalStaffBonus', 1)
        stub('xi.spells.damage.calculateElementalAffinityBonus', 1)
        stub('xi.spells.damage.calculateDayAndWeather', 1)
        stub('utils.handlePhalanx', function(_, damage)
            return damage
        end)

        stub('utils.handleOneForAll', function(_, damage)
            return damage
        end)

        stub('utils.handleStoneskin', function(_, damage)
            return damage
        end)
    end

    local function equipArrow(itemId, quantity)
        player:addItem(xi.item.POWER_BOW)
        player:addItem({ id = itemId, quantity = quantity })
        player:equipItem(xi.item.POWER_BOW, nil, xi.slot.RANGED)
        player:equipItem(itemId, nil, xi.slot.AMMO)
        assert(player:getEquippedItem(xi.slot.AMMO):getID() == itemId)
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
                job   = xi.job.WAR,
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
        target:setUnkillable(false)
    end)

    for _, case in ipairs(arrowCases) do
        it(string.format(
            'serializes one %s effect through the real ranged action',
            case.name), function()
            isolateCompatibilityFormula(7)
            equipArrow(case.itemId, 3)

            local startingHP = target:getHP()
            startRangedAttack()
            completeRangedAttack()

            local results = rangedFinishResults()
            assert(#results == 1, string.format('expected one ranged finish, got %u', #results))

            local result = results[1]
            assert(result.has_proc, string.format('%s did not serialize an additional effect', case.name))
            assert(result.proc_kind == case.subEffect)
            assert(result.proc_message == xi.msg.basic.ADD_EFFECT_DMG)
            assert(result.proc_value == 7)
            assert(
                startingHP - target:getHP() == result.value + result.proc_value,
                string.format(
                    '%s total HP delta did not equal physical plus additional packet values',
                    case.name))
            assert(player:getItemCount(case.itemId) == 2)
        end)

        it(string.format(
            'does not execute %s after the target leaves range during the shot',
            case.name), function()
            isolateCompatibilityFormula(7)
            local executor = spy('xi.combat.action.executeAddEffectDamage')
            equipArrow(case.itemId, 3)

            startRangedAttack()
            xi.test.world:skipTime(1)
            target:setPos(90, 90, 90)
            completeRangedAttack()

            local results = rangedFinishResults()
            assert(#results == 1)
            assert(not results[1].has_proc)
            assert(results[1].message == xi.msg.basic.RANGED_ATTACK_MISS)
            assert(player:getItemCount(case.itemId) == 2)
            executor:called(0)
        end)

        it(string.format(
            'does not execute %s after an ordinary physical ranged miss',
            case.name), function()
            isolateCompatibilityFormula(7)
            local executor = spy('xi.combat.action.executeAddEffectDamage')
            equipArrow(case.itemId, 3)
            player:setMod(xi.mod.RACC, -10000)
            target:setMod(xi.mod.EVA, 10000)

            startRangedAttack()
            completeRangedAttack(2)

            local results = rangedFinishResults()
            assert(#results == 1)
            assert(not results[1].has_proc)
            assert(results[1].message == xi.msg.basic.RANGED_ATTACK_MISS)
            assert(player:getItemCount(case.itemId) == 2)
            executor:called(0)
        end)

        it(string.format(
            'does not execute or consume %s when the action begins out of range',
            case.name), function()
            isolateCompatibilityFormula(7)
            local executor = spy('xi.combat.action.executeAddEffectDamage')
            equipArrow(case.itemId, 3)

            player:setPos(-100, -100, -100)
            xi.test.world:tickEntity(player)
            assert(player:checkDistance(target) > 25)
            player:lookAt(target:getPos())
            startUnengagedRangedAttack()
            completeRangedAttack()

            assert(#rangedFinishResults() == 0)
            assert(player:getItemCount(case.itemId) == 3)
            executor:called(0)
        end)

        it(string.format(
            'suppresses %s below its level while preserving the physical shot',
            case.name), function()
            isolateCompatibilityFormula(7)
            local executor = spy('xi.combat.action.executeAddEffectDamage')
            equipArrow(case.itemId, 3)
            player:levelRestriction(44)
            player:setMod(xi.mod.RACC, 1000)
            player:setMod(xi.mod.RECYCLE, 0)
            assert(player:getEquippedItem(xi.slot.AMMO):getID() == case.itemId)

            startRangedAttack()
            completeRangedAttack()

            local results = rangedFinishResults()
            assert(#results == 1)
            assert(not results[1].has_proc)
            assert(player:getItemCount(case.itemId) == 2)
            executor:called(0)
        end)
    end

    it('inherits the longer-range physical distance path without a magical distance pass', function()
        isolateCompatibilityFormula(7)
        local distance = spy('xi.combat.ranged.attackDistancePenalty')
        local executor = spy('xi.combat.action.executeAddEffectDamage')
        equipArrow(xi.item.FIRE_ARROW, 3)

        target:setPos(0, 0, 0)
        player:setPos(0, 0, 15)
        xi.test.world:tickEntity(player)
        player:lookAt(target:getPos())
        assert(player:checkDistance(target) > 10 and player:checkDistance(target) < 25)

        startUnengagedRangedAttack()
        completeRangedAttack()

        local results = rangedFinishResults()
        assert(#results == 1 and results[1].has_proc)
        assert(results[1].proc_value == 7)
        distance:called(2)
        executor:called(1)
    end)

    it('does not resolve the arrow effect after the target despawns mid-shot', function()
        isolateCompatibilityFormula(7)
        local executor = spy('xi.combat.action.executeAddEffectDamage')
        equipArrow(xi.item.ICE_ARROW, 3)

        startRangedAttack()
        xi.test.world:skipTime(1)
        target:despawn()
        completeRangedAttack()

        for _, result in ipairs(rangedFinishResults()) do
            assert(not result.has_proc)
        end

        executor:called(0)
    end)

    it('preserves an elemental arrow through the ordinary Recycle path', function()
        isolateCompatibilityFormula(7)
        local executor = spy('xi.combat.action.executeAddEffectDamage')
        equipArrow(xi.item.LIGHTNING_ARROW, 3)
        player:setMod(xi.mod.RECYCLE, 100)

        startRangedAttack()
        completeRangedAttack()

        local results = rangedFinishResults()
        assert(#results == 1, string.format('expected one ranged result, got %u', #results))
        assert(
            results[1].has_proc,
            string.format(
                'Recycle shot had no proc (message=%u, resolution=%s)',
                results[1].message,
                tostring(results[1].reaction)))
        assert(player:getItemCount(xi.item.LIGHTNING_ARROW) == 3)
        executor:called(1)
    end)

    it('preserves an elemental arrow through Unlimited Shot without duplicating its effect', function()
        isolateCompatibilityFormula(7)
        local executor = spy('xi.combat.action.executeAddEffectDamage')
        equipArrow(xi.item.ICE_ARROW, 3)
        player:addStatusEffect(xi.effect.UNLIMITED_SHOT, { duration = 60, origin = player })

        startRangedAttack()
        completeRangedAttack()

        local results = rangedFinishResults()
        assert(#results == 1 and results[1].has_proc)
        assert(player:getItemCount(xi.item.ICE_ARROW) == 3)
        assert(not player:hasStatusEffect(xi.effect.UNLIMITED_SHOT))
        executor:called(1)
    end)

    it('emits only the arrow profile result when an Enspell is also active', function()
        isolateCompatibilityFormula(7)
        local executor = spy('xi.combat.action.executeAddEffectDamage')
        equipArrow(xi.item.FIRE_ARROW, 3)
        player:addStatusEffect(xi.effect.ENFIRE, { power = 99, duration = 60, origin = player })

        startRangedAttack()
        completeRangedAttack()

        local results = rangedFinishResults()
        assert(#results == 1 and results[1].has_proc)
        assert(results[1].proc_kind == xi.subEffect.FIRE_DAMAGE)
        assert(results[1].proc_value == 7)
        executor:called(1)
    end)
end)
