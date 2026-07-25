describe('Temple of Uggalepih granite doors', function()
    local player
    local uggalepihDoor
    local prelateDoor

    local function readU32(data, offset)
        return data[offset] +
            data[offset + 1] * 256 +
            data[offset + 2] * 65536 +
            data[offset + 3] * 16777216
    end

    local function findTalkNumWork()
        for _, packet in pairs(player.packets:getIncoming()) do
            if packet.type == 0x02A then
                return packet
            end
        end

        return nil
    end

    before_each(function()
        player = xi.test.world:spawnPlayer({ zone = xi.zone.TEMPLE_OF_UGGALEPIH })

        uggalepihDoor = player.entities:get('_mf9')
        prelateDoor   = player.entities:get('_mf8')
        uggalepihDoor:setAnimation(xi.animation.CLOSE_DOOR)
        prelateDoor:setAnimation(xi.animation.CLOSE_DOOR)
    end)

    it('opens _mf9 with exactly one Uggalepih Key and consumes it', function()
        player:addItem(xi.item.UGGALEPIH_KEY)
        player.packets:clear()
        player.actions:tradeNpc(uggalepihDoor, { xi.item.UGGALEPIH_KEY })

        assert(player:getItemCount(xi.item.UGGALEPIH_KEY) == 0, 'Uggalepih Key was not consumed')
        assert(uggalepihDoor:getAnimation() == xi.animation.OPEN_DOOR, '_mf9 did not open')

        local message = findTalkNumWork()
        assert(message, 'missing key-break message')
        assert(readU32(message.data, 8) == 0, 'key-break message param0 should be zero')
        assert(readU32(message.data, 12) == xi.item.UGGALEPIH_KEY, 'key-break message named the wrong key')
    end)

    it('rejects a wrong or non-exact trade at _mf9 without consuming items', function()
        player:addItem(xi.item.PRELATE_KEY)
        player.actions:tradeNpc(uggalepihDoor, { xi.item.PRELATE_KEY })

        assert(player:getItemCount(xi.item.PRELATE_KEY) == 1, 'wrong key was consumed')
        assert(uggalepihDoor:getAnimation() == xi.animation.CLOSE_DOOR, 'wrong key opened _mf9')

        player:addItem(xi.item.UGGALEPIH_KEY)
        player:addItem(xi.item.FIRE_CRYSTAL)
        player.actions:tradeNpc(uggalepihDoor, { xi.item.UGGALEPIH_KEY, xi.item.FIRE_CRYSTAL })

        assert(player:getItemCount(xi.item.UGGALEPIH_KEY) == 1, 'non-exact trade consumed the Uggalepih Key')
        assert(player:getItemCount(xi.item.FIRE_CRYSTAL) == 1, 'non-exact trade consumed the extra item')
        assert(uggalepihDoor:getAnimation() == xi.animation.CLOSE_DOOR, 'non-exact trade opened _mf9')
    end)

    it('reports the Uggalepih Key on the locked side of _mf9', function()
        player:setPos(-60, -8, -99)
        player.packets:clear()
        player.actions:trigger(uggalepihDoor)

        assert(uggalepihDoor:getAnimation() == xi.animation.CLOSE_DOOR, 'locked-side trigger opened _mf9')

        local message = findTalkNumWork()
        assert(message, 'missing locked-door message')
        assert(readU32(message.data, 8) == xi.item.UGGALEPIH_KEY, 'locked message named the wrong key')
    end)

    it('keeps _mf8 on the Prelate Key behavior', function()
        player:addItem(xi.item.PRELATE_KEY)
        player.packets:clear()
        player.actions:tradeNpc(prelateDoor, { xi.item.PRELATE_KEY })

        assert(player:getItemCount(xi.item.PRELATE_KEY) == 0, 'Prelate Key was not consumed')
        assert(prelateDoor:getAnimation() == xi.animation.OPEN_DOOR, '_mf8 did not open')

        local breakMessage = findTalkNumWork()
        assert(breakMessage, 'missing Prelate Key break message')
        assert(readU32(breakMessage.data, 12) == xi.item.PRELATE_KEY, 'break message named the wrong key')

        prelateDoor:setAnimation(xi.animation.CLOSE_DOOR)
        player:setPos(-11, -8, -99)
        player.packets:clear()
        player.actions:trigger(prelateDoor)

        local lockedMessage = findTalkNumWork()
        assert(lockedMessage, 'missing _mf8 locked-door message')
        assert(readU32(lockedMessage.data, 8) == xi.item.PRELATE_KEY, '_mf8 locked message named the wrong key')
    end)

    it('opens each door when triggered from its unlocked side', function()
        player:setPos(-63, -8, -99)
        player.actions:trigger(uggalepihDoor)
        assert(uggalepihDoor:getAnimation() == xi.animation.OPEN_DOOR, '_mf9 did not open from its unlocked side')

        player:setPos(-7, -8, -99)
        player.actions:trigger(prelateDoor)
        assert(prelateDoor:getAnimation() == xi.animation.OPEN_DOOR, '_mf8 did not open from its unlocked side')
    end)
end)
