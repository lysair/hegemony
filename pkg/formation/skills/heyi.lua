local H = require "packages/hegemony/util"
local heyi = fk.CreateSkill{
  name = "heyi",
  tags = {Skill.Compulsory},
}
heyi:addEffect("arraysummon", {
  array_type = "formation",
})
--[[ heyi:addEffect{
  refresh_events = {fk.TurnStart, fk.GeneralRevealed, fk.EventAcquireSkill, "fk.RemoveStateChanged", fk.EventLoseSkill, fk.GeneralHidden, fk.Deathed},
  can_refresh = function(self, event, target, player, data)
    if event == fk.EventLoseSkill then return data == heyi
    elseif event == fk.GeneralHidden then return player == target
    else return player:hasShownSkill(self.name, true, true) end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    for _, p in ipairs(room.alive_players) do
      local ret = #room.alive_players > 3 and player:hasSkill(self) and H.inFormationRelation(p, player)
      room:handleAddLoseSkills(p, ret and 'feiying' or "-feiying", nil, false, true)
    end
  end,
}
heyi:addRelatedSkill(heyiTrig) ]]

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

