-- SPDX-License-Identifier: GPL-3.0-or-later

local extension = Package:new("hegemony_cards", Package.CardPack)

Fk:loadTranslationTable{
  ["hegemony_cards"] = "国战标准版",
}

extension.game_modes_whitelist = { 'nos_heg_mode', 'new_heg_mode' }
extension.game_modes_blacklist = {"aaa_role_mode", "m_1v1_mode", "m_1v2_mode", "m_2v2_mode", "zombie_mode", "chaos_mode"}

local function noKingdom(player)
  return player.general == "anjiang" and player.deputyGeneral == "anjiang"
end

local function sameKingdom(player, target) --isFriendWith
  if player == target then return true end
  return player.kingdom == target.kingdom and player.kingdom ~= "wild" and not noKingdom(player) --野心家拉拢……
end

extension:addCards{
  Fk:cloneCard("slash", Card.Spade, 5),
  Fk:cloneCard("slash", Card.Spade, 7),
  Fk:cloneCard("slash", Card.Spade, 8),
  Fk:cloneCard("slash", Card.Spade, 8),
  Fk:cloneCard("slash", Card.Spade, 9),
  Fk:cloneCard("slash", Card.Spade, 10),
  Fk:cloneCard("slash", Card.Spade, 11),
  Fk:cloneCard("slash", Card.Heart, 10),
  Fk:cloneCard("slash", Card.Heart, 12),
  Fk:cloneCard("slash", Card.Club, 2),
  Fk:cloneCard("slash", Card.Club, 3),
  Fk:cloneCard("slash", Card.Club, 4),
  Fk:cloneCard("slash", Card.Club, 5),
  Fk:cloneCard("slash", Card.Club, 8),
  Fk:cloneCard("slash", Card.Club, 9),
  Fk:cloneCard("slash", Card.Club, 10),
  Fk:cloneCard("slash", Card.Club, 11),
  Fk:cloneCard("slash", Card.Club, 12),
  Fk:cloneCard("slash", Card.Diamond, 10),
  Fk:cloneCard("slash", Card.Diamond, 11),
  Fk:cloneCard("slash", Card.Diamond, 12),

  Fk:cloneCard("thunder__slash", Card.Spade, 6),
  Fk:cloneCard("thunder__slash", Card.Spade, 7),
  Fk:cloneCard("thunder__slash", Card.Club, 6),
  Fk:cloneCard("thunder__slash", Card.Club, 7),
  Fk:cloneCard("thunder__slash", Card.Club, 8),

  Fk:cloneCard("fire__slash", Card.Heart, 4),
  Fk:cloneCard("fire__slash", Card.Diamond, 4),
  Fk:cloneCard("fire__slash", Card.Diamond, 5),

  Fk:cloneCard("jink", Card.Heart, 2),
  Fk:cloneCard("jink", Card.Heart, 11),
  Fk:cloneCard("jink", Card.Heart, 13),
  Fk:cloneCard("jink", Card.Diamond, 2),
  Fk:cloneCard("jink", Card.Diamond, 3),
  Fk:cloneCard("jink", Card.Diamond, 6),
  Fk:cloneCard("jink", Card.Diamond, 7),
  Fk:cloneCard("jink", Card.Diamond, 7),
  Fk:cloneCard("jink", Card.Diamond, 8),
  Fk:cloneCard("jink", Card.Diamond, 8),
  Fk:cloneCard("jink", Card.Diamond, 9),
  Fk:cloneCard("jink", Card.Diamond, 10),
  Fk:cloneCard("jink", Card.Diamond, 11),
  Fk:cloneCard("jink", Card.Diamond, 13),

  Fk:cloneCard("peach", Card.Heart, 4),
  Fk:cloneCard("peach", Card.Heart, 6),
  Fk:cloneCard("peach", Card.Heart, 7),
  Fk:cloneCard("peach", Card.Heart, 8),
  Fk:cloneCard("peach", Card.Heart, 9),
  Fk:cloneCard("peach", Card.Heart, 10),
  Fk:cloneCard("peach", Card.Heart, 12),
  Fk:cloneCard("peach", Card.Diamond, 2),

  Fk:cloneCard("analeptic", Card.Spade, 9),
  Fk:cloneCard("analeptic", Card.Club, 9),
  Fk:cloneCard("analeptic", Card.Diamond, 9),
}

