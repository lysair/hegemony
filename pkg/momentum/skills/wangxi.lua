local wangxi = fk.CreateSkill{
  name = "wangxi",
}
local wangxi_times = function(_, _, _, _, data)
  return data.damage
end
local wangxi_use = function(self, event, _, player, _)
  local room = player.room
  local tos = event:getCostData(self).tos
  for _, to in ipairs(tos) do
    if not to.dead then
      room:drawCards(to, 1, wangxi.name)
    end
  end
end
wangxi:addEffect(fk.Damage, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(wangxi.name) and player ~= data.to and not data.to.dead
  end,
  trigger_times = wangxi_times,
  on_cost = function(self, event, target, player, data)
    if player.room:askToSkillInvoke(player, {skill_name = wangxi.name, propmt = "#wangxi-invoke::"..data.to.id}) then
      local tos = {player, data.to}
      player.room:sortByAction(tos)
      event:setCostData(self, { tos = tos })
      return true
    end
  end,
  on_use = wangxi_use
})
wangxi:addEffect(fk.Damaged, {
  anim_type = "masochism",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(wangxi.name) and player ~= data.from and data.from and not data.from.dead
  end,
  trigger_times = wangxi_times,
  on_cost = function(self, event, target, player, data)
    if player.room:askToSkillInvoke(player, {skill_name = wangxi.name, propmt = "#wangxi-invoke::"..data.from.id}) then
      local tos = {data.from, player}
      player.room:sortByAction(tos)
      event:setCostData(self, { tos = tos })
      return true
    end
  end,
  on_use = wangxi_use
})

wangxi:addTest(function (room, me)
  local comp2 = room.players[2] ---@type ServerPlayer
  FkTest.runInRoom(function() room:handleAddLoseSkills(me, wangxi.name) end)
  FkTest.setNextReplies(me, {"1", "1", "1", "1", "1", "1"})
  FkTest.runInRoom(function ()
    room:damage{from = comp2, to = me, damage = 1}
    room:damage{from = me, to = comp2, damage = 1}
  end)
  lu.assertEquals(me:getHandcardNum(), 2)
  lu.assertEquals(comp2:getHandcardNum(), 2)
  FkTest.runInRoom(function ()
    room:damage{from = me, to = comp2, damage = 2}
    room:damage{from = me, to = me, damage = 1}
  end)
  lu.assertEquals(me:getHandcardNum(), 4)
  lu.assertEquals(comp2:getHandcardNum(), 4)
end)

Fk:loadTranslationTable{
  ["wangxi"] = "忘隙",
  [":wangxi"] = "当你对其他角色造成1点伤害后，或当你受到其他角色造成的1点伤害后，你可以与其各摸一张牌。",
  ["#wangxi-invoke"] = "忘隙：你可以与 %dest 各摸一张牌",

  ["$wangxi1"] = "大丈夫，何拘小节。",
  ["$wangxi2"] = "前尘往事，莫再提起。",
}

return wangxi
