local shenwei = fk.CreateTriggerSkill{
  name = "ty_heg__shenwei",
  relate_to_place = "m",
  anim_type = "drawcard",
  events = {fk.DrawNCards},
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Draw and
      table.every(player.room.alive_players, function(p) return player.hp >= p.hp end)
  end,
  on_use = function(self, event, target, player, data)
    data.n = data.n + 2
  end,
}

local shenwei_maxcards = fk.CreateMaxCardsSkill{
  name = "#ty_heg__shenwei_maxcards",
  fixed_func = function(self, player)
    if player:hasShownSkill(shenwei) then
      return player.hp + 2
    end
  end
}