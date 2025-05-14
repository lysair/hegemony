local H = require "packages/hegemony/util"
local heyi = fk.CreateSkill{
  name = "heyi",
  tags = {Skill.Compulsory},
}
heyi:addEffect("arraysummon", {
  array_type = "formation",
})

local can_refresh = function(self, event, target, player, data)
  return player:hasShownSkill(heyi.name, true, true)
end
local on_refresh = function(self, event, target, player, data)
  local room = player.room
  for _, p in ipairs(room.alive_players) do
    local ret = #room.alive_players > 3 and player:hasSkill(heyi.name) and H.inFormationRelation(p, player)
    room:handleAddLoseSkills(p, ret and 'feiying' or "-feiying", nil, false, true)
  end
end

heyi:addEffect(fk.TurnStart, {
  can_refresh = can_refresh,
  on_refresh = on_refresh,
})
heyi:addEffect(fk.GeneralRevealed, {
  can_refresh = can_refresh,
  on_refresh = on_refresh,
})
heyi:addEffect(fk.EventLoseSkill, {
  can_refresh = function(self, event, target, player, data)
    return data.name == heyi.name
  end,
  on_refresh = on_refresh
})
heyi:addEffect(fk.GeneralHidden, {
  can_refresh = function(self, event, target, player, data)
    return player == target
  end,
  on_refresh = on_refresh
})
heyi:addEffect(fk.EventAcquireSkill, {
  can_refresh = can_refresh,
  on_refresh = on_refresh
})
heyi:addEffect(H.PlayerRemoved, {
  can_refresh = can_refresh,
  on_refresh = on_refresh
})

heyi:addTest(function (room, me)
  FkTest.runInRoom(function ()
    room:handleAddLoseSkills(me, heyi.name)
  end)
end)

Fk:loadTranslationTable{
  ["heyi"] = "鹤翼",
  [":heyi"] = "阵法技，与你处于同一<a href='heg_formation'>队列</a>的角色拥有〖飞影〗。",
}
return heyi

