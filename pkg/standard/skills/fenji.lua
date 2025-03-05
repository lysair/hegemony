
local fenji = fk.CreateSkill{
  name = "hs__fenji",
}
fenji:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(fenji.name) and target.phase == Player.Finish and target:isKongcheng()
  end,
  on_use = function(self, event, target, player, data)
    target:drawCards(2, fenji.name)
    if not player.dead then player.room:loseHp(player, 1, fenji.name) end
  end,
})

Fk:loadTranslationTable{
  ["hs__fenji"] = "奋激",
  [":hs__fenji"] = "一名角色的结束阶段，若其没有手牌，你可令其摸两张牌，然后你失去1点体力。",

  ["$hs__fenji1"] = "百战之身，奋勇驱前！",
  ["$hs__fenji2"] = "两肋插刀，愿赴此躯！",
}
return fenji
