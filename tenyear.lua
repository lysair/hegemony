local extension = Package:new("tenyear")
extension.extensionName = "hegemony"
extension.game_modes_whitelist = { 'nos_heg_mode', 'new_heg_mode' }

local H = require "packages/hegemony/util"

Fk:loadTranslationTable{
  ["tenyear"] = "十周年-国战专属",
}

local jianggan = General(extension, "ty__jianggan", "wei", 3)
jianggan:addSkill("weicheng")
jianggan:addSkill("daoshu")
Fk:loadTranslationTable{
  ['ty__jianggan'] = '蒋干',
  ["~ty__jianggan"] = "丞相，再给我一次机会啊！",
}

return extension
