local qingyin = fk.CreateSkill {
  name = "ld__qingyin",
  tags = { Skill.Limited },
}

Fk:loadTranslationTable {
  ["ld__qingyin"] = "清隐",
  [":ld__qingyin"] = "限定技，出牌阶段，你可移除此武将牌，然后与你势力相同的角色将体力回复至体力上限。",

  ["$ld__qingyin1"] = "功成身退，再不问世间诸事。",
  ["$ld__qingyin2"] = "天下既定，我亦当遁迹匿踪，颐养天年矣。",
}

local H = require "packages/hegemony/util"

qingyin:addEffect("active", {
  anim_type = "drawcard",
  can_use = function(self, player)
    return player:usedSkillTimes(qingyin.name, Player.HistoryGame) == 0
  end,
  target_filter = Util.FalseFunc,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = effect.from
    local isDeputy = H.inGeneralSkills(player, qingyin.name)
    if isDeputy then
      H.removeGeneral(player, isDeputy == "d")
    end
    local targets = table.filter(room.alive_players, function(p) return H.compareKingdomWith(p, player) end)
    room:sortByAction(targets)
    room:recover({
      who = player,
      num = player.maxHp - player.hp,
      recoverBy = player,
      skillName = qingyin.name
    })
    for _, p in ipairs(targets) do
      if not p.dead and p:isWounded() then
        room:recover({
          who = p,
          num = p.maxHp - p.hp,
          recoverBy = player,
          skillName = qingyin.name,
        })
      end
    end
  end,
})

return qingyin
