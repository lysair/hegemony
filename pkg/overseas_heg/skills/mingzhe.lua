local mingzhe = fk.CreateSkill{
  name = "os_heg__mingzhe",
}
mingzhe:addEffect(fk.AfterCardsMove, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(mingzhe.name) or player.room.current == player then return end
    for _, move in ipairs(data) do
      if move.from == player then
        for _, info in ipairs(move.moveInfo) do
          if Fk:getCardById(info.cardId).color == Card.Red then
            if info.fromArea == Card.PlayerEquip then
              return true
            elseif table.contains({fk.ReasonUse, fk.ReasonResponse}, move.moveReason)
              and table.contains({Card.PlayerHand, Card.PlayerEquip}, info.fromArea) then
                return true
            end
          end
        end
      end
    end
  end,
  trigger_times = function (self, event, target, player, data)
    local num = 0
    for _, move in ipairs(data) do
      if move.from == player then
        for _, info in ipairs(move.moveInfo) do
          if Fk:getCardById(info.cardId).color == Card.Red then
            if info.fromArea == Card.PlayerEquip then
              num = num + 1
            elseif table.contains({fk.ReasonUse, fk.ReasonResponse}, move.moveReason)
              and table.contains({Card.PlayerHand, Card.PlayerEquip}, info.fromArea) then
                num = num + 1
            end
          end
        end
      end
    end
    return num
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, mingzhe.name)
  end,
})

Fk:loadTranslationTable{
  ["os_heg__mingzhe"] = "明哲",
  [":os_heg__mingzhe"] = "当你于回合外{因使用、打出而失去一张红色牌或失去装备区里的红色牌}后，你可摸一张牌。",

  ["$os_heg__mingzhe1"] = "明以洞察，哲以保身。",
  ["$os_heg__mingzhe2"] = "塞翁失马，焉知非福。",
}

return mingzhe
