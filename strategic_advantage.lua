-- SPDX-License-Identifier: GPL-3.0-or-later

local extension = Package:new("strategic_advantage", Package.CardPack)
extension.extensionName = "hegemony"

local H = require "packages/hegemony/util"
local U = require "packages/utility/utility"

Fk:loadTranslationTable{
  ["strategic_advantage"] = "君临天下·势备篇",
}

extension.game_modes_whitelist = { 'nos_heg_mode', 'new_heg_mode' }
extension.game_modes_blacklist = {"aaa_role_mode", "m_1v1_mode", "m_1v2_mode", "m_2v2_mode", "zombie_mode", "chaos_mode"}

extension:addCards{
  Fk:cloneCard("slash", Card.Heart, 10),
  Fk:cloneCard("slash", Card.Heart, 11),
  Fk:cloneCard("slash", Card.Spade, 4),
  Fk:cloneCard("slash", Card.Spade, 7),
  Fk:cloneCard("slash", Card.Spade, 8),
  Fk:cloneCard("slash", Card.Club, 4),
  Fk:cloneCard("slash", Card.Club, 6),
  Fk:cloneCard("slash", Card.Club, 7),
  Fk:cloneCard("slash", Card.Club, 8),

  Fk:cloneCard("thunder__slash", Card.Spade, 9),
  Fk:cloneCard("thunder__slash", Card.Spade, 10),
  -- Fk:cloneCard("thunder__slash", Card.Spade, 11),
  -- Fk:cloneCard("thunder__slash", Card.Club, 5),

  Fk:cloneCard("fire__slash", Card.Diamond, 8),
  Fk:cloneCard("fire__slash", Card.Diamond, 9),

  Fk:cloneCard("jink", Card.Heart, 4),
  Fk:cloneCard("jink", Card.Heart, 5),
  -- Fk:cloneCard("jink", Card.Heart, 6),
  Fk:cloneCard("jink", Card.Heart, 7),
  Fk:cloneCard("jink", Card.Diamond, 6),
  Fk:cloneCard("jink", Card.Diamond, 7),
  Fk:cloneCard("jink", Card.Diamond, 13),

  Fk:cloneCard("peach", Card.Heart, 8),
  Fk:cloneCard("peach", Card.Heart, 9),
  Fk:cloneCard("peach", Card.Diamond, 2),
  -- Fk:cloneCard("peach", Card.Diamond, 3),

  -- Fk:cloneCard("analeptic", Card.Spade, 6),
  Fk:cloneCard("analeptic", Card.Club, 9),

  Fk:cloneCard("nullification", Card.Spade, 13),

  H.hegNullification:clone(Card.Diamond, 11),
  H.hegNullification:clone(Card.Club, 13),
}

for _, c in ipairs{Fk:cloneCard("jink", Card.Heart, 6),
  Fk:cloneCard("peach", Card.Diamond, 3),
  Fk:cloneCard("analeptic", Card.Spade, 6),
  Fk:cloneCard("thunder__slash", Card.Spade, 11),
  Fk:cloneCard("thunder__slash", Card.Club, 5),
} do
  extension:addCard(c)
  H.addCardToAllianceCards(c)
end

local drowningSkill = fk.CreateActiveSkill{
  name = "sa__drowning_skill",
  prompt = "#sa__drowning_skill",
  target_num = 1,
  mod_target_filter = function(self, to_select, selected, user, card, distance_limited)
    return to_select ~= user and #Fk:currentRoom():getPlayerById(to_select):getCardIds(Player.Equip) > 0
  end,
  target_filter = function(self, to_select, selected, _, card)
    if #selected == 0 then
      return self:modTargetFilter(to_select, selected, Self.id, card, true)
    end
  end,
  on_effect = function(self, room, effect)
    local from = room:getPlayerById(effect.from)
    local to = room:getPlayerById(effect.to)
    local all_choices = {"sa__drowning_throw", "sa__drowning_damage:" .. from.id}
    local choices = table.clone(all_choices)
    --if not table.find(to:getCardIds(Player.Equip), function(id) return not to:prohibitDiscard(Fk:getCardById(id)) end) then
    if #to:getCardIds(Player.Equip) == 0 then
      table.remove(choices, 1)
    end
    local choice = room:askForChoice(to, choices, self.name, nil, false, all_choices)
    if choice == "sa__drowning_throw" then
      to:throwAllCards("e")
    else
      room:damage({
        from = from,
        to = to,
        card = effect.card,
        damage = 1,
        damageType = fk.ThunderDamage,
        skillName = self.name
      })
    end
  end
}
local drowning = fk.CreateTrickCard{
  name = "sa__drowning",
  skill = drowningSkill,
  is_damage_card = true,
  suit = Card.Heart,
  number = 13,
}
extension:addCards{
  drowning,
  drowning:clone(Card.Club, 12),
}
Fk:loadTranslationTable{
  ["sa__drowning"] = "水淹七军",
  [":sa__drowning"] = "锦囊牌<br/><b>时机</b>：出牌阶段<br/><b>目标</b>：一名装备区里有牌的其他角色<br/><b>效果</b>：目标角色选择：1.弃置装备区里的所有牌；2.受到你造成的1点雷电伤害。",
  ["sa__drowning_skill"] = "水淹七军",
  ["sa__drowning_throw"] = "弃置装备区里的所有牌",
  ["sa__drowning_damage"] = "受到%src造成的1点雷电伤害",
  ["#sa__drowning_skill"] = "选择一名装备区里有牌的其他角色，其选择：<br/>1.弃置装备区里的所有牌；2.受到你造成的1点雷电伤害",
}

