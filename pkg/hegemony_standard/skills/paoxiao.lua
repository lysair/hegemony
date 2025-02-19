local paoxiao = fk.CreateSkill{
  name = "hs__paoxiao",
  tags = {Skill.Compulsory},
}
local H = require "packages/hegemony/util"
paoxiao:addEffect('targetmod', {
  bypass_times = function(self, player, skill, scope, card)
    if card and player:hasSkill(paoxiao.name) and skill.trueName == "slash_skill"
      and scope == Player.HistoryPhase then
      return true
    end
  end,
})
paoxiao:addEffect(fk.CardUsing, {
  name = "#hs__paoxiaoTrigger",
  anim_type = "offensive",
  visible = false,
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    if target ~= player or not player:hasSkill(paoxiao.name) or data.card.trueName ~= "slash" then return false end
    local events = player.room.logic:getEventsOfScope(GameEvent.UseCard, 2, function(e)
      local use = e.data[1]
      return use.from == player.id and use.card.trueName == "slash"
    end, Player.HistoryTurn)
    return #events == 2 and events[2].id == player.room.logic:getCurrentEvent().id
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, self.name)
  end,
})
paoxiao:addEffect(fk.CardUsing, {
  can_refresh = function(self, event, target, player, data)
    return player == target and player:hasSkill(paoxiao.name) and data.card.trueName == "slash" and player:usedCardTimes("slash") > 1
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke("hs__paoxiao")
    room:doAnimate("InvokeSkill", {
      name = "paoxiao",
      player = player.id,
      skill_type = "offensive",
    })
  end,
})
paoxiao:addEffect(fk.TargetSpecified, {
  can_refresh = function (self, event, target, player, data)
    local room = player.room
    return player == target and data.card.trueName == "slash" and player:hasSkill("hs__paoxiao")
      and H.getHegLord(room, player) and H.getHegLord(room, player):hasSkill("shouyue") and data.to:isAlive()
  end,
  on_refresh = function (self, event, target, player, data)
    player.room:addPlayerMark(data.to, fk.MarkArmorNullified)
    data.extra_data = data.extra_data or {}
    data.extra_data.hsPaoxiaoNullifiled = data.extra_data.hsPaoxiaoNullifiled or {}
    data.extra_data.hsPaoxiaoNullifiled[tostring(data.to.id)] = (data.extra_data.hsPaoxiaoNullifiled[tostring(data.to.id)] or 0) + 1
  end,
})
paoxiao:addEffect(fk.CardUseFinished, {
  can_refresh = function (self, event, target, player, data)
    return player == target and (data.extra_data or {}).hsPaoxiaoNullifiled
  end,
  on_refresh = function (self, event, target, player, data)
    for key, num in pairs(data.extra_data.hsPaoxiaoNullifiled) do
      local p = player.room:getPlayerById(tonumber(key))
      if p:getMark(fk.MarkArmorNullified) > 0 then
        player.room:removePlayerMark(p, fk.MarkArmorNullified, num)
      end
    end
    data.hsPaoxiaoNullifiled = nil
  end,
})

Fk:loadTranslationTable{
  ["hs__paoxiao"] = "咆哮", -- 动态描述
  [":hs__paoxiao"] = "锁定技，你使用【杀】无次数限制。当你于一个回合内使用第二张【杀】时，你摸一张牌。",
  ["#hs__paoxiaoTrigger"] = "咆哮",
  ["$hs__paoxiao1"] = "啊~~~",
  ["$hs__paoxiao2"] = "燕人张飞在此！",
}

return paoxiao
