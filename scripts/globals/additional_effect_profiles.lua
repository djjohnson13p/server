-----------------------------------
-- Item additional-effect profiles
--
-- SQL item modifiers remain the source of numeric configuration for the
-- modifier-driven families. Scripted item families keep their policy here so
-- their item scripts do not duplicate anonymous parameter tables.
-----------------------------------
xi = xi or {}
xi.additionalEffect = xi.additionalEffect or {}
xi.additionalEffect.profile = xi.additionalEffect.profile or {}
xi.additionalEffect.profile.reportedInvalidItems = xi.additionalEffect.profile.reportedInvalidItems or {}

xi.additionalEffect.profile.classification =
{
    EVIDENCE_BACKED                   = 'EVIDENCE_BACKED',
    FRAMEWORK_CORRECT_LEGACY_NUMERICS = 'FRAMEWORK_CORRECT_LEGACY_NUMERICS',
    VERIFY_LIVE                       = 'VERIFY_LIVE',
    NOT_APPLICABLE                    = 'NOT_APPLICABLE',
    SPECIAL_CASE_TEST_BACKED          = 'SPECIAL_CASE_TEST_BACKED',
    CONFIGURATION_ERROR               = 'CONFIGURATION_ERROR',
    NOT_ACTIVE                        = 'NOT_ACTIVE',
    ERA_UNRESOLVED                    = 'ERA_UNRESOLVED',
}

xi.additionalEffect.profile.accuracyMode =
{
    NONE                     = 'NONE',
    ITEM_NATIVE_RANK         = 'ITEM_NATIVE_RANK',
    LEGACY_UNVERIFIED_RANK   = 'LEGACY_UNVERIFIED_RANK',
    LEGACY_DAMAGE_RESISTANCE = 'LEGACY_DAMAGE_RESISTANCE',
}

local itemPolicy =
{
    -- Issue #7899 supports item-native A-rank magic accuracy for these two
    -- bolts. It does not resolve dSTAT, so the existing INT contribution is
    -- retained and labeled rather than presented as retail-confirmed.
    [xi.item.ACID_BOLT] =
    {
        accuracyMode          = xi.additionalEffect.profile.accuracyMode.ITEM_NATIVE_RANK,
        skillRank             = xi.skillRank.A,
        governingStat         = xi.mod.INT,
        governingStatEvidence = 'LEGACY_UNVERIFIED',
        evidence              = 'LandSandBoat issue #7899 reported dataset',
    },

    [xi.item.SLEEP_BOLT] =
    {
        accuracyMode          = xi.additionalEffect.profile.accuracyMode.ITEM_NATIVE_RANK,
        skillRank             = xi.skillRank.A,
        governingStat         = xi.mod.INT,
        governingStatEvidence = 'LEGACY_UNVERIFIED',
        evidence              = 'LandSandBoat issue #7899 reported dataset',
    },
}

local familyPolicy =
{
    [5] =
    {
        classification = xi.additionalEffect.profile.classification.VERIFY_LIVE,
        drainResource = 'HP',
        selectionPolicy = 'SINGLE',
        undeadPolicy = 'BLOCK',
    },
    [6] =
    {
        classification = xi.additionalEffect.profile.classification.VERIFY_LIVE,
        drainResource = 'MP',
        selectionPolicy = 'SINGLE',
        undeadPolicy = 'BLOCK',
    },
    [7] =
    {
        classification = xi.additionalEffect.profile.classification.VERIFY_LIVE,
        drainResource = 'TP',
        selectionPolicy = 'SINGLE',
        undeadPolicy = 'BLOCK',
    },
    [8] =
    {
        classification = xi.additionalEffect.profile.classification.VERIFY_LIVE,
        drainResource = 'HP_OR_MP',
        selectionPolicy = 'LEGACY_RANDOM_VERIFY_LIVE',
        undeadPolicy = 'BLOCK',
    },
    [9] =
    {
        classification = xi.additionalEffect.profile.classification.VERIFY_LIVE,
        drainResource = 'HP_OR_MP_OR_TP',
        selectionPolicy = 'LEGACY_RANDOM_VERIFY_LIVE',
        undeadPolicy = 'BLOCK',
    },
    [10] =
    {
        classification = xi.additionalEffect.profile.classification.VERIFY_LIVE,
    },
    [11] =
    {
        classification = xi.additionalEffect.profile.classification.VERIFY_LIVE,
    },
    [12] =
    {
        classification = xi.additionalEffect.profile.classification.VERIFY_LIVE,
    },
    [13] =
    {
        classification = xi.additionalEffect.profile.classification.VERIFY_LIVE,
    },
}

