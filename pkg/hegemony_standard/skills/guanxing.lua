local guanxing = fk.CreateSkill{
  name = "hs__guanxing",
}
local H = require "packages/hegemony/util"
guanxing:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and
      player.phase == Player.Start
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local num = (H.inGeneralSkills(player, self.name) == "m" and player:hasShownSkill("yizhi"))
      and 5 or math.min(5, #room.alive_players)
    room:askToGuanxing(player, {cards = room:getNCards(num)})
  end,
})

Fk:loadTranslationTable{
  ["hs__guanxing"] = "观星",
  [":hs__guanxing"] = "准备阶段，你可将牌堆顶的X张牌（X为角色数且至多为5）" ..
    "扣置入处理区（对你可见），你将其中任意数量的牌置于牌堆顶，将其余的牌置于牌堆底。",
  ["$hs__guanxing1"] = "观今夜天象，知天下大事。",
  ["$hs__guanxing2"] = "知天易，逆天难。",
}

return guanxing
