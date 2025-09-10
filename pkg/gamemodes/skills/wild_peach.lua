local wildPeach = fk.CreateSkill{
  name = "wild_peach&",
}
local H = require "packages/hegemony/util"
wildPeach:addEffect("viewas", {
  anim_type = "support",
  prompt = "#wild_peach&",
  pattern = "peach",
  card_filter = Util.FalseFunc,
  view_as = function(self)
    local c = Fk:cloneCard("peach")
    c.skillName = wildPeach.name
    return c
  end,
  before_use = function(self, player)
    H.removeHegMark(player.room, player, "wild", 1)
  end,
  enabled_at_play = function(self, player)
    return player:getMark("@!!wild") > 0
  end,
  enabled_at_response = function(self, player)
    return player:getMark("@!!wild") > 0
  end,
})

Fk:loadTranslationTable{
  ["wild_peach&"] = "野心[桃]",
  [":wild_peach&"] = "你可弃一枚“野心家”，视为使用【桃】。",
  ["#wild_peach&"] = "你可弃一枚“野心家”，视为使用【桃】",
}

return wildPeach
