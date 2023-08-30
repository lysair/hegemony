local extension = Package:new("tenyear_heg")
extension.extensionName = "hegemony"
extension.game_modes_whitelist = { 'nos_heg_mode', 'new_heg_mode' }

local H = require "packages/hegemony/util"

Fk:loadTranslationTable{
  ["tenyear_heg"] = "十周年-国战专属",
  ["ty_heg"] = "新服",
}

local jianggan = General(extension, "ty_heg__jianggan", "wei", 3)
jianggan:addSkill("weicheng")
jianggan:addSkill("daoshu")
Fk:loadTranslationTable{
  ['ty_heg__jianggan'] = '蒋干',
  ["~ty_heg__jianggan"] = "丞相，再给我一次机会啊！",
}

return extension
