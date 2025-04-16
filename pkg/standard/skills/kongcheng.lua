
local kongcheng = fk.CreateSkill{
  name = "hs__kongcheng",
  tags = {Skill.Compulsory},
}

kongcheng:addEffect(fk.TargetConfirming, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(kongcheng.name) and player:isKongcheng() and (data.card.trueName == "slash" or data.card.name == "duel")
  end,
  on_use = function(self, event, target, player, data)
    data:cancelTarget(player)
  end
})

kongcheng:addEffect(fk.BeforeCardsMove, {
  anim_type = "defensive",
  can_trigger = function (self, event, target, player, data)
    if player:hasSkill(kongcheng.name) and player:isKongcheng() and player.room.current ~= player then
      for _, move in ipairs(data) do
        if move.moveReason == fk.ReasonGive and move.to == player and move.toArea == Card.PlayerHand then
          return true
        end
      end
    end
  end,
  on_use = function (self, event, target, player, data)
    local mirror_moves = {}
    for _, move in ipairs(data) do
      if move.moveReason == fk.ReasonGive and move.to == player and move.toArea == Card.PlayerHand then
        local mirror_info = move.moveInfo
        if #mirror_info > 0 then
          move.moveInfo = {}
          local mirror_move = table.clone(move)
          mirror_move.toArea = Card.PlayerSpecial
          mirror_move.specialName = "zither"
          mirror_move.moveVisible = true
          mirror_move.moveMark = nil
          mirror_move.moveInfo = mirror_info
          table.insert(mirror_moves, mirror_move)
        end
      end
    end
    table.insertTable(data, mirror_moves)
  end
})
kongcheng:addEffect(fk.EventPhaseStart, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(kongcheng.name) and player == target and player.phase == Player.Draw and
      #player:getPile("zither") > 0
  end,
  on_use = function (self, event, target, player, data)
    player.room:obtainCard(player, player:getPile("zither"), true)
  end
})

kongcheng:addTest(function (room, me)
  local comp2 = room.players[2]
  FkTest.runInRoom(function ()
    room:handleAddLoseSkills(comp2, kongcheng.name)
    room:useVirtualCard("slash", nil, me, comp2)
    room:useVirtualCard("duel", nil, me, comp2)
  end)
  lu.assertEquals(comp2.hp, 4)
  FkTest.runInRoom(function ()
    local card = Fk:getCardById(1)
    room:moveCardTo(card, Card.PlayerHand, comp2, fk.ReasonGive)
  end)
  lu.assertIsTrue(comp2:isKongcheng())
end)

Fk:loadTranslationTable{
  ["hs__kongcheng"] = "空城",
  [":hs__kongcheng"] = "锁定技，若你没有手牌：1. 当你成为【杀】或【决斗】的目标时，取消此目标；"..
    "2. 你的回合外，当牌因交给而移至你的手牌区前，你将此次移动的目标区域改为你的武将牌上（均称为“琴”），摸牌阶段开始时，你获得所有“琴”。",
  ["zither"] = "琴",
  ["$hs__kongcheng1"] = "（抚琴声）",
  ["$hs__kongcheng2"] = "（抚琴声）",
}

return kongcheng
