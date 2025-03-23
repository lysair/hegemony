local xuanlve = fk.CreateSkill{
  name = "xuanlve",
}
xuanlve:addEffect(fk.AfterCardsMove, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(xuanlve.name) then return end
    local room = player.room
    for _, move in ipairs(data) do
      if move.from == player then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerEquip then
            return table.find(room:getOtherPlayers(player, false), function(p)
              return not p:isNude()
            end) ~= nil
          end
        end
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room:getOtherPlayers(player, false), function(p)
      return not p:isNude()
    end)
    local tos = room:askToChoosePlayers(player, {targets = targets, min_num = 1, max_num = 1,
      prompt = '#xuanlve-discard', skill_name = xuanlve.name, cancelable = true})
    if #tos > 0 then
      event:setCostData(self, {tos = tos})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    local id = room:askForCardChosen(player, to, "he", xuanlve.name)
    room:throwCard(id, xuanlve.name, to, player)
  end,
})

Fk:loadTranslationTable{
  ['xuanlve'] = '旋略',
  [':xuanlve'] = '当你失去装备区的牌后，你可以弃置一名其他角色的一张牌。',
  ['#xuanlve-discard'] = '旋略：你可以弃置一名其他角色的一张牌',

  ["$xuanlve1"] = "舍辎简装，袭掠如风！",
  ["$xuanlve2"] = "卸甲奔袭，摧枯拉朽！",
}

return xuanlve
