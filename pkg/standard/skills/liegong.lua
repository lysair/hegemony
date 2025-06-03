local H = require "packages/hegemony/util"

local liegong = fk.CreateSkill{
  name = "hs__liegong",
  dynamic_desc = function(self, player)
    if H.hasHegLordSkill(Fk:currentRoom(), player, "shouyue") then
      return "hs__liegong_shouyue"
    else
      return "hs__liegong"
    end
  end,
}

liegong:addEffect(fk.TargetSpecified, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if not (target == player and player:hasSkill(self)) then return end
    local num = #data.to:getCardIds("h")
    return data.card.trueName == "slash" and
      (num <= player:getAttackRange() or num >= player.hp) and
      player.phase == Player.Play
  end,
  on_use = function(self, event, target, player, data)
    data.disresponsive = true
  end,
})
liegong:addEffect("atkrange", {
  correct_func = function(self, from, to)
    if H.hasHegLordSkill(Fk:currentRoom(), from, "shouyue") then
      return 1
    end
    return 0
  end,
})

Fk:loadTranslationTable{
  ["hs__liegong"] = "烈弓",
  [":hs__liegong"] = "当你于出牌阶段内使用【杀】指定目标后，若其手牌数不小于你的体力值或不大于你的攻击范围，你可令其不能使用【闪】响应此【杀】。",
  [":hs__liegong_shouyue"] = "当你于出牌阶段内使用【杀】指定目标后，若其手牌数不小于你的体力值或不大于你的攻击范围，你可令其不能使用【闪】响应此【杀】。你的攻击范围+1。",

  ["$hs__liegong1"] = "百步穿杨！",
  ["$hs__liegong2"] = "中！",
}

return liegong
