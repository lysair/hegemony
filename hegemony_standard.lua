local extension = Package:new("hegemony_standard")
extension.extensionName = "hegemony"
extension.game_modes_whitelist = { 'nos_heg_mode', 'new_heg_mode' }

local heg_mode = require "packages.hegemony.hegemony"
extension:addGameMode(heg_mode)

local nos_heg_mode = require "packages.hegemony.nos_hegemony"
extension:addGameMode(nos_heg_mode)

local H = require "packages/hegemony/util"

Fk:loadTranslationTable{
  ["hegemony_standard"] = "国战标准版",
  ["hs"] = "国标",
}

local caocao = General(extension, "hs__caocao", "wei", 4)
caocao:addSkill("jianxiong")
caocao:addCompanions({"hs__dianwei", "hs__xuchu"})
Fk:loadTranslationTable{
  ["hs__caocao"] = "曹操",
  ["~hs__caocao"] = "霸业未成，未成啊……",
}

local simayi = General(extension, "hs__simayi", "wei", 3)
simayi:addSkill("fankui")
simayi:addSkill("ex__guicai") -- 手杀
Fk:loadTranslationTable{
  ["hs__simayi"] = "司马懿",
  ["~hs__simayi"] = "我的气数就到这里了吗？",
}

local xiahoudun = General(extension, "hs__xiahoudun", "wei", 4)
xiahoudun:addSkill("ex__ganglie") -- 手杀修改：界刚烈。22按次
xiahoudun:addCompanions("hs__xiahouyuan")
Fk:loadTranslationTable{
  ["hs__xiahoudun"] = "夏侯惇",
  ["~hs__xiahoudun"] = "诸多败绩，有负丞相重托……",
}

local zhangliao = General(extension, "hs__zhangliao", "wei", 4)
zhangliao:addSkill("ex__tuxi") -- 手杀
Fk:loadTranslationTable{
  ["hs__zhangliao"] = "张辽",
  ["~hs__zhangliao"] = "被敌人占了先机……呃……",
}

local xuchu = General(extension, "hs__xuchu", "wei", 4)
xuchu:addSkill("luoyi")
Fk:loadTranslationTable{
  ["hs__xuchu"] = "许褚",
  ["~hs__xuchu"] = "冷，好冷啊……",
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

  ["$hs__yiji1"] = "也好。",
  ["$hs__yiji2"] = "罢了。",
  ["~hs__guojia"] = "咳，咳……",
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
zhenji:addCompanions("hs__caopi")

Fk:loadTranslationTable{
  ["hs__zhenji"] = "甄姬",
  ["hs__luoshen"] = "洛神",
  [":hs__luoshen"] = "准备阶段开始时，你可进行判定，你可重复此流程，直到判定结果为红色，然后你获得所有黑色的判定牌。",

  ["$hs__luoshen1"] = "髣髴兮若轻云之蔽月。",
  ["$hs__luoshen2"] = "飘飖兮若流风之回雪。",
  ["~hs__zhenji"] = "悼良会之永绝兮，哀一逝而异乡。",
}

local xiahouyuan = General(extension, "hs__xiahouyuan", "wei", 4)
xiahouyuan:addSkill("shensu")
Fk:loadTranslationTable{
  ["hs__xiahouyuan"] = "夏侯渊",
  ["~hs__xiahouyuan"] = "竟然比我还…快……",
}

local zhanghe = General(extension, "hs__zhanghe", "wei", 4)
zhanghe:addSkill("qiaobian")
Fk:loadTranslationTable{
  ["hs__zhanghe"] = "张郃",
  ["~hs__zhanghe"] = "呃，膝盖中箭了……",
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

  ["$hs__duanliang1"] = "截其源，断其粮，贼可擒也。",
  ["$hs__duanliang2"] = "人是铁，饭是钢。",
  ["~hs__xuhuang"] = "一顿不吃饿得慌。",
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
    local num = 0
    for _, v in pairs(H.getKingdomPlayersNum(room)) do
      if v and v > 0 then
        num = num + 1
      end
    end
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

  ["$hs__jushou1"] = "我先休息一会儿！",
  ["$hs__jushou2"] = "尽管来吧！",
  ["~hs__caoren"] = "实在是守不住了……",
}

local dianwei = General(extension, "hs__dianwei", "wei", 4)
dianwei:addSkill("qiangxi")
Fk:loadTranslationTable{
  ['hs__dianwei'] = '典韦',
  ["~hs__dianwei"] = "主公，快走！",
}

local xunyu = General(extension, "hs__xunyu", "wei", 3)
xunyu:addSkill("quhu")
xunyu:addSkill("jieming")
Fk:loadTranslationTable{
  ['hs__xunyu'] = '荀彧',
  ["~hs__xunyu"] = "主公要臣死，臣不得不死。",
}

local caopi = General(extension, "hs__caopi", "wei", 3)
local fangzhu = fk.CreateTriggerSkill{
  name = "hs__fangzhu",
  anim_type = "masochism",
  events = {fk.Damaged},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name)
  end,
  on_cost = function(self, event, target, player, data)
    local to = player.room:askForChoosePlayers(player, table.map(player.room:getOtherPlayers(player), function(p)
      return p.id end), 1, 1, "#hs__fangzhu-choose:::"..player:getLostHp(), self.name, true)
    if #to > 0 then
      self.cost_data = to[1]
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(self.cost_data)
    local num = player:getLostHp()
    if to.hp > 0 and #room:askForDiscard(to, 1, 1, true, self.name, true, nil, "hs__fangzhu_ask:::" .. num, false) > 0 then
      if not to.dead then room:loseHp(to, 1, self.name) end
    else
      to:drawCards(num, self.name)
      to:turnOver()
    end
  end,
}

caopi:addSkill("xingshang")
caopi:addSkill(fangzhu)

Fk:loadTranslationTable{
  ['hs__caopi'] = '曹丕',
  ["hs__fangzhu"] = "放逐",
  [":hs__fangzhu"] = "当你受到伤害后，你可令一名其他角色选择一项：1. 摸X张牌并叠置（X为你已损失的体力值）；2. 弃置一张牌并失去1点体力。",

  ["#hs__fangzhu-choose"] = "放逐：你可令一名其他角色选择摸%arg张牌并翻面，或弃置一张牌并失去1点体力",
  ["hs__fangzhu_ask"] = "放逐：弃置一张牌并失去1点体力，或点击“取消”，摸%arg张牌并叠置",

  ["$hs__fangzhu1"] = "死罪可免，活罪难赦！",
  ["$hs__fangzhu2"] = "给我翻过来！",
  ["~hs__caopi"] = "子建，子建……",
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

  ["$hs__xiaoguo1"] = "三军听我号令，不得撤退！",
  ["$hs__xiaoguo2"] = "看我先登城头，立下首功！",
  ["~hs__yuejin"] = "箭疮发作，吾命休矣。",
}

local liubei = General(extension, "hs__liubei", "shu", 4)
liubei:addSkill("ex__rende")
liubei:addCompanions({"hs__guanyu", "hs__zhangfei", "hs__ganfuren"})
Fk:loadTranslationTable{
  ["hs__liubei"] = "刘备",
  ["~hs__liubei"] = "汉室未兴，祖宗未耀，朕实不忍此时西去……",
}

