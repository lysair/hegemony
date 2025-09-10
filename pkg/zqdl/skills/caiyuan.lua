local caiyuan = fk.CreateSkill{
  name = "zq_heg__caiyuan",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["zq_heg__caiyuan"] = "才媛",
  [":zq_heg__caiyuan"] = "锁定技，若你的武将牌均明置：回合开始时，你摸两张牌；当你受到伤害后，你暗置此武将牌。",
}

local H = require "packages/hegemony/util"

caiyuan:addEffect(fk.TurnStart, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(caiyuan.name) and H.allGeneralsRevealed(player)
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(2, caiyuan.name)
  end,
})

caiyuan:addEffect(fk.Damaged, {
  anim_type = "masochism",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(caiyuan.name) and H.allGeneralsRevealed(player)
  end,
  on_use = function(self, event, target, player, data)
    H.hideBySkillName(player, caiyuan.name)
  end,
})

caiyuan:addTest(function(room, me)
  local comp2 = room.players[2]
end)

return caiyuan

