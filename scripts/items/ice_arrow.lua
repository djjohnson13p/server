-----------------------------------
-- ID: 17323
-- Item: Ice Arrow
-- Additional effect: Ice damage
-----------------------------------
---@type TItem
local itemObject = {}

itemObject.onItemAdditionalEffect = function(actor, target, baseAttackDamage, item)
    return xi.combat.action.executeScriptedDamageProfile(actor, target, item)
end

return itemObject
