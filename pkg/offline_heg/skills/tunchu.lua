local tunchu = fk.CreateSkill{
  name = "of_heg__tunchu",
}
tunchu:addEffect(fk.DrawNCards, {
  anim_type = "drawcard",
  derived_piles = "of_heg__lifeng_liang",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(tunchu.name)
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, tunchu.name)
  end,
  on_use = function(self, event, target, player, data)
    data.n = data.n + 2
    player.room:setPlayerMark(player, "@@of_heg__tunchu_prohibit-turn", 1)
  end,
})
tunchu:addEffect(fk.AfterDrawNCards, {
  anim_type = "drawcard",
  derived_piles = "of_heg__lifeng_liang",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:usedSkillTimes(tunchu.name, Player.HistoryPhase) > 0 and not player:isKongcheng()
  end,
  on_cost = function(self, event, target, player, data)
    local cards = player.room:askForCard(player, 1, 2, false, tunchu.name, false, ".", "#of_heg__tunchu-put")
    event:setCostData(self, {cards = cards})
    return true
  end,
  on_use = function(self, event, target, player, data)
    player:addToPile("of_heg__lifeng_liang", event:getCostData(self).cards, true, tunchu.name)
  end,
})
tunchu:addEffect("prohibit", {
  prohibit_use = function(self, player, card)
    return player:hasSkill(tunchu.name) and player:getMark("@@of_heg__tunchu_prohibit-turn") > 0 and card.trueName == "slash"
  end,
})

Fk:loadTranslationTable{
  ["of_heg__tunchu"] = "屯储",
  [":of_heg__tunchu"] = "摸牌阶段，你可以多摸两张牌，然后将至多两张手牌置于你的武将牌上，称为“粮”；然后本回合你不能使用【杀】。",

  ["@@of_heg__tunchu_prohibit-turn"] = "屯储",
  ["#of_heg__tunchu-put"] = "屯储：你可以将至多两张手牌置为“粮”",

  ["$of_heg__tunchu1"] = "屯粮事大，暂不与尔等计较。",
  ["$of_heg__tunchu2"] = "屯粮待战，莫动刀枪。",
}

return tunchu
