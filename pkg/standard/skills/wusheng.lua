local wusheng = fk.CreateSkill{
  name = "hs__wusheng",
}
local H = require "packages/hegemony/util"
wusheng:addEffect('viewas', {
  anim_type = "offensive",
  pattern = "slash",
  card_filter = function(self, player, to_select, selected)
    if #selected == 1 then return false end
    return (H.getHegLord(Fk:currentRoom(), player) and H.getHegLord(Fk:currentRoom(), Self):hasSkill("shouyue")) or Fk:getCardById(to_select).color == Card.Red
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 then
      return nil
    end
    local c = Fk:cloneCard("slash")
    c.skillName = wusheng.name
    c:addSubcard(cards[1])
    return c
  end,
})
wusheng:addEffect("targetmod", {
  name = "#hs__wusheng_targetmod",
  anim_type = "offensive",
  bypass_distances = function (self, player, skill, card, to)
    return card and player:hasSkill(wusheng.name) and skill.trueName == "slash_skill" and card.suit == Card.Diamond
  end
})

Fk:loadTranslationTable{
  ["hs__wusheng"] = "武圣", -- 动态描述
  [":hs__wusheng"] = "你可将一张红色牌当【杀】使用或打出。你使用的<font color='red'>♦</font>【杀】无距离限制。",
  ["$hs__wusheng1"] = "关羽在此，尔等受死！",
  ["$hs__wusheng2"] = "看尔乃插标卖首！",
}

return wusheng
