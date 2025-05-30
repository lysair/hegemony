local ruilve = fk.CreateSkill {
  name = "zq_heg__ruilve",
  attached_skill_name = "zq_heg__ruilve_other&",
}

Fk:loadTranslationTable {
  ["zq_heg__ruilve"] = "睿略",
  [":zq_heg__ruilve"] = "未确定势力的其他角色出牌阶段限一次，其可展示并交给你一张伤害类牌，然后其摸一张牌。",

  ["$zq_heg__ruilve1"] = "司马当兴，其兴在吾。",
  ["$zq_heg__ruilve2"] = "吾承父志，故知军事、通谋略。",
}

local ruilve_spec = {
  can_refresh = function(self, event, target, player, data)
    return target == player
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local players = room.alive_players
    local simashis = table.filter(players, function(p) return p:hasShownSkill(ruilve.name) end)
    local targets_map = {}
    for _, p in ipairs(players) do
      local will_attach = false
      for _, pid in ipairs(simashis) do
        if (p ~= pid and p.kingdom == "unknown") then
          will_attach = true
          break
        end
      end
      targets_map[p] = will_attach
    end
    for p, v in pairs(targets_map) do
      if v ~= p:hasSkill("zq_heg__ruilve_other&") then
        room:handleAddLoseSkills(p, v and ruilve.attached_skill_name or "-" .. ruilve.attached_skill_name, nil, false,
          true)
      end
    end
  end,
}

ruilve:addEffect(fk.AfterPropertyChange, ruilve_spec)
ruilve:addEffect(fk.GeneralRevealed, ruilve_spec)
ruilve:addEffect(fk.GeneralHidden, ruilve_spec)
ruilve:addEffect(fk.Deathed, ruilve_spec)
local addLoseEffect = function(self, player, _)
  local room = player.room
  for _, p in ipairs(room.alive_players) do
    if p ~= player and p.kingdom == "unknown" then
      room:handleAddLoseSkills(p, ruilve.attached_skill_name, nil, false, true)
    end
  end
end
ruilve:addAcquireEffect(addLoseEffect)
ruilve:addLoseEffect(addLoseEffect)

return ruilve
