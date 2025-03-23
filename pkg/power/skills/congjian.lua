local congjian = fk.CreateSkill{
  name = 'ld__congjian',
  tags = {Skill.Compulsory},
}
congjian:addEffect(fk.DamageInflicted, {
  anim_type = "negative",
  can_trigger = function(self, event, target, player, data)
    if not (target == player and player:hasSkill(congjian.name)) then return end
    return player.room.current == player
  end,
  on_use = function(_, _, _, _, data)
    data:changeDamage(1)
  end,
})
congjian:addEffect(fk.DamageCaused, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if not (target == player and player:hasSkill(congjian.name)) then return end
    return player.room.current ~= player
  end,
  on_use = function(_, _, _, _, data)
    data:changeDamage(1)
  end,
})

Fk:loadTranslationTable{
  ['ld__congjian'] = '从谏',
  [':ld__congjian'] = '锁定技，当你于回合外造成伤害时或于回合内受到伤害时，伤害值+1。',

  ['$ld__congjian1'] = '听君荐言，取为王，保宗嗣！',
  ['$ld__congjian2'] = '从谏良计，可得自保。',
}

return congjian
