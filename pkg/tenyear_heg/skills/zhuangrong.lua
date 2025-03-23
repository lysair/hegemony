local zhuangrong = fk.CreateActiveSkill{
  name = "ty_heg__zhuangrong",
  anim_type = "offensive",
  card_num = 1,
  target_num = 0,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0 and not player:isKongcheng()
  end,
  card_filter = function(self, to_select, selected)
    local card = Fk:getCardById(to_select)
    return #selected == 0 and card.type == Card.TypeTrick and not Self:prohibitDiscard(to_select)
  end,
  on_use = function(self, room, effect)
    local from = room:getPlayerById(effect.from)
    room:throwCard(effect.cards, self.name, from, from)
    if from.dead then return end
    room:setPlayerMark(from, "@@ty_heg__zhuanrong_hs_wushuang", 1)
    room:handleAddLoseSkills(from, "ty_heg__zhuanrong_hs_wushuang", nil)
  end,
}

local zhuangrong_refresh = fk.CreateTriggerSkill{
  name = "#ty_heg__zhuangrong_refresh",
  refresh_events = {fk.EventPhaseEnd},
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill("ty_heg__zhuanrong_hs_wushuang", true, true)
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    room:handleAddLoseSkills(player, "-ty_heg__zhuanrong_hs_wushuang", nil)
    room:setPlayerMark(player, "@@ty_heg__zhuanrong_hs_wushuang", 0)
  end,
}
