local H = require "packages/hegemony/util"
local function doImperialOrder(room, target)
  local all_choices = {"IO_reveal", "IO_discard", "IO_hplose"}
  local choices = table.clone(all_choices)
  if target.hp < 1 then table.remove(choices) end
  if table.every(target:getCardIds("he"), function(id)
    return Fk:getCardById(id).type ~= Card.TypeEquip or target:prohibitDiscard(Fk:getCardById(id))
  end) then
    table.remove(choices, 2) -- 没有装备牌不能选择弃牌
  end
  if (target.general ~= "anjiang" or target:prohibitReveal()) and (target.deputyGeneral ~= "anjiang" or target:prohibitReveal(true)) then
    table.remove(choices, 1) -- 没有暗将或不能亮将不能亮将
  end
  if #choices == 0 then return false end
  local choice = room:askForChoice(target, choices, "imperial_order_skill", nil, false, all_choices)
  if choice == "IO_reveal" then
    H.askToRevealGenerals(target, {
      skill_name = "imperial_order_skill",
      cancelable = false,
    })
    target:drawCards(1, "imperial_order_skill")
  elseif choice == "IO_discard" then
    room:askForDiscard(target, 1, 1, true, "imperial_order_skill", false, ".|.|.|.|.|equip")
  else
    room:loseHp(target, 1, "imperial_order_skill")
  end
end

local imperialOrderSkill = fk.CreateSkill{
  name = "imperial_order_skill",
}
imperialOrderSkill:addEffect('cardskill', {
  prompt = "#imperial_order_skill",
  mod_target_filter = function(self, player, to_select, selected)
    return to_select.kingdom == "unknown"
  end,
  can_use = function(self, player, card)
    for _, p in ipairs(Fk:currentRoom().alive_players) do
      if not player:isProhibited(p, card) and self:modTargetFilter(player, p, {}, card, true) then
        return true
      end
    end
  end,
  on_use = function(self, room, use)
    if not use.tos or #use.tos == 0 then
      use.tos = {}
      local user = use.from
      for _, player in ipairs(room.alive_players) do
        if player.kingdom == "unknown" and not user:isProhibited(player, use.card) then
          use:addTarget(player)
        end
      end
    end
  end,
  on_effect = function(self, room, effect)
    local target = effect.to
    doImperialOrder(room, target)
  end,
})
imperialOrderSkill:addEffect(fk.TurnEnd, {
  global = true,
  can_refresh = function(self, event, target, player, data)
    if player.room:getTag("ImperialOrderHasRemoved") then return false end -- 先这样，只有一次！
    return target == player and target.room:getTag("ImperialOrderRemoved")
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    for _, p in ipairs(room:getAlivePlayers()) do
      if p.kingdom == "unknown" then
        doImperialOrder(room, p)
      end
    end
    room:setTag("ImperialOrderRemoved", false)
    room:setTag("ImperialOrderHasRemoved", true)
  end,
})
imperialOrderSkill:addEffect(fk.BeforeCardsMove, {
  global = true,
  can_refresh = function(self, event, target, player, data)
    if player.room:getTag("ImperialOrderHasRemoved") then return false end -- 先这样，只有一次！
    if player.room:getTag("ImperialOrderRemoved") then return false end
    for _, move in ipairs(data) do
      if move.toArea == Card.DiscardPile and move.moveReason ~= fk.ReasonUse then
        for _, info in ipairs(move.moveInfo) do
          if Fk:getCardById(info.cardId).name == "imperial_order" then
            return true
          end
        end
      end
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local ids = {}
    local mirror_moves = {}
    for _, move in ipairs(data) do
      if move.toArea == Card.DiscardPile and move.moveReason ~= fk.ReasonUse then
        local move_info = {}
        local mirror_info = {}
        for _, info in ipairs(move.moveInfo) do
          local id = info.cardId
          if Fk:getCardById(id).name == "imperial_order" then
            table.insert(mirror_info, info)
            table.insert(ids, id)
          else
            table.insert(move_info, info)
          end
        end
        if #mirror_info > 0 then
          move.moveInfo = move_info
          local mirror_move = move:copy()
          mirror_move.to = nil
          mirror_move.toArea = Card.Void
          mirror_move.moveInfo = mirror_info
          mirror_move.moveVisible = true
          mirror_move.moveReason = fk.ReasonJustMove
          table.insert(mirror_moves, mirror_move)
        end
      end
    end
    if #ids > 0 then
      player.room:sendLog{
        type = "#ImperialOrderRemoved",
        card = ids,
      }
    end
    table.insertTable(data, mirror_moves)
    player.room:setTag("ImperialOrderRemoved", true)
  end,
})

