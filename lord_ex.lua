local H = require "packages/hegemony/util"
local U = require "packages/utility/utility"
local extension = Package:new("lord_ex")
extension.extensionName = "hegemony"
extension.game_modes_whitelist = { 'nos_heg_mode', 'new_heg_mode' }

Fk:loadTranslationTable{
  ["lord_ex"] = "君临天下·EX/不臣篇",
}

local dongzhao = General(extension, "ld__dongzhao", "wei", 3)

local quanjin = fk.CreateActiveSkill{
  name = "quanjin",
  prompt = "#quanjin-active",
  anim_type = "control",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_num = 1,
  card_filter = function(self, to_select, selected)
    return #selected < 1 and Fk:currentRoom():getCardArea(to_select) == Player.Hand
  end,
  target_num = 1,
  target_filter = function(self, to_select, selected, selected_cards)
    return #selected == 0 and to_select ~= Self.id and Fk:currentRoom():getPlayerById(to_select):getMark("_quanjin-phase") > 0 and #selected_cards == 1
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    room:moveCardTo(effect.cards, Card.PlayerHand, target, fk.ReasonGive, self.name, nil, false, player.id)
    if H.askCommandTo(player, target, self.name) then
      player:drawCards(1, self.name)
    else
      local num = player:getHandcardNum()
      for hc, p in ipairs(room.alive_players) do
        hc = p:getHandcardNum()
        if hc > num then
          num = hc
        end
      end
      num = math.min(num - player:getHandcardNum(), 5)
      player:drawCards(num, self.name)
    end
  end,
}
local quanjinRecorder = fk.CreateTriggerSkill{
  name = "#quanjin_recorder",
  visible = false,
  refresh_events = {fk.Damaged, fk.EventAcquireSkill},
  can_refresh = function(self, event, target, player, data)
    if not player:hasSkill(self.name) or player.room.current ~= player or player.phase ~= Player.Play then return false end
    return event == fk.Damaged or (target == player and data == quanjin)
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    if event == fk.Damaged then
      room:setPlayerMark(target, "_quanjin-phase", 1)
    else
      room.logic:getEventsOfScope(GameEvent.ChangeHp, 1, function (e)
        local damage = e.data[5]
        if damage then
          local target = data.to
          if target:getMark("_quanjin-phase") == 0 then
            room:setPlayerMark(target, "_quanjin-phase", 1)
          end
        end
      end, Player.HistoryPhase)
    end
  end,
}
quanjin:addRelatedSkill(quanjinRecorder)

local zaoyun = fk.CreateActiveSkill{
  name = "zaoyun",
  anim_type = "offensive",
  prompt = "#zaoyun",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  min_card_num = 1,
  card_filter = function(self, to_select, selected)
    return Fk:currentRoom():getCardArea(to_select) == Player.Hand
  end,
  target_num = 1,
  target_filter = function(self, to_select, selected, selected_cards)
    local target = Fk:currentRoom():getPlayerById(to_select)
    return #selected == 0 and not H.compareKingdomWith(target, Self) and target.kingdom ~= "unknown" -- ?
      and Self:distanceTo(target) - 1 == #selected_cards and #selected_cards > 0
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    room:throwCard(effect.cards, self.name, player, player)
    room:setPlayerMark(player, "_zaoyun_distance-turn", target.id)
    room:damage{ from = player, to = target, damage = 1, skillName = self.name }
  end,
}
local zaoyun_distance = fk.CreateDistanceSkill{
  name = "#zaoyun_distance",
  fixed_func = function(self, from, to)
    if from:getMark("_zaoyun_distance-turn") == to.id then
      return 1
    end
  end,
}
zaoyun:addRelatedSkill(zaoyun_distance)

dongzhao:addSkill(quanjin)
dongzhao:addSkill(zaoyun)

