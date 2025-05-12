local shangshi = fk.CreateSkill{
  name = "zq__shangshi",
}

Fk:loadTranslationTable{
  ["zq__shangshi"] = "伤逝",
  [":zq__shangshi"] = "每名角色的回合结束时，你可以将手牌摸至已损失体力值。",
}

shangshi:addEffect(fk.TurnEnd, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(shangshi.name) and player:getHandcardNum() < player:getLostHp()
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(player:getLostHp() - player:getHandcardNum(), shangshi.name)
  end,
})

shangshi:addTest(function(room, me)
  local comp2 = room.players[2]
end)

return shangshi