local function resolveClassification(itemId, procType)
    if procType == 14 then
        return xi.additionalEffect.profile.classification.SPECIAL_CASE_TEST_BACKED
    elseif familyPolicy[procType] then
        return familyPolicy[procType].classification
    elseif itemId == xi.item.ACID_BOLT or itemId == xi.item.SLEEP_BOLT then
        return xi.additionalEffect.profile.classification.FRAMEWORK_CORRECT_LEGACY_NUMERICS
    end

    return xi.additionalEffect.profile.classification.FRAMEWORK_CORRECT_LEGACY_NUMERICS
end

xi.additionalEffect.profile.resolve = function(item, baseAttackDamage)
    local itemId   = item:getID()
    local procType = item:getMod(xi.mod.ITEM_ADDEFFECT_TYPE)
    local policy   = itemPolicy[itemId] or {}
    local family   = familyPolicy[procType] or {}

    local profile =
    {
        itemId         = itemId,
        classification = resolveClassification(itemId, procType),
        evidence       = policy.evidence or 'LEGACY_UNVERIFIED',

        proc =
        {
            chance              = item:getMod(xi.mod.ITEM_ADDEFFECT_CHANCE),
            levelCorrection     = item:getMod(xi.mod.ITEM_ADDEFFECT_LVADJUST),
            triggeringAttack    = 'MELEE_OR_RANGED',
            distanceBandPolicy  = 'INHERIT_TRIGGERING_ATTACK_HIT',
            targetRestriction   = procType == 14 and 'NAMED_NM_CONFIG' or 'ATTACK_TARGET',
        },

        accuracy =
        {
            mode        = policy.accuracyMode or
                (procType == 2 and
                    xi.additionalEffect.profile.accuracyMode.LEGACY_UNVERIFIED_RANK or
                    xi.additionalEffect.profile.accuracyMode.LEGACY_DAMAGE_RESISTANCE),
            skillRank             = policy.skillRank or xi.skillRank.A,
            governingStat         = policy.governingStat or xi.mod.INT,
            governingStatEvidence = policy.governingStatEvidence or 'LEGACY_UNVERIFIED',
            element               = item:getMod(xi.mod.ITEM_ADDEFFECT_ELEMENT),
            resistancePolicy      = procType == 2 and 'STATUS_MAGIC_TIER' or 'FAMILY_HANDLER',
            immunityPolicy        = procType == 2 and 'STATUS_HELPERS' or 'FAMILY_HANDLER',
            nullificationPolicy   = procType == 1 and 'MAGICAL_ONCE' or 'FAMILY_HANDLER',
            absorptionPolicy      = procType == 1 and 'MAGICAL_ONCE' or 'FAMILY_HANDLER',
            partialResistPolicy   = procType == 2 and 'DURATION_SCALED_MIN_HALF' or 'FAMILY_HANDLER',
        },

        outcome =
        {
            family            = procType,
            baseAttackDamage  = baseAttackDamage,
            damage            = item:getMod(xi.mod.ITEM_ADDEFFECT_DMG),
            damageType        = 'ELEMENTAL_LEGACY',
            statusEffect      = item:getMod(xi.mod.ITEM_ADDEFFECT_STATUS),
            power             = item:getMod(xi.mod.ITEM_ADDEFFECT_POWER),
            duration          = item:getMod(xi.mod.ITEM_ADDEFFECT_DURATION),
            tickInterval      = 'STATUS_DEFAULT',
            drainResource     = family.drainResource or 'NONE',
            selectionPolicy   = family.selectionPolicy or 'SINGLE',
            undeadPolicy      = family.undeadPolicy or 'FAMILY_HANDLER',
            applicationPolicy = 'APPLY_FINAL_OUTCOME_ONCE',
        },

        presentation =
        {
            subEffect         = item:getMod(xi.mod.ITEM_SUBEFFECT),
            successMessage    = 'FAMILY_DEFAULT',
            noEffectMessage   = 'NONE',
            messageParameter  = 'APPLIED_AMOUNT_OR_EFFECT_ID',
            absorptionMessage = 'ADD_EFFECT_HEAL',
        },
    }

    return profile
