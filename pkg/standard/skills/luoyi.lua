local luoyi = fk.CreateSkill{
  name = "hs__luoyi",
}
luoyi:addEffect(fk.EventPhaseEnd, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Draw
  end,
  on_use = function(self, event, target, player, data)
    player.room:askToDiscard(player,{min_num = 1, max_num = 1, cancelable = false, skill_name = "hs__luoyi",
      prompt = "hs__luoyi-ask"})
  end,
})
luoyi:addEffect(fk.DamageCaused, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:usedSkillTimes("hs__luoyi", Player.HistoryTurn) > 0 and
      not data.chain and data.card and (data.card.trueName == "slash" or data.card.name == "duel")
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    -- local room = player.room
    -- player:broadcastSkillInvoke("hs__luoyi")
    -- room:notifySkillInvoked(player, "hs__luoyi")
    data.damage = data.damage + 1
  end,
})

luoyi:addTest(function(room, me)
  local comp2 = room.players[2]
  FkTest.runInRoom(function()
    room:handleAddLoseSkills(me, luoyi.name)
  end)
  local slash = Fk:getCardById(1)
  local duel = room:printCard("duel")
  FkTest.setNextReplies(me, { "1", json.encode {
    card = { skill = "discard_skill", subcards = { 36 } },
    targets = {}
  } , json.encode {
    card = 1,
    targets = { comp2.id }
  } , json.encode {
    card = duel.id,
    targets = { comp2.id }
  } })
  FkTest.setNextReplies(comp2, { "__cancel", "__cancel" })

  FkTest.runInRoom(function()
    room:obtainCard(me, 36)
    room:obtainCard(me, 1)
    room:obtainCard(me, duel)
    room:changeMaxHp(comp2, 4)
    room:recover{
      who = comp2,
      num = 4,
    }
    GameEvent.Turn:create(TurnData:new(me, "game_rule")):exec()
  end)
  lu.assertEquals(#me:getCardIds("h"), 2)
  lu.assertEquals(comp2.hp, 4)

  -- 测持续时间
  FkTest.setNextReplies(me, { "__cancel", json.encode {
    card = 1,
    targets = { comp2.id }
  } })
  FkTest.runInRoom(function()
    room:obtainCard(me, 1)
    GameEvent.Turn:create(TurnData:new(me, "game_rule")):exec()
  end)
  lu.assertEquals(comp2.hp, 3)
end)

Fk:loadTranslationTable{
  ["hs__luoyi-ask"] = "你可以弃置一张牌，于此回合内执行【杀】或【决斗】的效果造成伤害时伤害+1",

  ["hs__luoyi"] = "裸衣",
  [":hs__luoyi"] = "摸牌阶段结束时，你可弃置一张牌，令你于此回合内执行【杀】或【决斗】的效果造成伤害时，此伤害+1。",

  ["$hs__luoyi1"] = "脱！",
  ["$hs__luoyi2"] = "谁来与我大战三百回合？",
}

return luoyi

