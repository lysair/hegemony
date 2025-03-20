local yongjue = fk.CreateSkill{
  name = "yongjue",
}
local H = require "packages/hegemony/util"
yongjue:addEffect(fk.CardUseFinished, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(yongjue.name) and H.compareKingdomWith(target, player) and not target.dead and data.card.trueName == "slash" and target.phase == Player.Play then
      local events = target.room.logic:getEventsOfScope(GameEvent.UseCard, 1, function(e)
        local use = e.data
        return use.from == target
      end, Player.HistoryPhase)
      if #events == 1 and events[1].id == target.room.logic:getCurrentEvent().id then
        local cards = Card:getIdList(data.card)
        return #cards > 0 and table.every(cards, function(id) return target.room:getCardArea(id) == Card.Processing end)
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    return target.room:askForSkillInvoke(target, yongjue.name, nil, "#yongjue-invoke:::" .. data.card:toLogString())
  end,
  on_use = function(self, event, target, player, data)
    local room = target.room
    -- room:doIndicate(player.id, {target.id})
    room:obtainCard(target, data.card, true, fk.ReasonJustMove)
  end,
})

Fk:loadTranslationTable{
  ["yongjue"] = "勇决",
  [":yongjue"] = "当与你势力相同的角色于其出牌阶段内使用【杀】结算后，若此【杀】为其于此阶段内使用的第一张牌，其可获得此【杀】对应的所有实体牌。",

  ["#yongjue-invoke"] = "勇决：你可以获得此%arg",

  ["$yongjue1"] = "能救一个是一个！",
  ["$yongjue2"] = "扶幼主，成霸业！",
}

return yongjue
