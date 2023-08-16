local extension = Package:new("hegemony_standard")
extension.extensionName = "hegemony"
extension.game_modes_whitelist = { 'nos_heg_mode', 'new_heg_mode' }

local heg_mode = require "packages.hegemony.hegemony"
extension:addGameMode(heg_mode)

Fk:loadTranslationTable{
  ["hegemony_standard"] = "国战标准版",
  ["hs"] = "国标",
}

local function noKingdom(player)
  return player.general == "anjiang" and player.deputyGeneral == "anjiang"
end

local function sameKingdom(player, target) --isFriendWith
  if player == target then return true end
  return player.kingdom == target.kingdom and player.kingdom ~= "wild" and not noKingdom(player) --野心家拉拢……
end

local function getKingdomMapper(room)
  local kingdomMapper = {}
  --local kingdoms = {}
  for _, p in ipairs(room.alive_players) do
    if not noKingdom(p) then
      local kingdom = p.kingdom
      if kingdom == "wild" then
        kingdom = tostring(p.id)
      end
      --[[
      if allCardMapper[kingdom] == nil then
        table.insert(kingdoms, kingdom)
      end
      ]]
      kingdomMapper[kingdom] = kingdomMapper[kingdom] or {}
      table.insert(kingdomMapper[kingdom], p.id)
    end
  end
  return kingdomMapper
end

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
      if not room:askForUseActiveSkill(player, "yiji_active", "#hs__yiji-give", true) then
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

  ["#hs__yiji-give"] = "遗计：你可以将这些牌分配给任意角色，点“取消”自己保留",
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
    local cardsJudged = {}
    while true do
      local judge = {
        who = player,
        reason = self.name,
        pattern = ".|.|spade,club",
        skipDrop = true,
      }
      room:judge(judge)
      local card = judge.card
      if card.color == Card.Black then
        table.insert(cardsJudged, card)
      end
      if card.color ~= Card.Black or player.dead or not room:askForSkillInvoke(player, self.name) then
        break
      end
    end
    cardsJudged = table.filter(cardsJudged, function(c) return room:getCardArea(c.id) == Card.Processing end)
    if #cardsJudged > 0 then
      local dummy = Fk:cloneCard("jink")
      dummy:addSubcards(table.map(cardsJudged, function(card)
        return card:getEffectiveId()
      end))
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

local xiahouyuan = General(extension, "hs__xiahouyuan", "wei", 4)
xiahouyuan:addSkill("shensu")
Fk:loadTranslationTable{
  ["hs__xiahouyuan"] = "夏侯渊",
}

local zhanghe = General(extension, "hs__zhanghe", "wei", 4)
zhanghe:addSkill("qiaobian")
Fk:loadTranslationTable{
  ["hs__zhanghe"] = "张郃",
}

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
    for k, plist in pairs(getKingdomMapper(room)) do
      table.insertIfNeed(to_count, k)
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

local dianwei = General(extension, "hs__dianwei", "wei", 4)
dianwei:addSkill("qiangxi")
Fk:loadTranslationTable{
  ['hs__dianwei'] = '典韦',
}

local xunyu = General(extension, "hs__xunyu", "wei", 3)
xunyu:addSkill("quhu")
xunyu:addSkill("jieming")
Fk:loadTranslationTable{
  ['hs__xunyu'] = '荀彧',
}

local caopi = General(extension, "hs__caopi", "wei", 3)
caopi:addSkill("xingshang")
caopi:addSkill("fangzhu")
Fk:loadTranslationTable{
  ['hs__caopi'] = '曹丕',
}

local yuejin = General(extension, "hs__yuejin", "wei", 4)

local xiaoguo = fk.CreateTriggerSkill{
  name = "hs__xiaoguo",
  anim_type = "offensive",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target ~= player and player:hasSkill(self.name) and target.phase == Player.Finish and not player:isKongcheng()
  end,
  on_cost = function(self, event, target, player, data)
    local card = player.room:askForDiscard(player, 1, 1, true, self.name, true, ".|.|.|.|.|basic", "#hs__xiaoguo-invoke::"..target.id, true)
    if #card > 0 then
      self.cost_data = card
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:throwCard(self.cost_data, self.name, player, player)
    if #room:askForDiscard(target, 1, 1, true, self.name, true, ".|.|.|.|.|equip", "#hs__xiaoguo-discard:"..player.id) == 0 then
      room:damage{
        from = player,
        to = target,
        damage = 1,
        skillName = self.name,
      }
    end
  end,
}
yuejin:addSkill(xiaoguo)

Fk:loadTranslationTable{
  ["hs__yuejin"] = "乐进",
  ["hs__xiaoguo"] = "骁果",
  [":hs__xiaoguo"] = "其他角色的结束阶段开始时，你可以弃置一张基本牌，然后其需弃置一张装备牌，否则你对其造成1点伤害。",
  ["#hs__xiaoguo-invoke"] = "骁果：你可以弃置一张基本牌，%dest 需弃置一张装备牌，否则你对其造成1点伤害",
  ["#hs__xiaoguo-discard"] = "骁果：你需弃置一张装备牌，否则 %src 对你造成1点伤害",
}

local liubei = General(extension, "hs__liubei", "shu", 4)
liubei:addSkill("ex__rende")
Fk:loadTranslationTable{
  ["hs__liubei"] = "刘备",
}

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

local zhugeliang = General(extension, "hs__zhugeliang", "shu", 4)

