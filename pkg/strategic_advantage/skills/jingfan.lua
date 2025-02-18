local jingfanSkill = fk.CreateSkill {
  name = "#jingfan_skill",
  attached_equip = "jingfan",
  frequency = Skill.Compulsory,
}
jingfanSkill:addEffect("distance", {
  correct_func = function(self, from, to)
    if from:hasSkill(jingfanSkill.name) then
      return -1
    end
  end,
})

Fk:loadTranslationTable{
  ["jingfan"] = "惊帆",
  [":jingfan"] = "装备牌·坐骑<br /><b>坐骑技能</b>：你与其他角色的距离-1。",
}

return jingfanSkill