local guanyu = General(extension, "hs__guanyu", "shu", 5)
local wusheng = fk.CreateViewAsSkill{
  name = "hs__wusheng",
  anim_type = "offensive",
  pattern = "slash",
  card_filter = function(self, to_select, selected)
    if #selected == 1 then return false end
    return (H.getHegLord(Fk:currentRoom(), Self) and H.getHegLord(Fk:currentRoom(), Self):hasSkill("shouyue")) or Fk:getCardById(to_select).color == Card.Red
  end,
  view_as = function(self, cards)
    if #cards ~= 1 then
      return nil
    end
    local c = Fk:cloneCard("slash")
    c.skillName = self.name
    c:addSubcard(cards[1])
    return c
  end,
}
guanyu:addSkill(wusheng)
guanyu:addCompanions("hs__zhangfei")
Fk:loadTranslationTable{
  ["hs__guanyu"] = "关羽",
  ["hs__wusheng"] = "武圣",
  [":hs__wusheng"] = "你可将一张红色牌当【杀】使用或打出。",
  ["$hs__wusheng1"] = "关羽在此，尔等受死！",
  ["$hs__wusheng2"] = "看尔乃插标卖首！",
  ["~hs__guanyu"] = "什么？此地名叫麦城？",
}

local zhangfei = General(extension, "hs__zhangfei", "shu", 4)
local paoxiaoTrigger = fk.CreateTriggerSkill{
  name = "#hs__paoxiaoTrigger",
  events = {fk.CardUsing},
  anim_type = "offensive",
  visible = false,
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

  refresh_events = {fk.CardUsing, fk.TargetSpecified, fk.CardUseFinished},
  can_refresh = function(self, event, target, player, data)
    if player ~= target then return false end -- 摆一下
    if event == fk.CardUsing then
      return player:hasSkill(self.name) and data.card.trueName == "slash" and player:usedCardTimes("slash") > 1
    else
      local room = player.room
      if not H.getHegLord(room, player) or not H.getHegLord(room, player):hasSkill("shouyue") then return false end
      if event == fk.CardUseFinished then
        return (data.extra_data or {}).hsPaoxiaoNullifiled
      else
        return data.card.trueName == "slash" and player:hasSkill("hs__paoxiao") and room:getPlayerById(data.to):isAlive()
      end
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    if event == fk.CardUsing then
      player:broadcastSkillInvoke("hs__paoxiao")
      room:doAnimate("InvokeSkill", {
        name = "paoxiao",
        player = player.id,
        skill_type = "offensive",
      })
    elseif event == fk.CardUseFinished then
      for key, num in pairs(data.extra_data.hsPaoxiaoNullifiled) do
        local p = room:getPlayerById(tonumber(key))
        if p:getMark(fk.MarkArmorNullified) > 0 then
          room:removePlayerMark(p, fk.MarkArmorNullified, num)
        end
      end
      data.hsPaoxiaoNullifiled = nil
    else
      room:addPlayerMark(room:getPlayerById(data.to), fk.MarkArmorNullified)
      data.extra_data = data.extra_data or {}
      data.extra_data.hsPaoxiaoNullifiled = data.extra_data.hsPaoxiaoNullifiled or {}
      data.extra_data.hsPaoxiaoNullifiled[tostring(data.to)] = (data.extra_data.hsPaoxiaoNullifiled[tostring(data.to)] or 0) + 1
    end
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
  ["$hs__paoxiao1"] = "啊~~~",
  ["$hs__paoxiao2"] = "燕人张飞在此！",
  ["~hs__zhangfei"] = "实在是杀不动了……",
}

