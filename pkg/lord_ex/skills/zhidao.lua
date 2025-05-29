local zhidao = fk.CreateSkill {
  name = "ld__zhidao",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable {
  ["ld__zhidao"] = "雉盗",
  [":ld__zhidao"] = "锁定技，出牌阶段开始时，你选择一名其他角色，你于此回合内：1.使用牌仅能指定你或其为目标；2.计算与其距离为1；3.首次对其造成伤害后，获得其区域内一张牌。",

  ["@@ld__zhidao-turn"] = "雉盗",
  ["#ld__zhidao-choose"] = "雉盗：选择一名其他角色，本回合你使用牌仅能指定你或其为目标",

  ["$ld__zhidao1"] = "一朝得势，自当尽诸其力！",
  ["$ld__zhidao2"] = "本王要的，没有得不到的！",
}

zhidao:addEffect(fk.EventPhaseStart, {
  anim_type = "special",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(zhidao.name) and player == target and player.phase == Player.Play
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local targets = room:getOtherPlayers(player, false)
    local cid = room:askToChoosePlayers(player, {
      targets = targets,
      min_num = 1,
      max_num = 1,
      prompt = "#ld__zhidao-choose",
      skill_name = zhidao.name,
      cancelable = false,
    })[1]
    local to = cid
    room:setPlayerMark(to, "ld__zhidao-turn", 1)
    room:setPlayerMark(to, "@@ld__zhidao-turn", 1)
    room:setPlayerMark(player, "ld__zhidao-turn", 1)
  end,
})

zhidao:addEffect(fk.Damage, {
  is_delay_effect = true,
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if not (player:hasSkill(zhidao.name) and player == target and player:usedSkillTimes(zhidao.name, Player.HistoryTurn) > 0) then return false end
    return data.to:getMark("ld__zhidao-turn") > 0 and data.to ~= player and not data.to:isAllNude()
        and player:usedEffectTimes(self.name, Player.HistoryTurn) == 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local card = room:askToChooseCard(player, {
      target = data.to,
      flag = "hej",
      skill_name = zhidao.name,
    })
    room:obtainCard(player, card, false, fk.ReasonPrey)
  end,
})

zhidao:addEffect("prohibit", {
  is_prohibited = function(self, from, to, card)
    return from:usedSkillTimes(zhidao.name, Player.HistoryTurn) > 0 and to:getMark("ld__zhidao-turn") == 0
  end,
})

zhidao:addEffect("distance", {
  fixed_func = function(self, from, to)
    if to:getMark("ld__zhidao-turn") == 1 and to ~= from then
      return 1
    end
  end,
})

return zhidao