local burningCampsSkill = fk.CreateActiveSkill{
  name = "burning_camps_skill",
  prompt = "#burning_camps_skill",
  mod_target_filter = function(self, to_select, selected, user, card, distance_limited)
    local prev = Fk:currentRoom():getPlayerById(user):getNextAlive()
    return prev.id ~= user and (to_select == prev.id or H.inFormationRelation(prev, Fk:currentRoom():getPlayerById(to_select)))
  end,
  can_use = function(self, player, card)
    return not player:isProhibited(player:getNextAlive(), card) and player:getNextAlive() ~= player
  end,
  on_use = function(self, room, use)
    if not use.tos or #TargetGroup:getRealTargets(use.tos) == 0 then
      local player = room:getPlayerById(use.from)
      local prev = player:getNextAlive()
      use.tos = { {prev.id} }
      for _, p in ipairs(H.getFormationRelation(prev)) do
        if not player:isProhibited(p, use.card) then
          TargetGroup:pushTargets(use.tos, p.id)
        end
      end
    end
  end,
  on_effect = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.to)
    room:damage({
      from = player,
      to = target,
      card = effect.card,
      damage = 1,
      damageType = fk.FireDamage,
      skillName = self.name
    })
  end,
}
local burningCamps = fk.CreateTrickCard{
  name = "burning_camps",
  skill = burningCampsSkill,
  suit = Card.Heart,
  number = 12,
  multiple_targets = true,
  is_damage_card = true,
}

for _, c in ipairs{
  burningCamps,
  burningCamps:clone(Card.Spade, 3),
  burningCamps:clone(Card.Club, 11),
} do
  extension:addCard(c)
  H.addCardToAllianceCards(c)
end

--[[
extension:addCards{
  burningCamps,
  burningCamps:clone(Card.Spade, 3),
  burningCamps:clone(Card.Club, 11),
}
]]

Fk:loadTranslationTable{
  ["burning_camps"] = "火烧连营",
  [":burning_camps"] = "锦囊牌<br/><b>时机</b>：出牌阶段<br/><b>目标</b>：你的下家和除其外与其处于同一队列的所有角色<br/><b>效果</b>：目标角色受到你造成的1点火焰伤害。<br /><font color='grey'>\"<b>队列</b>\"：连续相邻的若干名(至少2名)势力相同的角色处于同一队列",
  ["#burning_camps_skill"] = "对你的下家和除其外与其处于同一队列的所有角色各造成1点火焰伤害",
}

local lureTigerSkill = fk.CreateActiveSkill{
  name = "lure_tiger_skill",
  prompt = "#lure_tiger_skill",
  min_target_num = 1,
  max_target_num = 2,
  mod_target_filter = function(self, to_select, selected, user)
    return user ~= to_select
  end,
  target_filter = function(self, to_select, selected)
    if #selected <= 1 then
      return self:modTargetFilter(to_select, selected, Self.id)
    end
  end,
  on_effect = function(self, room, effect)
    local target = room:getPlayerById(effect.to)
    room:setPlayerMark(target, "@@lure_tiger-turn", 1)
    room:setPlayerMark(target, MarkEnum.PlayerRemoved .. "-turn", 1)
    room:handleAddLoseSkills(target, "#lure_tiger_hp|#lure_tiger_prohibit", nil, false, true) -- global...
    room.logic:trigger("fk.RemoveStateChanged", target, nil) -- FIXME
  end,
}
local lureTigerProhibit = fk.CreateProhibitSkill{
  name = "#lure_tiger_prohibit",
  -- global = true,
  prohibit_use = function(self, player, card)
    return player:getMark("@@lure_tiger-turn") ~= 0
  end,
  is_prohibited = function(self, from, to, card)
    return to:getMark("@@lure_tiger-turn") ~= 0
  end,
}
local lureTigerHp = fk.CreateTriggerSkill{
  name = "#lure_tiger_hp",
  -- global = true,
  refresh_events = {fk.PreHpRecover, fk.PreHpLost, fk.DamageInflicted},
  can_refresh = function(self, event, target, player, data)
    return target == player and player:getMark("@@lure_tiger-turn") ~= 0
  end,
  on_refresh = function(self, event, target, player, data)
    if event == fk.DamageInflicted then
      data.damage = 0
    else
      data.num = 0
    end
    return true
  end,
}
Fk:addSkill(lureTigerProhibit)
Fk:addSkill(lureTigerHp)
local lureTiger = fk.CreateTrickCard{
  name = "lure_tiger",
  skill = lureTigerSkill,
  suit = Card.Heart,
  number = 2,
  multiple_targets = true,
}
extension:addCard(lureTiger)
lureTiger = lureTiger:clone(Card.Diamond, 10)
extension:addCard(lureTiger)
H.addCardToAllianceCards(lureTiger)

Fk:loadTranslationTable{
  ["lure_tiger"] = "调虎离山",
  [":lure_tiger"] = "锦囊牌<br/><b>时机</b>：出牌阶段<br/><b>目标</b>：一至两名其他角色<br/><b>效果</b>：目标角色于此回合内不计入距离和座次的计算，且不能使用牌，且不是牌的合法目标，且体力值不会改变。",
  ["#lure_tiger_prohibit"] = "调虎离山",
  ["#lure_tiger_skill"] = "选择一至两名其他角色，这些角色于此回合内不计入距离和座次的计算，<br/>且不能使用牌，且不是牌的合法目标，且体力值不会改变",

  ["@@lure_tiger-turn"] = "调虎离山",
}

