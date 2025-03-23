local gongxiu = fk.CreateTriggerSkill{
  name = "ty_heg__gongxiu",
  anim_type = "offensive",
  events = {fk.DrawNCards},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.n > 0
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, data, "#ty_heg__gongxiu_" .. player:getMark("ty_heg__gongxiu") .. "-ask:::" .. player.maxHp)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    data.n = data.n - 1
    local choices = {}
    if player:getMark("ty_heg__gongxiu") ~= 1 then
      table.insert(choices, "ty_heg__gongxiu_draw:::" .. player.maxHp)
    end
    if player:getMark("ty_heg__gongxiu") ~= 2 then
      table.insert(choices, "ty_heg__gongxiu_discard:::" .. player.maxHp)
    end 
    local choice = room:askForChoice(player, choices, self.name, "#ty_heg__gongxiu-choice")
    local targets, tos
    if choice:startsWith("ty_heg__gongxiu_draw") then
      room:setPlayerMark(player, "ty_heg__gongxiu", 1)
      targets = table.map(room.alive_players, Util.IdMapper)
      tos = room:askForChoosePlayers(player, targets, 1, player.maxHp, "#ty_heg__gongxiu_draw-choose:::" .. player.maxHp, self.name, false)
      room:sortPlayersByAction(tos)
      for _, id in ipairs(tos) do
        local p = room:getPlayerById(id)
        if not p.dead then
          p:drawCards(1, self.name)
        end
      end
    else
      room:setPlayerMark(player, "ty_heg__gongxiu", 2)
      targets = table.map(table.filter(room.alive_players,  function(p) return not p:isNude() end), Util.IdMapper)
      tos = room:askForChoosePlayers(player, targets, 1, player.maxHp, "#ty_heg__gongxiu_discard-choose:::" .. player.maxHp, self.name, false)
      room:sortPlayersByAction(tos)
      for _, id in ipairs(tos) do
        local p = room:getPlayerById(id)
        if not p.dead and not p:isNude() then
          room:askForDiscard(p, 1, 1, true, self.name, false)
        end
      end
    end
  end,
}