local zhugeliang = General(extension, "hs__zhugeliang", "shu", 3)
local guanxing = fk.CreateTriggerSkill{
  name = "hs__guanxing",
  anim_type = "control",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and
      player.phase == Player.Start
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local num = (H.inGeneralSkills(player, self.name) == "m" and H.hasShownSkill(player, "yizhi")) and 5 or math.min(5, #room.alive_players)
    room:askForGuanxing(player, room:getNCards(num))
  end,
}
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
  on_use = function(self, event, target, player, data)
    local room = player.room
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

zhugeliang:addSkill(guanxing)
zhugeliang:addSkill(kongcheng)
zhugeliang:addCompanions("hs__huangyueying")

Fk:loadTranslationTable{
  ["hs__zhugeliang"] = "诸葛亮",
  ["hs__guanxing"] = "观星",
  [":hs__guanxing"] = "准备阶段开始时，你可将牌堆顶的X张牌（X为角色数且至多为5}）扣置入处理区（对你可见），你将其中任意数量的牌置于牌堆顶，将其余的牌置于牌堆底。",
  ["hs__kongcheng"] = "空城",
  [":hs__kongcheng"] = "锁定技，若你没有手牌：1. 当你成为【杀】或【决斗】的目标时，取消之；"..
    "2. 你的回合外，当牌因交给而移至你的手牌区前，你将此次移动的目标区域改为你的武将牌上（均称为“琴”），摸牌阶段开始时，你获得所有“琴”。",

  ["zither"] = "琴",

  ["$hs__guanxing1"] = "观今夜天象，知天下大事。",
  ["$hs__guanxing2"] = "知天易，逆天难。",
  ["$hs__kongcheng1"] = "（抚琴声）",
  ["$hs__kongcheng2"] = "（抚琴声）",
  ["~hs__zhugeliang"] = "将星陨落，天命难违。",
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
  visible = false,
  events = {fk.CardEffectCancelledOut, fk.CardUsing, fk.CardResponding},
  can_trigger = function(self, event, target, player, data)
    if event == fk.CardEffectCancelledOut then
      if data.card.trueName ~= "slash" then return false end
      if target == player then -- 龙胆杀
        return table.contains(data.card.skillNames, "hs__longdan")
      elseif data.to == player.id then -- 龙胆闪
        for _, card in ipairs(data.cardsResponded) do
          if card.name == "jink" and table.contains(card.skillNames, "hs__longdan") then
            return true
          end
        end
      end
    else
      local room = player.room
      return player == target and H.getHegLord(room, player) and table.contains(data.card.skillNames, "hs__longdan") and H.getHegLord(room, player):hasSkill("shouyue")
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if event == fk.CardEffectCancelledOut then
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
    else
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(self.cost_data)
    if event == fk.CardEffectCancelledOut then
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
    else
      player:drawCards(1, self.name)
    end
  end,
}

longdan:addRelatedSkill(longdan_after)
zhaoyun:addSkill(longdan)
zhaoyun:addCompanions("hs__liushan")

Fk:loadTranslationTable{
  ["hs__zhaoyun"] = "赵云",
  ["hs__longdan"] = "龙胆",
  [":hs__longdan"] = "你可将【闪】当【杀】使用或打出，当此【杀】被一名角色使用的【闪】抵消后，你可对另一名角色造成1点伤害。你可将【杀】当【闪】使用或打出，当一名角色使用的【杀】被此【闪】抵消后，你可令另一名其他角色回复1点体力。",

  ["#longdan_after"] = "龙胆",
  ["#longdan_slash-ask"] = "龙胆：你可对 %dest 以外的一名角色造成1点伤害",
  ["#longdan_jink-ask"] = "龙胆：你可令 %dest 以外的一名其他角色回复1点体力",

  ["$hs__longdan1"] = "能进能退，乃真正法器！",
  ["$hs__longdan2"] = "吾乃常山赵子龙也！",
  ["~hs__zhaoyun"] = "这，就是失败的滋味吗？",
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
      local choice
      if H.getHegLord(room, player) and #choices > 1 and H.getHegLord(room, player):hasSkill("shouyue") then
        choice = choices
      else
        choice = {room:askForChoice(player, choices, self.name, "#hs__tieqi-ask::" .. to.id)}
      end
      local record = type(to:getMark("@hs__tieqi-turn")) == "table" and to:getMark("@hs__tieqi-turn") or {}
      for _, c in ipairs(choice) do
        table.insertIfNeed(record, c)
        room:setPlayerMark(to, "@hs__tieqi-turn", record)
        local mark = type(to:getMark("_hs__tieqi-turn")) == "table" and to:getMark("_hs__tieqi-turn") or {}
        for _, skill_name in ipairs(Fk.generals[c]:getSkillNameList()) do
          if Fk.skills[skill_name].frequency ~= Skill.Compulsory then
            table.insertIfNeed(mark, skill_name)
          end
        end
        room:setPlayerMark(to, "_hs__tieqi-turn", mark)
      end
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
  ["$hs__tieqi1"] = "目标敌阵，全军突击！",
  ["$hs__tieqi2"] = "敌人阵型已乱，随我杀！",
  ["~hs__machao"] = "请将我，葬在西凉……",
}

local huangyueying = General(extension, "hs__huangyueying", "shu", 3, 3, General.Female)
huangyueying:addSkill("jizhi")
huangyueying:addSkill("qicai")
huangyueying:addCompanions("hs__wolong")

Fk:loadTranslationTable{
  ["hs__huangyueying"] = "黄月英",
  ["hs__jizhi"] = "集智",
  [":hs__jizhi"] = "当你使用非转化的普通锦囊牌时，你可摸一张牌。",

  ["~hs__huangyueying"] = "亮……",
}

local huangzhong = General(extension, "hs__huangzhong", "shu", 4)
local liegong = fk.CreateTriggerSkill{
  name = "hs__liegong",
  anim_type = "offensive",
  events = {fk.TargetSpecified},
  can_trigger = function(self, event, target, player, data)
    if not (target == player and player:hasSkill(self.name)) then return end
    local room = player.room
    local to = room:getPlayerById(data.to)
    local num = #to:getCardIds(Player.Hand)
    local filter = num <= player:getAttackRange() or num >= player.hp
    return data.card.trueName == "slash" and filter and player.phase == Player.Play
  end,
  on_use = function(self, event, target, player, data)
    data.disresponsiveList = data.disresponsiveList or {}
    table.insert(data.disresponsiveList, data.to)
  end,
}
local liegongAR = fk.CreateAttackRangeSkill{
  name = "#hs__liegongAR",
  correct_func = function(self, from, to)
    if from:hasSkill("hs__liegong") then
      for _, p in ipairs(Fk:currentRoom().alive_players) do
        if string.find(p.general, "lord") and p:hasSkill("shouyue") and p.kingdom == from.kingdom then
          return 1
        end
      end
    end
    return 0
  end,
}
liegong:addRelatedSkill(liegongAR)
huangzhong:addSkill(liegong)
huangzhong:addCompanions("hs__weiyan")
Fk:loadTranslationTable{
  ["hs__huangzhong"] = "黄忠",
  ["hs__liegong"] = "烈弓",
  [":hs__liegong"] = "当你于出牌阶段内使用【杀】指定目标后，若其手牌数不小于你的体力值或不大于你的攻击范围，你可令其不能使用【闪】响应此【杀】。",
  ["$hs__liegong1"] = "百步穿杨！",
  ["$hs__liegong2"] = "中！",
  ["~hs__huangzhong"] = "不得不服老了……",
}

local weiyan = General(extension, "hs__weiyan", "shu", 4)
local kuanggu = fk.CreateTriggerSkill{
  name = "hs__kuanggu",
  anim_type = "drawcard",
  events = {fk.Damage},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self.name) and target == player and (data.extra_data or {}).kuanggucheck
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
    return data.damageEvent and player == data.damageEvent.from and player:distanceTo(target) < 2 and player:distanceTo(target) > -1
  end,
  on_refresh = function(self, event, target, player, data)
    data.damageEvent.extra_data = data.damageEvent.extra_data or {}
    data.damageEvent.extra_data.kuanggucheck = true
  end,
}

weiyan:addSkill(kuanggu)

Fk:loadTranslationTable{
  ["hs__weiyan"] = "魏延",
  ["hs__kuanggu"] = "狂骨",
  [":hs__kuanggu"] = "当你对距离1以内的角色造成1点伤害后，你可摸一张牌或回复1点体力。",
  ["draw1"] = "摸一张牌",
  ["recover"] = "回复1点体力",

  ["$hs__kuanggu1"] = "哈哈哈哈哈哈，赢你还不容易？",
  ["$hs__kuanggu2"] = "哼！也不看看我是何人！",
  ["~hs__weiyan"] = "奸贼……害我……",
}

local pangtong = General(extension, "hs__pangtong", "shu",3)
pangtong:addSkill("lianhuan")
pangtong:addSkill("niepan")
pangtong:addCompanions("hs__wolong")
Fk:loadTranslationTable{
  ['hs__pangtong'] = '庞统',
}

local wolong = General(extension, "hs__wolong", "shu", 3)
wolong:addSkill("bazhen")
wolong:addSkill("huoji")
wolong:addSkill("kanpo")
Fk:loadTranslationTable{
  ['hs__wolong'] = '卧龙诸葛亮',
  ["~hs__wolong"] = "我的计谋竟被……",
}

local liushan = General(extension, "hs__liushan", "shu", 3)
liushan:addSkill("xiangle")
liushan:addSkill("fangquan")
Fk:loadTranslationTable{
  ['hs__liushan'] = '刘禅',
  ["~hs__liushan"] = "别打脸，我投降还不行吗？",
}

local menghuo = General(extension, "hs__menghuo", "shu", 4)
menghuo:addCompanions("hs__zhurong")
menghuo:addSkill("huoshou")
menghuo:addSkill("zaiqi")
Fk:loadTranslationTable{
  ['hs__menghuo'] = '孟获',
}

local zhurong = General(extension, "hs__zhurong", "shu", 4, 4, General.Female)
zhurong:addSkill("juxiang")
zhurong:addSkill("lieren")
Fk:loadTranslationTable{
  ['hs__zhurong'] = '祝融',
  ["~hs__zhurong"] = "大王，我，先走一步了。",
}

