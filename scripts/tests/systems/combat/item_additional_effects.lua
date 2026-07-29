describe('Item additional effect framework', function()
    local player
    local target

    local siroccoKukri = 18018

    local function findTestItem(itemId)
        player:addItem(itemId)
        local item = player:findItem(itemId)
        assert(item, string.format('test item %u was not created', itemId))

        return item
    end

    local function isolateMagicalDamage()
        stub('addBonusesAbility', function(_, _, _, damage)
            return damage
        end)

        stub('applyResistanceAddEffect', 1)
        stub('xi.combat.damage.calculateDamageAdjustment', 1)
    end

    local function isolateMagicalFormula()
        stub('addBonusesAbility', function(_, _, _, damage)
            return damage
        end)

        stub('applyResistanceAddEffect', 1)
        stub('xi.combat.damage.calculateDamageAdjustment', 1)
        stub('math.randomInt', 1)
    end

    local function allowStatusResolution(resistRate, blockedGuard)
        for _, guard in ipairs({
            'xi.data.statusEffect.isTargetImmune',
            'xi.data.statusEffect.isTargetResistant',
            'xi.data.statusEffect.isEffectNullified',
        }) do
            stub(guard, guard == blockedGuard)
        end

        stub('xi.combat.magicHitRate.calculateResistRate', resistRate)
        stub('math.randomInt', 1)
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
        target:setUnkillable(true)
        target:setHP(target:getMaxHP())
    end)

    it('applies configured magical damage exactly once', function()
        isolateMagicalDamage()
        stub('xi.spells.damage.calculateAbsorption', 1)
        stub('xi.spells.damage.calculateNullification', 1)

        local item       = findTestItem(siroccoKukri)
        local startingHP = target:getHP()
        local subEffect, messageId, amount = xi.additionalEffect.attack(player, target, 0, item)

        assert(subEffect == xi.subEffect.WIND_DAMAGE, 'unexpected additional-effect animation')
        assert(messageId == xi.msg.basic.ADD_EFFECT_DMG, 'unexpected additional-effect message')
        assert(amount == 9, string.format('expected packet amount 9, got %s', tostring(amount)))
        assert(startingHP - target:getHP() == amount, 'target HP mutation did not match the packet amount')
    end)

    it('serializes each applied magical effect once through a real melee action', function()
        isolateMagicalDamage()
        stub('xi.spells.damage.calculateAbsorption', 1)
        stub('xi.spells.damage.calculateNullification', 1)
        stub('math.randomInt', 1)
        local applier = spy('xi.additionalEffect.applyDamage')

        player:changeJob(xi.job.THF)
        player:setLevel(99)
        player:setMod(xi.mod.ACC, 1000)
        player:addItem(siroccoKukri)
        player:equipItem(siroccoKukri, nil, xi.slot.MAIN)
        assert(player:getEquippedItem(xi.slot.MAIN):getID() == siroccoKukri)

        player.packets:clear()
        player.actions:engage(target)
        for _ = 1, 5 do
            xi.test.world:tickEntity(player)
            xi.test.world:skipTime(5)
        end

        local procResults = {}
        for _, action in pairs(player.packets:actionPackets()) do
            if action.cmd_no == xi.action.category.BASIC_ATTACK then
                for _, actionTarget in ipairs(action.target) do
                    for _, result in ipairs(actionTarget.result) do
                        if result.has_proc then
                            table.insert(procResults, result)
                        end
                    end
                end
            end
        end

        assert(#procResults > 0, 'no melee additional-effect action was serialized')
        applier:called(#procResults)
        for index, result in ipairs(procResults) do
            assert(result.proc_kind == xi.subEffect.WIND_DAMAGE)
            assert(result.proc_value == applier.calls[index].returned)
            assert(result.proc_message == xi.msg.basic.ADD_EFFECT_DMG)
        end
    end)

    it('applies absorption once and reports the actual healing', function()
        isolateMagicalDamage()

        local absorptionCalls = 0
        stub('xi.spells.damage.calculateAbsorption', function()
            absorptionCalls = absorptionCalls + 1
            return -1
        end)

        stub('xi.spells.damage.calculateNullification', 1)

        local item = findTestItem(siroccoKukri)
        target:setHP(target:getMaxHP() - 50)
        local startingHP = target:getHP()
        local _, messageId, amount = xi.additionalEffect.attack(player, target, 0, item)

        assert(absorptionCalls == 1, string.format('absorption evaluated %u times', absorptionCalls))
        assert(messageId == xi.msg.basic.ADD_EFFECT_HEAL, 'absorbed damage did not use the healing message')
        assert(target:getHP() - startingHP == amount, 'absorbed healing did not match the packet amount')
    end)

    it('evaluates magical nullification once', function()
        isolateMagicalDamage()
        stub('xi.spells.damage.calculateAbsorption', 1)

        local nullificationCalls = 0
        stub('xi.spells.damage.calculateNullification', function()
            nullificationCalls = nullificationCalls + 1
            return 1
        end)

        local item = findTestItem(siroccoKukri)
        xi.additionalEffect.attack(player, target, 0, item)

        assert(nullificationCalls == 1, string.format('nullification evaluated %u times', nullificationCalls))
    end)

    it('honors the breath nullification flag', function()
        target:setMod(xi.mod.NULL_BREATH_DAMAGE, 100)

        local damage = xi.additionalEffect.calcPhysDamage(player, target, nil, {
            damage   = 25,
            isBreath = true,
        })

        assert(damage == 0, string.format('breath additional damage was not nullified: %u', damage))
    end)

    it('resolves item-native A-rank profiles only for Acid and Sleep Bolts', function()
        local acidProfile  = xi.additionalEffect.profile.resolve(findTestItem(xi.item.ACID_BOLT), 0)
        local sleepProfile = xi.additionalEffect.profile.resolve(findTestItem(xi.item.SLEEP_BOLT), 0)
        local blindProfile = xi.additionalEffect.profile.resolve(findTestItem(xi.item.BLIND_BOLT), 0)

        for _, profile in ipairs({ acidProfile, sleepProfile }) do
            assert(profile.accuracy.mode == xi.additionalEffect.profile.accuracyMode.ITEM_NATIVE_RANK)
            assert(profile.accuracy.skillRank == xi.skillRank.A)
            assert(profile.accuracy.governingStat == xi.mod.INT)
            assert(profile.accuracy.governingStatEvidence == 'LEGACY_UNVERIFIED')
        end

        assert(
            acidProfile.outcome.statusEffect == xi.effect.DEFENSE_DOWN,
            string.format(
                'Acid Bolt status mod was %s',
                tostring(acidProfile.outcome.statusEffect)))
        assert(
            sleepProfile.outcome.statusEffect == xi.effect.SLEEP_I,
            string.format(
                'Sleep Bolt status mod was %s',
                tostring(sleepProfile.outcome.statusEffect)))
        assert(blindProfile.accuracy.mode == xi.additionalEffect.profile.accuracyMode.LEGACY_UNVERIFIED_RANK)
    end)

    it('isolates unsupported evidence families behind named VERIFY_LIVE compatibility profiles', function()
        for _, case in ipairs({
            { itemId = 16528, resource = 'HP',             selection = 'SINGLE' }, -- Bloody Rapier
            { itemId = 16509, resource = 'MP',             selection = 'SINGLE' }, -- Aspir Knife
            { itemId = 17823, resource = 'TP',             selection = 'SINGLE' }, -- Shinsoku
            {
                itemId   = xi.item.HOFUD,
                resource = 'HP_OR_MP',
                selection = 'UNIFORM_SINGLE_BRANCH_NO_RETRY_COMPATIBILITY',
            },
            {
                itemId   = xi.item.VAMPIRISM,
                resource = 'HP_OR_MP_OR_TP',
                selection = 'UNIFORM_SINGLE_BRANCH_NO_RETRY_COMPATIBILITY',
            },
            {
                itemId   = xi.item.CREPUSCULAR_KNIFE,
                resource = 'HP_OR_MP_OR_TP',
                selection = 'UNIFORM_SINGLE_BRANCH_NO_RETRY_COMPATIBILITY',
            },
            { itemId = 16944, resource = 'NONE',           selection = 'SINGLE' }, -- Lockheart: Dispel
            { itemId = 16504, resource = 'NONE',           selection = 'SINGLE' }, -- Oynos Knife: self buff
            { itemId = 18551, resource = 'NONE',           selection = 'SINGLE' }, -- Twilight Scythe: Death
        }) do
            local profile = xi.additionalEffect.profile.resolve(findTestItem(case.itemId), 0)
            assert(profile.classification == xi.additionalEffect.profile.classification.VERIFY_LIVE)
            assert(profile.outcome.drainResource == case.resource)
            assert(profile.outcome.selectionPolicy == case.selection)
        end
    end)

    it('rejects unsupported proc families explicitly', function()
        local item = findTestItem(xi.item.BRONZE_SWORD)
        item:addMod(xi.mod.ITEM_ADDEFFECT_TYPE, 99)
        item:addMod(xi.mod.ITEM_ADDEFFECT_CHANCE, 50)

        local valid, errors = xi.additionalEffect.profile.validate(
            xi.additionalEffect.profile.resolve(item, 0))

        assert(not valid)
        assert(#errors > 0)
        assert(string.find(errors[1], 'unsupported proc family', 1, true))
    end)

    it('separates a failed proc roll from status resistance', function()
        local resistance = spy('xi.combat.magicHitRate.calculateResistRate')
        stub('math.randomInt', 100)

        local item = findTestItem(xi.item.KABURA_ARROW)
        local subEffect, messageId, amount = xi.additionalEffect.attack(player, target, 0, item)

        resistance:called(0)
        assert(subEffect == 0 and messageId == 0 and amount == 0)
        assert(not target:hasStatusEffect(xi.effect.SILENCE))
    end)

    it('returns no presentation when a successful proc fully resists', function()
        allowStatusResolution(0.25)

        local item = findTestItem(xi.item.ACID_BOLT)
        local subEffect, messageId, amount = xi.additionalEffect.attack(player, target, 0, item)

        assert(subEffect == 0 and messageId == 0 and amount == 0)
        assert(not target:hasStatusEffect(xi.effect.DEFENSE_DOWN))
    end)

    it('applies Acid Bolt power and partial-resist duration through the profile', function()
        allowStatusResolution(0.5)

        local item = findTestItem(xi.item.ACID_BOLT)
        local subEffect, messageId, amount = xi.additionalEffect.attack(player, target, 0, item)
        local effect = target:getStatusEffect(xi.effect.DEFENSE_DOWN)

        assert(subEffect == xi.subEffect.DEFENSE_DOWN)
        assert(messageId == xi.msg.basic.ADD_EFFECT_STATUS_2)
        assert(amount == xi.effect.DEFENSE_DOWN)
        assert(effect, 'Acid Bolt did not apply Defense Down')
        assert(effect:getPower() == 12)
        assert(effect:getDuration() == 30 * 1000)
    end)

    it('applies Sleep Bolt duration through the profile', function()
        allowStatusResolution(1)

        local item = findTestItem(xi.item.SLEEP_BOLT)
        local subEffect, messageId, amount = xi.additionalEffect.attack(player, target, 0, item)
        local effect = target:getStatusEffect(xi.effect.SLEEP_I)

        assert(subEffect == xi.subEffect.SLEEP)
        assert(messageId == xi.msg.basic.ADD_EFFECT_STATUS_2)
        assert(amount == xi.effect.SLEEP_I)
        assert(effect, 'Sleep Bolt did not apply Sleep')
        assert(effect:getDuration() == 25 * 1000)
    end)

    for _, case in ipairs({
        {
            name     = 'Venom Bolt Poison',
            itemId   = xi.item.VENOM_BOLT,
            effectId = xi.effect.POISON,
            power    = 4,
            duration = 30,
            tick     = 3,
        },
        {
            name     = 'Blind Bolt Blindness',
            itemId   = xi.item.BLIND_BOLT,
            effectId = xi.effect.BLINDNESS,
            power    = 10,
            duration = 30,
            tick     = 0,
        },
    }) do
        it(string.format('preserves %s status parameters', case.name), function()
            allowStatusResolution(1)

            local item = findTestItem(case.itemId)
            xi.additionalEffect.attack(player, target, 0, item)
            local effect = target:getStatusEffect(case.effectId)

            assert(effect, string.format('%s was not applied', case.name))
            assert(effect:getPower() == case.power)
            assert(effect:getDuration() == case.duration * 1000)
            assert(effect:getTick() == case.tick * 1000)
        end)
    end

    for _, guard in ipairs({
        'xi.data.statusEffect.isTargetImmune',
        'xi.data.statusEffect.isTargetResistant',
        'xi.data.statusEffect.isEffectNullified',
    }) do
        it(string.format('honors the status guard %s', guard), function()
            allowStatusResolution(1, guard)

            local item = findTestItem(xi.item.ACID_BOLT)
            local subEffect, messageId, amount = xi.additionalEffect.attack(player, target, 0, item)

            assert(subEffect == 0 and messageId == 0 and amount == 0)
            assert(not target:hasStatusEffect(xi.effect.DEFENSE_DOWN))
        end)
    end

    it('removes an opposing boost only after successful status resolution', function()
        allowStatusResolution(1)
        target:addStatusEffect(xi.effect.DEFENSE_BOOST, { power = 25, duration = 60, origin = player })

        local item = findTestItem(xi.item.ACID_BOLT)
        xi.additionalEffect.attack(player, target, 0, item)

        assert(not target:hasStatusEffect(xi.effect.DEFENSE_BOOST))
        assert(target:hasStatusEffect(xi.effect.DEFENSE_DOWN))
    end)

    it('does not replace an existing status', function()
        stub('xi.data.statusEffect.isTargetImmune', false)
        stub('xi.data.statusEffect.isTargetResistant', false)
        stub('xi.combat.magicHitRate.calculateResistRate', 1)
        target:addStatusEffect(xi.effect.DEFENSE_DOWN, { power = 50, duration = 60, origin = player })
        local existing = target:getStatusEffect(xi.effect.DEFENSE_DOWN)

        local item = findTestItem(xi.item.ACID_BOLT)
        local subEffect, messageId, amount = xi.additionalEffect.attack(player, target, 0, item)

        assert(subEffect == 0 and messageId == 0 and amount == 0)
        assert(target:getStatusEffect(xi.effect.DEFENSE_DOWN) == existing)
    end)

    it('does not remove an opposing boost after authoritative status rejection', function()
        allowStatusResolution(1)
        target:addStatusEffect(xi.effect.ATTACK_BOOST, { power = 25, duration = 60, origin = player })
        stub('xi.additionalEffect.applyStatus', false)
        local remover = spy('xi.additionalEffect.removeOpposingStatus')

        local item = findTestItem(xi.item.DEMON_ARROW)
        local subEffect, messageId, amount = xi.additionalEffect.attack(player, target, 0, item)

        assert(subEffect == 0 and messageId == 0 and amount == 0)
        assert(target:hasStatusEffect(xi.effect.ATTACK_BOOST))
        remover:called(0)
    end)

    it('blocks an item above the effective level before profile resolution', function()
        player:setLevel(1)
        local resolver = spy('xi.additionalEffect.profile.resolve')

        local item = findTestItem(siroccoKukri)
        local subEffect, messageId, amount = xi.additionalEffect.attack(player, target, 0, item)

        resolver:called(0)
        assert(subEffect == 0 and messageId == 0 and amount == 0)
    end)

    it('level-corrects non-guaranteed proc rates independently', function()
        assert(xi.additionalEffect.levelCorrectRates(30, 20, 95, 5) == 45)
        assert(xi.additionalEffect.levelCorrectRates(30, 20, 100, 5) == 100)
    end)

    for _, case in ipairs({
        { name = 'all damage', mod = xi.mod.NULL_DAMAGE, params = {} },
        { name = 'physical damage', mod = xi.mod.NULL_PHYSICAL_DAMAGE, params = { isPhysical = true } },
        { name = 'ranged damage', mod = xi.mod.NULL_RANGED_DAMAGE, params = { isRanged = true } },
        { name = 'breath damage', mod = xi.mod.NULL_BREATH_DAMAGE, params = { isBreath = true } },
    }) do
        it(string.format('honors %s nullification for physical-profile damage', case.name), function()
            target:setMod(case.mod, 100)
            case.params.damage = 25

            assert(xi.additionalEffect.calcPhysDamage(player, target, nil, case.params) == 0)
        end)
    end

    it('honors physical and ranged absorption', function()
        target:setMod(xi.mod.PHYS_ABSORB, 100)

        assert(xi.additionalEffect.calcPhysDamage(player, target, nil, {
            damage     = 25,
            isPhysical = true,
        }) == -25)
        assert(xi.additionalEffect.calcPhysDamage(player, target, nil, {
            damage   = 25,
            isRanged = true,
        }) == -25)
    end)

    it('honors physical damage-type SDT', function()
        stub('xi.combat.damage.calculateDamageAdjustment', 1)
        target:setMod(xi.mod.PIERCE_SDT, -5000)

        local damage = xi.additionalEffect.calcPhysDamage(player, target, nil, {
            damage     = 40,
            isPhysical = true,
            damageType = xi.damageType.PIERCING,
        })

        assert(damage == 20, string.format('piercing SDT produced %u damage', damage))
    end)

    it('honors elemental and general magical nullification modifiers', function()
        isolateMagicalFormula()

        local item = findTestItem(siroccoKukri)
        for _, modifier in ipairs({ xi.mod.WIND_NULL, xi.mod.NULL_MAGICAL_DAMAGE }) do
            target:setMod(modifier, 100)
            local startingHP = target:getHP()
            local _, _, amount = xi.additionalEffect.attack(player, target, 0, item)
            assert(amount == 0)
            assert(target:getHP() == startingHP)
            target:setMod(modifier, 0)
        end
    end)

    it('honors elemental absorption and applies healing once', function()
        isolateMagicalFormula()
        target:setMod(xi.mod.WIND_ABSORB, 100)
        target:setHP(target:getMaxHP() - 50)

        local item       = findTestItem(siroccoKukri)
        local startingHP = target:getHP()
        local _, messageId, amount = xi.additionalEffect.attack(player, target, 0, item)

        assert(messageId == xi.msg.basic.ADD_EFFECT_HEAL)
        assert(amount == 9)
        assert(target:getHP() - startingHP == amount)
    end)
end)
