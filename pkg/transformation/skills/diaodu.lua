local diaodu = fk.CreateSkill{
  name = "diaodu",
}
local H = require "packages/hegemony/util"
diaodu:addEffect(fk.CardUsing, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(diaodu.name) then return false end
    return H.compareKingdomWith(target, player) and data.card.type == Card.TypeEquip
      and (player:hasShownSkill(diaodu.name) or player == target)
      and target:getMark("diaodu_use-turn") == 0

  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(target, {skill_name = diaodu.name, prompt = "#diaodu-invoke"})
  end,
  on_use = function(self, event, target, player, data)
    target:drawCards(1, diaodu.name)
    player.room:setPlayerMark(target, "diaodu_use-turn", 1)
  end,
})

diaodu:addEffect(fk.EventPhaseStart, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(diaodu.name) then return false end
    return target == player and target.phase == Player.Play and table.find(player.room.alive_players, function(p)
      return H.compareKingdomWith(p, player) and #p:getCardIds(Player.Equip) > 0 end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room.alive_players, function(p)
      return H.compareKingdomWith(p, player) and #p:getCardIds(Player.Equip) > 0 end)
    if #targets == 0 then return false end
    local tos = room:askToChoosePlayers(player, {targets = targets, min_num = 1, max_num = 1,
      prompt = "#diaodu-choose", skill_name = diaodu.name, cancelable = true})
    if #tos > 0 then
      event:setCostData(self, {tos = tos})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    target = event:getCostData(self).tos[1]
    local cid = room:askForCardChosen(player, target, "e", diaodu.name)
    room:obtainCard(player, cid, true, fk.ReasonPrey)
    if not table.contains(player:getCardIds(Player.Hand), cid) then return false end
    local card = Fk:getCardById(cid)
    if player.dead then return false end
    local targets = table.map(table.filter(room.alive_players, function(p) return p ~= player and p ~= target end), Util.IdMapper)
    -- local to = room:askForChoosePlayers(player, targets, 1, 1, "#diaodu-give:::" .. card:toLogString(), diaodu.name, target ~= player)
    local to = room:askForChoosePlayers(player, targets, 1, 1, "#diaodu-give:::" .. card:toLogString(), diaodu.name, true)
    if #to > 0 then
      room:moveCardTo(card, Card.PlayerHand, room:getPlayerById(to[1]), fk.ReasonGive, diaodu.name, nil, true, player.id)
    end
  end,
})

Fk:loadTranslationTable{
  ['diaodu'] = '调度',
  [':diaodu'] = '①每回合限一次，当与你势力相同的角色使用装备牌时，其可摸一张牌。②出牌阶段开始时，你可获得与你势力相同的一名角色装备区里的一张牌，然后你可将此牌交给另一名角色。',

  ["#diaodu-invoke"] = "调度：你可摸一张牌",
  ["#diaodu-choose"] = "调度：你可获得与你势力相同的一名角色装备区里的一张牌",
  ["#diaodu-give"] = "调度：将%arg交给另一名角色",

  ["$diaodu1"] = "诸军兵器战具，皆由我调配！",
  ["$diaodu2"] = "甲胄兵器，按我所说之法分发！",
}

return diaodu
