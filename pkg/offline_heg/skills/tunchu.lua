local tunchu = fk.CreateSkill{
  name = "of_heg__tunchu",
}

Fk:loadTranslationTable{
  ["of_heg__tunchu"] = "屯储",
  [":of_heg__tunchu"] = "摸牌阶段，你可以多摸两张牌，然后将至多两张手牌置于你的武将牌上，称为“粮”；然后本回合你不能使用【杀】。",

  ["@@of_heg__tunchu_prohibit-turn"] = "屯储",
  ["#of_heg__tunchu-put"] = "屯储：你可以将至多两张手牌置为“粮”",

  ["$of_heg__tunchu1"] = "屯粮事大，暂不与尔等计较。",
  ["$of_heg__tunchu2"] = "屯粮待战，莫动刀枪。",
}

tunchu:addEffect(fk.DrawNCards, {
  anim_type = "drawcard",
  derived_piles = "of_heg__lifeng_liang",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(tunchu.name)
  end,
  on_use = function(self, event, target, player, data)
    data.n = data.n + 2
    player.room:setPlayerMark(player, "@@of_heg__tunchu_prohibit-turn", 1)
  end,
})

tunchu:addEffect(fk.AfterDrawNCards, {
  mute = true,
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:usedSkillTimes(tunchu.name, Player.HistoryPhase) > 0 and not player:isKongcheng()
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = room:askToCards(player, {
      min_num = 1,
      max_num = 2,
      include_equip = false,
      skill_name = tunchu.name,
      prompt = "#of_heg__tunchu-put",
      cancelable = true,
    })
    player:addToPile("of_heg__lifeng_liang", cards, true, tunchu.name)
  end,
})

tunchu:addEffect("prohibit", {
  prohibit_use = function(self, player, card)
    return card and player:getMark("@@of_heg__tunchu_prohibit-turn") > 0 and card.trueName == "slash"
  end,
})

return tunchu