local kongcheng = fk.CreateTriggerSkill{
  name = "hs__kongcheng",
  anim_type = "defensive",
  events = {fk.TargetConfirming, fk.BeforeCardsMove, fk.EventPhaseStart},
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self.name) then return false end
    if event == fk.EventPhaseStart then
      return player == target and player.phase == Player.Draw and #player:getPile("zither") > 0
    else
      if not player:isKongcheng() then return false end
      if event == fk.TargetConfirming then
        return target == player and (data.card.trueName == "slash" or data.card.name == "duel")
      elseif event == fk.BeforeCardsMove then
        for _, move in ipairs(data) do
          if move.moveReason == fk.ReasonGive and move.to == player.id and move.toArea == Card.PlayerHand then
            return true
          end
        end
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    room:broadcastSkillInvoke(self.name)
    room:notifySkillInvoked(player, self.name, "defensive")
    if event == fk.TargetConfirming then
      AimGroup:cancelTarget(data, player.id)
    elseif event == fk.BeforeCardsMove then
      local mirror_moves = {}
      for _, move in ipairs(data) do
        if move.moveReason == fk.ReasonGive and move.to == player.id and move.toArea == Card.PlayerHand then
          local mirror_info = move.moveInfo
          if #mirror_info > 0 then
            move.moveInfo = {}
            local mirror_move = table.clone(move)
            mirror_move.toArea = Card.PlayerSpecial
            mirror_move.specialName = "zither"
            mirror_move.moveInfo = mirror_info
            table.insert(mirror_moves, mirror_move)
          end
        end
      end
      table.insertTable(data, mirror_moves)
    else
      local dummy = Fk:cloneCard("jink")
      dummy:addSubcards(player:getPile("zither"))
      room:obtainCard(player, dummy, true)
    end
  end
}

zhugeliang:addSkill("guanxing")
zhugeliang:addSkill(kongcheng)

Fk:loadTranslationTable{
  ["hs__zhugeliang"] = "诸葛亮",
  ["hs__kongcheng"] = "空城",
  [":hs__kongcheng"] = "锁定技，若你没有手牌：1. 当你成为【杀】或【决斗】的目标时，取消之；"..
    "2. 你的回合外，当牌因交给而移至你的手牌区前，你将此次移动的目标区域改为你的武将牌上（均称为“琴”），摸牌阶段开始时，你获得所有“琴”。",

  ["zither"] = "琴",
}

local zhaoyun = General(extension, "hs__zhaoyun", "shu", 4)

local longdan = fk.CreateViewAsSkill{
  name = "hs__longdan",
  pattern = "slash,jink",
  card_filter = function(self, to_select, selected)
    if #selected == 1 then return false end
    local _c = Fk:getCardById(to_select)
    local c
    if _c.trueName == "slash" then
      c = Fk:cloneCard("jink")
    elseif _c.name == "jink" then
      c = Fk:cloneCard("slash")
    else
      return false
    end
    return (Fk.currentResponsePattern == nil and Self:canUse(c)) or (Fk.currentResponsePattern and Exppattern:Parse(Fk.currentResponsePattern):match(c))
  end,
  view_as = function(self, cards)
    if #cards ~= 1 then
      return nil
    end
    local _c = Fk:getCardById(cards[1])
    local c
    if _c.trueName == "slash" then
      c = Fk:cloneCard("jink")
    elseif _c.name == "jink" then
      c = Fk:cloneCard("slash")
    end
    c.skillName = self.name
    c:addSubcard(cards[1])
    return c
  end,
}
local longdan_after = fk.CreateTriggerSkill{
  name = "#longdan_after",
  anim_type = "offensive",
  events = {fk.CardEffectCancelledOut},
  can_trigger = function(self, event, target, player, data)
    if data.card.trueName ~= "slash" then return false end
    if target == player then --龙胆杀
      return table.contains(data.card.skillNames, "hs__longdan")
    elseif data.to == player.id then --龙胆闪
      for _, card in ipairs(data.cardsResponded) do
        if card.name == "jink" and table.contains(card.skillNames, "hs__longdan") then
          return true
        end
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if target == player then
      local targets = table.map(room:getOtherPlayers(room:getPlayerById(data.to)), Util.IdMapper)
      if #targets == 0 then return false end
      local target = room:askForChoosePlayers(player, targets, 1, 1, "#longdan_slash-ask::" .. data.to, self.name, true)
      if #target > 0 then
        self.cost_data = target[1]
        return true
      end
      return false
    else
      local targets = table.map(table.filter(room:getOtherPlayers(target), function(p) return
        p ~= player and p:isWounded()
      end), Util.IdMapper)
      if #targets == 0 then return false end
      local target = room:askForChoosePlayers(player, targets, 1, 1, "#longdan_jink-ask::" .. target.id , self.name, true)
      if #target > 0 then
        self.cost_data = target[1]
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(self.cost_data)
    if target == player then
      room:damage{
        from = player,
        to = to,
        damage = 1,
        skillName = self.name,
      }
    else
      room:recover({
        who = to,
        num = 1,
        recoverBy = player,
        skillName = self.name,
      })
    end
  end,
}

longdan:addRelatedSkill(longdan_after)
zhaoyun:addSkill(longdan)

