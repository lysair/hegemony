local tribladeSkill = fk.CreateSkill{
  name = "#triblade_skill",
  attached_equip = "triblade",
}
tribladeSkill:addEffect(fk.Damage, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.card and data.card.trueName == "slash" and not data.to.dead and not data.chain and
      not player:isKongcheng() and table.find(player.room.alive_players, function(p) return data.to:distanceTo(p) == 1 and p ~= player end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.map(table.filter(room.alive_players, function(p)
      return data.to:distanceTo(p) == 1 and p ~= player end), Util.IdMapper)
    if #targets == 0 then return false end
    local to, card = room:askForChooseCardAndPlayers(player, targets, 1, 1, ".|.|.|hand", "#triblade-invoke::"..data.to.id, "triblade", true)
    if #to > 0 then
      event:setCostData(self, {tos = to, cards = {card} })
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    room:notifySkillInvoked(player, "triblade", "offensive")
    room:throwCard(event:getCostData(self).cards, "triblade", player, player)
    room:damage{
      from = player,
      to = room:getPlayerById(to),
      damage = 1,
      skillName = "triblade",
    }
  end
})

Fk:loadTranslationTable{
  ["triblade"] = "三尖两刃刀",
  ["#triblade_skill"] = "三尖两刃刀",
  [":triblade"] = "装备牌·武器<br/><b>攻击范围</b>：３ <br/><b>武器技能</b>：当你使用【杀】对目标角色造成伤害后，你可以弃置一张手牌，"..
  "对其距离1的一名其他角色造成1点伤害。",
  ["#triblade-invoke"] = "三尖两刃刀：你可以弃置一张手牌，对 %dest 距离1的一名其他角色造成1点伤害",
}

return tribladeSkill
