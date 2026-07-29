-----------------------------------
-- This global is intended to handle additional effects from item sources of:
-- melee attacks, ranged attacks, auto-spikes
-----------------------------------
require('scripts/globals/magic') -- For resist functions
require('scripts/globals/teleports') -- For warp weapon proc.
require('scripts/globals/additional_effect_profiles')
-----------------------------------
xi = xi or {}
xi.additionalEffect = xi.additionalEffect or {}
xi.additionalEffect.procFunctions = xi.additionalEffect.procFunctions or {}

xi.additionalEffect.dStatBonus = function(attacker, defender, dStat, damage)
    local statTable =
    {
        -- [attacker stat] = {counter stat, softcap},
        [xi.mod.MND] = { cStat = xi.mod.MND, softcap = 40 },
        [xi.mod.INT] = { cStat = xi.mod.INT, softcap = 20 },
        -- Can use pretty much any modifier and the pairs don't have to math (in case of SE shenanigans..)
    }

    local tableRow = statTable[dStat]
    local sCap = tableRow.softcap
    local bonus = 0

    -- Check if this is base stat or other modifier
    if dStat >= xi.mod.STR and dStat <= xi.mod.CHR then
        bonus = attacker:getStat(dStat) - defender:getStat(tableRow.cStat)
    else
        -- See table note above
        bonus = attacker:getMod(dStat) - defender:getMod(tableRow.cStat)
    end

    if bonus then
        if sCap > 0 and bonus > sCap then
            bonus = bonus + (bonus - sCap) / 2
        end

        if bonus > 0 then
            damage = damage + bonus
        end
    end

    return damage
end

xi.additionalEffect.levelCorrectRates = function(dLV, aLV, chance, lvCorrect)
    -- Do not alter 100% proc rates
    if chance < 100 then
        if dLV > aLV then
            chance = utils.clamp(chance - lvCorrect * (dLV - aLV), 1, 99)
        end
    end

    return chance
end

xi.additionalEffect.statusAttack = function(addStatus)
    local effectList =
    {
        [xi.effect.DEFENSE_DOWN] = { tick = 0, strip = xi.effect.DEFENSE_BOOST },
        [xi.effect.EVASION_DOWN] = { tick = 0, strip = xi.effect.EVASION_BOOST },
        [xi.effect.ATTACK_DOWN]  = { tick = 0, strip = xi.effect.ATTACK_BOOST },
        [xi.effect.POISON]       = { tick = 3, strip = nil },
        [xi.effect.CHOKE]        = { tick = 3, strip = nil },
    }

    local effect = effectList[addStatus]
    if effect then
        return effect.tick, effect.strip
    end

    return 0, nil
end

xi.additionalEffect.applyStatus = function(target, effectId, params)
    return target:addStatusEffect(effectId, params)
end

xi.additionalEffect.removeOpposingStatus = function(target, effectId)
    target:delStatusEffect(effectId)
end

-- Pure damage calculation. The outcome is applied exactly once by the
-- selected proc handler after packet presentation values are resolved.
xi.additionalEffect.calcDamage = function(attacker, element, defender, damage)
    local params = {}

    params.bonusmab   = 0
    params.includemab = false
    damage            = addBonusesAbility(attacker, element, defender, damage, params)
    damage            = math.floor(damage * applyResistanceAddEffect(attacker, defender, element, 0))
    damage            = math.floor(damage * xi.spells.damage.calculateAbsorption(defender, element, false, true, false, false))
    damage            = math.floor(damage * xi.spells.damage.calculateNullification(defender, element, false, true, false, false))
    damage            = math.floor(damage * xi.combat.damage.calculateDamageAdjustment(defender, false, true, false, false))
    damage            = math.floor(defender:handleSevereDamage(damage, false))
    damage            = utils.handlePhalanx(defender, damage)
    damage            = utils.handleOneForAll(defender, damage)
    damage            = utils.handleStoneskin(defender, damage)

    return utils.clamp(damage, -99999, 99999)
end

xi.additionalEffect.applyDamage = function(attacker, defender, damage, attackType, damageType)
    if damage < 0 then
        return -defender:addHP(-damage)
    elseif damage == 0 then
        return 0
    end

    local startingHP = defender:getHP()
    defender:takeDamage(damage, attacker, attackType, damageType)

    return startingHP - defender:getHP()
