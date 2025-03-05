
--[[
-- 军令四
local command4_prohibit = fk.CreateProhibitSkill{
  name = "#command4_prohibit",
  -- global = true,
  prohibit_use = function(self, player, card)
    if player:getMark("@@command4_effect-turn") > 0 then
      local subcards = card:isVirtual() and card.subcards or {card.id}
      return #subcards > 0 and table.every(subcards, function(id) return table.contains(player:getCardIds(Player.Hand), id) end)
    end
  end,
  prohibit_response = function(self, player, card)
    if player:getMark("@@command4_effect-turn") > 0 then
      local subcards = card:isVirtual() and card.subcards or {card.id}
      return #subcards > 0 and table.every(subcards, function(id) return table.contains(player:getCardIds(Player.Hand), id) end)
    end
  end,
}
Fk:addSkill(command4_prohibit)

-- 军令五 你不准回血！
local command5_cannotrecover = fk.CreateTriggerSkill{
  name = "#command5_cannotrecover",
  -- global = true,
  refresh_events = {fk.PreHpRecover},
  can_refresh = function(self, event, target, player, data)
    return target == player and player:getMark("@@command5_effect-turn") > 0
  end,
  on_refresh = function(self, event, target, player, data)
    data.num = 0
    return true
  end,
}
Fk:addSkill(command5_cannotrecover)

-- 军令六
local command6_select = fk.CreateActiveSkill{
  name = "#command6_select",
  can_use = Util.FalseFunc,
  target_num = 0,
  card_num = function()
    local x = 0
    if #Self.player_cards[Player.Hand] > 0 then x = x + 1 end
    if #Self.player_cards[Player.Equip] > 0 then x = x + 1 end
    return x
  end,
  card_filter = function(self, to_select, selected)
    if #selected == 1 then
      return (Fk:currentRoom():getCardArea(to_select) == Card.PlayerEquip) ~=
      (Fk:currentRoom():getCardArea(selected[1]) == Card.PlayerEquip)
    end
    return #selected == 0
  end,
}
Fk:addSkill(command6_select)
Fk:loadTranslationTable{
  ["#command6_select"] = "军令",
}

local vanguradSkill = fk.CreateActiveSkill{
  name = "vanguard_skill&",
  prompt = "#vanguard_skill&",
  anim_type = "drawcard",
  can_use = function(self, player)
    return player:getMark("@!vanguard") > 0
  end,
  card_filter = Util.FalseFunc,
  target_num = function()
    return table.find(Fk:currentRoom().alive_players, function(p) return (p.general == "anjiang" or p.deputyGeneral == "anjiang") and p ~= Self end) and 1 or 0
  end,
  target_filter = function(self, to_select, selected, selected_cards)
    if to_select ~= Self.id and #selected == 0 and table.find(Fk:currentRoom().alive_players, function(p) return (p.general == "anjiang" or p.deputyGeneral == "anjiang") and p ~= Self end) then
      local target = Fk:currentRoom():getPlayerById(to_select)
      return target.general == "anjiang" or target.deputyGeneral == "anjiang"
    end
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    room:removePlayerMark(player, "@!vanguard")
    if player:getMark("@!vanguard") == 0 then
      player:loseFakeSkill("vanguard_skill&")
      -- room:handleAddLoseSkills(player, "-vanguard_skill&", nil, false, true)
    end
    local num = 4 - player:getHandcardNum()
    if num > 0 then
      player:drawCards(num, self.name)
    end
    if #effect.tos == 0 then return false end
    local target = room:getPlayerById(effect.tos[1])
    local choices = {"known_both_main", "known_both_deputy"}
    if target.general ~= "anjiang" then
      table.remove(choices, 1)
    end
    if target.deputyGeneral ~= "anjiang" then
      table.remove(choices)
    end
    if #choices == 0 then return end
    local choice = room:askForChoice(player, choices, self.name, "#known_both-choice::"..target.id, false)
    local general = choice == "known_both_main" and {target:getMark("__heg_general"), target.deputyGeneral, target.seat} or {target.general, target:getMark("__heg_deputy"), target.seat}
    room:askForCustomDialog(player, self.name, "packages/hegemony/qml/KnownBothBox.qml", general)
  end,
}
Fk:addSkill(vanguradSkill)
Fk:loadTranslationTable{
  ["vanguard_skill&"] = "先驱",
  ["#vanguard_skill&"] = "你可弃一枚“先驱”，将手牌摸至4张，观看一名其他角色的一张暗置武将牌",
  [":vanguard_skill&"] = "出牌阶段，你可弃一枚“先驱”，将手牌摸至4张，观看一名其他角色的一张暗置武将牌。",
  ["vanguard"] = "先驱",
}

local removeYinyangfish = function(room, player)
  room:removePlayerMark(player, "@!yinyangfish")
  if player:getMark("@!yinyangfish") == 0 then
    player:loseFakeSkill("yinyangfish_skill&")
    -- room:handleAddLoseSkills(player, "-yinyangfish_skill&", nil, false, true)
  end
end
local yinyangfishSkill = fk.CreateActiveSkill{
  name = "yinyangfish_skill&",
  prompt = "#yinyangfish_skill&",
  anim_type = "drawcard",
  can_use = function(self, player)
    return player:getMark("@!yinyangfish") > 0
  end,
  card_filter = Util.FalseFunc,
  target_num = 0,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    removeYinyangfish(room, player)
    player:drawCards(1, self.name)
  end,
}
local yinyangfishMax = fk.CreateTriggerSkill{
  name = "#yinyangfish_max&",
  priority = 0.1,
  anim_type = "defensive",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player.phase == Player.Discard and player:hasSkill(self) and player:getMark("@!yinyangfish") > 0 and player:getHandcardNum() > player:getMaxCards()
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, nil, "#yinyangfish_max-ask")
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    removeYinyangfish(room, player)
    room:addPlayerMark(target, MarkEnum.AddMaxCardsInTurn, 2)
    room:broadcastProperty(player, "MaxCards")
  end,
}
yinyangfishSkill:addRelatedSkill(yinyangfishMax)
Fk:addSkill(yinyangfishSkill)
Fk:loadTranslationTable{
  ["yinyangfish_skill&"] = "阴阳鱼",
  ["#yinyangfish_skill&"] = "你可弃一枚“阴阳鱼”，摸一张牌",
  ["#yinyangfish_max&"] = "阴阳鱼",
  ["#yinyangfish_max-ask"] = "你可弃一枚“阴阳鱼”，此回合手牌上限+2",
  [":yinyangfish_skill&"] = "出牌阶段，你可弃一枚“阴阳鱼”，摸一张牌；弃牌阶段开始时，你可弃一枚“阴阳鱼”，此回合手牌上限+2。",
  ["yinyangfish"] = "阴阳鱼",
}

local removeCompanion = function(room, player)
  room:removePlayerMark(player, "@!companion")
  if player:getMark("@!companion") == 0 then
    player:loseFakeSkill("companion_skill&")
    player:loseFakeSkill("companion_peach&")
    -- room:handleAddLoseSkills(player, "-companion_skill&|-companion_peach&", nil, false, true)
  end
end
local companionSkill = fk.CreateActiveSkill{
  name = "companion_skill&",
  prompt = "#companion_skill&",
  anim_type = "drawcard",
  can_use = function(self, player)
    return player:getMark("@!companion") > 0
  end,
  card_filter = Util.FalseFunc,
  target_num = 0,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    removeCompanion(room, player)
    player:drawCards(2, self.name)
  end,
}
local companionPeach = fk.CreateViewAsSkill{
  name = "companion_peach&",
  anim_type = "support",
  prompt = "#companion_peach&",
  pattern = "peach",
  card_filter = Util.FalseFunc,
  view_as = function(self, cards)
    local c = Fk:cloneCard("peach")
    c.skillName = self.name
    return c
  end,
  before_use = function(self, player)
    local room = player.room
    removeCompanion(room, player)
  end,
  enabled_at_play = function(self, player)
    return player:getMark("@!companion") > 0
  end,
  enabled_at_response = function(self, player)
    return player:getMark("@!companion") > 0
  end,
}
Fk:addSkill(companionSkill)
Fk:addSkill(companionPeach)
Fk:loadTranslationTable{
  ["companion_skill&"] = "珠联[摸]",
  ["#companion_skill&"] = "你可弃一枚“珠联璧合”，摸两张牌",
  [":companion_skill&"] = "出牌阶段，你可弃一枚“珠联璧合”，摸两张牌。",
  ["companion_peach&"] = "珠联[桃]",
  [":companion_peach&"] = "你可弃一枚“珠联璧合”，视为使用【桃】。",
  ["#companion_peach&"] = "你可弃一枚“珠联璧合”，视为使用【桃】",
  ["companion"] = "珠联璧合",
}

-- 野心家标记
local removeWild = function(room, player)
  room:removePlayerMark(player, "@!wild")
  if player:getMark("@!wild") == 0 then
    player:loseFakeSkill("wild_draw&")
    player:loseFakeSkill("wild_peach&")
  end
end
local wildDraw = fk.CreateActiveSkill{
  name = "wild_draw&",
  prompt = "#wild_draw&",
  anim_type = "drawcard",
  can_use = function(self, player)
    return player:getMark("@!wild") > 0
  end,
  interaction = UI.ComboBox { choices = {"wild_vanguard", "wild_companion", "wild_yinyangfish"} },
  card_filter = Util.FalseFunc,
  target_num = function(self)
    return self.interaction.data == "wild_vanguard" and table.find(Fk:currentRoom().alive_players, function(p) return (p.general == "anjiang" or p.deputyGeneral == "anjiang") and p ~= Self end) and 1 or 0 
  end,
  target_filter = function(self, to_select, selected, selected_cards)
    if self.interaction.data == "wild_vanguard" and to_select ~= Self.id and #selected == 0 and table.find(Fk:currentRoom().alive_players, function(p) return (p.general == "anjiang" or p.deputyGeneral == "anjiang") and p ~= Self end) then
      local target = Fk:currentRoom():getPlayerById(to_select)
      return target.general == "anjiang" or target.deputyGeneral == "anjiang"
    end
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    removeWild(room, player)
    local pattern = self.interaction.data
    if pattern == "wild_companion" then
      player:drawCards(2, self.name)
    elseif pattern == "wild_yinyangfish" then
      player:drawCards(1, self.name)
    elseif pattern == "wild_vanguard" then
      local num = 4 - player:getHandcardNum()
      if num > 0 then
        player:drawCards(num, self.name)
      end
      if #effect.tos == 0 then return false end
      local target = room:getPlayerById(effect.tos[1])
      local choices = {"known_both_main", "known_both_deputy"}
      if target.general ~= "anjiang" then
        table.remove(choices, 1)
      end
      if target.deputyGeneral ~= "anjiang" then
        table.remove(choices)
      end
      if #choices == 0 then return end
      local choice = room:askForChoice(player, choices, self.name, "#known_both-choice::"..target.id, false)
      local general = choice == "known_both_main" and {target:getMark("__heg_general"), target.deputyGeneral, target.seat} or {target.general, target:getMark("__heg_deputy"), target.seat}
      room:askForCustomDialog(player, self.name, "packages/hegemony/qml/KnownBothBox.qml", general)
    end
  end,
}
local wildPeach = fk.CreateViewAsSkill{
  name = "wild_peach&",
  anim_type = "support",
  prompt = "#wild_peach&",
  pattern = "peach",
  card_filter = Util.FalseFunc,
  view_as = function(self, cards)
    local c = Fk:cloneCard("peach")
    c.skillName = self.name
    return c
  end,
  before_use = function(self, player)
    local room = player.room
    removeWild(room, player)
  end,
  enabled_at_play = function(self, player)
    return player:getMark("@!wild") > 0
  end,
  enabled_at_response = function(self, player)
    return player:getMark("@!wild") > 0
  end,
}
local wildMax = fk.CreateTriggerSkill{
  name = "#wild_max&",
  priority = 0.09,
  anim_type = "defensive",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player.phase == Player.Discard and player:hasSkill(self) and player:getMark("@!wild") > 0 and player:getHandcardNum() > player:getMaxCards()
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, nil, "#wild_max-ask")
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    removeWild(room, player)
    room:addPlayerMark(target, MarkEnum.AddMaxCardsInTurn, 2)
  end,
}
wildDraw:addRelatedSkill(wildMax)
Fk:addSkill(wildDraw)
Fk:addSkill(wildPeach)

Fk:loadTranslationTable{
  ["wild_draw&"] = "野心[牌]",
  [":wild_draw&"] = "你可弃一枚“野心家”，执行“先驱”、“阴阳鱼”或“珠联璧合”的效果。",
  ["#wild_draw&"] = "你可将“野心家”当一种标记弃置并执行其效果（点击左侧选项框展开）",
  ["wild_vanguard"] = "将手牌摸至4张，观看一张暗置武将牌",
  ["wild_yinyangfish"] = "摸一张牌",
  ["wild_companion"] = "摸两张牌",

  ["wild_peach&"] = "野心[桃]",
  [":wild_peach&"] = "你可弃一枚“野心家”，视为使用【桃】。",
  ["#wild_peach&"] = "你可弃一枚“野心家”，视为使用【桃】",

  ["#wild_max&"] = "野心家[手牌上限]",
  ["#wild_max-ask"] = "你可弃一枚“野心家”，此回合手牌上限+2",
}
--]]
local extension = Package:new("heg_mode", Package.SpecialPack)
extension:loadSkillSkelsByPath("./packages/hegemony/pkg/gamemodes/skills")
return extension
