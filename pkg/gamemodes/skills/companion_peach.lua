local companionSkill = fk.CreateSkill{
  name = "companion_peach&",
}
local H = require "packages/hegemony/util"
companionSkill:addEffect("viewas", {
  name = "companion_peach&",
  anim_type = "support",
  prompt = "#companion_peach&",
  pattern = "peach",
  card_filter = Util.FalseFunc,
  view_as = function(self)
    local c = Fk:cloneCard("peach")
    c.skillName = companionSkill.name
    return c
  end,
  before_use = function(self, player)
    H.removeHegMark(player.room, player, "companion", 1)
  end,
  enabled_at_play = function(self, player)
    return player:getMark("@!!companion") > 0
  end,
  enabled_at_response = function(self, player)
    return player:getMark("@!!companion") > 0
  end,
})
Fk:loadTranslationTable{
  ["companion_peach&"] = "珠联[桃]",
  [":companion_peach&"] = "你可弃一枚“珠联璧合”，视为使用【桃】。",
  ["#companion_peach&"] = "你可弃一枚“珠联璧合”，视为使用【桃】",
  ["companion"] = "珠联璧合",
}

return companionSkill