end

xi.additionalEffect.calcPhysDamage = function(attacker, defender, item, params)
    params.isPhysical = params.isPhysical or false
    params.isRanged   = params.isRanged or false
    params.isBreath   = params.isBreath or false
    params.damageType = params.damageType or xi.damageType.NONE
    params.damage     = math.floor(params.damage) or 0

    if params.damage == 0 then
        return 0
    end

    -- Check nullification
    if math.randomInt(1, 100) <= defender:getMod(xi.mod.NULL_DAMAGE) then
        return 0
    end

    if
        params.isPhysical and
        math.randomInt(1, 100) <= defender:getMod(xi.mod.NULL_PHYSICAL_DAMAGE)
    then
        return 0
    end

    if
        params.isRanged and
        math.randomInt(1, 100) <= defender:getMod(xi.mod.NULL_RANGED_DAMAGE)
    then
        return 0
    end

    if
        params.isBreath and
        math.randomInt(1, 100) <= defender:getMod(xi.mod.NULL_BREATH_DAMAGE)
    then
        return 0
    end

    -- Check absorbs
    -- Absorb: All damage.
    if math.randomInt(1, 100) <= defender:getMod(xi.mod.ABSORB_DMG_CHANCE) then
        return params.damage * -1
    end

    -- Absorb: ranged or phys
    if
        (params.isPhysical or params.isRanged) and
        math.randomInt(1, 100) <= defender:getMod(xi.mod.PHYS_ABSORB)
    then
        return params.damage * -1
    end

    params.damage = params.damage * xi.combat.damage.calculateDamageAdjustment(defender, params.isPhysical, false, params.isRanged, params.isBreath)

    -- multiplicative
    switch (params.damageType) : caseof
    {
        [xi.damageType.PIERCING] = function()
            params.damage = params.damage * (1 + defender:getMod(xi.mod.PIERCE_SDT) / 10000)
        end,

        [xi.damageType.SLASHING] = function()
            params.damage = params.damage * (1 + defender:getMod(xi.mod.SLASH_SDT) / 10000)
        end,

        [xi.damageType.BLUNT] = function() -- aka IMPACT
            params.damage = params.damage * (1 + defender:getMod(xi.mod.IMPACT_SDT) / 10000)
        end,

        [xi.damageType.HAND_TO_HAND] = function()
            params.damage = params.damage * (1 + defender:getMod(xi.mod.HTH_SDT) / 10000)
        end,
    }

    params.damage = math.floor(params.damage)

    params.damage = utils.handlePhalanx(defender, params.damage)
    params.damage = utils.handleStoneskin(defender, params.damage)

    return params.damage
end

xi.additionalEffect.procType =
{
    -- These are arbitrary, make up new ones as needed.
    DAMAGE        = 1,
    DEBUFF        = 2,
    HP_HEAL       = 3,
    MP_HEAL       = 4,
    HP_DRAIN      = 5,
    MP_DRAIN      = 6,
    TP_DRAIN      = 7,
    HPMP_DRAIN    = 8,
    HPMPTP_DRAIN  = 9,
    DISPEL        = 10,
    ABSORB_STATUS = 11,
    SELF_BUFF     = 12,
    DEATH         = 13,
    NM_SPECIFIC   = 14,
    PHYS_DAMAGE   = 15,
}

xi.additionalEffect.procFunctions[xi.additionalEffect.procType.DAMAGE] = function(attacker, defender, item, params)
    local subEffect = params.subEffect
    local msgID     = 0
    local msgParam  = 0

    local damage = xi.additionalEffect.calcDamage(attacker, params.element, defender, params.damage)
    damage = xi.additionalEffect.applyDamage(
        attacker,
        defender,
        damage,
        xi.attackType.MAGICAL,
        xi.damageType.ELEMENTAL + params.element)
    msgID  = xi.msg.basic.ADD_EFFECT_DMG

    if damage < 0 then
        msgID = xi.msg.basic.ADD_EFFECT_HEAL

        damage = damage * -1
    end

    msgParam = damage

    return subEffect, msgID, msgParam
end

