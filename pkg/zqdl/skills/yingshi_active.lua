local yingshi_active = fk.CreateSkill{
  name = "zq_heg__yingshis_active",
}

Fk:loadTranslationTable{
  ["zq_heg__yingshis_active"] = "鹰视",
}

yingshi_active:addEffect("active", {
  card_num = 0,
  target_num = 2,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected)
    local card = Fk:cloneCard("known_both")
    card.skillName = "zq_heg__yingshis"
    if #selected == 0 then
      return to_select:canUse(card)
    elseif #selected == 1 then
      return selected[1]:canUseTo(card, to_select)
    end
  end,
})

return yingshi_active
