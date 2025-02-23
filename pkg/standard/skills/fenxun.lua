local fenxun = fk.CreateSkill{
  name = "fenxun",
}
fenxun:addEffect("active", {
  anim_type = "offensive",
  card_num = 1,
  target_num = 1,
  prompt = "#fenxun",
  can_use = function(self, player)
    return player:usedSkillTimes(fenxun.name, Player.HistoryPhase) == 0 and not player:isNude()
  end,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and not Self:prohibitDiscard(Fk:getCardById(to_select))
  end,
  target_filter = function(self, player, to_select, selected, cards)
    return #selected == 0 and to_select ~= player
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    room:addTableMark(player, "fenxun-turn", effect.tos[1].id)
    room:throwCard(effect.cards, fenxun.name, player, player)
  end,
})
fenxun:addEffect("distance", {
  name = "#fenxun_distance",
  fixed_func = function(self, from, to)
    if table.contains(from:getTableMark("fenxun-turn"), to.id) then
      return 1
    end
  end,
})

fenxun:addTest(function (room, me)
  local comp3 = room.players[3]
  local function createTwiceClosure() -- 第二次询问时断点
    local i = 0
    return function()
      i = i + 1
      return i == 2
    end
  end
  FkTest.setRoomBreakpoint(me, "PlayCard", createTwiceClosure())
  FkTest.setNextReplies(me, {json.encode {
    card = { skill = "fenxun", subcards = {1} }, targets = { comp3.id }
  } })
  FkTest.runInRoom(function ()
    room:handleAddLoseSkills(me, "fenxun")
    room:obtainCard(me, 1)
    GameEvent.Turn:create(TurnData:new(me, "game_rule", { Player.Play })):exec()
  end)
  lu.assertEquals(me:distanceTo(comp3), 1)
end)

Fk:loadTranslationTable{
  ["fenxun"] = "奋迅",
  [":fenxun"] = "出牌阶段限一次，你可以弃置一张牌并选择一名其他角色，令你与其的距离视为1，直到回合结束。",
  ["#fenxun"] = "奋迅：弃一张牌，你与一名角色的距离视为1直到回合结束",
}

return fenxun
