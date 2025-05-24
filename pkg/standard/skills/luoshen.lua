local luoshen = fk.CreateSkill{
  name = "hs__luoshen",
}
luoshen:addEffect(fk.EventPhaseStart, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(luoshen.name) and player.phase == Player.Start
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cardsJudged = {}
    while true do
      local judge = {
        who = player,
        reason = luoshen.name,
        pattern = ".|.|spade,club",
        skipDrop = true,
      }
      room:judge(judge)
      local card = judge.card
      if card.color == Card.Black then
        table.insert(cardsJudged, card)
      elseif room:getCardArea(card) == Card.Processing then
        room:moveCardTo(card, Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile, luoshen.name, nil, true, player)
      end
      if not judge:matchPattern() or player.dead or not room:askToSkillInvoke(player, {skill_name = luoshen.name}) then
        break
      end
    end
    cardsJudged = table.filter(cardsJudged, function(c) return room:getCardArea(c.id) == Card.Processing end)
    if #cardsJudged > 0 then
      room:obtainCard(player, cardsJudged, true, fk.ReasonJustMove)
    end
  end,
})

luoshen:addTest(function(room, me)
  FkTest.runInRoom(function()
    room:handleAddLoseSkills(me, "hs__luoshen")
  end)
  local red = table.find(room.draw_pile, function(cid)
    return Fk:getCardById(cid).color == Card.Red
  end)
  local blacks = table.filter(room.draw_pile, function(cid)
    return Fk:getCardById(cid).color == Card.Black
  end)
  local rnd = 5
  FkTest.setNextReplies(me, { "1", "1", "1", "1", "1", "1" }) -- 除了第一个1以外后面全是潜在的“重复流程”
  -- 每次往红牌顶上塞若干个黑牌
  FkTest.runInRoom(function()
    room:throwCard(me:getCardIds("h"), nil, me, me)
    -- 控顶
    room:moveCardTo(red, Card.DrawPile)
    if rnd > 0 then room:moveCardTo(table.slice(blacks, 1, rnd + 1), Card.DrawPile) end
    GameEvent.Turn:create(TurnData:new(me, "game_rule", { Player.Start })):exec()
  end)
  lu.assertEquals(#me:getCardIds("h"), rnd)
end)

Fk:loadTranslationTable{
  ["hs__luoshen"] = "洛神",
  [":hs__luoshen"] = "准备阶段开始时，你可进行判定，你可重复此流程，直到判定结果为红色，然后你获得所有黑色的判定牌。",

  ["$hs__luoshen1"] = "髣髴兮若轻云之蔽月。",
  ["$hs__luoshen2"] = "飘飖兮若流风之回雪。",
}

return luoshen
