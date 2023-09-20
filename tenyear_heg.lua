local extension = Package:new("tenyear_heg")
extension.extensionName = "hegemony"
extension.game_modes_whitelist = { 'nos_heg_mode', 'new_heg_mode' }

local H = require "packages/hegemony/util"

Fk:loadTranslationTable{
  ["tenyear_heg"] = "国战-十周年专属",
  ["ty_heg"] = "新服",
}

local huaxin = General(extension, "ty_heg__huaxin", "wei", 3)
local wanggui = fk.CreateTriggerSkill{
  name = "ty_heg__wanggui",
  mute = true,
  events = {fk.Damage, fk.Damaged},
  can_trigger = function(self, event, target, player, data)
    if target ~= player or not player:hasSkill(self.name) or player:usedSkillTimes(self.name) > 0 then return false end
    return table.contains(player.player_skills, self) -- 此武将已明置
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if player.general ~= "anjiang" and player.deputyGeneral ~= "anjiang" then
      if room:askForSkillInvoke(player, self.name, data, "#ty_heg__wanggui_draw-invoke") then
        self.cost_data = nil
        return true
      end
    else
      local targets = table.map(table.filter(room.alive_players, function(p)
        return H.compareKingdomWith(p, player, true) end), function(p) return p.id end)
      if #targets == 0 then return end
      local to = room:askForChoosePlayers(player, targets, 1, 1, "#ty_heg__wanggui_damage-choose", self.name, true)
      if #to > 0 then
        self.cost_data = to[1]
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke(self.name)
    if self.cost_data then
      room:notifySkillInvoked(player, self.name, "offensive")
      local to = room:getPlayerById(self.cost_data)
      room:damage{
        from = player,
        to = to,
        damage = 1,
        skillName = self.name,
      }
    else
      room:notifySkillInvoked(player, self.name, "drawcard")
      local targets = table.map(table.filter(room.alive_players, function(p) return H.compareKingdomWith(p, player) end), Util.IdMapper)
      room:sortPlayersByAction(targets)
      for _, pid in ipairs(targets) do
        local p = room:getPlayerById(pid)
        if not p.dead then
          p:drawCards(1, self.name)
        end
      end
    end
  end,
}
local xibing = fk.CreateTriggerSkill{
  name = "ty_heg__xibing",
  anim_type = "control",
  events = {fk.TargetSpecified},
  can_trigger = function(self, event, target, player, data)
    if not (player:hasSkill(self.name) and target ~= player and target.phase == Player.Play and
      data.card.color == Card.Black and (data.card.trueName == "slash" or data.card:isCommonTrick()) and #AimGroup:getAllTargets(data.tos) == 1) then return false end
    local events = target.room.logic:getEventsOfScope(GameEvent.UseCard, 1, function(e) 
      local use = e.data[1]
      return use.from == target.id and use.card.color == Card.Black and (use.card.trueName == "slash" or use.card:isCommonTrick())
    end, Player.HistoryTurn)
    return #events == 1 and events[1].id == target.room.logic:getCurrentEvent().id
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, nil, "#ty_heg__xibing-invoke::"..target.id)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:doIndicate(player.id, {target.id})
    local num = math.min(target.hp, 5) - target:getHandcardNum()
    local cards
    if num > 0 then
      cards = target:drawCards(num, self.name)
    end
    if H.getGeneralsRevealedNum(player) == 2 and H.getGeneralsRevealedNum(target) == 2
      and room:askForChoice(player, {"ty_heg__xibing_hide::" .. target.id, "Cancel"}, self.name) ~= "Cancel" then
      for _, p in ipairs({player, target}) do
        local isDeputy = H.doHideGeneral(room, player, p, self.name)
        room:setPlayerMark(p, "@ty_heg__xibing_reveal-turn", H.getActualGeneral(p, isDeputy))
        local record = type(p:getMark(MarkEnum.RevealProhibited .. "-turn")) == "table" and p:getMark(MarkEnum.RevealProhibited .. "-turn") or {}
        table.insert(record, isDeputy and "d" or "m")
        room:setPlayerMark(p, MarkEnum.RevealProhibited .. "-turn", record)
      end
    end
    if cards and not target.dead then
      room:setPlayerMark(target, "@@ty_heg__xibing-turn", 1)
    end
  end,
}
local xibing_prohibit = fk.CreateProhibitSkill{
  name = "#ty_heg__xibing_prohibit",
  prohibit_use = function(self, player, card)
    if player:getMark("@@ty_heg__xibing-turn") == 0 then return false end 
    local subcards = Card:getIdList(card)
    return #subcards > 0 and table.every(subcards, function(id)
      return table.contains(player:getCardIds(Player.Hand), id)
    end)
  end,
}
xibing:addRelatedSkill(xibing_prohibit)

huaxin:addSkill(wanggui)
huaxin:addSkill(xibing)