xi.additionalEffect.procFunctions[xi.additionalEffect.procType.DEBUFF] = function(actor, target, item, params)
    -- Early return: No actor or target.
    if
        not actor or
        not target
    then
        return 0, 0, 0
    end

    -- Validate parameters.
    local effectId      = utils.defaultIfNil(params.addStatus, 0)
    local subEffect     = utils.defaultIfNil(params.subEffect, 0)
    local actionElement = params.element > 0 and params.element or xi.data.statusEffect.getAssociatedElement(effectId, xi.element.NONE)

    -- Early return: No effect to apply.
    if effectId == 0 then
        return 0, 0, 0
    end

    -- Early return: Target is immune to the effect.
    if xi.data.statusEffect.isTargetImmune(target, effectId, actionElement) then
        return 0, 0, 0
    end

    -- Early return: Trait nullifies effect.
    if xi.data.statusEffect.isTargetResistant(actor, target, effectId) then
        return 0, 0, 0
    end

    -- Early return: Incompatible effect in place.
    if xi.data.statusEffect.isEffectNullified(target, effectId, 0) then
        return 0, 0, 0
    end

    -- Early return: Regular resist rate.
    local resistRate = xi.combat.magicHitRate.calculateResistRate(
        actor,
        target,
        0,
        0,
        params.skillRank,
        actionElement,
        params.governingStat,
        effectId,
        0)
    if resistRate < 0.5 then
        return 0, 0, 0
    end

    -- Apply status effect.
    local power = params.power
    local tick, opposingBoost = xi.additionalEffect.statusAttack(effectId)
    local duration = math.floor(params.duration * resistRate)

    local statusApplied = xi.additionalEffect.applyStatus(
        target,
        effectId,
        { power = power, duration = duration, origin = actor, tick = tick })
    if not statusApplied then
        return 0, 0, 0
    end

    if opposingBoost then
        xi.additionalEffect.removeOpposingStatus(target, opposingBoost)
    end

    return subEffect, xi.msg.basic.ADD_EFFECT_STATUS_2, effectId
end

xi.additionalEffect.procFunctions[xi.additionalEffect.procType.HP_HEAL] =  function(attacker, defender, item, params)
    local subEffect = params.subEffect
    local msgID     = 0
    local msgParam  = 0
    -- Its not a drain and works vs undead. https://www.bg-wiki.com/bg/Dominion_Mace
    local hitPoints = params.damage -- Note: not actually damage, if you wanted damage see HP_DRAIN instead
    -- Unknown what modifies the HP, using power directly for now
    msgID = xi.msg.basic.ADD_EFFECT_HP_HEAL
    attacker:addHP(hitPoints)
    msgParam = hitPoints

    return subEffect, msgID, msgParam
end

xi.additionalEffect.procFunctions[xi.additionalEffect.procType.MP_HEAL] =  function(attacker, defender, item, params)
    local subEffect = params.subEffect
    local msgID     = 0
    local msgParam  = 0

    local magicPoints = params.damage
    -- Unknown what modifies this, using power directly for now
    msgID = xi.msg.basic.ADD_EFFECT_MP_HEAL
    attacker:addMP(magicPoints)
    msgParam = magicPoints

    return subEffect, msgID, msgParam
end

xi.additionalEffect.procFunctions[xi.additionalEffect.procType.HP_DRAIN] =  function(attacker, defender, item, params)
    local subEffect = params.subEffect
    local msgID     = 0
    local msgParam  = 0

    -- Hardcoded for now
    params.element = xi.element.DARK
    -- Undead cannot be drained
    if defender:isUndead() then
        return 0, 0, 0
    end

    local damage = xi.additionalEffect.calcDamage(attacker, params.element, defender, params.damage)
    damage = math.max(math.min(damage, defender:getHP()), 0)
    damage = xi.additionalEffect.applyDamage(
        attacker,
        defender,
        damage,
        xi.attackType.MAGICAL,
        xi.damageType.DARK)

    msgID    = xi.msg.basic.ADD_EFFECT_HP_DRAIN
    msgParam = damage
    attacker:addHP(damage)

    return subEffect, msgID, msgParam
end

