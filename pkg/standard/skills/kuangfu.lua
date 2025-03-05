local kuangfu = fk.CreateSkill{
  name = "kuangfu",
}
kuangfu:addEffect(fk.TargetSpecified, {
  can_trigger = function (self, event, target, player, data)
    if player:hasSkill(kuangfu.name) and data.card and data.card.trueName == "slash" and
      player.phase == Player.Play and player:usedSkillTimes(kuangfu.name, Player.HistoryPhase) == 0 and target == player then
      for _, p in ipairs(data:getAllTargets()) do
        if #p:getCardIds(Player.Equip) > 0 then
          return true
        end
      end
    end
  end,
  on_cost = function (self, event, target, player, data)
    local targets = table.filter(data:getAllTargets(), function (p)
      return #p:getCardIds(Player.Equip) > 0
    end)
    if #targets == 0 then return end
    if #targets == 1 then
      if player.room:askToSkillInvoke(player, {skill_name = kuangfu.name, prompt = "#kuangfu-invoke::" .. targets[1].id}) then
        event:setCostData(self, {tos = {targets} })
        return true
      end
    else
      local to = player.room:askToChoosePlayers(player, {targets = targets, min_num = 1, max_num = 1, prompt = "#kuangfu-choice",
        skill_name = kuangfu.name, cancelable = true})
      if #to > 0 then
        event:setCostData(self, {tos = to})
        return true
      end
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    local card = room:askToChooseCard(player, {target = to[1], flag = "e", skill_name = kuangfu.name})
    room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonPrey, kuangfu.name, nil, false, player.id)
    data.extra_data = data.extra_data or {}
    data.extra_data.kuangfuUser = player.id
  end,
})

kuangfu:addEffect(fk.CardUseFinished, {
  is_delay_effect = true,
  can_trigger = function (self, event, target, player, data)
    return (data.extra_data or {}).kuangfuUser == player.id and not data.damageDealt
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    player.room:askForDiscard(player, 2, 2, true, kuangfu.name, false)
  end,
})

kuangfu:addTest(function (room, me)
  local comp2 = room.players[2]
  local axe = room:printCard("axe")
  FkTest.setNextReplies(me, {
    json.encode {
      card = 1,
      targets = { comp2.id }
    },
    "1",
  })
  FkTest.runInRoom(function ()
    room:handleAddLoseSkills(me, kuangfu.name)
    room:useCard{from = comp2, tos = {comp2}, card = axe}
    GameEvent.Turn:create(TurnData:new(me, "game_rule", { Player.Play })):exec()
  end)
  lu.assertEquals(#me:getCardIds(Player.Hand), 1)

  FkTest.setNextReplies(me, {
    json.encode {
      card = 1,
      targets = { comp2.id }
    },
    "1",
  })
  local eight_diagram = room:printCard("eight_diagram")
  local jink = room:printCard("jink")
  FkTest.setNextReplies(comp2, { json.encode {
    card = jink.id,
  } })
  FkTest.runInRoom(function ()
    room:useCard{from = me, tos = {me}, card = axe}
    room:useCard{from = comp2, tos = {comp2}, card = eight_diagram}
    room:obtainCard(comp2, jink)
    GameEvent.Turn:create(TurnData:new(me, "game_rule", { Player.Play })):exec()
  end)
  lu.assertIsTrue(me:isNude())
end)

Fk:loadTranslationTable{
  ["kuangfu"] = "狂斧",
  [":kuangfu"] = "当你于出牌阶段内使用【杀】指定目标后，若你于此阶段内未发动过此技能，你可获得此牌其中一个目标角色装备区内的一张牌，然后此牌结算后，若此牌未造成过伤害，你弃置两张牌。",

  ["#kuangfu_delay"] = "狂斧",
  ["#kuangfu-invoke"] = "你可发动“狂斧”，获得%dest装备区内的一张牌",
  ["#kuangfu-choice"] = "狂斧：选择一名装备区内有牌且是此牌目标的角色，获得其装备区内一张牌",
  ["$kuangfu1"] = "吾乃上将潘凤，可斩华雄！",
  ["$kuangfu2"] = "这家伙，还是给我用吧！",
}

return kuangfu
