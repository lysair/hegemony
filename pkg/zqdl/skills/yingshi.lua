local yingshi = fk.CreateSkill {
  name = "zq__yingshis",
}

Fk:loadTranslationTable{
  ["zq__yingshis"] = "鹰视",
  [":zq__yingshis"] = "出牌阶段开始时，你可以令一名角色视为对你指定的另一名角色使用一张【知己知彼】，然后若使用者不为你，你摸一张牌。",

  ["#zq__yingshi-choose"] = "鹰视：选择两名角色，视为前者对后者使用【知己知彼】，若使用者不为你，你摸一张牌",

  ["$zq__yingshis1"] = "鹰扬千里，明察秋毫。",
  ["$zq__yingshis2"] = "鸢飞戾天，目入百川。",
}

yingshi:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(yingshi.name) and player.phase == Player.Play and
      table.find(player.room.alive_players, function (p)
        return p:canUse(Fk:cloneCard("known_both"))
      end)
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local success, dat = room:askToUseActiveSkill(player, {
      skill_name = "zq__yingshis_active",
      prompt = "#zq__yingshi-choose",
      cancelable = true,
    })
    if success and dat then
      event:setCostData(self, {tos = {dat.targets[1]}, extra_data = {dat.targets[2]}})
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local from = event:getCostData(self).tos[1]
    room:useVirtualCard("known_both", nil, from, event:getCostData(self).extra_data[1], yingshi.name)
    if from ~= player and not player.dead then
      player:drawCards(1, yingshi.name)
    end
  end,
})

return yingshi
