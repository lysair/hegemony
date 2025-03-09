local yicheng = fk.CreateSkill{
  name = "yicheng",
}
local H = require "packages/hegemony/util"

local yicheng_spec = {
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {skill_name = yicheng.name, prompt = "#yicheng-ask::" .. target.id})
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:doIndicate(player.id, {target.id})
    target:drawCards(1, yicheng.name)
    if not target.dead then
      room:askForDiscard(target, 1, 1, true, yicheng.name, false)
    end
  end
}

yicheng:addEffect(fk.TargetConfirmed, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(yicheng.name) and H.compareKingdomWith(target, player) and data.card.trueName == "slash"
  end,
  on_cost = yicheng_spec.on_cost,
  on_use = yicheng_spec.on_use
})
yicheng:addEffect(fk.TargetSpecified, {
  anim_type = "defensive",
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(yicheng.name) and H.compareKingdomWith(target, player) and data.card.trueName == "slash" and data.firstTarget
  end,
  on_cost = yicheng_spec.on_cost,
  on_use = yicheng_spec.on_use
})

yicheng:addTest(function (room, me)
  local sameKingdom = table.find(room.alive_players, function (p) return p ~= me and H.compareKingdomWith(p, me) end)
  if sameKingdom then
    FkTest.setNextReplies(me, {"1"})
    local comp2 = room.players[2]
    FkTest.runInRoom(function ()
      room:handleAddLoseSkills(me, yicheng.name)
      room:useVirtualCard("slash", nil, me, {comp2})
    end)

    FkTest.setNextReplies(me, {"1"})
    FkTest.runInRoom(function ()
      room:useVirtualCard("slash", nil, comp2, {sameKingdom})
    end)
  end
end)

Fk:loadTranslationTable{
  ["yicheng"] = "疑城",
  [":yicheng"] = "当与你势力相同的角色使用【杀】指定目标后或成为【杀】的目标后，你可令其摸一张牌，然后其弃置一张牌。",

  ["#yicheng-ask"] = "疑城：你可令 %dest 摸一张牌，然后其弃置一张牌",

  ["$yicheng1"] = "不怕死，就尽管放马过来！",
  ["$yicheng2"] = "待末将布下疑城，以退曹贼。",
}

return yicheng
