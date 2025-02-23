yijiActive = fk.CreateSkill{
  name = "hs__yiji_active",
}
yijiActive:addEffect("active", {
  expand_pile = function(self, player)
    return player:getTableMark("hs__yiji_cards")
  end,
  min_card_num = 1,
  target_num = 1,
  card_filter = function(self, player, to_select, selected)
    return table.contains(player:getTableMark("hs__yiji_cards"), to_select)
  end,
  target_filter = function(self, player, to_select, selected, selected_cards)
    return #selected == 0 and to_select ~= player
  end,
})

return yijiActive
