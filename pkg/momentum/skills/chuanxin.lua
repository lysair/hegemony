local chuanxin = fk.CreateSkill{
  name = "chuanxin",
}
local H = require "packages/hegemony/util"
chuanxin:addEffect(fk.DamageCaused, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and target:hasSkill(chuanxin.name) and player.phase == Player.Play and data.card and table.contains({"slash", "duel"}, data.card.trueName) and not data.chain
      and H.compareExpectedKingdomWith(player, data.to, true) and H.hasGeneral(data.to, true)
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, chuanxin.name, data, "#chuanxin-ask::" .. data.to.id)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local target = data.to
    data:preventDamage()
    local all_choices = {"chuanxin_discard", "removeDeputy:::" .. H.getActualGeneral(player, true)}
    local choices = table.clone(all_choices)
    if #data.to:getCardIds(Player.Equip) == 0 then table.remove(choices, 1) end
    local choice = room:askForChoice(target, choices, chuanxin.name, nil, false, all_choices)
    if choice:startsWith("removeDeputy") then
      H.removeGeneral(target, true)
    else
      target:throwAllCards("e")
      if not target.dead then
        room:loseHp(target, 1, chuanxin.name)
      end
    end
  end,
})

Fk:loadTranslationTable{
  ['chuanxin'] = '穿心',
  [':chuanxin'] = '当你于出牌阶段内使用【杀】或【决斗】对目标角色造成伤害时，若其与你势力不同或你明置此武将牌后与其势力不同，且其有副将，你可防止此伤害，令其选择一项：1. 弃置装备区里的所有牌，失去1点体力；2. 移除副将。',

  ["chuanxin_discard"] = "弃置装备区里的所有牌，失去1点体力",
  ["#chuanxin-ask"] = "你可防止此伤害，对 %dest 发动“穿心”",

  ['$chuanxin1'] = '一箭穿心，哪里可逃？',
  ['$chuanxin2'] = '穿心之痛，细细品吧，哈哈哈哈！',
}

return chuanxin
