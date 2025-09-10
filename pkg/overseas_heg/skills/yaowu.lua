local yaowu = fk.CreateSkill{
  name = "os_heg__yaowu",
  tags = {Skill.Limited},
}
local H = require "packages/hegemony/util"
yaowu:addEffect(fk.Damage, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(yaowu.name) and
      player:usedSkillTimes(yaowu.name, Player.HistoryGame) == 0 and player:isFakeSkill(self)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:changeMaxHp(player, 2)
    if not player.dead then
      room:recover({
        who = player,
        num = 2,
        recoverBy = player,
        skillName = yaowu.name
      })
      player.tag["os_heg__yaowu"] = true
    end
  end,
})
yaowu:addEffect(fk.Deathed, {
  anim_type = "negative",
  can_trigger = function(self, event, target, player, data)
    return target == player and player.tag["os_heg__yaowu"]
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room.alive_players, function(p) return H.compareKingdomWith(p, player) end)
    if #targets == 0 then return end
    room:doIndicate(player.id, targets)
    room:sortByAction(targets)
    for _, p in ipairs(targets) do
      if not p.dead then
        room:loseHp(p, 1, yaowu.name)
      end
    end
  end,
})

Fk:loadTranslationTable{
  ["os_heg__yaowu"] = "耀武",
  [":os_heg__yaowu"] = "限定技，当你造成伤害后，若此武将处于暗置状态，你可明置此武将牌，加2点体力上限，回复2点体力，修改〖恃勇〗，且当你死亡后，与你势力相同的角色各失去1点体力。",
  ["#os_heg__yaowu_death"] = "耀武",

  ["$os_heg__yaowu1"] = "潘凤已被我斩了，谁还来领死！",
  ["$os_heg__yaowu2"] = "十八路诸侯？！哼！乌合之众。",
}

return yaowu
