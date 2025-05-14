local yizhi = fk.CreateSkill{
  name = "yizhi",
  tags = {Skill.DeputyPlace, Skill.Compulsory},
}

local yizhi_spec = {
  can_refresh = function (self, event, target, player, data)
    return target == player
  end,
  on_refresh = function (self, event, target, player, data)
    local has_head_guanxing = false
    for _, sname in ipairs(Fk.generals[player.general]:getSkillNameList()) do
      if Fk.skills[sname].trueName == "guanxing" then
        has_head_guanxing = true
        break
      end
    end
    local ret = player:hasShownSkill(yizhi.name) and not (has_head_guanxing and player.general ~= "anjiang")
    player.room:handleAddLoseSkills(player, ret and "ld__guanxing" or "-ld__guanxing", nil, false, true)
  end
}

yizhi:addEffect(fk.GeneralRevealed, yizhi_spec)
yizhi:addEffect(fk.GeneralHidden, yizhi_spec)
yizhi:addEffect(fk.EventLoseSkill, yizhi_spec)
yizhi:addEffect(fk.EventAcquireSkill, yizhi_spec)

Fk:loadTranslationTable{
  ["yizhi"] = "遗志",
  [":yizhi"] = "副将技，此武将牌上单独的阴阳鱼个数-1；若你的主将的武将牌：有〖观星〗且处于明置状态，此〖观星〗改为固定观看五张牌；没有〖观星〗或处于暗置状态，你拥有〖观星〗。",
}

return yizhi