local ganfuren = General(extension, "hs__ganfuren", "shu", 3, 3, General.Female)
local shushen = fk.CreateTriggerSkill{
  name = "hs__shushen",
  anim_type = "support",
  events = {fk.HpRecover},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name)
  end,
  on_trigger = function(self, event, target, player, data)
    self.cancel_cost = false
    for i = 1, data.num do
      if self.cancel_cost then break end
      self:doCost(event, target, player, data)
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local to = room:askForChoosePlayers(player, table.map(room:getOtherPlayers(player),
      function(p) return p.id end), 1, 1, "#hs__shushen-choose", self.name, true)
    if #to > 0 then
      self.cost_data = to[1]
      return true
    end
    self.cancel_cost = true
  end,
  on_use = function(self, event, target, player, data)
    player.room:getPlayerById(self.cost_data):drawCards(1, self.name)
  end,
}

ganfuren:addSkill(shushen)
ganfuren:addSkill("shenzhi")

Fk:loadTranslationTable{
  ['hs__ganfuren'] = '甘夫人',
  ["hs__shushen"] = "淑慎",
  [":hs__shushen"] = "当你回复1点体力后，你可令一名其他角色摸一张牌。",

  ["#hs__shushen-choose"] = "淑慎：你可令一名其他角色摸一张牌",

  ["$hs__shushen1"] = "船到桥头自然直。",
  ["$hs__shushen2"] = "妾身无恙，相公请安心征战。",
  ["~hs__ganfuren"] = "请替我照顾好阿斗……",
}

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
    return table.find(Self:getEquipments(Card.SubtypeTreasure), function(cid)
      return Fk:getCardById(cid).name == "luminous_pearl"
    end) and 998 or Self.maxHp
  end,
  card_filter = function(self, to_select, selected)
    if #selected >= Self.maxHp then
      return table.find(Self:getEquipments(Card.SubtypeTreasure), function(cid)
        return Fk:getCardById(cid).name == "luminous_pearl" and not table.contains(selected, cid) and to_select ~= cid
      end)
    end
    return #selected < Self.maxHp and not Self:prohibitDiscard(to_select)
  end,
  on_use = function(self, room, effect)
    local from = room:getPlayerById(effect.from)
    room:throwCard(effect.cards, self.name, from, from)
    if not from.dead then
      from:drawCards(#effect.cards, self.name)
    end
  end
}

sunquan:addSkill(zhiheng)
sunquan:addCompanions("hs__zhoutai")

Fk:loadTranslationTable{
  ["hs__sunquan"] = "孙权",
  ["hs__zhiheng"] = "制衡",
  [":hs__zhiheng"] = "出牌阶段限一次，你可弃置至多X张牌（X为你的体力上限），然后你摸等量的牌。",

  ["$hs__zhiheng1"] = "容我三思。",
  ["$hs__zhiheng2"] = "且慢。",
  ["~hs__sunquan"] = "父亲，大哥，仲谋愧矣……",
}

local ganning = General(extension, "hs__ganning", "wu", 4)

ganning:addSkill("qixi")

Fk:loadTranslationTable{
  ["hs__ganning"] = "甘宁",
  ["~hs__ganning"] = "二十年后，又是一条好汉！",
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

  ["$hs__keji1"] = "谨慎为妙。",
  ["$hs__keji2"] = "时机未到。",
  ["$hs__mouduan1"] = "今日起兵，渡江攻敌！",
  ["$hs__mouduan2"] = "时机已到，全军出击！。",
  ["~hs__lvmeng"] = "种下恶因，必有恶果。",
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
huanggai:addCompanions("hs__zhouyu")

Fk:loadTranslationTable{
  ["hs__huanggai"] = "黄盖",
  ["hs__kurou"] = "苦肉",
  [":hs__kurou"] = "出牌阶段限一次，你可弃置一张牌，然后你失去1点体力，摸三张牌，于此阶段内使用【杀】的次数上限+1。",

  ["$hs__kurou1"] = "我这把老骨头，不算什么！",
  ["$hs__kurou2"] = "为成大业，死不足惜！",
  ["~hs__huanggai"] = "盖，有负公瑾重托……",
}

local zhouyu = General(extension, "hs__zhouyu", "wu", 3)
zhouyu:addSkill("ex__yingzi")
zhouyu:addSkill("ex__fanjian")
zhouyu:addCompanions("hs__xiaoqiao")
Fk:loadTranslationTable{
  ["hs__zhouyu"] = "周瑜",
  ["~hs__zhouyu"] = "既生瑜，何生亮。既生瑜，何生亮！",
}

local daqiao = General(extension, "hs__daqiao", "wu", 3, 3, General.Female)

daqiao:addSkill("guose")
daqiao:addSkill("liuli")
daqiao:addCompanions("hs__xiaoqiao")

Fk:loadTranslationTable{
  ["hs__daqiao"] = "大乔",
  ["~hs__daqiao"] = "伯符，我去了……",
}

local luxun = General(extension, "hs__luxun", "wu", 3)

local qianxun = fk.CreateTriggerSkill{
  name = "hs__qianxun",
  anim_type = "defensive",
  events = {fk.TargetConfirming, fk.BeforeCardsMove},
  frequency = Skill.Compulsory,
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self.name) then return false end
    if event == fk.TargetConfirming then
      return target == player and player:hasSkill(self.name) and data.card.name == "snatch"
    elseif event == fk.BeforeCardsMove then
      local id = 0
      local source = player
      local room = player.room
      local c
      for _, move in ipairs(data) do
        if move.to == player.id and move.toArea == Card.PlayerJudge then
          for _, info in ipairs(move.moveInfo) do
            id = info.cardId
            if info.fromArea == Card.PlayerJudge then
              source = room:getPlayerById(move.from) or player
            else
              source = player
            end
            c = source:getVirualEquip(id)
            --FIXME：巨大隐患，延时锦囊的virtual_equips在置入判定区的事件被篡改，或者判定阶段自然流程以外的方式离开判定区时不会清理
            if not c then c = Fk:getCardById(id) end
            if c.trueName == "indulgence" then
              return true
            end
          end
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:notifySkillInvoked(player, self.name)
    if event == fk.TargetConfirming then
      player:broadcastSkillInvoke(self.name, 2)
      AimGroup:cancelTarget(data, player.id)
    elseif event == fk.BeforeCardsMove then
      player:broadcastSkillInvoke(self.name, 1)
      local source = player
      local mirror_moves = {}
      local ids = {}
      for _, move in ipairs(data) do
        if move.to == player.id and move.toArea == Card.PlayerJudge then
          local move_info = {}
          local mirror_info = {}
          for _, info in ipairs(move.moveInfo) do
            local id = info.cardId
            if info.fromArea == Card.PlayerJudge then
              source = room:getPlayerById(move.from) or player
            else
              source = player
            end
            local c = source:getVirualEquip(id)
            if not c then c = Fk:getCardById(id) end
            if c.trueName == "indulgence" then
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
            mirror_move.toArea = Card.DiscardPile
            mirror_move.moveInfo = mirror_info
            table.insert(mirror_moves, mirror_move)
          end
        end
      end
      table.insertTable(data, mirror_moves)
    end
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

  ["$qianxun1"] = "儒生脱尘，不为贪逸淫乐之事。",
  ["$qianxun2"] = "谦谦君子，不饮盗泉之水。",
  ["$duoshi2"] = "以今日之大势当行此计。",
  ["$duoshi1"] = "国之大计审视为先。",
  ["~luxun"] = "还以为我已经不再年轻……",
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

  ["$hs__xiaoji1"] = "哼！",
  ["$hs__xiaoji2"] = "看我的厉害！",
  ["~hs__sunshangxiang"] = "不！还不可以死！",
}

