local extension = Package:new("manoeuvre")
extension.extensionName = "hegemony"
extension.game_modes_whitelist = { 'nos_heg_mode', 'new_heg_mode' }

local H = require "packages/hegemony/util"

Fk:loadTranslationTable{
  ["manoeuvre"] = "十周年-纵横捭阖",
  ["ty_mn"] = "新服",
}

-- local huaxin = General(extension, "ty_mn__huaxin", "wei", 3)
Fk:loadTranslationTable{
  ['ty_mn__huaxin'] = '华歆',
  ["ty_mn__wanggui"] = "望归",
  [":ty_mn__wanggui"] = "每回合限一次，当你造成或受到伤害后，若你：仅明置了此武将牌，你可对与你势力不同的一名角色造成1点伤害；武将牌均明置，你可令所有与你势力相同的角色各摸一张牌。",
  ["ty_mn__wanggui"] = "息兵",
  [":ty_mn__wanggui"] = "当一名其他角色于其出牌阶段内使用第一张黑色【杀】或黑色普通锦囊牌指定一名角色为唯一目标后，你可令其将手牌摸至体力值（至多摸至5张），然后若你与其均明置了所有武将牌，则你可暗置你与其各一张武将牌且本回合不能明置以此法暗置的武将牌。若其因此摸牌，其本回合不能再使用手牌。",

  ["$ty_mn__wanggui1"] = "存志太虚，安心玄妙。",
  ["$ty_mn__wanggui2"] = "礼法有度，良德才略。",
  ["$ty_mn__xibing1"] = "千里运粮，非用兵之利。",
  ["$ty_mn__xibing2"] = "宜弘一代之治，绍三王之迹。",
  ["~ty_mn__huaxin"] = "大举发兵，劳民伤国。",
}

local fengxiw = General(extension, "ty_mn__fengxiw", "wu", 3)
local yusui = fk.CreateTriggerSkill{
  name = "ty_mn__yusui",
  anim_type = "offensive",
  events = {fk.TargetConfirmed},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and data.from ~= player.id and data.card.color == Card.Black and
      player:usedSkillTimes(self.name, Player.HistoryTurn) == 0 and H.compareKingdomWith(player.room:getPlayerById(data.from), player, true) and player.hp > 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(data.from)
    room:loseHp(player, 1, self.name)
    if player.dead then return end
    local choices = {}
    if not to:isKongcheng() then
      table.insert(choices, "ty_mn__yusui_discard::" .. to.id .. ":" .. to.maxHp)
    end
    if to.hp > player.hp then
      table.insert(choices, "ty_mn__yusui_loseHp::" .. to.id .. ":" .. player.hp)
    end
    if #choices == 0 then return false end
    local choice = room:askForChoice(player, choices, self.name)
    if choice:startsWith("ty_mn__yusui_discard") then
      room:askForDiscard(to, to.maxHp, to.maxHp, false, self.name, false)
    else
      room:loseHp(to, to.hp - player.hp, self.name)
    end
  end,
}
local boyan = fk.CreateActiveSkill{
  name = "ty_mn__boyan",
  anim_type = "control",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = function(self, to_select, selected)
    return false
  end,
  target_filter = function(self, to_select, selected)
    return #selected == 0 and to_select ~= Self.id
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    local n = target.maxHp - target:getHandcardNum()
    if n > 0 then
      target:drawCards(n, self.name)
    end
    room:setPlayerMark(target, "@@ty_mn__boyan-turn", 1)
    local choices = {"ty_mn__boyan_mn_ask::" .. target.id, "Cancel"}
    if room:askForChoice(player, choices, self.name) ~= "Cancel" then
      room:setPlayerMark(target, "@@ty_mn__boyan_manoeuvre", 1)
      room:handleAddLoseSkills(target, "ty_mn__boyan_manoeuvre", nil)
    end
  end,
}
local boyan_prohibit = fk.CreateProhibitSkill{
  name = "#ty_mn__boyan_prohibit",
  prohibit_use = function(self, player, card)
    return player:getMark("@@ty_mn__boyan-turn") > 0
  end,
  prohibit_response = function(self, player, card)
    return player:getMark("@@ty_mn__boyan-turn") > 0
  end,
}
boyan:addRelatedSkill(boyan_prohibit)
local boyan_mn = fk.CreateActiveSkill{
  name = "ty_mn__boyan_manoeuvre",
  anim_type = "control",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = function(self, to_select, selected)
    return false
  end,
  target_filter = function(self, to_select, selected)
    return #selected == 0 and to_select ~= Self.id
  end,
  on_use = function(self, room, effect)
    local target = room:getPlayerById(effect.tos[1])
    room:setPlayerMark(target, "@@ty_mn__boyan-turn", 1)
  end,
}
local boyan_mn_detach = fk.CreateTriggerSkill{
  name = "#ty_mn__boyan_manoeuvre_detach",
  refresh_events = {fk.EventPhaseStart},
  can_refresh = function(self, event, target, player, data)
    return target == player and player.phase == Player.NotActive and player:hasSkill("ty_mn__boyan_manoeuvre", true, true) 
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    room:handleAddLoseSkills(player, "-ty_mn__boyan_manoeuvre", nil)
    room:setPlayerMark(player, "@@ty_mn__boyan_manoeuvre", 0)
  end,
}
boyan_mn:addRelatedSkill(boyan_mn_detach)
Fk:addSkill(boyan_mn)

fengxiw:addSkill(yusui)
fengxiw:addSkill(boyan)

Fk:loadTranslationTable{
  ["ty_mn__fengxiw"] = "冯熙",
  ["ty_mn__yusui"] = "玉碎",
  [":ty_mn__yusui"] = "每回合限一次，当你成为其他角色使用黑色牌的目标后，若你与其势力不同，你可失去1点体力，然后选择一项：1.令其弃置X张手牌（X为其体力上限）；2.令其失去体力值至与你相同。",
  ["ty_mn__boyan"] = "驳言",
  [":ty_mn__boyan"] = "出牌阶段限一次，你可选择一名其他角色，其将手牌摸至其体力上限，其本回合不能使用或打出手牌。" .. 
    "<br><font color=\"blue\">◆纵横：删去〖驳言〗描述中的“其将手牌摸至体力上限”。<font><br><font color=\"grey\"><b>纵横</b>：当拥有“纵横”效果技能发动结算完成后，可以令技能目标角色获得对应修订描述后的技能，直到其下回合结束。",

  ["ty_mn__yusui_discard"] = "令%dest弃置%arg张手牌",
  ["ty_mn__yusui_loseHp"] = "令%dest失去体力至%arg",
  ["ty_mn__boyan_mn_ask"] = "令%dest获得〖驳言（纵横）〗直到其下回合结束",
  ["@@ty_mn__boyan-turn"] = "驳言",
  ["@@ty_mn__boyan_manoeuvre"] = "驳言 纵横",

  ["ty_mn__boyan_manoeuvre"] = "驳言(纵横)",
  [":ty_mn__boyan_manoeuvre"] = "出牌阶段限一次，你可选择一名其他角色，其本回合不能使用或打出手牌。",

  ["$ty_mn__boyan1"] = "黑白颠倒，汝言谬矣！",
  ["$ty_mn__boyan2"] = "魏王高论，实为无知之言。",
  ["$ty_mn__yusui1"] = "宁为玉碎，不为瓦全！",
  ["$ty_mn__yusui2"] = "生义相左，舍生取义。",
  ["~ty_mn__fengxi"] = "乡音未改双鬓苍，身陷北国有义求。",
}

return extension
