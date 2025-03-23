local qiao = fk.CreateSkill{
  name = "ty_heg__qiao",
}
local H = require "packages/hegemony/util"
qiao:addEffect(fk.TargetConfirmed, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and
      not data.from:isNude() and player:usedSkillTimes(qiao.name, Player.HistoryTurn) < 2
      and not H.compareKingdomWith(data.from, player)
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, qiao.name, nil, "#ty_heg__qiao-invoke::"..data.from)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local from = data.from
    local id = room:askForCardChosen(player, from, "he", qiao.name)
    room:throwCard({id}, qiao.name, from, player)
    if not player:isNude() then
      room:askForDiscard(player, 1, 1, true, qiao.name, false)
    end
  end,
})

Fk:loadTranslationTable{
  ["ty_heg__qiao"] = "气傲",
  [":ty_heg__qiao"] = "每回合限两次，当你成为与你势力不同或未确定势力角色使用牌的目标后，你可弃置其一张牌，然后你弃置一张牌。",

  ["#ty_heg__qiao-invoke"] = "气傲：你可以弃置 %dest 一张牌，然后你弃置一张牌",

  ["$ty_heg__qiao1"] = "吾六十何为不受兵邪？",
  ["$ty_heg__qiao2"] = "芝性骄傲，吾独不为屈。",
}

return qiao
