local extension = Package:new("ziqidonglai")
extension.extensionName = "hegemony"
extension.game_modes_whitelist = { 'nos_heg_mode', 'new_heg_mode' }

extension:loadSkillSkelsByPath("./packages/hegemony/pkg/zqdl/skills")

Fk:loadTranslationTable{
  ["ziqidonglai"] = "紫气东来",
  ["zq"] = "紫气",
}

General:new(extension, "zq__shibao", "jin", 4):addSkill("zhuosheng")

Fk:loadTranslationTable{
  ["zq__shibao"] = "石苞",
  ["#zq__shibao"] = "经国之才",
  ["illustrator:zq__shibao"] = "凝聚永恒",
}

General:new(extension, "zq__wangjun", "jin", 4):addSkill("zq__chengliu")
Fk:loadTranslationTable{
  ["zq__wangjun"] = "王濬",
  ["#zq__wangjun"] = "顺流长驱",
  ["illustrator:zq__wangjun"] = "荆芥",
}

return extension
