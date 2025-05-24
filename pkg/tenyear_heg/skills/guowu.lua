local guowu = fk.CreateSkill{
  name = "ty_heg__guowu",
}
guowu:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(guowu.name) and player.phase == Player.Play and not player:isKongcheng()
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = player:getCardIds("h")
    player:showCards(cards)
    room:delay(300)
    local types = {}
    for _, id in ipairs(cards) do
      table.insertIfNeed(types, Fk:getCardById(id).type)
    end
    local card = room:getCardsFromPileByRule("slash", 1, "discardPile")
    if #card > 0 then
      room:moveCards({
        ids = card,
        to = player.id,
        toArea = Card.PlayerHand,
        moveReason = fk.ReasonJustMove,
        proposer = player.id,
        skillName = guowu.name,
      })
    end
    if #types > 1 then
      room:setPlayerMark(player, "ty_heg__guowu-phase", #types)
    end
  end,
})

guowu:addEffect(fk.CardUsing, {
  anim_type = "offensive",
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:getMark("ty_heg__guowu-phase") > 0
      and not player.dead and
      (data.card.trueName == "slash") and #data:getExtraTargets() > 0
      and player:usedEffectTimes(guowu.name, Player.HistoryPhase) < 1
  end,
  on_cost = function (self, event, target, player, data)
    local targets = data:getExtraTargets()
    local tos = player.room:askToChoosePlayers(player, {
      targets = targets,
      min_num = 1,
      max_num = 2,
      prompt = "#guowu-choose:::"..data.card:toLogString(),
      skill_name = guowu.name,
      cancelable = true
    })
    if #tos > 0 then
      event:setCostData(self, {tos = tos})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local to = event:getCostData(self).tos[1]
    data:addTarget(to)
  end,
})

guowu:addEffect("targetmod", {
  bypass_distances =  function(self, player, skill, card)
    return card and player:getMark("ty_heg__guowu-phase") > 0
  end,
})

Fk:loadTranslationTable{
  ["ty_heg__guowu"] = "帼武",
  ["#ty_heg__guowu_delay"] = "帼武",
  [":ty_heg__guowu"] = "出牌阶段开始时，你可展示所有手牌，若包含的类别数：不小于1，你从弃牌堆中获得一张【杀】；不小于2，你本阶段使用牌无距离限制；"..
    "不小于3，你本阶段使用【杀】可以多指定两个目标（限一次）。",

  ["#ty_heg__guowu-choose"] = "帼武：你可以为%arg增加至多两个目标",

  ["$ty_heg__guowu1"] = "方天映黛眉，赤兔牵红妆。",
  ["$ty_heg__guowu2"] = "武姬青丝利，巾帼女儿红。",
}

return guowu
