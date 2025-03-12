local hengjiang = fk.CreateSkill{
  name = "hengjiang",
}
hengjiang:addEffect(fk.Damaged, {
  anim_type = "masochism",
  can_trigger = function(self, _, target, player, _)
    if target ~= player or not player:hasSkill(hengjiang.name) then return false end
    local current = player.room.current
    return current ~= nil and not current.dead
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, {skill_name = hengjiang.name, prompt = "#hengjiang-invoke::" .. room.current.id}) then
      event:setCostData(self, { tos = {room.current} })
      return true
    end
  end,
  on_use = function(_, _, _, player, data)
    local room = player.room
    local target = room.current
    if target ~= nil and not target.dead then
      room:addPlayerMark(target, "@hengjiang-turn", math.max(1, #target:getCardIds("e")))
      room:addPlayerMark(target, MarkEnum.MinusMaxCardsInTurn, math.max(1, #target:getCardIds("e")))
    end
  end
})
hengjiang:addEffect(fk.TurnEnd, {
  anim_type = "drawcard",
  is_delay_effect = true,
  mute = true,
  can_trigger = function(_, _, target, player, _)
    if player.dead or player:usedSkillTimes(hengjiang.name) == 0 then return false end
    local room = player.room
    local discard_ids = {}
    room.logic:getEventsOfScope(GameEvent.Phase, 1, function (e)
      if e.data.phase == Player.Discard then
        table.insert(discard_ids, {e.id, e.end_id})
      end
      return false
    end, Player.HistoryTurn)
    if #discard_ids > 0 then
      if #room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function (e)
        local in_discard = false
        for _, ids in ipairs(discard_ids) do
          if #ids == 2 and e.id > ids[1] and e.id < ids[2] then
            in_discard = true
            break
          end
        end
        if in_discard then
          for _, move in ipairs(e.data) do
            if move.from == target and move.moveReason == fk.ReasonDiscard then
              for _, info in ipairs(move.moveInfo) do
                if info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip then
                  return true
                end
              end
            end
          end
        end
        return false
      end, Player.HistoryTurn) > 0 then
        return false
      end
    end
    return true
  end,
  on_use = function(_, _, _, player, _)
    if player:getHandcardNum() < player.maxHp then
      player:drawCards(player.maxHp - player:getHandcardNum() , hengjiang.name)
    end
  end,
})

---@param room Room
---@param me ServerPlayer
hengjiang:addTest(function(room, me)
  local comp2 = room.players[2]
  FkTest.runInRoom(function () room:changeHero(comp2, "ld__zangba") end)
  FkTest.setNextReplies(comp2, {"__cancel", "1"})
  local function createTwiceClosure() -- 第二次询问时断点
    local i = 0
    return function()
      i = i + 1
      return i == 2
    end
  end
  FkTest.setRoomBreakpoint(me, "PlayCard", createTwiceClosure())
  FkTest.setNextReplies(me, {json.encode {
    card = 1, targets = { comp2.id }
  } })
  FkTest.runInRoom(function ()
    room:obtainCard(me, 1)
    me:gainAnExtraTurn()
  end)
  lu.assertEquals(me:getMaxCards(), 3)
  FkTest.resumeRoom() -- 继续
  lu.assertEquals(comp2:getHandcardNum(), 4)

  FkTest.runInRoom(function ()
    comp2:throwAllCards("h")
  end)
  FkTest.setNextReplies(comp2, {"__cancel", "1"})
  FkTest.setNextReplies(me, {json.encode {
    card = 1, targets = { comp2.id }
  } })
  FkTest.runInRoom(function ()
    room:obtainCard(me, 1)
    me:gainAnExtraTurn()
  end)
  lu.assertEquals(comp2:getHandcardNum(), 0)
  lu.assertEquals(me:getHandcardNum(), 3)

  FkTest.setNextReplies(comp2, {"__cancel", "1"})
  FkTest.setNextReplies(me, {json.encode {
    card = 2, targets = { comp2.id }
  }, json.encode {
    card = { skill = "qingcheng", subcards = {1} }, targets = { comp2.id }
  } })
  FkTest.runInRoom(function ()
    me:throwAllCards("h")
    room:obtainCard(me, 1)
    room:obtainCard(me, 2)
    me:gainAnExtraTurn(true, nil, {Player.Play, Player.Discard})
  end)
  lu.assertEquals(comp2:getHandcardNum(), 4)
  lu.assertEquals(comp2.general, "anjiang")
end)

Fk:loadTranslationTable{
  ['hengjiang'] = '横江',
  [':hengjiang'] = '当你受到伤害后，你可以令当前回合角色本回合手牌上限-X（X为其装备区内牌数且至少为1）。' ..
    '然后若其本回合弃牌阶段内没有弃牌，你将手牌摸至体力上限。',
  ['@hengjiang-turn'] = '横江',
  ['#hengjiang_delay'] = '横江',

  ['$hengjiang1'] = '霸必奋勇杀敌，一雪夷陵之耻！',
  ['$hengjiang2'] = '江横索寒，阻敌绝境之中！',
}
return hengjiang
