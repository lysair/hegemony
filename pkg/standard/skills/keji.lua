local keji = fk.CreateSkill{
  name = "hs__keji",
  tags = {Skill.Compulsory},
}
keji:addEffect(fk.EventPhaseStart, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    if target ~= player or not player:hasSkill(keji.name) or player.phase ~= Player.Discard then return false end
    local cards, play_ids = {}, {}
    local logic = player.room.logic
    logic:getEventsOfScope(GameEvent.Phase, 1, function (e)
      if e.data.phase == Player.Play then
        table.insert(play_ids, {e.id, e.end_id})
      end
      return false
    end, Player.HistoryTurn)
    logic:getEventsOfScope(GameEvent.UseCard, 1, function (e)
      local in_play = false
      for _, ids in ipairs(play_ids) do
        if #ids == 2 and e.id > ids[1] and e.id < ids[2] then
          in_play = true
          break
        end
      end
      if in_play then
        local use = e.data
        if use.from == player and use.card.color ~= Card.NoColor then
          table.insertIfNeed(cards, use.card.color)
        end
      end
    end, Player.HistoryTurn)
    return #cards <= 1
  end,
  on_use = function(self, event, target, player, data)
    player.room:addPlayerMark(player, MarkEnum.AddMaxCardsInTurn, 4)
  end
})

Fk:loadTranslationTable{
  ["hs__keji"] = "克己",
  [":hs__keji"] = "锁定技，弃牌阶段开始时，若你于出牌阶段内未使用过有颜色的牌，或于出牌阶段内使用过的所有的牌的颜色均相同，你的手牌上限于此回合内+4。",

  ["$hs__keji1"] = "谨慎为妙。",
  ["$hs__keji2"] = "时机未到。",
}

return keji
