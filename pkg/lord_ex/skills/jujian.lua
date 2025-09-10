local jujian = fk.CreateSkill {
  name = "ld__jujian",
  tags = { Skill.DeputyPlace, Skill.Compulsory },
}

Fk:loadTranslationTable {
  ["ld__jujian"] = "举荐",
  [":ld__jujian"] = "副将技，锁定技，此武将牌上单独的阴阳鱼个数-1。当与你势力相同的角色进入濒死阶段时，你令其将体力回复至1点，然后你变更副将。",

  ["@@ld__jujian_change_before"] = "举荐 已变更",

  ["$ld__jujian1"] = "开言纳谏，社稷之福。",
  ["$ld__jujian2"] = "如此如此，敌军自破！",
}

local H = require "packages/hegemony/util"

jujian:addEffect(fk.EnterDying, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(jujian.name) and H.compareKingdomWith(player, target) and target.dying and
    player:getMark("@@ld__jujian_change_before") == 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if not target.dead then
      room:recover({
        who = target,
        num = math.min(1, target.maxHp) - target.hp,
        recoverBy = player,
        skillName = jujian.name,
      })
      room:setPlayerMark(player, "@@ld__jujian_change_before", 1)
      H.transformGeneral(player.room, player, false, false)
    end
  end,
})

return jujian
