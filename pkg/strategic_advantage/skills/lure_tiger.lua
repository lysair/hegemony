
local lureTigerSkill = fk.CreateSkill{
  name = "lure_tiger_skill",
}
lureTigerSkill:addEffect("active", {
  prompt = "#lure_tiger_skill",
  can_use = Util.CanUse,
  min_target_num = 1,
  max_target_num = 2,
  mod_target_filter = function(self, player, to_select, selected)
    return to_select ~= player
  end,
  target_filter = Util.CardTargetFilter,
  on_effect = function(self, room, effect)
    local target = effect.to
    room:setPlayerMark(target, "@@lure_tiger-turn", 1)
    room:setPlayerMark(target, MarkEnum.PlayerRemoved .. "-turn", 1)
    room:handleAddLoseSkills(target, "#lure_tiger_hp|#lure_tiger_prohibit", nil, false, true) -- global...
    room.logic:trigger("fk.RemoveStateChanged", target, nil) -- FIXME
  end,
})
lureTigerSkill:addEffect('prohibit', {
  name = "#lure_tiger_prohibit",
  global = true,
  prohibit_use = function(self, player, card)
    return player:getMark("@@lure_tiger-turn") ~= 0 -- TODO: kill
  end,
  is_prohibited = function(self, from, to, card)
    return to:getMark("@@lure_tiger-turn") ~= 0
  end,
})
lureTigerSkill:addEffect(fk.PreHpRecover, {
  name = "#lure_tiger_hp",
  global = true,
  can_refresh = function(self, event, target, player, data)
    return target == player and player:getMark("@@lure_tiger-turn") ~= 0
  end,
  on_refresh = function(self, event, target, player, data)
    data.num = 0
    return true
  end,
})
lureTigerSkill:addEffect(fk.PreHpLost, {
  name = "#lure_tiger_hp",
  global = true,
  can_refresh = function(self, event, target, player, data)
    return target == player and player:getMark("@@lure_tiger-turn") ~= 0
  end,
  on_refresh = function(self, event, target, player, data)
    data.num = 0
    return true
  end,
})
lureTigerSkill:addEffect(fk.DamageInflicted, {
  name = "#lure_tiger_hp",
  global = true,
  can_refresh = function(self, event, target, player, data)
    return target == player and player:getMark("@@lure_tiger-turn") ~= 0
  end,
  on_refresh = function(self, event, target, player, data)
    data.damage = 0
    return true
  end,
})

lureTigerSkill:addTest(function(room, me)
  local card = room:printCard("lure_tiger")
  local comp2, comp3, comp4 = room.players[2], room.players[3], room.players[4]
  FkTest.runInRoom(function()
    room:useCard{
      from = me,
      tos = {comp2, comp3},
      card = card,
    }
  end)
  lu.assertEquals(me:distanceTo(comp2), -1)
  lu.assertEquals(me:distanceTo(comp3), -1)
  lu.assertEquals(me:distanceTo(comp4), 1)
  lu.assertIs(me:getNextAlive(), comp4)
  lu.assertIsFalse(comp2:canUse(card))
  lu.assertIsFalse(me:canUseTo(card, comp2))

  FkTest.runInRoom(function()
    room:loseHp(comp2, 1)
  end)
  lu.assertEquals(comp2.hp, 4)

  -- 回合后
  FkTest.runInRoom(function()
    local data = { ---@type TurnDataSpec
      who = me,
      reason = "game_rule",
      phase_table = { Player.Finish }
    }
    GameEvent.Turn:create(TurnData:new(data)):exec()
  end)
  lu.assertIs(me:getNextAlive(), comp2)
  lu.assertEquals(me:distanceTo(comp3), 2)
end)

Fk:loadTranslationTable{
  ["lure_tiger"] = "调虎离山",
  [":lure_tiger"] = "锦囊牌<br/><b>时机</b>：出牌阶段<br/><b>目标</b>：一至两名其他角色<br/><b>效果</b>：目标角色于此回合内不计入距离和座次的计算，且不能使用牌，且不是牌的合法目标，且体力值不会改变。",
  ["#lure_tiger_prohibit"] = "调虎离山",
  ["#lure_tiger_skill"] = "选择一至两名其他角色，这些角色于此回合内不计入距离和座次的计算，<br/>且不能使用牌，且不是牌的合法目标，且体力值不会改变",

  ["@@lure_tiger-turn"] = "调虎离山",
}

return lureTigerSkill