local fightTogetherSkill = fk.CreateActiveSkill{
  name = "fight_together_skill",
  prompt = "#fight_together_skill",
  target_num = 1,
  mod_target_filter = function(self, to_select, selected, user, card, distance_limited)
    if table.every(Fk:currentRoom().alive_players, function(p) return not H.isBigKingdomPlayer(p) end) then return false end
    if #selected == 0 then
      return true
    else
      return H.isBigKingdomPlayer(Fk:currentRoom():getPlayerById(selected[1])) == H.isBigKingdomPlayer(Fk:currentRoom():getPlayerById(to_select))
    end
  end,
  target_filter = function(self, to_select, selected, _, card)
    if #selected == 0 then
      return self:modTargetFilter(to_select, selected, Self.id, card, true)
    end
  end,
  can_use = function(self, player, card)
    return table.find(Fk:currentRoom().alive_players, function(p) return H.isBigKingdomPlayer(p) end)
  end,
  on_use = function(self, room, use)
    if use.tos and #TargetGroup:getRealTargets(use.tos) > 0 then -- 如果一开始的目标被取消了就寄了，还是需要originalTarget
      local player = room:getPlayerById(use.from)
      local target = room:getPlayerById(use.tos[1][1])
      local bigKindom, smallKingdom = H.isBigKingdomPlayer(target), H.isSmallKingdomPlayer(target)
      if bigKindom then
        for _, p in ipairs(room:getAlivePlayers()) do
          if H.isBigKingdomPlayer(p) and p ~= target and not player:isProhibited(p, use.card) then
            TargetGroup:pushTargets(use.tos, p.id)
          end
        end
      end
      if smallKingdom then
        for _, p in ipairs(room:getAlivePlayers()) do
          if H.isSmallKingdomPlayer(p) and p ~= target and not player:isProhibited(p, use.card) then
            TargetGroup:pushTargets(use.tos, p.id)
          end
        end
      end
    end
  end,
  on_effect = function(self, room, cardEffectEvent)
    local to = room:getPlayerById(cardEffectEvent.to)
    if to.chained then
      to:drawCards(1, "fight_together")
    else
      to:setChainState(true)
    end
  end,
}
local fightTogether = fk.CreateTrickCard{
  name = "fight_together",
  skill = fightTogetherSkill,
  suit = Card.Spade,
  number = 12,
  multiple_targets = true,
  special_skills = { "recast" },
}
extension:addCards{
  fightTogether,
  fightTogether:clone(Card.Club, 10),
}

Fk:loadTranslationTable{
  ["fight_together"] = "勠力同心",
  [":fight_together"] = "锦囊牌<br/><b>时机</b>：出牌阶段<br/><b>目标</b>：所有大势力角色或所有小势力角色<br/><b>效果</b>：若目标角色：不处于连环状态，其横置；处于连环状态，其摸一张牌。<br/><font color='grey'>操作提示：选择一名角色，若其为大势力角色，则目标为所有大势力角色；若其为小势力角色，则目标为所有小势力角色</font>",
  ["#fight_together_skill"] = "选择所有大势力角色或小势力角色，若这些角色处于/不处于连环状态，其摸一张牌/横置",
}

local allianceFeastSkill = fk.CreateActiveSkill{
  name = "alliance_feast_skill",
  prompt = "#alliance_feast_skill",
  target_num = 1,
  mod_target_filter = function(self, to_select, selected, user, card, distance_limited)
    if to_select == user then return true end
    local to = Fk:currentRoom():getPlayerById(to_select)
    if to.kingdom == "unknown" then return false end
    local from = Fk:currentRoom():getPlayerById(user)
    if #selected == 0 then
      return H.compareKingdomWith(to, from, true)
    end
    local target = Fk:currentRoom():getPlayerById(selected[1])
    return H.compareKingdomWith(to, target)
  end,
  target_filter = function(self, to_select, selected, _, card)
    return #selected == 0 and self:modTargetFilter(to_select, selected, Self.id, card, true) and to_select ~= Self.id
  end,
  can_use = function(self, player, card)
    return not player:prohibitUse(card) and player.kingdom ~= "unknown"
  end,
  on_use = function(self, room, use)
    local card = use.card
    local player = room:getPlayerById(use.from)
    local num = 0
    if use.tos and #TargetGroup:getRealTargets(use.tos) > 0 then
      for _, pid in ipairs(TargetGroup:getRealTargets(use.tos)) do
        if pid ~= use.from then
          num = 1
          local _p = room:getPlayerById(pid)
          for _, p in ipairs(room:getAlivePlayers()) do
            if H.compareKingdomWith(p, _p) and p ~= _p then
              TargetGroup:pushTargets(use.tos, p.id)
              num = num + 1
            end
          end
          break
        end
      end
      if not player:isProhibited(player, card) then
        TargetGroup:pushTargets(use.tos, use.from)
      end
    elseif not player:isProhibited(player, card) then
      use.tos = { {use.from} }
    end
    use.extra_data = use.extra_data or {}
    use.extra_data.AFNum = num
  end,
  on_effect = function(self, room, cardEffectEvent)
    local from = room:getPlayerById(cardEffectEvent.from)
    local to = room:getPlayerById(cardEffectEvent.to)
    if from == to then
      local num = (cardEffectEvent.extra_data or {}).AFNum
      local choices = {}
      for i = 0, math.min(num, from:getLostHp()) do
        table.insert(choices, "#AFrecover:::" .. i .. ":" .. num - i)
      end
      local number = table.indexOf(choices, room:askForChoice(from, choices, self.name)) - 1
      if number > 0 then
        room:recover{
          who = from,
          recoverBy = from,
          card = cardEffectEvent.card,
          num = number,
          skillName = self.name
        }
      end
      from:drawCards(num - number, "alliance_feast")
    else
      to:drawCards(1, "alliance_feast")
      if to.chained then to:setChainState(false) end
    end
  end,
}
local allianceFeast = fk.CreateTrickCard{
  name = "alliance_feast",
  skill = allianceFeastSkill,
  suit = Card.Heart,
  number = 1,
  multiple_targets = true,
}
extension:addCard(allianceFeast)

