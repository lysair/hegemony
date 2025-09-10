local companionDraw = fk.CreateSkill{
  name = "companion_draw&",
}
local H = require "packages/hegemony/util"
companionDraw:addEffect("active", {
  prompt = "#companion_draw&",
  anim_type = "drawcard",
  can_use = function(self, player)
    return player:getMark("@!!companion") > 0
  end,
  card_filter = Util.FalseFunc,
  target_num = 0,
  on_use = function(self, room, effect)
    local player = effect.from
    H.removeHegMark(room, player, "companion", 1)
    player:drawCards(2, companionDraw.name)
  end,
})
Fk:loadTranslationTable{
  ["companion_draw&"] = "珠联[摸]",
  ["#companion_draw&"] = "你可弃一枚“珠联璧合”，摸两张牌",
  [":companion_draw&"] = "出牌阶段，你可弃一枚“珠联璧合”，摸两张牌。",
  ["companion"] = "珠联璧合",
}

return companionDraw
