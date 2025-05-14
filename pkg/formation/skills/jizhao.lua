local jizhao = fk.CreateSkill{
  name = "jizhao",
  tags = {Skill.Limited},
}
jizhao:addEffect(fk.AskForPeaches, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(jizhao.name) and player.dying and player:usedSkillTimes(jizhao.name, Player.HistoryGame) == 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if player:getHandcardNum() < player.maxHp then
      room:drawCards(player, player.maxHp - player:getHandcardNum(), jizhao.name)
    end
    if player.hp < 2 and not player.dead then
      room:recover{
        who = player,
        num = 2 - player.hp,
        recoverBy = player,
        skillName = jizhao.name,
      }
    end
    room:handleAddLoseSkills(player, "-shouyue|ex__rende", nil)
  end,
})

return jizhao
