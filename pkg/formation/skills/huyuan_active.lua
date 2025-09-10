local huyuanActive = fk.CreateSkill{
  name = "#ld__huyuan_active",
}
huyuanActive:addEffect("active", {
  mute = true,
  card_num = 1,
  target_num = 1,
  interaction = function()
    return UI.ComboBox {choices = {"ld__huyuan_give", "ld__huyuan_equip"} }
  end,
  card_filter = function(self, player, to_select, selected)
    if #selected == 0 then
      if self.interaction.data == "ld__huyuan_give" then
        return Fk:currentRoom():getCardArea(to_select) == Card.PlayerHand
      elseif self.interaction.data == "ld__huyuan_equip" then
        return Fk:getCardById(to_select).type == Card.TypeEquip
      end
    end
  end,
  target_filter = function(self, player, to_select, selected, selected_cards)
    if #selected == 0 and #selected_cards == 1 then
      if self.interaction.data == "ld__huyuan_give" then
        return to_select ~= player
      elseif self.interaction.data == "ld__huyuan_equip" then
        return to_select:hasEmptyEquipSlot(Fk:getCardById(selected_cards[1]).sub_type)
      end
    end
  end,
})

Fk:loadTranslationTable{
  ["#ld__huyuan_active"] = "护援",
  ["ld__huyuan_give"] = "给出手牌",
  ["ld__huyuan_equip"] = "置入装备",
}

return huyuanActive
