local keshou_filter = fk.CreateSkill{
  name = "#ld__keshou_filter",
}
keshou_filter:addEffect("active", {
  card_num = 2,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 or table.every(selected, function(id)
      return Fk:getCardById(to_select).color == Fk:getCardById(id).color
    end)
  end,
  target_filter = Util.FalseFunc,
  can_use = Util.FalseFunc,
})

Fk:loadTranslationTable{
  ["#ld__keshou_filter"] = "",
}

return keshou_filter
