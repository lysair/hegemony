local hengzheng = fk.CreateSkill{
  name = 'hengzheng',
}
hengzheng:addEffect(fk.EventPhaseStart, {
  anim_type = "big", -- 神杀特色
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(hengzheng.name) and player.phase == Player.Draw and
      (player.hp == 1 or player:isKongcheng()) and
      table.find(player.room:getOtherPlayers(player, false), function(p) return not p:isAllNude() end)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    data.phase_end = true
    for _, p in ipairs(room:getOtherPlayers(player, true)) do
      if not p:isAllNude() and player:isAlive() and p:isAlive() then
        local id = room:askForCardChosen(player, p, "hej", hengzheng.name)
        room:obtainCard(player, id, false)
      end
    end
  end,
})

Fk:loadTranslationTable{
  ['hengzheng'] = '横征',
  [':hengzheng'] = '摸牌阶段，若你体力值为1或者没有手牌，你可改为获得所有其他角色区域内各一张牌。',

  ['$hengzheng1'] = '老夫进京平乱，岂能空手而归？',
  ['$hengzheng2'] = '谁的？都是我的！',
}

return hengzheng
