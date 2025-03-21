local duanxie = fk.CreateSkill{
  name = 'duanxie',
}
duanxie:addEffect("active", {
  anim_type = 'offensive',
  can_use = function(self, player)
    return player:usedSkillTimes(duanxie.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected)
    return to_select ~= player and not to_select.chained
  end,
  max_target_num = function (self, player)
    return math.max(1, player.maxHp - player.hp)
  end,
  min_target_num = 1,
  on_use = function(self, room, effect)
    local player = effect.from
    for _, target in ipairs(effect.tos) do
      if not target.chained then
        target:setChainState(true)
      end
    end
    if not player.chained then
      player:setChainState(true)
    end
  end,
})

Fk:loadTranslationTable{
  ['duanxie'] = '断绁',
  [':duanxie'] = '出牌阶段限一次，你可以令至多X名其他角色横置，然后你横置（X为你已损失的体力值且至少为1）。',

  ["$duanxie1"] = "区区绳索就想挡住吾等去路？！",
  ["$duanxie2"] = "以身索敌，何惧同伤！",
}

return duanxie
