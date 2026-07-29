describe('Vanilla and Zilart single-resource drain profiles', function()
    local player
    local target

    local cases =
    {
        {
            name         = 'Aspir Knife',
            itemId       = xi.item.ASPIR_KNIFE,
            itemName     = 'aspir_knife',
            era          = 'ERA_UNRESOLVED',
            resource     = 'MP',
            family       = xi.additionalEffect.procType.MP_DRAIN,
            chance       = 10,
            amount       = 3,
            equipPolicy  = 'MAIN_OR_OFF_HAND',
            subEffect    = xi.subEffect.MP_DRAIN,
            message      = xi.msg.basic.ADD_EFFECT_MP_DRAIN,
        },
        {
            name         = 'Bloody Rapier',
            itemId       = xi.item.BLOODY_RAPIER,
            itemName     = 'bloody_rapier',
            era          = 'VANILLA',
            resource     = 'HP',
            family       = xi.additionalEffect.procType.HP_DRAIN,
            chance       = 5,
            amount       = 10,
            equipPolicy  = 'MAIN_OR_OFF_HAND',
            subEffect    = xi.subEffect.HP_DRAIN,
            message      = xi.msg.basic.ADD_EFFECT_HP_DRAIN,
        },
        {
            name         = 'Shinsoku',
            itemId       = xi.item.SHINSOKU,
            itemName     = 'shinsoku',
            era          = 'ZILART',
            resource     = 'TP',
            family       = xi.additionalEffect.procType.TP_DRAIN,
            chance       = 8,
            amount       = 10,
            equipPolicy  = 'MAIN_HAND_ONLY',
            subEffect    = xi.subEffect.TP_DRAIN,
            message      = xi.msg.basic.ADD_EFFECT_TP_DRAIN,
        },
    }

    local function copyTable(value)
        if type(value) ~= 'table' then
            return value
        end

        local result = {}
        for key, entry in pairs(value) do
            result[copyTable(key)] = copyTable(entry)
        end

        return result
    end

    local function findItem(itemId)
        player:addItem(itemId)
        local item = player:findItem(itemId)
        assert(item, string.format('test item %u was not created', itemId))

        return item
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

    local function setAttackerMaximums()
        player:setMaxHP(1000)
        player:setHP(1000)
        player:setMaxMP(1000)
        player:setMP(1000)
        player:setTP(3000)
    end

    local function setTargetResources(value)
        target:setMaxHP(1000)
        target:setHP(value)
        target:setMaxMP(1000)
        target:setMP(value)
        target:setTP(value)
    end

    local function isolateLegacyDrainFormula(resistRate, procRoll)
        stub('addBonusesAbility', function(_, element, _, damage)
            assert(element == xi.element.DARK)
            return damage
        end)

        local stubs =
        {
            resistance = stub('applyResistanceAddEffect', resistRate or 1),
            absorption = stub('xi.spells.damage.calculateAbsorption', 1),
            nullification = stub('xi.spells.damage.calculateNullification', 1),
            proc = stub('math.randomInt', procRoll or 1),
        }

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

        return stubs
    end

    before_each(function()
        xi.test.world:setSeed(1)

        player = xi.test.world:spawnPlayer(
            {
                zone  = xi.zone.WEST_RONFAURE,
                job   = xi.job.SAM,
                level = 99,
            })

        target = player.entities:get('Wild_Rabbit')
        target:respawn()
        target:setMobLevel(99, true)
        target:setUnkillable(true)
        setAttackerMaximums()
        setTargetResources(100)
    end)

    it('registers exactly the three independently addressable drain profiles', function()
        assert(xi.additionalEffect.profile.singleResourceDrainProfileCount() == #cases)

        for _, case in ipairs(cases) do
            local policy = xi.additionalEffect.profile.resolveSingleResourceDrain(case.itemId)
            local profile = xi.additionalEffect.profile.resolve(findItem(case.itemId), 0)
            local valid, errors = xi.additionalEffect.profile.validate(profile)

            assert(policy, string.format('%s has no scoped profile', case.name))
            assert(valid, table.concat(errors, '; '))
            assert(profile.singleResourceDrain == policy)
            assert(profile.profileFamily == 'VZ_SINGLE_RESOURCE_DRAIN')
            assert(profile.classification == xi.additionalEffect.profile.classification.VERIFY_LIVE)
            assert(policy.itemName == case.itemName)
            assert(policy.introductionEra == case.era)
            assert(policy.resource == case.resource)
            assert(policy.procFamily == case.family)
            assert(policy.procChance == case.chance)
            assert(policy.baseAmount == case.amount)
            assert(policy.equipPolicy == case.equipPolicy)
            assert(policy.presentationSubEffect == case.subEffect)
            assert(policy.presentationMessage == case.message)
            assert(policy.configuredElement == xi.element.DARK)
            assert(policy.effectiveElement == xi.element.DARK)
            assert(policy.messageAmountPolicy == 'ACTUAL_TARGET_RESOURCE_REMOVED')
            assert(policy.applicationOwnership ==
                'SCOPED_EXECUTOR_APPLIES_TARGET_AND_ATTACKER_ONCE')
            assert(type(policy.fieldClassifications) == 'table')
            assert(#policy.unresolvedEvidence > 0)
        end
    end)

    it('rejects malformed, mismatched, unsupported, and duplicate profiles', function()
        local original =
            copyTable(xi.additionalEffect.profile.resolveSingleResourceDrain(xi.item.ASPIR_KNIFE))

        local mismatchedResource = copyTable(original)
        mismatchedResource.resource = 'HP'
        local mismatchRegistry, mismatchErrors =
            xi.additionalEffect.profile.buildSingleResourceDrainRegistry({ mismatchedResource })
        assert(not mismatchRegistry and #mismatchErrors > 0)

        local mismatchedMessage = copyTable(original)
        mismatchedMessage.presentationMessage = xi.msg.basic.ADD_EFFECT_HP_DRAIN
        local messageRegistry, messageErrors =
            xi.additionalEffect.profile.buildSingleResourceDrainRegistry({ mismatchedMessage })
        assert(not messageRegistry and #messageErrors > 0)

        local unsupported = copyTable(original)
        unsupported.itemId = xi.item.BLOODY_BOLT
        local unsupportedRegistry, unsupportedErrors =
            xi.additionalEffect.profile.buildSingleResourceDrainRegistry({ unsupported })
        assert(not unsupportedRegistry and #unsupportedErrors > 0)

        local duplicateRegistry, duplicateErrors =
            xi.additionalEffect.profile.buildSingleResourceDrainRegistry({ original, original })
        assert(not duplicateRegistry)
        assert(#duplicateErrors == 1)
        assert(string.find(duplicateErrors[1], 'duplicate single-resource drain', 1, true))
    end)

    it('leaves combined, scripted, and later drain items outside the registry', function()
        for _, itemId in ipairs({
            xi.item.HOFUD,
            20706, -- Vampirism
            xi.item.BLOODY_BOLT,
            18856, -- Zareehkl Scythe
        }) do
            assert(not xi.additionalEffect.profile.resolveSingleResourceDrain(itemId))
        end

        for _, itemId in ipairs({ xi.item.HOFUD, 20706 }) do
            local profile = xi.additionalEffect.profile.resolve(findItem(itemId), 0)
            assert(not profile.singleResourceDrain)
            assert(profile.profileFamily == 'SQL_MODIFIER_GENERIC')
        end
    end)

    for _, case in ipairs(cases) do
        it(string.format(
            'runs %s through one validated calculation and one transfer',
            case.name), function()
            isolateLegacyDrainFormula()
            local calculator = spy('xi.additionalEffect.calcDamage')
            local executor = spy('xi.additionalEffect.executeSingleResourceDrain')
            setResource(player, case.resource, 0)

            local targetBefore = getResource(target, case.resource)
            local attackerBefore = getResource(player, case.resource)
            local subEffect, messageId, amount =
                xi.additionalEffect.attack(player, target, 0, findItem(case.itemId))

            assert(subEffect == case.subEffect)
            assert(messageId == case.message)
            assert(amount == case.amount)
            assert(targetBefore - getResource(target, case.resource) == amount)
            assert(getResource(player, case.resource) - attackerBefore == amount)
            calculator:called(1)
            executor:called(1)
        end)
    end

    for _, case in ipairs(cases) do
        it(string.format(
            'performs one %s proc roll and no downstream work after failure',
            case.name), function()
            local procRolls = 0
            stub('math.randomInt', function(minimum, maximum)
                assert(minimum == 1 and maximum == 100)
                procRolls = procRolls + 1
                return case.chance + 1
            end)

            local calculator = spy('xi.additionalEffect.calcDamage')
            local executor = spy('xi.additionalEffect.executeSingleResourceDrain')
            local before = getResource(target, case.resource)
            local subEffect, messageId, amount =
                xi.additionalEffect.attack(player, target, 0, findItem(case.itemId))

            assert(subEffect == 0 and messageId == 0 and amount == 0)
            assert(getResource(target, case.resource) == before)
            assert(procRolls == 1)
            calculator:called(0)
            executor:called(0)
        end)
    end

    for _, case in ipairs(cases) do
        it(string.format(
            'preserves the %s SQL proc boundary without level correction',
            case.name), function()
            local stubs = isolateLegacyDrainFormula(nil, case.chance)

            assert(xi.additionalEffect.levelCorrectRates(120, 99, case.chance, 0) == case.chance)

            local subEffect = xi.additionalEffect.attack(
                player,
                target,
                0,
                findItem(case.itemId))
            assert(subEffect == case.subEffect)

            setTargetResources(100)
            stubs.proc:returnValue(case.chance + 1)
            subEffect = xi.additionalEffect.attack(
                player,
                target,
                0,
                findItem(case.itemId))
            assert(subEffect == 0)
        end)
    end

    it('returns no drain for an invalid target and does no scoped work', function()
        isolateLegacyDrainFormula()
        local executor = spy('xi.additionalEffect.executeSingleResourceDrain')

        local subEffect, messageId, amount =
            xi.additionalEffect.attack(player, nil, 0, findItem(xi.item.ASPIR_KNIFE))

        assert(subEffect == 0 and messageId == 0 and amount == 0)
        executor:called(0)
    end)

    it('blocks every scoped item above the effective level before profile resolution', function()
        local resolver = spy('xi.additionalEffect.profile.resolve')
        player:setLevel(1)

        for _, case in ipairs(cases) do
            local subEffect, messageId, amount =
                xi.additionalEffect.attack(player, target, 0, findItem(case.itemId))
            assert(subEffect == 0 and messageId == 0 and amount == 0)
        end

        resolver:called(0)
    end)

    for _, case in ipairs(cases) do
        for _, boundary in ipairs({
            { name = 'below', difference = -1 },
            { name = 'equal', difference = 0 },
            { name = 'above', difference = 1 },
        }) do
            it(string.format(
                'caps %s at a target resource %s the configured amount',
                case.name,
                boundary.name), function()
                isolateLegacyDrainFormula()
                local targetResource = case.amount + boundary.difference
                if case.resource == 'HP' then
                    target:setUnkillable(false)
                end

                setResource(target, case.resource, targetResource)
                setResource(player, case.resource, 0)

                local targetBefore = getResource(target, case.resource)
                local subEffect, messageId, amount =
                    xi.additionalEffect.attack(player, target, 0, findItem(case.itemId))
                local expected = math.min(case.amount, targetBefore)

                assert(subEffect == case.subEffect)
                assert(messageId == case.message)
                assert(amount == expected)
                assert(targetBefore - getResource(target, case.resource) == expected)
                assert(getResource(player, case.resource) == expected)
            end)
        end
    end

    for _, case in ipairs(cases) do
        it(string.format(
            'reports %s target removal when the attacker is capped',
            case.name), function()
            isolateLegacyDrainFormula()
            setResource(target, case.resource, 100)

            local attackerMaximum = case.resource == 'TP' and 3000 or 1000
            for _, startingValue in ipairs({ attackerMaximum - 1, attackerMaximum }) do
                setResource(player, case.resource, startingValue)
                setResource(target, case.resource, 100)
                local targetBefore = getResource(target, case.resource)

                local _, messageId, amount =
                    xi.additionalEffect.attack(player, target, 0, findItem(case.itemId))

                assert(messageId == case.message)
                assert(amount == case.amount)
                assert(targetBefore - getResource(target, case.resource) == amount)
                assert(getResource(player, case.resource) <= attackerMaximum)
            end
        end)
    end

    for _, case in ipairs(cases) do
        it(string.format(
            'preserves %s zero-resource presentation without mutation',
            case.name), function()
            isolateLegacyDrainFormula()
            if case.resource == 'HP' then
                target:setUnkillable(false)
            end

            setResource(target, case.resource, 0)
            setResource(player, case.resource, 0)

            local subEffect, messageId, amount =
                xi.additionalEffect.attack(player, target, 0, findItem(case.itemId))

            if case.resource == 'HP' then
                assert(target:isDead())
                assert(subEffect == 0)
                assert(messageId == 0)
            else
                assert(subEffect == case.subEffect)
                assert(messageId == case.message)
            end

            assert(amount == 0)
            assert(getResource(target, case.resource) == 0)
            assert(getResource(player, case.resource) == 0)
        end)
    end

    it('rejects a dead target before any scoped calculation or proc roll', function()
        target:setUnkillable(false)
        target:setHP(0)
        assert(target:isDead())

        local calculator = spy('xi.additionalEffect.calcDamage')
        local executor = spy('xi.additionalEffect.executeSingleResourceDrain')
        local proc = spy('math.randomInt')

        for _, case in ipairs(cases) do
            local subEffect, messageId, amount =
                xi.additionalEffect.attack(player, target, 0, findItem(case.itemId))
            assert(subEffect == 0 and messageId == 0 and amount == 0)
        end

        proc:called(0)
        calculator:called(0)
        executor:called(0)
    end)

    for _, case in ipairs(cases) do
        it(string.format(
            'preserves %s legacy resistance tiers and rounding',
            case.name), function()
            local stubs = isolateLegacyDrainFormula()
            local expectedByTier =
                case.amount == 3 and { 3, 1, 0, 0, 0 } or { 10, 5, 2, 1, 0 }

            for index, tier in ipairs({ 1, 0.5, 0.25, 0.125, 0.0625 }) do
                stubs.resistance:returnValue(tier)
                setResource(target, case.resource, 100)
                setResource(player, case.resource, 0)

                local _, messageId, amount =
                    xi.additionalEffect.attack(player, target, 0, findItem(case.itemId))

                assert(messageId == case.message)
                assert(amount == expectedByTier[index])
                assert(100 - getResource(target, case.resource) == amount)
            end
        end)
    end

    it('applies the legacy defense stack once to every scoped resource', function()
        stub('addBonusesAbility', function(_, _, _, damage)
            return damage
        end)

        stub('applyResistanceAddEffect', 1)
        stub('xi.spells.damage.calculateAbsorption', 1)
        stub('xi.spells.damage.calculateNullification', 1)
        stub('xi.combat.damage.calculateDamageAdjustment', 1)
        stub('math.randomInt', 1)

        local calls = { phalanx = 0, oneForAll = 0, stoneskin = 0 }
        stub('utils.handlePhalanx', function(_, damage)
            calls.phalanx = calls.phalanx + 1
            return damage - 1
        end)

        stub('utils.handleOneForAll', function(_, damage)
            calls.oneForAll = calls.oneForAll + 1
            return damage - 1
        end)

        stub('utils.handleStoneskin', function(_, damage)
            calls.stoneskin = calls.stoneskin + 1
            return damage - 1
        end)

        for _, case in ipairs(cases) do
            setResource(target, case.resource, 100)
            setResource(player, case.resource, 0)
            local _, _, amount =
                xi.additionalEffect.attack(player, target, 0, findItem(case.itemId))
            assert(amount == math.max(case.amount - 3, 0))
        end

        assert(calls.phalanx == 3)
        assert(calls.oneForAll == 3)
        assert(calls.stoneskin == 3)
    end)

    for _, case in ipairs(cases) do
        it(string.format(
            'clamps absorbed %s compatibility damage to no transfer',
            case.name), function()
            local stubs = isolateLegacyDrainFormula()
            stubs.absorption:returnValue(-1)

            local targetBefore = getResource(target, case.resource)
            local attackerBefore = getResource(player, case.resource)
            local subEffect, messageId, amount =
                xi.additionalEffect.attack(player, target, 0, findItem(case.itemId))

            assert(subEffect == case.subEffect)
            assert(messageId == case.message)
            assert(amount == 0)
            assert(getResource(target, case.resource) == targetBefore)
            assert(getResource(player, case.resource) == attackerBefore)
            stubs.absorption:called(1)
            assert(stubs.absorption.calls[1].args[2] == xi.element.DARK)
        end)

        it(string.format(
            'honors one nullification result for %s without transfer',
            case.name), function()
            local stubs = isolateLegacyDrainFormula()
            stubs.nullification:returnValue(0)

            local targetBefore = getResource(target, case.resource)
            local attackerBefore = getResource(player, case.resource)
            local subEffect, messageId, amount =
                xi.additionalEffect.attack(player, target, 0, findItem(case.itemId))

            assert(subEffect == case.subEffect)
            assert(messageId == case.message)
            assert(amount == 0)
            assert(getResource(target, case.resource) == targetBefore)
            assert(getResource(player, case.resource) == attackerBefore)
            stubs.nullification:called(1)
            assert(stubs.nullification.calls[1].args[2] == xi.element.DARK)
        end)
    end

    it('keeps MP and TP drains isolated from both actors HP and other resources', function()
        isolateLegacyDrainFormula()

        for _, case in ipairs({ cases[1], cases[3] }) do
            setTargetResources(100)
            setAttackerMaximums()
            setResource(player, case.resource, 0)
            local before =
            {
                playerHP = player:getHP(),
                playerMP = player:getMP(),
                targetHP = target:getHP(),
                targetMP = target:getMP(),
            }

            xi.additionalEffect.attack(player, target, 0, findItem(case.itemId))

            assert(player:getHP() == before.playerHP)
            assert(target:getHP() == before.targetHP)
            if case.resource == 'TP' then
                assert(player:getMP() == before.playerMP)
                assert(target:getMP() == before.targetMP)
            end
        end
    end)
end)

describe('Vanilla and Zilart single-resource drain undead guard', function()
    local cases =
    {
        { itemId = xi.item.ASPIR_KNIFE, resource = 'MP' },
        { itemId = xi.item.BLOODY_RAPIER, resource = 'HP' },
        { itemId = xi.item.SHINSOKU, resource = 'TP' },
    }

    it('rejects all three drains before calculation against an actual undead target', function()
        local player = xi.test.world:spawnPlayer(
            {
                zone  = xi.zone.BUBURIMU_PENINSULA,
                job   = xi.job.SAM,
                level = 99,
            })
        local target = player.entities:get('Ghoul')
        assert(target and target:isUndead(), 'test target was not an undead mob')
        target:respawn()
        target:setMaxHP(1000)
        target:setHP(100)
        target:setMaxMP(1000)
        target:setMP(100)
        target:setTP(100)
        player:setMaxHP(1000)
        player:setHP(500)
        player:setMaxMP(1000)
        player:setMP(500)
        player:setTP(500)
        stub('math.randomInt', 1)
        local calculator = spy('xi.additionalEffect.calcDamage')

        for _, case in ipairs(cases) do
            player:addItem(case.itemId)
            local item = player:findItem(case.itemId)
            local targetHP = target:getHP()
            local targetMP = target:getMP()
            local targetTP = target:getTP()
            local playerHP = player:getHP()
            local playerMP = player:getMP()
            local playerTP = player:getTP()

            local subEffect, messageId, amount =
                xi.additionalEffect.attack(player, target, 0, item)

            assert(subEffect == 0 and messageId == 0 and amount == 0)
            assert(target:getHP() == targetHP)
            assert(target:getMP() == targetMP)
            assert(target:getTP() == targetTP)
            assert(player:getHP() == playerHP)
            assert(player:getMP() == playerMP)
            assert(player:getTP() == playerTP)
        end

        calculator:called(0)
    end)
end)
