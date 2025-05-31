local wushuang = fk.CreateSkill {
  name = "ty_heg__zhuanrong_hs_wushuang",
  tags = { Skill.Compulsory },
}

---@type TrigSkelSpec<AimFunc>
local wushuang_spec = {
  on_use = function(self, event, target, player, data)
    local to = (event == fk.TargetConfirmed and data.card.trueName == "duel") and data.from or data.to
    data:setResponseTimes(2, to)
  end,
}

wushuang:addEffect(fk.TargetSpecified, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(wushuang.name) and
      table.contains({ "slash", "duel" }, data.card.trueName)
  end,
  on_use = wushuang_spec.on_use
})

wushuang:addEffect(fk.TargetConfirmed, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(wushuang.name) and data.card.trueName == "duel"
  end,
  on_use = wushuang_spec.on_use
})

Fk:loadTranslationTable{
  ["ty_heg__zhuanrong_hs_wushuang"] = "无双",
  [":ty_heg__zhuanrong_hs_wushuang"] = "锁定技，当你使用【杀】指定一个目标后，该角色需依次使用两张【闪】才能抵消此【杀】；当你使用【决斗】指定一个目标后，或成为一名角色使用【决斗】的目标后，该角色每次响应此【决斗】需依次打出两张【杀】。",
}

return wushuang
