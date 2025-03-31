local zhuangrong = fk.CreateSkill{
  name = "ty_heg__zhuangrong",
}
zhuangrong:addEffect("active", {
  anim_type = "offensive",
  card_num = 1,
  target_num = 0,
  can_use = function(self, player)
    return player:usedSkillTimes(zhuangrong.name, Player.HistoryPhase) == 0 and not player:isKongcheng()
  end,
  card_filter = function(self, player, to_select, selected)
    local card = Fk:getCardById(to_select)
    return #selected == 0 and card.type == Card.TypeTrick and not player:prohibitDiscard(card)
  end,
  on_use = function(self, room, effect)
    local from = effect.from
    room:throwCard(effect.cards, zhuangrong.name, from, from)
    if from.dead then return end
    room:setPlayerMark(from, "@@ty_heg__zhuanrong_hs_wushuang", 1)
    room:handleAddLoseSkills(from, "ty_heg__zhuanrong_hs_wushuang", nil)
  end,
})

zhuangrong:addEffect(fk.EventPhaseEnd, {
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill("ty_heg__zhuanrong_hs_wushuang", true, true)
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    room:handleAddLoseSkills(player, "-ty_heg__zhuanrong_hs_wushuang", nil)
    room:setPlayerMark(player, "@@ty_heg__zhuanrong_hs_wushuang", 0)
  end,
})

Fk:loadTranslationTable{
  ["ty_heg__zhuangrong"] = "妆戎",
  [":ty_heg__zhuangrong"] = "出牌阶段限一次，你可以弃置一张锦囊牌，然后你本阶段视为拥有技能〖无双〗。",

  ["@@ty_heg__zhuanrong_hs_wushuang"] = "无双",

  ["$ty_heg__zhuangrong1"] = "继父神威，无坚不摧！",
  ["$ty_heg__zhuangrong2"] = "我乃温侯吕奉先之女！",
}

return zhuangrong

