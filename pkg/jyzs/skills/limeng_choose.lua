local limeng_choose = fk.CreateSkill{
  name = "#jy_heg__limeng_choose&",
}

Fk:loadTranslationTable{
  ["#jy_heg__limeng_choose&"] = "离梦",

  ["jy_heg__limeng_tip_1"] = "确认则无事",
  ["jy_heg__limeng_tip_2"] = "造成伤害",
}

limeng_choose:addEffect("active", {
  can_use = Util.FalseFunc,
  card_num = 1,
  card_filter = function (self, player, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).type ~= Card.TypeBasic
  end,
  min_target_num = 1,
  max_target_num = 2,
  target_filter = function (self, player, to_select, selected, selected_cards)
    if #selected == 2 then return false end
    local room = Fk:currentRoom()
    local generals = {} ---@type table<Player, General[]>
    table.forEach(room.alive_players, function(p)
      generals[p] = {Fk.generals[p.general], Fk.generals[p.deputyGeneral]}
    end)
    if #selected == 0 then
      for p, gs in pairs(generals) do
        for _, g in ipairs(gs) do
          for _p, _gs in pairs(generals) do
            for _, _g in ipairs(_gs) do
              if g:isCompanionWith(_g) then
                if p == to_select or _p == to_select then return true end
              end
            end
          end
        end
      end
    else
      local tar = selected[1]
      local gs = generals[tar]
      for _, g in ipairs(gs) do
        for p, _gs in pairs(generals) do
          if tar ~= p then
            for _, _g in ipairs(_gs) do
              if g:isCompanionWith(_g) then
                if to_select == p then return true end
              end
            end
          end
        end
      end
    end
    return false
  end,
  feasible = function (self, player, selected, selected_cards, card)
    if #selected_cards ~= 1 then return false end
    if #selected == 2 then return true
    elseif #selected == 1 then
      local tar = selected[1]
      return Fk.generals[tar.general]:isCompanionWith(Fk.generals[tar.deputyGeneral])
    end
    return false
  end,
  target_tip = function (self, player, to_select, selected, selected_cards, card, selectable, extra_data)
    if not selectable then return end
    if #selected > 0 then
      if #selected == 1 and selected[1] == to_select and self:feasible(player, selected, selected_cards) then
        return "jy_heg__limeng_tip_1"
      else
        return "jy_heg__limeng_tip_2"
      end
    end
  end
})

return limeng_choose