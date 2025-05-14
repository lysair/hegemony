local tianfu = fk.CreateSkill{
  name = "tianfu",
  tags = {Skill.Compulsory, Skill.MainPlace},
}
local H = require "packages/hegemony/util"

tianfu:addEffect("arraysummon", {
  array_type = "formation",
})

local can_refresh = function(self, event, target, player, data)
  return player:hasShownSkill(tianfu.name, true, true)
end
local on_refresh = function(self, event, target, player, data)
  local room = player.room
  local ret = H.inFormationRelation(room.current, player) and #room.alive_players > 3 and player:hasSkill(tianfu.name)
  room:handleAddLoseSkills(player, ret and 'ld__kanpo' or "-ld__kanpo", nil, false, true)
end

tianfu:addEffect(fk.TurnStart, {
  can_refresh = can_refresh,
  on_refresh = on_refresh,
})
tianfu:addEffect(fk.GeneralRevealed, {
  can_refresh = can_refresh,
  on_refresh = on_refresh,
})
tianfu:addEffect(fk.EventLoseSkill, {
  can_refresh = function(self, event, target, player, data)
    return data.name == tianfu.name
  end,
  on_refresh = on_refresh
})
tianfu:addEffect(fk.GeneralHidden, {
  can_refresh = function(self, event, target, player, data)
    return player == target
  end,
  on_refresh = on_refresh
})
tianfu:addEffect(fk.EventAcquireSkill, {
  can_refresh = can_refresh,
  on_refresh = on_refresh
})
tianfu:addEffect(H.PlayerRemoved, {
  can_refresh = can_refresh,
  on_refresh = on_refresh
})

Fk:loadTranslationTable{
  ["tianfu"] = "天覆",
  [":tianfu"] = "主将技，阵法技，你于与你处于同一<a href='heg_formation'>队列</a>的角色的回合内拥有〖看破〗。",
}
return tianfu
