local extension = Package:new("jyzs")
extension.extensionName = "hegemony"
extension.game_modes_whitelist = { "nos_heg_mode", "new_heg_mode" }

extension:loadSkillSkelsByPath("./packages/hegemony/pkg/jyzs/skills")

Fk:loadTranslationTable{
  ["jyzs"] = "金印紫授",
  ["jy_heg"] = "金印",
}

local duyu = General:new(extension, "jy_heg__duyu", "jin", 4)
duyu.mainMaxHpAdjustedValue = -1
duyu:addSkills{ "jy_heg__sanchen", "jy_heg__pozhu" }

Fk:loadTranslationTable{
  ["jy_heg__duyu"] = "杜预",
}

local bailingyun = General:new(extension, "jy_heg__bailingyun", "jin", 3, 3, General.Female)
bailingyun:addSkills{ "jy_heg__xiace", "jy_heg__limeng" }
bailingyun:addCompanions("zq_heg__simayi")

Fk:loadTranslationTable{
  ["jy_heg__bailingyun"] = "柏夫人",
}

return extension