xi.additionalEffect.procFunctions[xi.additionalEffect.procType.MP_DRAIN] =  function(attacker, defender, item, params)
    local subEffect = params.subEffect
    local msgID     = 0
    local msgParam  = 0

    -- Hardcoded for now
    params.element = xi.element.DARK
    -- Undead cannot be drained
    if defender:isUndead() then
        return 0, 0, 0
    end

    local damage = xi.additionalEffect.calcDamage(attacker, params.element, defender, params.damage)
    damage = math.max(math.min(damage, defender:getMP()), 0)

    msgID    = xi.msg.basic.ADD_EFFECT_MP_DRAIN
    msgParam = damage
    defender:addMP(-damage)
    attacker:addMP(damage)

    return subEffect, msgID, msgParam
end

xi.additionalEffect.procFunctions[xi.additionalEffect.procType.TP_DRAIN] =  function(attacker, defender, item, params)
    local subEffect = params.subEffect
    local msgID     = 0
    local msgParam  = 0

    -- Hardcoded for now
    params.element = xi.element.DARK

    -- Undead cannot be drained
    if defender:isUndead() then
        return 0, 0, 0
    end

    local damage = xi.additionalEffect.calcDamage(attacker, params.element, defender, params.damage)

    damage = math.max(math.min(damage, defender:getTP()), 0)

    msgID    = xi.msg.basic.ADD_EFFECT_TP_DRAIN
    msgParam = damage
    defender:addTP(-damage)
    attacker:addTP(damage)

    return subEffect, msgID, msgParam
end

-- Shared one-resource transfer primitive for the explicitly profiled drain
-- families. Selection and overall proc ownership remain with their callers.
xi.additionalEffect.executeResourceDrainTransfer = function(
    attacker,
    defender,
    params,
    policy,
    resource)
    if
        not attacker or
        not defender or
        type(params) ~= 'table' or
        type(policy) ~= 'table' or
        type(resource) ~= 'string'
    then
        return 0, 0, 0
    end

    if defender:isDead() or defender:isUndead() then
        return 0, 0, 0
    end

    local amount = xi.additionalEffect.calcDamage(
        attacker,
        policy.effectiveElement,
        defender,
        params.damage)
    amount = math.max(amount, 0)

    local availableResource
    if resource == 'HP' then
        availableResource = defender:getHP()
    elseif resource == 'MP' then
        availableResource = defender:getMP()
    elseif resource == 'TP' then
        availableResource = defender:getTP()
    else
        return 0, 0, 0
    end

    local message = policy.presentationMessage or
        (type(policy.resourceMessages) == 'table' and policy.resourceMessages[resource])
    if not message then
        return 0, 0, 0
    end

    amount = math.min(amount, availableResource)
    if amount <= 0 then
        return policy.presentationSubEffect, message, 0
    end

    local removed
    if resource == 'HP' then
        removed = xi.additionalEffect.applyDamage(
            attacker,
            defender,
            amount,
            xi.attackType.MAGICAL,
            xi.damageType.DARK)
        attacker:addHP(removed)
    elseif resource == 'MP' then
        local startingMP = defender:getMP()
        defender:addMP(-amount)
        removed = startingMP - defender:getMP()
        attacker:addMP(removed)
    else
        local startingTP = defender:getTP()
        defender:addTP(-amount)
        removed = startingTP - defender:getTP()
        attacker:addTP(removed)
    end

    return policy.presentationSubEffect, message, removed
end

-- Exact-scope entry point for the three Phase B3 single-resource profiles.
xi.additionalEffect.executeSingleResourceDrain = function(attacker, defender, params)
    if
        type(params) ~= 'table' or
        type(params.profile) ~= 'table' or
        type(params.profile.singleResourceDrain) ~= 'table'
    then
        return 0, 0, 0
    end

    local policy = params.profile.singleResourceDrain

    return xi.additionalEffect.executeResourceDrainTransfer(
        attacker,
        defender,
        params,
        policy,
        policy.resource)
end

xi.additionalEffect.selectCombinedResourceDrainBranch = function(policy, selector)
    if
        type(policy) ~= 'table' or
        type(policy.branchResources) ~= 'table' or
        type(selector) ~= 'number' or
        selector ~= math.floor(selector)
    then
        return nil
    end

    return policy.branchResources[selector]
end