local sunjian = General(extension, "hs__sunjian", "wu", 5)
sunjian:addSkill("yinghun")
Fk:loadTranslationTable{
  ['hs__sunjian'] = '孙坚',
  ["~hs__sunjian"] = "有埋伏！呃……啊！！",
}

local xiaoqiao = General(extension, "hs__xiaoqiao", "wu", 3, 3, General.Female)
local tianxiang = fk.CreateTriggerSkill{
  name = "hs__tianxiang",
  anim_type = "defensive",
  events = {fk.DamageInflicted},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self.name) and target == player
  end,
  on_cost = function(self, event, target, player, data)
    local tar, card =  player.room:askForChooseCardAndPlayers(player, table.map(player.room:getOtherPlayers(player), function (p)
      return p.id end), 1, 1, ".|.|heart|hand", "#hs__tianxiang-choose", self.name, true)
    if #tar > 0 and card then
      self.cost_data = {tar[1], card}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(self.cost_data[1])
    local cid = self.cost_data[2]
    room:throwCard(cid, self.name, player, player)

    if to.dead then return true end

    local choices = {"hs__tianxiang_loseHp"}
    if data.from and not data.from.dead then
      table.insert(choices, "hs__tianxiang_damage")
    end
    local choice = room:askForChoice(player, choices, self.name, "#hs__tianxiang-choice::"..to.id)
    if choice == "hs__tianxiang_loseHp" then
      room:loseHp(to, 1, self.name)
      if not to.dead and (room:getCardArea(cid) == Card.DrawPile or room:getCardArea(cid) == Card.DiscardPile) then
        room:obtainCard(to, cid, true, fk.ReasonJustMove)
      end
    else
      room:damage{
        from = data.from,
        to = to,
        damage = 1,
        skillName = self.name,
      }
      if not to.dead then
        to:drawCards(math.min(to:getLostHp(), 5), self.name)
      end
    end
    return true
  end,
}

xiaoqiao:addSkill(tianxiang)
xiaoqiao:addSkill("hongyan")

Fk:loadTranslationTable{
  ['hs__xiaoqiao'] = '小乔',
  ["hs__tianxiang"] = "天香",
  [":hs__tianxiang"] = "当你受到伤害时，你可弃置一张<font color='red'>♥</font>手牌并选择一名其他角色。你防止此伤害，选择：1.令来源对其造成1点伤害，其摸X张牌（X为其已损失的体力值且至多为5）；2.令其失去1点体力，其获得牌堆或弃牌堆中你以此法弃置的牌。",

  ["#hs__tianxiang-choose"] = "天香：弃置一张<font color='red'>♥</font>手牌并选择一名其他角色",
  ["#hs__tianxiang-choice"] = "天香：选择一项令 %dest 执行",
  ["hs__tianxiang_damage"] = "令其受到1点伤害并摸已损失体力值的牌",
  ["hs__tianxiang_loseHp"] = "令其失去1点体力并获得你弃置的牌",

  ["$hs__tianxiang1"] = "接着哦~",
  ["$hs__tianxiang2"] = "替我挡着~",
  ["~hs__xiaoqiao"] = "公瑾…我先走一步……",
}

local taishici = General(extension, "hs__taishici", "wu", 4)
taishici:addSkill("tianyi")
Fk:loadTranslationTable{
  ['hs__taishici'] = '太史慈',
  ["~hs__taishici"] = "大丈夫，当带三尺之剑，立不世之功！",
}

local zhoutai = General(extension, "hs__zhoutai", "wu", 4)
local buqu = fk.CreateTriggerSkill{
  name = "hs__buqu",
  anim_type = "defensive",
  events = {fk.AskForPeaches},
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and player.dying
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local scar_id =room:getNCards(1)[1]
    local scar = Fk:getCardById(scar_id)
    player:addToPile("hs__buqu_scar", scar_id, true, self.name)
    if player.dead or not table.contains(player:getPile("hs__buqu_scar"), scar_id) then return false end
    local success = true
    for _, id in pairs(player:getPile("hs__buqu_scar")) do
      if id ~= scar_id then
        local card = Fk:getCardById(id)
        if (card.number == scar.number) then
          success = false
          break
        end
      end
    end
    if success then
      room:recover({
        who = player,
        num = 1 - player.hp,
        recoverBy = player,
        skillName = self.name
      })
    else
      room:throwCard(scar:getEffectiveId(), self.name, player) 
    end
  end,
}
H.CreateClearSkill(buqu, "hs__buqu_scar")

local fenji = fk.CreateTriggerSkill{
  name = "hs__fenji",
  anim_type = "support",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self.name) and target.phase == Player.Finish and target:isKongcheng()
  end,
  on_use = function(self, event, target, player, data)
    target:drawCards(2, self.name)
    if not player.dead then player.room:loseHp(player, 1, self.name) end
  end,
}

zhoutai:addSkill(buqu)
zhoutai:addSkill(fenji)

Fk:loadTranslationTable{
  ['hs__zhoutai'] = '周泰',
  ["hs__buqu"] = "不屈",
  [":hs__buqu"] = "锁定技，当你处于濒死状态时，你将牌堆顶的一张牌置于你的武将牌上，称为“创”，若此牌的点数与已有的“创”点数均不同，则你将体力回复至1点。若出现相同点数则将此牌置入弃牌堆。",
  ["hs__fenji"] = "奋激",
  [":hs__fenji"] = "一名角色的结束阶段开始时，若其没有手牌，你可令其摸两张牌，然后你失去1点体力。",

  ["hs__buqu_scar"] = "创",

  ["$hs__buqu1"] = "战如熊虎，不惜躯命！",
  ["$hs__buqu2"] = "哼，这点小伤算什么！",
  ["$hs__fenji1"] = "百战之身，奋勇驱前！",
  ["$hs__fenji2"] = "两肋插刀，愿赴此躯！",
  ["~hs__zhoutai"] = "敌众我寡，无力回天……",
}

local lusu = General(extension, "hs__lusu", "wu", 3)
lusu:addSkill("haoshi")
lusu:addSkill("dimeng")
Fk:loadTranslationTable{
  ['hs__lusu'] = '鲁肃',
  ["~hs__lusu"] = "此联盟已破，吴蜀休矣。",
}

local erzhang = General(extension, "hs__zhangzhaozhanghong", "wu", 3)
erzhang:addSkill("zhijian")
erzhang:addSkill("guzheng")
Fk:loadTranslationTable{
  ['hs__zhangzhaozhanghong'] = '张昭张纮',
  ["~hs__zhangzhaozhanghong"] = "竭力尽智，死而无憾。",
}

