
local jieming = fk.CreateSkill{
  name = "hs__jieming",
}
jieming:addEffect(fk.Damaged, {
  anim_type = "masochism",
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local to = room:askToChoosePlayers(player, {targets = room.alive_players, min_num = 1, max_num = 1,
      prompt = "#hs__jieming-choose", skill_name = jieming.name, cancelable = true})
    if #to > 0 then
      event:setCostData(self, {tos = to})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local to = event:getCostData(self).tos[1]
    local num = math.min(to.maxHp, 5) - to:getHandcardNum()
    if num > 0 then
      to:drawCards(num, jieming.name)
    end
  end,
})

jieming:addTest(function (room, me)
  -- test1: 初始体力上限4，补到4张
  FkTest.setNextReplies(me, {json.encode {
    card = { skill = "choose_players_skill", subcards = {} },
    targets = {me.id}
  } })
  FkTest.runInRoom(function ()
    me:drawCards(1)
    room:handleAddLoseSkills(me, jieming.name)
    room:damage{
      to = me,
      damage = 1,
    }
  end)
  lu.assertEquals(me:getHandcardNum(), 4)

  -- test2: 溢出不摸牌
  local comp2 = room.players[2]
  FkTest.setNextReplies(me, {json.encode {
    card = { skill = "choose_players_skill", subcards = {} },
    targets = {comp2.id} -- 不摸牌
  } })
  FkTest.runInRoom(function ()
    comp2:drawCards(5)
    room:damage{
      to = me,
      damage = 1,
    }
  end)
  lu.assertEquals(comp2:getHandcardNum(), 5)

  -- test3: 体力上限超过5，最多摸到5张
  FkTest.setNextReplies(me, {json.encode {
    card = { skill = "choose_players_skill", subcards = {} },
    targets = {me.id} -- 至多到5
  }, json.encode {
    card = { skill = "choose_players_skill", subcards = {} },
    targets = {room.players[3].id} -- 无法发动
  } })
  FkTest.runInRoom(function ()
    room:changeMaxHp(me, 6)
    room:recover{who = me, num = 2}
    room:damage{
      to = me,
      damage = 2,
    }
  end)
  lu.assertEquals(me:getHandcardNum(), 5)
  lu.assertEquals(room.players[3]:getHandcardNum(), 0)
end)

Fk:loadTranslationTable{
  ["hs__jieming"] = "节命",
  [":hs__jieming"] = "当你受到伤害后，你可令一名角色将手牌补至X张（X为其体力上限且最多为5）。",

  ["#hs__jieming-choose"] = "节命：选择一名角色，其将手牌补至X张（X为其体力上限且最多为5）",
}

return jieming
