describe('Combined-resource drain compatibility profiles', function()
    local player
    local target

    local cases =
    {
        {
            name        = 'Hofud',
            itemId      = xi.item.HOFUD,
            itemName    = 'hofud',
            eraDate     = '2007-06-06',
            resourceSet = 'HP_OR_MP',
            family      = xi.additionalEffect.procType.HPMP_DRAIN,
            resources   = { 'HP', 'MP' },
            chance      = 15,
            amount      = 15,
            subEffect   = xi.subEffect.DARKNESS_DAMAGE,
        },
        {
            name        = 'Vampirism',
            itemId      = xi.item.VAMPIRISM,
            itemName    = 'vampirism',
            eraDate     = '2015-08-05',
            resourceSet = 'HP_OR_MP_OR_TP',
            family      = xi.additionalEffect.procType.HPMPTP_DRAIN,
            resources   = { 'HP', 'MP', 'TP' },
            chance      = 100,
            amount      = 20,
            subEffect   = xi.subEffect.MP_DRAIN,
        },
        {
            name        = 'Crepuscular Knife',
            itemId      = xi.item.CREPUSCULAR_KNIFE,
            itemName    = 'crepuscular_knife',
            eraDate     = '2021-07-12',
            resourceSet = 'HP_OR_MP_OR_TP',
            family      = xi.additionalEffect.procType.HPMPTP_DRAIN,
            resources   = { 'HP', 'MP', 'TP' },
            chance      = 15,
            amount      = 15,
            subEffect   = xi.subEffect.DARKNESS_DAMAGE,
        },
    }

    local resourceMessages =
    {
        HP = xi.msg.basic.ADD_EFFECT_HP_DRAIN,
        MP = xi.msg.basic.ADD_EFFECT_MP_DRAIN,
        TP = xi.msg.basic.ADD_EFFECT_TP_DRAIN,
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

    local function getResourceMaximum(entity, resource)
        if resource == 'HP' then
            return entity:getMaxHP()
        elseif resource == 'MP' then
            return entity:getMaxMP()
        end

        return 3000
    end

    local function resetResources()
        player:setMaxHP(1000)
        player:setHP(500)
        player:setMaxMP(1000)
        player:setMP(500)
        player:setTP(500)
        target:setMaxHP(1000)
        target:setHP(500)
        target:setMaxMP(1000)
        target:setMP(500)
        target:setTP(500)
    end

    local function isolateLegacyFormula(procRoll, selector, resistRate)
        stub('addBonusesAbility', function(_, element, _, damage)
            assert(element == xi.element.DARK)
            return damage
        end)

        local stubs =
        {
            resistance = stub('applyResistanceAddEffect', resistRate or 1),
            absorption = stub('xi.spells.damage.calculateAbsorption', 1),
            nullification = stub('xi.spells.damage.calculateNullification', 1),
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

        local rolls =
        {
            proc = 0,
            selection = 0,
        }
        stub('math.randomInt', function(minimum, maximum)
            if minimum == 1 and maximum == 100 then
                rolls.proc = rolls.proc + 1
                return procRoll or 1
            end

            rolls.selection = rolls.selection + 1
            return selector or 1
        end)

        return stubs, rolls
    end

    before_each(function()
        xi.test.world:setSeed(1)
        player = xi.test.world:spawnPlayer(
            {
                zone  = xi.zone.WEST_RONFAURE,
                job   = xi.job.WAR,
                level = 99,
            })
        target = player.entities:get('Wild_Rabbit')
        target:respawn()
        target:setMobLevel(99, true)
        target:setUnkillable(true)
        resetResources()
    end)

    it('registers exactly three independently addressable later-expansion profiles', function()
        assert(xi.additionalEffect.profile.combinedResourceDrainProfileCount() == #cases)

        for _, case in ipairs(cases) do
            local policy =
                xi.additionalEffect.profile.resolveCombinedResourceDrain(case.itemId)
            local profile = xi.additionalEffect.profile.resolve(findItem(case.itemId), 0)
            local valid, errors = xi.additionalEffect.profile.validate(profile)

            assert(policy, string.format('%s has no combined profile', case.name))
            assert(valid, table.concat(errors, '; '))
            assert(profile.combinedResourceDrain == policy)
            assert(profile.profileFamily == 'VZ_COMBINED_RESOURCE_DRAIN')
            assert(profile.classification ==
                xi.additionalEffect.profile.classification.VERIFY_LIVE)
            assert(policy.itemName == case.itemName)
            assert(policy.introductionEra ==
                xi.additionalEffect.profile.classification.LATER_EXPANSION)
            assert(policy.introductionDate == case.eraDate)
            assert(policy.resourceSet == case.resourceSet)
            assert(policy.procFamily == case.family)
            assert(policy.procChance == case.chance)
            assert(policy.baseAmount == case.amount)
            assert(policy.presentationSubEffect == case.subEffect)
            assert(policy.configuredElement == xi.element.NONE)
            assert(policy.effectiveElement == xi.element.DARK)
            assert(policy.branchSelectionPolicy ==
                'UNIFORM_SINGLE_BRANCH_NO_RETRY_COMPATIBILITY')
            assert(policy.retryFallbackPolicy ==
                'NO_RETRY_OR_FALLBACK_COMPATIBILITY')
            assert(policy.packetAmountPolicy ==
                'ACTUAL_SELECTED_TARGET_RESOURCE_REMOVED')
            assert(type(policy.fieldClassifications) == 'table')
            assert(#policy.unresolvedEvidence > 0)

            for index, resource in ipairs(case.resources) do
                assert(policy.branchResources[index] == resource)
                assert(policy.resourceMessages[resource] == resourceMessages[resource])
            end
        end
    end)

    it('keeps the Phase B3 and scripted drain registries separate', function()
        for _, case in ipairs(cases) do
            assert(not xi.additionalEffect.profile.resolveSingleResourceDrain(case.itemId))
        end

        for _, itemId in ipairs({
            xi.item.ASPIR_KNIFE,
            xi.item.BLOODY_RAPIER,
            xi.item.SHINSOKU,
            xi.item.BLOODY_BOLT,
        }) do
            assert(not xi.additionalEffect.profile.resolveCombinedResourceDrain(itemId))
        end
    end)

    it('rejects malformed, mismatched, unsupported, and duplicate profiles', function()
        local original =
            copyTable(xi.additionalEffect.profile.resolveCombinedResourceDrain(xi.item.HOFUD))

        local missingElement = copyTable(original)
        missingElement.effectiveElement = nil
        local missingRegistry, missingErrors =
            xi.additionalEffect.profile.buildCombinedResourceDrainRegistry({ missingElement })
        assert(not missingRegistry and #missingErrors > 0)

        local missingMessages = copyTable(original)
        missingMessages.resourceMessages = nil
        local messageRegistry, messageErrors =
            xi.additionalEffect.profile.buildCombinedResourceDrainRegistry({ missingMessages })
        assert(not messageRegistry and #messageErrors > 0)

        local mismatchedSet = copyTable(original)
        mismatchedSet.resourceSet = 'HP_OR_MP_OR_TP'
        local mismatchRegistry, mismatchErrors =
            xi.additionalEffect.profile.buildCombinedResourceDrainRegistry({ mismatchedSet })
        assert(not mismatchRegistry and #mismatchErrors > 0)

        local unsupportedPolicy = copyTable(original)
        unsupportedPolicy.branchSelectionPolicy = 'SEQUENTIAL_RETRY'
        local policyRegistry, policyErrors =
            xi.additionalEffect.profile.buildCombinedResourceDrainRegistry({ unsupportedPolicy })
        assert(not policyRegistry and #policyErrors > 0)

        local unsupported = copyTable(original)
        unsupported.itemId = xi.item.BLOODY_BOLT
        local unsupportedRegistry, unsupportedErrors =
            xi.additionalEffect.profile.buildCombinedResourceDrainRegistry({ unsupported })
        assert(not unsupportedRegistry and #unsupportedErrors > 0)

        local duplicateRegistry, duplicateErrors =
            xi.additionalEffect.profile.buildCombinedResourceDrainRegistry({ original, original })
        assert(not duplicateRegistry and #duplicateErrors == 1)
        assert(string.find(duplicateErrors[1], 'duplicate combined-resource drain', 1, true))
    end)

    it('maps every compatibility selector and rejects invalid selector values safely', function()
        for _, case in ipairs(cases) do
            local policy =
                xi.additionalEffect.profile.resolveCombinedResourceDrain(case.itemId)
            for selector, resource in ipairs(case.resources) do
                assert(xi.additionalEffect.selectCombinedResourceDrainBranch(
                    policy,
                    selector) == resource)
            end

            for _, selector in ipairs({ -1, 0, #case.resources + 1, 1.5 }) do
                assert(not xi.additionalEffect.selectCombinedResourceDrainBranch(
                    policy,
                    selector))
            end
        end

        assert(not xi.additionalEffect.selectCombinedResourceDrainBranch(nil, 1))
    end)

    for _, case in ipairs(cases) do
        for selector, resource in ipairs(case.resources) do
            it(string.format(
                'selects %s %s once after one successful overall proc',
                case.name,
                resource), function()
                local _, rolls = isolateLegacyFormula(1, selector)
                local calculator = spy('xi.additionalEffect.calcDamage')
                local transfer = spy('xi.additionalEffect.executeResourceDrainTransfer')
                local executor = spy('xi.additionalEffect.executeCombinedResourceDrain')
                setResource(player, resource, 0)

                local targetBefore = getResource(target, resource)
                local attackerBefore = getResource(player, resource)
                local subEffect, messageId, amount =
                    xi.additionalEffect.attack(player, target, 0, findItem(case.itemId))

                assert(subEffect == case.subEffect)
                assert(messageId == resourceMessages[resource])
                assert(amount == case.amount)
                assert(targetBefore - getResource(target, resource) == amount)
                assert(getResource(player, resource) - attackerBefore == amount)
                assert(rolls.proc == 1 and rolls.selection == 1)
                calculator:called(1)
                transfer:called(1)
                executor:called(1)
                assert(transfer.calls[1].args[5] == resource)
            end)
        end
    end

    for _, case in ipairs(cases) do
        if case.chance < 100 then
            it(string.format(
                'does no %s selection or transfer after overall proc failure',
                case.name), function()
                local _, rolls = isolateLegacyFormula(case.chance + 1, 1)
                local calculator = spy('xi.additionalEffect.calcDamage')
                local executor = spy('xi.additionalEffect.executeCombinedResourceDrain')
                local subEffect, messageId, amount =
                    xi.additionalEffect.attack(
                        player,
                        target,
                        0,
                        findItem(case.itemId))

                assert(subEffect == 0 and messageId == 0 and amount == 0)
                assert(rolls.proc == 1 and rolls.selection == 0)
                calculator:called(0)
                executor:called(0)
            end)
        else
            it(string.format(
                'keeps %s eligible at the configured 100 percent boundary',
                case.name), function()
                local _, rolls = isolateLegacyFormula(100, 1)
                local executor = spy('xi.additionalEffect.executeCombinedResourceDrain')
                local _, _, amount =
                    xi.additionalEffect.attack(
                        player,
                        target,
                        0,
                        findItem(case.itemId))

                assert(amount == case.amount)
                assert(rolls.proc == 1 and rolls.selection == 1)
                executor:called(1)
            end)
        end
    end

    for _, case in ipairs(cases) do
        for selector, resource in ipairs(case.resources) do
            it(string.format(
                'caps %s %s at target and attacker resource boundaries',
                case.name,
                resource), function()
                isolateLegacyFormula(1, selector)

                for _, targetValue in ipairs({
                    case.amount - 1,
                    case.amount,
                    case.amount + 1,
                }) do
                    if resource == 'HP' then
                        target:despawn()
                        target:respawn()
                        target:setUnkillable(false)
                    end

                    resetResources()
                    local attackerMaximum = getResourceMaximum(player, resource)
                    setResource(target, resource, targetValue)
                    setResource(player, resource, attackerMaximum - 1)
                    local targetBefore = getResource(target, resource)

                    local subEffect, messageId, amount =
                        xi.additionalEffect.attack(
                            player,
                            target,
                            0,
                            findItem(case.itemId))
                    local expected = math.min(case.amount, targetBefore)

                    assert(subEffect == case.subEffect)
                    assert(messageId == resourceMessages[resource])
                    assert(amount == expected)
                    assert(targetBefore - getResource(target, resource) == expected)
                    assert(getResource(player, resource) <= attackerMaximum)
                end

                resetResources()
                local attackerMaximum = getResourceMaximum(player, resource)
                setResource(player, resource, attackerMaximum)
                local targetBefore = getResource(target, resource)
                local _, messageId, amount =
                    xi.additionalEffect.attack(player, target, 0, findItem(case.itemId))
                assert(messageId == resourceMessages[resource])
                assert(amount == case.amount)
                assert(targetBefore - getResource(target, resource) == amount)
                assert(getResource(player, resource) == attackerMaximum)
            end)
        end
    end

    for _, case in ipairs(cases) do
        for selector, resource in ipairs(case.resources) do
            it(string.format(
                'preserves %s %s compatibility resistance tiers without fallback',
                case.name,
                resource), function()
                local stubs, rolls = isolateLegacyFormula(1, selector)
                local expectedByTier =
                    case.amount == 20 and { 20, 10, 5, 2, 1, 0 } or
                    { 15, 7, 3, 1, 0, 0 }

                for index, tier in ipairs({ 1, 0.5, 0.25, 0.125, 0.0625, 0 }) do
                    stubs.resistance:returnValue(tier)
                    resetResources()
                    setResource(player, resource, 0)
                    local targetBefore = getResource(target, resource)

                    local subEffect, messageId, amount =
                        xi.additionalEffect.attack(
                            player,
                            target,
                            0,
                            findItem(case.itemId))

                    assert(subEffect == case.subEffect)
                    assert(messageId == resourceMessages[resource])
                    assert(amount == expectedByTier[index])
                    assert(targetBefore - getResource(target, resource) == amount)
                end

                assert(rolls.selection == 6)
            end)
        end
    end

    it('does not retry selected empty MP or TP branches', function()
        for _, selection in ipairs({
            { case = cases[1], selector = 2, resource = 'MP' },
            { case = cases[2], selector = 2, resource = 'MP' },
            { case = cases[2], selector = 3, resource = 'TP' },
        }) do
            resetResources()
            local _, rolls = isolateLegacyFormula(1, selection.selector)
            setResource(target, selection.resource, 0)
            local hpBefore = target:getHP()
            local mpBefore = target:getMP()
            local tpBefore = target:getTP()

            local subEffect, messageId, amount =
                xi.additionalEffect.attack(
                    player,
                    target,
                    0,
                    findItem(selection.case.itemId))

            assert(subEffect == selection.case.subEffect)
            assert(messageId == resourceMessages[selection.resource])
            assert(amount == 0)
            assert(target:getHP() == hpBefore)
            assert(target:getMP() == mpBefore)
            assert(target:getTP() == tpBefore)
            assert(rolls.selection == 1)
        end
    end)

    it('does not retry selected nullified or absorbed branches', function()
        for _, case in ipairs(cases) do
            for selector, resource in ipairs(case.resources) do
                for _, mode in ipairs({ 'nullified', 'absorbed' }) do
                    resetResources()
                    local stubs, rolls = isolateLegacyFormula(1, selector)
                    if mode == 'nullified' then
                        stubs.nullification:returnValue(0)
                    else
                        stubs.absorption:returnValue(-1)
                    end

                    local before =
                    {
                        playerHP = player:getHP(),
                        playerMP = player:getMP(),
                        playerTP = player:getTP(),
                        targetHP = target:getHP(),
                        targetMP = target:getMP(),
                        targetTP = target:getTP(),
                    }
                    local subEffect, messageId, amount =
                        xi.additionalEffect.attack(
                            player,
                            target,
                            0,
                            findItem(case.itemId))

                    assert(subEffect == case.subEffect)
                    assert(messageId == resourceMessages[resource])
                    assert(amount == 0)
                    assert(player:getHP() == before.playerHP)
                    assert(player:getMP() == before.playerMP)
                    assert(player:getTP() == before.playerTP)
                    assert(target:getHP() == before.targetHP)
                    assert(target:getMP() == before.targetMP)
                    assert(target:getTP() == before.targetTP)
                    assert(rolls.selection == 1)
                end
            end
        end
    end)

    it('rejects dead targets before proc, selection, calculation, or transfer', function()
        target:setUnkillable(false)
        target:setHP(0)
        assert(target:isDead())
        local _, rolls = isolateLegacyFormula(1, 1)
        local calculator = spy('xi.additionalEffect.calcDamage')
        local executor = spy('xi.additionalEffect.executeCombinedResourceDrain')

        for _, case in ipairs(cases) do
            local subEffect, messageId, amount =
                xi.additionalEffect.attack(player, target, 0, findItem(case.itemId))
            assert(subEffect == 0 and messageId == 0 and amount == 0)
        end

        assert(rolls.proc == 0 and rolls.selection == 0)
        calculator:called(0)
        executor:called(0)
    end)

    it('returns no combined drain for invalid targets', function()
        isolateLegacyFormula(1, 1)
        local executor = spy('xi.additionalEffect.executeCombinedResourceDrain')
        local subEffect, messageId, amount =
            xi.additionalEffect.attack(player, nil, 0, findItem(xi.item.HOFUD))

        assert(subEffect == 0 and messageId == 0 and amount == 0)
        executor:called(0)
    end)

    it('keeps every nonselected actor and target resource isolated', function()
        for _, case in ipairs(cases) do
            for selector, resource in ipairs(case.resources) do
                resetResources()
                isolateLegacyFormula(1, selector)
                setResource(player, resource, 0)
                local before =
                {
                    playerHP = player:getHP(),
                    playerMP = player:getMP(),
                    playerTP = player:getTP(),
                    targetHP = target:getHP(),
                    targetMP = target:getMP(),
                    targetTP = target:getTP(),
                }

                xi.additionalEffect.attack(player, target, 0, findItem(case.itemId))

                for _, other in ipairs({ 'HP', 'MP', 'TP' }) do
                    if other ~= resource then
                        local playerBefore = before['player' .. other]
                        local targetBefore = before['target' .. other]
                        assert(getResource(player, other) == playerBefore)
                        assert(getResource(target, other) == targetBefore)
                    end
                end
            end
        end
    end)
end)

describe('Combined-resource drain undead no-retry guard', function()
    it('blocks every selected branch without calculation or fallback', function()
        local player = xi.test.world:spawnPlayer(
            {
                zone  = xi.zone.BUBURIMU_PENINSULA,
                job   = xi.job.WAR,
                level = 99,
            })
        local target = player.entities:get('Ghoul')
        assert(target and target:isUndead(), 'test target was not an undead mob')
        target:respawn()
        target:setMaxHP(1000)
        target:setHP(500)
        target:setMaxMP(1000)
        target:setMP(500)
        target:setTP(500)
        local cases =
        {
            { itemId = xi.item.HOFUD, resources = { 'HP', 'MP' } },
            { itemId = xi.item.VAMPIRISM, resources = { 'HP', 'MP', 'TP' } },
            { itemId = xi.item.CREPUSCULAR_KNIFE, resources = { 'HP', 'MP', 'TP' } },
        }
        local calculator = spy('xi.additionalEffect.calcDamage')

        for _, case in ipairs(cases) do
            player:addItem(case.itemId)
            local item = player:findItem(case.itemId)
            assert(item)

            for selector in ipairs(case.resources) do
                local selections = 0
                stub('math.randomInt', function(_, maximum)
                    if maximum == 100 then
                        return 1
                    end

                    selections = selections + 1
                    return selector
                end)

                local beforeHP = target:getHP()
                local beforeMP = target:getMP()
                local beforeTP = target:getTP()

                local subEffect, messageId, amount =
                    xi.additionalEffect.attack(player, target, 0, item)

                assert(subEffect == 0 and messageId == 0 and amount == 0)
                assert(target:getHP() == beforeHP)
                assert(target:getMP() == beforeMP)
                assert(target:getTP() == beforeTP)
                assert(selections == 1)
            end
        end

        calculator:called(0)
    end)
end)
