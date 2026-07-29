describe('Vanilla and Zilart single-resource drain melee actions', function()
    local cases =
    {
        {
            name      = 'Aspir Knife',
            itemId    = xi.item.ASPIR_KNIFE,
            job       = xi.job.NIN,
            resource  = 'MP',
            subEffect = xi.subEffect.MP_DRAIN,
            message   = xi.msg.basic.ADD_EFFECT_MP_DRAIN,
            amount    = 3,
            level     = 12,
        },
        {
            name      = 'Bloody Rapier',
            itemId    = xi.item.BLOODY_RAPIER,
            job       = xi.job.WAR,
            offhandJob = xi.job.DNC,
            resource  = 'HP',
            subEffect = xi.subEffect.HP_DRAIN,
            message   = xi.msg.basic.ADD_EFFECT_HP_DRAIN,
            amount    = 10,
            level     = 55,
        },
        {
            name      = 'Shinsoku',
            itemId    = xi.item.SHINSOKU,
            job       = xi.job.SAM,
            resource  = 'TP',
            subEffect = xi.subEffect.TP_DRAIN,
            message   = xi.msg.basic.ADD_EFFECT_TP_DRAIN,
            amount    = 10,
            level     = 72,
        },
    }

    local function isolateLegacyDrainFormula()
        stub('addBonusesAbility', function(_, element, _, damage)
            assert(element == xi.element.DARK)
            return damage
        end)

        stub('applyResistanceAddEffect', 1)
        stub('xi.spells.damage.calculateAbsorption', 1)
        stub('xi.spells.damage.calculateNullification', 1)
        stub('xi.combat.damage.calculateDamageAdjustment', 1)
        stub('utils.handlePhalanx', function(_, damage)
            return damage
        end)

        stub('utils.handleOneForAll', function(_, damage)
            return damage
        end)

        stub('utils.handleStoneskin', function(_, damage)
            return damage
        end)

        stub('math.randomInt', 1)
    end

    local function getResource(entity, resource)
        if resource == 'HP' then
            return entity:getHP()
        elseif resource == 'MP' then
            return entity:getMP()
        end

        return entity:getTP()
    end

    local function setResource(entity, resource, value)
        if resource == 'HP' then
            entity:setHP(value)
        elseif resource == 'MP' then
            entity:setMP(value)
        else
            entity:setTP(value)
        end
    end

    local function observeDrainTransfer(resource)
        local executeSingleResourceDrain = xi.additionalEffect.executeSingleResourceDrain
        local observation =
        {
            count = 0,
        }

        stub('xi.additionalEffect.executeSingleResourceDrain', function(actor, target, params)
            local targetBefore = getResource(target, resource)
            local actorBefore = getResource(actor, resource)
            local subEffect, messageId, amount = executeSingleResourceDrain(actor, target, params)

            observation.count = observation.count + 1
            observation.itemId = params.profile.itemId
            observation.amount = amount
            observation.targetRemoved = targetBefore - getResource(target, resource)
            observation.actorReceived = getResource(actor, resource) - actorBefore

            return subEffect, messageId, amount
        end)

        return observation
    end

    local function spawnCombatants(job)
        local player = xi.test.world:spawnPlayer(
            {
                zone  = xi.zone.WEST_RONFAURE,
                job   = job,
                level = 99,
            })
        player:setMod(xi.mod.ACC, 1000)
        player:setMaxHP(1000)
        player:setHP(500)
        player:setMaxMP(1000)
        player:setMP(500)
        player:setTP(500)

        local target = player.entities:moveTo('Wild_Rabbit')
        target:despawn()
        target:respawn()
        target:setMobLevel(99, true)
        target:setMod(xi.mod.EVA, -1000)
        target:setMaxHP(100000)
        target:setHP(target:getMaxHP())
        target:setMaxMP(1000)
        target:setMP(500)
        target:setTP(500)
        target:setUnkillable(true)

        return player, target
    end

    local function equipMain(player, itemId)
        player:addItem(itemId)
        player:equipItem(itemId, nil, xi.slot.MAIN)
        local item = player:getEquippedItem(xi.slot.MAIN)
        assert(item and item:getID() == itemId, 'main-hand test weapon was not equipped')

        return item
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
    end)

    for _, case in ipairs(cases) do
        it(string.format(
            'serializes one %s transfer through a real main-hand attack',
            case.name), function()
            isolateLegacyDrainFormula()
            local observation = observeDrainTransfer(case.resource)
            local player, target = spawnCombatants(case.job)
            equipMain(player, case.itemId)
            setResource(player, case.resource, case.resource == 'HP' and 500 or 0)
            setResource(target, case.resource, 500)

            local actions = performFirstAttack(player, target)
            local results = flattenedResults(actions)
            local procResults = {}
            for _, result in ipairs(results) do
                if result.has_proc then
                    table.insert(procResults, result)
                end
            end

            assert(#actions == 1, string.format('expected one attack action, got %u', #actions))
            assert(#procResults == 1, string.format('expected one drain result, got %u', #procResults))
            local result = procResults[1]
            assert(result.proc_kind == case.subEffect)
            assert(
                result.proc_message == case.message,
                string.format('expected proc message %u, got %u', case.message, result.proc_message))
            assert(result.proc_value == case.amount)

            assert(observation.count == 1)
            assert(observation.itemId == case.itemId)
            assert(observation.amount == result.proc_value)
            assert(observation.targetRemoved == result.proc_value)
            assert(observation.actorReceived == result.proc_value)
        end)

        it(string.format(
            'does not execute %s after a physical miss',
            case.name), function()
            isolateLegacyDrainFormula()
            local executor = spy('xi.additionalEffect.executeSingleResourceDrain')
            local player, target = spawnCombatants(case.job)
            equipMain(player, case.itemId)
            player:setMod(xi.mod.ACC, -10000)
            target:setMod(xi.mod.EVA, 10000)
            local results = flattenedResults(performFirstAttack(player, target))

            assert(#results > 0)
            for _, result in ipairs(results) do
                assert(not result.has_proc)
            end

            executor:called(0)
        end)

        it(string.format(
            'suppresses %s below its item level while preserving the physical attack',
            case.name), function()
            isolateLegacyDrainFormula()
            local executor = spy('xi.additionalEffect.executeSingleResourceDrain')
            local player, target = spawnCombatants(case.job)
            equipMain(player, case.itemId)
            player:levelRestriction(case.level - 1)
            player:setMod(xi.mod.ACC, 1000)
            local results = flattenedResults(performFirstAttack(player, target))

            assert(#results > 0)
            for _, result in ipairs(results) do
                assert(not result.has_proc)
            end

            executor:called(0)
        end)
    end

    for _, case in ipairs({ cases[1], cases[2] }) do
        it(string.format(
            'selects %s from the off hand without a script duplicate',
            case.name), function()
            isolateLegacyDrainFormula()
            local executor = spy('xi.additionalEffect.executeSingleResourceDrain')
            local player, target = spawnCombatants(case.offhandJob or xi.job.NIN)
            equipMain(player, xi.item.BRONZE_KNIFE)
            player:addItem(case.itemId)
            player:equipItem(case.itemId, nil, xi.slot.SUB)
            local sub = player:getEquippedItem(xi.slot.SUB)
            assert(sub and sub:getID() == case.itemId, 'off-hand drain weapon was not equipped')
            setResource(player, case.resource, case.resource == 'HP' and 500 or 0)
            setResource(target, case.resource, 500)

            local results = flattenedResults(performFirstAttack(player, target))
            local procResults = {}
            for _, result in ipairs(results) do
                if result.has_proc then
                    table.insert(procResults, result)
                end
            end

            assert(#procResults == 1)
            assert(procResults[1].proc_kind == case.subEffect)
            assert(procResults[1].proc_value == case.amount)
            executor:called(1)
            assert(executor.calls[1].args[3].profile.itemId == case.itemId)
        end)
    end

    it('lets an Enspell retain priority over the scoped item effect', function()
        isolateLegacyDrainFormula()
        local executor = spy('xi.additionalEffect.executeSingleResourceDrain')
        local player, target = spawnCombatants(xi.job.WAR)
        equipMain(player, xi.item.BLOODY_RAPIER)
        player:addStatusEffect(xi.effect.ENFIRE, { power = 9, duration = 60, origin = player })

        local results = flattenedResults(performFirstAttack(player, target))
        local procResults = {}
        for _, result in ipairs(results) do
            if result.has_proc then
                table.insert(procResults, result)
            end
        end

        assert(#procResults == 1)
        assert(procResults[1].proc_kind == xi.subEffect.FIRE_DAMAGE)
        executor:called(0)
    end)

    it('honors explicit item additional-effect priority without double execution', function()
        isolateLegacyDrainFormula()
        local executor = spy('xi.additionalEffect.executeSingleResourceDrain')
        local player, target = spawnCombatants(xi.job.WAR)
        local item = equipMain(player, xi.item.BLOODY_RAPIER)
        item:addMod(xi.mod.ITEM_ADDEFFECT_PRIORITY, 1)
        player:addStatusEffect(xi.effect.ENFIRE, { power = 9, duration = 60, origin = player })

        local results = flattenedResults(performFirstAttack(player, target))
        local procResults = {}
        for _, result in ipairs(results) do
            if result.has_proc then
                table.insert(procResults, result)
            end
        end

        assert(#procResults == 1)
        assert(procResults[1].proc_kind == xi.subEffect.HP_DRAIN)
        assert(procResults[1].proc_message == xi.msg.basic.ADD_EFFECT_HP_DRAIN)
        executor:called(1)
    end)

    it('owns one drain result per legitimate multi-attack swing', function()
        isolateLegacyDrainFormula()
        local executor = spy('xi.additionalEffect.executeSingleResourceDrain')
        local player, target = spawnCombatants(xi.job.SAM)
        equipMain(player, xi.item.SHINSOKU)
        player:setMod(xi.mod.DOUBLE_ATTACK, 100)

        local results = flattenedResults(performFirstAttack(player, target))
        local procCount = 0
        for _, result in ipairs(results) do
            if result.has_proc then
                procCount = procCount + 1
                assert(result.proc_kind == xi.subEffect.TP_DRAIN)
                assert(result.proc_value == 10)
            end
        end

        assert(#results == 2)
        assert(procCount == 2)
        executor:called(2)
    end)

    it('does no scoped drain work after the selected target despawns', function()
        isolateLegacyDrainFormula()
        local executor = spy('xi.additionalEffect.executeSingleResourceDrain')
        local player, target = spawnCombatants(xi.job.NIN)
        equipMain(player, xi.item.ASPIR_KNIFE)
        player.packets:clear()
        target:setUnkillable(false)
        target:despawn()
        player.actions:engage(target)
        xi.test.world:skipTime(5)
        xi.test.world:tickEntity(player)

        assert(#basicAttackActions(player) == 0)
        executor:called(0)
    end)

    it('leaves an ordinary melee attack without a scoped item unchanged', function()
        isolateLegacyDrainFormula()
        local executor = spy('xi.additionalEffect.executeSingleResourceDrain')
        local player, target = spawnCombatants(xi.job.WAR)
        equipMain(player, xi.item.BRONZE_SWORD)

        local results = flattenedResults(performFirstAttack(player, target))

        assert(#results > 0)
        for _, result in ipairs(results) do
            assert(not result.has_proc)
        end

        executor:called(0)
    end)
end)