imperialOrderSkill:addTest(function(room, me)
  local comp2, comp3 = room.players[2], room.players[3]
  local card = room:printCard("imperial_order")
  local axe = room:printCard("axe")

  -- test1：选择失去体力和弃装备
  FkTest.setNextReplies(comp2, { "IO_hplose" })
  FkTest.setNextReplies(comp3, { "IO_discard", tostring(axe.id) })

  FkTest.runInRoom(function()
    room:setPlayerProperty(comp2, "deputyGeneral", "zhouyu")
    room:setPlayerProperty(comp3, "deputyGeneral", "huangyueying")
    for _, _p in ipairs{comp2, comp3} do
      _p:hideGeneral()
      _p:hideGeneral(true)
      room:setPlayerProperty(_p, "kingdom", "unknown")
    end
    room:obtainCard(comp3, axe)
    room:useCard {
      from = me,
      card = card,
      tos = {},
    }
  end)
  lu.assertEquals(comp2.general, "anjiang")
  lu.assertEquals(comp2.hp, 3)
  lu.assertIsTrue(comp3:isNude())

  -- test2：选择亮将
  FkTest.setNextReplies(comp2, {"IO_reveal", "revealMain:::sunquan"})
  FkTest.setNextReplies(comp3, {"IO_reveal", "revealDeputy:::huangyueying"})
  FkTest.runInRoom(function()
    room:useCard {
      from = me,
      card = card,
      tos = {},
    }
  end)
  lu.assertEquals(comp2.hp, 3)
  lu.assertEquals(comp2:getHandcardNum(), 1)
  lu.assertEquals(comp3.hp, 4)
  lu.assertEquals(comp2.general, "sunquan")
  lu.assertEquals(comp3.deputyGeneral, "huangyueying")

  -- test3：强制目标
  FkTest.setNextReplies(comp2, {"IO_reveal", "revealDeputy:::zhouyu"})
  FkTest.runInRoom(function()
    room:useCard {
      from = me,
      card = card,
      tos = {me, comp2},
    }
  end)
  lu.assertEquals(me.hp, 3)
  lu.assertEquals(comp2.deputyGeneral, "zhouyu")
  lu.assertEquals(comp2:getHandcardNum(), 2)

  -- test4：移出游戏后执行
  FkTest.setNextReplies(comp2, {"IO_reveal", "revealMain:::sunquan"})
  FkTest.runInRoom(function()
    comp2:hideGeneral(false)
    comp2:hideGeneral(true)
    room:setPlayerProperty(comp2, "kingdom", "unknown")
    room:obtainCard(comp3, card)
    comp3:throwAllCards("h")
    GameEvent.Turn:create(TurnData:new(me, "game_rule", { Player.Finish })):exec()
  end)
  lu.assertEquals(comp2.general, "sunquan")
  lu.assertEquals(comp2:getHandcardNum(), 3)
end)

Fk:loadTranslationTable{
  ["imperial_order"] = "敕令",
  [":imperial_order"] = "锦囊牌<br/><b>时机</b>：出牌阶段<br/><b>目标</b>：所有没有势力的角色<br/><b>效果</b>：目标角色选择：1.明置一张武将牌，其摸一张牌；2.弃置一张装备牌；3.失去1点体力。<br/><br/>※此牌不因使用而进入弃牌堆前，改为将此牌移出游戏，回合结束前，没有势力的角色依次执行此牌的效果。",
  ["imperial_order_skill"] = "敕令",
  ["IO_reveal"] = "明置一张武将牌，摸一张牌",
  ["IO_discard"] = "弃置一张装备牌",
  ["IO_hplose"] = "失去1点体力",
  ["#ImperialOrderRemoved"] = "%card 被移出游戏",
  ["#imperial_order_skill"] = "所有没有势力的角色选择：1.明置一张武将牌，摸一张牌；2.弃置一张装备牌；3.失去1点体力",
}

return imperialOrderSkill