end

xi.additionalEffect.profile.validate = function(profile)
    local errors = {}
    local family = profile.outcome.family

    if not xi.additionalEffect.procFunctions[family] then
        table.insert(errors, string.format('unsupported proc family %s', tostring(family)))
    end

    if profile.proc.chance <= 0 or profile.proc.chance > 100 then
        table.insert(errors, string.format('invalid proc chance %s', tostring(profile.proc.chance)))
    end

    if family == 1 then
        if profile.outcome.damage <= 0 then
            table.insert(errors, 'damage profile requires positive damage')
        end

        if
            profile.accuracy.element <= xi.element.NONE or
            profile.accuracy.element > xi.element.DARK
        then
            table.insert(errors, 'damage profile requires an elemental resistance key')
        end
    elseif family == 2 then
        if
            profile.outcome.statusEffect <= 0 or
            profile.outcome.statusEffect == xi.effect.NONE
        then
            table.insert(errors, 'status profile requires a status effect')
        end

        if profile.outcome.duration <= 0 then
            table.insert(errors, 'status profile requires positive duration')
        end
    end

    return #errors == 0, errors
end

local function elementalArrowProfile(itemId, itemName, element, subEffect)
    local evidence = xi.additionalEffect.profile.classification

    return
    {
        itemId         = itemId,
        itemName       = itemName,
        family         = 'VZ_ELEMENTAL_ARROW',
        profileSource  = 'scripts/globals/additional_effect_profiles.lua',
        evidenceSource =
            'retail_parity/vanilla_zilart/artifacts/' ..
            'VZ-COMBAT-001-elemental-arrows-evidence.md',
        classification = evidence.VERIFY_LIVE,

        proc =
        {
            policy                = 'FIXED_PERCENT_COMPATIBILITY',
            chance                = 100,
            chanceClassification  = evidence.VERIFY_LIVE,
            levelPolicy           = 'ITEM_REQUIRED_LEVEL_GATE',
            levelClassification   = evidence.FRAMEWORK_CORRECT_LEGACY_NUMERICS,
            triggeringAttack      = 'SUCCESSFUL_RANGED_HIT',
            distancePolicy        = 'INHERIT_TRIGGERING_ATTACK',
            distanceClassification = evidence.FRAMEWORK_CORRECT_LEGACY_NUMERICS,
        },

        power =
        {
            policy         = 'UNIFORM_INTEGER_RANGE_COMPATIBILITY',
            minimum        = 7,
            maximum        = 10,
            classification = evidence.VERIFY_LIVE,
        },

        accuracy =
        {
            skillBasis               = xi.skillRank.A_PLUS,
            skillBasisPolicy         = 'LEGACY_A_PLUS',
            skillBasisClassification = evidence.VERIFY_LIVE,
            actorStat                = 0,
            targetStat               = 0,
            governingStatPolicy      = 'NO_STAT_COMPATIBILITY',
            governingStatClassification = evidence.VERIFY_LIVE,
            magicAccuracy            = 0,
            magicAccuracyPolicy      = 'NO_EXPLICIT_MACC_COMPATIBILITY',
            magicAccuracyClassification = evidence.VERIFY_LIVE,
            resistancePolicy         = 'MAGICAL_TIERS',
            resistanceClassification = evidence.VERIFY_LIVE,
            lowestResist             = 0.125,
            lowestResistClassification = evidence.VERIFY_LIVE,
        },

        outcome =
        {
            element               = element,
            elementClassification = evidence.EVIDENCE_BACKED,
            attackType            = xi.attackType.MAGICAL,
            damageTypePolicy      = 'ELEMENTAL_BY_ELEMENT',
            damageTypeClassification = evidence.FRAMEWORK_CORRECT_LEGACY_NUMERICS,
            applicationPolicy     = 'APPLY_FINAL_OUTCOME_ONCE',
            applicationClassification = evidence.FRAMEWORK_CORRECT_LEGACY_NUMERICS,
        },

        multipliers =
        {
            generalMagicDamage =
            {
                enabled        = true,
                classification = evidence.VERIFY_LIVE,
            },
            elementalSDT =
            {
                enabled        = true,
                classification = evidence.VERIFY_LIVE,
            },
            elementalStaff =
            {
                enabled        = true,
                classification = evidence.VERIFY_LIVE,
            },
            elementalAffinity =
            {
                enabled        = true,
                classification = evidence.VERIFY_LIVE,
            },
            dayWeather =
            {
                enabled        = true,
                classification = evidence.VERIFY_LIVE,
            },
            magicAttackBonus =
            {
                enabled        = false,
                classification = evidence.VERIFY_LIVE,
            },
            phalanx =
            {
                enabled        = true,
                classification = evidence.VERIFY_LIVE,
            },
            oneForAll =
            {
                enabled        = true,
                classification = evidence.VERIFY_LIVE,
            },
            stoneskin =
            {
                enabled        = true,
                classification = evidence.VERIFY_LIVE,
            },
            nullification =
            {
                enabled        = true,
                classification = evidence.FRAMEWORK_CORRECT_LEGACY_NUMERICS,
            },
            absorption =
            {
                enabled        = true,
                classification = evidence.FRAMEWORK_CORRECT_LEGACY_NUMERICS,
            },
        },

        presentation =
        {
            subEffect          = subEffect,
            message            = xi.msg.basic.ADD_EFFECT_DMG,
            classification     = evidence.FRAMEWORK_CORRECT_LEGACY_NUMERICS,
            amountPolicy       = 'ACTUAL_APPLIED_AMOUNT',
        },

        unresolvedEvidence =
        {
            'proc chance and level correction',
            'base power and random range',
            'governing stat and dSTAT',
            'magic accuracy and skill rank',
            'MAB, staff, affinity, and day/weather multipliers',
            'resist tiers and lowest tier',
            'defensive mitigation and absorption details',
        },
    }