local dingfeng = General(extension, "hs__dingfeng", "wu", 4)
dingfeng:addSkill("duanbing")
dingfeng:addSkill("fenxun")
Fk:loadTranslationTable{
  ["hs__dingfeng"] = "丁奉",
  ["$duanbing1"] = "众将官，短刀出鞘。",
  ["$duanbing2"] = "短兵轻甲也可取汝性命！",
  ["$fenxun1"] = "取封侯爵赏，正在今日！",
  ["$fenxun2"] = "给我拉过来！",
  ["~hs__dingfeng"] = "这风，太冷了……",
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
      table.every(selected, function(id) return not H.compareKingdomWith(target, room:getPlayerById(id)) end)
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

  ["$jijiu_hs__huatuo1"] = "救死扶伤，悬壶济世。",
  ["$jijiu_hs__huatuo2"] = "妙手仁心，药到病除。",
  ["$hs__chuli1"] = "病去，如抽丝。",
  ["$hs__chuli2"] = "病入膏肓，需下猛药。",
  ["~hs__huatuo"] = "生老病死，命不可违。",
}

local lvbu = General(extension, "hs__lvbu", "qun", 5)

lvbu:addSkill("wushuang")
lvbu:addCompanions("hs__diaochan")

Fk:loadTranslationTable{
  ["hs__lvbu"] = "吕布",
  ["~hs__lvbu"] = "不可能！",
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

  ["$hs__lijian1"] = "嗯呵呵~~呵呵~~",
  ["$hs__lijian2"] = "夫君，你要替妾身做主啊……",
  ["~hs__diaochan"] = "父亲大人，对不起……",
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
  visible = false,
  events = {fk.CardRespondFinished},
  can_trigger = function(self, event, target, player, data)
    if target ~= player or data.card.name ~= "jink" or player.dead then return false end
    if data.responseToEvent and table.contains(data.responseToEvent.card.skillNames, "hs__luanji") then
      local yuanshao = data.responseToEvent.from
      if yuanshao and H.compareKingdomWith(player, player.room:getPlayerById(yuanshao)) then
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
yuanshao:addCompanions("hs__yanliangwenchou")

Fk:loadTranslationTable{
  ["hs__yuanshao"] = "袁绍",
  ["hs__luanji"] = "乱击",
  [":hs__luanji"] = "你可将两张手牌当【万箭齐发】使用（不能使用此回合以此法使用过的花色），与你势力相同的角色打出【闪】响应此牌结算结束后，其可摸一张牌。",

  ["@hs__luanji-turn"] = "乱击",
  ["#hs__luanji-draw"] = "乱击：你可摸一张牌",
  ["#hs__luanji_draw"] = "乱击",

  ["$hs__luanji1"] = "弓箭手，准备放箭！",
  ["$hs__luanji2"] = "全都去死吧！",
  ["~hs__yuanshao"] = "老天不助我袁家啊！",
}

local sx = General(extension, 'hs__yanliangwenchou', 'qun', 4)
sx:addSkill('shuangxiong')
Fk:loadTranslationTable{
  ['hs__yanliangwenchou'] = '颜良文丑',
  ["~hs__yanliangwenchou"] = "这红脸长须大将是……",
}

local jiaxu = General(extension, 'hs__jiaxu', 'qun', 3)
jiaxu:addSkill('wansha')
jiaxu:addSkill('luanwu')
local weimu = fk.CreateTriggerSkill{
  name = "hs__weimu",
  anim_type = "defensive",
  events = { fk.TargetConfirming, fk.BeforeCardsMove },
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self.name) then return false end
    if event == fk.TargetConfirming then
      return target == player and data.card.color == Card.Black and data.card:isCommonTrick()
    elseif event == fk.BeforeCardsMove then
      local id = 0
      local source = player
      local room = player.room
      local c
      for _, move in ipairs(data) do
        if move.to == player.id and move.toArea == Card.PlayerJudge then
          for _, info in ipairs(move.moveInfo) do
            id = info.cardId
            if info.fromArea == Card.PlayerJudge then
              source = room:getPlayerById(move.from) or player
            else
              source = player
            end
            c = source:getVirualEquip(id)
            --FIXME：巨大隐患，延时锦囊的virtual_equips在置入判定区的事件被篡改，或者判定阶段自然流程以外的方式离开判定区时不会清理
            if not c then c = Fk:getCardById(id) end
            if c.sub_type == Card.SubtypeDelayedTrick and c.color == Card.Black then
              return true
            end
          end
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.TargetConfirming then
      AimGroup:cancelTarget(data, player.id)
    elseif event == fk.BeforeCardsMove then
      local source = player
      local mirror_moves = {}
      local ids = {}
      for _, move in ipairs(data) do
        if move.to == player.id and move.toArea == Card.PlayerJudge then
          local move_info = {}
          local mirror_info = {}
          for _, info in ipairs(move.moveInfo) do
            local id = info.cardId
            if info.fromArea == Card.PlayerJudge then
              source = room:getPlayerById(move.from) or player
            else
              source = player
            end
            local c = source:getVirualEquip(id)
            if not c then c = Fk:getCardById(id) end
            if c.sub_type == Card.SubtypeDelayedTrick and c.color == Card.Black then
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
            mirror_move.toArea = Card.DiscardPile
            mirror_move.moveInfo = mirror_info
            table.insert(mirror_moves, mirror_move)
          end
        end
      end
      table.insertTable(data, mirror_moves)
    end
  end
}

jiaxu:addSkill(weimu)
Fk:loadTranslationTable{
  ['hs__jiaxu'] = '贾诩',
  ['hs__weimu'] = '帷幕',
  [':hs__weimu'] = '锁定技，当你成为黑色锦囊牌目标后，取消之。',

  ["$hs__weimu1"] = "此计伤不到我。",
  ["$hs__weimu2"] = "你奈我何！",
  ["~hs__jiaxu"] = "我的时辰也到了……",
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

  ["$jianchu1"] = "你，可敢挡我！",
  ["$jianchu2"] = "我要杀你们个片甲不留！",
  ["~hs__pangde"] = "四面都是水……我命休矣。",
}

local zhangjiao = General(extension, "hs__zhangjiao", 'qun', 3)
zhangjiao:addSkill("leiji")
zhangjiao:addSkill("guidao")
Fk:loadTranslationTable{
  ['hs__zhangjiao'] = '张角',
  ["~hs__zhangjiao"] = "黄天…也死了……",
}

