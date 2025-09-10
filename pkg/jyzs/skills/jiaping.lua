local jiaping = fk.CreateSkill {
  name = "jy_heg__jiaping",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable {
  ["jy_heg__jiaping"] = "嘉平",
  [":jy_heg__jiaping"] = "<b><font color='goldenrod'>君主技</font></b>，你拥有“八荒死士令”。<br>" ..
  "#<b>八荒死士令</b>：每轮限一次，所有本轮明置过武将牌的晋势力角色可以移除其副将的武将牌并发动以下一个未以此法发动过的技能：“瞬覆”，“奉迎”，“将略”，“勇进”和“乱武”。",
}

jiaping:addEffect(fk.GeneralRevealed, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(jiaping.name, true) then
      for _, v in pairs(data) do
        if table.contains(Fk.generals[v]:getSkillNameList(), jiaping.name) then return true end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:handleAddLoseSkills(player, "#sishiling")
  end,
})

return jiaping