Fk:loadTranslationTable{
  ["hs__zhaoyun"] = "赵云",
  ["hs__longdan"] = "龙胆",
  [":hs__longdan"] = "你可将【闪】当【杀】使用或打出，当此【杀】被一名角色使用的【闪】抵消后，你可对另一名角色造成1点伤害。你可将【杀】当【闪】使用或打出，当一名角色使用的【杀】被此【闪】抵消后，你可令另一名其他角色回复1点体力。",

  ["#longdan_after"] = "龙胆",
  ["#longdan_slash-ask"] = "龙胆：你可对 %dest 以外的一名角色造成1点伤害",
  ["#longdan_jink-ask"] = "龙胆：你可令 %dest 以外的一名其他角色回复1点体力",
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
  [":hs__tieqi"] = "当你使用【杀】指定目标后，你可判定，令其本回合一张明置的武将牌非锁定技失效，其需弃置一张与判定结果花色相同的牌，否则其不能使用【闪】抵消此【杀】。",
  ["@hs__tieqi-turn"] = "铁骑",
  ["#hs__tieqi-ask"] = "铁骑：选择 %dest 一张明置的武将牌，本回合此武将牌上的非锁定技失效",
  ["#hs__tieqi-discard"] = "铁骑：你需弃置一张%arg牌，否则不能使用【闪】抵消此【杀】。",
  ["$hs__tieqi1"] = "敌人阵型已乱，随我杀！",
  ["$hs__tieqi2"] = "目标敌阵，全军突击！",
  ["~hs__machao"] = "请将我，葬在西凉……",
}

local huangyueying = General(extension, "hs__huangyueying", "shu", 3, 3, General.Female)
local jizhi = fk.CreateTriggerSkill{
  name = "hs__jizhi",
  anim_type = "drawcard",
  events = {fk.CardUsing},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and data.card:isCommonTrick() and
      (not data.card:isVirtual() or #data.card.subcards == 0)
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, self.name)
  end,
}

huangyueying:addSkill(jizhi)
huangyueying:addSkill("qicai")

Fk:loadTranslationTable{
  ["hs__huangyueying"] = "黄月英",
  ["hs__jizhi"] = "集智",
  [":hs__jizhi"] = "当你使用非转化的普通锦囊牌时，你可摸一张牌。",
}

local huangzhong = General(extension, "hs__huangzhong", "shu", 4)
huangzhong:addSkill("liegong")
Fk:loadTranslationTable{
  ["hs__huangzhong"] = "黄忠",
}

local weiyan = General(extension, "hs__weiyan", "shu", 4)
local kuanggu = fk.CreateTriggerSkill{ --虽然已有
  name = "hs__kuanggu",
  anim_type = "drawcard",
  events = {fk.Damage},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self.name) and target == player and (data.extra_data or {}).kuanggucheak
  end,
  on_trigger = function(self, event, target, player, data)
    self.cancel_cost = false
    for i = 1, data.damage do
      self:doCost(event, target, player, data)
      if self.cost_data == "Cancel" then break end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local choices = {"draw1", "Cancel"}
    if player:isWounded() then
      table.insert(choices, 2, "recover")
    end
    self.cost_data = room:askForChoice(player, choices, self.name)
    return self.cost_data ~= "Cancel"
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if self.cost_data == "recover" then
      room:recover({
        who = player,
        num = 1,
        recoverBy = player,
        skillName = self.name
      })
    elseif self.cost_data == "draw1" then
      player:drawCards(1, self.name)
    end
  end,

  refresh_events = {fk.BeforeHpChanged},
  can_refresh = function(self, event, target, player, data)
    if data.damageEvent and player == data.damageEvent.from and player:distanceTo(target) < 2 then
      return true
    end
  end,
  on_refresh = function(self, event, target, player, data)
    data.damageEvent.extra_data = data.damageEvent.extra_data or {}
    data.damageEvent.extra_data.kuanggucheak = true
  end,
}

weiyan:addSkill(kuanggu)

Fk:loadTranslationTable{
  ["hs__weiyan"] = "魏延",
  ["hs__kuanggu"] = "狂骨",
  [":hs__kuanggu"] = "当你对距离1以内的角色造成1点伤害后，你可摸一张牌或回复1点体力。",
  ["draw1"] = "摸一张牌",
  ["recover"] = "回复1点体力",
}

--pangtong

local wolong = General(extension, "hs__wolong", "shu", 3)
wolong:addSkill("bazhen")
wolong:addSkill("huoji")
wolong:addSkill("kanpo")
Fk:loadTranslationTable{
  ['hs__wolong'] = '卧龙诸葛亮',
}

local liushan = General(extension, "hs__liushan", "shu", 3)
liushan:addSkill("xiangle")
liushan:addSkill("fangquan")
Fk:loadTranslationTable{
  ['hs__liushan'] = '刘禅',
}

--menghuo

local zhurong = General(extension, "hs__zhurong", "shu", 4, 4, General.Female)
zhurong:addSkill("juxiang")
zhurong:addSkill("lieren")
Fk:loadTranslationTable{
  ['hs__zhurong'] = '祝融',
}

--ganfuren

local sunquan = General(extension, "hs__sunquan", "wu", 4)

