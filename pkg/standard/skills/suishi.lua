local suishi = fk.CreateSkill{
  name = "suishi",
  tags = {Skill.Compulsory},
}
local H = require "packages/hegemony/util"
suishi:addEffect(fk.EnterDying, {
  mute = true,
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and target ~= player and data.killer and H.compareKingdomWith(data.killer, player)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:notifySkillInvoked(player, suishi.name, "drawcard")
    player:broadcastSkillInvoke(suishi.name, 1)
    player:drawCards(1, suishi.name)
  end,
})
suishi:addEffect(fk.Death, {
  mute = true,
  anim_type = "negative",
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(self) and target ~= player and H.compareKingdomWith(target, player)
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    room:notifySkillInvoked(player, suishi.name, "negative")
    player:broadcastSkillInvoke(suishi.name, 2)
    room:loseHp(player, 1, suishi.name)
  end
})

Fk:loadTranslationTable{
  ["suishi"] = "随势",
  [":suishi"] = "锁定技，①当其他角色因受到伤害而进入濒死状态时，若来源与你势力相同，你摸一张牌；②当其他角色死亡时，若其与你势力相同，你失去1点体力。",

  ["$suishi1"] = "一荣俱荣！",
  ["$suishi2"] = "一损俱损……",
}

return suishi
