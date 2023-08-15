local extension = Package:new("hegemony_standard")

local heg_mode = require "packages.hegemony.hegemony"
extension:addGameMode(heg_mode)

return extension
