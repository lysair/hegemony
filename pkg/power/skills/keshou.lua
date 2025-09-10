local keshou = fk.CreateSkill{
  name = "ld__keshou",
}
local H = require "packages/hegemony/util"
keshou:addEffect(fk.DamageInflicted, {
  anim_type = "defensive",
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(keshou.name) and player == target and #target:getCardIds("he") > 1
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local _, dat = room:askToUseActiveSkill(player, {skill_name = "#ld__keshou_filter",
      prompt = "#ld__keshou:::" .. data.damage, cancelable = true})
    if dat then
      event:setCostData(self, {cards = dat.cards})
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    room:throwCard(event:getCostData(self).cards, keshou.name, player, player)
    data:changeDamage(-1)
    if player and H.getKingdomPlayersNum(room)[H.getKingdom(player)] == 1 then
      local judge = {
        who = player,
        reason = keshou.name,
        pattern = ".|.|heart,diamond|.|.|.",
      }
      room:judge(judge)
      if judge:matchPattern() and player:isAlive() then
        player:drawCards(1, keshou.name)
      end
    end
  end,
})

Fk:loadTranslationTable{
  ["ld__keshou"] = "恪守",
  [":ld__keshou"] = "当你受到伤害时，你可弃置两张颜色相同的牌，令此伤害值-1，然后若没有与你势力相同的其他角色，你判定，若结果为红色，你摸一张牌。",
  ["#ld__keshou"] = "恪守：是否弃置两张颜色相同的牌，令你受到的%arg点伤害-1",

  ["$ld__keshou1"] = "仁以待民，自处不败之势。",
  ["$ld__keshou2"] = "宽济百姓，则得战前养备之机。",
}
return keshou
