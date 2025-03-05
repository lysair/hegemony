
local yinghun = fk.CreateSkill{
  name = "hs__yinghun",
}
yinghun:addEffect(fk.EventPhaseStart, {
  anim_type = "drawcard",
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(yinghun.name) and player.phase == Player.Start
  end,
  on_cost = function(self, event, target, player, data)
    local to = player.room:askToChoosePlayers(player, {targets = player.room:getOtherPlayers(player, false), max_num = 1, min_num = 1,
      prompt = "#yinghun-choose:::"..player:getLostHp()..":"..player:getLostHp(), skill_name = yinghun.name, cancelable = true})
    if #to > 0 then
      event:setCostData(self, {tos = to})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    room:doIndicate(player.id, {to.id})
    local n = player:getLostHp()
    local choice = room:askForChoice(player, {"#yinghun-draw:::" .. n,  "#yinghun-discard:::" .. n}, yinghun.name)
    if choice:startsWith("#yinghun-draw") then
      player:broadcastSkillInvoke(yinghun.name, 1)
      room:notifySkillInvoked(player, yinghun.name, "support")
      to:drawCards(n, yinghun.name)
      if to:isAlive() then room:askForDiscard(to, 1, 1, true, yinghun.name, false) end
    else
      player:broadcastSkillInvoke(yinghun.name, 2)
      room:notifySkillInvoked(player, yinghun.name, "control")
      to:drawCards(1, yinghun.name)
      if to:isAlive() then room:askForDiscard(to, n, n, true, yinghun.name, false) end
    end
  end,
})

Fk:loadTranslationTable{
  ["hs__yinghun"] = "英魂",
  [":hs__yinghun"] = "准备阶段，你可选择一名其他角色并选择一项：1.令其摸X张牌，然后弃置一张牌；2.令其摸一张牌，然后弃置X张牌（X为你已损失的体力值）。",

  ["$hs__yinghun1"] = "以吾魂魄，保佑吾儿之基业。",
  ["$hs__yinghun2"] = "不诛此贼三族，则吾死不瞑目！",
}

return yinghun
