local shuliang = fk.CreateSkill{
  name = "of_heg__shuliang",
}

Fk:loadTranslationTable{
  ["of_heg__shuliang"] = "输粮",
  [":of_heg__shuliang"] = "一名与你势力相同角色的结束阶段，若你与其距离不大于“粮”数，你可以移去一张“粮”，然后该角色摸两张牌。",

  ["of_heg__lifeng_liang"] = "粮",
  ["#of_heg__shuliang-invoke"] = "输粮：你可以移去一张“粮”，令 %dest 摸两张牌",

  ["$of_heg__shuliang1"] = "将军驰劳，酒肉慰劳。",
  ["$of_heg__shuliang2"] = "将军，牌来了。",
}

local H = require "packages/hegemony/util"

shuliang:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(shuliang.name) and target.phase == Player.Finish and
    (H.compareKingdomWith(target, player) and player:distanceTo(target) <= #player:getPile("of_heg__lifeng_liang")) and
    #player:getPile("of_heg__lifeng_liang") > 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local card = room:askToCards(player, {
      min_num = 1,
      max_num = 1,
      include_equip = false,
      skill_name = shuliang.name,
      pattern = ".|.|.|of_heg__lifeng_liang",
      prompt = "#of_heg__shuliang-invoke::"..target.id,
      cancelable = true,
      expand_pile = "of_heg__lifeng_liang",
    })
    if #card > 0 then
      event:setCostData(self, {cards = card, tos = {target} })
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:moveCardTo(event:getCostData(self).cards, Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile, shuliang.name, nil, true, player)
    if not target.dead then
      target:drawCards(2, shuliang.name)
    end
  end,
})

return shuliang
