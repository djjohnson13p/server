describe('NM-specific item additional effects', function()
    local function isolateMagicalDamage()
        stub('addBonusesAbility', function(_, _, _, damage)
            return damage
        end)

        stub('applyResistanceAddEffect', 1)
        stub('xi.spells.damage.calculateAbsorption', 1)
        stub('xi.spells.damage.calculateNullification', 1)
        stub('xi.combat.damage.calculateDamageAdjustment', 1)
    end

    local function spawnPair(zoneId, targetName)
        local player = xi.test.world:spawnPlayer(
            {
                zone  = zoneId,
                job   = xi.job.WAR,
                level = 99,
            })
        local target = player.entities:get(targetName)
        assert(target, string.format('test target %s was not found', targetName))
        target:respawn()
        target:setUnkillable(true)
        target:setHP(target:getMaxHP())

        return player, target
    end

    local function addItem(player, itemId)
        player:addItem(itemId)
        local item = player:findItem(itemId)
        assert(item, string.format('test item %u was not created', itemId))

        return item
    end

    before_each(function()
        xi.test.world:setSeed(1)
        isolateMagicalDamage()
    end)

    for _, case in ipairs({
        {
            name   = 'Seiryu',
            zone   = xi.zone.RUAUN_GARDENS,
            itemId = xi.item.ZEPHYR,
        },
        {
            name   = 'Genbu',
            zone   = xi.zone.RUAUN_GARDENS,
            itemId = xi.item.ANTARCTIC_WIND,
        },
        {
            name   = 'Suzaku',
            zone   = xi.zone.RUAUN_GARDENS,
            itemId = xi.item.ARCTIC_WIND,
        },
        {
            name   = 'Byakko',
            zone   = xi.zone.RUAUN_GARDENS,
            itemId = xi.item.EAST_WIND,
        },
    }) do
        it(string.format('preserves the %s ammunition interaction', case.name), function()
            local player, target = spawnPair(case.zone, case.name)
            target:setMobMod(xi.mobMod.ADD_EFFECT, 1)
            local item = addItem(player, case.itemId)
            local startingHP = target:getHP()

            local subEffect, messageId, amount = xi.additionalEffect.attack(player, target, 0, item)

            assert(subEffect ~= 0 and messageId == xi.msg.basic.ADD_EFFECT_DMG)
            assert(amount == startingHP - target:getHP())
            assert(target:getMobMod(xi.mobMod.ADD_EFFECT) == 0)
        end)
    end

    it('preserves the Brigandish Blade Buccaneers Knife interaction', function()
        local player, target = spawnPair(xi.zone.VELUGANNON_PALACE, 'Brigandish_Blade')
        target:setMod(xi.mod.UDMGPHYS, -10000)
        target:setMod(xi.mod.UDMGRANGE, -10000)
        target:setMod(xi.mod.UDMGMAGIC, -10000)
        target:setMod(xi.mod.UDMGBREATH, -10000)
        local item = addItem(player, xi.item.BUCCANEERS_KNIFE)

        local _, messageId = xi.additionalEffect.attack(player, target, 0, item)

        assert(messageId == xi.msg.basic.ADD_EFFECT_DMG)
        assert(target:getMod(xi.mod.UDMGPHYS) == 0)
        assert(target:getMod(xi.mod.UDMGRANGE) == 0)
        assert(target:getMod(xi.mod.UDMGMAGIC) == 0)
        assert(target:getMod(xi.mod.UDMGBREATH) == 0)
        assert(target:getLocalVar('killable') == 1)
    end)

    it('does not trigger an NM action with the wrong configured item', function()
        local player, target = spawnPair(xi.zone.RUAUN_GARDENS, 'Seiryu')
        target:setMobMod(xi.mobMod.ADD_EFFECT, 1)
        local item = addItem(player, xi.item.EAST_WIND)
        local startingHP = target:getHP()

        local subEffect, messageId, amount = xi.additionalEffect.attack(player, target, 0, item)

        assert(subEffect == 0 and messageId == 0 and amount == 0)
        assert(target:getHP() == startingHP)
        assert(target:getMobMod(xi.mobMod.ADD_EFFECT) == 1)
    end)

    it('does not trigger an NM action against an unrelated target', function()
        local player, target = spawnPair(xi.zone.WEST_RONFAURE, 'Wild_Rabbit')
        local item = addItem(player, xi.item.ZEPHYR)
        local startingHP = target:getHP()

        local subEffect, messageId, amount = xi.additionalEffect.attack(player, target, 0, item)

        assert(subEffect == 0 and messageId == 0 and amount == 0)
        assert(target:getHP() == startingHP)
        assert(target:getLocalVar('aeFromItemId') == xi.item.ZEPHYR)
    end)
end)
