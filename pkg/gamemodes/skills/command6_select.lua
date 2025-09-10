-- 军令六
local command6_select = fk.CreateSkill{
  name = "#command6_select",
}
command6_select:addEffect("active", {
  can_use = Util.FalseFunc,
  target_num = 0,
  card_num = function(self, player)
    local x = 0
    if #player.player_cards[Player.Hand] > 0 then x = x + 1 end
    if #player.player_cards[Player.Equip] > 0 then x = x + 1 end
    return x
  end,
  card_filter = function(self, player, to_select, selected)
    if #selected == 1 then
      return (Fk:currentRoom():getCardArea(to_select) == Card.PlayerEquip) ~=
      (Fk:currentRoom():getCardArea(selected[1]) == Card.PlayerEquip)
    end
    return #selected == 0
  end,
})
Fk:loadTranslationTable{
  ["#command6_select"] = "军令",
}

return command6_select