-- Exact-scope selection and transfer owner for the three Phase B4 combined
-- profiles. The compatibility policy selects one branch and never retries.
xi.additionalEffect.executeCombinedResourceDrain = function(attacker, defender, params)
    if
        not attacker or
        not defender or
        type(params) ~= 'table' or
        type(params.profile) ~= 'table' or
        type(params.profile.combinedResourceDrain) ~= 'table' or
        defender:isDead()
    then
        return 0, 0, 0
    end

    local policy = params.profile.combinedResourceDrain
    local resourceCount = #policy.branchResources
    if resourceCount == 0 then
        return 0, 0, 0
    end

    local selector = math.randomInt(1, resourceCount)
    local resource =
        xi.additionalEffect.selectCombinedResourceDrainBranch(policy, selector)
    if not resource then
        return 0, 0, 0
    end

    return xi.additionalEffect.executeResourceDrainTransfer(
        attacker,
        defender,
        params,
        policy,
        resource)
end

-- TODO: add resistance check for params.element
xi.additionalEffect.procFunctions[xi.additionalEffect.procType.DISPEL] =  function(attacker, defender, item, params)
    local subEffect = params.subEffect
    local msgID     = 0
    local msgParam  = 0

    local dispel = defender:dispelStatusEffect()

    if dispel == xi.effect.NONE then
        return 0, 0, 0
    else
        msgID = xi.msg.basic.ADD_EFFECT_DISPEL
        msgParam = dispel
    end

    return subEffect, msgID, msgParam
end

xi.additionalEffect.procFunctions[xi.additionalEffect.procType.ABSORB_STATUS] =  function(attacker, defender, item, params)
    local subEffect = params.subEffect
    local msgID     = 0
    local msgParam  = 0

    -- Ripping off Aura Steal here
    local resist = applyResistanceAddEffect(attacker, defender, params.element, 0)
    if resist > 0.0625 then
        local stolen = attacker:stealStatusEffect(defender)
        msgID        = xi.msg.basic.STEAL_EFFECT
        msgParam     = stolen
    end

    return subEffect, msgID, msgParam
end

xi.additionalEffect.procFunctions[xi.additionalEffect.procType.SELF_BUFF] =  function(attacker, defender, item, params)
    local subEffect = params.subEffect
    local msgID     = 0
    local msgParam  = 0

    if params.addStatus == xi.effect.BLINK then -- BLINK http://www.ffxiah.com/item/18830/gusterion
        -- Does not stack with or replace other shadows
        if
            attacker:hasStatusEffect(xi.effect.BLINK) or
            attacker:hasStatusEffect(xi.effect.COPY_IMAGE)
        then
            return 0, 0, 0
        else
            attacker:addStatusEffect(xi.effect.BLINK, { power = params.power, duration = params.duration, origin = attacker })
            msgID    = xi.msg.basic.ADD_EFFECT_SELFBUFF
            msgParam = xi.effect.BLINK
        end
    elseif params.addStatus == xi.effect.HASTE then
        attacker:addStatusEffect(xi.effect.HASTE, { power = params.power, duration = params.duration, origin = attacker })
        -- Todo: verify power/duration/tier/overwrite etc
        msgID    = xi.msg.basic.ADD_EFFECT_SELFBUFF
        msgParam = xi.effect.HASTE
    else
        print('scripts/globals/additional_effects.lua : unhandled additional effect selfbuff! Effect ID: ' .. params.addStatus)
    end

    return subEffect, msgID, msgParam
end

xi.additionalEffect.procFunctions[xi.additionalEffect.procType.DEATH] = function(attacker, defender, item, params)
    local subEffect = params.subEffect
    local msgID     = 0
    local msgParam  = 0

    if
        defender:isNM() or
        defender:isUndead() or
        -- Todo: DeathRes has no place in the resistance functions so far..
        math.randomInt(1, 100) > defender:getMod(xi.mod.DEATHRES) -- We are checking for a fail, not a success.
    then
        return 0, 0, 0 -- NMs immune or roll failed so return out
    else
        msgID = xi.msg.basic.ADD_EFFECT_STATUS
        msgParam = xi.effect.KO
        defender:setHP(0)
    end

    return subEffect, msgID, msgParam
end

