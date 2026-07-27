-----------------------------------
-- ID: 17324
-- Item: Lightning Arrow
-- Additional effect: Lightning damage
-----------------------------------
---@type TItem
local itemObject = {}

itemObject.onItemAdditionalEffect = function(actor, target, baseAttackDamage, item)
    return xi.combat.action.executeScriptedDamageProfile(actor, target, item)
end

return itemObject
