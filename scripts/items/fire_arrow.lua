-----------------------------------
-- ID: 17322
-- Item: Fire Arrow
-- Additional effect: Fire damage
-----------------------------------
---@type TItem
local itemObject = {}

itemObject.onItemAdditionalEffect = function(actor, target, baseAttackDamage, item)
    return xi.combat.action.executeScriptedDamageProfile(actor, target, item)
end

return itemObject
