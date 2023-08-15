local extension = Package:new("hegemony_standard")
extension.extensionName = "hegemony"

local heg_mode = require "packages.hegemony.hegemony"
extension:addGameMode(heg_mode)

Fk:loadTranslationTable{
  ["hegemony_standard"] = "国战标准版",
  ["hs"] = "国标",
}

local caocao = General(extension, "hs__caocao", "wei", 4)
caocao:addSkill("jianxiong")
Fk:loadTranslationTable{
  ["hs__caocao"] = "曹操",
}

local simayi = General(extension, "hs__simayi", "wei", 3)
simayi:addSkill("fankui")
--simayi:addSkill("ex__guicai") --手杀
simayi:addSkill("guicai")
Fk:loadTranslationTable{
  ["hs__simayi"] = "司马懿",
}

local xiahoudun = General(extension, "hs__xiahoudun", "wei", 4)
xiahoudun:addSkill("ganglie") --手杀修改：界刚烈
Fk:loadTranslationTable{
  ["hs__xiahoudun"] = "夏侯惇",
}

local zhangliao = General(extension, "hs__zhangliao", "wei", 4)
--zhangliao:addSkill("ex__tuxi") --手杀
zhangliao:addSkill("tuxi")
Fk:loadTranslationTable{
  ["hs__zhangliao"] = "张辽",
}

local xuchu = General(extension, "hs__xuchu", "wei", 4)
xuchu:addSkill("luoyi")
Fk:loadTranslationTable{
  ["hs__xuchu"] = "许褚",
}

local guojia = General(extension, "hs__guojia", "wei", 3)
local yiji = fk.CreateTriggerSkill{
  name = "hs__yiji",
  anim_type = "masochism",
  events = {fk.Damaged},
  on_use = function(self, event, target, player, data)
    local room = player.room
    local ids = room:getNCards(2)
    local fakemove = {
      toArea = Card.PlayerHand,
      to = player.id,
      moveInfo = table.map(ids, function(id) return {cardId = id, fromArea = Card.Void} end),
      moveReason = fk.ReasonJustMove,
    }
    room:notifyMoveCards({player}, {fakemove})
    for _, id in ipairs(ids) do
      room:setCardMark(Fk:getCardById(id), "yiji", 1)
    end
    while table.find(ids, function(id) return Fk:getCardById(id):getMark("yiji") > 0 end) do
      if not room:askForUseActiveSkill(player, "yiji_active", "#yiji-give", true) then
        for _, id in ipairs(ids) do
          room:setCardMark(Fk:getCardById(id), "yiji", 0)
        end
        ids = table.filter(ids, function(id) return room:getCardArea(id) ~= Card.PlayerHand end)
        fakemove = {
          from = player.id,
          toArea = Card.Void,
          moveInfo = table.map(ids, function(id) return {cardId = id, fromArea = Card.PlayerHand} end),
          moveReason = fk.ReasonGive,
        }
        room:notifyMoveCards({player}, {fakemove})
        room:moveCards({
          fromArea = Card.Void,
          ids = ids,
          to = player.id,
          toArea = Card.PlayerHand,
          moveReason = fk.ReasonGive,
          skillName = self.name,
        })
      end
    end
  end,
}
guojia:addSkill(yiji)
guojia:addSkill("tiandu")
Fk:loadTranslationTable{
  ["hs__guojia"] = "郭嘉",
  ["hs__yiji"] = "遗计",
  [":hs__yiji"] = "当你受到伤害后，你可观看牌堆顶的两张牌并分配。",
}

