local shenwei = fk.CreateSkill{
  name = "ty_heg__shenwei",
  tags = {Skill.MainPlace},
}
shenwei:addEffect(fk.DrawNCards, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(shenwei.name) and player.phase == Player.Draw and
      table.every(player.room.alive_players, function(p) return player.hp >= p.hp end)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data.n = data.n + 2
  end,
})

shenwei:addEffect("maxcards", {
  fixed_func = function(self, player)
    if player:hasShownSkill(shenwei.name) then
      return player.hp + 2
    end
  end
})

Fk:loadTranslationTable{
  ["ty_heg__shenwei"] = "神威",
  [":ty_heg__shenwei"] = "主将技，此武将牌上单独的阴阳鱼个数-1。①摸牌阶段，若你的体力值为全场最高，你多摸两张牌。②你的手牌上限+2。",

  ["$ty_heg__shenwei1"] = "锋镝鸣手中，锐戟映秋霜。",
  ["$ty_heg__shenwei2"] = "红妆非我愿，学武觅封侯。",
}

return shenwei
