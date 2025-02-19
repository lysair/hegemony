local H = require "packages/hegemony/util"
local halberdActive = fk.CreateSkill{
  name = "sa__halberd_active",
}
halberdActive:addEffect("active", {
  name = "#sa__halberd_targets",
  can_use = Util.FalseFunc,
  min_target_num = 1,
  card_num = 0,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected)
    local orig = table.simpleClone(player:getMark("_sa__halberd"))
    if table.contains(orig, to_select.id) or to_select == player then return false end
    local room = Fk:currentRoom()
    if to_select.kingdom == "unknown" or (table.every(orig, function(id)
      return not H.compareKingdomWith(to_select, room:getPlayerById(id))
    end) and table.every(selected, function(p)
      return not H.compareKingdomWith(to_select, p)
    end)) then
      local card = Fk:cloneCard("slash")
      return not player:isProhibited(to_select, card) and card.skill:modTargetFilter(player, to_select, table.map(orig, function(pid) return room:getPlayerById(pid) end), card)
    end
  end,
})

return halberdActive
