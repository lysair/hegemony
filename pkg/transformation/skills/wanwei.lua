local wanwei = fk.CreateSkill{
  name = "ld__wanwei",
}
wanwei:addEffect(fk.BeforeCardsMove, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(wanwei.name) then return end
    local _data = {}
    for index, move in ipairs(data) do
      local num = 0
      if (move.moveReason == fk.ReasonPrey or move.moveReason == fk.ReasonDiscard) and move.from == player and move.proposer ~= player then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerEquip or info.fromArea == Card.PlayerHand then
            num = num + 1
          end
        end
      end
      if num ~= 0 then
        table.insert(_data, {index, num})
      end
    end
    if #_data == 0 then return end
    event:setCostData(self, {_data = _data})
    return true
  end,
  on_use = function(self, event, target, player, data)
    if player.dead then return end
    local room = player.room
    local _data = event:getCostData(self)._data
    for _, tab in ipairs(_data) do
      local index, num = tab[1], tab[2]
      local ids = room:askToChooseCards(player, {
        target = player,
        min = num,
        max = num,
        flag = "he",
        skill_name = wanwei.name,
        prompt = "#ld__wanwei-choose",
      })
      if #ids == num then
        local moveInfo = {}
        for _, id in ipairs(ids) do
          local from = room:getCardArea(id)
          local info = {}
          info.cardId = id
          info.fromArea = from
          table.insertIfNeed(moveInfo, info)
        end
        if #moveInfo == num then
          data[index].moveInfo = moveInfo
        end
      end
    end
  end,
})

Fk:loadTranslationTable{
  ["ld__wanwei"] = "挽危",
  [":ld__wanwei"] = "当你的牌被其他角色弃置或获得时，你可改为你选择的等量的牌。",

  ["#ld__wanwei-choose"] = "挽危：请选择等量即将被其他角色弃置或获得的牌",

  ["$ld__wanwei1"] = "吉凶未可知，何故自乱？",
  ["$ld__wanwei2"] = "虽为水火之势，亦当虑而后动。",
}

return wanwei
