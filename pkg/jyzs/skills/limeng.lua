local limeng = fk.CreateSkill{
  name = "jy_heg__limeng",
}

Fk:loadTranslationTable{
  ["jy_heg__limeng"] = "离梦",
  [":jy_heg__limeng"] = "结束阶段，你可以弃置一张非基本牌并选择场上两张珠联璧合的武将牌，" ..
    "若不为同一名角色的武将，则这些角色分别对另一名角色造成1点伤害。",
  ["#jy_heg__limeng-invoke"] = "你可发动 离梦，弃置一张非基本牌并选择场上两张珠联璧合的武将牌，<br>" ..
    "若不为同一名角色的武将，则这些角色分别对另一名角色造成1点伤害",
}

limeng:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if not (target == player and player:hasSkill(self.name) and player.phase == Player.Finish
      and not player:isNude()) then return false end
    local generals = {} ---@type table<Player, General[]>
    table.forEach(player.room.alive_players, function(p)
      generals[p] = {Fk.generals[p.general], Fk.generals[p.deputyGeneral]}
    end)
    for p, gs in pairs(generals) do
      for _, g in ipairs(gs) do
        for _p, _gs in pairs(generals) do
          for _, _g in ipairs(_gs) do
            if g:isCompanionWith(_g) then return true end
          end
        end
      end
    end
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local _, ret = room:askToUseActiveSkill(player, {
      skill_name = "#jy_heg__limeng_choose&",
      skip = true,
      prompt = "#jy_heg__limeng-invoke"
    })
    if ret then
      event:setCostData(self, {tos = ret.targets, cards = ret.cards})
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local costData = event:getCostData(self)
    local tos, cards = costData.tos, costData.cards
    local room = player.room
    room:throwCard(cards, limeng.name, player, player)
    if #tos < 2 then return end
    room:sortByAction(tos)
    for i = 1, 2, 1 do
      local to1, to2 = tos[i], tos[3-i]
      if to1:isAlive() and to2:isAlive() then
        room:damage{
          from = to1,
          to = to2,
          damage = 1,
        }
      end
    end
  end
})

limeng:addTest(function (room, me)
  FkTest.runInRoom(function ()
    room:handleAddLoseSkills(me, limeng.name)
  end)
  local comp2, comp3 = room.players[2], room.players[3]
  FkTest.setRoomBreakpoint(me, "AskForUseActiveSkill")
  local card = room:printCard("dilu")

  FkTest.runInRoom(function ()
    room:obtainCard(me, card)
    room:changeHero(comp2, "hs__zhouyu") -- comp2和3是珠联璧合，comp2自己也是珠联璧合
    room:changeHero(comp2, "hs__xiaoqiao", nil, true)
    room:changeHero(comp3, "hs__huanggai")
    room:changeHero(comp3, "hs__zhoutai", nil, true)
    me:gainAnExtraPhase(Player.Finish)
  end)

  local handler = ClientInstance.current_request_handler --[[@as ReqActiveSkill]]
  -- 验证只能选comp2和3
  lu.assertIsFalse(handler:targetValidity(me.id))
  lu.assertIsTrue(handler:targetValidity(comp2.id))
  lu.assertIsTrue(handler:targetValidity(comp3.id))
  for i = 4, 8 do
    lu.assertIsFalse(handler:targetValidity(room.players[i].id))
  end
  handler:selectCard(card.id, {selected = true})
  -- 只选comp2，可以确定，可以选comp3
  handler:selectTarget(comp2.id, {selected = true})
  lu.assertIsTrue(handler:targetValidity(comp3.id))
  lu.assertIsTrue(handler:feasible())

  -- 再选comp3，可以确定
  handler:selectTarget(comp3.id, {selected = true})
  lu.assertIsTrue(handler:feasible())

  -- 取消comp2，不可以确定，可以选comp2
  handler:selectTarget(comp2.id, {selected = false})
  lu.assertIsTrue(handler:targetValidity(comp2.id))
  lu.assertIsFalse(handler:feasible())

  FkTest.setNextReplies(me, {
    FkTest.replyUseSkill("#jy_heg__limeng_choose&", {comp2, comp3}, {card.id})
  })
  FkTest.resumeRoom()
  lu.assertEquals(comp2.hp, 2) -- 周瑜小乔 max 3
  lu.assertEquals(comp3.hp, 3)

  FkTest.setNextReplies(me, {
    FkTest.replyUseSkill("#jy_heg__limeng_choose&", {comp2}, {card.id})
  })
  FkTest.runInRoom(function ()
    room:obtainCard(me, card)
    me:gainAnExtraPhase(Player.Finish)
  end)
  lu.assertEquals(comp2.hp, 2)
end)

return limeng
