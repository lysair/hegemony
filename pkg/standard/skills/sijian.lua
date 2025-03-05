local sijian = fk.CreateSkill{
  name = "sijian",
}
sijian:addEffect(fk.AfterCardsMove, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(sijian.name) or not player:isKongcheng() then return end
    local ret = false
    for _, move in ipairs(data) do
      if move.from == player then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerHand then
            ret = true
            break
          end
        end
      end
    end
    if ret then
      return table.find(player.room:getOtherPlayers(player, false), function(p) return not p:isNude() end)
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(player.room:getOtherPlayers(player, false), function(p) return not p:isNude() end)
    local tos = room:askToChoosePlayers(player, {targets = targets, min_num = 1, max_num = 1,
      prompt = "#sijian-ask", skill_name = sijian.name, cancelable = true})
    if #tos > 0 then
      event:setCostData(self, {tos = tos})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    local id = room:askToChooseCard(player, {target = to, flag = "he", skill_name = sijian.name})
    room:throwCard({id}, sijian.name, to, player)
  end,
})

sijian:addTest(function (room, me)
  local comp2 = room.players[2]
  FkTest.setNextReplies(me, {"1"})
  FkTest.runInRoom(function ()
    room:handleAddLoseSkills(me, sijian.name)
    room:obtainCard(comp2, 1)
    room:obtainCard(me, 2)
    room:throwCard({1}, "", me)
  end)
end)

Fk:loadTranslationTable{
  ["sijian"] = "死谏",
  [":sijian"] = "当你失去手牌后，若你没有手牌，你可弃置一名其他角色的一张牌。",

  ["#sijian-ask"] = "死谏：你可弃置一名其他角色的一张牌",

  ["$sijian2"] = "忠言逆耳啊！！",
  ["$sijian1"] = "且听我最后一言！",
}

return sijian
