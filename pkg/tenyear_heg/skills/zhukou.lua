local zhukou = fk.CreateTriggerSkill{
  name = "ty_heg__zhukou",
  anim_type = "offensive",
  events = {fk.Damage},
  can_trigger = function(self, event, target, player, data)
    if not (target == player and player:hasSkill(self)) then return end
    local room = player.room
    if room.current and room.current.phase == Player.Play then
      local damage_event = room.logic:getCurrentEvent()
      if not damage_event then return false end
      local events = room.logic:getActualDamageEvents(1, function(e)
        return e.data[1].from == player
      end, Player.HistoryPhase)
      if #events > 0 and damage_event.id == events[1].id then
        local n = #room.logic:getEventsOfScope(GameEvent.UseCard, 999, function(e)
          return e.data[1].from == player.id
        end, Player.HistoryTurn)
        if n > 0 then
          self.cost_data = n
          return true
        end
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, data, "#ty_heg__zhukou:::" .. self.cost_data)
  end,
  on_use = function(self, event, target, player, data)
    local n = self.cost_data
    player:drawCards(math.min(5, n), self.name)
  end,
}
