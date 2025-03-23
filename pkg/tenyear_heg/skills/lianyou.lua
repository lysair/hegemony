local lianyou = fk.CreateTriggerSkill{
  name = "ty_heg__lianyou",
  anim_type = "control",
  events = {fk.Death},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self, false, true)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local targets = table.map(table.filter(room.alive_players,  function(p)
      return not p:hasSkill(self) end), Util.IdMapper)
    if #targets > 0 then
      local to = room:askForChoosePlayers(player, targets, 1, 1, "#ty_heg__lianyou-choose", self.name, true)
      if #to > 0 then
        to = to[1]
        room:handleAddLoseSkills(room:getPlayerById(to), "xinghuo")
      end
    end
  end,
}