local zhiheng = fk.CreateActiveSkill{
  name = "hs__zhiheng",
  anim_type = "drawcard",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  target_num = 0,
  min_card_num = 1,
  max_card_num = function()
    return Self.maxHp
  end,
  card_filter = function(self, to_select, selected)
    return #selected < Self.maxHp
  end,
  on_use = function(self, room, effect)
    local from = room:getPlayerById(effect.from)
    room:throwCard(effect.cards, self.name, from, from)
    from:drawCards(#effect.cards, self.name)
  end
}

sunquan:addSkill(zhiheng)

Fk:loadTranslationTable{
  ["hs__sunquan"] = "孙权",
  ["hs__zhiheng"] = "制衡",
  [":hs__zhiheng"] = "出牌阶段限一次，你可弃置至多X张牌（X为你的体力上限），然后你摸等量的牌。",
}

local ganning = General(extension, "hs__ganning", "wu", 4)

ganning:addSkill("qixi")

Fk:loadTranslationTable{
  ["hs__ganning"] = "甘宁",
}

local lvmeng = General(extension, "hs__lvmeng", "wu", 4)

local keji = fk.CreateTriggerSkill{
  name = "hs__keji",
  anim_type = "defensive",
  events = {fk.EventPhaseStart},
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    if target ~= player or not player:hasSkill(self.name) or player.phase ~= Player.Discard then return false end 
    local cards, play_ids = {}, {}
    local logic = player.room.logic
    logic:getEventsOfScope(GameEvent.Phase, 1, function (e)
      if e.data[2] == Player.Play then
        table.insert(play_ids, {e.id, e.end_id})
      end
      return false
    end, Player.HistoryTurn)
    logic:getEventsOfScope(GameEvent.UseCard, 1, function (e)
      local in_play = false
      for _, ids in ipairs(play_ids) do
        if #ids == 2 and e.id > ids[1] and e.id < ids[2] then
          in_play = true
          break
        end
      end
      if in_play then
        local use = e.data[1]
        if use.from == player.id and (use.card.color ~= Card.NoColor) then
          table.insertIfNeed(cards, use.card.color)
        end
      end
    end, Player.HistoryTurn)
    return #cards <= 1
  end,
  on_use = function(self, event, target, player, data)
    player.room:addPlayerMark(player, MarkEnum.AddMaxCardsInTurn, 4)
  end
}

local mouduan = fk.CreateTriggerSkill{
  name = "hs__mouduan",
  events = {fk.EventPhaseStart},
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    if target ~= player or not player:hasSkill(self.name) or player.phase ~= Player.Finish then return false end 
    local suits, types, play_ids = {}, {}, {}
    local logic = player.room.logic
    logic:getEventsOfScope(GameEvent.Phase, 1, function (e)
      if e.data[2] == Player.Play then
        table.insert(play_ids, {e.id, e.end_id})
      end
      return false
    end, Player.HistoryTurn)
    logic:getEventsOfScope(GameEvent.UseCard, 1, function (e)
      local in_play = false
      for _, ids in ipairs(play_ids) do
        if #ids == 2 and e.id > ids[1] and e.id < ids[2] then
          in_play = true
          break
        end
      end
      if in_play then
        local use = e.data[1]
        if use.from == player.id then
          table.insertIfNeed(suits, use.card.suit)
          table.insertIfNeed(types, use.card.type)
        end
      end
    end, Player.HistoryTurn)
    return #suits >= 4 or #types >= 3
  end,
  on_cost = function(self, event, target, player, data)
    local targets = player.room:askForChooseToMoveCardInBoard(player, "#hs__mouduan-move", self.name, true, nil)
    if #targets ~= 0 then
      self.cost_data = targets
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local targets = self.cost_data
    local room = player.room
    targets = table.map(targets, function(id) return room:getPlayerById(id) end)
    room:askForMoveCardInBoard(player, targets[1], targets[2], self.name)
  end
}

lvmeng:addSkill(keji)
lvmeng:addSkill(mouduan)

Fk:loadTranslationTable{
  ["hs__lvmeng"] = "吕蒙",
  ["hs__keji"] = "克己",
	[":hs__keji"] = "锁定技，弃牌阶段开始时，若你于出牌阶段内未使用过有颜色的牌，或于出牌阶段内使用过的所有的牌的颜色均相同，你的手牌上限于此回合内+4。",
	["hs__mouduan"] = "谋断",
	[":hs__mouduan"] = "结束阶段开始时，若你于出牌阶段内使用过四种花色或三种类别的牌，你可移动场上的一张牌。",

  ["#hs__mouduan-move"] = "谋断：你可选择两名角色，移动他们场上的一张牌",
}

local huanggai = General(extension, "hs__huanggai", "wu", 4)

local kurou = fk.CreateActiveSkill{
  name = "hs__kurou",
  anim_type = "drawcard",
  card_num = 1,
  target_num = 0,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  on_use = function(self, room, effect)
    local from = room:getPlayerById(effect.from)
    room:throwCard(effect.cards, self.name, from, from)
    if from.dead then return end
    room:loseHp(from, 1, self.name)
    if from.dead then return end
    from:drawCards(3, self.name)
  end
}
local kurouBuff = fk.CreateTargetModSkill{
  name = "#hs__kurou_buff",
  residue_func = function(self, player, skill, scope)
    if skill.trueName == "slash_skill" and scope == Player.HistoryPhase then
      return player:usedSkillTimes("hs__kurou", Player.HistoryPhase)
    end
  end,
}
kurou:addRelatedSkill(kurouBuff)

huanggai:addSkill(kurou)

Fk:loadTranslationTable{
  ["hs__huanggai"] = "黄盖",
  ["hs__kurou"] = "苦肉",
  [":hs__kurou"] = "出牌阶段限一次，你可弃置一张牌，然后你失去1点体力，摸三张牌，于此阶段内使用【杀】的次数上限+1。",
}

--zhouyu

local daqiao = General(extension, "hs__daqiao", "wu", 3, 3, General.Female)

daqiao:addSkill("guose")
daqiao:addSkill("liuli")

Fk:loadTranslationTable{
  ["hs__daqiao"] = "大乔",
}

local luxun = General(extension, "hs__luxun", "wu", 3)

local qianxun = fk.CreateTriggerSkill{
  name = "hs__qianxun",
  anim_type = "defensive",
  events = {fk.TargetConfirming},
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and (data.card.name == "snatch" or data.card.name == "indulgence")
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    room:broadcastSkillInvoke(self.name)
    room:notifySkillInvoked(player, self.name, "defensive")
    AimGroup:cancelTarget(data, player.id)
  end
}

local duoshi = fk.CreateViewAsSkill{
  name = "duoshi",
  anim_type = "drawcard",
  pattern = "await_exhausted",
  card_filter = function(self, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).color == Card.Red and Fk:currentRoom():getCardArea(to_select) == Player.Hand
  end,
  view_as = function(self, cards)
    if #cards ~= 1 then
      return nil
    end
    local c = Fk:cloneCard("await_exhausted")
    c.skillName = self.name
    c:addSubcard(cards[1])
    return c
  end,
  enabled_at_play = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryTurn) < 4
  end,
}

