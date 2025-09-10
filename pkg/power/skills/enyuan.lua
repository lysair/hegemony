local enyuan = fk.CreateSkill{
  name = "ld__enyuan",
  tags = {Skill.Compulsory},
}
enyuan:addEffect(fk.TargetConfirmed, {
  mute = true,
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    if target ~= player or not player:hasSkill(enyuan.name) then return false end
    return data.card.trueName == "peach" and data.from ~= player and not data.from.dead
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:notifySkillInvoked(player, enyuan.name, "support")
    player:broadcastSkillInvoke(enyuan.name, 2)
    local from = data.from
    if from and not from.dead then
      room:doIndicate(player.id, {from.id})
      from:drawCards(1, enyuan.name)
    end
  end,
})
enyuan:addEffect(fk.Damaged, {
  mute = true,
  anim_type = "masochism",
  can_trigger = function(self, event, target, player, data)
    if target ~= player or not player:hasSkill(enyuan.name) then return false end
    return data.from and not data.from.dead
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:notifySkillInvoked(player, enyuan.name, "masochism")
    player:broadcastSkillInvoke(enyuan.name, 1)
    local from = data.from
    if from and not from.dead then
      room:doIndicate(player.id, {from.id})
      if from == player then
        room:loseHp(player, 1, enyuan.name)
      else
        local card = room:askToCards(from, {
          min_num = 1,
          max_num = 1,
          include_equip = false,
          skill_name = enyuan.name,
          prompt = "#ld__enyuan-give:"..player.id,
          cancelable = true,
        })
        if #card > 0 then
          room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonGive, enyuan.name, nil, false, player)
        else
          room:loseHp(from, 1, enyuan.name)
        end
      end
    end
  end,
})

Fk:loadTranslationTable{
  ["ld__enyuan"] = "恩怨",
  [":ld__enyuan"] = "锁定技，当你成为【桃】的目标后，若使用者不为你，其摸一张牌；当你受到伤害后，伤害来源需交给你一张手牌，否则失去1点体力。",

  ["#ld__enyuan-give"] = "恩怨：交给 %src 一张手牌，否则失去1点体力",

  ["$ld__enyuan1"] = "伤了我，休想全身而退！",
  ["$ld__enyuan2"] = "报之以李，还之以桃。",
}

return enyuan
