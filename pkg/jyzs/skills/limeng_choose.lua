local limeng_choose = fk.CreateSkill{
  name = "jy_heg__limeng_choos",
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
      --local compGenerals = {}
      for p, gs in pairs(generals) do
        for _, g in ipairs(gs) do
          for _p, _gs in pairs(generals) do
            for _, _g in ipairs(_gs) do
              if g:isCompanionWith(_g) then
                if p == to_select or _p == to_select then return true end
                --compGenerals[p] = compGenerals[p] or {}
                --table.insert(compGenerals[p], g)
              end
            end
          end
        end
      end
      --return false --compGenerals[to_select] ~= nil
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
  end,
  feasible = function (self, player, selected, selected_cards, card)
    if #selected_cards ~= 1 then return false end
    if #selected == 2 then return true
    elseif #selected == 1 then
      local tar = selected[1]
      return Fk.generals[tar.general]:isCompanionWith(Fk.generals[tar.deputyGeneral])
    end
    return false
  end
})

return limeng_choose