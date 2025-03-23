local wuxin = fk.CreateSkill{
  name = "wuxin",
}
local H = require "packages/hegemony/util"
wuxin:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(wuxin.name) and player.phase == Player.Draw
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local num = H.getSameKingdomPlayersNum(room, nil, "qun")
    if player:hasSkill("hongfa") then
      num = num + #player:getPile("heavenly_army")
    end
    room:askForGuanxing(player, room:getNCards(num), nil, {0, 0}, wuxin.name)
  end,
})

return wuxin
