local wildDraw = fk.CreateSkill{
  name = "wild_draw&",
}
local H = require "packages/hegemony/util"
wildDraw:addEffect("active", {
  prompt = "#wild_draw&",
  anim_type = "drawcard",
  can_use = function(self, player)
    return player:getMark("@!wild") > 0
  end,
  interaction = UI.ComboBox { choices = {"wild_vanguard", "wild_companion", "wild_yinyangfish"} },
  card_filter = Util.FalseFunc,
  target_num = function(self, player)
    return self.interaction.data == "wild_vanguard" and
      table.find(Fk:currentRoom().alive_players, function(p) return
        (p.general == "anjiang" or p.deputyGeneral == "anjiang") and p ~= player
      end) and 1 or 0
  end,
  target_filter = function(self, player, to_select, selected, selected_cards)
    if self.interaction.data == "wild_vanguard" and to_select ~= player
      and #selected == 0 and table.find(Fk:currentRoom().alive_players, function(p)
        return (p.general == "anjiang" or p.deputyGeneral == "anjiang") and p ~= player
      end) then
      return to_select.general == "anjiang" or to_select.deputyGeneral == "anjiang"
    end
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    H.removeHegMark(room, player, "vanguard", 1)
    local pattern = self.interaction.data
    if pattern == "wild_companion" then
      player:drawCards(2, wildDraw.name)
    elseif pattern == "wild_yinyangfish" then
      player:drawCards(1, wildDraw.name)
    elseif pattern == "wild_vanguard" then
      local num = 4 - player:getHandcardNum()
      if num > 0 then
        player:drawCards(num, wildDraw.name)
      end
      if #effect.tos == 0 or player.dead then return false end
      local target = effect.tos[1]
      local choices = {"known_both_main", "known_both_deputy"}
      if target.general ~= "anjiang" then
        table.remove(choices, 1)
      end
      if target.deputyGeneral ~= "anjiang" then
        table.remove(choices)
      end
      if #choices == 0 then return end
      local choice = room:askForChoice(player, choices, wildDraw.name, "#known_both-choice::"..target.id, false)
      local general = choice == "known_both_main" and {target:getMark("__heg_general"), target.deputyGeneral, target.seat} or {target.general, target:getMark("__heg_deputy"), target.seat}
      room:askForCustomDialog(player, wildDraw.name, "packages/hegemony/qml/KnownBothBox.qml", general)
    end
  end,
})

wildDraw:addEffect(fk.EventPhaseStart, {
  priority = 0.09,
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player.phase == Player.Discard and player:hasSkill(wildDraw.name)
      and player:getMark("@!wild") > 0 and player:getHandcardNum() > player:getMaxCards()
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = wildDraw.name,
      prompt = "#wild_max-ask",
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    H.removeHegMark(room, player, "vanguard", 1)
    room:addPlayerMark(target, MarkEnum.AddMaxCardsInTurn, 2)
  end,
})

Fk:loadTranslationTable{
  ["wild_draw&"] = "野心[牌]",
  [":wild_draw&"] = "你可弃一枚“野心家”，执行“先驱”、“阴阳鱼”或“珠联璧合”的效果。",
  ["#wild_draw&"] = "你可将“野心家”当一种标记弃置并执行其效果",
  ["wild_vanguard"] = "将手牌摸至4张，观看一张暗置武将牌",
  ["wild_yinyangfish"] = "摸一张牌",
  ["wild_companion"] = "摸两张牌",
  -- ["#wild_max&"] = "野心家[手牌上限]",
  ["#wild_max-ask"] = "你可弃一枚“野心家”，此回合手牌上限+2",
}
