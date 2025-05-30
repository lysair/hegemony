local jieyue = fk.CreateSkill{
  name = "ld__jieyue",
}
local H = require "packages/hegemony/util"
jieyue:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(jieyue.name) and player.phase == Player.Start
      and not player:isKongcheng() and table.find(player.room.alive_players, function(p) return
        p.kingdom ~= "wei" and p ~= player
      end)
  end,
  on_cost = function(self, event, target, player, data)
    local plist, cards = player.room:askToChooseCardsAndPlayers(player, {
      targets = table.filter(player.room.alive_players, function(p) return
        p.kingdom ~= "wei" and p ~= player
      end),
      min_num = 1,
      max_num = 1,
      pattern = ".|.|.|hand",
      max_card_num = 1,
      min_card_num = 1,
      prompt = "#ld__jieyue-target",
      skill_name = jieyue.name,
      cancelable = true})
    if #plist > 0 then
      event:setCostData(self, {tos = plist, cards = cards})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    room:moveCardTo(event:getCostData(self).cards, Player.Hand, to, fk.ReasonGive, jieyue.name, nil, false, player.id)
    if H.askCommandTo(player, to, jieyue.name) then
      player:drawCards(1, jieyue.name)
    else
      room:addPlayerMark(player, "_ld__jieyue-turn")
    end
  end
})
jieyue:addEffect(fk.DrawNCards, {
  is_delay_effect = true,
  mute = true,
  can_use = function(self, event, target, player, data)
    return target == player and target:getMark("_ld__jieyue-turn") > 0
  end,
  on_use = function(self, event, target, player, data)
    data.n = data.n + 3 * target:getMark("_ld__jieyue-turn")
  end,
})

Fk:loadTranslationTable{
  ['ld__jieyue'] = '节钺',
  [':ld__jieyue'] = '准备阶段，你可将一张手牌交给不是魏势力或没有势力的一名角色，对其发起“军令”。若其：执行，你摸一张牌；不执行，摸牌阶段，你令额定摸牌数+3。',

  ["#ld__jieyue-target"] = "节钺：你可将一张手牌交给不是魏势力或没有势力的一名角色，对其发起军令",
  ["#ld__jieyue_draw"] = "节钺",

  ["$ld__jieyue1"] = "杀我？你做不到！",
  ["$ld__jieyue2"] = "阳关大道，你不选吗？",
}

return jieyue
