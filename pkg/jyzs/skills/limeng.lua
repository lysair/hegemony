local limeng = fk.CreateSkill{
  name = "jy_heg__limeng",
}

Fk:loadTranslationTable{
  ["jy_heg__limeng"] = "离梦",
  [":jy_heg__limeng"] = "结束阶段，你可以弃置一张非基本牌并选择场上两张珠联璧合的武将牌，" ..
    "若不为同一名角色的武将，则这些角色分别对另一名角色造成1点伤害。",
}

limeng:addEffect(fk.EventPhaseStart, {
  can_trigger = function(self, event, target, player, data)
    return player.phase == Player.Finish and player:hasSkill(limeng.name) and target == player
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local targets = {}
    local _, ret = room:askToUseActiveSkill(player, {
      skill_name = "jy_heg__limeng_choose",
      --[[ min_num = 1,
      max_num = 2,
      min_card_num = 1,
      max_card_num = 1,
      will_throw = true,
      skill_name = limeng.name,
      targets = {},
      pattern = ".|.|.|.|.|^basic",
      include_equip = true, ]]
    })
    if ret then
      event:setCostData(self, {tos = ret.targets, cards = ret.cards})
    end
  end,
  on_use = function (self, event, target, player, data)
    local costData = event:getCostData(self)
    local tos, cards = costData.tos, costData.cards
    local room = player.room
    room:throwCard(cards, limeng.name, player, player)
    if #tos < 2 then return end
    room:sortByAction(tos)
    for i = 1, 2, 1 do
      local to1, to2 = tos[i], tos[3-i]
      if to1:isAlive() and to2:isAlive() then
        room:damage{
          from = to1,
          to = to2,
          damage = 1,
        }
      end
    end
  end
})

return limeng
