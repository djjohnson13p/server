-----------------------------------
-- Item additional-effect profiles
--
-- SQL item modifiers remain the single source of numeric configuration.
-- This layer makes policy and evidence status explicit without duplicating
-- those values in a second data store.
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

return xi.additionalEffect.profile
