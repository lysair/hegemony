local jixi = fk.CreateSkill{
  name = "ld__jixi",
  tags = { Skill.MainPlace } ,
}
jixi:addEffect("viewas", {
  anim_type = "control",
  pattern = "snatch",
  expand_pile = "ld__dengai_field",
  enabled_at_play = function(self, player)
    return #player:getPile("ld__dengai_field") > 0
  end,
  enabled_at_response = function(self, player)
    return #player:getPile("ld__dengai_field") > 0
  end,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and Self:getPileNameOfId(to_select) == "ld__dengai_field"
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 then
      return nil
    end
    local c = Fk:cloneCard("snatch")
    c.skillName = self.name
    c:addSubcard(cards[1])
    return c
  end,
})
jixi:addAI(nil, "vs_skill")

Fk:loadTranslationTable{
  ["ld__jixi"] = "急袭",
  [":ld__jixi"] = "主将技，此武将牌上的单独阴阳鱼个数-1。你可将一张“田”当【顺手牵羊】使用。",

  ["$ld__jixi1"] = "谁占到先机，谁就胜了。",
  ["$ld__jixi2"] = "哪里走！！",
}

return jixi