end

local elementalArrowDefinitions =
{
    elementalArrowProfile(
        xi.item.FIRE_ARROW,
        'fire_arrow',
        xi.element.FIRE,
        xi.subEffect.FIRE_DAMAGE),
    elementalArrowProfile(
        xi.item.ICE_ARROW,
        'ice_arrow',
        xi.element.ICE,
        xi.subEffect.ICE_DAMAGE),
    elementalArrowProfile(
        xi.item.LIGHTNING_ARROW,
        'lightning_arrow',
        xi.element.THUNDER,
        xi.subEffect.LIGHTNING_DAMAGE),
}

local expectedSubEffect =
{
    [xi.element.FIRE   ] = xi.subEffect.FIRE_DAMAGE,
    [xi.element.ICE    ] = xi.subEffect.ICE_DAMAGE,
    [xi.element.THUNDER] = xi.subEffect.LIGHTNING_DAMAGE,
}

local expectedElementalArrows =
{
    [xi.item.FIRE_ARROW] =
    {
        itemName  = 'fire_arrow',
        element   = xi.element.FIRE,
        subEffect = xi.subEffect.FIRE_DAMAGE,
    },
    [xi.item.ICE_ARROW] =
    {
        itemName  = 'ice_arrow',
        element   = xi.element.ICE,
        subEffect = xi.subEffect.ICE_DAMAGE,
    },
    [xi.item.LIGHTNING_ARROW] =
    {
        itemName  = 'lightning_arrow',
        element   = xi.element.THUNDER,
        subEffect = xi.subEffect.LIGHTNING_DAMAGE,
    },
}

local requiredMultiplierPolicies =
{
    'generalMagicDamage',
    'elementalSDT',
    'elementalStaff',
    'elementalAffinity',
    'dayWeather',
    'magicAttackBonus',
    'phalanx',
    'oneForAll',
    'stoneskin',
    'nullification',
    'absorption',
}

local function isInteger(value)
    return type(value) == 'number' and value % 1 == 0
end

