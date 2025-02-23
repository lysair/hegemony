
local xiaoguo = fk.CreateSkill{
  name = "hs__xiaoguo",
}
xiaoguo:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target ~= player and player:hasSkill(self) and target.phase == Player.Finish and not player:isKongcheng()
  end,
  on_cost = function(self, event, target, player, data)
    local card = player.room:askForDiscard(player, 1, 1, true, self.name, true, ".|.|.|.|.|basic", "#hs__xiaoguo-invoke::"..target.id, true)
    if #card > 0 then
      event:setCostData(self, {cards = card})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:throwCard(event:getCostData(self).cards, self.name, player, player)
    if #room:askForDiscard(target, 1, 1, true, self.name, true, ".|.|.|.|.|equip", "#hs__xiaoguo-discard:"..player.id) == 0 then
      room:damage{
        from = player,
        to = target,
        damage = 1,
        skillName = self.name,
      }
    elseif not player.dead then
      player:drawCards(1, self.name)
    end
  end,
})

Fk:loadTranslationTable{
  ["hs__xiaoguo"] = "骁果",
  [":hs__xiaoguo"] = "其他角色的结束阶段，你可弃置一张基本牌，然后其选择一项：1.弃置一张装备牌，然后你摸一张牌；2.你对其造成1点伤害。",
  ["#hs__xiaoguo-invoke"] = "骁果：你可以弃置一张基本牌，%dest 需弃置一张装备牌，否则你对其造成1点伤害",
  ["#hs__xiaoguo-discard"] = "骁果：你需弃置一张装备牌，否则 %src 对你造成1点伤害",

  ["$hs__xiaoguo1"] = "三军听我号令，不得撤退！",
  ["$hs__xiaoguo2"] = "看我先登城头，立下首功！",
  ["~hs__yuejin"] = "箭疮发作，吾命休矣。",
}

return xiaoguo
