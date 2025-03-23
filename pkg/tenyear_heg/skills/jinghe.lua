local jinghe = fk.CreateActiveSkill{
  name = "ty_heg__jinghe",
  anim_type = "support",
  min_card_num = 1,
  min_target_num = 1,
  prompt = "#ty_heg__jinghe",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0 and not player:isKongcheng()
  end,
  card_filter = function(self, to_select, selected)
    if #selected < Self.maxHp and Fk:currentRoom():getCardArea(to_select) == Player.Hand then
      if #selected == 0 then
        return true
      else
        return table.every(selected, function(id) return Fk:getCardById(to_select).trueName ~= Fk:getCardById(id).trueName end)
      end
    end
  end,
  target_filter = function(self, to_select, selected, selected_cards)
    return #selected < #selected_cards and H.getGeneralsRevealedNum(Fk:currentRoom():getPlayerById(to_select)) > 0
  end,
  feasible = function (self, selected, selected_cards)
    return #selected > 0 and #selected == #selected_cards
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    room:setPlayerMark(player, "ty_heg__jinghe_used", 1)
    player:showCards(effect.cards)
    room:sortPlayersByAction(effect.tos)

    local num = 0 + #effect.tos
    local skills = table.random({"ty_heg__leiji", "ty_heg__yinbingn", "ty_heg__huoqi", "ty_heg__guizhu", "ty_heg__xianshou", "ty_heg__lundao", "ty_heg__guanyue", "ty_heg__yanzhengn"}, num)
    local selected = {}
    for _, id in ipairs(effect.tos) do
      local p = room:getPlayerById(id)
      if not p.dead then
        local choices = table.filter(skills, function(s) return not p:hasSkill(s, true) and not table.contains(selected, s) end)
        if #choices > 0 then
          local choice = room:askForChoice(p, choices, self.name, "#ty_heg__jinghe-choice:::"..#skills, true, skills)
          room:setPlayerMark(p, self.name, choice)
          table.insert(selected, choice)
          room:handleAddLoseSkills(p, choice, nil, true, false)
        end
      end
    end
  end,
}
local jinghe_trigger = fk.CreateTriggerSkill {
  name = "#ty_heg__jinghe_trigger",
  mute = true,
  events = {fk.TurnStart, fk.BuryVictim},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:getMark("ty_heg__jinghe_used") > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "ty_heg__jinghe_used", 0)
    for _, p in ipairs(room.alive_players) do
      if p:getMark("ty_heg__jinghe") ~= 0 then
        local skill = p:getMark("ty_heg__jinghe")
        room:setPlayerMark(p, "ty_heg__jinghe", 0)
        room:handleAddLoseSkills(p, "-"..skill, nil, true, false)
      end
    end
  end,
}