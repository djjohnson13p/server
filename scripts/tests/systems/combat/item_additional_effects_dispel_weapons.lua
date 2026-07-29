describe('Lockheart and Mythril Heart Dispel melee integration', function()
    local cases =
    {
        { name = 'Lockheart', itemId = xi.item.LOCKHEART, level = 64 },
        { name = 'Mythril Heart', itemId = xi.item.MYTHRIL_HEART, level = 66 },
        { name = 'Mythril Heart +1', itemId = xi.item.MYTHRIL_HEART_PLUS_1, level = 66 },
    }

    local function spawnCombatants()
        local player = xi.test.world:spawnPlayer(
            {
                zone  = xi.zone.WEST_RONFAURE,
                job   = xi.job.WAR,
                level = 99,
            })
        player:setMod(xi.mod.ACC, 1000)

        local target = player.entities:moveTo('Wild_Rabbit')
        target:despawn()
        target:respawn()
        target:setMobLevel(99, true)
        target:setMod(xi.mod.EVA, -1000)
        target:setMaxHP(100000)
        target:setHP(target:getMaxHP())
        target:setUnkillable(true)

        return player, target
    end

    local function equipMain(player, itemId)
        player:addItem(itemId)
        player:equipItem(itemId, nil, xi.slot.MAIN)
        local item = player:getEquippedItem(xi.slot.MAIN)
        assert(item and item:getID() == itemId)
    end

    local function addDispellable(player, target, effectId)
        target:addStatusEffect(
            effectId,
            {
                power    = 10,
                duration = 60,
                origin   = player,
                flag     = xi.effectFlag.DISPELABLE,
            })
        assert(target:hasStatusEffect(effectId))
    end

    local function basicAttackActions(player)
        local actions = {}
        for _, action in pairs(player.packets:actionPackets()) do
            if
                action.cmd_no == xi.action.category.BASIC_ATTACK and
                action.m_uID == player:getID() and
                action.cmd_arg == xi.action.fourCC.ATTACK
            then
                table.insert(actions, action)
            end
        end

        return actions
    end

    local function flattenedResults(actions)
        local results = {}
        for _, action in ipairs(actions) do
            for _, actionTarget in ipairs(action.target) do
                for _, result in ipairs(actionTarget.result) do
                    table.insert(results, result)
                end
            end
        end

        return results
    end

    local function performFirstAttack(player, target, beforeFirstTick)
        player.packets:clear()
        player.actions:engage(target)
        if beforeFirstTick then
            beforeFirstTick()
        end

        for _ = 1, 10 do
            xi.test.world:setSeed(1)
            xi.test.world:tickEntity(player)
            local actions = basicAttackActions(player)
            if #flattenedResults(actions) > 0 then
                return actions
            end

            xi.test.world:skipTime(5)
        end

        return {}
    end

    before_each(function()
        xi.test.world:setSeed(1)
        stub('math.randomInt', 1)
    end)

    for _, case in ipairs(cases) do
        it(string.format(
            'serializes one %s Dispel through the real main-hand melee path',
            case.name), function()
            local player, target = spawnCombatants()
            local executor = spy('xi.additionalEffect.executeDispel')
            equipMain(player, case.itemId)
            addDispellable(player, target, xi.effect.PROTECT)

            local actions = performFirstAttack(player, target)
            local results = flattenedResults(actions)

            assert(#actions == 1)
            assert(#results == 1)
            assert(
                results[1].has_proc,
                string.format(
                    'missing proc; kind=%s message=%s value=%s retained=%s',
                    tostring(results[1].proc_kind),
                    tostring(results[1].proc_message),
                    tostring(results[1].proc_value),
                    tostring(target:hasStatusEffect(xi.effect.PROTECT))))
            assert(results[1].proc_kind == xi.subEffect.DARKNESS_DAMAGE)
            assert(results[1].proc_message == xi.msg.basic.ADD_EFFECT_DISPEL)
            assert(results[1].proc_value == xi.effect.PROTECT)
            assert(not target:hasStatusEffect(xi.effect.PROTECT))
            executor:called(1)
            assert(executor.calls[1].args[3].profile.itemId == case.itemId)
        end)

        it(string.format(
            'does not execute %s after a physical miss',
            case.name), function()
            local player, target = spawnCombatants()
            local executor = spy('xi.additionalEffect.executeDispel')
            equipMain(player, case.itemId)
            addDispellable(player, target, xi.effect.PROTECT)
            player:setMod(xi.mod.ACC, -10000)
            target:setMod(xi.mod.EVA, 10000)

            local results = flattenedResults(performFirstAttack(player, target))
            assert(#results == 1)
            assert(not results[1].has_proc)
            assert(target:hasStatusEffect(xi.effect.PROTECT))
            executor:called(0)
        end)

        it(string.format(
            'suppresses %s below its item level while preserving the physical attack',
            case.name), function()
            local player, target = spawnCombatants()
            local executor = spy('xi.additionalEffect.executeDispel')
            equipMain(player, case.itemId)
            addDispellable(player, target, xi.effect.PROTECT)
            player:levelRestriction(case.level - 1)
            player:setMod(xi.mod.ACC, 1000)

            local results = flattenedResults(performFirstAttack(player, target))
            assert(#results == 1)
            assert(not results[1].has_proc)
            assert(target:hasStatusEffect(xi.effect.PROTECT))
            executor:called(0)
        end)

        it(string.format(
            'rejects impossible off-hand equip of the two-handed %s',
            case.name), function()
            local player, target = spawnCombatants()
            local executor = spy('xi.additionalEffect.executeDispel')
            equipMain(player, xi.item.BRONZE_KNIFE)
            player:addItem(case.itemId)
            player:equipItem(case.itemId, nil, xi.slot.SUB)
            local subItem = player:getEquippedItem(xi.slot.SUB)
            assert(not subItem or subItem:getID() ~= case.itemId)
            addDispellable(player, target, xi.effect.PROTECT)

            local results = flattenedResults(performFirstAttack(player, target))
            assert(#results == 1)
            assert(not results[1].has_proc)
            assert(target:hasStatusEffect(xi.effect.PROTECT))
            executor:called(0)
        end)
    end

    it('keeps Enspell priority without duplicate Dispel execution', function()
        local player, target = spawnCombatants()
        local executor = spy('xi.additionalEffect.executeDispel')
        equipMain(player, xi.item.LOCKHEART)
        addDispellable(player, target, xi.effect.PROTECT)
        player:addStatusEffect(
            xi.effect.ENFIRE,
            { power = 9, duration = 60, origin = player })

        local results = flattenedResults(performFirstAttack(player, target))
        local procResults = {}
        for _, result in ipairs(results) do
            if result.has_proc then
                table.insert(procResults, result)
            end
        end

        assert(#procResults == 1)
        assert(procResults[1].proc_kind == xi.subEffect.FIRE_DAMAGE)
        assert(target:hasStatusEffect(xi.effect.PROTECT))
        executor:called(0)
    end)

    it('emits one Dispel result per legitimate multi-attack swing', function()
        local player, target = spawnCombatants()
        local executor = spy('xi.additionalEffect.executeDispel')
        equipMain(player, xi.item.LOCKHEART)
        addDispellable(player, target, xi.effect.PROTECT)
        addDispellable(player, target, xi.effect.SHELL)
        player:setMod(xi.mod.DOUBLE_ATTACK, 100)

        local results = flattenedResults(performFirstAttack(player, target))
        local procCount = 0
        local removedEffects = {}
        for _, result in ipairs(results) do
            if result.has_proc then
                procCount = procCount + 1
                assert(result.proc_kind == xi.subEffect.DARKNESS_DAMAGE)
                assert(result.proc_message == xi.msg.basic.ADD_EFFECT_DISPEL)
                removedEffects[result.proc_value] = true
            end
        end

        assert(#results == 2)
        assert(procCount == 2)
        assert(removedEffects[xi.effect.PROTECT])
        assert(removedEffects[xi.effect.SHELL])
        assert(not target:hasStatusEffect(xi.effect.PROTECT))
        assert(not target:hasStatusEffect(xi.effect.SHELL))
        executor:called(2)
    end)

    it('does no Dispel work after the selected target despawns', function()
        local player, target = spawnCombatants()
        local executor = spy('xi.additionalEffect.executeDispel')
        equipMain(player, xi.item.LOCKHEART)
        addDispellable(player, target, xi.effect.PROTECT)
        player.packets:clear()
        player.actions:engage(target)
        target:setUnkillable(false)
        target:despawn()
        xi.test.world:skipTime(5)
        xi.test.world:tickEntity(player)

        assert(#basicAttackActions(player) == 0)
        executor:called(0)
    end)

    it('leaves ordinary melee without a Dispel profile unchanged', function()
        local player, target = spawnCombatants()
        local executor = spy('xi.additionalEffect.executeDispel')
        equipMain(player, xi.item.BRONZE_KNIFE)
        addDispellable(player, target, xi.effect.PROTECT)

        local results = flattenedResults(performFirstAttack(player, target))
        assert(#results == 1)
        assert(not results[1].has_proc)
        assert(target:hasStatusEffect(xi.effect.PROTECT))
        executor:called(0)
    end)
end)