Fk:loadTranslationTable{
  ["ty_heg__huaxin"] = "华歆",
  ["ty_heg__wanggui"] = "望归",
  [":ty_heg__wanggui"] = "每回合限一次，当你造成或受到伤害后，若你：仅明置了此武将牌，你可对与你势力不同的一名角色造成1点伤害；武将牌均明置，"..
  "你可令所有与你势力相同的角色各摸一张牌。",
  ["ty_heg__xibing"] = "息兵",
  [":ty_heg__xibing"] = "当一名其他角色于其出牌阶段内使用第一张黑色【杀】或黑色普通锦囊牌指定一名角色为唯一目标后，你可令其将手牌摸至体力值"..
  "（至多摸至五张），然后若你与其均明置了所有武将牌，则你可暗置你与其各一张武将牌且本回合不能明置以此法暗置的武将牌。若其因此摸牌，其本回合不能使用手牌。",

  ["#ty_heg__xibing-invoke"] = "你想对 %dest 发动 “息兵” 吗？",
  ["ty_heg__xibing_hide"] = "暗置你与%dest各一张武将牌且本回合不能明置",
  ["@ty_heg__xibing_reveal-turn"] = "息兵禁亮",
  ["@@ty_heg__xibing-turn"] = "息兵 禁用手牌",
  ["#ty_heg__wanggui_damage-choose"] = "望归：你可对与你势力不同的一名角色造成1点伤害",
  ["#ty_heg__wanggui_draw-invoke"] = "望归：你可令所有与你势力相同的角色各摸一张牌",

  ["$ty_heg__wanggui1"] = "存志太虚，安心玄妙。",
  ["$ty_heg__wanggui2"] = "礼法有度，良德才略。",
  ["$ty_heg__xibing1"] = "千里运粮，非用兵之利。",
  ["$ty_heg__xibing2"] = "宜弘一代之治，绍三王之迹。",
  ["~ty_heg__huaxin"] = "大举发兵，劳民伤国。",
}

local yanghu = General(extension, "ty_heg__yanghu", "wei", 3)
local deshao = fk.CreateTriggerSkill{
  name = "ty_heg__deshao",
  anim_type = "defensive",
  events = {fk.TargetSpecified},
  can_trigger = function (self, event, target, player, data)
    return target ~= player and player:hasSkill(self.name) and #TargetGroup:getRealTargets(data.tos) == 1
      and data.card.color == Card.Black
      and TargetGroup:getRealTargets(data.tos)[1] == player.id and H.getGeneralsRevealedNum(player) >= H.getGeneralsRevealedNum(target) 
      and player:usedSkillTimes(self.name, Player.HistoryTurn) < player.hp
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, nil, "#ty_heg__deshao-invoke::"..data.from)
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local from = room:getPlayerById(data.from)
    if from:getHandcardNum() ~= 0 then
      local id = room:askForCardChosen(player, from, "he", self.name)
      room:throwCard(id, self.name, from, player)
    end
  end,
}

local mingfa = fk.CreateActiveSkill{
  name = "ty_heg__mingfa",
  anim_type = "offensive",
  card_num = 0,
  target_num = 1,
  can_use = function (self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = function (self, to_select, selected)
    return false
  end,
  target_filter = function (self, to_select, selected)
    return #selected == 0 and to_select ~= Self.id and (not H.compareKingdomWith(Fk:currentRoom():getPlayerById(to_select), Self))
  end,
  on_use = function(self, room, effect)
    local target = room:getPlayerById(effect.tos[1])
    local mark = type(target:getMark("@@ty_heg__mingfa_delay")) == "table" and target:getMark("@@ty_heg__mingfa_delay") or {}
    table.insert(mark, effect.from)
    room:setPlayerMark(target, "@@ty_heg__mingfa_delay", mark)
  end,
}

local mingfa_delay = fk.CreateTriggerSkill{
  name = "#ty_heg__mingfa_delay",
  anim_type = "offensive",
  events = {fk.EventPhaseChanging},
  can_trigger = function (self, event, target, player, data)
    if target.dead or data.to ~= Player.NotActive or player.dead then return false end
    local mark = target:getMark("@@ty_heg__mingfa_delay")
    return type(mark) == "table" and table.contains(mark, player.id)
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    local room = player.room
    if player:getHandcardNum() > target:getHandcardNum() then
      room:damage{
        from = player,
        to = target,
        damage = 1,
        skillName = self.name,
      }
      if target:getHandcardNum() > 0 then
        local cards = room:askForCardsChosen(player, target, 1, 1, "h", self.name)
        local dummy = Fk:cloneCard("dilu")
        dummy:addSubcards(cards)
        room:obtainCard(player, dummy, false, fk.ReasonPrey)
      end
    elseif player:getHandcardNum() < target:getHandcardNum() then
      player:drawCards(math.min(target:getHandcardNum() - player:getHandcardNum(), 5), self.name)
    end
  end,

  refresh_events = {fk.AfterTurnEnd, fk.BuryVictim},
  can_refresh = function(self, event, target, player, data)
    if event == fk.AfterTurnEnd then
      return player == target and player:getMark("@@ty_heg__mingfa_delay") ~= 0
    elseif event == fk.BuryVictim then
      local mark = player:getMark("@@ty_heg__mingfa_delay")
      return type(mark) == "table" and table.every(player.room.alive_players, function (p)
        return not table.contains(mark, p.id)
      end)
    end
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@@ty_heg__mingfa_delay", 0)
  end,
}

mingfa:addRelatedSkill(mingfa_delay)
yanghu:addSkill(deshao)
yanghu:addSkill(mingfa)
Fk:loadTranslationTable{
  ["ty_heg__yanghu"] = "羊祜",
  ["ty_heg__deshao"] = "德劭",
  [":ty_heg__deshao"] = "每回合限X次（X为你的体力值），当其他角色使用黑色牌指定你为唯一目标后，若其明置的武将牌数不大于你，你可弃置其一张牌。",
  ["ty_heg__mingfa"] = "明伐",
  [":ty_heg__mingfa"] = "出牌阶段限一次，你可以选择其他势力的一名角色，其下个回合结束时，若其手牌数：小于你，你对其造成1点伤害并获得其一张手牌；"..
  "不小于你，你摸至与其手牌数相同（最多摸五张）。",
  ["#ty_heg__mingfa_delay"] = "明伐",
  ["@@ty_heg__mingfa_delay"] = "明伐",
  ["#ty_heg__deshao-invoke"] = "德劭：你可以弃置 %dest 一张牌",

  ["$ty_heg__deshao1"] = "名德远播，朝野俱瞻。",
  ["$ty_heg__deshao2"] = "增修德信，以诚服人。",
  ["$ty_heg__mingfa1"] = "煌煌大势，无须诈取。",
  ["$ty_heg__mingfa2"] = "开示公道，不为掩袭。",
  ["~ty_heg__yanghu"] = "臣死之后，杜元凯可继之……",
}


local zongyu = General(extension, "ty_heg__zongyu", "shu", 3)
local qiao = fk.CreateTriggerSkill{
  name = "ty_heg__qiao",
  anim_type = "control",
  events = {fk.TargetConfirmed},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and
      not player.room:getPlayerById(data.from):isNude() and player:usedSkillTimes(self.name, Player.HistoryTurn) < 2
      and not H.compareKingdomWith(player.room:getPlayerById(data.from), player)
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, nil, "#ty_heg__qiao-invoke::"..data.from)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local from = room:getPlayerById(data.from)
    local id = room:askForCardChosen(player, from, "he", self.name)
    room:throwCard({id}, self.name, from, player)
    if not player:isNude() then
      room:askForDiscard(player, 1, 1, true, self.name, false)
    end
  end,
}
local chengshang = fk.CreateTriggerSkill{
  name = "ty_heg__chengshang",
  anim_type = "drawcard",
  events = {fk.CardUseFinished},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and player.phase == Player.Play and data.tos and data.card.type ~= Card.TypeEquip and -- FIXME
      table.find(TargetGroup:getRealTargets(data.tos), function(id) return not H.compareKingdomWith(Fk:currentRoom():getPlayerById(id), Self) end) 
      and not data.damageDealt and data.card.suit ~= Card.NoSuit and player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, nil,
      "#ty_heg__chengshang-invoke:::"..data.card:getSuitCompletedString(true))
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = room:getCardsFromPileByRule(".|"..tostring(data.card.number).."|"..data.card:getSuitString())
    if #cards > 0 then
      room:moveCards({
        ids = cards,
        to = player.id,
        toArea = Card.PlayerHand,
        moveReason = fk.ReasonJustMove,
        proposer = player.id,
        skillName = self.name,
      })
    else
      player:setSkillUseHistory(self.name, 0, Player.HistoryPhase)
    end
  end,
}
zongyu:addSkill(qiao)
zongyu:addSkill(chengshang)

