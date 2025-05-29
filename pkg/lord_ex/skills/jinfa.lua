local jinfa = fk.CreateSkill{
    name = "ld__jinfa",
}

Fk:loadTranslationTable{
    ["ld__jinfa"] = "矜伐",
    [":ld__jinfa"] = "出牌阶段限一次，你可弃置一张牌并选择一名其他角色，令其选择一项：1.令你获得其一张牌；2.交给你一张装备牌，若此装备牌为♠，其视为对你使用一张【杀】。",

    ["#ld__jinfa"] = "矜伐：弃置一张牌并选择一名其他角色",
    ["#ld__jinfa_give"] = "矜伐：交给 %src 一张装备牌，否则文钦获得你的一张牌",

    ["$ld__jinfa1"] = "居功者，当自矜，为将者，当善伐。",
    ["$ld__jinfa2"] = "此战伐敌所获，皆我之功。",
}

jinfa:addEffect("active",{
  anim_type = "offensive",
  prompt = "#ld__jinfa",
  card_num = 1,
  target_num = 1,
  can_use = function (self, player)
    return player:usedSkillTimes(jinfa.name, Player.HistoryPhase) == 0 and not player:isNude()
  end,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and not player:prohibitDiscard(to_select)
  end,
  target_filter = function(self, player,to_select, selected, selected_cards)
    local target = to_select
    return #selected == 0 and not target:isNude() and to_select ~= player
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    room:throwCard(effect.cards, jinfa.name, player, player)
    local card1 = room:askToCards(target,{
        min_num = 1,
        max_num = 1,
        include_equip = true,
        skill_name = jinfa.name,
        prompt = "#ld__jinfa_give:"..player.id,
        pattern = ".|.|.|.|.|equip",
        cancelable = true,
    })
    if #card1 == 1 then
      room:obtainCard(player.id, card1[1], true, fk.ReasonGive)
      if Fk:getCardById(card1[1]).suit == Card.Spade then
        local card = Fk:cloneCard("slash")
        if not (target:prohibitUse(card) or target:isProhibited(player, card)) then
          room:useVirtualCard("slash", nil, target, player)
        end
      end
    else
      if target:isNude() then return end
      local card2 = room:askToChooseCard(player,{
        target = target,
        flag = "he",
        skill_name = jinfa.name,
      })
      room:obtainCard(player, card2, false, fk.ReasonPrey)
    end
  end,
})

return jinfa