Fk:loadTranslationTable{
  ["ld__dongzhao"] = "董昭",
  ["quanjin"] = "劝进",
  [":quanjin"] = "出牌阶段限一次，你可将一张手牌交给一名此阶段受到过伤害的角色，对其发起军令。若其执行，你摸一张牌；若其不执行，你将手牌摸至与手牌最多的角色相同（最多摸五张）。",
  ["zaoyun"] = "凿运",
  [":zaoyun"] = "出牌阶段限一次，你可选择一名与你势力不同且你至其距离大于1的角色并弃置X张手牌（X为你至其的距离-1），令你至其的距离此回合视为1，然后你对其造成1点伤害。",

  ["#quanjin-active"] = "发动 劝进，选择一张手牌交给一名此阶段内受到过伤害的角色并对其发起军令",
  ["#zaoyun-discard"] = "凿运：弃置 %arg 张手牌（你至%src的距离-1）",
  ["#zaoyun"] = "凿运：选择任意张手牌弃置，再选择一名与你势力不同且你至其距离为弃置手牌数+1的角色",

  ["$quanjin1"] = "今称魏公，则可以藩卫之名，征吴伐蜀也。",
  ["$quanjin2"] = "明公受封，正合天心人意！",
  ["$zaoyun1"] = "开渠输粮，振军之心，破敌之胆！",
  ["$zaoyun2"] = "兵精粮足，胜局已定！",
  ["~ld__dongzhao"] = "一生无愧，又何惧身后之议……",
}


local xushu = General(extension, "ld__xushu", "shu", 4)
xushu.deputyMaxHpAdjustedValue = -1
local qiance = fk.CreateTriggerSkill{
  name = "ld__qiance",
  anim_type = "control",
  events = {fk.TargetSpecified},
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and data.card:isCommonTrick() and data.firstTarget
  end,
  on_cost = function (self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, nil, "#ld__qiance-ask") 
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room.alive_players, function(p) return H.isBigKingdomPlayer(p) end)
    if #targets > 0 then
      data.disresponsiveList = data.disresponsiveList or {}
      for _, p in ipairs(targets) do
        table.insertIfNeed(data.disresponsiveList, p.id)
      end
    end
  end,
}

local jujian = fk.CreateTriggerSkill{
  name = "ld__jujian",
  anim_type = "defensive",
  relate_to_place = "d",
  events = {fk.DamageInflicted},
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(self.name) and H.compareKingdomWith(player, data.to) and data.damage >= data.to.hp
  end,
  on_cost = function (self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, nil, "#ld__jujian-ask") 
  end,
  on_use = function (self, event, target, player, data)
    data.damage = 0
    H.transformGeneral(player.room, player)
  end,
}

xushu:addSkill(qiance)
xushu:addSkill(jujian)

Fk:loadTranslationTable{
  ["ld__xushu"] = "徐庶",
  ["ld__qiance"] = "谦策",
  [":ld__qiance"] = "当你使用锦囊牌指定目标后，你可令所有大势力角色不能响应此牌。",
  ["ld__jujian"] = "举荐",
  [":ld__jujian"] = "副将技，此武将减少半个阴阳鱼。与你势力相同的角色受到伤害时，若伤害值不小于其体力值，你可以防止之，然后你变更此武将牌。",

  ["#ld__qiance-ask"] = "谦策：是否令所有大势力角色不能响应此牌",
  ["#ld__jujian-ask"] = "举荐：是否防止此伤害，然后你变更此武将牌",

  ["$ld__qiance1"] = "开言纳谏，社稷之福。",
  ["$ld__qiance2"] = "如此如此，敌军自破。",
  ["$ld__jujian1"] = "千金易得，贤才难求。",
  ["$ld__jujian2"] = "愿与将军共图王之霸业。",
  ["~ld__xushu"] = "大义无言，虽死无怨。",
}
--[[
local mengda = General(extension, "ld__mengda", "wei", 4)
mengda.subkingdom = "shu"
Fk:loadTranslationTable{
  ["ld__mengda"] = "孟达",
}

local zhanglu = General(extension, "ld__zhanglu", "qun", 3)
zhanglu.subkingdom = "wei"
Fk:loadTranslationTable{
  ["ld__zhanglu"] = "张鲁",
}

local mf = General(extension, "ld__mifangfushiren", "shu", 4)
mf.subkingdom = "wu"
Fk:loadTranslationTable{
  ["ld__mifangfushiren"] = "糜芳傅士仁",
}

local shixie = General(extension, "ld__shixie", "qun", 3)
shixie.subkingdom = "wu"
Fk:loadTranslationTable{
  ["ld__shixie"] = "士燮",
}

local liuqi = General(extension, "ld__liuqi", "qun", 4)
liuqi.subkingdom = "shu"
Fk:loadTranslationTable{
  ["ld__liuqi"] = "刘琦",
}

local tangzi = General(extension, "ld__tangzi", "wei", 4)
tangzi.subkingdom = "wu"
Fk:loadTranslationTable{
  ["ld__tangzi"] = "唐咨",
}

local xiahouba = General(extension, "ld__xiahouba", "shu", 4)
xiahouba.subkingdom = "wei"
Fk:loadTranslationTable{
  ["ld__xiahouba"] = "夏侯霸",
}

local panjun = General(extension, "ld__panjun", "wu", 3)
panjun.subkingdom = "shu"
Fk:loadTranslationTable{
  ["ld__panjun"] = "潘濬",
}

local wenqin = General(extension, "ld__wenqin", "wei", 4)
wenqin.subkingdom = "wu"
Fk:loadTranslationTable{
  ["ld__wenqin"] = "文钦",
}

local sufei = General(extension, "ld__sufei", "wu", 4)
sufei.subkingdom = "qun"
Fk:loadTranslationTable{
  ["ld__sufei"] = "苏飞",
}

local xuyou = General(extension, "ld__xuyou", "qun", 3)
xuyou.subkingdom = "wei"
Fk:loadTranslationTable{
  ["ld__xuyou"] = "许攸",
}

local pengyang = General(extension, "ld__pengyang", "shu", 3)
pengyang.subkingdom = "qun"
Fk:loadTranslationTable{
  ["ld__pengyang"] = "彭羕",
}
--]]