xi.additionalEffect.procFunctions[xi.additionalEffect.procType.HPMP_DRAIN] = function(attacker, defender, item, params)
    -- VZ-COMBAT-001 compatibility policy: the current random branch is
    -- isolated and classified VERIFY_LIVE until retail ordering is captured.
    local drainRoll = math.randomInt(1, 2)

    local drainFuncs =
    {
        [1] = xi.additionalEffect.procType.HP_DRAIN,
        [2] = xi.additionalEffect.procType.MP_DRAIN
    }

    return xi.additionalEffect.procFunctions[drainFuncs[drainRoll]](attacker, defender, item, params)
end

xi.additionalEffect.procFunctions[xi.additionalEffect.procType.HPMPTP_DRAIN] = function(attacker, defender, item, params)
    -- VZ-COMBAT-001 compatibility policy: the current random branch is
    -- isolated and classified VERIFY_LIVE until retail ordering is captured.
    local drainRoll = math.randomInt(1, 3)

    local drainFuncs =
    {
        [1] = xi.additionalEffect.procType.HP_DRAIN,
        [2] = xi.additionalEffect.procType.MP_DRAIN,
        [3] = xi.additionalEffect.procType.TP_DRAIN
    }

    return xi.additionalEffect.procFunctions[drainFuncs[drainRoll]](attacker, defender, item, params)
end

-- Script only for now
xi.additionalEffect.procFunctions[xi.additionalEffect.procType.PHYS_DAMAGE] = function(attacker, defender, item, params)
    local subEffect = params.subEffect
    local msgID     = 0
    local msgParam  = 0

    local damage = xi.additionalEffect.calcPhysDamage(attacker, defender, item, params)
    msgID  = xi.msg.basic.ADD_EFFECT_DMG

    if damage < 0 then
        msgID = xi.msg.basic.ADD_EFFECT_HEAL

        damage = -xi.additionalEffect.applyDamage(
            attacker,
            defender,
            damage,
            params.isRanged and xi.attackType.RANGED or
                (params.isBreath and xi.attackType.BREATH or xi.attackType.PHYSICAL),
            params.damageType)
    else
        damage = xi.additionalEffect.applyDamage(
            attacker,
            defender,
            damage,
            params.isRanged and xi.attackType.RANGED or
                (params.isBreath and xi.attackType.BREATH or xi.attackType.PHYSICAL),
            params.damageType)
    end

    msgParam = damage

    return subEffect, msgID, msgParam
end

-- NM-specific additional effects configuration table
-- Options: requiredItem, specialAction, customSubEffect, customMsgID, customMsgParam
-- Add new entries here: ['NM_Name'] = { requiredItem = xi.item.ITEM_ID, specialAction = function() }
xi.additionalEffect.nmSpecificConfigs = {
    ['Brigandish_Blade'] = {
        requiredItem = xi.item.BUCCANEERS_KNIFE,
        specialAction = function(defender)
            -- If Brigandish Blade has damage immunity (at 1% HP), remove it
            if defender:getMod(xi.mod.UDMGPHYS) == -10000 then
                -- Remove all damage immunities
                defender:setMod(xi.mod.UDMGPHYS, 0)
                defender:setMod(xi.mod.UDMGRANGE, 0)
                defender:setMod(xi.mod.UDMGMAGIC, 0)
                defender:setMod(xi.mod.UDMGBREATH, 0)

                defender:setLocalVar('killable', 1)
                defender:setUnkillable(false)
            end
        end,
    },
    ['Seiryu'] = {
        requiredItem = xi.item.ZEPHYR,
        specialAction = function(defender)
            defender:setMobMod(xi.mobMod.ADD_EFFECT, 0)
        end,
    },
    ['Genbu'] = {
        requiredItem = xi.item.ANTARCTIC_WIND,
        specialAction = function(defender)
            defender:setMobMod(xi.mobMod.ADD_EFFECT, 0)
        end,
    },
    ['Suzaku'] = {
        requiredItem = xi.item.ARCTIC_WIND,
        specialAction = function(defender)
            defender:setMobMod(xi.mobMod.ADD_EFFECT, 0)
        end,
    },
    ['Byakko'] = {
        requiredItem = xi.item.EAST_WIND,
        specialAction = function(defender)
            defender:setMobMod(xi.mobMod.ADD_EFFECT, 0)
        end,
    },
}