Fk:loadTranslationTable{
  ["alliance_feast"] = "联军盛宴",
  [":alliance_feast"] = "锦囊牌<br/><b>时机</b>：出牌阶段<br/><b>目标</b>：有势力的你和除你的势力外的一个势力的所有角色<br/><b>效果</b>：若目标角色：为你，你摸X张牌，回复（Y-X）点体力（Y为该势力的角色数）（X为你选择的自然数且不大于Y）；不为你，其摸一张牌，重置。<br/><font color='grey'>操作提示：选择一名与你势力不同的角色，目标为你和该势力的所有角色</font>",
  ["alliance_feast_skill"] = "联军盛宴",
  ["#AFrecover"] = "回复%arg点体力，摸%arg2张牌",
  ["#alliance_feast_skill"] = "选择除你的势力外的一个势力的所有角色，<br/>你选择X（不大于Y），摸X张牌，回复Y-X点体力（Y为该势力的角色数）；<br/>这些角色各摸一张牌，重置",
}

local threatenEmperorSkill = fk.CreateActiveSkill{
  name = "threaten_emperor_skill",
  prompt = "#threaten_emperor_skill",
  mod_target_filter = function(self, to_select, selected, user, card, distance_limited)
    return to_select == Self.id and H.isBigKingdomPlayer(Self)
  end,
  can_use = function(self, player, card)
    return not player:isProhibited(player, card) and H.isBigKingdomPlayer(player)
  end,
  on_use = function(self, room, use)
    if not use.tos or #TargetGroup:getRealTargets(use.tos) == 0 then
      use.tos = { {use.from} }
    end
  end,
  on_effect = function(self, room, effect)
    local target = room:getPlayerById(effect.to)
    room:setPlayerMark(target, "_TEeffect-turn", 1)
    room:handleAddLoseSkills(target, "#threaten_emperor_extra", nil, false, true) -- global ...
    target:endPlayPhase()
  end,
}
local threatenEmperorExtra = fk.CreateTriggerSkill{
  name = "#threaten_emperor_extra",
  -- global = true,
  priority = 1,
  events = {fk.EventPhaseEnd},
  can_trigger = function(self, event, target, player, data)
    return target.phase == Player.Discard and player:getMark("_TEeffect-turn") > 0
  end,
  on_cost = function(self, event, target, player, data)
    local card = player.room:askForDiscard(player, 1, 1, false, self.name, true, nil, "#TE-ask", true)
    if #card > 0 then
      self.cost_data = card
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:throwCard(self.cost_data, self.name, player, player)
    player:gainAnExtraTurn()
  end,
}
Fk:addSkill(threatenEmperorExtra)
local threatenEmperor = fk.CreateTrickCard{
  name = "threaten_emperor",
  skill = threatenEmperorSkill,
  suit = Card.Diamond,
  number = 1,
}

for _, c in ipairs{
  threatenEmperor,
  threatenEmperor:clone(Card.Diamond, 4),
  threatenEmperor:clone(Card.Spade, 1),
} do
  extension:addCard(c)
  H.addCardToAllianceCards(c)
end
--[[
extension:addCards{
  threatenEmperor,
  threatenEmperor:clone(Card.Diamond, 4),
  threatenEmperor:clone(Card.Spade, 1),
}
]]
Fk:loadTranslationTable{
  ["threaten_emperor"] = "挟天子以令诸侯",
  [":threaten_emperor"] = "锦囊牌<br/><b>时机</b>：出牌阶段<br/><b>目标</b>：为大势力角色的你<br/><b>效果</b>：目标角色结束出牌阶段，此回合的弃牌阶段结束时，其可弃置一张手牌，然后其获得一个额外回合。",
  ["#TE-ask"] = "受到【挟天子以令诸侯】影响，你可以弃置一张手牌，获得一个额外回合",
  ["threaten_emperor_skill"] = "挟天子以令诸侯",
  ["#threaten_emperor_extra"] = "挟天子以令诸侯",
  ["#threaten_emperor_skill"] = "你结束出牌阶段，此回合弃牌阶段结束时，你可弃置一张手牌，然后获得一个额外回合",
}

