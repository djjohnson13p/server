describe('Ranged item additional effects', function()
    local player
    local target

    local function equipBolt(itemId, quantity)
        player:addItem(xi.item.LIGHT_CROSSBOW)
        player:addItem({ id = itemId, quantity = quantity })
        player:equipItem(xi.item.LIGHT_CROSSBOW, nil, xi.slot.RANGED)
        player:equipItem(itemId, nil, xi.slot.AMMO)
    end

    local function allowStatusResolution()
        stub('xi.data.statusEffect.isTargetImmune', false)
        stub('xi.data.statusEffect.isTargetResistant', false)
        stub('xi.data.statusEffect.isEffectNullified', false)
        stub('xi.combat.magicHitRate.calculateResistRate', 1)
        stub('math.randomInt', 1)
    end

    local function performRangedAttack()
        player.packets:clear()
        player.actions:engage(target)
        player.actions:rangedAttack(target)
        xi.test.world:advanceTime(10)
        xi.test.world:setSeed(1)
        xi.test.world:tickEntity(player)
        xi.test.world:processClientUpdates()
    end

    local function findRangedFinish()
        for _, action in pairs(player.packets:actionPackets()) do
            if action.cmd_no == xi.action.category.RANGED_FINISH then
                return action.target[1].result[1]
            end
        end

        return nil
    end

    before_each(function()
        xi.test.world:setSeed(1)

        player = xi.test.world:spawnPlayer(
            {
                zone  = xi.zone.WEST_RONFAURE,
                job   = xi.job.RNG,
                level = 99,
            })
        player:setMod(xi.mod.RACC, 1000)
        player:setMod(xi.mod.RECYCLE, 0)

        target = player.entities:moveTo('Wild_Rabbit')
        target:despawn()
        target:respawn()
        target:setUnkillable(true)
    end)

    it('applies Acid Bolt through the real ranged state and packet path', function()
        allowStatusResolution()
        local distance = spy('xi.combat.ranged.attackDistancePenalty')
        local resolver = spy('xi.additionalEffect.profile.resolve')
        equipBolt(xi.item.ACID_BOLT, 3)

        performRangedAttack()

        local result = findRangedFinish()
        local effect = target:getStatusEffect(xi.effect.DEFENSE_DOWN)
        assert(result, 'ranged finish packet was not emitted')
        assert(result.has_proc, 'Acid Bolt packet did not contain an additional effect')
        assert(result.proc_kind == xi.subEffect.DEFENSE_DOWN)
        assert(result.proc_value == xi.effect.DEFENSE_DOWN)
        assert(result.proc_message == xi.msg.basic.ADD_EFFECT_STATUS_2)
        assert(effect and effect:getPower() == 12 and effect:getDuration() == 60 * 1000)
        assert(
            player:getItemCount(xi.item.ACID_BOLT) == 2,
            string.format(
                'Acid Bolt count was %u',
                player:getItemCount(xi.item.ACID_BOLT)))
        distance:called()
        resolver:called(1)
        assert(resolver.calls[1].returned.itemId == xi.item.ACID_BOLT)
    end)

    it('applies Sleep Bolt through the real ranged state and packet path', function()
        allowStatusResolution()
        equipBolt(xi.item.SLEEP_BOLT, 3)

        performRangedAttack()

        local result = findRangedFinish()
        local effect = target:getStatusEffect(xi.effect.SLEEP_I)
        assert(result, 'ranged finish packet was not emitted')
        assert(result.has_proc, 'Sleep Bolt packet did not contain an additional effect')
        assert(result.proc_kind == xi.subEffect.SLEEP)
        assert(result.proc_value == xi.effect.SLEEP_I)
        assert(result.proc_message == xi.msg.basic.ADD_EFFECT_STATUS_2)
        assert(effect, 'Sleep Bolt status was not retained after the ranged action')
        assert(
            effect:getDuration() == 25 * 1000,
            string.format('Sleep Bolt duration was %u', effect:getDuration()))
        assert(
            player:getItemCount(xi.item.SLEEP_BOLT) == 2,
            string.format(
                'Sleep Bolt count was %u',
                player:getItemCount(xi.item.SLEEP_BOLT)))
    end)

    it('does not let latent-derived modifiers bypass item level eligibility', function()
        player:setLevel(1)
        player:addItem(xi.item.SHIVAS_CLAWS)
        local item = player:findItem(xi.item.SHIVAS_CLAWS)
        local resolver = spy('xi.additionalEffect.profile.resolve')

        local subEffect, messageId, amount = xi.additionalEffect.attack(player, target, 0, item)

        resolver:called(0)
        assert(subEffect == 0 and messageId == 0 and amount == 0)
    end)
end)
