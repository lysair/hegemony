local duanbing = fk.CreateSkill{
  name = "duanbing",
}
duanbing:addEffect(fk.AfterCardTargetDeclared, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(duanbing.name) and data.card.trueName == "slash" and
      table.find(data:getExtraTargets(), function(_p)
        return player:distanceTo(_p) == 1
      end)
  end,
  on_cost = function(self, event, target, player, data)
    local targets = table.filter(data:getExtraTargets(), function(_p)
      return player:distanceTo(_p) == 1
    end)
    local tos = player.room:askToChoosePlayers(player, {targets = targets, min_num = 1, max_num = 1,
      prompt = "#duanbing-choose", skill_name = duanbing.name})
    if #tos > 0 then
      event:setCostData(self, {tos = tos})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    data:addTarget(event:getCostData(self).tos[1])
  end,
})

duanbing:addTest(function (room, me)
  local comp2, comp8 = room.players[2], room.players[8]
  local orig_hp2, orig_hp8 = comp2.hp, comp8.hp
  FkTest.setNextReplies(me, { json.encode {
    card = { skill = "choose_players_skill", subcards = {} },
    targets = { comp8.id }
  } })
  FkTest.runInRoom(function ()
    room:handleAddLoseSkills(me, duanbing.name)
    room:useVirtualCard("slash", nil, me, comp2)
  end)
  lu.assertEquals(comp2.hp, orig_hp2 - 1)
  lu.assertEquals(comp8.hp, orig_hp8 - 1)
end)

Fk:loadTranslationTable{
  ["duanbing"] = "短兵",
  [":duanbing"] = "当你使用【杀】选择目标后，你可令一名距离为1的角色也成为此【杀】的目标。",
  ["#duanbing-choose"] = "短兵：你可以额外选择一名距离为1的其他角色为目标",

  ["$duanbing1"] = "众将官，短刀出鞘。",
  ["$duanbing2"] = "短兵轻甲也可取汝性命！",
}

return duanbing