-- NM_SPECIFIC additional effect trigger
xi.additionalEffect.procFunctions[xi.additionalEffect.procType.NM_SPECIFIC] = function(attacker, defender, item, params)
    local subEffect = params.subEffect
    local msgID     = 0
    local msgParam  = 0
    local defenderName = defender:getName()

    local config = xi.additionalEffect.nmSpecificConfigs[defenderName]
    if
        config and
        (config.requiredItem == item:getID() or
        config.requiredItem == xi.item.NONE)
    then
        -- Calculate damage
        local damage = xi.additionalEffect.calcDamage(attacker, params.element, defender, params.damage)
        damage = xi.additionalEffect.applyDamage(
            attacker,
            defender,
            damage,
            xi.attackType.MAGICAL,
            xi.damageType.ELEMENTAL + params.element)
        msgID = xi.msg.basic.ADD_EFFECT_DMG
        msgParam = damage

        -- Execute special action if configured
        if config.specialAction then
            config.specialAction(defender)
        end

        subEffect = config.customSubEffect or subEffect
        msgID = config.customMsgID or msgID
        msgParam = config.customMsgParam or msgParam
    else
        if defender and item then
            defender:setLocalVar('aeFromItemId', item:getID())
        end

        return 0, 0, 0
    end

    return subEffect, msgID, msgParam
end

-- paralyze on hit, fire damage on hit, etc.
xi.additionalEffect.attack = function(attacker, defender, baseAttackDamage, item)
    if not attacker or not defender or not item then
        return 0, 0, 0
    end

    -- If player is level synced below the level of the item, do no proc
    if item:getReqLvl() > attacker:getMainLvl() then
        return 0, 0, 0
    end

    local profile = xi.additionalEffect.profile.resolve(item, baseAttackDamage)
    local valid, errors = xi.additionalEffect.profile.validate(profile)
    if not valid then
        if not xi.additionalEffect.profile.reportedInvalidItems[item:getID()] then
            print(string.format(
                'ERR: invalid additional-effect profile for item %u: %s',
                item:getID(),
                table.concat(errors, '; ')))
            xi.additionalEffect.profile.reportedInvalidItems[item:getID()] = true
        end

        return 0, 0, 0
    end

    if
        (profile.singleResourceDrain or profile.combinedResourceDrain) and
        defender:isDead()
    then
        return 0, 0, 0
    end

    local params =
    {
        profile          = profile,
        lvCorrect        = profile.proc.levelCorrection,
        dStat            = item:getMod(xi.mod.ITEM_ADDEFFECT_DSTAT),
        addType          = profile.outcome.family,
        subEffect        = profile.presentation.subEffect,
        damage           = profile.outcome.damage,
        chance           = profile.proc.chance,
        element          = profile.accuracy.element,
        skillRank        = profile.accuracy.skillRank,
        governingStat    = profile.accuracy.governingStat,
        addStatus        = profile.outcome.statusEffect,
        power            = profile.outcome.power,
        duration         = profile.outcome.duration,
        baseAttackDamage = profile.outcome.baseAttackDamage,
    }

    params.chance = xi.additionalEffect.levelCorrectRates(
        defender:getMainLvl(),
        attacker:getMainLvl(),
        params.chance,
        params.lvCorrect)

    -- If we're not going to proc, lets not execute all those checks!
    if math.randomInt(1, 100) > params.chance then
        return 0, 0, 0
    end

    -- Archery/marksmanship use this, most other items -usually- do not (See notes at top of script).
    if params.dStat > 0 then
        params.damage = xi.additionalEffect.dStatBonus(attacker, defender, params.dStat, params.damage)
    end

    if profile.singleResourceDrain then
        return xi.additionalEffect.executeSingleResourceDrain(attacker, defender, params)
    elseif profile.combinedResourceDrain then
        return xi.additionalEffect.executeCombinedResourceDrain(attacker, defender, params)
    elseif xi.additionalEffect.procFunctions[params.addType] then
        return xi.additionalEffect.procFunctions[params.addType](attacker, defender, item, params)
    else
        print('ERR: xi.additionalEffect.attack passed invalid/unimplemented addType of ' .. tostring(params.addType))
    end

    return 0, 0, 0
end

xi.additionalEffect.spikes = function(attacker, defender, damage, spikeEffect, power, chance)
    --[[ Todo..
    local procType =
    {
        -- These are arbitrary, make up new ones as needed.
    }
    ]]
end
