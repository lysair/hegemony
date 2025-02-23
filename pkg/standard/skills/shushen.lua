local shushen = fk.CreateSkill{
  name = "shushen",
}
shushen:addEffect(fk.HpRecover, {
  anim_type = "support",
  on_trigger = function(self, event, target, player, data)
    for _ = 1, data.num do
      if event:isCancelCost(self) or not player:hasSkill(shushen.name) then break end
      self:doCost(event, target, player, data)
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local to = room:askToChoosePlayers(player, {
      targets = room:getOtherPlayers(player, false),
      min_num = 1,
      max_num = 1,
      prompt = "#shushen-choose",
      skill_name = shushen.name,
    })
    if #to > 0 then
      event:setCostData(self, {tos = to})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local to = event:getCostData(self).tos[1]
    if not to:isKongcheng() then
      to:drawCards(1, shushen.name)
    else
      to:drawCards(2, shushen.name)
    end
  end,
})

shushen:addTest(function (room, me)
  local comp2, comp3 = room.players[2], room.players[3]
  FkTest.setNextReplies(me, { json.encode {
    card = { skill = "choose_players_skill", subcards = {} },
    targets = { comp2.id }
  }, json.encode {
    card = { skill = "choose_players_skill", subcards = {} },
    targets = { comp3.id }
  } })
  FkTest.runInRoom(function ()
    room:handleAddLoseSkills(me, shushen.name)
    room:loseHp(me, 2)
    comp2:drawCards(1)
    room:recover{
      who = me,
      num = 2,
    }
  end)
  lu.assertEquals(comp2:getHandcardNum(), 2)
  lu.assertEquals(comp3:getHandcardNum(), 2)
end)

Fk:loadTranslationTable{
  ["shushen"] = "淑慎",
  [":shushen"] = "当你回复1点体力后，你可令一名其他角色摸一张牌，若其没有手牌，则改为摸两张牌。",
  ["#shushen-choose"] = "淑慎：你可令一名其他角色摸一张牌",
  ["$shushen1"] = "船到桥头自然直。",
  ["$shushen2"] = "妾身无恙，相公请安心征战。",
}

return shushen
