local kurou = fk.CreateSkill{
  name = "hs__kurou",
}
kurou:addEffect("active", {
  anim_type = "drawcard",
  card_num = 1,
  target_num = 0,
  can_use = function(self, player)
    return player:usedSkillTimes(kurou.name, Player.HistoryPhase) == 0
  end,
  on_use = function(self, room, effect)
    local from = effect.from
    room:throwCard(effect.cards, kurou.name, from, from)
    if from.dead then return end
    room:loseHp(from, 1, self.name)
    if from.dead then return end
    from:drawCards(3, self.name)
  end
})
kurou:addEffect("targetmod", {
  residue_func = function(self, player, skill, scope)
    if skill.trueName == "slash_skill" and scope == Player.HistoryPhase then
      return player:usedSkillTimes(kurou.name, Player.HistoryPhase)
    end
  end,
})

Fk:loadTranslationTable{
  ["hs__kurou"] = "苦肉",
  [":hs__kurou"] = "出牌阶段限一次，你可弃置一张牌，然后你失去1点体力，摸三张牌，于此阶段内使用【杀】的次数上限+1。",

  ["$hs__kurou1"] = "我这把老骨头，不算什么！",
  ["$hs__kurou2"] = "为成大业，死不足惜！",
}

return kurou