local function doImperialOrder(room, target)
  local all_choices = {"IO_reveal", "IO_discard", "IO_hplose"}
  local choices = table.clone(all_choices)
  if target.hp < 1 then table.remove(choices) end
  if table.every(target:getCardIds{Player.Equip, Player.Hand}, function(id) return Fk:getCardById(id).type ~= Card.TypeEquip or target:prohibitDiscard(Fk:getCardById(id)) end) then
    table.remove(choices, 2)
  end
  if (target.general ~= "anjiang" or target:prohibitReveal()) and (target.deputyGeneral ~= "anjiang" or target:prohibitReveal(true)) then
    table.remove(choices, 1)
  end
  if #choices == 0 then return false end
  local choice = room:askForChoice(target, choices, "imperial_order_skill", nil, false, all_choices)
  if choice == "IO_reveal" then
    H.askForRevealGenerals(room, target, "imperial_order_skill", true, true, false, false)
    target:drawCards(1, "imperial_order_skill")
  elseif choice == "IO_discard" then
    room:askForDiscard(target, 1, 1, true, "imperial_order_skill", false, ".|.|.|.|.|equip")
  else
    room:loseHp(target, 1, "imperial_order_skill")
  end
end
local imperialOrderRemoved = fk.CreateTriggerSkill{
  name = "imperial_order_removed",
  global = true,
  refresh_events = {fk.BeforeCardsMove, fk.TurnEnd},
  can_refresh = function(self, event, target, player, data)
    if player.room:getTag("ImperialOrderHasRemoved") then return false end -- 先这样，只有一次！
    if event == fk.BeforeCardsMove then
      if player.room:getTag("ImperialOrderRemoved") then return false end
      for _, move in ipairs(data) do
        if move.toArea == Card.DiscardPile and move.moveReason ~= fk.ReasonUse then
          for _, info in ipairs(move.moveInfo) do
            if Fk:getCardById(info.cardId).name == "imperial_order" then
              return true
            end
          end
        end
      end
    else
      return target == player and target.room:getTag("ImperialOrderRemoved")
    end
  end,
  on_refresh = function(self, event, target, player, data)
    if event == fk.BeforeCardsMove then
      local ids = {}
      local mirror_moves = {}
      for _, move in ipairs(data) do
        if move.toArea == Card.DiscardPile and move.moveReason ~= fk.ReasonUse then
          local move_info = {}
          local mirror_info = {}
          for _, info in ipairs(move.moveInfo) do
            local id = info.cardId
            if Fk:getCardById(id).name == "imperial_order" then
              table.insert(mirror_info, info)
              table.insert(ids, id)
            else
              table.insert(move_info, info)
            end
          end
          if #mirror_info > 0 then
            move.moveInfo = move_info
            local mirror_move = table.clone(move)
            mirror_move.to = nil
            mirror_move.toArea = Card.Void
            mirror_move.moveInfo = mirror_info
            mirror_move.moveVisible = true
            table.insert(mirror_moves, mirror_move)
          end
        end
      end
      if #ids > 0 then
        player.room:sendLog{
          type = "#ImperialOrderRemoved",
          card = ids,
        }
      end
      table.insertTable(data, mirror_moves)
      player.room:setTag("ImperialOrderRemoved", true)
    else
      local room = player.room
      for _, p in ipairs(room:getAlivePlayers()) do
        if p.kingdom == "unknown" then
          doImperialOrder(room, p)
        end
      end
      room:setTag("ImperialOrderRemoved", false)
      room:setTag("ImperialOrderHasRemoved", true)
    end
  end,
}
Fk:addSkill(imperialOrderRemoved)
local imperialOrderSkill = fk.CreateActiveSkill{
  name = "imperial_order_skill",
  prompt = "#imperial_order_skill",
  mod_target_filter = function(self, to_select, selected, user, card, distance_limited)
    return Fk:currentRoom():getPlayerById(to_select).kingdom == "unknown"
  end,
  can_use = function(self, player, card)
    for _, p in ipairs(Fk:currentRoom().alive_players) do
      if not player:isProhibited(p, card) and self:modTargetFilter(p.id, {}, player.id, card, true) then
        return true
      end
    end
  end,
  on_use = function(self, room, use)
    if not use.tos or #TargetGroup:getRealTargets(use.tos) == 0 then
      use.tos = {}
      local user = room:getPlayerById(use.from)
      for _, player in ipairs(room.alive_players) do
        if player.kingdom == "unknown" and not user:isProhibited(player, use.card) then
          TargetGroup:pushTargets(use.tos, player.id)
        end
      end
    end
  end,
  on_effect = function(self, room, effect)
    local target = room:getPlayerById(effect.to)
    doImperialOrder(room, target)
  end,
}
local imperialOrder = fk.CreateTrickCard{
  name = "imperial_order",
  skill = imperialOrderSkill,
  suit = Card.Club,
  number = 3,
  multiple_targets = true,
}
extension:addCard(imperialOrder)

Fk:loadTranslationTable{
  ["imperial_order"] = "敕令",
  [":imperial_order"] = "锦囊牌<br/><b>时机</b>：出牌阶段<br/><b>目标</b>：所有没有势力的角色<br/><b>效果</b>：目标角色选择：1.明置一张武将牌，其摸一张牌；2.弃置一张装备牌；3.失去1点体力。<br/><br/>※此牌不因使用而进入弃牌堆前，改为将此牌移出游戏，回合结束前，没有势力的角色依次执行此牌的效果。",
  ["imperial_order_skill"] = "敕令",
  ["IO_reveal"] = "明置一张武将牌，摸一张牌",
  ["IO_discard"] = "弃置一张装备牌",
  ["IO_hplose"] = "失去1点体力",
  ["#ImperialOrderRemoved"] = "%card 被移出游戏",
  ["#imperial_order_skill"] = "所有没有势力的角色选择：1.明置一张武将牌，摸一张牌；2.弃置一张装备牌；3.失去1点体力",
}