Fk:loadTranslationTable{
  ["ty_heg__zongyu"] = "宗预",
  ["ty_heg__qiao"] = "气傲",
  [":ty_heg__qiao"] = "每回合限两次，当你成为其他势力角色使用牌的目标后，你可弃置其一张牌，然后你弃置一张牌。",
  ["ty_heg__chengshang"] = "承赏",
  [":ty_heg__chengshang"] = "当你使用指定有其他势力角色为目标的牌结算后，若此时为你的出牌阶段且你未发动过此技能，且若此牌没有造成伤害，你可以获得牌堆中所有与此牌花色点数相同的牌。"..
  "若你没有因此获得牌，此技能视为此阶段未发动过。",

  ["#ty_heg__qiao-invoke"] = "气傲：你可以弃置 %dest 一张牌，然后你弃置一张牌",
  ["#ty_heg__chengshang-invoke"] = "承赏：你可以获得牌堆中所有的 %arg 牌",

  ["$ty_heg__qiao1"] = "吾六十何为不受兵邪？",
  ["$ty_heg__qiao2"] = "芝性骄傲，吾独不为屈。",
  ["$ty_heg__chengshang1"] = "嘉其抗直，甚爱待之。",
  ["$ty_heg__chengshang2"] = "为国鞠躬，必受封赏。",
  ["~ty_heg__zongyu"] = "吾年逾七十，唯少一死耳……",
}

local dengzhi = General(extension, "ty_heg__dengzhi", "shu", 3)
local jianliang = fk.CreateTriggerSkill{
  name = "ty_heg__jianliang",
  anim_type = "drawcard",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and player.phase == Player.Draw and
      table.every(player.room.alive_players, function(p) return player:getHandcardNum() <= p:getHandcardNum() end)
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local targets = table.map(table.filter(room.alive_players, function(p) return H.compareKingdomWith(p, player) end), Util.IdMapper)
    room:sortPlayersByAction(targets)
    for _, pid in ipairs(targets) do
      local p = room:getPlayerById(pid)
      if not p.dead then
        p:drawCards(1, self.name)
      end
    end
  end,
}

