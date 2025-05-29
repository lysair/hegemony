local quanjin = fk.CreateSkill {
  name = "quanjin",
}

Fk:loadTranslationTable {
  ["quanjin"] = "劝进",
  [":quanjin"] = "出牌阶段限一次，你可将一张手牌交给一名此阶段受到过伤害的角色，对其发起“军令”。若其执行，你摸一张牌；若其不执行，你将手牌摸至与手牌最多的角色相同（最多摸五张）。",

  ["#quanjin-active"] = "发动 劝进，选择一张手牌交给一名此阶段内受到过伤害的角色并对其发起军令",

  ["$quanjin1"] = "今称魏公，则可以藩卫之名，征吴伐蜀也。",
  ["$quanjin2"] = "明公受封，正合天心人意！",
}

local H = require "packages/hegemony/util"

quanjin:addEffect("active", {
  prompt = "#quanjin-active",
  anim_type = "control",
  can_use = function(self, player)
    return player:usedSkillTimes(quanjin.name, Player.HistoryPhase) == 0
  end,
  card_num = 1,
  card_filter = function(self, player, to_select, selected)
    return #selected < 1 and Fk:currentRoom():getCardArea(to_select) == Player.Hand
  end,
  target_num = 1,
  target_filter = function(self, player, to_select, selected, selected_cards)
    return #selected == 0 and to_select ~= player.id and
    to_select:getMark("_quanjin-phase") > 0                                                      -- and #selected_cards == 1
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    room:moveCardTo(effect.cards, Card.PlayerHand, target, fk.ReasonGive, quanjin.name, nil, false, player.id)
    if H.askCommandTo(player, target, quanjin.name) then
      player:drawCards(1, quanjin.name)
    else
      local num = player:getHandcardNum()
      for hc, p in ipairs(room.alive_players) do
        hc = p:getHandcardNum()
        if hc > num then
          num = hc
        end
      end
      num = math.min(num - player:getHandcardNum(), 5)
      player:drawCards(num, quanjin.name)
    end
  end,
})
quanjin:addAcquireEffect(function(self, player, is_start)
  if is_start then return end
  local room = player.room
  room.logic:getActualDamageEvents(998, function(e)
    local damage = e.data[1]
    local to = damage.to
    if to and to:getMark("_quanjin-phase") == 0 then
      room:setPlayerMark(to, "_quanjin-phase", 1)
    end
    return false
  end, Player.HistoryPhase)
end)
quanjin:addEffect(fk.Damaged, {
  name = "#quanjin_recorder",
  can_refresh = function(self, event, target, player, data)
    return player:hasSkill(quanjin.name, true) and player.phase == Player.Play -- FIXME
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(target, "_quanjin-phase", 1)
  end,
})

return quanjin