extension:addCards{
  Fk:cloneCard("dismantlement", Card.Spade, 3),
  Fk:cloneCard("dismantlement", Card.Spade, 4),
  Fk:cloneCard("dismantlement", Card.Heart, 12),
  Fk:cloneCard("snatch", Card.Diamond, 3),
  Fk:cloneCard("snatch", Card.Spade, 3),
  Fk:cloneCard("snatch", Card.Spade, 4),
  Fk:cloneCard("duel", Card.Spade, 1),
  Fk:cloneCard("duel", Card.Club, 1),
  Fk:cloneCard("collateral", Card.Club, 12),
  Fk:cloneCard("ex_nihilo", Card.Heart, 7),
  Fk:cloneCard("ex_nihilo", Card.Heart, 8),
  Fk:cloneCard("nullification", Card.Spade, 11),
  Fk:cloneCard("nullification", Card.Club, 13),--国
  Fk:cloneCard("nullification", Card.Diamond, 12),--国
  Fk:cloneCard("savage_assault", Card.Spade, 13),
  Fk:cloneCard("savage_assault", Card.Club, 7),
  Fk:cloneCard("archery_attack", Card.Heart, 1),
  Fk:cloneCard("god_salvation", Card.Heart, 1),
  Fk:cloneCard("amazing_grace", Card.Heart, 3),
  Fk:cloneCard("lightning", Card.Spade, 1),
  Fk:cloneCard("indulgence", Card.Heart, 6),
  Fk:cloneCard("indulgence", Card.Club, 6),
  Fk:cloneCard("fire_attack", Card.Heart, 2),
  Fk:cloneCard("fire_attack", Card.Heart, 3),
  Fk:cloneCard("iron_chain", Card.Spade, 12),
  Fk:cloneCard("iron_chain", Card.Club, 12),
  Fk:cloneCard("iron_chain", Card.Club, 13),
  Fk:cloneCard("supply_shortage", Card.Spade, 10),
  Fk:cloneCard("supply_shortage", Card.Club, 10),
}

local befriendAttackingSkill = fk.CreateActiveSkill{
  name = "befriend_attacking_skill",
  target_num = 1,
  mod_target_filter = function(self, to_select, selected, user)
    local target = Fk:currentRoom():getPlayerById(to_select)
    local player = Fk:currentRoom():getPlayerById(user)
    return player ~= target and target.kingdom ~= "unknown" and not sameKingdom(target, player)
  end,
  target_filter = function(self, to_select, selected, _, card)
    if #selected == 0 then
      return Self.kingdom ~= "unknown" and self:modTargetFilter(to_select, selected, Self.id, card, true)
    end
  end,
  on_effect = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.to)
    if target.dead then return end
    target:drawCards(1, "befriend_attacking")
    if player.dead then return end
    player:drawCards(3, "befriend_attacking")
  end
}
local befriendAttacking = fk.CreateTrickCard{
  name = "befriend_attacking",
  skill = befriendAttackingSkill,
}
extension:addCards({
  befriendAttacking:clone(Card.Heart, 9),
})
Fk:loadTranslationTable{
  ["befriend_attacking"] = "远交近攻",
  ["befriend_attacking_skill"] = "远交近攻",
  [":befriend_attacking"] = "锦囊牌<br/><b>时机</b>：出牌阶段<br/><b>目标</b>：有明置武将且势力与你不同的一名角色<br/><b>效果</b>：目标角色"..
  "摸一张牌，然后你摸三张牌。",
}

local knownBothSkill = fk.CreateActiveSkill{
  name = "known_both_skill",
  target_num = 1,
  mod_target_filter = function(self, to_select, selected, user)
    local target = Fk:currentRoom():getPlayerById(to_select)
    return Fk:currentRoom():getPlayerById(user) ~= target and (not target:isKongcheng() or noKingdom(target))
  end,
  target_filter = function(self, to_select, selected, _, card)
    if #selected == 0 then
      return self:modTargetFilter(to_select, selected, Self.id, card, true)
    end
  end,
  on_effect = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.to)
    if target.dead or player.dead then return end
    local all_choices = {"known_both_main", "known_both_deputy", "known_both_hand"}
    local choices = table.clone(all_choices)
    if target:isKongcheng() then
      table.remove(choices)
    end
    if target.general ~= "anjiang" then
      table.remove(choices, 1)
    end
    if target.deputyGeneral ~= "anjiang" then
      table.removeOne(choices, "known_both_deputy")
    end
    if #choices == 0 then return end
    local choice = room:askForChoice(player, choices, self.name, "#known_both-choice::"..target.id, false, all_choices)
    if choice == "known_both_hand" then
      room:fillAG(player, target.player_cards[Player.Hand])
      room:delay(5000)
      room:closeAG(player)
    else
      local general = choice == "known_both_main" and {target:getMark("__heg_general"), target.deputyGeneral, target.seat} or {target.general, target:getMark("__heg_deputy"), target.seat}
      room:askForCustomDialog(player, self.name, "packages/hegemony/qml/KnownBothBox.qml", general)
    end
  end,
}
local knownBoth = fk.CreateTrickCard{
  name = "known_both",
  skill = knownBothSkill,
  special_skills = {"recast"},
}
extension:addCards{
  knownBoth:clone(Card.Club, 3),
  knownBoth:clone(Card.Club, 4),
}
Fk:loadTranslationTable{
  ["known_both"] = "知己知彼",
  ["known_both_skill"] = "知己知彼",
  [":known_both"] = "锦囊牌<br/><b>时机</b>：出牌阶段<br/><b>目标</b>：一名其他角色<br/><b>效果</b>：观看其一张暗置的武将牌或其手牌。",
  ["#known_both-choice"] = "知己知彼：选择对 %dest 执行的一项",
  ["known_both_main"] = "观看主将",
  ["known_both_deputy"] = "观看副将",
  ["known_both_hand"] = "观看手牌",
  ["#KnownBothGeneral"] = "观看武将",
}

