local extension = Package:new("power")
extension.extensionName = "hegemony"
extension.game_modes_whitelist = { 'nos_heg_mode', 'new_heg_mode' }
local H = require "packages/hegemony/util"

Fk:loadTranslationTable{
  ["power"] = "君临天下·权",
}
--[[
Fk:loadTranslationTable{
  ["ld__cuiyanmaojie"] = "崔琰＆毛玠",
  ["zhengbi"] = "征辟",
  [":zhengbi"] = "出牌阶段开始时，你可选择：1.选择一名没有势力的角色，你于此回合内对其使用牌无距离关系的限制，且对包括其在内的角色使用牌无次数限制；2.将一张基本牌交给一名有势力的角色，若其有牌且牌数：为1，其将所有牌交给你；大于1，其将一张不是基本牌的牌或两张基本牌交给你。",
  ["ld__fengying"] = "奉迎",
  [":ld__fengying"] = "限定技，出牌阶段，你可将所有手牌当【挟天子以令诸侯】（无目标的限制）使用，当此牌被使用时，你选择所有与你势力相同的角色，这些角色各将手牌补至X张（X为其体力上限）。",
}
]]
local yujin = General(extension, "ld__yujin", "wei", 4)
local jieyue = fk.CreateTriggerSkill{
  name = "ld__jieyue",
  anim_type = "control",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and player.phase == Player.Start and not player:isKongcheng() and table.find(player.room.alive_players, function(p) return
      p.kingdom ~= "wei"
    end)
  end,
  on_cost = function(self, event, target, player, data)
    local plist, cid = player.room:askForChooseCardAndPlayers(player, table.map(table.filter(player.room.alive_players, function(p) return
      p.kingdom ~= "wei"
    end), Util.IdMapper), 1, 1, ".|.|.|hand", "#ld__jieyue-target", self.name, true)
    if #plist > 0 then
      self.cost_data = {plist[1], cid}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = self.cost_data[1]
    local target = room:getPlayerById(to)
    room:moveCardTo(self.cost_data[2], Player.Hand, target, fk.ReasonGive, self.name, nil, false, player.id)
    if H.askCommandTo(player, target, self.name) then
      player:drawCards(1, self.name)
    else
      room:addPlayerMark(player, "_ld__jieyue-turn")
    end
  end
}
local jieyue_draw = fk.CreateTriggerSkill{
  name = "#ld__jieyue_draw",
  mute = true,
  frequency = Skill.Compulsory,
  events = {fk.DrawNCards},
  can_use = function(self, event, target, player, data)
    return target == player and target:getMark("_ld__jieyue-turn") > 0
  end,
  on_use = function(self, event, target, player, data)
    data.n = data.n + 3 * target:getMark("_ld__jieyue-turn")
  end,
}
jieyue:addRelatedSkill(jieyue_draw)

yujin:addSkill(jieyue)
yujin:addCompanions("hs__xiahoudun")

Fk:loadTranslationTable{
  ['ld__yujin'] = '于禁',
  ['ld__jieyue'] = '节钺',
  [':ld__jieyue'] = '准备阶段开始时，你可将一张手牌交给不是魏势力或没有势力的一名角色，对其发起军令。若其：执行，你摸一张牌；不执行，摸牌阶段，你令额定摸牌数+3。',

  ["#ld__jieyue-target"] = "节钺：你可将一张手牌交给不是魏势力或没有势力的一名角色，对其发起军令",
  ["#ld__jieyue_draw"] = "节钺",
}
--[[
Fk:loadTranslationTable{
  ["ld__wangping"] = "王平",
  ["jianglve"] = "将略",
  [":jianglve"] = "限定技，出牌阶段，你可选择军令，然后发动势力召唤。你选择所有与你势力相同的其他角色，这些角色各选择是否执行此军令。你加1点体力上限，回复1点体力。所有选择是的角色各加1点体力上限，回复1点体力。你摸X张牌（X为以此法回复过体力的角色数）。",

  ["ld__fazheng"] = "法正",
  ["ld__enyuan"] = "恩怨",
  [":ld__enyuan"] = "锁定技，当其他角色对你使用【桃】时，其摸一张牌；当你受到伤害后，伤害来源需交给你一张手牌，否则失去1点体力。",
  ["ld__xuanhuo"] = "眩惑",
  [":ld__xuanhuo"] = "与你势力相同的其他角色的出牌阶段限一次，其可以交给你一张手牌，然后其弃置一张牌，选择下列技能中的一个：〖武圣〗〖咆哮〗〖龙胆〗〖铁骑〗〖烈弓〗〖狂骨〗（场上已有的技能无法选择）。其于此回合内或明置有其以此法选择的技能的武将牌之前拥有其以此法选择的技能。",

  ["ld__lukang"] = "陆抗", --手杀版
  ["keshou"] = "恪守",
  [":keshou"] = "当你受到伤害时，你可发动此技能，你可弃置两张颜色相同的手牌，令此伤害值-1。若没有与你势力相同的其他角色，你判定，若结果为红色，你摸一张牌。",
  ["zhuwei"] = "筑围",
  [":zhuwei"] = "当你进行的判定结果确定后，你可获得此牌，然后你可令当前回合角色手牌上限和使用【杀】的次数上限于此回合内+1。",
}
]]
local wuguotai = General(extension, "ld__wuguotai", "wu", 3, 3, General.Female)
local buyi = fk.CreateTriggerSkill{
  name = "ld__buyi",
  anim_type = "support",
  events = {fk.AfterDying},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self.name) and target and H.compareKingdomWith(target, player) and not target.dead 
      and data.damage and data.damage.from and not data.damage.from.dead
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, nil, "#ld__buyi-ask:" .. target.id .. ":" .. data.damage.from.id)
  end,
  on_use = function(self, event, target, player, data)
    if not H.askCommandTo(player, data.damage.from, self.name) then
      player.room:recover({
        who = target,
        num = 1,
        recoverBy = player,
        skillName = self.name,
      })
    end
  end,
}

