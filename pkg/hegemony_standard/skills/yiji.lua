local yiji = fk.CreateSkill{
  name = "hs__yiji",
}
yiji:addEffect(fk.Damaged, {
  anim_type = "masochism",
  events = {},
  on_use = function(self, event, target, player, data)
    local room = player.room
    local ids = room:getNCards(2)
    while true do
      room:setPlayerMark(player, "hs__yiji_cards", ids)
      local _, ret = room:askToUseActiveSkill(player, {skill_name = "hs__yiji_active", prompt = "#hs__yiji-give", cancelable = true, no_indicate = true})
      room:setPlayerMark(player, "hs__yiji_cards", 0)
      if ret then
        for _, id in ipairs(ret.cards) do
          table.removeOne(ids, id)
        end
        room:moveCardTo(ret.cards, Card.PlayerHand, ret.targets[1], fk.ReasonGive, "hs__yiji", nil, false, player)
        if #ids == 0 then break end
        if player.dead then
          room:moveCards({
            ids = ids,
            toArea = Card.DiscardPile,
            moveReason = fk.ReasonJustMove,
            skillName = "hs__yiji",
          })
          break
        end
      else
        room:moveCardTo(ids, Player.Hand, player, fk.ReasonGive, "hs__yiji", nil, false, player)
        break
      end
    end
  end,
})

yiji:addTest(function (room, me)
  local comp2 = room.players[2]
  local cards = {Fk:getCardById(1), Fk:getCardById(2)}
  FkTest.setNextReplies(me, { "1" ,
  json.encode {
    card = { skill = "hs__yiji_active", subcards = { 2 } },
    targets = { comp2.id }
  } })
  FkTest.runInRoom(function()
    room:handleAddLoseSkills(me, yiji.name)
    room:moveCardTo(cards, Card.DrawPile)
    room:damage{
      from = comp2,
      to = me,
      damage = 1,
    }
  end)
  lu.assertEquals(me:getHandcardNum(), 1)
  lu.assertEquals(comp2:getHandcardNum(), 1)
  lu.assertEquals(me:getCardIds(Player.Hand)[1], 1)
  lu.assertEquals(comp2:getCardIds(Player.Hand)[1], 2)
end)

Fk:loadTranslationTable{
  ["hs__yiji"] = "遗计",
  [":hs__yiji"] = "当你受到伤害后，你可观看牌堆顶的两张牌并分配。",

  ["#hs__yiji-give"] = "遗计：你可以将这些牌分配给其他角色，或点“取消”自己保留",
  ["hs__yiji_active"] = "遗计",

  ["$hs__yiji1"] = "也好。",
  ["$hs__yiji2"] = "罢了。",
}

return yiji