local bladeSkill = fk.CreateTriggerSkill{
  name = "#sa__blade_skill",
  attached_equip = "sa__blade",
  mute = true,
  events = {fk.CardUsing},
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.card.trueName == "slash"
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:broadcastPlaySound("./packages/standard_cards/audio/card/blade")
    room:setEmotion(player, "./packages/standard_cards/image/anim/blade")
    for _, id in ipairs(TargetGroup:getRealTargets(data.tos)) do
      local p = room:getPlayerById(id)
      room:addPlayerMark(p, "@@sa__blade")
      local record = U.getMark(p, MarkEnum.RevealProhibited)
      table.insertTable(record, {"m", "d"})
      room:setPlayerMark(p, MarkEnum.RevealProhibited, record)
      data.extra_data = data.extra_data or {}
      data.extra_data.sa__bladeRevealProhibited = data.extra_data.sa__bladeRevealProhibited or {}
      data.extra_data.sa__bladeRevealProhibited[tostring(id)] = (data.extra_data.sa__bladeRevealProhibited[tostring(id)] or 0) + 1
    end
  end,

  refresh_events = { fk.CardUseFinished },
  can_refresh = function(self, event, target, player, data)
    return data.extra_data and data.extra_data.sa__bladeRevealProhibited
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    for key, num in pairs(data.extra_data.sa__bladeRevealProhibited) do
      local p = room:getPlayerById(tonumber(key))
      if p:getMark("@@sa__blade") > 0 then
        room:removePlayerMark(p, "@@sa__blade", num)
        local record = U.getMark(p, MarkEnum.RevealProhibited)
        table.removeOne(record, "m")
        table.removeOne(record, "d")
        if #record == 0 then record = 0 end
        room:setPlayerMark(p, MarkEnum.RevealProhibited, record)
      end
    end
    data.sa__bladeRevealProhibited = nil
  end,
}
Fk:addSkill(bladeSkill)
local blade = fk.CreateWeapon{
  name = "sa__blade",
  suit = Card.Spade,
  number = 5,
  attack_range = 3,
  equip_skill = bladeSkill,
}

extension:addCard(blade)
Fk:loadTranslationTable{
  ["sa__blade"] = "青龙偃月刀",
  [":sa__blade"] = "装备牌·武器<br /><b>攻击范围</b>：３<br /><b>武器技能</b>：锁定技，当你使用【杀】时，此牌的使用结算结束之前，此【杀】的目标角色不能明置武将牌。",

  ["@@sa__blade"] = "青龙偃月刀",
}

local halberdTargets = fk.CreateActiveSkill{
  name = "#sa__halberd_targets",
  can_use = Util.FalseFunc,
  min_target_num = 1,
  card_num = 0,
  card_filter = Util.FalseFunc,
  target_filter = function(self, to_select, selected)
    local orig = table.simpleClone(Self:getMark("_sa__halberd"))
    if table.contains(orig, to_select) or to_select == Self.id then return false end
    local target = Fk:currentRoom():getPlayerById(to_select)
    local room = Fk:currentRoom()
    if target.kingdom == "unknown" or (table.every(orig, function(id)
      return not H.compareKingdomWith(target, room:getPlayerById(id))
    end) and table.every(selected, function(id)
      return not H.compareKingdomWith(target, room:getPlayerById(id))
    end)) then
      local card = Fk:cloneCard("slash")
      return not Self:isProhibited(target, card) and card.skill:modTargetFilter(to_select, orig, Self.id, card, true)
    end
  end,
}
local halberdDelay = fk.CreateTriggerSkill{
  name = "#sa__halberd_delay",
  mute = true,
  events = {fk.CardEffectCancelledOut},
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    return target == player and data.card.trueName == "slash" and table.contains(data.card.skillNames, "sa__halberd")
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local e = room.logic:getCurrentEvent():findParent(GameEvent.UseCard)
    local use = e.data[1]
    if #TargetGroup:getRealTargets(use.tos) > 0 then
      room:sendLog{
        type = "#HalberdNullified",
        from = target.id,
        -- to = {player.id},
        arg = "sa__halberd",
        arg2 = data.card:toLogString(),
      }
      use.nullifiedTargets = TargetGroup:getRealTargets(use.tos)
    end
  end,
}
local halberdSkill = fk.CreateTriggerSkill{
  name = "#sa__halberd_skill",
  attached_equip = "sa__halberd",
  events = {fk.AfterCardTargetDeclared},
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.card.trueName == "slash" and #U.getUseExtraTargets(player.room, data) > 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "_sa__halberd", TargetGroup:getRealTargets(data.tos))
    local _, ret = room:askForUseActiveSkill(player, "#sa__halberd_targets", "#sa__halberd-ask", true)
    room:setPlayerMark(player, "_sa__halberd", 0)
    if ret then
      self.cost_data = ret.targets
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:broadcastPlaySound("./packages/standard_cards/audio/card/halberd")
    room:setEmotion(player, "./packages/standard_cards/image/anim/halberd")
    room:doIndicate(player.id, self.cost_data)
    data.card.skillName = "sa__halberd"
    room:sendLog{
      type = "#HalberdTargets",
      from = player.id,
      to = self.cost_data,
      arg = "sa__halberd",
      card = Card:getIdList(data.card),
    }
    table.forEach(self.cost_data, function (id)
      table.insert(data.tos, {id})
    end)
  end
}
halberdSkill:addRelatedSkill(halberdTargets)
halberdSkill:addRelatedSkill(halberdDelay)
Fk:addSkill(halberdSkill)
local halberd = fk.CreateWeapon{
  name = "sa__halberd",
  suit = Card.Diamond,
  number = 12,
  attack_range = 4,
  equip_skill = halberdSkill,
}

