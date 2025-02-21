local ziliang = fk.CreateSkill{
  name = "ziliang",
  tags = {Skill.DeputyPlace, Skill.Compulsory},
}
local H = require "packages/hegemony/util"
ziliang:addEffect(fk.Damaged, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(ziliang.name) and H.compareKingdomWith(player, target) and not target.dead and #player:getPile("ld__dengai_field") > 0
  end,
  on_cost = function(self, event, target, player, data)
    local card = player.room:askForCard(player, 1, 1, false, ziliang.name, true, ".|.|.|ld__dengai_field", "#ziliang-card::" .. target.id, "ld__dengai_field")
    if #card > 0 then
      event:setCostData(self, {cards = card})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:moveCardTo(event:getCostData(self).cards, Card.PlayerHand, target, fk.ReasonGive, ziliang.name, "ld__dengai_field", true, player.id)
  end,
})

Fk:loadTranslationTable{
["ziliang"] = "资粮",
[":ziliang"] = "副将技，当与你势力相同的角色受到伤害后，你可将一张“田”交给其。",
["#ziliang-card"] = "资粮：你可将一张“田”交给 %dest",

["$ziliang1"] = "兵，断不可无粮啊。",
["$ziliang2"] = "吃饱了，才有力气为国效力。",
}

return ziliang
