local fengshi = fk.CreateSkill{
  name = "fengshi",
}
local H = require "packages/hegemony/util"
fengshi:addEffect("arraysummon", {
  array_type = "siege",
})
fengshi:addEffect(fk.TargetSpecified, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return player:hasShownSkill(fengshi.name) and data.card.trueName == "slash" and H.inSiegeRelation(target, player, data.to)
      and #player.room.alive_players > 3 and #data.to:getCardIds(Player.Equip) > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player.room:askForDiscard(data.to, 1, 1, true, fengshi.name, false, ".|.|.|equip", "#fengshi-discard")
  end
})

Fk:loadTranslationTable{
  ['fengshi'] = '锋矢',
  [':fengshi'] = '阵法技，若你是围攻角色，此围攻关系中的围攻角色使用【杀】指定被围攻角色为目标后，你令被围攻角色角色弃置其装备区里的一张牌。',

  ["#fengshi_trigger"] = "锋矢",
  ["#fengshi-discard"] = "锋矢：弃置装备区里的一张牌",

  ['$fengshi1'] = '大军压境，还不卸甲受降！',
  ['$fengshi2'] = '放下兵器，饶你不死！',
}

return fengshi
