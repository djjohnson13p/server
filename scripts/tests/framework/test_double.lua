describe('Test Doubles', function()
    ---@type CClientEntityPair
    local player

    before_each(function()
        player = xi.test.world:spawnPlayer()
    end)

    -- Stubs replace global functions with your own implementation
    -- They do not need to match params
    -- They can be instantiated in the following fashion
    describe('stub()', function()
        it('can replace global functions with a new implementation', function()
            player:setSkillLevel(xi.skill.BONECRAFT, 300)

            local s = stub('xi.crafting.getRealSkill', function()
                return 100
            end)

            assert(s)

            local level = xi.crafting.getRealSkill(player, xi.skill.BONECRAFT)
            assert(level == 100, string.format('Expected stubbed level of 100 but got %s', tostring(level)))
        end)

        it('does not leak across tests', function()
            player:setSkillLevel(xi.skill.BONECRAFT, 300)

            local level = xi.crafting.getRealSkill(player, xi.skill.BONECRAFT)
            assert(level == 30, 'Expected level of 30')
        end)

        it('can replace global functions with a direct result', function()
            player:setSkillLevel(xi.skill.BONECRAFT, 300)

            local s = stub('xi.crafting.getRealSkill', 100)
            assert(s)

            local level = xi.crafting.getRealSkill(player, xi.skill.BONECRAFT)
            assert(level == 100, string.format('Expected stubbed level of 100 but got %s', tostring(level)))
        end)

        it('can execute side-effects', function()
            player:setSkillLevel(xi.skill.BONECRAFT, 300)

            local s = stub('xi.crafting.getRealSkill')
            s:sideEffect(function()
                player:changeJob(xi.job.DRK)
            end)

            local level = xi.crafting.getRealSkill(player, xi.skill.BONECRAFT)
            assert(level == 30, string.format('Expected original level of 30 but got %s', tostring(level)))
            assert(player:getMainJob() == xi.job.DRK, 'Expected job to be DRK')
        end)

        it('can stack replacements on the same function', function()
            player:setSkillLevel(xi.skill.BONECRAFT, 300)
            stub('xi.crafting.getRealSkill', 100)
            stub('xi.crafting.getRealSkill', 200)

            assert(xi.crafting.getRealSkill(player, xi.skill.BONECRAFT) == 200)
        end)

        it('restores the original after stacked replacements', function()
            player:setSkillLevel(xi.skill.BONECRAFT, 300)

            assert(xi.crafting.getRealSkill(player, xi.skill.BONECRAFT) == 30)
        end)
    end)

    describe('spy()', function()
        it('can spy on global functions', function()
            player:setSkillLevel(xi.skill.BONECRAFT, 300)

            local s = spy('xi.crafting.getRealSkill')
            xi.crafting.getRealSkill(player, xi.skill.SMITHING)
            xi.crafting.getRealSkill(player, xi.skill.BONECRAFT)

            -- Assert spy was called twice!
            s:called(2)

            -- calledWith will match calls in any order
            s:calledWith(player, xi.skill.SMITHING)
            s:calledWith(player, xi.skill.BONECRAFT)

            -- Can inspect results
            assert(s.calls[1].returned == 0, 'Expected level 0')
            assert(s.calls[2].returned == 30, 'Expected level 30 for 300 skill')
        end)

        it('can wrap a replacement on the same function', function()
            player:setSkillLevel(xi.skill.BONECRAFT, 300)
            stub('xi.crafting.getRealSkill', 100)
            local s = spy('xi.crafting.getRealSkill')

            assert(xi.crafting.getRealSkill(player, xi.skill.BONECRAFT) == 100)
            s:called(1)
        end)

        it('restores the original after a wrapped replacement', function()
            player:setSkillLevel(xi.skill.BONECRAFT, 300)

            assert(xi.crafting.getRealSkill(player, xi.skill.BONECRAFT) == 30)
        end)
    end)
end)