local weimeng = fk.CreateActiveSkill{
  name = "ty_heg__weimeng",
  anim_type = "control",
  card_num = 0,
  target_num = 1,
  prompt = function (self, selected, selected_cards)
    return "#ty_heg__weimeng:::"..Self.hp
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = function(self, to_select, selected)
    return false
  end,
  target_filter = function(self, to_select, selected)
    return #selected == 0 and to_select ~= Self.id and not Fk:currentRoom():getPlayerById(to_select):isKongcheng()
  end,
  on_use = function (self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    local cards = room:askForCardsChosen(player, target, 1, player.hp, "h", self.name)
    local dummy1 = Fk:cloneCard("dilu")
    dummy1:addSubcards(cards)
    room:obtainCard(player, dummy1, false, fk.ReasonPrey)
    if player.dead or player:isNude() or target.dead then return end
    local cards2
    if #player:getCardIds("he") <= #cards then
      cards2 = player:getCardIds("he")
    else
      cards2 = room:askForCard(player, #cards, #cards, true, self.name, false, ".",
        "#ty_heg__weimeng-give::"..target.id..":"..#cards)
      if #cards2 < #cards then
        cards2 = table.random(player:getCardIds("he"), #cards)
      end
    end
    local dummy2 = Fk:cloneCard("dilu")
    dummy2:addSubcards(cards2)
    room:obtainCard(target, dummy2, false, fk.ReasonGive)
    local choices = {"ty_heg__weimeng_mn_ask::" .. target.id, "Cancel"}
    if room:askForChoice(player, choices, self.name) ~= "Cancel" then
      room:setPlayerMark(target, "@@ty_heg__weimeng_manoeuvre", 1)
      room:handleAddLoseSkills(target, "ty_heg__weimeng_manoeuvre", nil)
    end
  end,
}

local weimeng_mn = fk.CreateActiveSkill{
  name = "ty_heg__weimeng_manoeuvre",
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
    return #selected == 0 and to_select ~= Self.id and not Fk:currentRoom():getPlayerById(to_select):isKongcheng()
  end,
  on_use = function (self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    local card1 = room:askForCardChosen(player, target, "h", self.name)
    room:obtainCard(player, card1, false, fk.ReasonPrey)
    if player.dead or player:isNude() or target.dead then return end
    local cards2 = room:askForCard(player, 1, 1, true, self.name, false, ".", "#ty_heg__weimeng-give::"..target.id..":"..tostring(1))
    room:obtainCard(target, cards2[1], false, fk.ReasonGive)
  end,
}

local weimeng_mn_detach = fk.CreateTriggerSkill{
  name = "#ty_heg__weimeng_manoeuvre_detach",
  refresh_events = {fk.AfterTurnEnd},
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill("ty_heg__weimeng_manoeuvre", true, true) 
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    room:handleAddLoseSkills(player, "-ty_heg__weimeng_manoeuvre", nil)
    room:setPlayerMark(player, "@@ty_heg__weimeng_manoeuvre", 0)
  end,
}

weimeng_mn:addRelatedSkill(weimeng_mn_detach)
Fk:addSkill(weimeng_mn)
dengzhi:addSkill(jianliang)
dengzhi:addSkill(weimeng)
Fk:loadTranslationTable{
  ["ty_heg__dengzhi"] = "邓芝",
  ["ty_heg__jianliang"] = "简亮",
  [":ty_heg__jianliang"] = "摸牌阶段开始时，若你的手牌数为全场最少，你可令与你势力相同的所有角色各摸一张牌。",
  ["ty_heg__weimeng"] = "危盟",
  [":ty_heg__weimeng"] = "出牌阶段限一次，你可选择一名其他角色，获得其至多X张手牌，然后交给其等量的牌（X为你的体力值）。"..
  "<br><font color=\"blue\">◆纵横：〖危盟〗描述中的X改为1。<font><br><font color=\"grey\">\"<b>纵横</b>\"："..
  "当拥有“纵横”效果技能发动结算完成后，可以令技能目标角色获得对应修订描述后的技能，直到其下回合结束。",
  ["#ty_heg__weimeng-give"] = "危盟：交还 %dest %arg 张牌。",
  ["ty_heg__weimeng_mn_ask"] = "令%dest获得〖危盟（纵横）〗直到其下回合结束。",
  ["@@ty_heg__weimeng_manoeuvre"] = "危盟 纵横",
  ["ty_heg__weimeng_manoeuvre"] = "危盟⇋",
  ["#ty_heg__weimeng"] = "危盟：获得一名其他角色至多%arg张牌，交还等量牌。",
  [":ty_heg__weimeng_manoeuvre"] = "出牌阶段限一次，你可以获得目标角色一张手牌，然后交给其等量的牌。",

  ["$ty_heg__jianliang1"] = "岂曰少衣食，与君共袍泽！",
  ["$ty_heg__jianliang2"] = "义士同心力，粮秣应期来！",
  ["$ty_heg__weimeng1"] = "此礼献于友邦，共赴兴汉大业！",
  ["$ty_heg__weimeng2"] = "吴有三江之守，何故委身侍魏？",
  ["~ty_heg__dengzhi"] = "伯约啊，我帮不了你了……",
}

local luyusheng = General(extension, "ty_heg__luyusheng", "wu", 3, 3, General.Female)
local zhente = fk.CreateTriggerSkill{
  name = "ty_heg__zhente",
  anim_type = "defensive",
  events = {fk.TargetConfirmed},
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self.name) and player:usedSkillTimes(self.name) == 0 and data.from ~= player.id then
      return (data.card:isCommonTrick() or data.card.type == Card.TypeBasic) and data.card.color == Card.Black
    end
  end,
  on_cost = function(self, event, target, player, data)
    if player.room:askForSkillInvoke(player, self.name, nil,
    "#ty_heg__zhente-invoke:".. data.from .. "::" .. data.card:toLogString() .. ":" .. data.card:getColorString()) then
      player.room:doIndicate(player.id, {data.from})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(data.from)
    local color = data.card:getColorString()
    local choice = room:askForChoice(to, {
      "ty_heg__zhente_negate::" .. tostring(player.id) .. ":" .. data.card.name,
      "ty_heg__zhente_colorlimit:::" .. color
    }, self.name)
    if choice:startsWith("ty_heg__zhente_negate") then
      table.insertIfNeed(data.nullifiedTargets, player.id)
    else
      local colorsRecorded = type(to:getMark("@ty_heg__zhente-turn")) == "table" and to:getMark("@ty_heg__zhente-turn") or {}
      table.insertIfNeed(colorsRecorded, color)
      room:setPlayerMark(to, "@ty_heg__zhente-turn", colorsRecorded)
    end
  end,
}
local zhente_prohibit = fk.CreateProhibitSkill{
  name = "#ty_heg__zhente_prohibit",
  prohibit_use = function(self, player, card)
    local mark = player:getMark("@ty_heg__zhente-turn")
    return type(mark) == "table" and table.contains(mark, card:getColorString())
  end,
}

local zhiwei = fk.CreateTriggerSkill{
  name = "ty_heg__zhiwei",
  events = {fk.GeneralRevealed, fk.AfterCardsMove, fk.Damage, fk.Damaged},
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self.name) then
      if event == fk.GeneralRevealed and data == "ty_heg__luyusheng" then
        return true
      elseif event == fk.AfterCardsMove then
        if player.phase ~= Player.Discard then return false end
        local zhiwei_id = player:getMark(self.name)
        if zhiwei_id == 0 then return false end
        local room = player.room
        local to = room:getPlayerById(zhiwei_id)
        if to == nil or to.dead then return false end
        for _, move in ipairs(data) do
          if move.from == player.id and move.moveReason == fk.ReasonDiscard then
            for _, info in ipairs(move.moveInfo) do
              if (info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip) and
              room:getCardArea(info.cardId) == Card.DiscardPile then
                return true
              end
            end
          end
        end
      elseif event == fk.Damage then
        return target ~= nil and not target.dead and player:getMark(self.name) == target.id
      elseif event == fk.Damaged then
        return target ~= nil and not target.dead and player:getMark(self.name) == target.id and not player:isKongcheng()
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    return true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.GeneralRevealed then
      room:notifySkillInvoked(player, self.name, "special")
      player:broadcastSkillInvoke(self.name)
      local targets = table.map(room:getOtherPlayers(player, false), function(p) return p.id end)
      if #targets == 0 then return false end
      local to = room:askForChoosePlayers(player, targets, 1, 1, "#ty_heg__zhiwei-choose", self.name, false, true)
      if #to > 0 then
        room:setPlayerMark(player, self.name, to[1])
      end
    elseif event == fk.AfterCardsMove then
      local zhiwei_id = player:getMark(self.name)
      if zhiwei_id == 0 then return false end
      local to = room:getPlayerById(zhiwei_id)
      if to == nil or to.dead then return false end
      local cards = {}
      for _, move in ipairs(data) do
        if move.from == player.id and move.moveReason == fk.ReasonDiscard then
          for _, info in ipairs(move.moveInfo) do
            if (info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip) and
            room:getCardArea(info.cardId) == Card.DiscardPile then
              table.insertIfNeed(cards, info.cardId)
            end
          end
        end
      end
      if #cards > 0 then
        room:notifySkillInvoked(player, self.name, "support")
        player:broadcastSkillInvoke(self.name)
        room:setPlayerMark(player, "@zhiwei", to.general)
        room:moveCards({
        ids = cards,
        to = zhiwei_id,
        toArea = Card.PlayerHand,
        moveReason = fk.ReasonPrey,
        proposer = player.id,
        skillName = self.name,
      })
      end
    elseif event == fk.Damage then
      room:notifySkillInvoked(player, self.name, "drawcard")
      player:broadcastSkillInvoke(self.name)
      room:setPlayerMark(player, "@zhiwei", target.general)
      room:drawCards(player, 1, self.name)
    elseif event == fk.Damaged then
      local cards = player:getCardIds(Player.Hand)
      if #cards > 0 then
        room:notifySkillInvoked(player, self.name, "negative")
        player:broadcastSkillInvoke(self.name)
        room:setPlayerMark(player, "@zhiwei", target.general)
        room:throwCard(table.random(cards, 1), self.name, player, player)
      end
    end
  end,

  refresh_events = {fk.BuryVictim},
  can_refresh = function(self, event, target, player, data)
    return player:getMark(self.name) == target.id
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, self.name, 0)
    room:setPlayerMark(player, "@zhiwei", 0)
    local isDeputy = H.inGeneralSkills(player, self.name)
    if isDeputy then
      isDeputy = isDeputy == "d"
      player:hideGeneral(isDeputy)
    end
  end,
}
zhente:addRelatedSkill(zhente_prohibit)
luyusheng:addSkill(zhente)
luyusheng:addSkill(zhiwei)

Fk:loadTranslationTable{
  ["ty_heg__luyusheng"] = "陆郁生",
  ["ty_heg__zhente"] = "贞特",
  [":ty_heg__zhente"] = "每回合限一次，当你成为其他角色使用黑色基本牌或黑色普通锦囊牌的目标后，你可令使用者选择一项：1.本回合不能使用黑色牌；"..
  "2.此牌对你无效",
  ["ty_heg__zhiwei"] = "至微",
  [":ty_heg__zhiwei"] = "当你明置此武将牌时，你可以选择一名其他角色：该角色造成伤害后，你摸一张牌；该角色受到伤害后，你随机弃置一张手牌；"..
  "你弃牌阶段弃置的牌均被该角色获得；该角色死亡时，你暗置此武将牌。",

  ["#ty_heg__zhente-invoke"] = "是否使用贞特，令%src选择令【%arg】对你无效或不能再使用%arg2牌",
  ["ty_heg__zhente_negate"] = "令【%arg】对%dest无效",
  ["ty_heg__zhente_colorlimit"] = "本回合不能再使用%arg牌",
  ["@ty_heg__zhente-turn"] = "贞特",
  ["#ty_heg__zhiwei-choose"] = "至微：选择一名其他角色",
  ["@ty_heg__zhiwei"] = "至微",

  ["$ty_heg__zhente1"] = "抗声昭节，义形于色。",
  ["$ty_heg__zhente2"] = "少履贞特之行，三从四德。",
  ["$ty_heg__zhiwei1"] = "体信贯于神明，送终以礼。",
  ["$ty_heg__zhiwei2"] = "昭德以行，生不能侍奉二主。",
  ["~ty_heg__luyusheng"] = "父亲，郁生甚是想念……",
}

local fengxiw = General(extension, "ty_heg__fengxiw", "wu", 3)
local yusui = fk.CreateTriggerSkill{
  name = "ty_heg__yusui",
  anim_type = "offensive",
  events = {fk.TargetConfirmed},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and data.from ~= player.id and data.card.color == Card.Black and
      player:usedSkillTimes(self.name, Player.HistoryTurn) == 0 and H.compareKingdomWith(player.room:getPlayerById(data.from), player, true) and
      player.hp > 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(data.from)
    room:loseHp(player, 1, self.name)
    if player.dead then return end
    local choices = {}
    if not to:isKongcheng() then
      table.insert(choices, "ty_heg__yusui_discard::" .. to.id .. ":" .. to.maxHp)
    end
    if to.hp > player.hp then
      table.insert(choices, "ty_heg__yusui_loseHp::" .. to.id .. ":" .. player.hp)
    end
    if #choices == 0 then return false end
    local choice = room:askForChoice(player, choices, self.name)
    if choice:startsWith("ty_heg__yusui_discard") then
      room:askForDiscard(to, to.maxHp, to.maxHp, false, self.name, false)
    else
      room:loseHp(to, to.hp - player.hp, self.name)
    end
  end,
}
local boyan = fk.CreateActiveSkill{
  name = "ty_heg__boyan",
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
    room:setPlayerMark(target, "@@ty_heg__boyan-turn", 1)
    local choices = {"ty_heg__boyan_mn_ask::" .. target.id, "Cancel"}
    if room:askForChoice(player, choices, self.name) ~= "Cancel" then
      room:setPlayerMark(target, "@@ty_heg__boyan_manoeuvre", 1)
      room:handleAddLoseSkills(target, "ty_heg__boyan_manoeuvre", nil)
    end
  end,
}
local boyan_prohibit = fk.CreateProhibitSkill{
  name = "#ty_heg__boyan_prohibit",
  prohibit_use = function(self, player, card)
    return player:getMark("@@ty_heg__boyan-turn") > 0
  end,
  prohibit_response = function(self, player, card)
    return player:getMark("@@ty_heg__boyan-turn") > 0
  end,
}
boyan:addRelatedSkill(boyan_prohibit)
local boyan_mn = fk.CreateActiveSkill{
  name = "ty_heg__boyan_manoeuvre",
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
    room:setPlayerMark(target, "@@ty_heg__boyan-turn", 1)
  end,
}
local boyan_mn_detach = fk.CreateTriggerSkill{
  name = "#ty_heg__boyan_manoeuvre_detach",
  refresh_events = {fk.AfterTurnEnd},
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill("ty_heg__boyan_manoeuvre", true, true) 
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    room:handleAddLoseSkills(player, "-ty_heg__boyan_manoeuvre", nil)
    room:setPlayerMark(player, "@@ty_heg__boyan_manoeuvre", 0)
  end,
}
boyan_mn:addRelatedSkill(boyan_mn_detach)
Fk:addSkill(boyan_mn)
fengxiw:addSkill(yusui)
fengxiw:addSkill(boyan)
Fk:loadTranslationTable{
  ["ty_heg__fengxiw"] = "冯熙",
  ["ty_heg__yusui"] = "玉碎",
  [":ty_heg__yusui"] = "每回合限一次，当你成为其他角色使用黑色牌的目标后，若你与其势力不同，你可失去1点体力，然后选择一项：1.令其弃置X张手牌"..
  "（X为其体力上限）；2.令其失去体力值至与你相同。",
  ["ty_heg__boyan"] = "驳言",
  [":ty_heg__boyan"] = "出牌阶段限一次，你可选择一名其他角色，其将手牌摸至其体力上限，其本回合不能使用或打出手牌。"..
  "<br><font color=\"blue\">◆纵横：删去〖驳言〗描述中的“其将手牌摸至体力上限”。<font><br><font color=\"grey\">\"<b>纵横</b>\"："..
  "当拥有“纵横”效果技能发动结算完成后，可以令技能目标角色获得对应修订描述后的技能，直到其下回合结束。",

  ["ty_heg__yusui_discard"] = "令%dest弃置%arg张手牌",
  ["ty_heg__yusui_loseHp"] = "令%dest失去体力至%arg",
  ["ty_heg__boyan_mn_ask"] = "令%dest获得〖驳言（纵横）〗直到其下回合结束",
  ["@@ty_heg__boyan-turn"] = "驳言",
  ["@@ty_heg__boyan_manoeuvre"] = "驳言 纵横",

  ["ty_heg__boyan_manoeuvre"] = "驳言⇋",
  [":ty_heg__boyan_manoeuvre"] = "出牌阶段限一次，你可选择一名其他角色，其本回合不能使用或打出手牌。",

  ["$ty_heg__boyan1"] = "黑白颠倒，汝言谬矣！",
  ["$ty_heg__boyan2"] = "魏王高论，实为无知之言。",
  ["$ty_heg__yusui1"] = "宁为玉碎，不为瓦全！",
  ["$ty_heg__yusui2"] = "生义相左，舍生取义。",
  ["~ty_heg__fengxiw"] = "乡音未改双鬓苍，身陷北国有义求。",
}

local miheng = General(extension, "ty_heg__miheng", "qun", 3)
miheng:addCompanions("hs__kongrong")
local kuangcai = fk.CreateTriggerSkill{
  name = "ty_heg__kuangcai",
  mute = true,
  frequency = Skill.Compulsory,
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self.name) and player.phase == Player.Discard then
      local n = 0
      for _, v in pairs(player.cardUsedHistory) do
        if v[Player.HistoryTurn] > 0 then
          n = 1
          break
        end
      end
      if n == 0 then
        return true
      else
        return #player.room.logic:getEventsOfScope(GameEvent.ChangeHp, 1, function (e)
          local damage = e.data[5]
          if damage and target == damage.from then
            return true
          end
        end, Player.HistoryTurn) == 0 and player:getMaxCards() > 0
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke(self.name)
    local n = 0
    for _, v in pairs(player.cardUsedHistory) do
      if v[Player.HistoryTurn] > 0 then
        n = 1
        break
      end
    end
    if n == 0 then
      room:notifySkillInvoked(player, self.name, "support")
      room:addPlayerMark(player, MarkEnum.AddMaxCards, 1)
    else
      room:notifySkillInvoked(player, self.name, "negative")
      room:addPlayerMark(player, MarkEnum.MinusMaxCards, 1)
    end
  end,
}
local kuangcai_targetmod = fk.CreateTargetModSkill{
  name = "#ty_heg__kuangcai_targetmod",
  bypass_times = function(self, player, skill, scope, card, to)
    return player:hasSkill("ty_heg__kuangcai") and scope == Player.HistoryPhase and player.phase ~= Player.NotActive
  end,
  bypass_distances = function(self, player, skill, card, to)
    return player:hasSkill("ty_heg__kuangcai") and player.phase ~= Player.NotActive
  end,
}
kuangcai:addRelatedSkill(kuangcai_targetmod)
local ty_heg__shejian = fk.CreateTriggerSkill{
  name = "ty_heg__shejian",
  anim_type = "control",
  events = {fk.TargetConfirmed},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and data.from ~= player.id and #AimGroup:getAllTargets(data.tos) == 1 and
      not player:isKongcheng()
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, nil, "#ty_heg__shejian-invoke::"..data.from..":"..data.card:toLogString())
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local from = room:getPlayerById(data.from)
    local n = player:getHandcardNum()
    player:throwAllCards("h")
    if not (player.dead or from.dead) then
      room:doIndicate(player.id, {data.from})
      local choices = {"shejian_damage::" .. data.from}
      n = math.min(n, #from:getCardIds("he"))
      if not from:isNude() then
        table.insert(choices, 1, "shejian_discard::" .. data.from .. ":" .. n)
      end
      local choice = room:askForChoice(player, choices, self.name, "#ty_heg__shejian-choice::"..data.from..":"..n)
      if choice:startsWith("shejian_discard") then
        local cards = room:askForCardsChosen(player, from, n, n, "he", self.name)
        room:throwCard(cards, self.name, from, player)
      else
        room:damage{
          from = player,
          to = from,
          damage = 1,
          skillName = self.name
        }
      end
    end
  end,
}
miheng:addSkill(kuangcai)
miheng:addSkill(ty_heg__shejian)
Fk:loadTranslationTable{
  ["ty_heg__miheng"] = "祢衡",
  ["ty_heg__kuangcai"] = "狂才",
  [":ty_heg__kuangcai"] = "锁定技，你的回合内，你使用牌无距离和次数限制。弃牌阶段开始时，若你本回合：没有使用过牌，你的手牌上限+1；使用过牌且没有造成伤害，你手牌上限-1。",
  ["ty_heg__shejian"] = "舌剑",
  [":ty_heg__shejian"] = "当你成为其他角色使用牌的唯一目标后，你可以弃置所有手牌。若如此做，你选择一项：1.弃置其等量的牌；2.对其造成1点伤害。",
  ["#ty_heg__shejian-invoke"] = "舌剑：%dest 对你使用 %arg，你可以弃置所有手牌，弃置其等量的牌或对其造成1点伤害",
  ["#ty_heg__shejian-choice"] = "舌剑：弃置 %dest %arg张牌或对其造成1点伤害",
  ["shejian_discard"] = "弃置%dest%arg张牌",
  ["shejian_damage"] = "对%dest造成1点伤害",

  ["$ty_heg__kuangcai1"] = "耳所瞥闻，不忘于心。",
  ["$ty_heg__kuangcai2"] = "吾焉能从屠沽儿耶？",
  ["$ty_heg__shejian1"] = "伤人的，可不止刀剑！	",
  ["$ty_heg__shejian2"] = "死公！云等道？",
  ["~ty_heg__miheng"] = "恶口……终至杀身……",
}

