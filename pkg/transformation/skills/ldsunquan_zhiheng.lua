local ld__zhiheng = fk.CreateSkill{
  name = "ld__lordsunquan_zhiheng",
}

Fk:loadTranslationTable{
  ["ld__lordsunquan_zhiheng"] = "制衡",
  [":ld__lordsunquan_zhiheng"] = "出牌阶段限一次，你可以弃置至多X张牌（X为你体力上限），摸等量的牌。",

  ["$ld__lordsunquan_zhiheng1"] = "二宫并阙，孤之所愿。",
  ["$ld__lordsunquan_zhiheng2"] = "鲁王才兼文武，堪比太子。",
}
ld__zhiheng:addEffect("active", {
  anim_type = "drawcard",
  can_use = function(self, player)
    return player:usedSkillTimes(ld__zhiheng.name, Player.HistoryPhase) == 0
  end,
  target_num = 0,
  min_card_num = 1,
  max_card_num = function(self, player)
    return table.find(player:getEquipments(Card.SubtypeTreasure), function(cid)
      return Fk:getCardById(cid).name == "luminous_pearl"
    end) and 998 or player.maxHp
  end,
  card_filter = function(self, player, to_select, selected)
    if #selected >= player.maxHp then
      return table.find(player:getEquipments(Card.SubtypeTreasure), function(cid)
        return Fk:getCardById(cid).name == "luminous_pearl" and not table.contains(selected, cid) and to_select ~= cid
      end)
    end
    return #selected < player.maxHp and not player:prohibitDiscard(Fk:getCardById(to_select))
  end,
  on_use = function(self, room, effect)
    local from = effect.from
    room:throwCard(effect.cards, ld__zhiheng.name, from, from)
    if not from.dead then
      from:drawCards(#effect.cards, ld__zhiheng.name)
    end
  end
})

return ld__zhiheng
