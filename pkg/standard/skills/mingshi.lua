local mingshi = fk.CreateSkill{
  name = "mingshi",
  tags = {Skill.Compulsory},
}
mingshi:addEffect(fk.DamageInflicted, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(mingshi.name) and data.from and
      (data.from.general == "anjiang" or data.from.deputyGeneral == "anjiang")
  end,
  on_use = function(self, event, target, player, data)
    data:changeDamage(-1)
  end,
})

mingshi:addTest(function (room, me)
  local comp2 = room.players[2]
  FkTest.runInRoom(function ()
    room:handleAddLoseSkills(me, mingshi.name)
    room:changeHero(comp2, "zhouyu", false, true)
    comp2:hideGeneral(true)
    room:damage{
      from = comp2,
      to = me,
      damage = 2,
    }
  end)
  lu.assertEquals(me.hp, 3)
end)

Fk:loadTranslationTable{
  ["mingshi"] = "名士",
  [":mingshi"] = "锁定技，当你受到伤害时，若来源有暗置的武将牌，你令伤害值-1。",

  ["$mingshi1"] = "孔门之后，忠孝为先。",
  ["$mingshi2"] = "名士之风，仁义高洁。",
}

return mingshi
