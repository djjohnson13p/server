describe('Vanilla and Zilart Dispel weapon profiles', function()
    local player
    local target

    local cases =
    {
        {
            name   = 'Lockheart',
            itemId = xi.item.LOCKHEART,
            chance = 5,
            level  = 64,
        },
        {
            name   = 'Mythril Heart',
            itemId = xi.item.MYTHRIL_HEART,
            chance = 10,
            level  = 66,
        },
        {
            name   = 'Mythril Heart +1',
            itemId = xi.item.MYTHRIL_HEART_PLUS_1,
            chance = 10,
            level  = 66,
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

    local function addEffect(effectId, flag, duration)
        target:addStatusEffect(
            effectId,
            {
                power    = 10,
                duration = duration == nil and 60 or duration,
                origin   = player,
                flag     = flag,
            })
        assert(target:hasStatusEffect(effectId))
    end

    local function addDispellable(effectId)
        addEffect(effectId, xi.effectFlag.DISPELABLE, 60)
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
    end)

    it('registers exactly the three era-qualified candidate profiles', function()
        assert(xi.additionalEffect.profile.dispelWeaponProfileCount() == #cases)

        for _, case in ipairs(cases) do
            local policy = xi.additionalEffect.profile.resolveDispelWeapon(case.itemId)
            local profile = xi.additionalEffect.profile.resolve(findItem(case.itemId), 0)
            local valid, errors = xi.additionalEffect.profile.validate(profile)

            assert(policy, string.format('%s has no Dispel profile', case.name))
            assert(valid, table.concat(errors, '; '))
            assert(profile.dispelWeapon == policy)
            assert(profile.profileFamily == 'VZ_DISPEL_WEAPON')
            assert(profile.classification ==
                xi.additionalEffect.profile.classification.VERIFY_LIVE)
            assert(policy.introductionEra ==
                xi.additionalEffect.profile.classification.VANILLA_OR_ZILART)
            assert(policy.procFamily == xi.additionalEffect.procType.DISPEL)
            assert(policy.procChance == case.chance)
            assert(policy.levelCorrection == 0)
            assert(policy.equipPolicy == 'MAIN_HAND_TWO_HANDED_GREAT_SWORD')
            assert(policy.selectionPolicy ==
                'UNIFORM_RANDOM_DISPELABLE_POSITIVE_DURATION_COMPATIBILITY')
            assert(policy.removalOwnership ==
                'STATUS_CONTAINER_SELECTS_AND_REMOVES_ONE_EFFECT_ONCE')
            assert(policy.retryFallbackPolicy ==
                'NO_RETRY_OR_FALLBACK_COMPATIBILITY')
            assert(policy.accuracyPolicy ==
                'NO_MAGIC_ACCURACY_LAYER_COMPATIBILITY')
            assert(policy.configuredElement == xi.element.NONE)
            assert(policy.effectiveElement == xi.element.NONE)
            assert(policy.resistancePolicy ==
                'NO_RESISTANCE_LAYER_COMPATIBILITY')
            assert(policy.presentationSubEffect == xi.subEffect.DARKNESS_DAMAGE)
            assert(policy.presentationMessage == xi.msg.basic.ADD_EFFECT_DISPEL)
            assert(type(policy.fieldClassifications) == 'table')
            assert(#policy.unresolvedEvidence > 0)
        end
    end)

    it('keeps every out-of-scope Dispel item outside the exact registry', function()
        for _, itemId in ipairs({
            16942, -- Balmung
            xi.item.CLAUSTRUM_75,
            xi.item.ZANMATO_P1,
        }) do
            assert(not xi.additionalEffect.profile.resolveDispelWeapon(itemId))
        end
    end)

    it('rejects unsupported, duplicate, missing, and drifted definitions', function()
        local original =
            copyTable(xi.additionalEffect.profile.resolveDispelWeapon(xi.item.LOCKHEART))

        local unsupported = copyTable(original)
        unsupported.itemId = xi.item.CLAUSTRUM_75
        local unsupportedRegistry, unsupportedErrors =
            xi.additionalEffect.profile.buildDispelWeaponRegistry({ unsupported })
        assert(not unsupportedRegistry and #unsupportedErrors > 0)

        local duplicateRegistry, duplicateErrors =
            xi.additionalEffect.profile.buildDispelWeaponRegistry({ original, original })
        assert(not duplicateRegistry and #duplicateErrors > 0)

        local missingPresentation = copyTable(original)
        missingPresentation.presentationSubEffect = nil
        local presentationRegistry, presentationErrors =
            xi.additionalEffect.profile.buildDispelWeaponRegistry({ missingPresentation })
        assert(not presentationRegistry and #presentationErrors > 0)

        local missingSelection = copyTable(original)
        missingSelection.selectionPolicy = nil
        local selectionRegistry, selectionErrors =
            xi.additionalEffect.profile.buildDispelWeaponRegistry({ missingSelection })
        assert(not selectionRegistry and #selectionErrors > 0)

        local driftedChance = copyTable(original)
        driftedChance.procChance = original.procChance + 1
        local chanceRegistry, chanceErrors =
            xi.additionalEffect.profile.buildDispelWeaponRegistry({ driftedChance })
        assert(not chanceRegistry and #chanceErrors > 0)
    end)

    for _, case in ipairs(cases) do
        it(string.format(
            'preserves the %s SQL proc pass and fail boundary with one roll',
            case.name), function()
            local item = findItem(case.itemId)
            addDispellable(xi.effect.PROTECT)
            local remover = spy('xi.additionalEffect.removeOneDispelStatus')
            local procRolls = 0
            stub('math.randomInt', function(minimum, maximum)
                assert(minimum == 1 and maximum == 100)
                procRolls = procRolls + 1
                return case.chance
            end)

            local subEffect, messageId, effectId =
                xi.additionalEffect.attack(player, target, 0, item)
            assert(
                subEffect == xi.subEffect.DARKNESS_DAMAGE,
                string.format(
                    'unexpected result %s/%s/%s; status retained=%s',
                    tostring(subEffect),
                    tostring(messageId),
                    tostring(effectId),
                    tostring(target:hasStatusEffect(xi.effect.PROTECT))))
            assert(messageId == xi.msg.basic.ADD_EFFECT_DISPEL)
            assert(effectId == xi.effect.PROTECT)
            assert(procRolls == 1)
            remover:called(1)

            addDispellable(xi.effect.PROTECT)
            procRolls = 0
            stub('math.randomInt', function(minimum, maximum)
                assert(minimum == 1 and maximum == 100)
                procRolls = procRolls + 1
                return case.chance + 1
            end)

            subEffect, messageId, effectId =
                xi.additionalEffect.attack(player, target, 0, item)
            assert(subEffect == 0 and messageId == 0 and effectId == 0)
            assert(procRolls == 1)
            assert(target:hasStatusEffect(xi.effect.PROTECT))
            remover:called(1)
        end)
    end

    it('performs no accuracy or resistance roll after a successful proc', function()
        local item = findItem(xi.item.LOCKHEART)
        addDispellable(xi.effect.PROTECT)
        stub('math.randomInt', 1)
        local resistance = spy('applyResistanceAddEffect')

        local subEffect, messageId, effectId =
            xi.additionalEffect.attack(player, target, 0, item)

        assert(subEffect == xi.subEffect.DARKNESS_DAMAGE)
        assert(messageId == xi.msg.basic.ADD_EFFECT_DISPEL)
        assert(effectId == xi.effect.PROTECT)
        resistance:called(0)
    end)

    it('reports no result when no removable status exists', function()
        local item = findItem(xi.item.LOCKHEART)
        stub('math.randomInt', 1)
        local remover = spy('xi.additionalEffect.removeOneDispelStatus')

        local subEffect, messageId, effectId =
            xi.additionalEffect.attack(player, target, 0, item)

        assert(subEffect == 0 and messageId == 0 and effectId == 0)
        remover:called(1)
    end)

    it('removes one eligible status while preserving protected categories', function()
        local item = findItem(xi.item.LOCKHEART)
        addEffect(xi.effect.DIA, xi.effectFlag.ERASABLE, 60)
        addEffect(xi.effect.FOOD, xi.effectFlag.FOOD, 60)
        addEffect(xi.effect.COLURE_ACTIVE, xi.effectFlag.AURA, 60)
        addEffect(xi.effect.RERAISE, xi.effectFlag.DISPELABLE, 0)
        addDispellable(xi.effect.SHELL)
        stub('math.randomInt', 1)

        local _, messageId, effectId =
            xi.additionalEffect.attack(player, target, 0, item)

        assert(messageId == xi.msg.basic.ADD_EFFECT_DISPEL)
        assert(effectId == xi.effect.SHELL)
        assert(not target:hasStatusEffect(xi.effect.SHELL))
        assert(target:hasStatusEffect(xi.effect.DIA))
        assert(target:hasStatusEffect(xi.effect.FOOD))
        assert(target:hasStatusEffect(xi.effect.COLURE_ACTIVE))
        assert(target:hasStatusEffect(xi.effect.RERAISE))
    end)

    it('selects and removes exactly one of multiple removable effects', function()
        local item = findItem(xi.item.LOCKHEART)
        addDispellable(xi.effect.PROTECT)
        addDispellable(xi.effect.SHELL)
        stub('math.randomInt', 1)
        local remover = spy('xi.additionalEffect.removeOneDispelStatus')

        local _, messageId, effectId =
            xi.additionalEffect.attack(player, target, 0, item)

        assert(messageId == xi.msg.basic.ADD_EFFECT_DISPEL)
        assert(effectId == xi.effect.PROTECT or effectId == xi.effect.SHELL)
        assert(not target:hasStatusEffect(effectId))
        local otherEffect =
            effectId == xi.effect.PROTECT and xi.effect.SHELL or xi.effect.PROTECT
        assert(target:hasStatusEffect(otherEffect))
        remover:called(1)
    end)

    for _, invalidResult in ipairs({ false, xi.effect.NONE, -1 }) do
        it(string.format(
            'fails safely without retry for invalid removal result %s',
            tostring(invalidResult)), function()
            local item = findItem(xi.item.LOCKHEART)
            stub('math.randomInt', 1)
            local calls = 0
            stub('xi.additionalEffect.removeOneDispelStatus', function()
                calls = calls + 1
                return invalidResult
            end)

            local subEffect, messageId, effectId =
                xi.additionalEffect.attack(player, target, 0, item)

            assert(subEffect == 0 and messageId == 0 and effectId == 0)
            assert(calls == 1)
        end)
    end

    it('validates a copied execution profile before any status mutation', function()
        local item = findItem(xi.item.LOCKHEART)
        local profile = copyTable(xi.additionalEffect.profile.resolve(item, 0))
        profile.dispelWeapon.presentationSubEffect = nil
        local remover = spy('xi.additionalEffect.removeOneDispelStatus')

        local subEffect, messageId, effectId =
            xi.additionalEffect.executeDispel(
                player,
                target,
                { profile = profile, subEffect = xi.subEffect.DARKNESS_DAMAGE })

        assert(subEffect == 0 and messageId == 0 and effectId == 0)
        remover:called(0)
    end)

    it('rejects dead and invalid targets before proc or removal', function()
        local item = findItem(xi.item.LOCKHEART)
        target:setUnkillable(false)
        target:setHP(0)
        local procRoll = spy('math.randomInt')
        local remover = spy('xi.additionalEffect.removeOneDispelStatus')

        local subEffect, messageId, effectId =
            xi.additionalEffect.attack(player, target, 0, item)
        assert(subEffect == 0 and messageId == 0 and effectId == 0)
        procRoll:called(0)
        remover:called(0)

        subEffect, messageId, effectId =
            xi.additionalEffect.attack(player, nil, 0, item)
        assert(subEffect == 0 and messageId == 0 and effectId == 0)
        procRoll:called(0)
        remover:called(0)
    end)
end)