luxun:addSkill(qianxun)
luxun:addSkill(duoshi)

Fk:loadTranslationTable{
  ["hs__luxun"] = "陆逊",
  ["hs__qianxun"] = "谦逊",
	[":hs__qianxun"] = "锁定技，当你成为【顺手牵羊】或【乐不思蜀】的目标时，你取消此目标。",
  ["duoshi"] = "度势",
  [":duoshi"] = "每阶段限四次，你可将一张红色手牌当【以逸待劳】使用。",
}

local sunshangxiang = General(extension, "hs__sunshangxiang", "wu", 3, 3, General.Female)

local xiaoji = fk.CreateTriggerSkill{
  name = "hs__xiaoji",
  anim_type = "drawcard",
  events = {fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self.name) then return end
    for _, move in ipairs(data) do
      if move.from == player.id then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerEquip then
            return true
          end
        end
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    if player.room:askForSkillInvoke(player, self.name) then
      return true
    end
    self.cancel_cost = true
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(2, self.name)
  end,
}

sunshangxiang:addSkill(xiaoji)
sunshangxiang:addSkill("jieyin")

Fk:loadTranslationTable{
  ["hs__sunshangxiang"] = "孙尚香",
  ["hs__xiaoji"] = "枭姬",
	[":hs__xiaoji"] = "当你失去装备区的装备牌后，你可以摸两张牌。",
}

local sunjian = General(extension, "hs__sunjian", "wu", 5)
sunjian:addSkill("yinghun")
Fk:loadTranslationTable{
  ['hs__sunjian'] = '孙坚',
}

--xiaoqiao

local taishici = General(extension, "hs__taishici", "wu", 4)
taishici:addSkill("tianyi")
Fk:loadTranslationTable{
  ['hs__taishici'] = '太史慈',
}

--zhoutai

local lusu = General(extension, "hs__lusu", "wu", 3)
lusu:addSkill("haoshi")
lusu:addSkill("dimeng")
Fk:loadTranslationTable{
  ['hs__lusu'] = '鲁肃',
}

local erzhang = General(extension, "hs__zhangzhaozhanghong", "wu", 3)
erzhang:addSkill("zhijian")
erzhang:addSkill("guzheng")
Fk:loadTranslationTable{
  ['hs__zhangzhaozhanghong'] = '张昭张纮',
}

local dingfeng = General(extension, "hs__dingfeng", "wu", 4)
dingfeng:addSkill("duanbing")
dingfeng:addSkill("fenxun")
Fk:loadTranslationTable{
  ["hs__dingfeng"] = "丁奉",
}

local huatuo = General(extension, "hs__huatuo", "qun", 3)

local chuli = fk.CreateActiveSkill{
  name = "hs__chuli",
  anim_type = "control",
  card_num = 0,
  min_target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0 and not player:isNude()
  end,
  card_filter = function(self, to_select, selected)
    return false
  end,
  target_filter = function(self, to_select, selected, selected_cards)
    local room = Fk:currentRoom()
    local target = room:getPlayerById(to_select)
    return to_select ~= Self.id and not target:isNude() and #selected < 3 and
      table.every(selected, function(id) return not sameKingdom(target, room:getPlayerById(id)) end)
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local targets = table.clone(effect.tos)
    table.insert(targets, 1, effect.from)
    room:sortPlayersByAction(targets)
    for _, id in ipairs(targets) do
      local target = room:getPlayerById(id)
      if not target:isNude() then
        local c = room:askForCardChosen(player, target, "he", self.name)
        room:throwCard({c}, self.name, target, player)
        if Fk:getCardById(c).suit == Card.Spade then
          room:addPlayerMark(target, "_hs__chuli-phase", 1)
        end
      end
    end
    for _, id in ipairs(targets) do
      local target = room:getPlayerById(id)
      if target:getMark("_hs__chuli-phase") > 0 and not target.dead then
        room:setPlayerMark(target, "_hs__chuli-phase", 0)
        target:drawCards(1, self.name)
      end
    end
  end,
}

huatuo:addSkill("jijiu")
huatuo:addSkill(chuli)

Fk:loadTranslationTable{
  ["hs__huatuo"] = "华佗",
  ["hs__chuli"] = "除疠",
  [":hs__chuli"] = "出牌阶段限一次，你可选择至多三名势力各不相同或未确定势力的其他角色，然后你弃置你和这些角色的各一张牌。被弃置♠牌的角色各摸一张牌。",
}

local lvbu = General(extension, "hs__lvbu", "qun", 5)

lvbu:addSkill("wushuang")

Fk:loadTranslationTable{
  ["hs__lvbu"] = "吕布",
}

local diaochan = General(extension, "hs__diaochan", "qun", 3, 3, General.Female)