local zhenji = General(extension, "hs__zhenji", "wei", 3, 3, General.Female)
local luoshen = fk.CreateTriggerSkill{
  name = "hs__luoshen",
  anim_type = "drawcard",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and player.phase == Player.Start
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = {}
    while true do
      local judge = {
        who = player,
        reason = self.name,
        pattern = ".|.|spade,club",
      }
      room:judge(judge)
      local card = judge.card
      if card.color == Card.Black then
        table.insert(cards, card.id)
      end
      if card.color ~= Card.Black or player.dead or not room:askForSkillInvoke(player, self.name) then
        break
      end
    end
    cards = table.filter(cards, function(c) return room:getCardArea(c) == Card.DiscardPile end)
    if #cards > 0 then
      local dummy = Fk:cloneCard("jink")
      dummy:addSubcards(cards)
      room:obtainCard(player, dummy, true, fk.ReasonJustMove)
    end
  end,
}
zhenji:addSkill(luoshen)
zhenji:addSkill("qingguo")

Fk:loadTranslationTable{
  ["hs__zhenji"] = "甄姬",
  ["hs__luoshen"] = "洛神",
  [":hs__luoshen"] = "准备阶段开始时，你可进行判定，你可重复此流程，直到判定结果为红色，然后你获得所有黑色的判定牌。",
}
--xiahouyuan

--zhanghe

local xuhuang = General(extension, "hs__xuhuang", "wei", 4)
local duanliang = fk.CreateViewAsSkill{
  name = "hs__duanliang",
  anim_type = "control",
  pattern = "supply_shortage",
  card_filter = function(self, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).color == Card.Black and Fk:getCardById(to_select).type ~= Card.TypeTrick
  end,
  view_as = function(self, cards)
    if #cards ~= 1 then
      return nil
    end
    local c = Fk:cloneCard("supply_shortage")
    c.skillName = self.name
    c:addSubcard(cards[1])
    return c
  end,
  before_use = function(self, player, use)
    local targets = TargetGroup:getRealTargets(use.tos)
    if #targets == 0 then return end
    local room = player.room
    for _, p in ipairs(targets) do
      if player:distanceTo(room:getPlayerById(p)) > 2 then
        room:setPlayerMark(player, "@@hs__duanliang-phase", 1)
      end
    end
  end
}
local duanliang_targetmod = fk.CreateTargetModSkill{
  name = "#hs__duanliang_targetmod",
  distance_limit_func =  function(self, player, skill)
    if player:hasSkill(self.name) and skill.name == "supply_shortage_skill" then
      return 99
    end
  end,
}
local duanliang_invalidity = fk.CreateInvaliditySkill {
  name = "#hs__duanliang_invalidity",
  invalidity_func = function(self, from, skill)
    return from:getMark("@@hs__duanliang-phase") > 0 and
      skill.name == "hs__duanliang"
  end
}
duanliang:addRelatedSkill(duanliang_targetmod)
duanliang:addRelatedSkill(duanliang_invalidity)

xuhuang:addSkill(duanliang)

Fk:loadTranslationTable{
  ["hs__xuhuang"] = "徐晃",
  ["hs__duanliang"] = "断粮",
  [":hs__duanliang"] = "你可将一张不为锦囊牌的黑色牌当【兵粮寸断】使用（无距离关系的限制），若你至目标对应的角色的距离大于2，此技能于此阶段内无效。",

  ["@@hs__duanliang-phase"] = "断粮 无效",
}