local awaitExhaustedSkill = fk.CreateActiveSkill{
  name = "await_exhausted_skill",
  mod_target_filter = Util.TrueFunc,
  can_use = function(self, player, card)
    return not player:isProhibited(player, card)
  end,
  on_use = function(self, room, use)
    if not use.tos or #TargetGroup:getRealTargets(use.tos) == 0 then
      local player = room:getPlayerById(use.from)
      if player.kingdom == "unknown" then
        use.tos = {{use.from}}
      else
        use.tos = {}
        for _, p in ipairs(room:getAlivePlayers()) do
          if not player:isProhibited(p, use.card) and player.kingdom == p.kingdom then
            TargetGroup:pushTargets(use.tos, p.id)
          end
        end
      end
    end
  end,
  on_effect = function(self, room, effect)
    local target = room:getPlayerById(effect.to)
    if target.dead then return end
    target:drawCards(2, "await_exhausted")
    if target.dead then return end
      room:askForDiscard(target, 2, 2, true, self.name, false)
  end,
}
local awaitExhausted = fk.CreateTrickCard{
  name = "await_exhausted",
  skill = awaitExhaustedSkill,
  multiple_targets = true,
}
extension:addCards({
  awaitExhausted:clone(Card.Heart, 11),
  awaitExhausted:clone(Card.Diamond, 4),
})
Fk:loadTranslationTable{
  ["await_exhausted"] = "以逸待劳",
  ["await_exhausted_skill"] = "以逸待劳",
  [":await_exhausted"] = "锦囊牌<br/><b>时机</b>：出牌阶段<br/><b>目标</b>：你和与你势力相同的角色<br/><b>效果</b>：每名目标角色各摸两张牌，"..
  "然后弃置两张牌。",
}

extension:addCards{
  Fk:cloneCard("crossbow", Card.Diamond, 1),
  Fk:cloneCard("qinggang_sword", Card.Spade, 6),
  Fk:cloneCard("ice_sword", Card.Spade, 2),
  --Fk:cloneCard("double_swords", Card.Spade, 2),
}

local doubleSwordsSkill = fk.CreateTriggerSkill{
  name = "#heg__double_swords_skill",
  attached_equip = "heg__double_swords",
  events = {fk.TargetSpecified},
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self.name) and
      data.card and data.card.trueName == "slash" then
      local target = player.room:getPlayerById(data.to)
      return target.gender ~= player.gender and not (noKingdom(player) or noKingdom(target))
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = player.room:getPlayerById(data.to)
    if to:isKongcheng() then
      player:drawCards(1, self.name)
    else
      local result = room:askForDiscard(to, 1, 1, false, self.name, true, ".", "#double_swords-invoke:"..player.id)
      if #result == 0 then
        player:drawCards(1, self.name)
      end
    end
  end,
}
Fk:addSkill(doubleSwordsSkill)
local doubleSwords = fk.CreateWeapon{
  name = "heg__double_swords",
  suit = Card.Spade,
  number = 2,
  attack_range = 2,
  equip_skill = doubleSwordsSkill,
}
extension:addCard(doubleSwords)
Fk:loadTranslationTable{
  ["heg__double_swords"] = "雌雄双股剑",
  [":heg__double_swords"] = "装备牌·武器<br /><b>攻击范围</b>：２<br /><b>武器技能</b>：每当你指定异性角色为【杀】的目标后，你可以令其选择一项：弃置一张手牌，或令你摸一张牌。",
  ["#heg__double_swords_skill"] = "雌雄双股剑",
}

local sixSwordsSkill = fk.CreateAttackRangeSkill{
  name = "#six_swords_skill",
  attached_equip = "six_swords",
  frequency = Skill.Compulsory,
  correct_func = function (self, from, to)
    if from.kingdom ~= "unknown" then
      if table.find(Fk:currentRoom().alive_players, function(p)
        return p.kingdom ~= "unknown" and from.kingdom == p.kingdom and from ~= p and
          p:getEquipment(Card.SubtypeWeapon) and Fk:getCardById(p:getEquipment(Card.SubtypeWeapon)).name == "six_swords" end) then
        return 1
      end
    end
    return 0
  end,
}
Fk:addSkill(sixSwordsSkill)
local sixSwords = fk.CreateWeapon{
  name = "six_swords",
  suit = Card.Diamond,
  number = 2,
  attack_range = 2,
  equip_skill = sixSwordsSkill,
}
extension:addCard(sixSwords)
Fk:loadTranslationTable{
  ["six_swords"] = "吴六剑",
  [":six_swords"] = "装备牌·武器<br/><b>攻击范围</b>：２ <br/><b>武器技能</b>：锁定技，与你势力相同的其他角色攻击范围+1。",
}

