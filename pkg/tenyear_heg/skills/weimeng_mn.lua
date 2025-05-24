local weimeng_mn = fk.CreateSkill{
  name = "ty_heg__weimeng_manoeuvre",
}
weimeng_mn:addEffect("active", {
  anim_type = "control",
  prompt = "#ty_heg__weimeng_manoeuvre",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(weimeng_mn.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected)
    return #selected == 0 and to_select ~= player and not to_select:isKongcheng()
  end,
  on_use = function (self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    local card1 = room:askToChooseCard(player, {
    target = target,
    flag = "h",
    skill_name = weimeng_mn.name,
  })
    room:obtainCard(player, card1, false, fk.ReasonPrey)
    if player.dead or player:isNude() or target.dead then return end
    local cards2 = room:askForCard(player, 1, 1, true, weimeng_mn.name, false, ".", "#ty_heg__weimeng-give::"..target.id..":"..tostring(1))
    room:obtainCard(target, cards2[1], false, fk.ReasonGive)
  end,
})

weimeng_mn:addEffect(fk.TurnEnd, {
  late_refresh = true,
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill("ty_heg__weimeng_manoeuvre", true, true)
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    room:handleAddLoseSkills(player, "-ty_heg__weimeng_manoeuvre", nil)
    room:setPlayerMark(player, "@@ty_heg__weimeng_manoeuvre", 0)
  end,
})

Fk:loadTranslationTable{
  ["ty_heg__weimeng_manoeuvre"] = "危盟⇋",
  [":ty_heg__weimeng_manoeuvre"] = "出牌阶段限一次，你可以获得目标角色一张手牌，然后交给其等量的牌。",
  ["#ty_heg__weimeng_manoeuvre"] = "危盟：获得一名其他角色至多1张牌，交还等量牌。",
}

return weimeng_mn
