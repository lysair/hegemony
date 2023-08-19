-- SPDX-License-Identifier: GPL-3.0-or-later

local extension = Package:new("strategic_advantage", Package.CardPack)
extension.extensionName = "hegemony"

local H = require "packages/hegemony/util"

Fk:loadTranslationTable{
  ["strategic_advantage"] = "君临天下·势备篇",
}

extension.game_modes_whitelist = { 'nos_heg_mode', 'new_heg_mode' }
extension.game_modes_blacklist = {"aaa_role_mode", "m_1v1_mode", "m_1v2_mode", "m_2v2_mode", "zombie_mode", "chaos_mode"}

extension:addCards{
  Fk:cloneCard("fire__slash", Card.Diamond, 8),
  Fk:cloneCard("fire__slash", Card.Diamond, 9),

  Fk:cloneCard("analeptic", Card.Spade, 6),
  Fk:cloneCard("analeptic", Card.Club, 9),
}
local burningCampsSkill = fk.CreateActiveSkill{
  name = "burning_camps_skill",
  mod_target_filter = Util.TrueFunc, -- Self->getNextAlive() != Self && Self->getNextAlive()->getFormation().contains(to_select);
  can_use = function(self, player, card)
    return not player:isProhibited(player:getNextAlive(), card) -- 不计入座次……
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
extension:addCards{
  burningCamps,
  burningCamps:clone(Card.Spade, 3),
  burningCamps:clone(Card.Club, 11),
}

Fk:loadTranslationTable{
  ["burning_camps"] = "火烧连营",
  [":burning_camps"] = "锦囊牌<br/><b>时机</b>：出牌阶段<br/><b>目标</b>：你的下家和除其外与其处于同一队列的所有角色<br/><b>效果</b>：目标角色受到你造成的1点火焰伤害。",
}

local fightTogetherSkill = fk.CreateActiveSkill{
  name = "fight_together_skill",
  target_num = 1,
  mod_target_filter = Util.TrueFunc,
  target_filter = function(self, to_select, selected, _, card)
    if #selected == 0 then
      return self:modTargetFilter(to_select, selected, Self.id, card, true)
    end
  end,
  can_use = function(self, player, card)
    if not player:prohibitUse(card) then --and table.find(Fk:currentRoom().alive_players, function(p) return H.isBigKingdomPlayer(p) end)
      local kingdomMapper = {} -- 摘一部分
      for _, p in ipairs(Fk:currentRoom().alive_players) do
        local kingdom = p.kingdom -- p.role
        if kingdom ~= "unknown" then
          if kingdom == "wild" then -- 权宜
            kingdom = tostring(p.id)
          end
          if kingdomMapper[kingdom] then return true end
          kingdomMapper[kingdom] = true
        end
      end
    end
    return false
  end,
  on_use = function(self, room, use)
    if use.tos and #TargetGroup:getRealTargets(use.tos) > 0 then --先1个
      local target = room:getPlayerById(use.tos[1][1])
      local bigKindom, smallKingdom = H.isBigKingdomPlayer(target), H.isSmallKingdomPlayer(target)
      if bigKindom then
        for _, p in ipairs(room.alive_players) do
          if H.isBigKingdomPlayer(p) and p ~= target then
            TargetGroup:pushTargets(use.tos, p.id)
          end
        end
      end
      if smallKingdom then
        for _, p in ipairs(room.alive_players) do
          if H.isSmallKingdomPlayer(p) and p ~= target then
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
}

local breastplateSkill = fk.CreateTriggerSkill{
  name = "#sa__breastplate_skill",
  attached_equip = "sa__breastplate",
  events = {fk.DamageInflicted},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and data.damage >= player.hp
  end,
  on_cost = function(self, event, target, player, data)
    local damage_nature_table = {
      [fk.NormalDamage] = "normal_damage",
      [fk.FireDamage] = "fire_damage",
      [fk.ThunderDamage] = "thunder_damage",
      [fk.IceDamage] = "ice_damage",
    }
    return player.room:askForSkillInvoke(player, self.name, data, "#sa__breastplate-ask:::" .. data.damage .. ":" .. damage_nature_table[data.damageType])
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:notifySkillInvoked(player, self.name, "defensive")
    local damage_nature_table = {
      [fk.NormalDamage] = "normal_damage",
      [fk.FireDamage] = "fire_damage",
      [fk.ThunderDamage] = "thunder_damage",
      [fk.IceDamage] = "ice_damage",
    }
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
    if target ~= player or not player:hasSkill(self.name) then return false end
    if event == fk.TargetConfirming then return table.contains({"fire__slash", "burning_camps", "fire_attack"}, data.card.name) 
    else return H.isSmallKingdomPlayer(player) and not player.chained end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:notifySkillInvoked(player, self.name, "defensive")
    if event == fk.TargetConfirming then 
      AimGroup:cancelTarget(data, player.id)
    else
      return true
    end
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

return extension