-- The validator intentionally enumerates every supported policy.
-- luacheck: ignore 561
xi.additionalEffect.profile.validateScriptedDamage = function(profile)
    local errors = {}

    if type(profile) ~= 'table' then
        return false, { 'scripted damage profile must be a table' }
    end

    if not isInteger(profile.itemId) or profile.itemId <= 0 then
        table.insert(errors, 'scripted damage profile requires a positive integer item ID')
    end

    local expectedArrow = expectedElementalArrows[profile.itemId]
    if not expectedArrow then
        table.insert(errors, string.format(
            'unsupported elemental-arrow item ID %s',
            tostring(profile.itemId)))
    elseif profile.itemName ~= expectedArrow.itemName then
        table.insert(errors, string.format(
            'item %u requires profile name %s',
            profile.itemId,
            expectedArrow.itemName))
    end

    if profile.family ~= 'VZ_ELEMENTAL_ARROW' then
        table.insert(errors, string.format('unsupported scripted damage family %s', tostring(profile.family)))
    end

    if profile.classification ~= xi.additionalEffect.profile.classification.VERIFY_LIVE then
        table.insert(errors, 'elemental-arrow profile must retain VERIFY_LIVE classification')
    end

    if type(profile.proc) ~= 'table' then
        table.insert(errors, 'scripted damage profile requires proc policy')
    else
        if profile.proc.policy ~= 'FIXED_PERCENT_COMPATIBILITY' then
            table.insert(errors, string.format('unsupported proc policy %s', tostring(profile.proc.policy)))
        end

        if
            not isInteger(profile.proc.chance) or
            profile.proc.chance < 1 or
            profile.proc.chance > 100
        then
            table.insert(errors, string.format('invalid proc chance %s', tostring(profile.proc.chance)))
        end

        if profile.proc.levelPolicy ~= 'ITEM_REQUIRED_LEVEL_GATE' then
            table.insert(errors, string.format('unsupported level policy %s', tostring(profile.proc.levelPolicy)))
        end

        if
            profile.proc.triggeringAttack ~= 'SUCCESSFUL_RANGED_HIT' or
            profile.proc.distancePolicy ~= 'INHERIT_TRIGGERING_ATTACK'
        then
            table.insert(errors, 'unsupported triggering-attack policy')
        end
    end

    if type(profile.power) ~= 'table' then
        table.insert(errors, 'scripted damage profile requires base-power policy')
    else
        if profile.power.policy ~= 'UNIFORM_INTEGER_RANGE_COMPATIBILITY' then
            table.insert(errors, string.format('unsupported base-power policy %s', tostring(profile.power.policy)))
        end

        if
            not isInteger(profile.power.minimum) or
            not isInteger(profile.power.maximum) or
            profile.power.minimum < 0 or
            profile.power.maximum < profile.power.minimum
        then
            table.insert(errors, 'base-power range must be ordered nonnegative integers')
        end
    end

    if type(profile.accuracy) ~= 'table' then
        table.insert(errors, 'scripted damage profile requires accuracy policy')
    else
        if profile.accuracy.skillBasisPolicy ~= 'LEGACY_A_PLUS' then
            table.insert(errors, string.format(
                'unsupported skill-basis policy %s',
                tostring(profile.accuracy.skillBasisPolicy)))
        end

        if
            profile.accuracy.skillBasis ~= xi.skillRank.A_PLUS or
            profile.accuracy.actorStat ~= 0 or
            profile.accuracy.targetStat ~= 0
        then
            table.insert(errors, 'unsupported compatibility accuracy inputs')
        end

        if profile.accuracy.governingStatPolicy ~= 'NO_STAT_COMPATIBILITY' then
            table.insert(errors, string.format(
                'unsupported governing-stat policy %s',
                tostring(profile.accuracy.governingStatPolicy)))
        end

        if
            profile.accuracy.magicAccuracyPolicy ~= 'NO_EXPLICIT_MACC_COMPATIBILITY' or
            profile.accuracy.magicAccuracy ~= 0
        then
            table.insert(errors, 'unsupported explicit magic-accuracy policy')
        end

        if profile.accuracy.resistancePolicy ~= 'MAGICAL_TIERS' then
            table.insert(errors, string.format(
                'unsupported resistance policy %s',
                tostring(profile.accuracy.resistancePolicy)))
        end

        if
            type(profile.accuracy.lowestResist) ~= 'number' or
            profile.accuracy.lowestResist <= 0 or
            profile.accuracy.lowestResist > 1
        then
            table.insert(errors, string.format(
                'invalid lowest resist tier %s',
                tostring(profile.accuracy.lowestResist)))
        end
    end

    if type(profile.outcome) ~= 'table' then
        table.insert(errors, 'scripted damage profile requires outcome policy')
    else
        if not expectedSubEffect[profile.outcome.element] then
            table.insert(errors, string.format(
                'unsupported elemental-arrow element %s',
                tostring(profile.outcome.element)))
        end

        if profile.outcome.attackType ~= xi.attackType.MAGICAL then
            table.insert(errors, 'elemental-arrow compatibility profile requires magical attack type')
        end

        if profile.outcome.damageTypePolicy ~= 'ELEMENTAL_BY_ELEMENT' then
            table.insert(errors, string.format(
                'unsupported damage-type policy %s',
                tostring(profile.outcome.damageTypePolicy)))
        end

        if profile.outcome.applicationPolicy ~= 'APPLY_FINAL_OUTCOME_ONCE' then
            table.insert(errors, 'unsupported outcome-application policy')
        end

        if expectedArrow and profile.outcome.element ~= expectedArrow.element then
            table.insert(errors, string.format(
                'item %u has the wrong elemental damage type',
                profile.itemId))
        end
    end

    if type(profile.multipliers) ~= 'table' then
        table.insert(errors, 'scripted damage profile requires multiplier policies')
    else
        for _, policyName in ipairs(requiredMultiplierPolicies) do
            local policy = profile.multipliers[policyName]
            if type(policy) ~= 'table' or type(policy.enabled) ~= 'boolean' then
                table.insert(errors, string.format('missing multiplier policy %s', policyName))
            end
        end

        if
            profile.multipliers.magicAttackBonus and
            profile.multipliers.magicAttackBonus.enabled
        then
            table.insert(errors, 'unsupported magic-attack-bonus policy')
        end

        for _, policyName in ipairs(requiredMultiplierPolicies) do
            if
                policyName ~= 'magicAttackBonus' and
                profile.multipliers[policyName] and
                not profile.multipliers[policyName].enabled
            then
                table.insert(errors, string.format(
                    'unsupported disabled multiplier policy %s',
                    policyName))
            end
        end
    end

    if type(profile.presentation) ~= 'table' then
        table.insert(errors, 'scripted damage profile requires presentation policy')
    else
        if
            expectedSubEffect[profile.outcome and profile.outcome.element] and
            profile.presentation.subEffect ~= expectedSubEffect[profile.outcome.element]
        then
            table.insert(errors, 'element and additional-effect subeffect do not match')
        end

        if profile.presentation.message ~= xi.msg.basic.ADD_EFFECT_DMG then
            table.insert(errors, string.format(
                'unsupported presentation message %s',
                tostring(profile.presentation.message)))
        end

        if profile.presentation.amountPolicy ~= 'ACTUAL_APPLIED_AMOUNT' then
            table.insert(errors, 'unsupported presentation amount policy')
        end

        if
            expectedArrow and
            profile.presentation.subEffect ~= expectedArrow.subEffect
        then
            table.insert(errors, string.format(
                'item %u has the wrong additional-effect presentation',
                profile.itemId))
        end
    end

    return #errors == 0, errors
