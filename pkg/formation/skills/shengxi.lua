local shengxi = fk.CreateSkill{
  name = "shengxi",
}
shengxi:addEffect(fk.EventPhaseStart, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return player == target and player:hasSkill(shengxi.name) and player.phase == Player.Finish and
    #player.room.logic:getActualDamageEvents(1, function(e) return e.data.from == player end) == 0
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(2, shengxi.name)
  end,
})

shengxi:addTest(function (room, me)
  FkTest.setNextReplies(me, {"1", json.encode {
    card = 1,
    targets = { room.players[2].id }
  }, "__cancel", "1", "1"})
  FkTest.runInRoom(function ()
    room:handleAddLoseSkills(me, shengxi.name)
    GameEvent.Turn:create(TurnData:new(me, "game_rule", {Player.Finish})):exec()
  end)
  lu.assertEquals(me:getHandcardNum(), 2)
  FkTest.runInRoom(function ()
    room:obtainCard(me, 1)
    GameEvent.Turn:create(TurnData:new(me, "game_rule", {Player.Play, Player.Finish})):exec()
  end)
  lu.assertEquals(me:getHandcardNum(), 2)
end)

Fk:loadTranslationTable{
  ["shengxi"] = "生息",
  [":shengxi"] = "结束阶段，若你于此回合内未造成过伤害，你可摸两张牌。",

  ["$shengxi1"] = "国之生计，在民生息。",
  ["$shengxi2"] = "安民止战，兴汉室！",
}

return shengxi