extension:addCards{
  Fk:cloneCard("spear", Card.Spade, 12),
  Fk:cloneCard("axe", Card.Diamond, 5),
}

local tribladeSkill = fk.CreateTriggerSkill{
  name = "#triblade_skill",
  attached_equip = "triblade",
  events = {fk.Damage},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and data.card and data.card.trueName == "slash" and not data.to.dead and not data.chain and
      not player:isKongcheng() and table.find(player.room.alive_players, function(p) return data.to:distanceTo(p) == 1 end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.map(table.filter(room.alive_players, function(p)
      return data.to:distanceTo(p) == 1 end), function (p) return p.id end)
    local to, card = room:askForChooseCardAndPlayers(player, targets, 1, 1, ".|.|.|hand", "#triblade-invoke::"..data.to.id, self.name, true)
    if #to > 0 then
      self.cost_data = {to[1], card}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = self.cost_data[1]
    room:doIndicate(player.id, {to})
    room:throwCard(self.cost_data[2], self.name, player, player)
    room:damage{
      from = player,
      to = room:getPlayerById(to),
      damage = 1,
      skillName = self.name,
    }
  end
}
Fk:addSkill(tribladeSkill)
local triblade = fk.CreateWeapon{
  name = "triblade",
  suit = Card.Diamond,
  number = 12,
  attack_range = 3,
  equip_skill = tribladeSkill,
}
extension:addCard(triblade)
Fk:loadTranslationTable{
  ["triblade"] = "三尖两刃刀",
  ["#triblade_skill"] = "三尖两刃刀",
  [":triblade"] = "装备牌·武器<br/><b>攻击范围</b>：３ <br/><b>武器技能</b>：当你使用【杀】对目标角色造成伤害后，你可以弃置一张手牌，"..
  "对其距离1的另一名角色造成1点伤害。",
  ["#triblade-invoke"] = "三尖两刃刀：你可以弃置一张手牌，对 %dest 距离1的一名角色造成1点伤害",
}

extension:addCards{
  Fk:cloneCard("fan", Card.Diamond, 1),
  Fk:cloneCard("kylin_bow", Card.Heart, 5),

  Fk:cloneCard("eight_diagram", Card.Spade, 2),
  Fk:cloneCard("nioh_shield", Card.Club, 2),
}

local silverLionSkill = fk.CreateTriggerSkill{
  name = "#heg__silver_lion_skill",
  attached_equip = "heg__silver_lion",
  frequency = Skill.Compulsory,
  events = {fk.DamageInflicted},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and data.damage > 1
  end,
  on_use = function(_, _, _, _, data)
    data.damage = 1
  end,
}
Fk:addSkill(silverLionSkill)
local silverLion = fk.CreateArmor{
  name = "heg__silver_lion",
  suit = Card.Club,
  number = 1,
  equip_skill = silverLionSkill,
  on_uninstall = function(self, room, player)
    Armor.onUninstall(self, room, player)
    if player:isAlive() and player:isWounded() and self.equip_skill:isEffectable(player) then
      room:broadcastPlaySound("./packages/maneuvering/audio/card/silver_lion")
      room:setEmotion(player, "./packages/maneuvering/image/anim/silver_lion")
      room:recover{
        who = player,
        num = 1,
        skillName = self.name
      }
    end
  end,
}
extension:addCard(silverLion)
Fk:loadTranslationTable{
  ["heg__silver_lion"] = "白银狮子",
  [":heg__silver_lion"] = "装备牌·防具<br /><b>防具技能</b>：锁定技，当你受到伤害时，若此伤害大于1点，防止多余的伤害。当你失去装备区里的【白银狮子】后，你回复1点体力。",
}

extension:addCards{
  --Fk:cloneCard("silver_lion", Card.Club, 1),
  Fk:cloneCard("vine", Card.Club, 2),

  Fk:cloneCard("dilu", Card.Club, 5),
  Fk:cloneCard("jueying", Card.Spade, 5),
  Fk:cloneCard("zhuahuangfeidian", Card.Heart, 13),
  Fk:cloneCard("chitu", Card.Heart, 5),
  Fk:cloneCard("dayuan", Card.Spade, 13),
  Fk:cloneCard("zixing", Card.Diamond, 13),
}

return extension