local caiwenji = General(extension, "hs__caiwenji", "qun", 3, 3, General.Female)
local duanchang = fk.CreateTriggerSkill{
  name = "hs__duanchang",
  anim_type = "control",
  frequency = Skill.Compulsory,
  events = {fk.Death},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name, false, true) and data.damage and data.damage.from and not data.damage.from.dead
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = data.damage.from ---@type ServerPlayer
    local choices = {}
    if not to.general:startsWith("blank_") then
      table.insert(choices, to.general ~= "anjiang" and to.general or "mainGeneral")
    end
    if not to.deputyGeneral:startsWith("blank_") then
      table.insert(choices, to.deputyGeneral ~= "anjiang" and to.deputyGeneral or "deputyGeneral")
    end
    if #choices == 0 then return false end
    local choice = room:askForChoice(player, choices, self.name, "#hs__duanchang-ask::" .. to.id)
    local record = type(to:getMark("@hs__duanchang")) == "table" and to:getMark("@hs__duanchang") or {}
    table.insert(record, choice)
    room:setPlayerMark(to, "@hs__duanchang", record)
    local _g = (choice == "mainGeneral" or choice == to.general) and to.general or to.deputyGeneral
    if _g ~= "anjiang" then
      local skills = {}
      for _, skill_name in ipairs(Fk.generals[_g]:getSkillNameList(true)) do
        table.insertIfNeed(skills, skill_name)
      end
      if #skills > 0 then
        room:handleAddLoseSkills(to, "-"..table.concat(skills, "|-"), nil, true, false)
      end
    else
      _g = choice == "mainGeneral" and to:getMark("__heg_general") or to:getMark("__heg_deputy")
      local general = Fk.generals[_g]
      for _, s in ipairs(general:getSkillNameList()) do
        local skill = Fk.skills[s]
        to:loseFakeSkill(skill)
      end
      local record = type(to:getMark("_hs__duanchang_anjiang")) == "table" and to:getMark("_hs__duanchang_anjiang") or {}
      table.insert(record, _g)
      room:setPlayerMark(to, "_hs__duanchang_anjiang", record)
    end
  end,

  refresh_events = {fk.GeneralRevealed},
  can_refresh = function(self, event, target, player, data)
    return target == player and type(player:getMark("_hs__duanchang_anjiang")) == "table" and table.contains(player:getMark("_hs__duanchang_anjiang"), data)
  end,
  on_refresh = function(self, event, target, player, data)
    local skills = {}
    for _, skill_name in ipairs(Fk.generals[data]:getSkillNameList(true)) do
      table.insertIfNeed(skills, skill_name)
    end
    if #skills > 0 then
      player.room:handleAddLoseSkills(player, "-"..table.concat(skills, "|-"), nil, true, false)
    end
  end,
}
caiwenji:addSkill("beige")
caiwenji:addSkill(duanchang)
Fk:loadTranslationTable{
  ["hs__caiwenji"] = "蔡文姬",
  ["hs__duanchang"] = "断肠",
  [":hs__duanchang"] = "锁定技，当你死亡时，你令杀死你的角色失去一张武将牌上的所有技能。",

  ["#hs__duanchang-ask"] = "断肠：令 %dest 失去一张武将牌上的所有技能",
  ["@hs__duanchang"] = "断肠",

  ["$hs__duanchang1"] = "流落异乡愁断肠。",
  ["$hs__duanchang2"] = "日东月西兮徒相望，不得相随兮空断肠。",
  ["~hs__caiwenji"] = "人生几何时，怀忧终年岁。",
}

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
    local targets = table.map(table.filter(room.alive_players, function(p) return H.compareKingdomWith(p, player) end), Util.IdMapper)
    room:sortPlayersByAction(targets)
    for _, p in ipairs(targets) do
      p = room:getPlayerById(p)
      if not p.dead then
        p:drawCards(3, self.name)
      end
    end
    if player.dead or player.kingdom == "unknown" then return false end
    local kingdomMapper = H.getKingdomPlayersNum(room)
    local num = kingdomMapper[H.getKingdom(player)]
    for _, n in pairs(kingdomMapper) do
      if n < num then return false end
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

local mateng_mashu = fk.CreateDistanceSkill{
  name = "heg_mateng__mashu",
  frequency = Skill.Compulsory,
  correct_func = function(self, from, to)
    if from:hasSkill(self.name) then
      return -1
    end
  end,
}
mateng:addSkill(mateng_mashu)
mateng:addSkill(xiongyi)

Fk:loadTranslationTable{
  ["hs__mateng"] = "马腾",
  ["xiongyi"] = "雄异",
  [":xiongyi"] = "限定技，出牌阶段，你可令与你势力相同的所有角色各摸三张牌，然后若你的势力是角色数最小的势力，你回复1点体力。",
  ["heg_mateng__mashu"] = "马术",
  [":heg_mateng__mashu"] = "锁定技，你与其他角色的距离-1。",

  ["$xiongyi1"] = "弟兄们，我们的机会来啦！",
  ["$xiongyi2"] = "此时不战，更待何时！",
  ["~hs__mateng"] = "儿子，为爹报仇啊！",
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
  ["#lirang_active"] = "礼让",

  ["$mingshi1"] = "孔门之后，忠孝为先。",
  ["$mingshi2"] = "名士之风，仁义高洁。",
  ["$lirang1"] = "夫礼先王以承天之道，以治人之情。",
  ["$lirang2"] = "谦者，德之柄也，让者，礼之逐也。",
  ["~kongrong"] = "覆巢之下，岂有完卵……",
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
          return H.compareKingdomWith(p, target) and not player:isProhibited(p, slash)
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
      -- player:endPlayPhase()
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
  ["~hs__jiling"] = "额，将军为何咆哮不断……",
}

local tianfeng = General(extension, "hs__tianfeng", "qun", 3)

local sijian = fk.CreateTriggerSkill{
  name = "sijian",
  events = {fk.AfterCardsMove},
  anim_type = "control",
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
      return data.damage and data.damage.from and H.compareKingdomWith(data.damage.from, player)
    else
      return H.compareKingdomWith(target, player)
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.EnterDying then
      room:notifySkillInvoked(player, self.name, "drawcard")
      player:broadcastSkillInvoke(self.name, 1)
      player:drawCards(1, self.name)
    else
      room:notifySkillInvoked(player, self.name, "negative")
      player:broadcastSkillInvoke(self.name, 2)
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

  ["$sijian2"] = "忠言逆耳啊！！",
  ["$sijian1"] = "且听我最后一言！",
  ["$suishi1"] = "一荣俱荣！",
  ["$suishi2"] = "一损俱损……",
  ["~hs__tianfeng"] = "不纳吾言而反诛吾心，奈何奈何！！",
}

local panfeng = General(extension, "hs__panfeng", "qun", 4)
panfeng:addSkill("kuangfu")
Fk:loadTranslationTable{
  ["hs__panfeng"] = "潘凤",

  ["$kuangfu1"] = "吾乃上将潘凤，可斩华雄！",
  ["$kuangfu2"] = "这家伙，还是给我用吧！",
  ["~hs__panfeng"] = "潘凤又被华雄斩啦。",
}

