describe('Elemental Arrow scripted damage profiles', function()
    local player
    local target

    local cases =
    {
        {
            itemId    = xi.item.FIRE_ARROW,
            element   = xi.element.FIRE,
            subEffect = xi.subEffect.FIRE_DAMAGE,
        },
        {
            itemId    = xi.item.ICE_ARROW,
            element   = xi.element.ICE,
            subEffect = xi.subEffect.ICE_DAMAGE,
        },
        {
            itemId    = xi.item.LIGHTNING_ARROW,
            element   = xi.element.THUNDER,
            subEffect = xi.subEffect.LIGHTNING_DAMAGE,
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

    local function isolateProfileFormula(basePower, resistRate, procResult, lifecycle)
        local procRolls          = 0
        local powerRolls         = 0
        local resistanceChecks   = 0
        local nullificationChecks = 0
        local absorptionChecks   = 0

        lifecycle = lifecycle or {}

        stub('math.randomInt', function(minimum, maximum)
            assert(minimum == 1 and maximum == 100)
            procRolls = procRolls + 1
            if type(procResult) == 'function' then
                return procResult()
            end

            return procResult == nil and 100 or procResult
        end)

        stub('math.random', function(minimum, maximum)
            assert(minimum == 7 and maximum == 10)
            powerRolls = powerRolls + 1
            return basePower
        end)

        stub('xi.combat.magicHitRate.calculateResistRate', function()
            resistanceChecks = resistanceChecks + 1
            if type(resistRate) == 'function' then
                return resistRate()
            end

            return resistRate or 1
        end)

        stub('xi.spells.damage.calculateNullification', function()
            nullificationChecks = nullificationChecks + 1
            return lifecycle.nullification == nil and 1 or lifecycle.nullification
        end)

        stub('xi.spells.damage.calculateAbsorption', function()
            absorptionChecks = absorptionChecks + 1
            return lifecycle.absorption == nil and 1 or lifecycle.absorption
        end)

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

        return function()
            return
                procRolls,
                powerRolls,
                resistanceChecks,
                nullificationChecks,
                absorptionChecks
        end
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
        target:setMaxHP(100000)
        target:setHP(target:getMaxHP())
        target:setUnkillable(false)
    end)

    it('registers exactly the three Phase B1 profiles with explicit evidence policy', function()
        assert(xi.additionalEffect.profile.scriptedDamageProfileCount() == 3)

        for _, case in ipairs(cases) do
            local profile = xi.additionalEffect.profile.resolveScriptedDamage(case.itemId)
            local valid, errors = xi.additionalEffect.profile.validateScriptedDamage(profile)

            assert(valid, table.concat(errors, '; '))
            assert(profile.itemId == case.itemId)
            assert(profile.family == 'VZ_ELEMENTAL_ARROW')
            assert(profile.classification == xi.additionalEffect.profile.classification.VERIFY_LIVE)
            assert(profile.proc.policy == 'FIXED_PERCENT_COMPATIBILITY')
            assert(profile.proc.chance == 100)
            assert(profile.proc.chanceClassification == xi.additionalEffect.profile.classification.VERIFY_LIVE)
            assert(profile.proc.levelPolicy == 'ITEM_REQUIRED_LEVEL_GATE')
            assert(profile.power.policy == 'UNIFORM_INTEGER_RANGE_COMPATIBILITY')
            assert(profile.power.minimum == 7 and profile.power.maximum == 10)
            assert(profile.power.classification == xi.additionalEffect.profile.classification.VERIFY_LIVE)
            assert(profile.accuracy.skillBasis == xi.skillRank.A_PLUS)
            assert(profile.accuracy.skillBasisClassification == xi.additionalEffect.profile.classification.VERIFY_LIVE)
            assert(profile.accuracy.actorStat == 0 and profile.accuracy.targetStat == 0)
            assert(profile.accuracy.magicAccuracy == 0)
            assert(profile.accuracy.lowestResist == 0.125)
            assert(profile.outcome.element == case.element)
            assert(profile.outcome.elementClassification == xi.additionalEffect.profile.classification.EVIDENCE_BACKED)
            assert(profile.outcome.attackType == xi.attackType.MAGICAL)
            assert(profile.multipliers.elementalSDT.classification == xi.additionalEffect.profile.classification.VERIFY_LIVE)
            assert(not profile.multipliers.magicAttackBonus.enabled)
            assert(profile.presentation.subEffect == case.subEffect)
            assert(profile.presentation.message == xi.msg.basic.ADD_EFFECT_DMG)
        end

        assert(not xi.additionalEffect.profile.resolveScriptedDamage(18699))
    end)

    it('rejects malformed and unsupported profile policies', function()
        local original = xi.additionalEffect.profile.resolveScriptedDamage(xi.item.FIRE_ARROW)

        local missingElement = copyTable(original)
        missingElement.outcome.element = nil
        local validElement, elementErrors =
            xi.additionalEffect.profile.validateScriptedDamage(missingElement)
        assert(not validElement and #elementErrors > 0)

        local malformedPower = copyTable(original)
        malformedPower.power.minimum = '7'
        local validPower, powerErrors =
            xi.additionalEffect.profile.validateScriptedDamage(malformedPower)
        assert(not validPower and #powerErrors > 0)

        local unsupportedProc = copyTable(original)
        unsupportedProc.proc.policy = 'SECOND_ROLL'
        local validProc, procErrors =
            xi.additionalEffect.profile.validateScriptedDamage(unsupportedProc)
        assert(not validProc and #procErrors > 0)

        local unsupportedMAB = copyTable(original)
        unsupportedMAB.multipliers.magicAttackBonus.enabled = true
        local validMAB, mabErrors =
            xi.additionalEffect.profile.validateScriptedDamage(unsupportedMAB)
        assert(not validMAB and #mabErrors > 0)

        local laterArrow = copyTable(original)
        laterArrow.itemId = 18699
        local validLaterArrow, laterArrowErrors =
            xi.additionalEffect.profile.validateScriptedDamage(laterArrow)
        assert(not validLaterArrow and #laterArrowErrors > 0)

        local wrongElement = copyTable(original)
        wrongElement.outcome.element = xi.element.ICE
        wrongElement.presentation.subEffect = xi.subEffect.ICE_DAMAGE
        local validWrongElement, wrongElementErrors =
            xi.additionalEffect.profile.validateScriptedDamage(wrongElement)
        assert(not validWrongElement and #wrongElementErrors > 0)
    end)

    it('rejects duplicate scripted item profile registration', function()
        local profile = xi.additionalEffect.profile.resolveScriptedDamage(xi.item.FIRE_ARROW)
        local registry, errors =
            xi.additionalEffect.profile.buildScriptedDamageRegistry({ profile, profile })

        assert(not registry)
        assert(#errors == 1)
        assert(string.find(errors[1], 'duplicate scripted damage item profile', 1, true))
    end)

    for _, basePower in ipairs({ 7, 10 }) do
        it(string.format(
            'uses the compatibility base-power boundary %u through the profile executor',
            basePower), function()
            local rollCounts = isolateProfileFormula(basePower)
            local item = findItem(xi.item.FIRE_ARROW)
            local startingHP = target:getHP()

            local subEffect, messageId, amount =
                xi.combat.action.executeScriptedDamageProfile(player, target, item)
            local procRolls, powerRolls = rollCounts()

            assert(subEffect == xi.subEffect.FIRE_DAMAGE)
            assert(messageId == xi.msg.basic.ADD_EFFECT_DMG)
            assert(amount == basePower)
            assert(startingHP - target:getHP() == amount)
            assert(procRolls == 1, string.format('profile used %u proc rolls', procRolls))
            assert(powerRolls == 1, string.format('profile used %u power rolls', powerRolls))
        end)
    end

    it('does not advance power RNG or downstream resolution after a failed proc', function()
        local profile = copyTable(
            xi.additionalEffect.profile.resolveScriptedDamage(xi.item.FIRE_ARROW))
        profile.proc.chance = 50
        stub('xi.additionalEffect.profile.resolveScriptedDamage', profile)

        local rollCounts = isolateProfileFormula(7, 1, 51)
        local item = findItem(xi.item.FIRE_ARROW)
        local applications = 0
        target:addListener('TAKE_DAMAGE', 'TEST_FAILED_PROC_APPLICATION', function()
            applications = applications + 1
        end)

        local startingHP = target:getHP()

        local subEffect, messageId, amount =
            xi.combat.action.executeScriptedDamageProfile(player, target, item)
        local procRolls, powerRolls, resistanceChecks, nullificationChecks, absorptionChecks =
            rollCounts()

        assert(subEffect == 0 and messageId == 0 and amount == 0)
        assert(target:getHP() == startingHP)
        assert(procRolls == 1)
        assert(powerRolls == 0)
        assert(resistanceChecks == 0)
        assert(nullificationChecks == 0)
        assert(absorptionChecks == 0)
        assert(applications == 0)
    end)

    it('resolves a successful configured proc through each lifecycle stage exactly once', function()
        local profile = copyTable(
            xi.additionalEffect.profile.resolveScriptedDamage(xi.item.FIRE_ARROW))
        profile.proc.chance = 50
        stub('xi.additionalEffect.profile.resolveScriptedDamage', profile)

        local rollCounts = isolateProfileFormula(7, 1, 50)
        local item = findItem(xi.item.FIRE_ARROW)
        local applications = 0
        target:addListener('TAKE_DAMAGE', 'TEST_SUCCESSFUL_PROC_APPLICATION', function()
            applications = applications + 1
        end)

        local startingHP = target:getHP()

        local subEffect, messageId, amount =
            xi.combat.action.executeScriptedDamageProfile(player, target, item)
        local procRolls, powerRolls, resistanceChecks, nullificationChecks, absorptionChecks =
            rollCounts()

        assert(subEffect == xi.subEffect.FIRE_DAMAGE)
        assert(messageId == xi.msg.basic.ADD_EFFECT_DMG and amount == 7)
        assert(startingHP - target:getHP() == amount)
        assert(procRolls == 1)
        assert(powerRolls == 1)
        assert(resistanceChecks == 1)
        assert(nullificationChecks == 1)
        assert(absorptionChecks == 1)
        assert(applications == 1)
    end)

    it('does not resolve power after full nullification', function()
        local rollCounts = isolateProfileFormula(7, 1, 1, { nullification = 0 })
        local item = findItem(xi.item.FIRE_ARROW)
        local startingHP = target:getHP()

        local subEffect, messageId, amount =
            xi.combat.action.executeScriptedDamageProfile(player, target, item)
        local procRolls, powerRolls, resistanceChecks, nullificationChecks, absorptionChecks =
            rollCounts()

        assert(subEffect == 0 and messageId == 0 and amount == 0)
        assert(target:getHP() == startingHP)
        assert(procRolls == 1)
        assert(powerRolls == 0)
        assert(resistanceChecks == 0)
        assert(nullificationChecks == 1)
        assert(absorptionChecks == 0)
    end)

    it('does not resolve power below the configured resist floor', function()
        local rollCounts = isolateProfileFormula(7, 0.0625, 1)
        local item = findItem(xi.item.FIRE_ARROW)
        local startingHP = target:getHP()

        local subEffect, messageId, amount =
            xi.combat.action.executeScriptedDamageProfile(player, target, item)
        local procRolls, powerRolls, resistanceChecks, nullificationChecks, absorptionChecks =
            rollCounts()

        assert(subEffect == 0 and messageId == 0 and amount == 0)
        assert(target:getHP() == startingHP)
        assert(procRolls == 1)
        assert(powerRolls == 0)
        assert(resistanceChecks == 1)
        assert(nullificationChecks == 1)
        assert(absorptionChecks == 0)
    end)

    it('preserves direct numeric base-power callers without a resolver invocation', function()
        local rollCounts = isolateProfileFormula(7)
        local applications = 0
        target:addListener('TAKE_DAMAGE', 'TEST_NUMERIC_POWER_APPLICATION', function()
            applications = applications + 1
        end)

        local startingHP = target:getHP()

        local subEffect, messageId, amount =
            xi.combat.action.executeAddEffectDamage(player, target, {
                chance         = 100,
                ignoreEnSpell  = true,
                basePower      = 9,
                attackType     = xi.attackType.MAGICAL,
                magicalElement = xi.element.FIRE,
                canResist      = true,
            })
        local procRolls, powerRolls, resistanceChecks, nullificationChecks, absorptionChecks =
            rollCounts()

        assert(subEffect == xi.subEffect.FIRE_DAMAGE)
        assert(messageId == xi.msg.basic.ADD_EFFECT_DMG and amount == 9)
        assert(startingHP - target:getHP() == amount)
        assert(procRolls == 1)
        assert(powerRolls == 0)
        assert(resistanceChecks == 1)
        assert(nullificationChecks == 1)
        assert(absorptionChecks == 1)
        assert(applications == 1)
    end)

    it('retains no-INT and no-MAB behavior only as a compatibility contract', function()
        isolateProfileFormula(8)
        local item = findItem(xi.item.FIRE_ARROW)
        local magicBonus = spy('xi.spells.damage.calculateMagicBonusDiff')

        local function executeWithStats(actorINT, targetINT, actorMAB)
            target:setHP(target:getMaxHP())
            player:setMod(xi.mod.INT, actorINT)
            player:setMod(xi.mod.MATT, actorMAB)
            target:setMod(xi.mod.INT, targetINT)

            local _, _, amount =
                xi.combat.action.executeScriptedDamageProfile(player, target, item)

            return amount
        end

        local baseline       = executeWithStats(0, 0, 0)
        local higherActorINT = executeWithStats(200, 0, 0)
        local higherTargetINT = executeWithStats(0, 200, 0)
        local higherActorMAB = executeWithStats(0, 0, 200)

        assert(baseline == 8)
        assert(higherActorINT == baseline)
        assert(higherTargetINT == baseline)
        assert(higherActorMAB == baseline)
        magicBonus:called(0)
    end)

    for _, tier in ipairs({
        { multiplier = 1,     expected = 8 },
        { multiplier = 0.5,   expected = 4 },
        { multiplier = 0.25,  expected = 2 },
        { multiplier = 0.125, expected = 1 },
    }) do
        it(string.format(
            'retains the compatibility %.3f resistance tier',
            tier.multiplier), function()
            isolateProfileFormula(8, tier.multiplier)
            local item = findItem(xi.item.ICE_ARROW)
            local startingHP = target:getHP()

            local subEffect, messageId, amount =
                xi.combat.action.executeScriptedDamageProfile(player, target, item)

            assert(subEffect == xi.subEffect.ICE_DAMAGE)
            assert(messageId == xi.msg.basic.ADD_EFFECT_DMG)
            assert(amount == tier.expected)
            assert(startingHP - target:getHP() == amount)
        end)
    end

    it('presents no effect below the compatibility one-eighth resist floor', function()
        isolateProfileFormula(8, 0.0625)
        local item = findItem(xi.item.LIGHTNING_ARROW)
        local startingHP = target:getHP()

        local subEffect, messageId, amount =
            xi.combat.action.executeScriptedDamageProfile(player, target, item)

        assert(subEffect == 0 and messageId == 0 and amount == 0)
        assert(target:getHP() == startingHP)
    end)

    it('passes each item element, A+ rank, and no-stat compatibility inputs to resistance', function()
        local captured = {}
        isolateProfileFormula(8)
        stub('xi.combat.magicHitRate.calculateResistRate', function(...)
            captured = { ... }
            return 1
        end)

        for _, case in ipairs(cases) do
            target:setHP(target:getMaxHP())
            captured = {}
            xi.combat.action.executeScriptedDamageProfile(
                player,
                target,
                findItem(case.itemId))

            assert(captured[5] == xi.skillRank.A_PLUS)
            assert(captured[6] == case.element)
            assert(captured[7] == 0)
            assert(captured[9] == 0)
        end
    end)

    for _, multiplier in ipairs({
        {
            name = 'general magical damage adjustment',
            path = 'xi.combat.damage.calculateDamageAdjustment',
            value = 0.5,
            expected = 4,
        },
        {
            name = 'elemental SDT',
            path = 'xi.combat.damage.magicalElementSDT',
            value = 0.5,
            expected = 4,
        },
        {
            name = 'elemental staff bonus',
            path = 'xi.spells.damage.calculateElementalStaffBonus',
            value = 1.5,
            expected = 12,
        },
        {
            name = 'elemental affinity',
            path = 'xi.spells.damage.calculateElementalAffinityBonus',
            value = 1.5,
            expected = 12,
        },
        {
            name = 'day and weather',
            path = 'xi.spells.damage.calculateDayAndWeather',
            value = 1.25,
            expected = 10,
        },
    }) do
        it(string.format(
            'retains %s only as a compatibility multiplier',
            multiplier.name), function()
            isolateProfileFormula(8)
            stub(multiplier.path, multiplier.value)
            local item = findItem(xi.item.FIRE_ARROW)

            local _, _, amount =
                xi.combat.action.executeScriptedDamageProfile(player, target, item)

            assert(amount == multiplier.expected)
        end)
    end

    it('applies Phalanx, One for All, and Stoneskin once in compatibility order', function()
        isolateProfileFormula(8)
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

        local item = findItem(xi.item.FIRE_ARROW)

        local _, _, amount =
            xi.combat.action.executeScriptedDamageProfile(player, target, item)

        assert(amount == 5)
        assert(calls.phalanx == 1 and calls.oneForAll == 1 and calls.stoneskin == 1)
    end)

    for _, case in ipairs(cases) do
        it(string.format(
            'honors %u elemental nullification once',
            case.element), function()
            isolateProfileFormula(8)
            local nullificationCalls = 0
            stub('xi.spells.damage.calculateNullification', function(_, element)
                nullificationCalls = nullificationCalls + 1
                assert(element == case.element)
                return 0
            end)

            local item = findItem(case.itemId)
            local startingHP = target:getHP()

            local subEffect, messageId, amount =
                xi.combat.action.executeScriptedDamageProfile(player, target, item)

            assert(subEffect == 0 and messageId == 0 and amount == 0)
            assert(target:getHP() == startingHP)
            assert(nullificationCalls == 1)
        end)
    end

    for _, case in ipairs(cases) do
        it(string.format(
            'honors %u elemental absorption once',
            case.element), function()
            isolateProfileFormula(8)
            local absorptionCalls = 0
            stub('xi.spells.damage.calculateAbsorption', function(_, element)
                absorptionCalls = absorptionCalls + 1
                assert(element == case.element)
                return -1
            end)

            target:setHP(target:getMaxHP() - 20)
            local item = findItem(case.itemId)
            local startingHP = target:getHP()

            local subEffect, messageId, amount =
                xi.combat.action.executeScriptedDamageProfile(player, target, item)

            assert(subEffect == case.subEffect)
            assert(messageId == xi.msg.basic.ADD_EFFECT_HEAL)
            assert(amount == 8)
            assert(target:getHP() - startingHP == amount)
            assert(absorptionCalls == 1)
        end)
    end

    it('reports only the target HP actually removed at the damage cap', function()
        isolateProfileFormula(7)
        target:setHP(5)
        local item = findItem(xi.item.FIRE_ARROW)
        local startingHP = target:getHP()

        local _, messageId, amount =
            xi.combat.action.executeScriptedDamageProfile(player, target, item)

        assert(messageId == xi.msg.basic.ADD_EFFECT_DMG)
        assert(amount == startingHP - target:getHP())
        assert(amount == 5)
    end)

    it('reports only the target HP actually restored at the healing cap', function()
        isolateProfileFormula(7)
        stub('xi.spells.damage.calculateAbsorption', -1)
        target:setHP(target:getMaxHP() - 3)
        local item = findItem(xi.item.FIRE_ARROW)
        local startingHP = target:getHP()

        local _, messageId, amount =
            xi.combat.action.executeScriptedDamageProfile(player, target, item)

        assert(messageId == xi.msg.basic.ADD_EFFECT_HEAL)
        assert(amount == target:getHP() - startingHP)
        assert(amount == 3)
    end)
end)