extension:addCard(halberd)

Fk:loadTranslationTable{
  ["sa__halberd"] = "方天画戟",
  [":sa__halberd"] = "装备牌·武器<br /><b>攻击范围</b>：４<br /><b>武器技能</b>：当你使用【杀】选择目标后，"..
  "可以令任意名{势力各不相同且与已选择的目标势力均不相同的}角色和任意名没有势力的角色也成为目标，当此【杀】被【闪】抵消后，此【杀】对所有目标均无效。",
  ["#sa__halberd_skill"] = "方天画戟",
  ["#sa__halberd_targets"] = "方天画戟",
  ["#sa__halberd-ask"] = "你可发动【方天画戟】，令任意名势力各不相同且与已选择的目标势力均不相同的角色和任意名没有势力的角色也成为目标",
  ["#sa__halberd_delay"] = "方天画戟",
  ["#HalberdTargets"] = "%from 发动了 “%arg” ，令 %to 也成为 %card 的目标",
  ["#HalberdNullified"] = "由于 “%arg” 的效果，%from 对所有剩余目标使用的 %arg2 无效",
}

local damage_nature_table = {
  [fk.NormalDamage] = "normal_damage",
  [fk.FireDamage] = "fire_damage",
  [fk.ThunderDamage] = "thunder_damage",
  [fk.IceDamage] = "ice_damage",
}

local breastplateSkill = fk.CreateTriggerSkill{
  name = "#sa__breastplate_skill",
  attached_equip = "sa__breastplate",
  events = {fk.DamageInflicted},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.damage >= player.hp
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, data, "#sa__breastplate-ask:::" .. data.damage .. ":" .. damage_nature_table[data.damageType])
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:notifySkillInvoked(player, self.name, "defensive")
    room:sendLog{
      type = "#BreastplateSkill",
      from = player.id,
      arg = self.attached_equip,
      arg2 = data.damage,
      arg3 = damage_nature_table[data.damageType],
    }
    room:moveCardTo(table.filter(player:getEquipments(Card.SubtypeArmor), function(id) return Fk:getCardById(id).name == "sa__breastplate" end),
      Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile, self.name, nil, true, player.id)
    return true
  end,
}
Fk:addSkill(breastplateSkill)
local breastplate = fk.CreateArmor{
  name = "sa__breastplate",
  suit = Card.Club,
  number = 2,
  equip_skill = breastplateSkill,
}
extension:addCard(breastplate)
H.addCardToAllianceCards(breastplate)
Fk:loadTranslationTable{
  ["sa__breastplate"] = "护心镜",
  ["#sa__breastplate_skill"] = "护心镜",
  [":sa__breastplate"] = "装备牌·防具<br/><b>防具技能</b>：当你伤害时，若此伤害大于或等于你当前的体力值，你可将装备区里的【护心镜】置入弃牌堆，然后防止此伤害。",
  ["#sa__breastplate-ask"] = "护心镜：你可将装备区里的【护心镜】置入弃牌堆，防止 %arg 点 %arg2 伤害",
  ["#BreastplateSkill"] = "%from 发动了 “%arg”，防止了 %arg2 点 %arg3 伤害",
}

local ironArmorSkill = fk.CreateTriggerSkill{
  name = "#iron_armor_skill",
  attached_equip = "iron_armor",
  frequency = Skill.Compulsory,
  events = {fk.TargetConfirming, fk.BeforeChainStateChange},
  can_trigger = function(self, event, target, player, data)
    if target ~= player or not player:hasSkill(self) then return false end
    if event == fk.TargetConfirming then return table.contains({"fire__slash", "burning_camps", "fire_attack"}, data.card.name) 
    else return H.isSmallKingdomPlayer(player) and not player.chained end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:notifySkillInvoked(player, self.name, "defensive")
    if event == fk.TargetConfirming then 
      AimGroup:cancelTarget(data, player.id)
    end
    return true
  end
}
Fk:addSkill(ironArmorSkill)
local ironArmor = fk.CreateArmor{
  name = "iron_armor",
  suit = Card.Spade,
  number = 2,
  equip_skill = ironArmorSkill,
}
extension:addCard(ironArmor)
Fk:loadTranslationTable{
  ["iron_armor"] = "明光铠",
  ["#iron_armor_skill"] = "明光铠",
  [":iron_armor"] = "装备牌·防具<br/><b>防具技能</b>：锁定技，当你成为【火烧连营】、【火攻】或火【杀】的目标时，你取消此目标；当你横置前，若你是小势力角色，你防止此次横置。",
}