local zoushi = General(extension, "hs__zoushi", "qun", 3, 3, General.Female)
local huoshui = fk.CreateTriggerSkill{ -- FIXME
  name = "huoshui",
  anim_type = "control",
  frequency = Skill.Compulsory,
  events = {fk.TurnStart, fk.GeneralRevealed, fk.EventAcquireSkill, fk.EventLoseSkill, fk.Deathed},
  can_trigger = function(self, event, target, player, data)
    if target ~= player then return false end
    if event == fk.TurnStart then
      return player:hasSkill(self.name) 
    end
    if player.phase == Player.NotActive then return false end
    if event == fk.EventAcquireSkill or event == fk.EventLoseSkill then
      return data == self 
    elseif event == fk.GeneralRevealed then
      return data == "hs__zoushi" and player:hasSkill(self.name) 
    else
      return player:hasSkill(self.name, true, true) 
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if table.contains({fk.TurnStart, fk.GeneralRevealed, fk.EventAcquireSkill}, event) then
      local targets = {}
      for _, p in ipairs(room:getOtherPlayers(player)) do
        room:setPlayerMark(p, "@@huoshui-turn", 1)
        local record = type(p:getMark(MarkEnum.RevealProhibited .. "-turn")) == "table" and p:getMark(MarkEnum.RevealProhibited .. "-turn") or {}
        table.insertTable(record, {"m", "d"})
        room:setPlayerMark(p, MarkEnum.RevealProhibited .. "-turn", record)
        table.insert(targets, p.id)
      end
      room:doIndicate(player.id, targets)
    else
      for _, p in ipairs(room:getOtherPlayers(player)) do
        room:setPlayerMark(p, "@@huoshui-turn", 0)
        local record = type(p:getMark(MarkEnum.RevealProhibited .. "-turn")) == "table" and p:getMark(MarkEnum.RevealProhibited .. "-turn") or {}
        table.removeOne(record, "m")
        table.removeOne(record, "d")
        if #record == 0 then record = 0 end
        room:setPlayerMark(p, MarkEnum.RevealProhibited .. "-turn", record)
      end
    end
  end,
}
local qingcheng = fk.CreateActiveSkill{
  name = "qingcheng",
  anim_type = "control",
  card_num = 1,
  target_num = 1,
  card_filter = function(self, to_select, selected, targets)
    return #selected == 0 and Fk:getCardById(to_select).color == Card.Black
  end,
  target_filter = function(self, to_select, selected, selected_cards)
    if #selected > 0 or #selected_cards == 0 then return false end --TODO
    local target = Fk:currentRoom():getPlayerById(to_select)
    return to_select ~= Self.id and target.general ~= "anjiang" and target.deputyGeneral ~= "anjiang"
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    local ret = false
    if Fk:getCardById(effect.cards[1]).type == Card.TypeEquip then
      ret = true
    end
    room:throwCard(effect.cards, self.name, player, player)
    H.doHideGeneral(room, player, target, self.name)
    if ret and not player.dead then
      local targets = table.filter(room.alive_players, function(p) return p.general ~= "anjiang" and p.deputyGeneral ~= "anjiang" and p ~= player and p ~= target end)
      if #targets == 0 then return false end
      local to = room:askForChoosePlayers(player, table.map(targets, Util.IdMapper), 1, 1, "#qingcheng-again", self.name, true)
      if #to > 0 then
        target = room:getPlayerById(to[1])
        H.doHideGeneral(room, player, target, self.name)
      end
    end
  end,
}
zoushi:addSkill(huoshui)
zoushi:addSkill(qingcheng)
Fk:loadTranslationTable{
  ["hs__zoushi"] = "邹氏",
  ["huoshui"] = "祸水",
  [":huoshui"] = "锁定技，你的回合内，其他角色不能明置其武将牌。",
  ["qingcheng"] = "倾城",
  [":qingcheng"] = "出牌阶段，你可弃置一张黑色牌并选择一名武将牌均明置的其他角色，然后你暗置其一张武将牌。然后若你以此法弃置的牌是黑色装备牌，则你可再选择另一名武将牌均明置的其他角色，暗置其一张武将牌。",

  ["@@huoshui-turn"] = "祸水",
  ["#qingcheng-again"] = "倾城：你可再选择另一名武将牌均明置的其他角色，暗置其一张武将牌",

  ["$huoshui1"] = "走不动了嘛？" ,
  ["$huoshui2"] = "别走了在玩一会嘛？" ,
  ["$qingcheng1"] = "我和你们真是投缘啊。",
  ["$qingcheng2"] = "哼，眼睛都直了呀。",
  ["~hs__zoushi"] = "年老色衰了吗？",
}

-- 军令四
local command4_prohibit = fk.CreateProhibitSkill{
  name = "#command4_prohibit",
  -- global = true,
  prohibit_use = function(self, player, card)
    return player:getMark("_command4_effect-turn") > 0 and table.contains(player.player_cards[Player.Hand], card.id)
  end,
  prohibit_response = function(self, player, card)
    return player:getMark("_command4_effect-turn") > 0 and table.contains(player.player_cards[Player.Hand], card.id)
  end,
}
Fk:addSkill(command4_prohibit)

-- 军令五 你不准回血！
local command5_cannotrecover = fk.CreateTriggerSkill{
  name = "#command5_cannotrecover",
  -- global = true,
  refresh_events = {fk.PreHpRecover},
  can_refresh = function(self, event, target, player, data)
    return target == player and player:getMark("_command5_effect-turn") > 0
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
  can_use = function() return false end,
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
    return target == player and player.phase == Player.Discard and player:hasSkill(self.name) and player:getMark("@!yinyangfish") > 0 and player:getHandcardNum() > player:getMaxCards()
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, nil, "#yinyangfish_max-ask")
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    removeYinyangfish(room, player)
    room:addPlayerMark(target, MarkEnum.AddMaxCardsInTurn, 2)
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
    return target == player and player.phase == Player.Discard and player:hasSkill(self.name) and player:getMark("@!wild") > 0 and player:getHandcardNum() > player:getMaxCards()
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

local battleRoyalVS = fk.CreateViewAsSkill{
  name = "battle_royal&",
  pattern = "slash,jink",
  interaction = function()
    local names = {}
    if Fk.currentResponsePattern == nil and Self:canUse(Fk:cloneCard("slash")) then
      table.insertIfNeed(names, "slash")
    else
      for _, name in ipairs({"slash", "jink"}) do
        if Fk.currentResponsePattern and Exppattern:Parse(Fk.currentResponsePattern):match(Fk:cloneCard(name)) then
          table.insertIfNeed(names, name)
        end
      end
    end
    if #names == 0 then return end
    return UI.ComboBox {choices = names}
  end,
  card_filter = function(self, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).trueName == "peach"
  end,
  view_as = function(self, cards)
    if #cards ~= 1 or self.interaction.data == nil then return end
    local card = Fk:cloneCard(self.interaction.data)
    card.skillName = self.name
    card:addSubcard(cards[1])
    return card
  end,
}
local battleRoyalProhibit = fk.CreateProhibitSkill{
  name = "#battle_royal_prohibit&",
  prohibit_use = function(self, player, card)
    if not card or card.trueName ~= "peach" or #card.skillNames > 0 then return false end
    local subcards = Card:getIdList(card)
    return #subcards > 0 and table.every(subcards, function(id)
      return table.contains(player:getCardIds(Player.Hand), id)
    end)
  end
}
battleRoyalVS:addRelatedSkill(battleRoyalProhibit)
Fk:addSkill(battleRoyalVS)
-- Fk:addSkill(battleRoyalProhibit)

Fk:loadTranslationTable{
  ["battle_royal&"] = "鏖战",
  [":battle_royal&"] = "非转化的【桃】只能当【杀】或【闪】使用或打出。",
  ["#battle_royal_prohibit&"] = "鏖战",
}

return extension