local lijian = fk.CreateActiveSkill{
  name = "hs__lijian",
  anim_type = "offensive",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = function(self, to_select, selected)
    return #selected == 0
  end,
  target_filter = function(self, to_select, selected)
    return #selected < 2 and to_select ~= Self.id and
      Fk:currentRoom():getPlayerById(to_select).gender == General.Male
  end,
  target_num = 2,
  min_card_num = 1,
  on_use = function(self, room, use)
    local player = room:getPlayerById(use.from)
    room:throwCard(use.cards, self.name, player, player)
    local duel = Fk:cloneCard("duel")
    duel.skillName = self.name
    local new_use = { ---@type CardUseStruct
      from = use.tos[2],
      tos = { { use.tos[1] } },
      card = duel,
    }
    room:useCard(new_use)
  end,
}

diaochan:addSkill(lijian)
diaochan:addSkill("biyue")

Fk:loadTranslationTable{
  ["hs__diaochan"] = "貂蝉",
  ["hs__lijian"] = "离间",
  [":hs__lijian"] = "出牌阶段限一次，你可弃置一张牌并选择两名其他男性角色，后选择的角色视为对先选择的角色使用一张【决斗】。",
}

local yuanshao = General(extension, "hs__yuanshao", "qun", 4)

local luanji = fk.CreateViewAsSkill{
  name = "hs__luanji",
  anim_type = "offensive",
  pattern = "archery_attack",
  card_filter = function(self, to_select, selected)
    if #selected == 2 or Fk:currentRoom():getCardArea(to_select) ~= Player.Hand then return false end
    local record = type(Self:getMark("@hs__luanji-turn")) == "table" and Self:getMark("@hs__luanji-turn") or {}
    return not table.contains(record, Fk:getCardById(to_select):getSuitString(true))
  end,
  view_as = function(self, cards)
    if #cards ~= 2 then
      return nil
    end
    local c = Fk:cloneCard("archery_attack")
    c.skillName = "hs__luanji"
    c:addSubcards(cards)
    return c
  end,
  before_use = function(self, player, use)
    local room = player.room
    local record = type(player:getMark("@hs__luanji-turn")) == "table" and player:getMark("@hs__luanji-turn") or {}
    local cards = use.card.subcards
    for _, cid in ipairs(cards) do
      local suit = Fk:getCardById(cid):getSuitString(true)
      if suit ~= "log_nosuit" then table.insertIfNeed(record, suit) end
    end
    room:setPlayerMark(player, "@hs__luanji-turn", record)
  end
}
local luanji_draw = fk.CreateTriggerSkill{
  name = "#hs__luanji_draw",
  anim_type = "drawcard",
  events = {fk.CardRespondFinished},
  can_trigger = function(self, event, target, player, data)
    if target ~= player or data.card.name ~= "jink" or player.dead then return false end
    if data.responseToEvent and table.contains(data.responseToEvent.card.skillNames, "hs__luanji") then
      local yuanshao = data.responseToEvent.from
      if yuanshao and sameKingdom(player, player.room:getPlayerById(yuanshao)) then
        return true
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, nil, "#hs__luanji-draw")
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, self.name)
  end,
}
luanji:addRelatedSkill(luanji_draw)

yuanshao:addSkill(luanji)

Fk:loadTranslationTable{
  ["hs__yuanshao"] = "袁绍",
  ["hs__luanji"] = "乱击",
  [":hs__luanji"] = "你可将两张手牌当【万箭齐发】使用（不能使用此回合以此法使用过的花色），与你势力相同的角色打出【闪】响应此牌结算结束后，其可摸一张牌。",

  ["@hs__luanji-turn"] = "乱击",
  ["#hs__luanji-draw"] = "乱击：你可摸一张牌",
  ["#hs__luanji_draw"] = "乱击",
}

local sx = General(extension, 'hs__yanliangwenchou', 'qun', 4)
sx:addSkill('shuangxiong')
Fk:loadTranslationTable{
  ['hs__yanliangwenchou'] = '颜良文丑',
}

local jiaxu = General(extension, 'hs__jiaxu', 'qun', 3)
jiaxu:addSkill('wansha')
jiaxu:addSkill('luanwu')
local weimu = fk.CreateTriggerSkill{
  name = "hs__weimu",
  anim_type = "defensive",
  events = { fk.TargetConfirming },
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and data.card.color == Card.Black and data.card.type == Card.TypeTrick
  end,
  on_use = function(self, event, target, player, data)
    AimGroup:cancelTarget(data, player.id)
  end
}
jiaxu:addSkill(weimu)
Fk:loadTranslationTable{
  ['hs__jiaxu'] = '贾诩',
  ['hs__weimu'] = '帷幕',
  [':hs__weimu'] = '锁定技，当你成为黑色锦囊牌目标后，取消之。',
}

local pangde = General(extension, "hs__pangde", "qun", 4)

local jianchu = fk.CreateTriggerSkill{
  name = "jianchu",
  anim_type = "offensive",
  events = {fk.TargetSpecified},
  can_trigger = function(self, event, target, player, data)
    if not (target == player and player:hasSkill(self.name)) then return end
    local to = player.room:getPlayerById(data.to)
    return data.card.trueName == "slash" and not to:isNude()
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(data.to)
    local id = room:askForCardChosen(player, to, "he", self.name)
    room:throwCard({id}, self.name, to, player)
    local card = Fk:getCardById(id)
    if card.type == Card.TypeEquip then
      data.disresponsive = true
    else
      if not to.dead then
        local cardlist = Card:getIdList(data.card)
        if #cardlist > 0 and table.every(cardlist, function(id) return room:getCardArea(id) == Card.Processing end) then
          room:obtainCard(to.id, data.card, false)
        end
      end
    end
  end,
}