local jingfan = fk.CreateOffensiveRide{
  name = "jingfan",
  suit = Card.Heart,
  number = 3,
}
extension:addCard(jingfan)
H.addCardToAllianceCards(jingfan)
Fk:loadTranslationTable{
  ["jingfan"] = "惊帆",
  [":jingfan"] = "装备牌·坐骑<br /><b>坐骑技能</b>：你与其他角色的距离-1。",
}
local woodenOxSkill = fk.CreateActiveSkill{
  name = "wooden_ox_skill",
  attached_equip = "wooden_ox",
  can_use = function(self, player, card)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
}
-- Fk:addSkill(woodenOxSkill)
local woodenOx = fk.CreateTreasure{
  name = "wooden_ox",
  suit = Card.Diamond,
  number = 5,
  equip_skill = woodenOxSkill,
}
-- extension:addCard(woodenOx)
Fk:loadTranslationTable{
  ["wooden_ox"] = "木牛流马",
  [":wooden_ox"] = "装备牌·宝物<br/><b>宝物技能</b>：<br/>" ..
    "1. 出牌阶段限一次，你可将一张手牌置入仓廪（称为“辎”，“辎”数至多为5），然后你可将装备区里的【木牛流马】置入一名其他角色的装备区。<br/>" ..
    "2. 你能如手牌般使用或打出“辎”。<br/>" ..
    "3. 当你并非因交换而失去装备区里的【木牛流马】前，若目标区域不为其他角色的装备区，当你失去此牌后，你将所有“辎”置入弃牌堆。<br/>" ..
    "◆“辎”对你可见。<br/>◆此延时类效果于你的死亡流程中能被执行。",
  ["wooden_ox_skill"] = "木牛",
  ["#wooden_ox-move"] = "你可以将【木牛流马】移动至一名其他角色的装备区",
  ["carriage&"] = "辎",
}

local jadeSealSkill = fk.CreateTriggerSkill{
  name = "#jade_seal_skill",
  attached_equip = "jade_seal",
  events = {fk.EventPhaseStart, fk.DrawNCards},
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    if target ~= player or not player:hasSkill(self) or not H.isBigKingdomPlayer(player) then return false end
    return event == fk.DrawNCards or player.phase == Player.Play
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if event == fk.EventPhaseStart then
      local card = Fk:cloneCard("known_both")
      local max_num = card.skill:getMaxTargetNum(player, card)
      local targets = {}
      for _, p in ipairs(room:getOtherPlayers(player)) do
        if not player:isProhibited(p, card) then
          table.insert(targets, p.id)
        end
      end
      if #targets == 0 or max_num == 0 then return end
      local to = room:askForChoosePlayers(player, targets, 1, max_num, "#jade_seal-ask", self.name, false)
      if #to > 0 then
        self.cost_data = to
        return true
      end
    else
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.EventPhaseStart then
      room:notifySkillInvoked(player, self.name, "control")
      local targets = table.map(self.cost_data, Util.Id2PlayerMapper)
      room:useVirtualCard("known_both", nil, player, targets, self.name)
    else
      room:notifySkillInvoked(player, self.name, "drawcard")
      data.n = data.n + 1
    end
  end,
}
local jadeSealBig = H.CreateBigKingdomSkill{
  name = "#jade_seal_big",
  attached_equip = "jade_seal",
  fixed_func = function(self, player)
    return player:hasSkill(self) and player.kingdom ~= "unknown"
  end
}
jadeSealSkill:addRelatedSkill(jadeSealBig)
Fk:addSkill(jadeSealSkill)
local jadeSeal = fk.CreateTreasure{
  name = "jade_seal",
  suit = Card.Club,
  number = 1,
  equip_skill = jadeSealSkill,
}
extension:addCard(jadeSeal)
Fk:loadTranslationTable{
  ["jade_seal"] = "玉玺",
  [":jade_seal"] = "装备牌·宝物<br/><b>宝物技能</b>：锁定技，若你有势力，你的势力为大势力，除你的势力外的所有势力均为小势力；摸牌阶段，若你有势力，你令额定摸牌数+1；出牌阶段开始时，若你有势力，你视为使用【知己知彼】。",
  ["#jade_seal_skill"] = "玉玺",
  ["#jade_seal-ask"] = "受到【玉玺】的效果，视为你使用一张【知己知彼】",
}

local alliance = fk.CreateActiveSkill{
  name = "alliance&",
  prompt = "#alliance&",
  anim_type = "support",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0 and table.find(player:getCardIds(Player.Hand), function(id) return Fk:getCardById(id):getMark("@@alliance") > 0 end)
  end,
  max_card_num = 3,
  min_card_num = 1,
  card_filter = function(self, to_select, selected)
    return Fk:getCardById(to_select):getMark("@@alliance") > 0 and table.contains(Self.player_cards[Player.Hand], to_select) and #selected <= 3
  end,
  target_num = 1,
  target_filter = function(self, to_select, selected, selected_cards)
    if #selected == 0 and #selected_cards >= 1 and #selected_cards <= 3 then
      local target = Fk:currentRoom():getPlayerById(to_select)
      return (H.compareKingdomWith(target, Self, true) or target.kingdom == "unknown") and to_select ~= Self.id
    end
  end,
  on_use = function(self, room, effect)
    local target = room:getPlayerById(effect.tos[1])
    local player = room:getPlayerById(effect.from)
    local ret = H.compareKingdomWith(target, player, true)
    room:moveCardTo(effect.cards, Card.PlayerHand, target, fk.ReasonGive, self.name, nil, true, player.id)
    if ret and not player.dead then
      player:drawCards(#effect.cards, self.name)
    end
  end
}
Fk:addSkill(alliance)
Fk:loadTranslationTable{
  ["alliance&"] = "合纵",
  [":alliance&"] = "出牌阶段限一次，你可选择一项：1.若你已确定势力，你可将有“合”标记的至多三张手牌交给与你势力不同的一名角色，摸等量的牌；2.你可将有“合”标记的至多三张手牌交给未确定势力的一名角色。",
  ["#alliance&"] = "合纵：你可将至多3张有“合”标记的手牌交给势力不同或无势力的角色，前者你摸等量的牌",
}

return extension
