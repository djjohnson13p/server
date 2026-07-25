describe('Call for Help', function()
    local player
    local callForHelpMessage       = 19
    local cannotCallForHelpMessage = 22

    local function getMob(name)
        local mob = player.entities:get(name)
        mob:despawn()
        mob:respawn()
        mob:setCallForHelpFlag(false)
        mob:setCallForHelpBlocked(false)
        mob:setBattleID(0)

        return mob
    end

    local function getBattleMessageCount(messageId)
        local count = 0

        for _, packet in pairs(player.packets:getIncoming()) do
            if packet.type == 0x029 then
                local receivedMessageId = packet.data[24] + packet.data[25] * 256
                if receivedMessageId == messageId then
                    count = count + 1
                end
            end
        end

        return count
    end

    local function callForHelp()
        player.packets:clear()
        player.actions:callForHelp()
    end

    before_each(function()
        player = xi.test.world:spawnPlayer(
            {
                zone  = xi.zone.WEST_RONFAURE,
                job   = xi.job.WAR,
                level = 75,
            })
    end)

    it('marks an eligible claimed enemy without requiring an active target', function()
        local mob = getMob('Wild_Rabbit')
        mob:updateClaim(player)

        assert(not player:isEngaged(), 'test precondition: player should not be engaged')
        callForHelp()

        assert(mob:getCallForHelpFlag(), 'eligible claimed enemy was not marked for help')
        assert(not player:hasClaim(mob), 'Call for Help should clear the mob claim')
        assert(getBattleMessageCount(callForHelpMessage) == 1, 'expected one Call for Help message')
        assert(getBattleMessageCount(cannotCallForHelpMessage) == 0, 'unexpected failure message')
    end)

    it('marks every eligible enemy and emits one success message', function()
        local partyMember = xi.test.world:spawnPlayer({ zone = xi.zone.WEST_RONFAURE, level = 75 })
        player.actions:inviteToParty(partyMember)
        partyMember.actions:acceptPartyInvite()

        local rabbit = getMob('Wild_Rabbit')
        local sheep  = getMob('Wild_Sheep')
        rabbit:updateClaim(player)
        sheep:addEnmity(player, 1, 1)
        sheep:updateClaim(partyMember)

        callForHelp()

        assert(rabbit:getCallForHelpFlag(), 'first eligible enemy was not marked')
        assert(sheep:getCallForHelpFlag(), 'second eligible enemy was not marked')
        assert(getBattleMessageCount(callForHelpMessage) == 1, 'expected exactly one success message')
    end)

    it('rejects unclaimed enemies even when personal enmity remains', function()
        local mob = getMob('Wild_Rabbit')
        mob:updateClaim(player)
        mob:updateClaim(nil)

        assert(mob:getCE(player) > 0 or mob:getVE(player) > 0, 'test precondition: personal enmity should remain')
        callForHelp()

        assert(not mob:getCallForHelpFlag(), 'unclaimed enemy was incorrectly marked')
        assert(getBattleMessageCount(cannotCallForHelpMessage) == 1, 'expected one failure message')
    end)

    it('rejects party claim without the requesters personal enmity', function()
        local partyMember = xi.test.world:spawnPlayer({ zone = xi.zone.WEST_RONFAURE, level = 75 })
        player.actions:inviteToParty(partyMember)
        partyMember.actions:acceptPartyInvite()

        local mob = getMob('Wild_Rabbit')
        mob:updateClaim(partyMember)
        assert(player:hasClaim(mob), 'test precondition: party claim should be shared')
        assert(mob:getCE(player) == 0 and mob:getVE(player) == 0, 'test precondition: requester should have no personal enmity')

        callForHelp()
        assert(not mob:getCallForHelpFlag(), 'party-only enmity was incorrectly accepted')
    end)

    it('accepts personal enmity on a party claim', function()
        local partyMember = xi.test.world:spawnPlayer({ zone = xi.zone.WEST_RONFAURE, level = 75 })
        player.actions:inviteToParty(partyMember)
        partyMember.actions:acceptPartyInvite()

        local mob = getMob('Wild_Rabbit')
        mob:addEnmity(player, 1, 1)
        mob:updateClaim(partyMember)

        assert(player:hasClaim(mob), 'test precondition: party claim should be shared')
        assert(mob:getCE(player) > 0 or mob:getVE(player) > 0, 'test precondition: requester should have personal enmity')

        callForHelp()
        assert(mob:getCallForHelpFlag(), 'personal enmity on a party claim should be eligible')
    end)

    it('does not treat pet-only enmity as the masters personal enmity', function()
        player:changeJob(xi.job.SMN)
        player:setLevel(75)
        player:spawnPet(xi.petId.CARBUNCLE)
        local pet = player:getPet()
        assert(pet, 'test precondition: Carbuncle was not summoned')

        local mob = getMob('Wild_Rabbit')
        mob:updateClaim(pet)
        assert(player:hasClaim(mob), 'test precondition: pet claim should belong to master')
        assert(mob:getCE(player) == 0 and mob:getVE(player) == 0, 'test precondition: master should have zero personal enmity')

        callForHelp()
        assert(not mob:getCallForHelpFlag(), 'pet-only enmity was incorrectly accepted')
    end)

    it('accepts master personal enmity on a pet claim', function()
        player:changeJob(xi.job.SMN)
        player:setLevel(75)
        player:spawnPet(xi.petId.CARBUNCLE)
        local pet = player:getPet()
        assert(pet, 'test precondition: Carbuncle was not summoned')

        local mob = getMob('Wild_Rabbit')
        mob:addEnmity(player, 1, 1)
        mob:updateClaim(pet)

        assert(player:hasClaim(mob), 'test precondition: pet claim should belong to master')
        assert(mob:getCE(player) > 0 or mob:getVE(player) > 0, 'test precondition: master should have personal enmity')

        callForHelp()
        assert(mob:getCallForHelpFlag(), 'master personal enmity should make pet claim eligible')
    end)

    it('ignores already flagged and explicitly blocked enemies', function()
        local flagged = getMob('Wild_Rabbit')
        local blocked = getMob('Wild_Sheep')
        flagged:updateClaim(player)
        blocked:addEnmity(player, 1, 1)
        blocked:updateClaim(player)
        flagged:setCallForHelpFlag(true)
        blocked:setCallForHelpBlocked(true)

        callForHelp()

        assert(flagged:getCallForHelpFlag(), 'already flagged enemy should remain flagged')
        assert(not blocked:getCallForHelpFlag(), 'blocked enemy was incorrectly marked')
        assert(getBattleMessageCount(cannotCallForHelpMessage) == 1, 'expected one failure message')
    end)

    it('honors battle and confrontation boundaries', function()
        local battleMob = getMob('Wild_Rabbit')
        battleMob:updateClaim(player)
        battleMob:setBattleID(1)

        callForHelp()
        assert(not battleMob:getCallForHelpFlag(), 'different battle ID was incorrectly accepted')

        battleMob:setBattleID(0)
        player:addStatusEffect(xi.effect.CONFRONTATION, { power = 1, duration = 60, origin = player })
        callForHelp()
        assert(not battleMob:getCallForHelpFlag(), 'different confrontation was incorrectly accepted')
    end)

end)
