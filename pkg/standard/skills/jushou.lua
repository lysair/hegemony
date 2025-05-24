local jushou = fk.CreateSkill{
  name = "hs__jushou",
}
local H = require "packages/hegemony/util"
jushou:addEffect(fk.EventPhaseStart, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Finish
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local num = 0
    for _, v in pairs(H.getKingdomPlayersNum(room)) do
      if v and v > 0 then
        num = num + 1
      end
    end
    room:drawCards(player, num, self.name)
    if player.dead then return false end
    local cards = {}
    for _, id in pairs(player:getCardIds("h")) do
      local card = Fk:getCardById(id)
      if (card.type == Card.TypeEquip and not player:prohibitUse(card)) or (card.type ~= Card.TypeEquip and not player:prohibitDiscard(card)) then
        table.insert(cards, id)
      end
    end
    if #cards == 0 then return end
    local card = room:askToCards(player, {min_num = 1, max_num = 1, skill_name = jushou.name,
      pattern = tostring(Exppattern{ id = cards }), cancelable = false, prompt = "#hs__jushou-select"})[1]
    if card then
      if Fk:getCardById(card).type == Card.TypeEquip then
        room:useCard{
          from = player,
          tos = { player },
          card = Fk:getCardById(card),
        }
      else
        room:throwCard(card, self.name, player, player)
      end
    end
    if player.dead then return false end
    if num > 2 then player:turnOver() end
  end,
})

jushou:addTest(function (room, me)
  -- test1: 装备
  local equip = table.find(room.draw_pile, function(cid)
    return Fk:getCardById(cid).type == Card.TypeEquip and Fk:getCardById(cid).sub_type ~= Card.SubtypeWeapon
  end)
  local nonEquip = table.find(room.draw_pile, function(cid)
    return Fk:getCardById(cid).type ~= Card.TypeEquip
  end)
  local halberd = room:printCard("halberd")
  local num = 0
  for _, v in pairs(H.getKingdomPlayersNum(room)) do
    if v and v > 0 then
      num = num + 1
    end
  end
  FkTest.setNextReplies(me, { "1" })
  FkTest.setRoomBreakpoint(me, "AskForUseActiveSkill") -- 断点
  FkTest.runInRoom(function ()
    room:moveCardTo(nonEquip, Card.DrawPile) -- 牌堆第2张牌，非装备
    room:moveCardTo(equip, Card.DrawPile) -- 牌堆第1张牌，装备
    room:useCard{
      from = me,
      tos = { me },
      card = halberd,
    }
    room:handleAddLoseSkills(me, jushou.name)
    GameEvent.Turn:create(TurnData:new(me, "game_rule", { Player.Finish })):exec()
  end)
  local handler = ClientInstance.current_request_handler --[[@as ReqActiveSkill]]
  lu.assertIsFalse(handler:cardValidity(halberd.id)) -- 不能选装备区
  FkTest.setNextReplies(me, {json.encode {
    card = { skill = "choose_cards_skill", subcards = { equip } },
    targets = {}
  } })
  FkTest.resumeRoom() -- 继续
  lu.assertEquals(me:getHandcardNum(), num - 1)
  lu.assertEquals(#me:getCardIds("e"), 2)
  lu.assertEquals(#room.discard_pile, 0)
  if num > 2 then
    lu.assertIsFalse(me.faceup)
  end

  -- test2: 非装备
  FkTest.setNextReplies(me, {"1", json.encode {
    card = { skill = "choose_cards_skill", subcards = { nonEquip } },
    targets = {}
  } })
  FkTest.runInRoom(function ()
    if not me.faceup then me:turnOver() end
    GameEvent.Turn:create(TurnData:new(me, "game_rule", { Player.Finish })):exec()
  end)
  lu.assertEquals(me:getHandcardNum(), 2 * num - 2)
  lu.assertEquals(#me:getCardIds("e"), 2)
  lu.assertEquals(#room.discard_pile, 1)
end)

Fk:loadTranslationTable{
  ["hs__jushou"] = "据守",
  [":hs__jushou"] = "结束阶段，你可摸X张牌（X为势力数），然后弃置一张手牌，若以此法弃置的牌为装备牌，则改为你使用之。若X大于2，则你将武将牌叠置。",

  ["#hs__jushou_select"] = "据守",
  ["#hs__jushou-select"] = "据守：选择使用手牌中的一张装备牌或弃置手牌中的一张非装备牌",

  ["$hs__jushou1"] = "我先休息一会儿！",
  ["$hs__jushou2"] = "尽管来吧！",
}

return jushou
