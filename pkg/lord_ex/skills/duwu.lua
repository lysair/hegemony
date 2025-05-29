local duwu = fk.CreateSkill{
    name = "ld__duwu",
    tags = { Skill.Limited },
}

Fk:loadTranslationTable{
    ["ld__duwu"] = "黩武",
    [":ld__duwu"] = "限定技，出牌阶段，你可以选择一个“军令”，你对你攻击范围内所有与你势力不同或未确定势力的角色发起此“军令”，若其不执行，你对其造成1点伤害并摸一张牌。"..
    "此“军令”结算后，若存在进入濒死状态被救回的角色，你失去1点体力。",

    ["#ld__duwu-active"] = "发动 黩武，令攻击范围内所有与你势力不同的角色执行“军令”",

    ["$ld__duwu1"] = "破曹大功，正在今朝！",
    ["$ld__duwu2"] = "全力攻城！言退者，斩！",
}

local H = require "packages/hegemony/util"

duwu:addEffect("active",{
  anim_type = "big",
  prompt = "#ld__duwu-active",
  can_use = function(self, player)
    return player:usedSkillTimes(duwu.name, Player.HistoryGame) == 0
  end,
  card_filter = Util.FalseFunc,
  on_use = function (self, room, effect)
    local player = effect.from
    local index = H.startCommand(player, duwu.name)
    local targets =table.filter(room.alive_players, function(p) return not H.compareKingdomWith(player, p) and player:inMyAttackRange(p)  end)
    if #targets > 0 then
      room:doIndicate(player.id, targets)
      room:sortByAction(targets)
      local x = 0
      local events = room.logic.event_recorder[GameEvent.Dying]
      if events then
        x = #events
      end
      for _, p in ipairs(targets) do
        if player.dead then break end
        if not p.dead and not H.doCommand(p, duwu.name, index, player) then
          room:damage{
            from = player,
            to = p,
            damage = 1,
            skillName = duwu.name,
          }
          if not player.dead then
            player:drawCards(1, duwu.name)
          end
        end
      end
      if not player.dead then
        events = room.logic.event_recorder[GameEvent.Dying]
        if events then
          for i = x + 1, #events, 1 do
            if not events[i].data[1].who.dead then
              room:loseHp(player, 1, duwu.name)
              break
            end
          end
        end
      end
    end
  end,
})

return duwu