pangde:addSkill("mashu")
pangde:addSkill(jianchu)

Fk:loadTranslationTable{
  ["hs__pangde"] = "庞德",
  ["jianchu"] = "鞬出",
  [":jianchu"] = "当你使用【杀】指定目标后，你可以弃置该角色的一张牌，若此牌：为装备牌，其不能使用【闪】抵消此【杀】；不为装备牌，其获得此【杀】。",
}

local zhangjiao = General(extension, "hs__zhangjiao", 'qun', 3)
zhangjiao:addSkill("leiji")
zhangjiao:addSkill("guidao")
Fk:loadTranslationTable{
  ['hs__zhangjiao'] = '张角',
}

--caiwenji

local mateng = General(extension, "hs__mateng", "qun", 4)

local xiongyi = fk.CreateActiveSkill{
  name = "xiongyi",
  anim_type = "drawcard",
  frequency = Skill.Limited,
  card_num = 0,
  target_num = 0,
  frequency = Skill.Limited,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,
  card_filter = function() return false end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local targets = table.map(table.filter(room.alive_players, function(p) return sameKingdom(p, player) end), Util.IdMapper)
    room:sortPlayersByAction(targets)
    for _, p in ipairs(targets) do
      p = room:getPlayerById(p)
      if not p.dead then
        p:drawCards(3, self.name)
      end
    end
    if player.dead then return false end
    local kingdomMapper = getKingdomMapper(room)
    local num = #kingdomMapper[player.kingdom == "wild" and tostring(p.id) or player.kingdom]
    for k, plist in pairs(kingdomMapper) do
      if #plist < num then return false end
    end
    if player:isWounded() then
      room:recover({
        who = player,
        num = 1,
        recoverBy = player,
        skillName = self.name
      })
    end
  end,
}

mateng:addSkill("mashu")
mateng:addSkill(xiongyi)

Fk:loadTranslationTable{
  ["hs__mateng"] = "马腾",
  ["xiongyi"] = "雄异",
  [":xiongyi"] = "限定技，出牌阶段，你可令与你势力相同的所有角色各摸三张牌，然后若你的势力是角色数最小的势力，你回复1点体力。",
}

local kongrong = General(extension, "hs__kongrong", "qun", 3)

local mingshi = fk.CreateTriggerSkill{
  name = "mingshi",
  anim_type = "defensive",
  events = {fk.DamageInflicted},
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and data.from and 
      (data.from.general == "anjiang" or data.from.deputyGeneral == "anjiang")
  end,
  on_use = function(self, event, target, player, data)
    data.damage = data.damage - 1
  end,
}
local lirang = fk.CreateTriggerSkill{
  name = "lirang",
  anim_type = "support",
  events = {fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self.name) then return false end
    for _, move in ipairs(data) do
      if move.from == player.id and move.moveReason == fk.ReasonDiscard and move.toArea == Card.DiscardPile then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip then
            return true
          end
        end
      end
    end
  end,
  on_trigger = function(self, event, target, player, data)
    for _, move in ipairs(data) do
      if not player:hasSkill(self.name) then break end
      if move.from == player.id and move.moveReason == fk.ReasonDiscard and move.toArea == Card.DiscardPile then
        local cids = {}
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip then
            table.insertIfNeed(cids, info.cardId)
          end
        end
        self:doCost(event, nil, player, cids)
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local ids = data
    local room = player.room
    local fakemove = {
      toArea = Card.PlayerHand,
      to = player.id,
      moveInfo = table.map(ids, function(id) return {cardId = id, fromArea = Card.DiscardPile} end),
      moveReason = fk.ReasonJustMove,
    }
    room:notifyMoveCards({player}, {fakemove})
    for _, id in ipairs(ids) do
      room:setCardMark(Fk:getCardById(id), "lirang", 1)
    end
    while table.find(ids, function(id) return Fk:getCardById(id):getMark("lirang") > 0 end) do
      if not room:askForUseActiveSkill(player, "#lirang_active", "#lirang-give", true) then
        for _, id in ipairs(ids) do
          room:setCardMark(Fk:getCardById(id), "lirang", 0)
        end
        ids = table.filter(ids, function(id) return room:getCardArea(id) ~= Card.PlayerHand end)
        fakemove = {
          from = player.id,
          toArea = Card.DiscardPile,
          moveInfo = table.map(ids, function(id) return {cardId = id, fromArea = Card.PlayerHand} end),
          moveReason = fk.ReasonGive,
        }
        room:notifyMoveCards({player}, {fakemove})
      end
    end
  end,
}
local lirang_active = fk.CreateActiveSkill{
  name = "#lirang_active",
  mute = true,
  min_card_num = 1,
  target_num = 1,
  card_filter = function(self, to_select, selected, targets)
    return Fk:getCardById(to_select):getMark("lirang") > 0
  end,
  target_filter = function(self, to_select, selected, selected_cards)
    return #selected == 0 and to_select ~= Self.id
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    room:doIndicate(player.id, {target.id})
    for _, id in ipairs(effect.cards) do
      room:setCardMark(Fk:getCardById(id), "lirang", 0)
    end
    local fakemove = {
      from = player.id,
      toArea = Card.DiscardPile,
      moveInfo = table.map(effect.cards, function(id) return {cardId = id, fromArea = Card.PlayerHand} end),
      moveReason = fk.ReasonGive,
    }
    room:notifyMoveCards({player}, {fakemove})
    room:moveCards({
      fromArea = Card.DiscardPile,
      ids = effect.cards,
      to = target.id,
      toArea = Card.PlayerHand,
      moveReason = fk.ReasonGive,
      skillName = self.name,
    })
  end,
}
lirang:addRelatedSkill(lirang_active)

