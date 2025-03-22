
-- 军令五 你不准回血！
local command5_cannotrecover = fk.CreateSkill{
  name = "#command5_cannotrecover",
}
command5_cannotrecover:addEffect(fk.PreHpRecover, {
  -- global = true,
  can_refresh = function(self, event, target, player, data)
    return target == player and player:getMark("@@command5_effect-turn") > 0
  end,
  on_refresh = function(self, event, target, player, data)
    data:preventRecover()
  end,
})

return command5_cannotrecover