local zhonghui = General(extension, "ld__zhonghui", "wild", 4)
zhonghui:addCompanions("ld__jiangwei")
local quanji = fk.CreateTriggerSkill{
  name = "ld__quanji",
  mute = true,
  events = {fk.Damaged, fk.Damage},
  can_trigger = function(self, event, target, player, data)
    if target ~= player or not player:hasSkill(self.name) or player.dead then return false end
    if event == fk.Damaged then return player:getMark("_ld__quanji_damaged-turn") == 0
    else return player:getMark("_ld__quanji_damage-turn") == 0 end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke(self.name)
    if event == fk.Damaged then
      room:setPlayerMark(player, "_ld__quanji_damaged-turn", 1)
      room:notifySkillInvoked(player, self.name, "masochism")
    else
      room:setPlayerMark(player, "_ld__quanji_damage-turn", 1)
      room:notifySkillInvoked(player, self.name, "drawcard")
    end
    player:drawCards(1, self.name)
    if not player:isNude() then
      local card = room:askForCard(player, 1, 1, true, self.name, false, nil, "#ld__quanji-push")
      player:addToPile("ld__zhonghui_power", card, true, self.name)
    end
  end,
}
local quanji_maxcards = fk.CreateMaxCardsSkill{
  name = "#ld__quanji_maxcards",
  correct_func = function(self, player)
    return player:hasSkill(self.name) and #player:getPile("ld__zhonghui_power") or 0
  end,
}
quanji:addRelatedSkill(quanji_maxcards)
H.CreateClearSkill(quanji, "ld__zhonghui_power")
local paiyi = fk.CreateActiveSkill{
  name = "ld__paiyi",
  anim_type = "control",
  prompt = function(self)
    return "#ld__paiyi-active:::" .. math.min(#Self:getPile("ld__zhonghui_power") - 1, 7)
  end,
  card_num = 1,
  target_num = 1,
  expand_pile = "ld__zhonghui_power",
  can_use = function(self, player)
    return #player:getPile("ld__zhonghui_power") > 0 and player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  target_filter = function(self, to_select, selected)
    return #selected == 0
  end,
  card_filter = function(self, to_select, selected)
    return #selected == 0 and Self:getPileNameOfId(to_select) == "ld__zhonghui_power"
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    room:moveCardTo(effect.cards, Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile, self.name, "ld__zhonghui_power", true, player.id)
    if not target.dead then
      room:drawCards(target, math.min(#player:getPile("ld__zhonghui_power"), 7), self.name)
    end
    if not player.dead and not target.dead and target:getHandcardNum() > player:getHandcardNum() then
      room:damage{
        from = player,
        to = target,
        damage = 1,
        skillName = self.name,
      }
    end
  end,
}

zhonghui:addSkill(quanji)
zhonghui:addSkill(paiyi)

Fk:loadTranslationTable{
  ["ld__zhonghui"] = "钟会",
  ["ld__quanji"] = "权计",
  [":ld__quanji"] = "每回合各限一次，当你受到伤害后或当你造成伤害后，你可摸一张牌，然后将一张牌置于武将牌上（称为“权”）；你的手牌上限+X（X为“权”数）。",
  ["ld__paiyi"] = "排异",
  [":ld__paiyi"] = "出牌阶段限一次，你将一张“权”置入弃牌堆并选择一名角色，其摸X张牌，若其手牌数大于你，你对其造成1点伤害（X为“权”的数量且至多为7）。",

  ["#ld__quanji-push"] = "权计：将一张牌置于武将牌上（称为“权”）",
  ["ld__zhonghui_power"] = "权",
  ["#ld__paiyi-active"] = "发动排异，选择一张“权”牌置入弃牌堆并选择一名角色，令其摸 %arg 张牌",

  ["$ld__quanji1"] = "不露圭角，择时而发！",
  ["$ld__quanji2"] = "晦养厚积，乘势而起！",
  ["$ld__paiyi1"] = "排斥异己，为王者必由之路！",
  ["$ld__paiyi2"] = "非吾友，则必敌也！",
  ["~ld__zhonghui"] = "吾机关算尽，却还是棋错一着……",
}

local simazhao = General(extension, "ld__simazhao", "wild", 3)
local zhaoxin = fk.CreateTriggerSkill{
  name = "ld__zhaoxin",
  anim_type = "control",
  events = {fk.Damaged},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self.name) and player == target and not player:isKongcheng()
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, nil, "#ld__zhaoxin-ask")
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:showCards(player.player_cards[Player.Hand])
    local targets = table.map(table.filter(room:getOtherPlayers(player, false), function(p)
      return (p:getHandcardNum() <= player:getHandcardNum()) end), function(p) return p.id end)
    if #targets > 0 then
      local to = room:getPlayerById(room:askForChoosePlayers(player, targets, 1, 1, "#ld__zhaoxin-choose", self.name, false)[1])
      U.swapHandCards(room, player, player, to, self.name)
    end
  end,
}

local suzhi = fk.CreateTriggerSkill{
  name = "ld__suzhi",
  frequency = Skill.Compulsory,
  mute = true,
  events = {fk.CardUsing, fk.DamageCaused, fk.AfterCardsMove, fk.TurnEnd},
  can_trigger = function(self, event, target, player, data)
    local room = player.room
    if player:hasSkill(self.name) and player:getMark("@ld__suzhi-turn") < 3 and room.current == player then
      if event == fk.CardUsing then
        return target == player and data.card.type == Card.TypeTrick and (not data.card:isVirtual() or #data.card.subcards == 0)
      elseif event == fk.DamageCaused then
        return target == player and data.card and (data.card.trueName == "slash" or data.card.name == "duel") and not data.chain
      elseif event == fk.AfterCardsMove then
        for _, move in ipairs(data) do
          if move.from and move.from ~= player.id and move.moveReason == fk.ReasonDiscard then
            --FIXME:国战暂时没有同时两名角色弃置牌的情况，先鸽
            local from = room:getPlayerById(move.from)
            if from and not (from.dead or from:isNude()) then
              for _, info in ipairs(move.moveInfo) do
                if info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip then
                  self.cost_data = move.from
                  return true
                end
              end
            end
          end
        end
      elseif event == fk.TurnEnd then
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.TurnEnd then
      room:notifySkillInvoked(player, self.name)
      room:setPlayerMark(player, "@@ld__fankui_simazhao", 1)
      room:handleAddLoseSkills(player, "ld__simazhao__fankui", nil)
      return false
    else
      player:broadcastSkillInvoke(self.name)
      room:addPlayerMark(player, "@ld__suzhi-turn", 1)
      if event == fk.CardUsing then
        room:notifySkillInvoked(player, self.name, "drawcard")
        player:drawCards(1, self.name)
      elseif event == fk.DamageCaused then
        room:notifySkillInvoked(player, self.name, "offensive")
        room:doIndicate(player.id, {data.to.id})
        data.damage = data.damage + 1
      elseif event == fk.AfterCardsMove then
        room:notifySkillInvoked(player, self.name, "control")
        room:doIndicate(player.id, {self.cost_data})
        local card = room:askForCardChosen(player, room:getPlayerById(self.cost_data), "he", self.name)
        room:obtainCard(player.id, card, false, fk.ReasonPrey)
      end
    end
  end,

  refresh_events = {fk.TurnStart},
  can_refresh = function(self, event, target, player, data)
    return target == player and player:getMark("@@ld__fankui_simazhao") > 0
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "@@ld__fankui_simazhao", 0)
    room:handleAddLoseSkills(player, "-ld__simazhao__fankui", nil)
  end,
}

local suzhi_target = fk.CreateTargetModSkill{
  name = "#ld__suzhi_target",
  frequency = Skill.Compulsory,
  bypass_distances = function(self, player, skill, card)
    return player:hasSkill(suzhi.name) and player.phase ~= Player.NotActive and player:getMark("@ld__suzhi-turn") < 3 and
    card and card.type == Card.TypeTrick and (not card:isVirtual() or #card.subcards == 0)
  end,
}

local fankui = fk.CreateTriggerSkill{
  name = "ld__simazhao__fankui",
  anim_type = "masochism",
  events = {fk.Damaged},
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self.name) and data.from and not data.from.dead then
      if data.from == player then
        return #player.player_cards[Player.Equip] > 0
      else
        return not data.from:isNude()
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local from = data.from
    room:doIndicate(player.id, {from.id})
    local flag =  from == player and "e" or "he"
    local card = room:askForCardChosen(player, from, flag, self.name)
    room:obtainCard(player.id, card, false, fk.ReasonPrey)
  end
}

suzhi:addRelatedSkill(suzhi_target)
simazhao:addSkill(zhaoxin)
simazhao:addSkill(suzhi)
simazhao:addRelatedSkill(fankui)
simazhao:addCompanions("hs__simayi")

Fk:loadTranslationTable{
  ["ld__simazhao"] = "司马昭",
  ["ld__zhaoxin"] = "昭心",
  [":ld__zhaoxin"] = "当你受到伤害后，你可以展示所有手牌，然后与一名手牌数不大于你的角色交换手牌。",
  ["#ld__zhaoxin-ask"] = "昭心：你可以展示所有手牌，然后与一名手牌数不大于你的角色交换手牌",
  ["#ld__zhaoxin-choose"] = "昭心：选择一名手牌数不大于你的角色，与其交换手牌",

  ["ld__suzhi"] = "夙智",
  [":ld__suzhi"] = "锁定技，你的回合内：1.你执行【杀】或【决斗】的效果而造成伤害时，此伤害+1；2.你使用非转化的锦囊牌时摸一张牌且无距离限制；"..
  "3.其他角色的牌被弃置后，你获得其一张牌。当你于一回合内触发上述效果三次后，此技能于此回合内失效。回合结束时，你获得“反馈”直至回合开始。",
  ["@ld__suzhi-turn"] = "夙智",
  ["@@ld__fankui_simazhao"] = "夙智 反馈",

  ["ld__simazhao__fankui"] = "反馈",
  [":ld__simazhao__fankui"] = "当你受到伤害后，你可获得来源的一张牌。",

  ["$ld__zhaoxin1"] = "行明动正，何惧他人讥毁。",
  ["$ld__zhaoxin2"] = "大业之举，岂因宵小而动？",
  ["$ld__suzhi1"] = "敌军势大与否，无碍我自计定施。",
  ["$ld__suzhi2"] = "汝竭力强攻，也只是徒燥军心。",
  ["$ld__simazhao__fankui1"] = "胆敢诽谤惑众，这就是下场！",
  ["$ld__simazhao__fankui2"] = "今天，就拿你来杀鸡儆猴。",

  ["~ld__simazhao"] = "千里之功，只差一步了……",
}

--local sunchen = General(extension, "ld__sunchen", "wild", 4)





Fk:loadTranslationTable{
  ["ld__sunchen"] = "孙綝",
  ["shiluk"] = "嗜戮",
  [":shiluk"] = "当一名角色死亡后，你可将其所有武将牌置于你的武将牌旁，称为“戮”，若你为来源，你从剩余武将牌堆额外获得两张“戮”。"..
  "准备阶段，你可以弃置至多X张牌（X为“戮”数），摸等量的牌。",
  ["xiongnve"] = "凶虐",
  [":xiongnve"] = "出牌阶段开始时，你可以移去一张“戮”，令你本回合对此“戮”势力角色获得下列效果中的一项："..
  "1.对其造成伤害时，令此伤害+1；2.对其造成伤害时，你获得其一张牌；3.对其使用牌无次数限制。"..
  "出牌阶段结束时，你可以移去两张“戮”，然后直到你的下回合，其他角色对你造成的伤害-1。",

  ["$shiluk1"] = "以杀立威，谁敢反我？",
  ["$shiluk2"] = "将这些乱臣贼子，尽皆诛之！",
  ["$xiongnve1"] = "当今天子乃我所立，他敢怎样？",
  ["$xiongnve2"] = "我兄弟三人同掌禁军，有何所惧？",
  ["~ld__sunchen"] = "愿陛下念臣昔日之功，陛下？陛下！！",
}

local gongsunyuan = General(extension, "ld__gongsunyuan", "wild", 4)
local huaiyi = fk.CreateActiveSkill{
  name = "ld__huaiyi",
  prompt = "#ld__huaiyi-active",
  anim_type = "control",
  card_num = 0,
  target_num = 0,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0 and not player:isKongcheng()
  end,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local cards = player.player_cards[Player.Hand]
    player:showCards(cards)
    local colors = {}
    for _, id in ipairs(cards) do
      table.insertIfNeed(colors, Fk:getCardById(id):getColorString())
    end
    if #colors < 2 then return end
    local color = room:askForChoice(player, colors, self.name)
    local throw = {}
    for _, id in ipairs(cards) do
      if Fk:getCardById(id):getColorString() == color then
        table.insert(throw, id)
      end
    end
    room:throwCard(throw, self.name, player, player)
    local targets = room:askForChoosePlayers(player, table.map(table.filter(room:getOtherPlayers(player), function(p)
      return (not p:isNude()) end), function(p) return p.id end), 1, #throw, "#ld__huaiyi-choose:::"..tostring(#throw), self.name, true)
    if #targets > 0 then
      room:sortPlayersByAction(targets)
      for _, pid in ipairs(targets) do
        if player.dead then break end
        local target = room:getPlayerById(pid)
        if target.dead or target:isNude() then
        else
          local id = room:askForCardChosen(player, target, "he", self.name)
          if Fk:getCardById(id).type == Card.TypeEquip then
            player:addToPile("ld__gongsunyuan_infidelity", id, true, self.name)
          else
            room:obtainCard(player, id, false, fk.ReasonPrey)
          end
        end
      end
    end
  end,
}

local zisui = fk.CreateTriggerSkill{
  name = "ld__zisui",
  frequency = Skill.Compulsory,
  mute = true,
  events = {fk.DrawNCards, fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self.name) or player ~= target then return false end
    if event == fk.DrawNCards and #player:getPile("ld__gongsunyuan_infidelity") > 0 then
      return true
    elseif event == fk.EventPhaseStart and player.phase == Player.Finish and #player:getPile("ld__gongsunyuan_infidelity") > player.maxHp then
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.DrawNCards then
      room:notifySkillInvoked(player, self.name, "drawcard")
      player:broadcastSkillInvoke(self.name)
      data.n = data.n + #player:getPile("ld__gongsunyuan_infidelity")
    elseif fk.EventPhaseStart then
      room:notifySkillInvoked(player, self.name, "negative")
      player.room:killPlayer({who = player.id})
    end
  end,
}

gongsunyuan:addSkill(huaiyi)
gongsunyuan:addSkill(zisui)

Fk:loadTranslationTable{
  ["ld__gongsunyuan"] = "公孙渊",
  ["ld__huaiyi"] = "怀异",
  [":ld__huaiyi"] = "出牌阶段限一次，你可以展示所有手牌，若其中包含两种颜色，则你弃置其中一种颜色的牌，然后获得至多X名角色的各一张牌"..
  "（X为你以此法弃置的手牌数）。你将以此法获得的装备牌置于武将牌上，称为“异”。",
  ["ld__zisui"] = "恣睢",
  [":ld__zisui"] = "锁定技，摸牌阶段，你多摸“异”数量的牌。结束阶段，若“异”数量大于你的体力上限，你死亡。",

  ["#ld__huaiyi-active"] = "发动 怀异，展示所有手牌，然后选择一种颜色弃置",
  ["#ld__huaiyi-choose"] = "怀异：你可以获得至多%arg名角色各一张牌",
  ["ld__gongsunyuan_infidelity"] = "异",

  ["$ld__huaiyi1"] = "曹魏可王，吾亦可王！",
  ["$ld__huaiyi2"] = "这天下，本就是我囊中之物。",
  ["$ld__zisui1"] = "仲达公，敢问这辽隧之战，谁胜谁负啊，哈哈哈哈……",
  ["$ld__zisui2"] = "凡从我大燕者，授印封爵，全族俱荣！",
  ["~ld__gongsunyuan"] = "流星骤损，三军皆溃，看来大势去矣……",
}


return extension

