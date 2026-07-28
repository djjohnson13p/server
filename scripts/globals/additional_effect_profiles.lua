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

local statusAmmunitionRegistry = {}

local function resolveClassification(itemId, procType)
    if statusAmmunitionRegistry[itemId] then
        return xi.additionalEffect.profile.classification.VERIFY_LIVE
    elseif procType == 14 then
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
    local statusAmmunition = statusAmmunitionRegistry[itemId]
    local profileFamily = 'SQL_MODIFIER_GENERIC'
    local evidenceSource
    local fieldClassifications
    local triggeringAttack = 'MELEE_OR_RANGED'
    local chancePolicy = 'SQL_MODIFIER'
    local levelPolicy = 'SQL_MODIFIER'
    local effectiveElement
    if statusAmmunition then
        profileFamily = 'VZ_STATUS_AMMUNITION'
        evidenceSource = statusAmmunition.evidenceSource
        fieldClassifications = statusAmmunition.fieldClassifications
        triggeringAttack = 'SUCCESSFUL_RANGED_HIT'
        chancePolicy = 'SQL_MODIFIER_COMPATIBILITY'
        levelPolicy = 'SQL_MODIFIER_COMPATIBILITY'
        effectiveElement = statusAmmunition.effectiveElement
    end

    local profile =
    {
        itemId            = itemId,
        profileFamily     = profileFamily,
        classification    = resolveClassification(itemId, procType),
        evidence          = policy.evidence or 'LEGACY_UNVERIFIED',
        evidenceSource    = evidenceSource,
        statusAmmunition  = statusAmmunition,
        fieldClassifications = fieldClassifications,

        proc =
        {
            chance              = item:getMod(xi.mod.ITEM_ADDEFFECT_CHANCE),
            levelCorrection     = item:getMod(xi.mod.ITEM_ADDEFFECT_LVADJUST),
            chancePolicy        = chancePolicy,
            levelPolicy         = levelPolicy,
            triggeringAttack    = triggeringAttack,
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
            effectiveElement      = effectiveElement,
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

    if profile.statusAmmunition then
        local validStatusAmmunition, statusAmmunitionErrors =
            xi.additionalEffect.profile.validateStatusAmmunition(profile)
        if not validStatusAmmunition then
            for _, validationError in ipairs(statusAmmunitionErrors) do
                table.insert(errors, validationError)
            end
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

local function statusAmmunitionProfile(
    itemId,
    itemName,
    ammunitionCategory,
    effectId,
    subEffect,
    configuredElement,
    effectiveElement,
    chance,
    levelCorrection,
    power,
    duration)
    local evidence = xi.additionalEffect.profile.classification

    return
    {
        itemId              = itemId,
        itemName            = itemName,
        profileFamily       = 'VZ_STATUS_AMMUNITION',
        profileSource       = 'scripts/globals/additional_effect_profiles.lua',
        evidenceSource      =
            'retail_parity/vanilla_zilart/artifacts/' ..
            'VZ-COMBAT-001-status-ammunition-evidence.md',
        classification      = evidence.VERIFY_LIVE,
        ammunitionCategory  = ammunitionCategory,
        triggeringAttack    = 'SUCCESSFUL_RANGED_HIT',
        distancePolicy      = 'INHERIT_TRIGGERING_ATTACK',
        procChancePolicy    = 'SQL_MODIFIER_COMPATIBILITY',
        levelPolicy         = 'SQL_MODIFIER_COMPATIBILITY',
        procChance          = chance,
        levelCorrection     = levelCorrection,
        skillBasis          = xi.skillRank.A,
        skillBasisPolicy    = 'LEGACY_A_RANK_COMPATIBILITY',
        governingStat       = xi.mod.INT,
        governingStatPolicy = 'LEGACY_INT_ACCURACY_COMPATIBILITY',
        dStatPolicy         = 'NOT_USED_BY_STATUS_HANDLER',
        configuredElement   = configuredElement,
        effectiveElement    = effectiveElement,
        elementPolicy       = 'SQL_OR_ASSOCIATED_STATUS_COMPATIBILITY',
        statusEffect        = effectId,
        power               = power,
        powerPolicy         = 'SQL_MODIFIER_COMPATIBILITY',
        duration            = duration,
        durationPolicy      = 'SQL_MODIFIER_COMPATIBILITY',
        resistancePolicy    = 'STATUS_MAGIC_TIER_MIN_HALF',
        defensivePolicy     = 'STATUS_GUARDS_AND_CONTAINER',
        applicationPolicy   = 'APPLY_ONCE_THEN_REMOVE_OPPOSING_BOOST',
        overwritePolicy     = 'STATUS_CONTAINER_COMPATIBILITY',
        presentationSubEffect = subEffect,
        presentationMessage = xi.msg.basic.ADD_EFFECT_STATUS_2,
        presentationPolicy  = 'NORMAL_RANGED_ADDITIONAL_EFFECT',
        spartanCooldownPolicy =
            itemId == xi.item.SPARTAN_BULLET and 'NOT_IMPLEMENTED_VERIFY_LIVE' or 'NOT_APPLICABLE',

        fieldClassifications =
        {
            identity          = evidence.EVIDENCE_BACKED,
            introductionEra   = evidence.EVIDENCE_BACKED,
            statusEffect      = evidence.EVIDENCE_BACKED,
            procChance        = evidence.VERIFY_LIVE,
            levelCorrection   = evidence.VERIFY_LIVE,
            skillBasis        = evidence.VERIFY_LIVE,
            governingStat     = evidence.VERIFY_LIVE,
            dStat             = evidence.NOT_APPLICABLE,
            element           = evidence.VERIFY_LIVE,
            power             = evidence.VERIFY_LIVE,
            duration          = evidence.VERIFY_LIVE,
            resistance        = evidence.VERIFY_LIVE,
            immunity          = evidence.FRAMEWORK_CORRECT_LEGACY_NUMERICS,
            traitResistance   = evidence.FRAMEWORK_CORRECT_LEGACY_NUMERICS,
            nullification     = evidence.FRAMEWORK_CORRECT_LEGACY_NUMERICS,
            overwrite         = evidence.VERIFY_LIVE,
            opposingBoost     = evidence.FRAMEWORK_CORRECT_LEGACY_NUMERICS,
            distance          = evidence.FRAMEWORK_CORRECT_LEGACY_NUMERICS,
            ammunitionUse     = evidence.FRAMEWORK_CORRECT_LEGACY_NUMERICS,
            presentation      = evidence.FRAMEWORK_CORRECT_LEGACY_NUMERICS,
            spartanCooldown   =
                itemId == xi.item.SPARTAN_BULLET and evidence.VERIFY_LIVE or evidence.NOT_APPLICABLE,
        },

        unresolvedEvidence =
        {
            'proc chance and level correction',
            'magic accuracy, skill basis, and governing stat',
            'action element and resistance tiers',
            'power, duration, overwrite, and status-removal semantics',
            'exact client presentation',
        },
    }
end

local statusAmmunitionDefinitions =
{
    statusAmmunitionProfile(
        xi.item.KABURA_ARROW,
        'kabura_arrow',
        'ARCHERY',
        xi.effect.SILENCE,
        xi.subEffect.SILENCE,
        xi.element.NONE,
        xi.element.WIND,
        95,
        5,
        1,
        60),
    statusAmmunitionProfile(
        xi.item.PATRIARCH_PROTECTORS_ARROW,
        'patriarch_protectors_arrow',
        'ARCHERY',
        xi.effect.PARALYSIS,
        xi.subEffect.PARALYSIS,
        xi.element.NONE,
        xi.element.ICE,
        95,
        5,
        30,
        30),
    statusAmmunitionProfile(
        xi.item.BLIND_BOLT,
        'blind_bolt',
        'MARKSMANSHIP_BOLT',
        xi.effect.BLINDNESS,
        xi.subEffect.BLIND,
        xi.element.DARK,
        xi.element.DARK,
        100,
        5,
        10,
        30),
    statusAmmunitionProfile(
        xi.item.VENOM_BOLT,
        'venom_bolt',
        'MARKSMANSHIP_BOLT',
        xi.effect.POISON,
        xi.subEffect.POISON,
        xi.element.WATER,
        xi.element.WATER,
        100,
        5,
        4,
        30),
    statusAmmunitionProfile(
        xi.item.POISON_ARROW,
        'poison_arrow',
        'ARCHERY',
        xi.effect.POISON,
        xi.subEffect.POISON,
        xi.element.NONE,
        xi.element.WATER,
        95,
        5,
        4,
        30),
    statusAmmunitionProfile(
        xi.item.SLEEP_ARROW,
        'sleep_arrow',
        'ARCHERY',
        xi.effect.SLEEP_I,
        xi.subEffect.SLEEP,
        xi.element.NONE,
        xi.element.NONE,
        95,
        5,
        0,
        25),
    statusAmmunitionProfile(
        xi.item.DEMON_ARROW,
        'demon_arrow',
        'ARCHERY',
        xi.effect.ATTACK_DOWN,
        xi.subEffect.ATTACK_DOWN,
        xi.element.NONE,
        xi.element.WATER,
        95,
        5,
        12,
        60),
    statusAmmunitionProfile(
        xi.item.SPARTAN_BULLET,
        'spartan_bullet',
        'MARKSMANSHIP_BULLET',
        xi.effect.STUN,
        xi.subEffect.STUN,
        xi.element.NONE,
        xi.element.THUNDER,
        10,
        5,
        10,
        5),
}

local expectedStatusAmmunition = {}
for _, definition in ipairs(statusAmmunitionDefinitions) do
    expectedStatusAmmunition[definition.itemId] = definition
end

local function validateStatusAmmunitionDefinition(definition)
    local errors = {}
    if type(definition) ~= 'table' then
        return false, { 'status-ammunition profile must be a table' }
    end

    local expected = expectedStatusAmmunition[definition.itemId]
    if not expected then
        table.insert(errors, string.format(
            'unsupported status-ammunition item ID %s',
            tostring(definition.itemId)))

        return false, errors
    end

    for _, field in ipairs({
        'itemName',
        'profileFamily',
        'ammunitionCategory',
        'triggeringAttack',
        'distancePolicy',
        'procChancePolicy',
        'levelPolicy',
        'skillBasis',
        'skillBasisPolicy',
        'governingStat',
        'governingStatPolicy',
        'dStatPolicy',
        'configuredElement',
        'effectiveElement',
        'elementPolicy',
        'statusEffect',
        'power',
        'powerPolicy',
        'duration',
        'durationPolicy',
        'resistancePolicy',
        'defensivePolicy',
        'applicationPolicy',
        'overwritePolicy',
        'presentationSubEffect',
        'presentationMessage',
        'presentationPolicy',
        'spartanCooldownPolicy',
    }) do
        if definition[field] ~= expected[field] then
            table.insert(errors, string.format(
                'item %u has invalid %s %s',
                definition.itemId,
                field,
                tostring(definition[field])))
        end
    end

    for _, field in ipairs({ 'procChance', 'levelCorrection' }) do
        if not isInteger(definition[field]) or definition[field] ~= expected[field] then
            table.insert(errors, string.format(
                'item %u has invalid %s %s',
                definition.itemId,
                field,
                tostring(definition[field])))
        end
    end

    if
        definition.classification ~= xi.additionalEffect.profile.classification.VERIFY_LIVE or
        type(definition.fieldClassifications) ~= 'table'
    then
        table.insert(errors, string.format(
            'item %u must retain explicit VERIFY_LIVE field classifications',
            definition.itemId))
    end

    return #errors == 0, errors
end

xi.additionalEffect.profile.buildStatusAmmunitionRegistry = function(definitions)
    local registry = {}
    local errors = {}

    for index, definition in ipairs(definitions) do
        local valid, validationErrors = validateStatusAmmunitionDefinition(definition)
        for _, validationError in ipairs(validationErrors) do
            table.insert(errors, string.format('definition %u: %s', index, validationError))
        end

        if valid then
            if registry[definition.itemId] then
                table.insert(errors, string.format(
                    'duplicate status-ammunition item profile %u',
                    definition.itemId))
            else
                registry[definition.itemId] = definition
            end
        end
    end

    if #errors > 0 then
        return nil, errors
    end

    return registry, errors
end

local statusAmmunitionRegistryErrors
statusAmmunitionRegistry, statusAmmunitionRegistryErrors =
    xi.additionalEffect.profile.buildStatusAmmunitionRegistry(statusAmmunitionDefinitions)
if not statusAmmunitionRegistry then
    error(table.concat(statusAmmunitionRegistryErrors, '; '))
end

xi.additionalEffect.profile.resolveStatusAmmunition = function(item)
    if item == nil then
        return nil
    end

    local itemId = type(item) == 'number' and item or item:getID()

    return statusAmmunitionRegistry[itemId]
end

xi.additionalEffect.profile.statusAmmunitionProfileCount = function()
    local count = 0
    for _ in pairs(statusAmmunitionRegistry) do
        count = count + 1
    end

    return count
end

xi.additionalEffect.profile.validateStatusAmmunition = function(profile)
    local errors = {}
    local policy = profile and profile.statusAmmunition
    local validPolicy, policyErrors = validateStatusAmmunitionDefinition(policy)
    if not validPolicy then
        return false, policyErrors
    end

    if
        profile.profileFamily ~= 'VZ_STATUS_AMMUNITION' or
        profile.classification ~= xi.additionalEffect.profile.classification.VERIFY_LIVE
    then
        table.insert(errors, 'status-ammunition profile must retain explicit VERIFY_LIVE scope')
    end

    local actualFields =
    {
        { 'proc chance', profile.proc.chance, policy.procChance },
        { 'level correction', profile.proc.levelCorrection, policy.levelCorrection },
        { 'skill basis', profile.accuracy.skillRank, policy.skillBasis },
        { 'governing stat', profile.accuracy.governingStat, policy.governingStat },
        { 'configured element', profile.accuracy.element, policy.configuredElement },
        { 'effective element', profile.accuracy.effectiveElement, policy.effectiveElement },
        { 'status effect', profile.outcome.statusEffect, policy.statusEffect },
        { 'power', profile.outcome.power, policy.power },
        { 'duration', profile.outcome.duration, policy.duration },
        { 'subeffect', profile.presentation.subEffect, policy.presentationSubEffect },
    }

    for _, field in ipairs(actualFields) do
        if field[2] ~= field[3] then
            table.insert(errors, string.format(
                'status-ammunition %s drifted: expected %s, got %s',
                field[1],
                tostring(field[3]),
                tostring(field[2])))
        end
    end

    if
        profile.outcome.family ~= 2 or
        profile.proc.triggeringAttack ~= policy.triggeringAttack or
        profile.proc.chancePolicy ~= policy.procChancePolicy or
        profile.proc.levelPolicy ~= policy.levelPolicy or
        profile.accuracy.resistancePolicy ~= 'STATUS_MAGIC_TIER' or
        profile.accuracy.partialResistPolicy ~= 'DURATION_SCALED_MIN_HALF'
    then
        table.insert(errors, 'status-ammunition execution policy drifted')
    end

    return #errors == 0, errors
end

return xi.additionalEffect.profile
