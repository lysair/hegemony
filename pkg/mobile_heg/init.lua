local extension = Package:new("mobile_heg")
extension.extensionName = "hegemony"
extension.game_modes_whitelist = { 'nos_heg_mode', 'new_heg_mode' }

extension:loadSkillSkelsByPath("./packages/hegemony/pkg/mobile_heg/skills")

Fk:loadTranslationTable{
  ["mobile_heg"] = "国战-手杀专属",
  ["m_heg"] = "手杀",
}

General:new(extension, "m_heg__duyu", "qun", 4):addSkills{ "m_heg__wuku", "m_heg__miewu" }
Fk:loadTranslationTable{
  ["m_heg__duyu"] = "杜预",
  ["#m_heg__duyu"] = "文成武德",
  ["illustrator:m_heg__duyu"] = "鬼画府",

  ["~m_heg__duyu"] = "洛水圆石，遂道向南，吾将以俭自完耳……",
}

General:new(extension, "m_heg__dongcheng", "qun", 4):addSkills{ "m_heg__chengzhao" }
Fk:loadTranslationTable{
  ["m_heg__dongcheng"] = "董承",
  ["#m_heg__dongcheng"] = "沥胆卫汉",
  --["illustrator:m_heg__dongcheng"] = "",

  ["~m_heg__dongcheng"] = "九泉之下，我等着你曹贼到来！",
}

return extension