end

xi.additionalEffect.profile.buildScriptedDamageRegistry = function(definitions)
    local registry = {}
    local errors = {}

    for index, profile in ipairs(definitions) do
        local valid, validationErrors =
            xi.additionalEffect.profile.validateScriptedDamage(profile)
        for _, validationError in ipairs(validationErrors) do
            table.insert(errors, string.format(
                'definition %u: %s',
                index,
                validationError))
        end

        if valid then
            if registry[profile.itemId] then
                table.insert(errors, string.format(
                    'duplicate scripted damage item profile %u',
                    profile.itemId))
            else
                registry[profile.itemId] = profile
            end
        end
    end

    if #errors > 0 then
        return nil, errors
    end

    return registry, errors
end

local elementalArrowRegistry, elementalArrowRegistryErrors =
    xi.additionalEffect.profile.buildScriptedDamageRegistry(elementalArrowDefinitions)
if not elementalArrowRegistry then
    error(table.concat(elementalArrowRegistryErrors, '; '))
end

xi.additionalEffect.profile.resolveScriptedDamage = function(item)
    if item == nil then
        return nil
    end

    local itemId = type(item) == 'number' and item or item:getID()

    return elementalArrowRegistry[itemId]
end

xi.additionalEffect.profile.scriptedDamageProfileCount = function()
    local count = 0
    for _ in pairs(elementalArrowRegistry) do
        count = count + 1
    end

    return count
end

return xi.additionalEffect.profile
