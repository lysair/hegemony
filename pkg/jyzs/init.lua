local extension = Package:new("jyzs")
extension.extensionName = "hegemony"
extension.game_modes_whitelist = { "nos_heg_mode", "new_heg_mode" }

extension:loadSkillSkelsByPath("./packages/hegemony/pkg/jyzs/skills")

Fk:loadTranslationTable{
  ["jyzs"] = "金印紫授",
  ["jy_heg"] = "金印",
}

return extension
