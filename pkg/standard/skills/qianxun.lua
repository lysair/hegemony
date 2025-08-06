
local qianxun = fk.CreateSkill{
  name = "hs__qianxun",
  tags = {Skill.Compulsory},
}
qianxun:addEffect(fk.TargetConfirming, {
  anim_type = "defensive",
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(qianxun.name) and (data.card.trueName == "snatch") -- or data.card.trueName == "indulgence")
  end,
  on_use = function(self, event, target, player, data)
    player.room:notifySkillInvoked(player, qianxun.name)
    player:broadcastSkillInvoke(qianxun.name, 2)
    data:cancelTarget(player)
  end
})

qianxun:addEffect(fk.BeforeCardsMove, {
  anim_type = "defensive",
  mute = true,
  can_trigger = function (self, event, target, player, data)
    if not player:hasSkill(qianxun.name) then return false end
    local id = 0
    local source = player
    local c
    for _, move in ipairs(data) do
      if move.to == player.id and move.toArea == Card.PlayerJudge then
        for _, info in ipairs(move.moveInfo) do
          id = info.cardId
          if info.fromArea == Card.PlayerJudge then
            source = move.from or player
          else
            source = player
          end
          c = source:getVirualEquip(id)
          --FIXME：巨大隐患，延时锦囊的virtual_equips在置入判定区的事件被篡改，或者判定阶段自然流程以外的方式离开判定区时不会清理
          if not c then c = Fk:getCardById(id) end
          if c.trueName == "indulgence" then
            return true
          end
        end
      end
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    room:notifySkillInvoked(player, qianxun.name)
    player:broadcastSkillInvoke(qianxun.name, 1)
    local source = player
    local mirror_moves = {}
    local ids = {}
    for _, move in ipairs(data) do
      if move.to == player and move.toArea == Card.PlayerJudge then
        local move_info = {}
        local mirror_info = {}
        for _, info in ipairs(move.moveInfo) do
          local id = info.cardId
          if info.fromArea == Card.PlayerJudge then
            source = move.from or player
          else
            source = player
          end
          local c = source:getVirualEquip(id)
          if not c then c = Fk:getCardById(id) end
          if c.trueName == "indulgence" then
            table.insert(mirror_info, info)
            table.insert(ids, id)
          else
            table.insert(move_info, info)
          end
        end
        if #mirror_info > 0 then
          move.moveInfo = move_info
          local mirror_move = table.simpleClone(move)
          mirror_move.to = nil
          mirror_move.toArea = Card.DiscardPile
          mirror_move.moveInfo = mirror_info
          table.insert(mirror_moves, mirror_move)
        end
      end
    end
    table.insertTable(data, mirror_moves)
  end
})

qianxun:addTest(function (room, me)
  local comp2 = room.players[2]
  FkTest.runInRoom(function () room:handleAddLoseSkills(comp2, qianxun.name) end)
  local card = room:printCard("indulgence")
  FkTest.runInRoom(function ()
    room:obtainCard(comp2, 1)
    room:useVirtualCard("snatch", nil, me, comp2)
    room:obtainCard(me, card)
    room:useCard{
      from = me,
      tos = { comp2 },
      card = card,
    }
  end)
  lu.assertIsFalse(comp2:isKongcheng())
  lu.assertEquals(#comp2:getCardIds("e"), 0)
end)

Fk:loadTranslationTable{
  ["hs__qianxun"] = "谦逊",
  [":hs__qianxun"] = "锁定技，当你成为【顺手牵羊】或【乐不思蜀】的目标时，你取消此目标。",

  ["$hs__qianxun1"] = "儒生脱尘，不为贪逸淫乐之事。",
  ["$hs__qianxun2"] = "谦谦君子，不饮盗泉之水。",
}

return qianxun
