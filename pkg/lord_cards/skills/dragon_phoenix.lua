local dragonPhoenixSkill = fk.CreateSkill{
  name = "#dragon_phoenix_skill",
  attached_equip = "dragon_phoenix",
}
dragonPhoenixSkill:addEffect(fk.TargetSpecified, {
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(dragonPhoenixSkill.name) then return end
    if target == player and data.card and data.card.trueName == "slash" then
      return not data.to:isNude()
    end
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {skill_name = dragonPhoenixSkill.name, prompt = "#dragon_phoenix-slash::" .. data.to.id})
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    -- room:setEmotion(player, "./packages/hegemony/image/anim/dragon_phoenix")
    room:askForDiscard(data.to, 1, 1, true, dragonPhoenixSkill.name, false, ".", "#dragon_phoenix-invoke")
  end,
})
dragonPhoenixSkill:addEffect(fk.EnterDying, {
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(dragonPhoenixSkill.name) and data.damage and data.damage.from == player and
      not target:isKongcheng() and player.room.logic:damageByCardEffect() and data.damage.card.trueName == "slash"
  end,
  on_cost = function (self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {skill_name = dragonPhoenixSkill.name, prompt = "#dragon_phoenix-dying::" .. target.id})
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    -- room:setEmotion(player, "./packages/hegemony/image/anim/dragon_phoenix")
    local card = room:askForCardChosen(player, target, "h", dragonPhoenixSkill.name)
    room:obtainCard(player, card, false, fk.ReasonPrey)
  end
})

dragonPhoenixSkill:addTest(function (room, me)
  local comp2 = room.players[2]
  local card = room:printCard("dragon_phoenix")
  FkTest.setNextReplies(me, {"1"})
  FkTest.runInRoom(function ()
    room:useCard{from = me, tos = {me}, card = card}
    room:obtainCard(comp2, 36, true)
    room:useVirtualCard("slash", nil, me, comp2)
  end)
  lu.assertEquals(me:getAttackRange(), 2)
  lu.assertIsTrue(comp2:isKongcheng())

  --local peach = room:printCard("peach")
  FkTest.setNextReplies(me, {"1", "1"})
  FkTest.runInRoom(function ()
    room:loseHp(comp2, 2)
    room:obtainCard(comp2, 36, true)
    room:obtainCard(comp2, 56, true)
    --room:obtainCard(me, peach)
    room:useVirtualCard("slash", nil, me, comp2)
  end)
end)

Fk:loadTranslationTable{
  ["dragon_phoenix"] = "飞龙夺凤",
  [":dragon_phoenix"] = "装备牌·武器<br/><b>攻击范围</b>：２ <br/><b>武器技能</b>：①当你使用【杀】指定目标后，你可令目标弃置一张牌。②当一名角色因执行你使用的【杀】的效果而受到你造成的伤害而进入濒死状态后，你可获得其一张手牌。",
  ["#dragon_phoenix_skill"] = "飞龙夺凤",
  ["#dragon_phoenix-slash"] = "飞龙夺凤：你可令 %dest 弃置一张牌",
  ["#dragon_phoenix-dying"] = "飞龙夺凤：你可获得 %dest 一张手牌",
  ["#dragon_phoenix-invoke"] = "受到“飞龙夺凤”影响，你需弃置一张牌",
}

return dragonPhoenixSkill