local caoren = General(extension, "hs__caoren", "wei", 4)
local jushou_select = fk.CreateActiveSkill{
  name = "#hs__jushou_select",
  can_use = function() return false end,
  target_num = 0,
  card_num = 1,
  card_filter = function(self, to_select, selected)
    if #selected == 0 and Fk:currentRoom():getCardArea(to_select) ~= Card.PlayerEquip then
      local card = Fk:getCardById(to_select)
      if card.type == Card.TypeEquip then
        return not Self:prohibitUse(card)
      else
        return not Self:prohibitDiscard(card)
      end
    end
  end,
}
local jushou = fk.CreateTriggerSkill{
  name = "hs__jushou",
  anim_type = "defensive",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and player.phase == Player.Finish
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to_count = {}
    for _, p in ipairs(room.alive_players) do
      table.insertIfNeed(to_count, p.kingdom)
    end
    local num = #to_count
    room:drawCards(player, num, self.name)
    if player.dead then return false end
    local jushou_card
    for _, id in pairs(player:getCardIds(Player.Hand)) do
      local card = Fk:getCardById(id)
      if (card.type == Card.TypeEquip and not player:prohibitUse(card)) or (card.type ~= Card.TypeEquip and not player:prohibitDiscard(card)) then
        jushou_card = card
        break
      end
    end
    if not jushou_card then return end
    local _, ret = room:askForUseActiveSkill(player, "#hs__jushou_select", "#hs__jushou-select", false)
    if ret then
      jushou_card = Fk:getCardById(ret.cards[1])
    end
    if jushou_card then
      if jushou_card.type == Card.TypeEquip then
        room:useCard({
          from = player.id,
          tos = {{player.id}},
          card = jushou_card,
        })
      else
        room:throwCard(jushou_card:getEffectiveId(), self.name, player, player)
      end
    end
    if player.dead then return false end
    if num > 2 then player:turnOver() end
  end,
}
jushou:addRelatedSkill(jushou_select)
caoren:addSkill(jushou)

Fk:loadTranslationTable{
  ["hs__caoren"] = "曹仁",
  ["hs__jushou"] = "据守",
  [":hs__jushou"] = "结束阶段开始时，你可摸X张牌（X为势力数），然后弃置一张手牌，若以此法弃置的牌为装备牌，则改为你使用之。若X大于2，则你将武将牌叠置。",

  ["#hs__jushou_select"] = "据守",
  ["#hs__jushou-select"] = "据守：选择使用手牌中的一张装备牌或弃置手牌中的一张非装备牌",
}

--dianwei

--xunyu

--caopi

--yuejin

--liubei

local guanyu = General(extension, "hs__guanyu", "shu", 5)
guanyu:addSkill("wusheng")
Fk:loadTranslationTable{
  ["hs__guanyu"] = "关羽",
}

local zhangfei = General(extension, "hs__zhangfei", "shu", 4)
local paoxiaoTrigger = fk.CreateTriggerSkill{
  name = "#hs__paoxiaoTrigger",
  events = {fk.CardUsing},
  anim_type = "offensive",
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    if target ~= player or not player:hasSkill(self.name) or data.card.trueName ~= "slash" then return false end
    local events = player.room.logic:getEventsOfScope(GameEvent.UseCard, 2, function(e) 
      local use = e.data[1]
      return use.from == player.id and use.card.trueName == "slash" 
    end, Player.HistoryTurn)
    return #events == 2 and events[2].id == player.room.logic:getCurrentEvent().id
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, self.name)
  end,

  refresh_events = {fk.CardUsing},
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and
      data.card.trueName == "slash" and
      player:usedCardTimes("slash") > 1
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:broadcastSkillInvoke("paoxiao")
    player.room:doAnimate("InvokeSkill", {
      name = "paoxiao",
      player = player.id,
      skill_type = "offensive",
    })
  end,
}
local paoxiao = fk.CreateTargetModSkill{
  name = "hs__paoxiao",
  frequency = Skill.Compulsory,
  bypass_times = function(self, player, skill, scope)
    if player:hasSkill(self.name) and skill.trueName == "slash_skill"
      and scope == Player.HistoryPhase then
      return true
    end
  end,
}
paoxiao:addRelatedSkill(paoxiaoTrigger)

zhangfei:addSkill(paoxiao)

Fk:loadTranslationTable{
  ["hs__zhangfei"] = "张飞",
  ["hs__paoxiao"] = "咆哮",
  [":hs__paoxiao"] = "锁定技，你使用【杀】无次数限制。当你于出牌阶段使用第二张【杀】时，你摸一张牌。",

  ["#hs__paoxiaoTrigger"] = "咆哮",
}

--zhugeliang 可做