wuguotai:addSkill(buyi)
wuguotai:addSkill("ganlu")
wuguotai:addCompanions("hs__sunjian")

Fk:loadTranslationTable{
  ['ld__wuguotai'] = '吴国太',
  ['ld__buyi'] = '补益',
  [':ld__buyi'] = '与你势力相同的角色的濒死结算结束后，若其存活，你可对伤害来源发起军令。若来源不执行，则你令该角色回复1点体力。',

  ["#ld__buyi-ask"] = "补益：你可对 %dest 发起军令。若来源不执行，则 %src 回复1点体力",

  ["$ganlu_ld__wuguotai1"] = "玄德，实乃佳婿呀！。", -- 特化
	["$ganlu_ld__wuguotai2"] = "好一个郎才女貌，真是天作之合啊。",
	["$ld__buyi1"] = "有我在，定保贤婿无余！",
	["$ld__buyi2"] = "东吴，岂容汝等儿戏！",
	["~ld__wuguotai"] = "诸位卿家，还请尽力辅佐仲谋啊……",
}
--[[
Fk:loadTranslationTable{
  ['ld__yuanshu'] = '袁术',
  ['ld__yongsi'] = "庸肆",
  [':ld__yongsi'] = "锁定技，若所有角色的装备区里均没有【玉玺】，你视为装备着【玉玺】；你成为【知己知彼】的目标后，展示所有手牌。",
  ['ld__weidi'] = "伪帝",
  [':ld__weidi'] = "出牌阶段限一次，你可选择一名本回合从牌堆获得过牌的其他角色，对其发起军令。若其不执行，则你获得其所有手牌，然后交给其等量的牌。",
}
]]
local zhangxiu = General(extension, "ld__zhangxiu", "qun", 4)
local fudi = fk.CreateTriggerSkill{
  name = 'ld__fudi',
  events = { fk.Damaged },
  anim_type = "masochism",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and data.from and data.from ~= player
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local c = room:askForCard(player, 1, 1, false, self.name, true,
      '.|.|.|hand', '#ld__fudi-give:' .. data.from.id)[1]

    if c then
      self.cost_data = c
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:obtainCard(data.from, self.cost_data, false, fk.ReasonGive)

    local p = data.from
    local x = player.hp
    if not p or p.dead then return end
    local targets = {}
    for _, _p in ipairs(room.alive_players) do
      if H.compareKingdomWith(_p, p) then
        if _p.hp >= x then
          if _p.hp > x then
            targets = {}
            x = _p.hp
          end
          table.insert(targets, _p)
        end
      end
    end
    local to
    if #targets == 0 then return
    elseif #targets == 1 then
      to = targets[1].id
    else
      to = room:askForChoosePlayers(player, table.map(targets, Util.IdMapper),
        1, 1, '#ld__fudi-dmg', self.name, false)[1]
    end

    room:damage {
      from = player,
      to = room:getPlayerById(to),
      damage = 1,
      skillName = self.name,
    }
  end,
}
local congjian = fk.CreateTriggerSkill{
  name = 'ld__congjian',
  anim_type = "offensive",
  events = { fk.DamageInflicted, fk.DamageCaused },
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    if not (target == player and player:hasSkill(self.name)) then return end
    if event == fk.DamageInflicted then
      return player.phase ~= Player.NotActive
    elseif event == fk.DamageCaused then
      return player.phase == Player.NotActive
    end
  end,
  on_use = function(_, _, _, _, data)
    data.damage = data.damage + 1
  end,
}
zhangxiu:addSkill(fudi)
zhangxiu:addSkill(congjian)
zhangxiu:addCompanions("hs__jiaxu")
Fk:loadTranslationTable{
  ['ld__zhangxiu'] = '张绣',
  ['ld__fudi'] = '附敌',
  [':ld__fudi'] = '当你受到其他角色造成的伤害后，你可以交给伤害来源一张手牌。若如此做，你对与其势力相同的角色中体力值最多且不小于你的一名角色造成1点伤害。',
  ['#ld__fudi-give'] = '附敌：你可以交给 %src 一张手牌，然后对其势力体力最大造成一点伤害',
  ['#ld__fudi-dmg'] = '附敌：选择要造成伤害的目标',
  ['ld__congjian'] = '从谏',
  [':ld__congjian'] = '锁定技，当你于回合外造成伤害时或于回合内受到伤害时，伤害值+1。',

  ['$ld__fudi1'] = '弃暗投明，为明公计！',
	['$ld__fudi2'] = '绣虽有降心，奈何贵营难容。',
	['~ld__zhangxiu'] = '若失文和，吾将何归？',
}

return extension
