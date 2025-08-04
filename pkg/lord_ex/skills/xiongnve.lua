local xiongnve = fk.CreateSkill {
  name = "xiongnve",
}

Fk:loadTranslationTable {
  ["xiongnve"] = "凶虐",
  [":xiongnve"] = "出牌阶段开始时，你可以移去一张“戮”，令你本回合对此“戮”势力角色获得下列效果中的一项：" ..
      "1.对其造成伤害时，令此伤害+1；2.对其造成伤害时，你获得其一张牌；3.对其使用牌无次数限制。" ..
      "出牌阶段结束时，你可以移去两张“戮”，然后直到你的下回合，当你受到其他角色造成的伤害时，此伤害-1。",

  ["#xiongnve-chooose"] = "发动 凶虐，弃置一张“戮”，获得一项效果",
  ["xiongnve_choice1"] = "增加伤害",
  ["xiongnve_choice2"] = "造成伤害时拿牌",
  ["xiongnve_choice3"] = "用牌无次数限制",
  ["#xiongnve-defence"] = "发动 凶虐，弃置两张“戮”，直到下回合，受到伤害-1",

  ["@xiongnve_choice-phase"] = "凶虐",
  ["@xiongnve_kindom-phase"] = "凶虐",
  ["@xiongnve_choice"] = "凶虐",
  ["xiongnve_defence"] = "减少伤害",
  ["xiongnve_effect1"] = "增加伤害",
  ["xiongnve_effect2"] = "造伤拿牌",
  ["xiongnve_effect3"] = "无限用牌",

  ["$xiongnve1"] = "当今天子乃我所立，他敢怎样？",
  ["$xiongnve2"] = "我兄弟三人同掌禁军，有何所惧？",
}

xiongnve:addEffect(fk.EventPhaseStart, {
  anim_type = "drawcard",
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(xiongnve.name) and player.phase == Player.Play then
      local x = type(player:getMark("@&massacre")) == "table" and #player:getMark("@&massacre") or 0
      return x > 0
    end
  end,
  on_cost = function(self, event, target, player, data)
    local result = player.room:askToCustomDialog(player, {
      skill_name = xiongnve.name,
      qml_path = "packages/utility/qml/ChooseGeneralsAndChoiceBox.qml",
      extra_data = {
        player:getMark("@&massacre"),
        { "xiongnve_choice1", "xiongnve_choice2", "xiongnve_choice3" },
        "#xiongnve-chooose",
        { "Cancel" }
      }
    })
    if result ~= "" then
      local reply = result
      if reply.choice ~= "Cancel" then
        event:setCostData(self, { cards = reply.cards, choice = reply.choice })
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke(xiongnve.name)
    room:notifySkillInvoked(player, xiongnve.name,
      event:getCostData(self).choice == "xiongnve_choice2" and "control" or "offensive")
    local cards = event:getCostData(self).cards
    room:returnToGeneralPile(cards, "bottom")
    local generals = player:getMark("@&massacre")
    local choosegenerlas = {}
    if generals == 0 then generals = {} end
    for _, name in ipairs(cards) do
      table.removeOne(generals, name)
      table.insert(choosegenerlas, name)
    end
    room:setPlayerMark(player, "@&massacre", generals)
    room:setPlayerMark(player, "@xiongnve_choice-phase",
      "xiongnve_effect" .. string.sub(event:getCostData(self).choice, 16, 16))
    local general = Fk.generals[choosegenerlas[1]]
    local kingdoms = { general.kingdom }
    if general.subkingdom then
      table.insert(kingdoms, general.subkingdom)
    end
    room:setPlayerMark(player, "@xiongnve_kindom-phase", kingdoms)
  end,
})

xiongnve:addEffect(fk.EventPhaseEnd, {
  anim_type = "defensive",
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(xiongnve.name) and player.phase == Player.Play then
      local x = type(player:getMark("@&massacre")) == "table" and #player:getMark("@&massacre") or 0
      return x > 1
    end
  end,
  on_cost = function(self, event, target, player, data)
    local result = player.room:askToCustomDialog(player, {
      skill_name = xiongnve.name,
      qml_path = "packages/utility/qml/ChooseGeneralsAndChoiceBox.qml",
      extra_data = {
        player:getMark("@&massacre"),
        { "OK" },
        "#xiongnve-defence",
        { "Cancel" },
        2,
        2
      }
    })
    if result ~= "" then
      local reply = result
      if reply.choice == "OK" then
        event:setCostData(self, { cards = reply.cards })
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke(xiongnve.name)
    room:notifySkillInvoked(player, xiongnve.name, "defensive")
    local cards = event:getCostData(self).cards
    room:returnToGeneralPile(cards, "bottom")
    local generals = player:getMark("@&massacre")
    if generals == 0 then generals = {} end
    for _, name in ipairs(cards) do
      table.removeOne(generals, name)
    end
    room:setPlayerMark(player, "@&massacre", generals)
    room:setPlayerMark(player, "@xiongnve_choice", "xiongnve_defence")
  end,
})

xiongnve:addEffect(fk.TurnStart, {
  can_refresh = function(self, event, target, player, data)
    return target == player and player:getMark("@xiongnve_choice") ~= 0
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@xiongnve_choice", 0)
  end,
})

local function compareXiongNveKingdom(player, target)
  local mark = player:getMark("@xiongnve_kindom-phase")
  return type(mark) == "table" and table.contains(mark, target.kingdom)
end

xiongnve:addEffect(fk.DamageCaused, {
  is_delay_effect = true,
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if player.dead or target ~= player then return false end
    if not data.to.dead and compareXiongNveKingdom(player, data.to) then
      local effect_name = player:getMark("@xiongnve_choice-phase")
      if effect_name == "xiongnve_effect1" then
        return true
      elseif effect_name == "xiongnve_effect2" then
        return #data.to.player_cards[Player.Equip] > 0 or (not data.to:isKongcheng() and data.to ~= player)
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke("xiongnve")
    room:doIndicate(player.id, { data.to.id })
    local effect_name = player:getMark("@xiongnve_choice-phase")
    if effect_name == "xiongnve_effect1" then
      room:notifySkillInvoked(player, xiongnve.name, "offensive")
      data:changeDamage(1)
    elseif effect_name == "xiongnve_effect2" then
      room:notifySkillInvoked(player, xiongnve.name, "control")
      local flag = data.to == player and "e" or "he"
      local card = room:askToChooseCard(player, {
        target = data.to,
        flag = flag,
        skill_name = xiongnve.name,
      })
      room:obtainCard(player, card, false, fk.ReasonPrey)
    end
  end,
})

xiongnve:addEffect(fk.DamageInflicted, {
  is_delay_effect = true,
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if player.dead or player ~= target then return false end
    return player:getMark("@xiongnve_choice") == "xiongnve_defence" and data.from and data.from ~= player
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke("xiongnve")
    room:notifySkillInvoked(player, xiongnve.name, "defensive")
    data:changeDamage(-1)
  end,
})

xiongnve:addEffect("targetmod", {
  bypass_times = function(self, player, skill, scope, card, to)
    return card and to and player:getMark("@xiongnve_choice-phase") == "xiongnve_effect3" and
    compareXiongNveKingdom(player, to)
  end,
})

return xiongnve