--local zhaoyun = General(extension, "hs__zhaoyun", "shu", 4) --……
Fk:loadTranslationTable{
  ["hs__zhaoyun"] = "赵云",
  ["hs__longdan"] = "龙胆",
  [":hs__longdan"] = "你可将【闪】当【杀】使用或打出，当此【杀】被一名角色使用的【闪】抵消后，你可对另一名角色造成1点伤害。你可将【杀】当【闪】使用或打出，当一名角色使用的【杀】被此【闪】抵消后，你可令另一名其他角色回复1点体力。",
}

local machao = General(extension, "hs__machao", "shu", 4)
local tieqi = fk.CreateTriggerSkill{
  name = "hs__tieqi",
  anim_type = "offensive",
  events = {fk.TargetSpecified},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and data.card.trueName == "slash"
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(data.to)
    local judge = {
      who = player,
      reason = self.name,
      pattern = ".|.|spade,club,heart,diamond",
    }
    if player.dead then return end
    local choices = {}
    if to.general ~= "anjiang" then
      table.insert(choices, to.general)
    end
    if to.deputyGeneral ~= "anjiang" then
      table.insert(choices, to.deputyGeneral)
    end
    if #choices > 0 then
      local choice = room:askForChoice(player, choices, self.name, "#hs__tieqi-ask::" .. to.id)
      local record = type(to:getMark("@hs__tieqi-turn")) == "table" and to:getMark("@hs__tieqi-turn") or {}
      table.insertIfNeed(record, choice)
      room:setPlayerMark(to, "@hs__tieqi-turn", record)
      local mark = type(to:getMark("_hs__tieqi-turn")) == "table" and to:getMark("_hs__tieqi-turn") or {}
      for _, skill_name in ipairs(Fk.generals[choice]:getSkillNameList()) do
        table.insertIfNeed(mark, skill_name)
      end
      room:setPlayerMark(to, "_hs__tieqi-turn", mark)
    end
    room:judge(judge)
    if judge.card.suit ~= nil then
      local suits = {}
      table.insert(suits, judge.card:getSuitString())
      if #room:askForDiscard(to, 1, 1, false, self.name, true, ".|.|" .. table.concat(suits, ","), "#hs__tieqi-discard:::" .. judge.card:getSuitString()) == 0 then
        data.disresponsive = true
      end
    end
  end,
}
local tieqiInvalidity = fk.CreateInvaliditySkill {
  name = "#hs__tieqi_invalidity",
  invalidity_func = function(self, from, skill)
    if from:getMark("_hs__tieqi-turn") ~= 0 then
      return table.contains(from:getMark("_hs__tieqi-turn"), skill.name) and
      (skill.frequency ~= Skill.Compulsory and skill.frequency ~= Skill.Wake) and not skill.name:endsWith("&")
    end
  end
}
tieqi:addRelatedSkill(tieqiInvalidity)
machao:addSkill("mashu")
machao:addSkill(tieqi)
Fk:loadTranslationTable{
  ["hs__machao"] = "马超",
  ["hs__tieqi"] = "铁骑",
  [":hs__tieqi"] = "当你使用【杀】指定目标后，你可判定，令其本回合一张处于明置状态的武将牌非锁定技失效，其需弃置一张与判定结果花色相同的牌，否则其不能使用【闪】抵消此【杀】。",
  ["@hs__tieqi-turn"] = "铁骑",
  ["#hs__tieqi-ask"] = "铁骑：选择 %dest 一张处于明置状态的武将牌，本回合此武将牌上的非锁定技失效",
  ["#hs__tieqi-discard"] = "铁骑：你需弃置一张%arg牌，否则不能使用【闪】抵消此【杀】。",
  ["$hs__tieqi1"] = "敌人阵型已乱，随我杀！",
  ["$hs__tieqi2"] = "目标敌阵，全军突击！",
  ["~hs__machao"] = "请将我，葬在西凉……",
}

return extension
