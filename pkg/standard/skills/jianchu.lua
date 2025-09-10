
local jianchu = fk.CreateSkill{
  name = "jianchu",
}
jianchu:addEffect(fk.TargetSpecified, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if not (target == player and player:hasSkill(self.skeleton.name)) then return end
    return data.card.trueName == "slash" and not data.to:isNude()
  end,
  on_cost = function (self, event, target, player, data)
    if player.room:askToSkillInvoke(player, {
      skill_name = jianchu.name,
      prompt = "#jianchu-invoke:"..data.to.id,
    }) then
      event:setCostData(self, {tos = {data.to} })
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = data.to
    local id = room:askToChooseCard(player, {target = to, flag = "he", skill_name = self.skeleton.name})
    room:throwCard({id}, self.skeleton.name, to, player)
    local card = Fk:getCardById(id)
    if card.type == Card.TypeEquip then
      data.disresponsive = true
    else
      if not to.dead then
        local cardlist = Card:getIdList(data.card)
        if #cardlist > 0 and table.every(cardlist, function(c) return room:getCardArea(c) == Card.Processing end) then
          room:obtainCard(to.id, data.card, true)
        end
      end
    end
  end,
})

jianchu:addTest(function (room, me)
  local comp2 = room.players[2]
  FkTest.setNextReplies(me, {"1", "56"})
  local jink = room:printCard("jink")
  FkTest.setNextReplies(comp2, { json.encode {
    card = jink.id,
  } })
  FkTest.runInRoom(function ()
    room:handleAddLoseSkills(me, jianchu.name)
    room:obtainCard(comp2, jink, true)
    room:obtainCard(comp2, 56, true)
    room:obtainCard(me, 1)
    room:useCard{
      from = me,
      tos = {comp2},
      card = Fk:getCardById(1),
    }
  end)
  lu.assertEquals(comp2:getHandcardNum(), 1)
  lu.assertEquals(comp2.hp, 4)
  lu.assertEquals(comp2:getCardIds("h")[1], 1)

  local axe = room:printCard("axe")
  FkTest.setNextReplies(me, {"1", tostring(axe.id)})
  FkTest.setNextReplies(comp2, { json.encode {
    card = jink.id,
  } })
  FkTest.runInRoom(function ()
    room:obtainCard(comp2, axe, true)
    room:obtainCard(comp2, jink, true)
    room:obtainCard(me, 1)
    room:useCard{
      from = me,
      tos = {comp2},
      card = Fk:getCardById(1),
    }
  end)
  lu.assertEquals(comp2:getHandcardNum(), 1)
  lu.assertEquals(comp2.hp, 3)
  lu.assertEquals(comp2:getCardIds("h")[1], jink.id)
end)

Fk:loadTranslationTable{
  ["jianchu"] = "鞬出",
  [":jianchu"] = "当你使用【杀】指定目标后，你可以弃置该角色的一张牌，若此牌：为装备牌，其不能使用【闪】抵消此【杀】；不为装备牌，其获得此【杀】。",
  ["#jianchu-invoke"] = "鞬出：可以弃置 %src 一张牌，若此牌：为装备牌，其不能使用【闪】抵消此【杀】；不为装备牌，其获得此【杀】。",
  ["$jianchu1"] = "你，可敢挡我！",
  ["$jianchu2"] = "我要杀你们个片甲不留！",
}

return jianchu
