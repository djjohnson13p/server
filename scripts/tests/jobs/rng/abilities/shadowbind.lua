describe('Shadowbind', function()
    local player
    local mob

    local statusGuards =
    {
        'xi.data.statusEffect.isTargetImmune',
        'xi.data.statusEffect.isTargetResistant',
        'xi.data.statusEffect.isEffectNullified',
    }

    local function equipRangedWeapon(targetPlayer, arrowCount)
        targetPlayer:addItem(xi.item.POWER_BOW)
        targetPlayer:addItem({ id = xi.item.WOODEN_ARROW, quantity = arrowCount })
        targetPlayer:equipItem(xi.item.POWER_BOW, nil, xi.slot.RANGED)
        targetPlayer:equipItem(xi.item.WOODEN_ARROW, nil, xi.slot.AMMO)
    end

    local function controlBindRoll(roll, blockedGuard)
        for _, guard in ipairs(statusGuards) do
            stub(guard, guard == blockedGuard)
        end

        stub('math.randomInt', function(minimum)
            if minimum == 0 then
                return roll
            end

            return 100
        end)
    end

    local function useShadowbind(targetPlayer)
        targetPlayer.packets:clear()
        targetPlayer.actions:useAbility(mob, xi.jobAbility.SHADOWBIND)
        xi.test.world:tickEntity(targetPlayer)
    end

    local function getShadowbindMessage(targetPlayer)
        for _, action in pairs(targetPlayer.packets:actionPackets()) do
            if action.cmd_arg == xi.jobAbility.SHADOWBIND then
                return action.target[1].result[1].message
            end
        end

        return nil
    end

    before_each(function()
        player = xi.test.world:spawnPlayer(
            {
                zone  = xi.zone.WEST_RONFAURE,
                job   = xi.job.RNG,
                level = 40,
            })

        mob = player.entities:moveTo('Wild_Rabbit')
        mob:despawn()
        mob:respawn()
        mob:delStatusEffect(xi.effect.BIND)
        mob:setMod(xi.mod.BIND_MEVA, 0)
        equipRangedWeapon(player, 10)
    end)

    it('binds on a successful resistance roll and consumes one arrow', function()
        controlBindRoll(99)
        stub('xi.combat.ranged.shouldUseAmmo', true)

        useShadowbind(player)

        assert(mob:hasStatusEffect(xi.effect.BIND), 'successful Shadowbind did not apply Bind')
        assert(getShadowbindMessage(player) == xi.msg.basic.IS_EFFECT, 'successful Shadowbind used the wrong message')
        assert(player:getItemCount(xi.item.WOODEN_ARROW) == 9, 'successful Shadowbind did not consume one arrow')
    end)

    it('fails below Bind magic evasion and still consumes one arrow', function()
        mob:setMod(xi.mod.BIND_MEVA, 50)
        controlBindRoll(49)
        stub('xi.combat.ranged.shouldUseAmmo', true)

        useShadowbind(player)

        assert(not mob:hasStatusEffect(xi.effect.BIND), 'failed Shadowbind applied Bind')
        assert(getShadowbindMessage(player) == xi.msg.basic.JA_MISS, 'failed Shadowbind used the wrong message')
        assert(player:getItemCount(xi.item.WOODEN_ARROW) == 9, 'failed Shadowbind did not consume one arrow')
    end)

    for _, guard in ipairs(statusGuards) do
        it(string.format('honors %s', guard), function()
            controlBindRoll(99, guard)
            stub('xi.combat.ranged.shouldUseAmmo', true)

            useShadowbind(player)

            assert(not mob:hasStatusEffect(xi.effect.BIND), string.format('%s did not block Bind', guard))
            assert(getShadowbindMessage(player) == xi.msg.basic.JA_MISS, string.format('%s used the wrong message', guard))
            assert(player:getItemCount(xi.item.WOODEN_ARROW) == 9, string.format('%s path did not consume one arrow', guard))
        end)
    end

    it('does not replace an existing Bind effect', function()
        mob:addStatusEffect(xi.effect.BIND, { duration = 60, origin = player })
        local existingEffect = mob:getStatusEffect(xi.effect.BIND)
        controlBindRoll(99)
        stub('xi.combat.ranged.shouldUseAmmo', true)

        useShadowbind(player)

        assert(mob:getStatusEffect(xi.effect.BIND) == existingEffect, 'existing Bind effect was replaced')
        assert(getShadowbindMessage(player) == xi.msg.basic.JA_MISS, 'existing Bind guard used the wrong message')
        assert(player:getItemCount(xi.item.WOODEN_ARROW) == 9, 'existing Bind guard did not consume one arrow')
    end)

    it('honors Unlimited Shot ammo preservation through the ranged subsystem', function()
        controlBindRoll(99)
        player:addStatusEffect(xi.effect.UNLIMITED_SHOT, { duration = 60, origin = player })

        useShadowbind(player)

        assert(mob:hasStatusEffect(xi.effect.BIND), 'Unlimited Shot path did not apply Bind')
        assert(player:getItemCount(xi.item.WOODEN_ARROW) == 10, 'Unlimited Shot did not preserve the arrow')
        assert(not player:hasStatusEffect(xi.effect.UNLIMITED_SHOT), 'Unlimited Shot was not consumed')
    end)

    it('is unavailable below Ranger level 40', function()
        local lowLevelPlayer = xi.test.world:spawnPlayer(
            {
                zone  = xi.zone.WEST_RONFAURE,
                job   = xi.job.RNG,
                level = 39,
            })
        equipRangedWeapon(lowLevelPlayer, 10)
        controlBindRoll(99)
        stub('xi.combat.ranged.shouldUseAmmo', true)

        useShadowbind(lowLevelPlayer)

        assert(not mob:hasStatusEffect(xi.effect.BIND), 'level 39 Ranger used Shadowbind')
        assert(lowLevelPlayer:getItemCount(xi.item.WOODEN_ARROW) == 10, 'unavailable ability consumed ammo')
    end)

    it('is available from a level 40 Ranger subjob', function()
        local subjobPlayer = xi.test.world:spawnPlayer(
            {
                zone   = xi.zone.WEST_RONFAURE,
                job    = xi.job.WAR,
                level  = 80,
                sjob   = xi.job.RNG,
                slevel = 40,
            })
        equipRangedWeapon(subjobPlayer, 10)
        subjobPlayer.entities:moveTo(mob)
        controlBindRoll(99)
        stub('xi.combat.ranged.shouldUseAmmo', true)

        useShadowbind(subjobPlayer)

        assert(subjobPlayer:getSubJob() == xi.job.RNG, 'test precondition: Ranger subjob was not configured')
        assert(mob:hasStatusEffect(xi.effect.BIND), 'level 40 Ranger subjob could not use Shadowbind')
        assert(subjobPlayer:getItemCount(xi.item.WOODEN_ARROW) == 9, 'subjob Shadowbind did not consume one arrow')
    end)
end)
