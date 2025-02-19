local shensu = fk.CreateSkill{
  name = "hs__shensu",
}
shensu:addEffect(fk.EventPhaseChanging, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self) and not data.skipped then
      if data.phase == Player.Judge then
        if player.skipped_phases[Player.Draw] then return end
      elseif data.phase == Player.Play then
        if player:isNude() then return end
      elseif data.phase == Player.Discard then
        if player.hp < 1 then return end
      else
        return
      end
      return table.find(player.room:getOtherPlayers(player, false), function (p)
        return player:canUseTo(Fk:cloneCard("slash"), p, {bypass_distances = true, bypass_times = true})
      end)
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local slash = Fk:cloneCard("slash")
    local max_num = slash.skill:getMaxTargetNum(player, slash)
    local targets = table.filter(room:getOtherPlayers(player, false), function(p)
      return player:canUseTo(slash, p, {bypass_distances = true, bypass_times = true})
    end)
    if #targets == 0 or max_num == 0 then return end
    if data.phase == Player.Judge then
      local tos = room:askToChoosePlayers(player, {targets = targets, min_num = 1,
        max_num = max_num, prompt = "#hs__shensu1-choose", skill_name = shensu.name, cancelable = true})
      if #tos > 0 then
        event:setCostData(self, {tos = tos})
        return true
      end
    elseif data.phase == Player.Play then
      local cards = table.filter(player:getCardIds("he"), function (id)
        return Fk:getCardById(id).type == Card.TypeEquip and not player:prohibitDiscard(id)
      end)
      local tos, id = room:askToChooseCardAndPlayers(player, {targets = targets,
        min_num = 1, max_num = max_num, pattern = tostring(Exppattern{ id = cards }),
        prompt = "#hs__shensu2-choose", skill_name = self.name, cancelable = true})
      if #tos > 0 and id then
        event:setCostData(self, { tos = tos, cards = {id} })
        return true
      end
    elseif data.phase == Player.Discard then
      local tos = room:askToChoosePlayers(player, {targets = targets, min_num = 1,
        max_num = max_num, prompt = "#hs__shensu3-choose", skill_name = shensu.name, cancelable = true})
      if #tos > 0 then
        event:setCostData(self, {tos = tos})
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if data.phase == Player.Judge then
      player:skip(Player.Draw)
    elseif data.phase == Player.Play then
      player:skip(Player.Play)
      room:throwCard(event:getCostData(self).cards, shensu.name, player, player)
    elseif data.phase == Player.Discard then
      player.room:loseHp(player, 1, self.name)
    end
    data.skipped = true
    if player.dead then return end
    local targets = event:getCostData(self).tos
    room:sortByAction(targets)
    room:useVirtualCard("slash", nil, player, targets, shensu.name, true)
  end,
})

shensu:addTest(function (room, me)
  local comp3 = room.players[3]
  local card = room:printCard("axe")
  local orig_hp = comp3.hp
  FkTest.runInRoom(function ()
    room:handleAddLoseSkills(me, shensu.name)
    room:obtainCard(me, card)
    me:drawCards(6)
  end)
  FkTest.setNextReplies(me, { json.encode {
    card = { skill = "choose_players_skill", subcards = {} },
    targets = { comp3.id }
  }, json.encode {
    card = { skill = "choose_players_skill", subcards = { card.id } },
    targets = { comp3.id }
  }, json.encode {
    card = { skill = "choose_players_skill", subcards = {} },
    targets = { comp3.id }
  } })
  FkTest.runInRoom(function ()
    local data = { ---@type TurnDataSpec
      who = me,
      reason = "game_rule",
    }
    GameEvent.Turn:create(TurnData:new(data)):exec()
  end)
  local handler = ClientInstance.current_request_handler --[[@as ReqActiveSkill]]
  lu.assertIsTrue(handler:targetValidity(comp3.id))
  FkTest.resumeRoom()
  lu.assertEquals(#me:getCardIds("h"), 6)
  lu.assertEquals(comp3.hp, orig_hp - 3)
end)

Fk:loadTranslationTable{
  ["hs__shensu"] = "神速",
  [":hs__shensu"] = "①判定阶段开始前，你可跳过此阶段和摸牌阶段视为使用普【杀】。②出牌阶段开始前，你可跳过此阶段并弃置一张装备牌视为使用普【杀】。③弃牌阶段开始前，你可跳过此阶段并失去1点体力视为使用普【杀】。",

  ["#hs__shensu1-choose"] = "神速：你可以跳过判定阶段和摸牌阶段，视为使用一张无距离限制的【杀】",
  ["#hs__shensu2-choose"] = "神速：你可以跳过出牌阶段并弃置一张装备牌，视为使用一张无距离限制的【杀】",
  ["#hs__shensu3-choose"] = "神速：你可以跳过弃牌阶段并失去1点体力，视为使用一张无距离限制的【杀】",

  ["$hs__shensu1"] = "吾善于千里袭人！",
  ["$hs__shensu2"] = "取汝首级，有如探囊取物！",
}

return shensu
