describe('Vanilla and Zilart status-ammunition profiles', function()
    local player
    local target

    local cases =
    {
        {
            itemId            = xi.item.KABURA_ARROW,
            effectId          = xi.effect.SILENCE,
            subEffect         = xi.subEffect.SILENCE,
            configuredElement = xi.element.NONE,
            effectiveElement  = xi.element.WIND,
            chance            = 95,
            power             = 1,
            duration          = 60,
        },
        {
            itemId            = xi.item.PATRIARCH_PROTECTORS_ARROW,
            effectId          = xi.effect.PARALYSIS,
            subEffect         = xi.subEffect.PARALYSIS,
            configuredElement = xi.element.NONE,
            effectiveElement  = xi.element.ICE,
            chance            = 95,
            power             = 30,
            duration          = 30,
        },
        {
            itemId            = xi.item.BLIND_BOLT,
            effectId          = xi.effect.BLINDNESS,
            subEffect         = xi.subEffect.BLIND,
            configuredElement = xi.element.DARK,
            effectiveElement  = xi.element.DARK,
            chance            = 100,
            power             = 10,
            duration          = 30,
        },
        {
            itemId            = xi.item.VENOM_BOLT,
            effectId          = xi.effect.POISON,
            subEffect         = xi.subEffect.POISON,
            configuredElement = xi.element.WATER,
            effectiveElement  = xi.element.WATER,
            chance            = 100,
            power             = 4,
            duration          = 30,
        },
        {
            itemId            = xi.item.POISON_ARROW,
            effectId          = xi.effect.POISON,
            subEffect         = xi.subEffect.POISON,
            configuredElement = xi.element.NONE,
            effectiveElement  = xi.element.WATER,
            chance            = 95,
            power             = 4,
            duration          = 30,
        },
        {
            itemId            = xi.item.SLEEP_ARROW,
            effectId          = xi.effect.SLEEP_I,
            subEffect         = xi.subEffect.SLEEP,
            configuredElement = xi.element.NONE,
            effectiveElement  = xi.element.NONE,
            chance            = 95,
            power             = 0,
            duration          = 25,
        },
        {
            itemId            = xi.item.DEMON_ARROW,
            effectId          = xi.effect.ATTACK_DOWN,
            subEffect         = xi.subEffect.ATTACK_DOWN,
            configuredElement = xi.element.NONE,
            effectiveElement  = xi.element.WATER,
            chance            = 95,
            power             = 12,
            duration          = 60,
        },
        {
            itemId            = xi.item.SPARTAN_BULLET,
            effectId          = xi.effect.STUN,
            subEffect         = xi.subEffect.STUN,
            configuredElement = xi.element.NONE,
            effectiveElement  = xi.element.THUNDER,
            chance            = 10,
            power             = 10,
            duration          = 5,
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

    local function allowStatusResolution(resistRate)
        stub('xi.data.statusEffect.isTargetImmune', false)
        stub('xi.data.statusEffect.isTargetResistant', false)
        stub('xi.data.statusEffect.isEffectNullified', false)
        stub('xi.combat.magicHitRate.calculateResistRate', resistRate or 1)
        stub('math.randomInt', 1)
    end

    before_each(function()
        xi.test.world:setSeed(1)

        player = xi.test.world:spawnPlayer(
            {
                zone  = xi.zone.WEST_RONFAURE,
                job   = xi.job.RNG,
                level = 99,
            })

        target = player.entities:get('Wild_Rabbit')
        target:respawn()
        target:setMobLevel(99, true)
        target:setUnkillable(true)
    end)

    it('registers exactly the eight bounded status-ammunition profiles', function()
        assert(xi.additionalEffect.profile.statusAmmunitionProfileCount() == #cases)

        for _, case in ipairs(cases) do
            local item = findItem(case.itemId)
            local policy = xi.additionalEffect.profile.resolveStatusAmmunition(case.itemId)
            local profile = xi.additionalEffect.profile.resolve(item, 0)
            local valid, errors = xi.additionalEffect.profile.validate(profile)

            assert(policy, string.format('item %u has no scoped profile', case.itemId))
            assert(valid, table.concat(errors, '; '))
            assert(profile.profileFamily == 'VZ_STATUS_AMMUNITION')
            assert(profile.classification == xi.additionalEffect.profile.classification.VERIFY_LIVE)
            assert(profile.statusAmmunition == policy)
            assert(profile.proc.triggeringAttack == 'SUCCESSFUL_RANGED_HIT')
            assert(profile.proc.chance == case.chance)
            assert(profile.proc.levelCorrection == 5)
            assert(profile.accuracy.mode == xi.additionalEffect.profile.accuracyMode.LEGACY_UNVERIFIED_RANK)
            assert(profile.accuracy.skillRank == xi.skillRank.A)
            assert(profile.accuracy.governingStat == xi.mod.INT)
            assert(profile.accuracy.element == case.configuredElement)
            assert(profile.accuracy.effectiveElement == case.effectiveElement)
            assert(profile.outcome.statusEffect == case.effectId)
            assert(profile.outcome.power == case.power)
            assert(profile.outcome.duration == case.duration)
            assert(profile.presentation.subEffect == case.subEffect)
            assert(policy.fieldClassifications.statusEffect ==
                xi.additionalEffect.profile.classification.EVIDENCE_BACKED)
            assert(policy.fieldClassifications.procChance ==
                xi.additionalEffect.profile.classification.VERIFY_LIVE)
        end
    end)

    it('keeps Acid and Sleep Bolt evidence ownership distinct', function()
        for _, itemId in ipairs({ xi.item.ACID_BOLT, xi.item.SLEEP_BOLT }) do
            local profile = xi.additionalEffect.profile.resolve(findItem(itemId), 0)
            assert(not profile.statusAmmunition)
            assert(profile.profileFamily == 'SQL_MODIFIER_GENERIC')
            assert(profile.accuracy.mode == xi.additionalEffect.profile.accuracyMode.ITEM_NATIVE_RANK)
        end

        assert(not xi.additionalEffect.profile.resolveStatusAmmunition(21313))
    end)

    it('rejects malformed, unsupported, and duplicate status profiles', function()
        local original =
            copyTable(xi.additionalEffect.profile.resolveStatusAmmunition(xi.item.KABURA_ARROW))

        local malformedElement = copyTable(original)
        malformedElement.effectiveElement = xi.element.FIRE
        local invalidElementRegistry, elementErrors =
            xi.additionalEffect.profile.buildStatusAmmunitionRegistry({ malformedElement })
        assert(not invalidElementRegistry and #elementErrors > 0)

        local unsupported = copyTable(original)
        unsupported.itemId = 21313
        local unsupportedRegistry, unsupportedErrors =
            xi.additionalEffect.profile.buildStatusAmmunitionRegistry({ unsupported })
        assert(not unsupportedRegistry and #unsupportedErrors > 0)

        local duplicateRegistry, duplicateErrors =
            xi.additionalEffect.profile.buildStatusAmmunitionRegistry({ original, original })
        assert(not duplicateRegistry)
        assert(#duplicateErrors == 1)
        assert(string.find(duplicateErrors[1], 'duplicate status-ammunition', 1, true))
    end)

    for _, case in ipairs(cases) do
        it(string.format('applies item %u once through its validated profile', case.itemId), function()
            allowStatusResolution(1)
            local applier = spy('xi.additionalEffect.applyStatus')
            local item = findItem(case.itemId)

            local subEffect, messageId, amount =
                xi.additionalEffect.attack(player, target, 0, item)
            local effect = target:getStatusEffect(case.effectId)

            assert(subEffect == case.subEffect)
            assert(messageId == xi.msg.basic.ADD_EFFECT_STATUS_2)
            assert(amount == case.effectId)
            assert(effect, string.format('item %u did not apply its status', case.itemId))
            assert(effect:getPower() == case.power)
            assert(effect:getDuration() == case.duration * 1000)
            assert(effect:getTick() == (case.effectId == xi.effect.POISON and 3000 or 0))
            applier:called(1)
        end)
    end

    it('performs one proc roll and no downstream work after failure', function()
        local procRolls = 0
        stub('math.randomInt', function(minimum, maximum)
            assert(minimum == 1 and maximum == 100)
            procRolls = procRolls + 1
            return 96
        end)

        local resistance = spy('xi.combat.magicHitRate.calculateResistRate')
        local applier = spy('xi.additionalEffect.applyStatus')

        local subEffect, messageId, amount = xi.additionalEffect.attack(
            player,
            target,
            0,
            findItem(xi.item.KABURA_ARROW))

        assert(subEffect == 0 and messageId == 0 and amount == 0)
        assert(procRolls == 1)
        resistance:called(0)
        applier:called(0)
    end)

    it('preserves each configured proc pass boundary and level correction', function()
        stub('xi.data.statusEffect.isTargetImmune', false)
        stub('xi.data.statusEffect.isTargetResistant', false)
        stub('xi.data.statusEffect.isEffectNullified', false)
        stub('xi.combat.magicHitRate.calculateResistRate', 1)
        stub('math.randomInt', 100)

        for _, case in ipairs(cases) do
            assert(
                xi.additionalEffect.levelCorrectRates(100, 99, case.chance, 5) ==
                (case.chance == 100 and 100 or case.chance - 5))

            if case.chance == 100 then
                local subEffect = xi.additionalEffect.attack(
                    player,
                    target,
                    0,
                    findItem(case.itemId))
                assert(subEffect == case.subEffect)
                target:delStatusEffect(case.effectId)
            end
        end
    end)

    it('rejects every non-guaranteed profile above its proc boundary', function()
        stub('xi.data.statusEffect.isTargetImmune', false)
        stub('xi.data.statusEffect.isTargetResistant', false)
        stub('xi.data.statusEffect.isEffectNullified', false)
        local resistance = spy('xi.combat.magicHitRate.calculateResistRate')
        local applier = spy('xi.additionalEffect.applyStatus')
        local procRolls = 0
        stub('math.randomInt', function()
            procRolls = procRolls + 1
            return 96
        end)

        local expectedRolls = 0
        for _, case in ipairs(cases) do
            if case.chance < 100 then
                expectedRolls = expectedRolls + 1
                local subEffect, messageId, amount = xi.additionalEffect.attack(
                    player,
                    target,
                    0,
                    findItem(case.itemId))
                assert(subEffect == 0 and messageId == 0 and amount == 0)
            end
        end

        assert(procRolls == expectedRolls)
        resistance:called(0)
        applier:called(0)
    end)

    it('half-resists every scoped item by flooring only its duration', function()
        allowStatusResolution(0.5)

        for _, case in ipairs(cases) do
            local subEffect = xi.additionalEffect.attack(
                player,
                target,
                0,
                findItem(case.itemId))
            local effect = target:getStatusEffect(case.effectId)
            assert(subEffect == case.subEffect)
            assert(effect and effect:getPower() == case.power)
            assert(effect:getDuration() == math.floor(case.duration * 0.5) * 1000)
            target:delStatusEffect(case.effectId)
        end
    end)

    it('fully suppresses every scoped item below the compatibility floor', function()
        allowStatusResolution(0.25)

        for _, case in ipairs(cases) do
            local subEffect, messageId, amount = xi.additionalEffect.attack(
                player,
                target,
                0,
                findItem(case.itemId))
            assert(subEffect == 0 and messageId == 0 and amount == 0)
            assert(not target:hasStatusEffect(case.effectId))
        end
    end)

    for _, guard in ipairs({
        'xi.data.statusEffect.isTargetImmune',
        'xi.data.statusEffect.isTargetResistant',
        'xi.data.statusEffect.isEffectNullified',
    }) do
        it(string.format('applies %s to every scoped item before resistance', guard), function()
            for _, guardName in ipairs({
                'xi.data.statusEffect.isTargetImmune',
                'xi.data.statusEffect.isTargetResistant',
                'xi.data.statusEffect.isEffectNullified',
            }) do
                stub(guardName, guardName == guard)
            end

            stub('math.randomInt', 1)
            local resistance = spy('xi.combat.magicHitRate.calculateResistRate')
            local applier = spy('xi.additionalEffect.applyStatus')
            for _, case in ipairs(cases) do
                local subEffect, messageId, amount = xi.additionalEffect.attack(
                    player,
                    target,
                    0,
                    findItem(case.itemId))
                assert(subEffect == 0 and messageId == 0 and amount == 0)
            end

            resistance:called(0)
            applier:called(0)
        end)
    end

    for _, resistRate in ipairs({ 1, 0.5, 0.25, 0.125, 0 }) do
        it(string.format('preserves the compatibility status resist tier %.3f', resistRate), function()
            allowStatusResolution(resistRate)

            local subEffect, messageId, amount = xi.additionalEffect.attack(
                player,
                target,
                0,
                findItem(xi.item.KABURA_ARROW))
            local effect = target:getStatusEffect(xi.effect.SILENCE)

            if resistRate >= 0.5 then
                assert(subEffect == xi.subEffect.SILENCE)
                assert(messageId == xi.msg.basic.ADD_EFFECT_STATUS_2)
                assert(amount == xi.effect.SILENCE)
                assert(effect and effect:getDuration() == math.floor(60 * resistRate) * 1000)
            else
                assert(subEffect == 0 and messageId == 0 and amount == 0)
                assert(not effect)
            end
        end)
    end

    it('transports the compatibility rank, stat, element, and effect once', function()
        stub('xi.data.statusEffect.isTargetImmune', false)
        stub('xi.data.statusEffect.isTargetResistant', false)
        stub('xi.data.statusEffect.isEffectNullified', false)
        stub('math.randomInt', 1)

        local resistanceCalls = 0
        stub('xi.combat.magicHitRate.calculateResistRate',
        function(actor, defender, _, _, skillRank, element, governingStat, effectId)
            resistanceCalls = resistanceCalls + 1
            assert(actor == player and defender == target)
            assert(skillRank == xi.skillRank.A)
            assert(element == xi.element.DARK)
            assert(governingStat == xi.mod.INT)
            assert(effectId == xi.effect.BLINDNESS)
            return 1
        end)

        xi.additionalEffect.attack(player, target, 0, findItem(xi.item.BLIND_BOLT))
        assert(resistanceCalls == 1)
    end)

    it('does not present or strip after authoritative application rejection', function()
        allowStatusResolution(1)
        target:addStatusEffect(xi.effect.ATTACK_BOOST, { power = 25, duration = 60, origin = player })
        stub('xi.additionalEffect.applyStatus', false)
        local remover = spy('xi.additionalEffect.removeOpposingStatus')

        local subEffect, messageId, amount = xi.additionalEffect.attack(
            player,
            target,
            0,
            findItem(xi.item.DEMON_ARROW))

        assert(subEffect == 0 and messageId == 0 and amount == 0)
        assert(target:hasStatusEffect(xi.effect.ATTACK_BOOST))
        remover:called(0)
    end)

    it('removes the opposing boost exactly once only after successful application', function()
        allowStatusResolution(1)
        local remover = spy('xi.additionalEffect.removeOpposingStatus')

        local subEffect = xi.additionalEffect.attack(
            player,
            target,
            0,
            findItem(xi.item.DEMON_ARROW))

        assert(subEffect == xi.subEffect.ATTACK_DOWN)
        assert(target:hasStatusEffect(xi.effect.ATTACK_DOWN))
        remover:called(1)
        assert(remover.calls[1].args[2] == xi.effect.ATTACK_BOOST)
    end)
end)
