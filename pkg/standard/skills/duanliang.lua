local duanliang = fk.CreateSkill{
  name = "hs__duanliang",
}
duanliang:addEffect('viewas', {
  anim_type = "control",
  pattern = "supply_shortage",
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).color == Card.Black and Fk:getCardById(to_select).type ~= Card.TypeTrick
  end,
  view_as = function(self, cards)
    if #cards ~= 1 then
      return nil
    end
    local c = Fk:cloneCard("supply_shortage")
    c.skillName = duanliang.name
    c:addSubcard(cards[1])
    return c
  end,
  before_use = function(self, player, use)
    local targets = use.tos
    if #targets == 0 then return end
    local room = player.room
    for _, t in ipairs(targets) do
      if player:distanceTo(t) > 2 then
        room:invalidateSkill(player, duanliang.name, "-phase")
        room:setPlayerMark(player, "@@hs__duanliang-phase", 1)
      end
    end
  end
})
duanliang:addEffect('targetmod', {
  bypass_distances = function (self, player, skill, card, to)
    return player:hasSkill(duanliang.name) and skill.trueName == "supply_shortage_skill"
  end
})

Fk:loadTranslationTable{
  ["hs__duanliang"] = "断粮",
  [":hs__duanliang"] = "你可将一张不为锦囊牌的黑色牌当【兵粮寸断】使用" ..
    "（无距离关系的限制），若你至目标对应的角色的距离大于2，此技能于此阶段内无效。",

  ["@@hs__duanliang-phase"] = "断粮 无效",

  ["$hs__duanliang1"] = "截其源，断其粮，贼可擒也。",
  ["$hs__duanliang2"] = "人是铁，饭是钢。",
}

return duanliang
