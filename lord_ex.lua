local H = require "packages/hegemony/util"
local extension = Package:new("lord_ex")
extension.extensionName = "hegemony"
extension.game_modes_whitelist = { 'nos_heg_mode', 'new_heg_mode' }

Fk:loadTranslationTable{
  ["lord_ex"] = "君临天下·EX/不臣篇",
}

local zhonghui = General(extension, "ld__zhonghui", "wild", 4)
zhonghui.total_hidden = true
-- zhonghui:addCompanions("ld__jiangwei")
local quanji = fk.CreateTriggerSkill{
  name = "ld__quanji",
}
local paiyi = fk.CreateActiveSkill{
  name = "ld__paiyi",
}
zhonghui:addSkill(quanji)
zhonghui:addSkill(paiyi)

Fk:loadTranslationTable{
  ["ld__zhonghui"] = "钟会",
  ["ld__quanji"] = "权计",
  ["ld__paiyi"] = "排异",

  ["$ld__quanji1"] = "不露圭角，择时而发！",
  ["$ld__quanji2"] = "晦养厚积，乘势而起！",
  ["$ld__paiyi1"] = "排斥异己，为王者必由之路！",
  ["$ld__paiyi2"] = "非吾友，则必敌也！",
  ["~ld__zhonghui"] = "吾机关算尽，却还是棋错一着……",
}

return extension
