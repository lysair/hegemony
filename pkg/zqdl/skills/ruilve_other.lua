local ruilve_other = fk.CreateSkill {
  name = "zq_heg__ruilve_other&",
}

Fk:loadTranslationTable {
  ["zq_heg__ruilve_other&"] = "睿略",
  [":zq_heg__ruilve_other&"] = "出牌阶段限一次，你可以展示并交给司马师一张伤害类牌，然后你摸一张牌。",
  ["#zq_heg__ruilve_ask"] = "睿略: 选择一张伤害类牌",
}

ruilve_other:addEffect("active", {
  anim_type = "support",
  prompt = "#zq_heg__ruilve_ask",
  card_num = 1,
  target_num = 0,
  can_use = function(self, player)
    return player:usedSkillTimes(ruilve_other.name, Player.HistoryPhase) == 0 and player:hasSkill(ruilve_other.name)
  end,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).is_damage_card
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    player:broadcastSkillInvoke("zq_heg__ruilve")
    if #effect.cards > 0 then
      player:showCards(effect.cards)
    end
    local targets = table.filter(room:getOtherPlayers(player, false),
      function(p) return p:hasShownSkill("zq_heg__ruilve") end)
    if #targets == 0 then return false end
    local to
    if #targets == 1 then
      to = targets[1]
    else
      to = room:askToChoosePlayers(player, {
        targets = targets,
        min_num = 1,
        max_num = 1,
        skill_name = ruilve_other.name,
        cancelable = false,
      })
    end
    room:doIndicate(player, to)
    room:moveCardTo(effect.cards, Player.Hand, to, fk.ReasonGive, ruilve_other.name, nil, false, to)
    player:drawCards(1, ruilve_other.name)
  end,
})

return ruilve_other
