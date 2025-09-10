local bingxin = fk.CreateSkill{
  name = "jy_heg__bingxin",
}

Fk:loadTranslationTable{
  ["jy_heg__bingxin"] = "冰心",
  [":jy_heg__bingxin"] = "若你手牌的数量等于体力值且颜色相同，你可以展示手牌（无则跳过）并摸一张牌，视为使用一张本回合未以此法使用过牌名的基本牌。",

  ["#jy_heg__bingxin"] = "冰心：摸一张牌，视为使用一张基本牌",

  ["$jy_heg__bingxin1"] = "思鸟黄雀至，卧冰鱼自跃。",
  ["$jy_heg__bingxin2"] = "夜静向寒月，卧冰求鲤鱼。",
}

bingxin:addEffect("viewas", {
  pattern = ".|.|.|.|.|basic|",
  prompt = "#jy_heg__bingxin",
  interaction = function(self, player)
    local all_names = Fk:getAllCardNames("b")
    local names = player:getViewAsCardNames(bingxin.name, all_names, {}, player:getTableMark("jy_heg__bingxin-turn"))
    if #names > 0 then
      return UI.CardNameBox { choices = names, all_choices = all_names }
    end
  end,
  card_filter = Util.FalseFunc,
  view_as = function(self, player, cards)
    if not self.interaction.data then return end
    local card = Fk:cloneCard(self.interaction.data)
    card.skillName = bingxin.name
    return card
  end,
  before_use = function(self, player, use)
    if not player:isKongcheng() then
      player.room:showCards(player:getCardIds("h"))
    end
    player.room:addTableMark(player, "jy_heg__bingxin-turn", use.card.trueName)
    player:drawCards(1, bingxin.name)
  end,
  enabled_at_play = function(self, player)
    local cards = player:getCardIds("h")
    return #cards == math.max(player.hp, 0) and
      table.every(cards, function(id)
        return Fk:getCardById(id):compareColorWith(Fk:getCardById(cards[1]))
      end)
  end,
  enabled_at_response = function(self, player, response)
    local cards = player:getCardIds("h")
    return not response and #cards == math.max(player.hp, 0) and
    table.every(cards, function(id)
      return Fk:getCardById(id):compareColorWith(Fk:getCardById(cards[1]))
    end)
  end,
})

return bingxin