kongrong:addSkill(mingshi)
kongrong:addSkill(lirang)

Fk:loadTranslationTable{
  ["hs__kongrong"] = "孔融",
  ["mingshi"] = "名士",
  [":mingshi"] = "锁定技，当你受到伤害时，若来源有暗置的武将牌，你令伤害值-1。",
	["lirang"] = "礼让",
	[":lirang"] = "当你的牌因弃置而移至弃牌堆后，你可将其中的至少一张牌交给其他角色。",

  ["#lirang-give"] = "礼让：你可以将这些牌分配给任意角色，点“取消”仍弃置",
}

local jiling = General(extension, "hs__jiling", "qun", 4)

local shuangren = fk.CreateTriggerSkill{
  name = "shuangren",
  anim_type = "offensive",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self.name) and player.phase == Player.Play and not player:isKongcheng() and table.find(player.room:getOtherPlayers(player), function(p)
      return not p:isKongcheng()
    end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local availableTargets = table.map(
      table.filter(room:getOtherPlayers(player), function(p)
        return not p:isKongcheng()
      end),
      function(p)
        return p.id
      end
    )
    if #availableTargets == 0 then return false end
    local target = room:askForChoosePlayers(player, availableTargets, 1, 1, "#shuangren-ask", self.name, true)
    if #target > 0 then
      self.cost_data = target[1]
      return true
    end
    return false
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local target = room:getPlayerById(self.cost_data)
    local pindian = player:pindian({target}, self.name)
    if pindian.results[target.id].winner == player then
      if player.dead then return end
      local slash = Fk:cloneCard("slash")
      if player:prohibitUse(slash) then return false end
      local availableTargets = table.map(
        table.filter(room:getOtherPlayers(player), function(p)
          return sameKingdom(p, target) and not player:isProhibited(p, slash)
        end),
        function(p)
          return p.id
        end
      )
      if #availableTargets == 0 then return false end
      local victims = room:askForChoosePlayers(player, availableTargets, 1, 1, "#shuangren_slash-ask:" .. target.id, self.name, false)
      if #victims > 0 then
        local to = room:getPlayerById(victims[1])
        if to.dead then return false end
        room:useVirtualCard("slash", nil, player, {to}, self.name, true)
      end
    else
      --player:endPlayPhase()
      return true
    end
  end,
}

jiling:addSkill(shuangren)

Fk:loadTranslationTable{
  ["hs__jiling"] = "纪灵",
  ["shuangren"] = "双刃",
  [":shuangren"] = "出牌阶段开始时，你可与一名角色拼点。若你：赢，你视为对与其势力相同的一名角色使用【杀】；没赢，你结束出牌阶段。",
  
  ["#shuangren-ask"] = "双刃：你可与一名角色拼点",
  ["#shuangren_slash-ask"] = "双刃：你视为对与 %src 势力相同的一名角色使用【杀】",

  ["$shuangren1"] = "仲国大将纪灵在此！",
  ["$shuangren2"] = "吃我一记三尖两刃刀！",
  ["~jiling"] = "额，将军为何咆哮不断……",
}

local tianfeng = General(extension, "hs__tianfeng", "qun", 3)

local sijian = fk.CreateTriggerSkill{
  name = "sijian",
  events = {fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self.name) or not player:isKongcheng() then return end
    local ret = false
    for _, move in ipairs(data) do
      if move.from == player.id then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerHand then
            ret = true
            break
          end
        end
      end
    end
    if ret then
      return table.find(player.room.alive_players, function(p) return not p:isNude() end)
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.map(table.filter(room.alive_players, function(p) return not p:isNude() end), Util.IdMapper)
    local target = room:askForChoosePlayers(player, targets, 1, 1, "#sijian-ask", self.name, true)
    if #target > 0 then
      self.cost_data = target[1]
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(self.cost_data)
    local id = room:askForCardChosen(player, to, "he", self.name)
    room:throwCard({id}, self.name, to, player)
  end,
}

local suishi = fk.CreateTriggerSkill{
  name = "suishi",
  frequency = Skill.Compulsory,
  events = {fk.EnterDying, fk.Death},
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self.name) or target == player then return false end
    if event == fk.EnterDying then
      return data.damage and data.damage.from and sameKingdom(data.damage.from, player)
    else
      return sameKingdom(target, player)
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.EnterDying then
      room:notifySkillInvoked(player, self.name, "drawcard")
      room:broadcastSkillInvoke(self.name, 1)
      player:drawCards(1, self.name)
    else
      room:notifySkillInvoked(player, self.name, "negative")
      room:broadcastSkillInvoke(self.name, 2)
      room:loseHp(player, 1, self.name)
    end
  end,
}

tianfeng:addSkill(sijian)
tianfeng:addSkill(suishi)

Fk:loadTranslationTable{
  ["hs__tianfeng"] = "田丰",
  ["sijian"] = "死谏",
	[":sijian"] = "当你失去手牌后，若你没有手牌，你可弃置一名其他角色的一张牌。",
	["suishi"] = "随势",
	[":suishi"] = "锁定技，当其他角色因受到伤害而进入濒死状态时，若来源与你势力相同，你摸一张牌；当其他角色死亡时，若其与你势力相同，你失去1点体力。",

  ["#sijian-ask"] = "死谏：你可弃置一名其他角色的一张牌",
}

-- panfeng

-- zoushi

return extension
