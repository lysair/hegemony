local zhangwu = fk.CreateSkill{
  name = "zhangwu",
  tags = {Skill.Compulsory},
}
zhangwu:addEffect(fk.BeforeCardsMove, {
  anim_type = 'drawcard',
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(zhangwu.name) then return false end
    for _, move in ipairs(data) do
      if move.from == player and (move.to ~= player or (move.toArea ~= Card.PlayerEquip and move.toArea ~= Card.PlayerHand)) and
        (move.moveReason ~= fk.ReasonUse or player.room.logic:getCurrentEvent():findParent(GameEvent.UseCard).data.card.name ~= "dragon_phoenix") then
        for _, info in ipairs(move.moveInfo) do
          if (info.fromArea == Card.PlayerEquip or info.fromArea == Card.PlayerHand) and Fk:getCardById(info.cardId).name == "dragon_phoenix" then
            return true
          end
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local ids = {}
    local mirror_moves = {} ---@type MoveCardsData[]
    for _, move in ipairs(data) do
      if move.from == player and (move.to ~= player or (move.toArea ~= Card.PlayerEquip and move.toArea ~= Card.PlayerHand)) and
        (move.moveReason ~= fk.ReasonUse or player.room.logic:getCurrentEvent():findParent(GameEvent.UseCard).data.card.name ~= "dragon_phoenix") then
        local move_info = {}
        local mirror_info = {}
        for _, info in ipairs(move.moveInfo) do
          local id = info.cardId
          if (info.fromArea == Card.PlayerEquip or info.fromArea == Card.PlayerHand) and Fk:getCardById(info.cardId).name == "dragon_phoenix" then
            table.insert(ids, id)
            table.insert(mirror_info, info)
          else
            table.insert(move_info, info)
          end
        end
        if #mirror_info > 0 then
          move.moveInfo = move_info
          local mirror_move = table.simpleClone(move)
          mirror_move.to = nil
          mirror_move.toArea = Card.DrawPile
          mirror_move.drawPilePosition = -1
          mirror_move.moveInfo = mirror_info
          table.insert(mirror_moves, mirror_move)
        end
      end
    end
    player:showCards(ids)
    table.insertTable(data, mirror_moves)
    if not player.dead then
      player:drawCards(2, zhangwu.name) -- 大摆特摆
    end
  end,
})
zhangwu:addEffect(fk.AfterCardsMove, {
  anim_type = 'drawcard',
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(zhangwu.name) then return false end
    for _, move in ipairs(data) do
      if move.to ~= player and (move.toArea == Card.PlayerEquip or move.toArea == Card.DiscardPile) then
        for _, info in ipairs(move.moveInfo) do
          if Fk:getCardById(info.cardId).name == "dragon_phoenix" then
            return true
          end
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local ids = {}
    for _, move in ipairs(data) do
      if move.to ~= player and (move.toArea == Card.PlayerEquip or move.toArea == Card.DiscardPile) then
        for _, info in ipairs(move.moveInfo) do
          if Fk:getCardById(info.cardId).name == "dragon_phoenix" then
            table.insert(ids, info.cardId)
          end
        end
      end
    end
    player.room:obtainCard(player, ids, true, fk.ReasonPrey)
  end,
})

zhangwu:addTest(function (room, me)
  FkTest.runInRoom(function ()
    room:handleAddLoseSkills(me, "zhangwu")
  end)
  local comp2 = room.players[2]
  local card = room:printCard("dragon_phoenix")
  FkTest.runInRoom(function ()
    room:useCard{
      from = comp2,
      tos = {comp2},
      card = card
    }
  end)
  lu.assertEquals(me:getCardIds("h"), {card.id})
  FkTest.runInRoom(function ()
    me:throwAllCards("h")
  end)
  lu.assertEquals(me:getHandcardNum(), 2)
  FkTest.runInRoom(function ()
    room:obtainCard(comp2, card)
    comp2:throwAllCards("h")
  end)
  lu.assertEquals(me:getHandcardNum(), 3)
end)

Fk:loadTranslationTable{
  ["zhangwu"] = "章武",
  [":zhangwu"] = "锁定技，①当【飞龙夺凤】移至弃牌堆或其他角色的装备区后，你获得此【飞龙夺凤】；" ..
    "②当你非因使用【飞龙夺凤】而失去【飞龙夺凤】前，你展示此【飞龙夺凤】，将此【飞龙夺凤】的此次移动" ..
    "的目标区域改为牌堆底，摸两张牌。",

  ["$zhangwu1"] = "遁剑归一，有凤来仪。",
  ["$zhangwu2"] = "剑气化龙，听朕雷动！",
}

return zhangwu