local xunchen = General(extension, "ty_heg__xunchen", "qun", 3)
local anyong = fk.CreateTriggerSkill{
  name = "ty_heg__anyong",
  events = {fk.DamageCaused},
  anim_type = "offensive",
  can_trigger = function (self, event, target, player, data)
    return target and H.compareKingdomWith(target, player) and player:hasSkill(self.name)
      and data.to ~= player and data.to ~= target
      and player:usedSkillTimes(self.name, Player.HistoryTurn) == 0
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, nil, "#ty_heg__anyong-invoke:"..data.from.id .. ":" .. data.to.id .. ":" .. data.damage)
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local to = data.to
    local num = H.getGeneralsRevealedNum(to)
    if num == 1 then
      room:askForDiscard(player, 2, 2, false, self.name, false)
    elseif num == 2 then
      room:loseHp(player, 1, self.name)
      room:handleAddLoseSkills(player, "-ty_heg__anyong", nil)
    end
    data.damage = data.damage * 2
  end,
}

local fenglve = fk.CreateActiveSkill{
  name = "ty_heg__fenglve",
  anim_type = "control",
  prompt = "#ty_heg__fenglve-active",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0 and not player:isKongcheng()
  end,
  card_filter = function(self, to_select, selected)
    return false
  end,
  target_filter = function(self, to_select, selected)
    return #selected == 0 and to_select ~= Self.id and not Fk:currentRoom():getPlayerById(to_select):isKongcheng()
  end,
  on_use = function (self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    local pindian = player:pindian({target}, self.name)
    if pindian.results[target.id].winner == player then
      if not (player.dead or target.dead or target:isNude()) then
        local cards = target:getCardIds("hej")
        if #cards > 2 then
          cards = room:askForCardsChosen(target, target, 2, 2, "hej", self.name)
        end
        room:moveCardTo(cards, Player.Hand, player, fk.ReasonGive, self.name, nil, false, player.id)
      end
    elseif pindian.results[target.id].winner == target then
      if not (player.dead or target.dead or player:isNude()) then
        local cards2 = room:askForCard(player, 1, 1, true, self.name, false, ".", "#ty_heg__fenglve-give::" .. target.id)
        room:obtainCard(target, cards2[1], false, fk.ReasonGive)
      end
    end
    if player.dead or target.dead then return false end
    local choices = {"ty_heg__fenglve_mn_ask::" .. target.id, "Cancel"}
    if room:askForChoice(player, choices, self.name) ~= "Cancel" then
      room:setPlayerMark(target, "@@ty_heg__fenglve_manoeuvre", 1)
      room:handleAddLoseSkills(target, "ty_heg__fenglve_manoeuvre", nil)
    end
  end,
}

local fenglve_mn = fk.CreateActiveSkill{
  name = "ty_heg__fenglve_manoeuvre",
  anim_type = "control",
  prompt = "#ty_heg__fenglve-active",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0 and not player:isKongcheng()
  end,
  card_filter = function(self, to_select, selected)
    return false
  end,
  target_filter = function(self, to_select, selected)
    return #selected == 0 and to_select ~= Self.id and not Fk:currentRoom():getPlayerById(to_select):isKongcheng()
  end,
  on_use = function (self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    local pindian = player:pindian({target}, self.name)
    if pindian.results[target.id].winner == player then
      if not (player.dead or target.dead or target:isNude()) then
        local cards1 = room:askForCardChosen(target, target, "hej", self.name)
        room:obtainCard(player, cards1, false, fk.ReasonGive)
      end
    elseif pindian.results[target.id].winner == target then
      if not (player.dead or target.dead or player:isNude()) then
        local cards = player:getCardIds("he")
        if #cards > 2 then
          cards = room:askForCard(player, 2, 2, true, self.name, false, ".", "#ty_heg__fenglve-give::" .. target.id .. ":" .. tostring(2))
        end
        room:moveCardTo(cards, Player.Hand, target, fk.ReasonGive, self.name, nil, false, player.id)
      end
    end
  end,
}

local fenglve_mn_detach = fk.CreateTriggerSkill{
  name = "#ty_heg__fenglve_manoeuvre_detach",
  refresh_events = {fk.AfterTurnEnd},
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill("ty_heg__fenglve_manoeuvre", true, true)
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    room:handleAddLoseSkills(player, "-ty_heg__fenglve_manoeuvre", nil)
    room:setPlayerMark(player, "@@ty_heg__fenglve_manoeuvre", 0)
  end,
}

fenglve_mn:addRelatedSkill(fenglve_mn_detach)
Fk:addSkill(fenglve_mn)
xunchen:addSkill(anyong)
xunchen:addSkill(fenglve)

Fk:loadTranslationTable{
  ["ty_heg__xunchen"] = "荀谌",
  ["ty_heg__fenglve"] = "锋略",
  [":ty_heg__fenglve"] = "出牌阶段限一次，你可以和一名其他角色拼点，若你赢，该角色交给你其区域内的两张牌；若其赢，你交给其一张牌。"..
  "<br><font color=\"blue\">◆纵横：交换〖锋略〗描述中的“一张牌”和“两张牌”。<font><br><font color=\"grey\">\"<b>纵横</b>\"："..
  "当拥有“纵横”效果技能发动结算完成后，可以令技能目标角色获得对应修订描述后的技能，直到其下回合结束。",

  ["#ty_heg__fenglve-active"] = "发动“锋略”，与一名角色拼点",
  ["#ty_heg__fenglve-give"] = "锋略：选择 %arg 张牌交给 %dest",
  ["ty_heg__fenglve_mn_ask"] = "令%dest获得〖锋略（纵横）〗直到其下回合结束",
  ["@@ty_heg__fenglve_manoeuvre"] = "锋略 纵横",

  ["ty_heg__fenglve_manoeuvre"] = "锋略⇋",
  [":ty_heg__fenglve_manoeuvre"] = "出牌阶段限一次，你可以和一名其他角色拼点，若你赢，该角色交给你其区域内的一张牌；若其赢，你交给其两张牌。",

  ["ty_heg__anyong"] = "暗涌",
  ["#ty_heg__anyong-invoke"] = "暗涌：是否令 %src 对 %dest 造成的 %arg 点伤害翻倍！",
  [":ty_heg__anyong"] = "每回合限一次，当与你势力相同的一名角色对另一名其他角色造成伤害时，你可令此伤害翻倍，然后若受到伤害的角色："..
  "武将牌均明置，你失去1点体力并失去此技能；只明置了一张武将牌，你弃置两张手牌。",

  ["$ty_heg__fenglve1"] = "冀州宝地，本当贤者居之。",
  ["$ty_heg__fenglve2"] = "当今敢称贤者，唯袁氏本初一人。",
  ["$ty_heg__anyong1"] = "冀州暗潮汹涌，群仕居危思变。",
  ["$ty_heg__anyong2"] = "殿上太守且相看，殿下几人还拥韩。",
  ["~ty_heg__xunchen"] = "为臣当不贰，贰臣不当为。",
}

local jianggan = General(extension, "ty_heg__jianggan", "wei", 3)
jianggan:addSkill("weicheng")
jianggan:addSkill("daoshu")
Fk:loadTranslationTable{
  ["ty_heg__jianggan"] = "蒋干",
  ["~ty_heg__jianggan"] = "丞相，再给我一次机会啊！",
}

return extension
