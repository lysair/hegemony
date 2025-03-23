local zhuwei = fk.CreateSkill{
  name = "ld__zhuwei",
}
zhuwei:addEffect(fk.FinishJudge, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(zhuwei.name)
      and player.room:getCardArea(data.card) == Card.Processing
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:obtainCard(player.id, data.card, true, fk.ReasonJustMove)
    local current = room.current
    local choices = {"ld__zhuwei_ask::" .. current.id, "Cancel"}
    if room:askForChoice(player, choices, zhuwei.name) ~= "Cancel" then
      room:addPlayerMark(current, "@ld__zhuwei_buff-turn", 1)
      room:addPlayerMark(current, MarkEnum.AddMaxCardsInTurn, 1)
    end
  end,
})

zhuwei:addEffect("targetmod", {
  residue_func = function(self, player, skill, scope)
    if skill.trueName == "slash_skill" and player:getMark("@ld__zhuwei_buff-turn") > 0 and scope == Player.HistoryPhase then
      return player:getMark("@ld__zhuwei_buff-turn")
    end
  end,
})

Fk:loadTranslationTable{
  ["ld__zhuwei"] = "筑围",
  [":ld__zhuwei"] = "当你的判定结果确定后，你可获得此判定牌，然后你可令当前回合角色手牌上限和使用【杀】的次数上限于此回合内+1。",
  ["ld__zhuwei_ask"] = "令%dest手牌上限和使用【杀】的次数上限于此回合内+1",
  ["@ld__zhuwei_buff-turn"] = "筑围",

  ["$ld__zhuwei1"] = "背水一战，只为破敌。",
  ["$ld__zhuwei2"] = "全线并进，连战克晋。",
}

return zhuwei
