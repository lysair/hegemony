local huoshui = fk.CreateSkill{
  name = "huoshui",
  tags = {Skill.Compulsory},
}

local H = require "packages/hegemony/util"

local addHuoshui = function(player)
  local room = player.room
  local targets = {}
  for _, p in ipairs(room:getOtherPlayers(player, false)) do
    room:setPlayerMark(p, "@@huoshui-turn", 1)
    room:addTableMark(p, MarkEnum.RevealProhibited .. "-turn", "m")
    room:addTableMark(p, MarkEnum.RevealProhibited .. "-turn", "d")
    table.insert(targets, p.id)
  end
  room:doIndicate(player.id, targets)
end

local removeHuoshui = function(player)
  local room = player.room
  for _, p in ipairs(room:getOtherPlayers(player, false)) do
    room:setPlayerMark(p, "@@huoshui-turn", 0)
    room:removeTableMark(p, MarkEnum.RevealProhibited .. "-turn", "m")
    room:removeTableMark(p, MarkEnum.RevealProhibited .. "-turn", "d")
  end
end

huoshui:addEffect(fk.TurnStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasShownSkill(self) and player.room.current == player
  end,
  on_use = function(self, event, target, player, data)
    addHuoshui(player)
  end,
})

huoshui:addEffect(fk.GeneralRevealed, {
  anim_type = "control",
  can_trigger = function (self, event, target, player, data)
    if target == player and player:hasSkill(self) and player.room.current == player then
      for _, v in pairs(data) do
        if table.contains(Fk.generals[v]:getSkillNameList(), self.name) then return true end
      end
    end
  end,
  on_use = function (self, event, target, player, data)
    addHuoshui(player)
  end
})

huoshui:addAcquireEffect(function (self, player, is_start)
  if player.room.current == player and player:hasShownSkill(huoshui.name) then
    addHuoshui(player)
  end
end)

huoshui:addLoseEffect(function (self, player, is_death)
  if player.room.current == player then
    removeHuoshui(player)
  end
end)
--[[ 
huoshui:addEffect(fk.Deathed, {
  anim_type = "control",
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(self, true, true) and target == player and player.room.current == player
  end,
  on_use = function (self, event, target, player, data)
    removeHuoshui(player)
  end
})
-- ]]
huoshui:addEffect(fk.CardUsing, {
  anim_type = "control",
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(self)and target == player and player.room.current == player and
      (data.card.trueName == "slash" or data.card.trueName == "archery_attack")
  end,
  on_use = function (self, event, target, player, data)
    local targets = table.filter(player.room.alive_players, function(p) return
      not H.compareKingdomWith(p, player) and not H.allGeneralsRevealed(p)
    end)
    if #targets > 0 then
      data.disresponsiveList = data.disresponsiveList or {}
      for _, p in ipairs(targets) do
        table.insertIfNeed(data.disresponsiveList, p)
      end
    end
  end
})


Fk:loadTranslationTable{
  ["huoshui"] = "祸水",
  [":huoshui"] = "锁定技，你的回合内：1.其他角色不能明置其武将牌；2.当你使用【杀】或【万箭齐发】时，你令此牌不能被与你势力不同且有暗置武将牌的角色响应。",

  ["@@huoshui-turn"] = "祸水",

  ["$huoshui1"] = "走不动了吗？" ,
  ["$huoshui2"] = "别走了，再玩一会嘛~" ,
}

return huoshui
