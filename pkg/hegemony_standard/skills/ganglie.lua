local ganglie = fk.CreateSkill{
  name = "hs__ganglie",
}
ganglie:addEffect(fk.Damaged, {
  anim_type = "masochism",
  on_trigger = function(self, event, target, player, data)
    self:doCost(event, target, player, data)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local from = data.from
    if from and not from.dead then room:doIndicate(player, {from}) end
    local judge = {
      who = player,
      reason = ganglie.name,
      pattern = ".",
    }
    room:judge(judge)
    if judge.card.color == Card.Red and from and not from.dead then
      room:damage{
        from = player,
        to = from,
        damage = 1,
        skillName = ganglie.name,
      }
    elseif judge.card.color == Card.Black and from and not from:isNude() and not from.dead then
      local cid = room:askToChooseCard(player, {target = from, flag = "he", skill_name = ganglie.name})
      room:throwCard({cid}, ganglie.name, from, player)
    end
  end
})

ganglie:addTest(function (room, me)
  local comp2 = room.players[2]
  FkTest.setNextReplies(me, { "1", "8", "1", "1" }) -- 第二个是弃置comp2牌
  local red = table.find(room.draw_pile, function(cid)
    return Fk:getCardById(cid).color == Card.Red and cid ~= 8
  end)
  local black = table.find(room.draw_pile, function(cid)
    return Fk:getCardById(cid).color == Card.Black and cid ~= 8
  end)
  FkTest.runInRoom(function ()
    room:handleAddLoseSkills(me, ganglie.name)
    room:moveCardTo(red, Card.DrawPile)
    room:moveCardTo(black, Card.DrawPile)
    room:obtainCard(comp2, 8)
    room:damage{
      from = comp2,
      to = me,
      damage = 1,
    }
    room:damage{
      from = comp2,
      to = me,
      damage = 1,
    }
    room:damage{
      from = nil,
      to = me,
      damage = 1,
    }
  end)
  lu.assertEquals(comp2.hp, 3)
  lu.assertEquals(comp2:getHandcardNum(), 0)
end)

Fk:loadTranslationTable{
  ["hs__ganglie"] = "刚烈",
  [":hs__ganglie"] = "当你受到伤害后，你可判定，若结果为：红色，你对来源造成1点伤害；黑色，你弃置来源的一张牌。",

  ["$hs__ganglie1"] = "",
  ["$hs__ganglie2"] = "",
}

return ganglie
