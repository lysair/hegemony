local tanfeng = fk.CreateSkill{
  name = "os_heg__tanfeng",
}
local H = require "packages/hegemony/util"
tanfeng:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(tanfeng.name) and
      player.phase == Player.Start and table.find(player.room.alive_players, function(p) return
        not H.compareKingdomWith(p, player) and not p:isAllNude()
      end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local availableTargets = table.filter(room.alive_players, function(p)
        return not H.compareKingdomWith(p, player) and not p:isAllNude() -- not willBeFriendWith，救命！
      end)
    if #availableTargets == 0 then return false end
    local tos = room:askToChoosePlayers(player, {
      targets = availableTargets,
      min_num = 1,
      max_num = 1,
      propmt = "#os_heg__tanfeng-ask",
      skill_name = tanfeng.name,
      cancelable = true
    })
    if #tos > 0 then
      event:setCostData(self, {tos = tos})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    target = event:getCostData(self).tos[1]
    local cid = room:askForCardChosen(player, target, "hej", tanfeng.name)
    room:throwCard({cid}, tanfeng.name, target, player)
    local choices = {"os_heg__tanfeng_damaged::" .. player.id, "Cancel"}
    local slash = Fk:cloneCard("slash")
    slash.skillName = tanfeng.name
    local choice = room:askForChoice(target, choices, tanfeng.name, nil)
    if choice ~= "Cancel" then
      room:damage{
        from = player,
        to = target,
        damage = 1,
        damageType = fk.FireDamage,
        skillName = tanfeng.name,
      }
      if not (target.dead or player.dead) then
        local phases = {"phase_judge", "phase_draw", "phase_play", "phase_discard", "phase_finish"}
        choice = room:askToChoice(target, {choices = phases, prompt = "#os_heg__tanfeng-skip:" .. player.id, skill_name = tanfeng.name})
        player:skip(Util.PhaseStrMapper(choice))
      end
    end
  end,
})

Fk:loadTranslationTable{
  ["os_heg__tanfeng"] = "探锋",
  [":os_heg__tanfeng"] = "准备阶段开始时，你可弃置一名没有势力或势力与你不同的角色区域内的一张牌，然后其选择是否受到你造成的1点火焰伤害，令你跳过一个阶段（判定阶段，摸牌阶段，出牌阶段，弃牌阶段或结束阶段）。",

  ["#os_heg__tanfeng-ask"] = "探锋：你可选择一名其他势力角色，弃置其区域内的一张牌", -- 留一下
  ["os_heg__tanfeng_damaged"] = "受到%dest造成的1点火焰伤害，令其跳过一个阶段",
  ["#os_heg__tanfeng-skip"] = "探锋：令 %src 跳过此回合的一个阶段",

  ["$os_heg__tanfeng1"] = "探敌薄防之地，夺敌不备之间。",
  ["$os_heg__tanfeng2"] = "探锋之锐，以待进取之机。",
}

return tanfeng
