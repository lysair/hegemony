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
    return #selected == 0 and to_select ~= Self.id and Fk:currentRoom():getPlayerById(to_select):getMark("_quanjin-phase") > 0 -- and #selected_cards == 1
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
    if not (player:hasSkill(quanjin) or player:isFakeSkill(quanjin)) or player.phase ~= Player.Play then return false end
    return event == fk.Damaged or (target == player and data == quanjin)
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    if event == fk.Damaged then
      room:setPlayerMark(target, "_quanjin-phase", 1)
    elseif room:getTag("RoundCount") then
      room.logic:getActualDamageEvents(998, function(e)
        local damage = e.data[1]
        local to = damage.to
        if to and to:getMark("_quanjin-phase") == 0 then
          room:setPlayerMark(to, "_quanjin-phase", 1)
        end
        return false
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
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0 and player.kingdom ~= "unknown"
  end,
  min_card_num = 1,
  card_filter = function(self, to_select, selected)
    return Fk:currentRoom():getCardArea(to_select) == Player.Hand and not Self:prohibitDiscard(Fk:getCardById(to_select))
  end,
  target_num = 1,
  target_filter = function(self, to_select, selected, selected_cards)
    local target = Fk:currentRoom():getPlayerById(to_select)
    return #selected == 0 and H.compareKingdomWith(target, Self, true)
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
  ["#ld__dongzhao"] = "移尊易鼎",
  ["illustrator:ld__dongzhao"] = "小牛",
  ["designer:ld__dongzhao"] = "逍遥鱼叔",
  ["cv:ld__dongzhao"] = "宋国庆",

  ["quanjin"] = "劝进",
  [":quanjin"] = "出牌阶段限一次，你可将一张手牌交给一名此阶段受到过伤害的角色，对其发起“军令”。若其执行，你摸一张牌；若其不执行，你将手牌摸至与手牌最多的角色相同（最多摸五张）。",
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

local zhuling = General(extension, "ld__zhuling", "wei", 4)
local juejue = fk.CreateTriggerSkill{
  name = "ld__juejue",
  anim_type = "offensive",
  events = {fk.EventPhaseStart, fk.BuryVictim},
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self) then return end
    if event == fk.EventPhaseStart then
      return target == player and player.phase == Player.Discard
    else
      return data.damage and data.damage.from == player and H.compareKingdomWith(player, target)
    end
  end,
  on_cost = function(self, event, target, player, data)
    if event == fk.EventPhaseStart then
      return player.room:askForSkillInvoke(player, self.name, data, "#ld__juejue-ask")
    else
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    if event == fk.EventPhaseStart then
      room:loseHp(player, 1, self.name)
    else
      local deathEvent = room.logic:getCurrentEvent():findParent(GameEvent.Death, true)
      deathEvent.extra_data = deathEvent.extra_data or {}
      deathEvent.extra_data.ignorePunishment = true
    end
  end,
}

local juejue_delay = fk.CreateTriggerSkill{
  name = "#ld__juejue_delay",
  events = {fk.EventPhaseEnd},
  can_trigger = function (self, event, target, player, data)
    if not (target == player and player.phase == Player.Discard and player:isAlive() and player:usedSkillTimes(juejue.name, Player.HistoryPhase) > 0) then return false end
    local x = 0
    local logic = player.room.logic
    logic:getEventsOfScope(GameEvent.MoveCards, 1, function (e)
      for _, move in ipairs(e.data) do
        if move.from == player.id and move.moveReason == fk.ReasonDiscard and move.skillName == "game_rule" then
          x = x + #move.moveInfo
          if x > 1 then return true end
        end
      end
      return false
    end, Player.HistoryTurn)
    self.cost_data = x
    return x > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local targets = room:getOtherPlayers(player)
    local n = self.cost_data
    for _, target in ipairs(targets) do
      if not target.dead then
        local choices = {"ld__juejue_damage"}
        if #target:getCardIds("h") >= n then
          table.insert(choices, "ld__juejue_putcard")
        end
        local choice = room:askForChoice(target, choices, self.name)
        if choice == "ld__juejue_damage" then
          room:damage{
            from = player,
            to = target,
            damage = 1,
            skillName = self.name,
          }
        else
          local card = room:askForCard(target, n, n, true, self.name, false, ".|.|.|hand", nil)
          room:moveCardTo(card, Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile, self.name)
        end
      end
    end
  end,
}

local fangyuan = H.CreateArraySummonSkill{
  name = "ld__fangyuan",
  array_type = "siege",
}
local fangyuanTrigger = fk.CreateTriggerSkill{
  name = "#ld__fangyuan_trigger",
  visible = false,
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    local prev_player = player:getLastAlive()
    local next_player = player:getNextAlive()
    return player:hasSkill(self) and player.phase == Player.Finish and H.inSiegeRelation(prev_player, next_player, player) 
      and #player.room.alive_players > 3
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local prev_player = player:getLastAlive()
    local next_player = player:getNextAlive()
    local targets = {}
    local slash = Fk:cloneCard("slash")
    if not player:isProhibited(prev_player, slash) then
      table.insert(targets, prev_player.id)
    end
    if not player:isProhibited(next_player, slash) then
      table.insert(targets, next_player.id)
    end
    local target = room:askForChoosePlayers(player, targets, 1, 1, "#ld__fangyuan-choose", self.name, false)
    local to = room:getPlayerById(target[1])
    room:useVirtualCard("slash", nil, player, to, self.name, true)
  end,
}

local fangyuanCardTrig = fk.CreateTriggerSkill{ -- FIXME
  name = '#ld__fangyuan_card_trigger',
  visible = false,
  frequency = Skill.Compulsory,
  refresh_events = {fk.TurnStart, fk.GeneralRevealed, fk.EventAcquireSkill, "fk.RemoveStateChanged", fk.EventLoseSkill, fk.GeneralHidden},
  can_refresh = function(self, event, target, player, data)
    if event == fk.EventLoseSkill then return data == fangyuan
    elseif event == fk.GeneralHidden then return player == target 
    else return H.hasShownSkill(player, self.name, true, true) end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local ret = #room.alive_players > 3 and player:hasSkill(self)
    local prev = player:getLastAlive()
    local next = player:getNextAlive()
    if event == fk.GeneralHidden or event == fk.EventLoseSkill then
      for _, p in ipairs(room.alive_players) do
        room:setPlayerMark(p, "ld__fangyuan_card", 0)
      end
    else
      local clear = true
      if ret and H.inSiegeRelation(prev:getLastAlive(), player, prev) then
        room:setPlayerMark(prev:getLastAlive(), "ld__fangyuan_card", 1)
        room:setPlayerMark(player, "ld__fangyuan_card", 1)
        room:setPlayerMark(prev, "ld__fangyuan_card", -1)
        clear = false
      end
      if ret and H.inSiegeRelation(player, next:getNextAlive(), next) then
        room:setPlayerMark(player, "ld__fangyuan_card", 1)
        room:setPlayerMark(next:getNextAlive(), "ld__fangyuan_card", 1)
        room:setPlayerMark(next, "ld__fangyuan_card", -1)
        clear = false
      end
      if clear == true then
        for _, p in ipairs(room.alive_players) do
          room:setPlayerMark(p, "ld__fangyuan_card", 0)
        end
      end
    end
  end,
}
local fangyuan_maxcards = fk.CreateMaxCardsSkill{
  name = "#ld__fangyuan_maxcards",
  correct_func = function(self, player)
    return player:getMark("ld__fangyuan_card")
  end,
}

juejue:addRelatedSkill(juejue_delay)
zhuling:addSkill(juejue)
fangyuan:addRelatedSkill(fangyuanTrigger)
fangyuan:addRelatedSkill(fangyuan_maxcards)
fangyuan:addRelatedSkill(fangyuanCardTrig)
zhuling:addSkill(fangyuan)
Fk:loadTranslationTable{
  ["ld__zhuling"] = "朱灵",
  ["ld__juejue"] = "决绝",
  [":ld__juejue"] = "①弃牌阶段开始时，你可失去1点体力，若如此做，此阶段结束时，若你于此阶段内弃置过牌，你令所有其他角色选择一项：1.将X张手牌置入弃牌堆；2.受到你造成的1点伤害（X为你于此阶段内弃置的牌数）；②你杀死与你势力相同的角色不执行奖惩。",
  ["ld__fangyuan"] = "方圆",
  [":ld__fangyuan"] = "阵法技，①若你是围攻角色，此围攻关系中围攻角色手牌上限+1，被围攻角色手牌上限-1。②结束阶段，若你是被围攻角色，你视为对此围攻关系中一名围攻角色使用一张无距离限制的【杀】。",

  ["#ld__juejue-ask"] = "决绝：你可失去1点体力",
  ["#ld__juejue_delay"] = "决绝",
  ["ld__juejue_damage"] = "受到伤害",
  ["ld__juejue_putcard"] = "将牌置入弃牌堆",

  ["#ld__fangyuan-choose"] = "方圆：选择此围攻关系中的一名围攻角色，视为对其使用一张【杀】",

  ["$ld__juejue1"] = "",
  ["$ld__juejue2"] = "",
  ["$ld__fangyuan1"] = "",
  ["$ld__fangyuan2"] = "",
  ["~ld__zhuling"] = "",
}

--[[
local xushu = General(extension, "ld__xushu", "shu", 4)
xushu.deputyMaxHpAdjustedValue = -1
local qiance = fk.CreateTriggerSkill{
  name = "ld__qiance",
  anim_type = "control",
  events = {fk.TargetSpecified},
  can_trigger = function (self, event, target, player, data)
    return H.compareKingdomWith(target, player) and player:hasSkill(self) and data.card:isCommonTrick() and data.firstTarget
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
    return player:hasSkill(self) and H.compareKingdomWith(player, data.to) and data.damage >= data.to.hp
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
xushu:addCompanions("hs__wolong")
Fk:loadTranslationTable{
  ["ld__xushu"] = "徐庶",
  ["#ld__xushu"] = "难为完臣",
  ["illustrator:ld__xushu"] = "YanBai",
  ["ld__qiance"] = "谦策",
  [":ld__qiance"] = "当与你势力相同的角色使用锦囊牌指定目标后，你可令所有大势力角色不能响应此牌。",
  ["ld__jujian"] = "举荐",
  [":ld__jujian"] = "副将技，此武将牌上单独的阴阳鱼个数-1。当与你势力相同的角色受到伤害时，若伤害值不小于其体力值，你可防止之，然后你变更此武将牌。",

  ["#ld__qiance-ask"] = "谦策：是否令所有大势力角色不能响应此牌",
  ["#ld__jujian-ask"] = "举荐：是否防止此伤害，然后你变更此武将牌",

  ["$ld__qiance1"] = "开言纳谏，社稷之福。",
  ["$ld__qiance2"] = "如此如此，敌军自破。",
  ["$ld__jujian1"] = "千金易得，贤才难求。",
  ["$ld__jujian2"] = "愿与将军共图王之霸业。",
  ["~ld__xushu"] = "大义无言，虽死无怨。",
}
]]--

local xushu = General(extension, "ld__xushu", "shu", 4)
xushu.deputyMaxHpAdjustedValue = -1

local xiaozhen = fk.CreateTriggerSkill{
  name = "ld__xiaozhen",
  anim_type = "offensive",
  events = {fk.AfterCardTargetDeclared},
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(self) and data.from == player.id and (data.card.trueName == "slash" or data.card:isCommonTrick())
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local targets = TargetGroup:getRealTargets(data.tos)
    data.tos = {}
    player:drawCards(1, self.name)
    for _, pid in ipairs(targets) do
      target = room:getPlayerById(pid)
      room:setPlayerMark(target, "@@lure_tiger-turn", 1)
      room:setPlayerMark(target, MarkEnum.PlayerRemoved .. "-turn", 1)
      room:handleAddLoseSkills(target, "#lure_tiger_hp|#lure_tiger_prohibit", nil, false, true) -- global...
      room.logic:trigger("fk.RemoveStateChanged", target, nil) -- FIXME
    end
  end,
}

local jianyan = fk.CreateActiveSkill{
  name = "ld__jianyan",
  anim_type = "support",
  card_num = 0,
  target_num = 0,
  relate_to_place = "d",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  interaction = function()
    return UI.ComboBox {choices = {"black", "red", "basic", "trick", "equip"} }
  end,
  on_use = function(self, room, effect)
    local pattern = self.interaction.data
    if not pattern then pattern = "red" end -- for AI
    local player = room:getPlayerById(effect.from)
    local card
    local cards = {}
    local _pattern
    if pattern == "black" then
      _pattern = ".|.|spade,club"
    elseif pattern == "red" then
      _pattern = ".|.|heart,diamond"
    else
      _pattern = ".|.|.|.|.|" .. pattern
    end
    if #room:getCardsFromPileByRule(_pattern, 1) == 0 then return false end
    while true do
      local id = room:getNCards(1)[1]
      room:moveCardTo(id, Card.Processing, nil, fk.ReasonJustMove, self.name)
      room:delay(300)
      local c = Fk:getCardById(id)
      if c:getColorString() == pattern or c:getTypeString() == pattern then
        card = c
        break
      else
        table.insert(cards, id)
      end
    end
    local availableTargets = table.map(table.filter(room.alive_players, function(p) return p.gender == General.Male end), function(p) return p.id end)
    if #availableTargets == 0 then
      table.insert(cards, card.id)
    else
      local target = room:askForChoosePlayers(player, availableTargets, 1, 1, "#ld__jianyan-ask", self.name, false)[1]
      local to = room:getPlayerById(target)
      local choices = {"ld__jianyan_getcard:::" .. card:toLogString()}
      if to:isWounded() then
        table.insert(choices, "ld__jianyan_recover:" .. player.id)
      end
      local choice = room:askForChoice(to, choices, self.name)
      if choice:startsWith("ld__jianyan_getcard") then
        room:moveCardTo(card.id, Player.Hand, to, fk.ReasonPrey, self.name, nil, true, player.id)
      else
        table.insert(cards, card.id)
        room:recover({
          who = to,
          num = 1,
          recoverBy = player,
          skillName = self.name
        })
        H.transformGeneral(room, player)
      end
    end
    cards = table.filter(cards, function(id) return room:getCardArea(id) == Card.Processing end)
    room:moveCardTo(cards, Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile, self.name, nil, true, player.id)
  end,
}
xushu:addSkill("zhuhai")
xushu:addSkill(xiaozhen)
xushu:addSkill(jianyan)
xushu:addCompanions("hs__wolong")
Fk:loadTranslationTable{
  ["ld__xushu"] = "徐庶",
  ["designer:ld__xushu"] = "教父&风萧",
  ["illustrator:ld__xushu"] = "YanBai",
  -- ["ld__zhuhai"] = "诛害",
  -- [":ld__zhuhai"] = "其他角色的结束阶段，若其本回合造成过伤害，你可对其使用一张无距离限制的【杀】。",
  ["ld__xiaozhen"] = "晓阵",
  [":ld__xiaozhen"] = "当你使用【杀】或普通锦囊牌选择目标后，你可取消此牌所有目标，摸一张牌，然后调离这些角色直至此回合结束。",
  ["ld__jianyan"] = "荐言",
  [":ld__jianyan"] = "副将技，此武将牌上单独的阴阳鱼个数-1；出牌阶段限一次，你可检索一种牌的类别或颜色，然后令一名男性角色选择：1.获得以此法检索到的牌；2.回复1点体力，然后你变更此武将牌。",

  ["#ld__jianyan-ask"] = "荐言：选择一名男性角色",
  ["ld__jianyan_recover"] = "回复1点体力，然后%src变更",
  ["ld__jianyan_getcard"] = "获得%arg",

  ["$ld__xiaozhen1"] = "既遇明主，天下可图！",
  ["$ld__xiaozhen2"] = "弃武从文，安邦卫国！",
  ["$ld__jianyan1"] = "开言纳谏，社稷之福。",
  ["$ld__jianyan2"] = "如此如此，敌军自破！",
  ["~ld__xushu"] = "大义无言，虽死无怨。",
}

local liuba = General(extension, "ld__liuba", "shu", 3)
local tongdu = fk.CreateTriggerSkill{
  name = "ld__tongdu",
  anim_type = "control",
  events = {fk.EventPhaseStart},
  can_trigger = function (self, event, target, player, data)
    if target.phase ~= Player.Finish or not H.compareKingdomWith(player, target) or not player:hasSkill(self)
      or (target ~= player and not H.hasShownSkill(player, self)) then return false end
    local room = player.room
    local discard_ids = {}
    room.logic:getEventsOfScope(GameEvent.Phase, 1, function (e)
      if e.data[2] == Player.Discard then
        table.insert(discard_ids, {e.id, e.end_id})
      end
      return false
    end, Player.HistoryTurn)
    if #discard_ids > 0 then
      local num = 0
      room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function (e)
        local in_discard = false
        for _, ids in ipairs(discard_ids) do
          if #ids == 2 and e.id > ids[1] and e.id < ids[2] then
            in_discard = true
            break
          end
        end
        if in_discard then
          for _, move in ipairs(e.data) do
            if move.from == target.id and move.moveReason == fk.ReasonDiscard then
              for _, info in ipairs(move.moveInfo) do
                if info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip then
                  num = num + 1
                end
              end
            end
          end
        end
        return false
      end, Player.HistoryTurn) 
      if num > 0 then
        self.cost_data = math.min(3, num)
        return true
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    return target.room:askForSkillInvoke(target, self.name, nil, "#ld__tongdu-ask:" .. player.id .. "::" .. self.cost_data)
  end,
  on_use = function (self, event, target, player, data)
    target:drawCards(self.cost_data, self.name)
  end,
}

local qingyin = fk.CreateActiveSkill{
  name = "ld__qingyin",
  anim_type = "support",
  frequency = Skill.Limited,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local isDeputy = H.inGeneralSkills(player, self.name)
    if isDeputy then
      H.removeGeneral(room, player, isDeputy == "d")
    end
    local targets = table.map(table.filter(room.alive_players, function(p) return H.compareKingdomWith(p, player) end), Util.IdMapper)
    room:sortPlayersByAction(targets)
    room:recover({
      who = player,
      num = player.maxHp - player.hp,
      recoverBy = player,
      skillName = self.name
    })
    for _, pid in ipairs(targets) do
      local p = room:getPlayerById(pid)
      if not p.dead and p:isWounded() then
        room:recover({
          who = p,
          num = p.maxHp - p.hp,
          recoverBy = player,
          skillName = self.name,
        })
      end
    end
  end,
}
liuba:addSkill(tongdu)
liuba:addSkill(qingyin)

Fk:loadTranslationTable{
  ["ld__liuba"] = "刘巴",
  ["#ld__liuba"] = "清河一鲲",
  ["illustrator:ld__liuba"] = "Mr_Sleeping",
  ["designer:ld__liuba"] = "逍遥鱼叔",

  ["ld__tongdu"] = "统度",
  [":ld__tongdu"] = "与你势力相同的角色结束阶段，其可摸X张牌（X为其于弃牌阶段弃置的牌数且至多为3）",
  ["ld__qingyin"] = "清隐",
  [":ld__qingyin"] = "限定技，出牌阶段，你可移除此武将牌，然后与你势力相同的角色将体力回复至体力上限。",

  ["#ld__tongdu-ask"] = "你可发动%src的“统度”，摸 %arg 张牌",

  ["$ld__tongdu1"] = "统荆益二州诸物之价，以为民生国祚之大计。",
  ["$ld__tongdu2"] = "铸直百之钱，可平物价，定军民之心。",
  ["$ld__qingyin1"] = "功成身退，再不问世间诸事。",
  ["$ld__qingyin2"] = "天下既定，我亦当遁迹匿踪，颐养天年矣。",
  ["~ld__liuba"] = "家国将逢巨变，奈何此身先陨。",
}

local wujing = General(extension, "ld__wujing", "wu", 4)

local fengyang = H.CreateArraySummonSkill{
  name = "ld__fengyang",
  array_type = "formation",
}
local fengyangTrig = fk.CreateTriggerSkill{
  name = "#ld__fengyang_trigger",
  frequency = Skill.Compulsory,
  events = {fk.BeforeCardsMove},
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self) or #player.room.alive_players < 4 then return end
    local room = player.room
    for _, move in ipairs(data) do
      if move.from and H.inFormationRelation(player, room:getPlayerById(move.from)) and
        (move.moveReason == fk.ReasonDiscard or (move.toArea == Card.PlayerHand and move.to ~= move.from and move.moveReason ~= fk.ReasonGive))
        and move.proposer and not H.compareKingdomWith(room:getPlayerById(move.proposer), player) then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerEquip then
            return true
          end
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local ids, targets = {}, {}
    room:notifySkillInvoked(player, "ld__fengyang", "defensive")
    player:broadcastSkillInvoke("ld__fengyang")
    for _, move in ipairs(data) do
      if move.from and H.inFormationRelation(player, room:getPlayerById(move.from)) and
        (move.moveReason == fk.ReasonDiscard or (move.toArea == Card.PlayerHand and move.to ~= move.from and move.moveReason ~= fk.ReasonGive))
        and move.proposer and not H.compareKingdomWith(room:getPlayerById(move.proposer), player) then
        local move_info = {}
        for _, info in ipairs(move.moveInfo) do
          local id = info.cardId
          if info.fromArea == Card.PlayerEquip then
            table.insert(ids, id)
          else
            table.insert(move_info, info)
          end
          if #ids > 0 then
            table.insertIfNeed(targets, move.from)
            move.moveInfo = move_info
          end
        end
      end
    end
    if #ids > 0 then
      room:doIndicate(player.id, targets)
      room:sendLog{
        type = "#cancelDismantle",
        card = ids,
        arg = self.name,
      }
    end
  end,
}

local diaogui = fk.CreateViewAsSkill{
  name = "ld__diaogui",
  anim_type = "drawcard",
  pattern = "lure_tiger",
  card_filter = function(self, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).type == Card.TypeEquip
  end,
  view_as = function(self, cards)
    if #cards ~= 1 then
      return nil
    end
    local c = Fk:cloneCard("lure_tiger")
    c.skillName = self.name
    c:addSubcard(cards[1])
    return c
  end,
  enabled_at_play = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryTurn) == 0
  end,
}

local diaogui_effect = fk.CreateTriggerSkill{
  name = "#ld__diaogui_effect",
  mute = true,
  events = {fk.CardUseFinished},
  can_trigger = function(self, event, target, player, data)
    if target == player then
      if event == fk.CardUseFinished then
        return data.card and table.contains(data.card.skillNames, "ld__diaogui")
      end
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local targets = table.map(table.filter(room.alive_players, function(p) return H.inFormationRelation(p, player)  end), Util.IdMapper)
    if #targets > 0 then
      for _, pid in ipairs(targets) do
        local p = room:getPlayerById(pid)
        p:drawCards(1, self.name)
      end
    end
  end,
}

diaogui:addRelatedSkill(diaogui_effect)
wujing:addSkill(diaogui)
fengyang:addRelatedSkill(fengyangTrig)
wujing:addSkill(fengyang)
Fk:loadTranslationTable{
  ["ld__wujing"] = "吴景",
  ["#ld__wujing"] = "汗马鎏金",
  ["illustrator:ld__wujing"] = "小牛",
  ["designer:ld__wujing"] = "逍遥鱼叔",
  ["cv:ld__wujing"] = "虞晓旭",

  ["ld__diaogui"] = "调归",
  [":ld__diaogui"] = "出牌阶段限一次，你可将一张装备牌当【调虎离山】使用，然后与你处于同一队列的角色各摸一张牌。",
  ["ld__fengyang"] = "风扬",
  ["#ld__fengyang_trigger"] = "风扬",
  [":ld__fengyang"] = "阵法技，与你处于同一队列的角色装备区内的牌被与你势力不同的角色弃置或获得时，取消之",

  ["$ld__diaogui1"] = "闻伯符立业，今特来相助。",
  ["$ld__diaogui2"] = "臣虽驽钝，愿以此腔热血报国",
  ["$ld__fengyang2"] = "谁也休想染指江东寸土。",
  ["$ld__fengyang1"] = "如此咽喉要地，吾当倾力守之。",
  ["~ld__wujing"] = "憾未能见，我江东一统天下之时……",
}

local zhugeke = General(extension, "ld__zhugeke", "wu", 3)
zhugeke:addCompanions("hs__dingfeng")
local aocai = fk.CreateViewAsSkill{
  name = "ld__aocai",
  pattern = ".|.|.|.|.|basic",
  anim_type = "special",
  expand_pile = function() return U.getMark(Self, "ld__aocai") end,
  prompt = function()
    return "#ld__aocai"
  end,
  card_filter = function(self, to_select, selected)
    if #selected == 0 and table.contains(U.getMark(Self, "ld__aocai"), to_select) then
      local card = Fk:getCardById(to_select)
      if card.type == Card.TypeBasic then
        if Fk.currentResponsePattern == nil then
          return Self:canUse(card) and not Self:prohibitUse(card)
        else
          return Exppattern:Parse(Fk.currentResponsePattern):match(card)
        end
      end
    end
  end,
  view_as = function(self, cards)
    if #cards ~= 1 then return end
    return Fk:getCardById(cards[1])
  end,
  enabled_at_play = function(self, player)
    return false
  end,
  enabled_at_response = function(self, player, response)
    return player.phase == Player.NotActive
  end,
}
local aocai_trigger = fk.CreateTriggerSkill{
  name = "#ld__aocai_trigger",
  refresh_events = {fk.AskForCardUse, fk.AskForCardResponse},
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(aocai.name) and player ~= player.room.current
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local ids = {}
    for i = 1, 2, 1 do
      if i > #room.draw_pile then break end
      table.insert(ids, room.draw_pile[i])
    end
    player.room:setPlayerMark(player, "ld__aocai", ids)
  end,
}

local duwu = fk.CreateActiveSkill{
  name =  "ld__duwu",
  frequency = Skill.Limited,
  anim_type = "support",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,
  card_filter = Util.FalseFunc,
  on_use = function (self, room, effect)
    local player = room:getPlayerById(effect.from)
    local index = H.startCommand(player, self.name)
    local targets = table.map(table.filter(room.alive_players, function(p) return not H.compareKingdomWith(player, p) and player:inMyAttackRange(p)  end), Util.IdMapper)
    if #targets > 0 then
      room:handleAddLoseSkills(player, "#ld__duwu_trigger", nil)
      room:doIndicate(player.id, targets)
      room:sortPlayersByAction(targets)
      for _, pid in ipairs(targets) do
        local p = room:getPlayerById(pid)
        if player.dead then break end
        if not p.dead and not H.doCommand(p, self.name, index, player) then
          room:damage{
            from = player,
            to = p,
            damage = 1,
            skillName = self.name,
          }
          player:drawCards(1, self.name)
        end
      end
      room:handleAddLoseSkills(player, "-#ld__duwu_trigger", nil)
      if #table.filter(room.alive_players, function(p) return p:getMark("ld__duwu_delay-phase") == 1 end) > 0 then
        room:loseHp(player, 1, self.name)
      end
    end 
  end,
}

local duwu_trigger = fk.CreateTriggerSkill{
  name = "#ld__duwu_trigger",
  mute = true,
  events = {fk.AfterDying},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and not player.dead and not target.dead
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(target, "ld__duwu_delay-phase", 1)
  end,
}

aocai:addRelatedSkill(aocai_trigger)
zhugeke:addSkill(aocai)
Fk:addSkill(duwu_trigger)
zhugeke:addSkill(duwu)

Fk:loadTranslationTable{
  ["ld__zhugeke"] = "诸葛恪",
  ["#ld__zhugeke"] = "兴家赤族",
  ["designer:ld__zhugeke"] = "逍遥鱼叔",
  ["illustrator:ld__zhugeke"] = "猎枭",

  ["ld__aocai"] = "傲才",
  [":ld__aocai"] = "当你于回合外需要使用或打出一张基本牌时，你可以观看牌堆顶的两张牌，若你观看的牌中有相同牌名的牌，你可以使用或打出之。",
  ["ld__duwu"] = "黩武",
  [":ld__duwu"] = "限定技，出牌阶段，你可以选择一个“军令”，你对你攻击范围内所有与你势力不同或未确定势力的角色发起此“军令”，若其不执行，你对其造成1点伤害并摸一张牌。"..
  "此“军令”结算后，若存在进入濒死状态被救回的角色，你失去1点体力。",

  ["$ld__aocai1"] = "哼，易如反掌。",
  ["$ld__aocai2"] = "吾主圣明，泽披臣属。",
  ["$ld__duwu1"] = "破曹大功，正在今朝！",
  ["$ld__duwu2"] = "全力攻城！言退者，斩！",
  ["~ld__zhugeke"] = "重权震主，是我疏忽了……",
}

local yanbaihu = General(extension, "ld__yanbaihu", "qun", 4)
local zhidao = fk.CreateTriggerSkill{
  name = "ld__zhidao",
  frequency = Skill.Compulsory,
  events = {fk.EventPhaseStart},
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(self) and player == target and player.phase == Player.Play
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local targets = table.map(room:getOtherPlayers(player), Util.IdMapper)
    local target = room:askForChoosePlayers(player, targets, 1, 1, "#ld__zhidao-choose", self.name, false)
    local to = room:getPlayerById(target[1])
    room:setPlayerMark(to, "ld__zhidao-turn", 1)
    room:setPlayerMark(to, "@@ld__zhidao-turn", 1)
    room:setPlayerMark(player, "ld__zhidao-turn", 1)
  end,
}

local zhidao_trigger = fk.CreateTriggerSkill{
  name = "#ld_zhidao_trigger",
  frequency = Skill.Compulsory,
  events = {fk.Damage},
  can_trigger = function (self, event, target, player, data)
    if not (player:hasSkill(self) and  player == data.from and player:usedSkillTimes(zhidao.name, Player.HistoryTurn) > 0
      and data.to:getMark("ld__zhidao-turn") > 0 and data.to ~= player) then return false end
    local room = player.room
    return room.logic:getActualDamageEvents(1, function(e) return e.data[1].from == player end)[1].data[1] == data
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local card = room:askForCardChosen(player, data.to, "he", self.name)
    room:obtainCard(player.id, card, false, fk.ReasonPrey)
  end,
}

local zhidao_prohibit = fk.CreateProhibitSkill{
  name = "#ld__zhidao_prohibit",
  is_prohibited = function(self, from, to, card)
    return from:usedSkillTimes(zhidao.name, Player.HistoryTurn) > 0 and to:getMark("ld__zhidao-turn") == 0
  end,
}
local zhidao_distance = fk.CreateDistanceSkill{
  name = "#ld__zhidao_distance",
  fixed_func = function(self, from, to)
    if to:getMark("ld__zhidao-turn") == 1 and to ~= from then
      return 1
    end
  end,
}

local jilix = fk.CreateTriggerSkill{
  name = "ld__jilix",
  frequency = Skill.Compulsory,
  relate_to_place = "d",
  events = {fk.TargetConfirmed, fk.DamageInflicted},
  can_trigger = function (self, event, target, player, data)
    if event == fk.TargetConfirmed then
      return player:hasSkill(self) and player == target and data.card.color == Card.Red
        and (data.card.type == Card.TypeBasic or data.card:isCommonTrick()) and #AimGroup:getAllTargets(data.tos) == 1
    else
      if not (player:hasSkill(self) and player == target) then return false end
      local events = player.room.logic:getActualDamageEvents(2, function(e)
        return e.data[1].to == player
      end, Player.HistoryTurn)
      return #events == 1
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    local room = player.room
    if event == fk.TargetConfirmed then
      data.additionalEffect = 1
    else
      H.removeGeneral(room, player, true)
      return true
    end
  end,
}

zhidao:addRelatedSkill(zhidao_trigger)
zhidao:addRelatedSkill(zhidao_prohibit)
zhidao:addRelatedSkill(zhidao_distance)
yanbaihu:addSkill(zhidao)
yanbaihu:addSkill(jilix)
Fk:loadTranslationTable{
  ["ld__yanbaihu"] = "严白虎",
  ["#ld__yanbaihu"] = "豺牙落涧",
  ["designer:ld__yanbaihu"] = "逍遥鱼叔",
  ["illustrator:ld__yanbaihu"] = "",

  ["ld__zhidao"] = "雉盗",
  [":ld__zhidao"] = "锁定技，出牌阶段开始时，你选择一名其他角色，你于此回合内：1.使用牌仅能指定你或其为目标；2.计算与其距离为1；3.首次对其造成伤害后，获得其区域内一张牌。",
  ["ld__jilix"] = "寄篱",
  [":ld__jilix"] = "副将技，锁定技，①当你成为红色基本牌或红色普通锦囊牌的唯一目标后，你令此牌结算两次；②当你于一回合内第二次受到伤害时，你移除此武将牌，防止之。",

  ["#ld_zhidao_trigger"] = "雉盗",
  ["@@ld__zhidao-turn"] = "雉盗",
  ["#ld__zhidao-choose"] = "雉盗：选择一名其他角色，本回合你使用牌仅能指定你或其为目标",

  ["$ld__zhidao1"] = "",
  ["$ld__zhidao2"] = "",
  ["$ld__jilix1"] = "",
  ["$ld__jilix2"] = "",
  ["~ld__yanbaihu"] = "",
}

local huangzu = General(extension, "ld__huangzu", "qun", 4)
local xishe = fk.CreateTriggerSkill{
  name = "ld__xishe",
  anim_type = "offensive",
  events = {fk.EventPhaseStart},
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(self) and target.phase == Player.Start and table.find(player:getCardIds("e"), function(id) return not player:prohibitDiscard(Fk:getCardById(id)) end) and player ~= target
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    while true do
      local card = room:askForDiscard(player, 1, 1, true, self.name, true, ".|.|.|equip", "#ld__xishe::" .. target.id)
      if #card == 0 then break end
      local slash = Fk:cloneCard("slash")
      slash.skillName = self.name
      local use = {from = player.id, tos = { {target.id} }, card = slash, extraUse = true} ---@type CardUseStruct
      use.extra_data = use.extra_data or {}
      use.extra_data.ld__xisheUser = player.id
      room:useCard(use)
      if #player:getCardIds("e") == 0 or player.dead or target.dead then
        break
      end
    end
  end,

  refresh_events = {fk.Death},
  can_refresh = function(self, event, target, player, data)
    return target == player and data.damage and data.damage.card and table.contains(data.damage.card.skillNames, self.name)
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local use = room.logic:getMostRecentEvent(GameEvent.UseCard).data[1]
    local user = room:getPlayerById((use.extra_data or {}).ld__xisheUser)
    room:setPlayerMark(user, "ld__xishe_change-turn", 1)
  end,
}

local xishe_delay = fk.CreateTriggerSkill{
  name = "#ld__xishe_delay",
  anim_type = "offensive",
  mute = true,
  events = {fk.TargetSpecified, fk.TurnEnd},
  can_trigger = function (self, event, target, player, data)
    if event == fk.TargetSpecified then
      return target == player and (data.extra_data or {}).ld__xisheUser == player.id
    else
      return player:getMark("ld__xishe_change-turn") > 0 and player:getMark("@@ld__xishe_change_before") == 0
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    if event == fk.TargetSpecified then
      local targets = table.map(table.filter(table.map(AimGroup:getAllTargets(data.tos), Util.Id2PlayerMapper),function (p) return p.hp < player.hp end), Util.IdMapper)
      data.disresponsiveList = data.disresponsiveList or {}
      table.insertTableIfNeed(data.disresponsiveList, targets)
    else
      local room = player.room
      if room:askForChoice(player, {"transform_deputy", "Cancel"}, self.name) ~= "Cancel" then
        room:notifySkillInvoked(player, xishe.name, "special")
        player:broadcastSkillInvoke(xishe.name)
        room:setPlayerMark(player, "@@ld__xishe_change_before", 1)
        H.transformGeneral(room, player)
      end
    end
  end,
}

xishe:addRelatedSkill(xishe_delay)
huangzu:addSkill(xishe)
Fk:loadTranslationTable{
  ["ld__huangzu"] = "黄祖",
  ["#ld__huangzu"] = "遮山扼江",
  ["designer:ld__huangzu"] = "逍遥鱼叔",
  ["illustrator:ld__huangzu"] = "YanBai",

  ["ld__xishe"] = "袭射",
  [":ld__xishe"] = "其他角色的准备阶段，你可以弃置一张装备区内的牌，视为对其使用一张【杀】（体力值小于你的角色不能响应），然后你可以重复此流程。此回合结束时，若你以此法杀死了一名角色，你可以变更副将。 <br>注：变更副将后暗置的效果尚在施工中。",
  ["#ld__xishe_noresponse"] = "袭射",
  ["#ld__xishe"] = "袭射：你可以弃置一张装备区内的牌，视为对 %dest 使用一张【杀】",

  ["@@ld__xishe_change_before"] = "袭射 已变更",
  ["#ld__xishe_delay"] = "袭射",

  ["$ld__xishe1"] = "伏箭灭破虏，坚城拒讨逆。",
  ["$ld__xishe2"] = "什么江东猛虎？还不是我箭下之鬼！",
  ["~ld__huangzu"] = "今日不过是成王败寇，哼！动手吧！",
}

local mengda = General(extension, "ld__mengda", "shu", 4)
mengda.subkingdom = "wei"
local qiuan = fk.CreateTriggerSkill{
  name = "ld__qiuan",
  anim_type = "masochism",
  events = {fk.DamageInflicted},
  derived_piles = "ld__mengda_letter",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and data.card
      and #player:getPile("ld__mengda_letter") == 0 and U.hasFullRealCard(player.room, data.card)
  end,
  on_use = function(self, event, target, player, data)
    player:addToPile("ld__mengda_letter", data.card, true, self.name)
    if #player:getPile("ld__mengda_letter") > 0 then
      return true
    end
  end,
}
local liangfan = fk.CreateTriggerSkill{
  name = "ld__liangfan",
  anim_type = "offensive",
  frequency = Skill.Compulsory,
  events = {fk.EventPhaseStart, fk.Damage},
  can_trigger = function(self, event, target, player, data)
    if event == fk.EventPhaseStart then
      return player:hasSkill(self.name) and player.phase == Player.Start and #player:getPile("ld__mengda_letter") > 0
    end
    if event == fk.Damage then
      return target == player and player:hasSkill(self.name) and data.card and data.card:getMark("@@ld__mengda_letter-turn") > 0
        and not data.to:isNude() and not player.dead and not data.to.dead and data.to ~= player
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    local room = player.room
    if event == fk.EventPhaseStart then
      for _, id in ipairs(player:getPile("ld__mengda_letter")) do
        room:setCardMark(Fk:getCardById(id), "@@ld__mengda_letter-turn", 1)
      end
      local dummy = Fk:cloneCard("dilu")
      dummy:addSubcards(player:getPile("ld__mengda_letter"))
      room:obtainCard(player, dummy, true)
      room:loseHp(player, 1, self.name)
    else
      local card = room:askForCardChosen(player, data.to, "he", self.name)
      room:obtainCard(player, card, false, fk.ReasonPrey)
    end
  end,
}

mengda:addSkill(qiuan)
mengda:addSkill(liangfan)

Fk:loadTranslationTable{
  ["ld__mengda"] = "孟达",
  ["#ld__mengda"] = "怠军反复",
  ["designer:ld__mengda"] = "韩旭",
  ["illustrator:ld__mengda"] = "张帅",

  ["ld__qiuan"] = "求安",
  [":ld__qiuan"] = "当你受到伤害时，若没有“函”，你可将造成此伤害的牌置于武将牌上，称为“函”，然后防止此伤害。",
  ["ld__liangfan"] = "量反",
  [":ld__liangfan"] = "锁定技，准备阶段，若你有“函”，你获得之，然后失去1点体力，当你于此回合内使用以此法获得的牌造成伤害后，你可以获得受伤角色的一张牌。",

  ["ld__mengda_letter"] = "函",

  ["@@ld__mengda_letter-turn"] = "函",

  ["$ld__qiuan1"] = "明公神文圣武，吾自当举城来降。",
  ["$ld__qiuan2"] = "臣心不自安，乃君之过也。",
  ["$ld__liangfan1"] = "今举兵投魏，必可封王拜相，一展宏图。",
  ["$ld__liangfan2"] = "今举义军事若成，吾为复汉元勋也。",

  ["~ld__mengda"] = "吾一生寡信，今报应果然来矣...",
}

local zhanglu = General(extension, "ld__zhanglu", "qun", 3)
zhanglu.subkingdom = "wei"
local bushi = fk.CreateTriggerSkill{
  name = "ld__bushi",
  anim_type = "defensive",
  events = {fk.EventPhaseStart},
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(self) and target.phase == Player.Finish 
      and player:getMark("ld__bushi-turn") > 0 and #player:getPile("ld__midao_rice") > 0
  end,
  on_cost = function(self, event, target, player, data)
    local card = player.room:askForCard(player, 1, 1, false, self.name, true, ".|.|.|ld__midao_rice", "#ld__bushi_discard", "ld__midao_rice")
    if #card > 0 then
      self.cost_data = card
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    room:moveCardTo(self.cost_data, Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile, self.name, "ld__midao_rice", true, player.id)
    local targets = table.map(room.alive_players, Util.IdMapper)
    local tos = room:askForChoosePlayers(player, targets, 1, player.maxHp, "#ld__midao-choose", self.name, false)
    room:sortPlayersByAction(tos)
    if #tos == 0 then
      tos = table.random(targets, 1)
    end
    for _, id in ipairs(tos) do
      local p = room:getPlayerById(id)
      if not p.dead then
        p:drawCards(1, self.name)
      end
    end
    for _, id in ipairs(tos) do
      local p = room:getPlayerById(id)
      if not p.dead then
        local card = room:askForCard(p, 1, 1, true, self.name, true, nil, "#ld__bushi")
        if #card > 0 then
          player:addToPile("ld__midao_rice", card, true, self.name)
        end
      end
    end
  end,

  refresh_events = {fk.Damage, fk.Damaged},
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(self)
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:addPlayerMark(player, "ld__bushi-turn", 1)
  end,
}

local midao = fk.CreateTriggerSkill{
  name = "ld__midao",
  anim_type = "offensive",
  derived_piles = "ld__midao_rice",
  events = {fk.GeneralRevealed, fk.AskForRetrial},
  can_trigger = function (self, event, target, player, data)
    if event == fk.GeneralRevealed then
      if player:hasSkill(self) then
        for _, v in pairs(data) do
          if table.contains(Fk.generals[v]:getSkillNameList(), self.name) then return true end
        end
      end
    elseif event == fk.AskForRetrial then
      return player:hasSkill(self) and #player:getPile("ld__midao_rice") > 0
    end
  end,
  on_cost = function (self, event, target, player, data)
    if event == fk.GeneralRevealed then
      return true
    elseif event == fk.AskForRetrial then
      local card = player.room:askForCard(player, 1, 1, false, self.name, true, ".|.|.|ld__midao_rice", "#ld__midao-ask::" .. target.id .. ":" .. data.reason, "ld__midao_rice")
      if #card > 0 then
        self.cost_data = card[1]
        return true
      end
    end
  end,
  on_use = function (self, event, target, player, data)
    if event == fk.GeneralRevealed then
      player:drawCards(2, self.name)
      if player:isNude() then return end
      local dummy = Fk:cloneCard("dilu")
      local cards
      if #player:getCardIds("he") < 3 then
        cards = player:getCardIds("he")
      else
        cards = player.room:askForCard(player, 2, 2, true, self.name, false, ".", "#ld__midao")
      end
      dummy:addSubcards(cards)
      player:addToPile("ld__midao_rice", dummy, true, self.name)
    elseif event == fk.AskForRetrial then
      player.room:retrial(Fk:getCardById(self.cost_data), player, data, self.name, true)
    end
  end,
}

zhanglu:addSkill(bushi)
zhanglu:addSkill(midao)
Fk:loadTranslationTable{
  ["ld__zhanglu"] = "张鲁",
  ["#ld__zhanglu"] = "政宽教惠",
  -- ["designer:ld__zhanglu"] = "韩旭",
  ["illustrator:ld__zhanglu"] = "磐蒲",

  ["ld__bushi"] = "布施",
  [":ld__bushi"] = "一名角色的结束阶段，若你于此回合内造成或受到过伤害，你可移去一张“米”，令至多X名角色各摸一张牌（X为你的体力上限），以此法摸牌的角色可依次将一张牌置于你武将牌上，称为“米”。",
  ["ld__midao"] = "米道",
  [":ld__midao"] = "①当你明置此武将牌后，你摸两张牌，然后将两张牌置于武将牌上，称为“米”②一名角色的判定牌生效前，你可以打出一张“米”替换之。",

  ["$ld__bushi1"] = "争斗，永远没有赢家。",
  ["$ld__bushi2"] = "和平，永远没有输家。",
  ["$ld__midao1"] = "恩结天地，法惠八荒。",
  ["$ld__midao2"] = "行五斗米道，可知暖饱。",

  ["#ld__midao-choose"] = "布施：选择至多你体力上限数名角色各摸一张牌",
  ["#ld__bushi_discard"] = "布施：你可以移去一张“米”，令至多你体力上限名角色各摸一张牌。",
  ["#ld__bushi"] = "布施：你可以将一张牌置于张鲁武将牌上，称为“米”。",

  ["#ld__midao-ask"] = "米道：你可打出一张牌替换 %dest 的 %arg 判定",   
  ["#ld__midao"] = "米道：请将两张牌置于武将牌上，称为“米”。",

  ["ld__midao_rice"] = "米",

  ["~ld__zhanglu"] = "唉，义不敌武，道难御兵……",
}


local qtc = General(extension, "ld__mifangfushiren", "shu", 4)
qtc.subkingdom = "wu"
local fengshih = fk.CreateTriggerSkill{
  name = "ld__fengshih",
  anim_type = "offensive",
  events = {fk.TargetSpecified},
  can_trigger = function(self, event, target, player, data)
    if not (target == player and player:hasSkill(self) and #AimGroup:getAllTargets(data.tos) == 1) then return false end
    local target = player.room:getPlayerById(data.to)
    return player:getHandcardNum() > target:getHandcardNum() and not target:isNude()
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local target = room:getPlayerById(data.to)
    room:askForDiscard(player, 1, 1, true, self.name, false)
    if not target:isNude() then
      local cid = room:askForCardChosen(player, target, "he", self.name)
      room:throwCard({cid}, self.name, target, player)
    end
    data.additionalDamage = (data.additionalDamage or 0) + 1
  end,
}

local fengshih_back = fk.CreateTriggerSkill{
  name = "#ld__fengshih_back",
  mute = true,
  anim_type = "negative",
  events = {fk.TargetConfirmed},
  can_trigger = function(self, event, target, player, data)
    return target == player and H.hasShownSkill(player, fengshih) and not player:isNude() and #AimGroup:getAllTargets(data.tos) == 1
      and player:getHandcardNum() < player.room:getPlayerById(data.from):getHandcardNum()
  end,
  on_cost = function (self, event, target, player, data)
    return player.room:askForSkillInvoke(player.room:getPlayerById(data.from), self.name, nil, "#ld__fengshih_back-ask:" .. player.id) 
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke("ld__fengshih")
    room:notifySkillInvoked(player, "ld__fengshih", "negative")
    local cid = room:askForCardChosen(player, room:getPlayerById(data.from), "he", self.name)
    room:throwCard({cid}, self.name, room:getPlayerById(data.from), player)
    if not player:isNude() then
      room:askForDiscard(player, 1, 1, true, self.name, false)
    end
    data.additionalDamage = (data.additionalDamage or 0) + 1
  end,
}

fengshih:addRelatedSkill(fengshih_back)
qtc:addSkill(fengshih)

Fk:loadTranslationTable{
  ["ld__mifangfushiren"] = "糜芳傅士仁",
  ["#ld__mifangfushiren"] = "逐驾迎尘",
  ["designer:ld__mifangfushiren"] = "Loun老萌",
  ["illustrator:ld__mifangfushiren"] = "木美人",

  ["ld__fengshih"] = "锋势",
  [":ld__fengshih"] = "①当你使用牌指定其他角色为唯一目标后，若其手牌数小于你且你与其均有牌，你可以弃置你与其各一张牌，然后此牌造成伤害值+1；②当你成为其他角色使用牌的唯一目标后，若你手牌数小于其且你与其均有牌，其可以令你弃置你与其各一张牌，然后此牌造成伤害值+1。",

  ["#ld__fengshih_back"] = "锋势",
  ["#ld__fengshih_back-ask"] = "锋势：是否令%src弃置你与其各一张牌，然后此牌的伤害基数+1",

  ["$ld__fengshih1"] = "雪中送炭？倒不如落井下石！",
  ["$ld__fengshih2"] = "今发兵援羽，敢问是过是功？",

  ["~ld__mifangfushiren"] = "虞翻小儿，你安敢辱我！",
}

local shixie = General(extension, "hs__shixie", "qun", 3)
shixie.subkingdom = "wu"
local biluan = fk.CreateDistanceSkill{
  name = "hs__biluan",
  anim_type = "defensive",
  frequency = Skill.Compulsory,
  correct_func = function(self, from, to)
    if to:hasSkill(self) then
      return math.max(#to.player_cards[Player.Equip], 1)
    end
  end,
}

local lixia = fk.CreateTriggerSkill{
  name = "hs__lixia",
  anim_type = "offensive",
  events = {fk.EventPhaseStart},
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(self) and not H.compareKingdomWith(player, target) and H.hasShownSkill(player, self)
     and #player.player_cards[Player.Equip] > 0 and target.phase == Player.Start and not target.dead
  end,
  on_cost = function (self, event, target, player, data)
    return player.room:askForSkillInvoke(target, self.name, nil, "#hs__lixia-ask")
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local id = room:askForCardChosen(target, player, "e", self.name)
    room:throwCard({id}, self.name, player, target)
    local choices = {}
    if #target:getCardIds("he") > 1 then
      table.insert(choices, "hs__lixia_discard")
    end
    table.insert(choices, "hs__lixia_drawcards")
    if target.hp > 0 then
      table.insert(choices, "hs__lixia_loseHp")
    end
    local choice = room:askForChoice(target, choices, self.name)
    if choice == "hs__lixia_discard" then
      room:askForDiscard(target, 2, 2, true, self.name, false)
    elseif choice == "hs__lixia_drawcards" then
      player:drawCards(2, self.name)
    else
      room:loseHp(target, 1, self.name)
    end
  end,
}
shixie:addSkill(biluan)
shixie:addSkill(lixia)

Fk:loadTranslationTable{
  ["hs__shixie"] = "士燮",
  ["#hs__shixie"] = "百粤灵欹",
  ["designer:hs__shixie"] = "韩旭",
  ["illustrator:hs__shixie"] = "磐蒲",

  ["hs__biluan"] = "避乱",
  [":hs__biluan"] = "锁定技，其他角色计算与你的距离+X（X为你装备区内的牌数且至少为1）。",
  ["hs__lixia"] = "礼下",
  [":hs__lixia"] = "与你势力不同或未确定势力角色的准备阶段，其可弃置你装备区内的一张牌，然后选择一项：1.令你摸两张牌；2.弃置两张牌；3.失去1点体力。",

  ["#hs__lixia-ask"] = "礼下：是否弃置士燮一张装备区内的牌。",

  ["hs__lixia_discard"] = "弃置两张牌",
  ["hs__lixia_drawcards"] = "令士燮摸两张牌",
  ["hs__lixia_loseHp"] = "失去1点体力",

  ["$hs__lixia1"] = "将军真乃国之栋梁。",
  ["$hs__lixia2"] = "英雄可安身立命于交州之地。",

  ["~hs__shixie"] = "我这一生，足矣……",
}

local liuqi = General(extension, "ld__liuqi", "qun", 3)
liuqi.subkingdom = "shu"
local wenji = fk.CreateTriggerSkill{
  name = "ld__wenji",
  anim_type = "control",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Play and
      not table.every(player.room:getOtherPlayers(player), function(p) return (p:isNude()) end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local to = room:askForChoosePlayers(player, table.map(table.filter(room:getOtherPlayers(player), function(p)
      return not p:isNude() end), Util.IdMapper), 1, 1, "#wenji-choose", self.name, true)
    if #to > 0 then
      self.cost_data = to[1]
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(self.cost_data)
    local card = room:askForCard(to, 1, 1, true, self.name, false, ".", "#wenji-give::"..player.id)
    if H.compareKingdomWith(player, to, true) then
      if not player:isNude() then
        room:obtainCard(player.id, card[1], false, fk.ReasonGive)
        local card_back = room:askForCard(player, 1, 1, true, self.name, false, ".|.|.|.|.|.|^" .. card[1], "#wenji-give::"..to.id)
        room:obtainCard(to.id, card_back[1], false, fk.ReasonGive)
      end
    else
      room:obtainCard(player.id, card[1], false, fk.ReasonGive)
      room:setPlayerMark(player, "ld__wenji-turn", card[1])
    end
  end,
}

local wenji_targetmod = fk.CreateTargetModSkill{
  name = "#wenji_targetmod",
  bypass_times = function(self, player, skill, scope, card, to)
    return player:hasSkill(self) and card.id == player:getMark("ld__wenji-turn")
  end,
  bypass_distances =  function(self, player, skill, card, to)
    return player:hasSkill(self) and card.id == player:getMark("ld__wenji-turn")
  end,
}

local wenji_record = fk.CreateTriggerSkill{
  name = "#ld__wenji_record",
  mute = true,
  events = {fk.CardUsing},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:usedSkillTimes("ld__wenji", Player.HistoryTurn) > 0 and player:getMark("ld__wenji-turn") ~= 0 and
      player:getMark("ld__wenji-turn") == data.card.id
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data.disresponsiveList = data.disresponsiveList or {}
    for _, p in ipairs(player.room:getOtherPlayers(player)) do
      table.insertIfNeed(data.disresponsiveList, p.id)
    end
  end,
}

local tunjiang = fk.CreateTriggerSkill{
  name = "ld__tunjiang",
  anim_type = "drawcard",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    if not (target == player and player:hasSkill(self) and player.phase == Player.Finish) then return false end
    local targets, play_ids = {}, {}
    local ret = false
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
          ret = true
          for _, id in ipairs(TargetGroup:getRealTargets(use.tos)) do
            table.insertIfNeed(targets, id)
          end
          if #targets > 1 then return true end
        end
      end
    end, Player.HistoryTurn)
    return ret and (#targets == 0 or (#targets == 1 and targets[1] == player.id))
  end,
  on_use = function(self, event, target, player, data)
    local num = 0
    for _, v in pairs(H.getKingdomPlayersNum(player.room)) do
      if v and v > 0 then
        num = num + 1
      end
    end
    player:drawCards(num, self.name)
  end,
}

wenji:addRelatedSkill(wenji_targetmod)
wenji:addRelatedSkill(wenji_record)
liuqi:addSkill(tunjiang)
liuqi:addSkill(wenji)

Fk:loadTranslationTable{
  ["ld__liuqi"] = "刘琦",
  ["#ld__liuqi"] = "居外而安",
  ["designer:ld__liuqi"] = "荼蘼（韩旭）",
  ["illustrator:ld__liuqi"] = "绘聚艺堂",

  ["ld__wenji"] = "问计",
  [":ld__wenji"] = "出牌阶段开始时，你可令一名角色交给你一张牌，然后若其：与你势力相同或未确定势力，你于此回合内使用此牌无距离与次数限制且不能被响应；与你势力不同，你交给其另一张牌。",
  ["ld__tunjiang"] = "屯江",
  [":ld__tunjiang"] = "结束阶段，若你于此回合的出牌阶段内使用过牌且未指定过其他角色为目标，你可摸X张牌（X为场上势力数）。",

  ["#wenji-choose"] = "问计：选择一名其他角色，令其交给你一张牌，然后根据其势力执行不同效果。",
  ["#wenji-give"] = "问计：交给 %dest 一张牌",

  ["$ld__wenji1"] = "言出子口，入于吾耳，可以言未？",
  ["$ld__wenji2"] = "还望先生救我！。",
  ["$ld__tunjiang1"] = "皇叔勿惊，吾与关将军已到。",
  ["$ld__tunjiang2"] = "江夏冲要之地，孩儿愿往守之。",
  ["~ld__liuqi"] = "父亲，孩儿来，见你了。",
}

local tangzi = General(extension, "ld__tangzi", "wei", 4)
tangzi.subkingdom = "wu"
local xingzhao = fk.CreateTriggerSkill{
  name = "ld__xingzhao",
  anim_type = "drawcard",
  frequency = Skill.Compulsory,
  events = {fk.Damaged, fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) then
      if event == fk.Damaged then
        return #table.filter(player.room.alive_players, function(p) return p:isWounded() end) > 1 and target == player
      elseif event == fk.AfterCardsMove then
        if not (#table.filter(player.room.alive_players, function(p) return p:isWounded() end) > 3) then return false end
        for _, move in ipairs(data) do
          if move.from == player.id then
            for _, info in ipairs(move.moveInfo) do
              if info.fromArea == Card.PlayerEquip then
                return true
              end
            end
          end
        end
      else 
        return #table.filter(player.room.alive_players, function(p) return p:isWounded() end) > 2
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    if event == fk.AfterCardsMove then
      player:drawCards(1, self.name)
    elseif event == fk.Damaged then
      if player:getHandcardNum() < data.from:getHandcardNum() then
        player:drawCards(1, self.name)
      end
      if player:getHandcardNum() > data.from:getHandcardNum() then
        data.from:drawCards(1, self.name)
      end
    else
      return true
    end
  end,

  refresh_events = {fk.GeneralRevealed, fk.GeneralHidden, fk.EventLoseSkill, fk.HpChanged, fk.MaxHpChanged},
  can_refresh = function(self, event, target, player, data)
    if event == fk.GeneralRevealed or event == fk.GeneralHidden or event == fk.EventLoseSkill then
      return target == player
    else
      return true
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    if H.hasShownSkill(player, self.name) and #table.filter(room.alive_players, function(p) return p:isWounded() end) > 0 then
      room:handleAddLoseSkills(player, "ld__xunxun", nil, false, true)
    else
      room:handleAddLoseSkills(player, "-ld__xunxun", nil, false, true)
    end
  end,
}

local xingzhao_maxcards = fk.CreateMaxCardsSkill{
  name = "#ld__xingzhao_maxcards",
  correct_func = function(self, player)
    if player:hasSkill(self) and #table.filter(Fk:currentRoom().alive_players,
      function(p) return p:isWounded() end) >= 3 then
      return 4
    end
  end
}

local ld__xunxun = fk.CreateTriggerSkill{
  name = "ld__xunxun",
  anim_type = "control",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Draw
  end,
  on_use = function(self, event, target, player, data)
    player.room:askForGuanxing(player, player.room:getNCards(4), {2, 2}, {2, 2})
  end,
}

xingzhao:addRelatedSkill(xingzhao_maxcards)
tangzi:addSkill(xingzhao)
tangzi:addRelatedSkill(ld__xunxun)
Fk:loadTranslationTable{
  ["ld__tangzi"] = "唐咨",
  ["#ld__tangzi"] = "得时识风",
  ["designer:ld__tangzi"] = "荼蘼（韩旭）",
  ["illustrator:ld__tangzi"] = "凝聚永恒",

  ["ld__xingzhao"] = "兴棹",
  [":ld__xingzhao"] = "锁定技，场上受伤的角色数为：1个或以上，你拥有技能〖恂恂〗；2个或以上，你受到伤害后，你与伤害来源手牌数较少的角色摸一张牌；3个或以上，你的手牌上限+4；4个或以上，你失去装备区内的牌时，摸一张牌。",
  ["ld__xunxun"] = "恂恂",
  [":ld__xunxun"] = "摸牌阶段开始时，你可观看牌堆顶的四张牌，将其中两张牌以任意顺序置于牌堆顶，其余以任意顺序置于牌堆底。",

  ["$ld__xingzhao1"] = "精挑细选，方能成百年之计。",
  ["$ld__xingzhao2"] = "拿些上好的木料来。",
--   ["$ld__xunxun1"] = "让我先探他一探。",
--   ["$ld__xunxun2"] = "船，也不是一天就能造出来的。",
  ["~ld__tangzi"] = "偷工减料，要不得啊...",
}

local xiahouba = General(extension, "ld__xiahouba", "shu", 4)
xiahouba.subkingdom = "wei"
xiahouba:addCompanions("ld__jiangwei")
local baolie = fk.CreateTriggerSkill{
  name = "ld__baolie",
  anim_type = "offensive",
  events = {fk.EventPhaseStart},
  frequency = Skill.Compulsory,
  can_trigger = function (self, event, target, player, data)
    return player == target and player:hasSkill(self) and player.phase == Player.Play and H.getGeneralsRevealedNum(player) > 0
      and table.find(player.room.alive_players, function(p)
        return H.compareKingdomWith(p, player, true) and p:inMyAttackRange(player)
      end)
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local targets = table.map(table.filter(room:getOtherPlayers(player), function(p)
      return H.compareKingdomWith(p, player, true) and p:inMyAttackRange(player) end), Util.IdMapper)
    if #targets == 0 then return end
    room:doIndicate(player.id, targets)
    for _, p in ipairs(targets) do
      if player.dead then return end
      local to = room:getPlayerById(p)
      if not to.dead then
        local use = room:askForUseCard(to, "slash", "slash", "#baolie-use:" .. player.id, true, {include_targets = {player.id} })
        if use then
          use.extraUse = true
          room:useCard(use)
        elseif not to:isNude() then
          local card = room:askForCardChosen(player, to, "he", self.name)
          room:throwCard({card}, self.name, to, player)
        end
      end
    end
  end,
}

local baolie_targetmod = fk.CreateTargetModSkill{
  name = "#baolie_targetmod",
  bypass_times = function(self, player, skill, scope, card, to)
    return player:hasSkill(self) and to.hp >= player.hp and skill.trueName == "slash_skill"
  end,
  bypass_distances =  function(self, player, skill, card, to)
    return player:hasSkill(self) and to.hp >= player.hp and skill.trueName == "slash_skill"
  end,
}

baolie:addRelatedSkill(baolie_targetmod)
xiahouba:addSkill(baolie)

Fk:loadTranslationTable{
  ["ld__xiahouba"] = "夏侯霸",
  ["#ld__xiahouba"] = "棘途壮志",
  ["designer:ld__xiahouba"] = "逍遥鱼叔",
  ["illustrator:ld__xiahouba"] = "小牛",

  ["ld__baolie"] = "豹烈",
  [":ld__baolie"] = "锁定技，①出牌阶段开始时，你令所有与你势力不同且攻击范围内含有你的角色依次对你使用一张【杀】，否则你弃置其一张牌。②你对体力值不小于你的角色使用【杀】无距离与次数限制。",

  ["#baolie-use"] = "豹烈：对%src使用一张【杀】，否则其弃置你一张牌",

  ["$ld__baolie1"] = "废话少说，受死吧，喝！",
  ["$ld__baolie2"] = "当今曹营之将，一个能打的都没有！",
  ["~ld__xiahouba"] = "不好，有埋伏！呃！",
}

local panjun = General(extension, "ld__panjun", "wu", 3)
panjun.subkingdom = "shu"

local congcha = fk.CreateTriggerSkill{
  name = "ld__congcha",
  anim_type = "drawcard",
  events = {fk.EventPhaseStart, fk.DrawNCards},
  can_trigger = function (self, event, target, player, data)
    if not (target == player and player:hasSkill(self)) then return end
    if event == fk.EventPhaseStart then
      return player.phase == Player.Start and
        table.find(player.room:getOtherPlayers(player), function(p) return H.getGeneralsRevealedNum(p) == 0 end)
    else
      return player.phase == Player.Draw and
        table.every(player.room.alive_players, function(p) return H.getGeneralsRevealedNum(p) > 0 end)
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    if event == fk.EventPhaseStart then
      local targets = table.map(table.filter(room:getOtherPlayers(player), function(p)
        return H.getGeneralsRevealedNum(p) == 0 end), Util.IdMapper)
      if #targets == 0 then return false end
      local to = room:askForChoosePlayers(player, targets, 1, 1, "#ld__congcha_choose", self.name, true)
      if #to > 0 then
        target = room:getPlayerById(to[1])
        local record = U.getMark(target, "@@ld__congcha_delay")
        table.insert(record, player.id)
        room:setPlayerMark(target, "@@ld__congcha_delay", record)
        room:setPlayerMark(player, "_ld__congcha", target.id)
      end
    else
      data.n = data.n + 2
    end
  end,
}

local congcha_delay = fk.CreateTriggerSkill{
  name = "#ld__congcha_delay",
  anim_type = "offensive",
  events = {fk.GeneralRevealed},
  can_trigger = function (self, event, target, player, data)
    if target.dead or player.dead then return false end
    local mark = target:getMark("@@ld__congcha_delay")
    return type(mark) == "table" and table.contains(mark, player.id)
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    local room = player.room
    room:doIndicate(player.id, {target.id})
    local record = target:getMark("@@ld__congcha_delay")
    table.removeOne(record, player.id)
    if #record == 0 then record = 0 end
    room:setPlayerMark(target, "@@ld__congcha_delay", record)
    room:setPlayerMark(player, "_ld__congcha", 0)
    if H.compareKingdomWith(player, target) then
      local targets = {target.id, player.id}
      room:sortPlayersByAction(targets)
      for _, pid in ipairs(targets) do
        local p = room:getPlayerById(pid)
        if not p.dead then p:drawCards(2, self.name) end
      end
    else
      room:loseHp(target, 1, self.name)
    end
  end,

  refresh_events = {fk.TurnStart},
  can_refresh = function(self, event, target, player, data)
    return target == player and player:getMark("_ld__congcha") ~= 0
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    target = room:getPlayerById(player:getMark("_ld__congcha"))
    local record = U.getMark(target, "@@ld__congcha_delay")
    table.removeOne(record, player.id)
    if #record == 0 then record = 0 end
    room:setPlayerMark(target, "@@ld__congcha_delay", record)
    room:setPlayerMark(player, "_ld__congcha", 0)
  end,
}


panjun:addSkill(congcha)
congcha:addRelatedSkill(congcha_delay)
panjun:addSkill("gongqing")
Fk:loadTranslationTable{
  ["ld__panjun"] = "潘濬",
  ["#ld__panjun"] = "逆鳞之砥",
  ["illustrator:ld__panjun"] = "Domi",
  ["designer:ld__panjun"] = "逍遥鱼叔",

  ["ld__congcha"] = "聪察",
  [":ld__congcha"] = "①准备阶段，你可选择一名未确定势力的角色，然后直到你的下回合开始，当其明置武将牌后，若其确定势力且势力与你：相同，你与其各摸两张牌；不同，其失去1点体力。②摸牌阶段，若场上不存在未确定势力的角色，你可多摸两张牌。",

  ["@@ld__congcha_delay"] = "聪察",
  ["#ld__congcha_delay"] = "聪察",
  ["#ld__congcha_choose"] = "聪察：选择一名未确定势力的角色",

  ["$ld__congcha1"] = "窥一斑而知全豹。",
  ["$ld__congcha2"] = "问一事则明其心。",
  ["~ld__panjun"] = "密谋既泄，难处奸贼啊……",
}

local wenqin = General(extension, "ld__wenqin", "wei", 4)
wenqin.subkingdom = "wu"
local jinfa = fk.CreateActiveSkill{
  name = "ld__jinfa",
  anim_type = "offensive",
  card_num = 1,
  target_num = 1,
  can_use = function (self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0 and not player:isNude()
  end,
  card_filter = function(self, to_select, selected)
    return #selected == 0 and not Self:prohibitDiscard(to_select)
  end,
  target_filter = function(self, to_select, selected, selected_cards)
    local target = Fk:currentRoom():getPlayerById(to_select)
    return #selected == 0 and not target:isNude() and to_select ~= Self.id
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    room:throwCard(effect.cards, self.name, player, player)
    local card1 = room:askForCard(target, 1, 1, true, self.name, true, ".|.|.|.|.|equip", "ld__jinfa_give")
    if #card1 == 1 then
      room:obtainCard(player.id, card1[1], true, fk.ReasonGive)
      if Fk:getCardById(card1[1]).suit == Card.Spade then
        local card = Fk:cloneCard("slash")
        if not (target:prohibitUse(card) or target:isProhibited(player, card)) then
          room:useVirtualCard("slash", nil, target, player)
        end
      end
    else
      local card2 = room:askForCardChosen(player, target, "he", self.name)
      room:obtainCard(player, card2, false, fk.ReasonPrey)
    end
  end,
}

wenqin:addSkill(jinfa)
Fk:loadTranslationTable{
  ["ld__wenqin"] = "文钦",
  ["#ld__wenqin"] = "勇而无算",
  ["illustrator:ld__wenqin"] = "匠人绘-零二",
  ["designer:ld__wenqin"] = "逍遥鱼叔",

  ["ld__jinfa"] = "矜伐",
  [":ld__jinfa"] = "出牌阶段限一次，你可弃置一张牌并选择一名其他角色，令其选择一项：1.令你获得其一张牌；2.交给你一张装备牌，若此装备牌为♠，其视为对你使用一张【杀】。",

  ["ld__jinfa_give"] = "矜伐：交给文钦一张装备牌，否则文钦获得你的一张牌",

  ["$ld__jinfa1"] = "居功者，当自矜，为将者，当善伐。",
  ["$ld__jinfa2"] = "此战伐敌所获，皆我之功。",

  ["~ld__wenqin"] = "公休，汝这是何意，呃……",

}

local sufei = General(extension, "ld__sufei", "qun", 4)
sufei.subkingdom = "wu"
local zhengjian = fk.CreateTriggerSkill{
  name = "ld__zhengjian",
  anim_type = "defensive",
  events = {fk.EventPhaseStart},
  can_trigger = function (self, event, target, player, data)
    if not (H.compareKingdomWith(player, target) and target.phase == Player.Finish and player:hasSkill(self)) then return false end
    if target:getMark("@!companion") ~= 0 then return end
    local events = target.room.logic:getEventsOfScope(GameEvent.UseCard, 999, function(e) 
      local use = e.data[1]
      return use.from == target.id
    end, Player.HistoryTurn)
    return #events >= target.maxHp
  end,
  on_use = function (self, event, target, player, data)
    H.addHegMark(player.room, target, "companion")
    player.room:setPlayerMark(target, "ld__zhengjian", 1)
  end,

  refresh_events = {fk.TargetConfirmed, fk.Death, fk.EnterDying},
  can_refresh = function (self, event, target, player, data)
    if event == fk.TargetConfirmed then
      return player:hasSkill(self) and player == target and data.card.trueName == "slash"
    elseif event == fk.Death then
      return player:hasSkill(self.name, false, true) and player == target
    elseif event == fk.EnterDying then
      return player:hasSkill(self) and target:getMark("ld__zhengjian") > 0
    end
  end,
  on_refresh = function (self, event, target, player, data)
    if event == fk.TargetConfirmed or event == fk.Death then
      local targets = table.filter(player.room.alive_players, function(p) return p:getMark("ld__zhengjian") > 0 end)
      if #targets > 0 then
        for _, p in ipairs(targets) do
          player.room:setPlayerMark(p, "ld__zhengjian", 0)
        end
      end
    else
      player.room:setPlayerMark(target, "ld__zhengjian", 0)
    end
  end,
}

local zhengjian_prohibit = fk.CreateProhibitSkill{
  name = "#zhengjian_prohibit",
  prohibit_use = function(self, player, card)
    return card.trueName == "peach" and player:getMark("ld__zhengjian") > 0
  end,
}

sufei:addCompanions("hs__ganning")
zhengjian:addRelatedSkill(zhengjian_prohibit)
sufei:addSkill(zhengjian)
Fk:loadTranslationTable{
  ["ld__sufei"] = "苏飞",
  ["#ld__sufei"] = "诤友投明",
  -- ["designer:ld__sufei"] = "逍遥鱼叔",
  ["illustrator:ld__sufei"] = "Domi",

  ["ld__zhengjian"] = "诤荐",
  [":ld__zhengjian"] = "与你势力相同角色的结束阶段，若其本回合使用牌数不小于其体力上限且没有“珠联璧合”标记，你可令其获得一个“珠联璧合”标记，若如此做，其不能使用【桃】直至你成为【杀】的目标或其进入濒死状态。",

  ["$ld__zhengjian1"] = "需持续投入，方有回报。",
  ["$ld__zhengjian2"] = "心无旁骛，断而敢行。",

  ["~ld__sufei"] = "恐不能再与兴霸兄，并肩作战了……",
}

local xuyou = General(extension, "ld__xuyou", "qun", 3)
xuyou.subkingdom = "wei"
local chenglue = fk.CreateTriggerSkill{
  name = "ld__chenglue",
  anim_type = "drawcard",
  events = {fk.TargetSpecified},
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(self) and H.compareKingdomWith(target, player) and #AimGroup:getAllTargets(data.tos) > 1 and data.firstTarget
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, nil, "#ld__chenglue-ask:" .. target.id)
  end,
  on_use = function(self, event, target, player, data)
    if target:isAlive() then
      target:drawCards(1, self.name)
    end
    data.extra_data = data.extra_data or {}
    data.extra_data.ld__chenglueUser = data.extra_data.ld__chenglueUser or {}
    data.extra_data.ld__chenglueUser[player.id] = true
  end,
}
local chenglue_after = fk.CreateTriggerSkill{
  name = "#ld__chenglue_after",
  events = {fk.CardUseFinished},
  mute = true,
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return ((data.extra_data or {}).ld__chenglueUser or {})[player.id]
      and data.damageDealt and data.damageDealt[player.id]
  end,
  on_cost = function(self, event, target, player, data)
    local targets = table.map(table.filter(player.room.alive_players, function(p)
      return H.compareKingdomWith(p, player)
        and p:getMark("@!yinyangfish") == 0 and p:getMark("@!companion") == 0
        and p:getMark("@!wild") == 0 and p:getMark("@!vanguard") == 0
    end), Util.IdMapper)
    if #targets == 0 then return end
    local to = player.room:askForChoosePlayers(player, targets, 1, 1, "#ld__chenglue-give", self.name, true)
    if #to == 1 then
      self.cost_data = to[1]
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    H.addHegMark(player.room, player.room:getPlayerById(self.cost_data), "yinyangfish")
  end,
}
chenglue:addRelatedSkill(chenglue_after)

local shicai = fk.CreateTriggerSkill{
  name = "ld__shicai",
  mute = true,
  frequency = Skill.Compulsory,
  events = {fk.Damaged},
  on_use = function (self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke(self.name)
    if data.damage == 1 then
      room:notifySkillInvoked(player, self.name, "masochism")
      player:drawCards(1, self.name)
    else
      room:notifySkillInvoked(player, self.name, "negative")
      room:throwCard(player:getCardIds("h"), self.name, player, player)
    end
  end,
}

xuyou:addSkill(chenglue)
xuyou:addSkill(shicai)

Fk:loadTranslationTable{
  ["ld__xuyou"] = "许攸",
  ["#ld__xuyou"] = "毕方矫翼",
  ["designer:ld__xuyou"] = "逍遥鱼叔",
  ["illustrator:ld__xuyou"] = "猎枭",

  ["ld__chenglue"] = "成略",
  [":ld__chenglue"] = "当与你势力相同的角色使用牌指定目标后，若目标数大于1，你可令其摸一张牌。若如此做且你受到过此牌造成的伤害，此牌结算完成后，你可令一名与你势力相同且没有国战标记的角色获得一个“阴阳鱼”标记。",
  ["ld__shicai"] = "恃才",
  [":ld__shicai"] = "锁定技，当你受到伤害后，若此伤害为1点，你摸一张牌，否则你弃置所有手牌。",

  ["#ld__chenglue_after"] = "成略",
  ["#ld__chenglue-ask"] = "成略：你可令 %src 摸一张牌",
  ["#ld__chenglue-give"] = "成略：你可令一名与你势力相同且没有国战标记的角色获得一个“阴阳鱼”标记",

  ["$ld__chenglue1"] = "阿瞒，苦思之事，我早有良策。",
  ["$ld__chenglue2"] = "策略已有，按部就班即可得胜。",
  ["$ld__shicai1"] = "如此大胜，皆由我一人谋划。",
  ["$ld__shicai2"] = "画谋定计，谁堪与我比较。",
  ["~ld__xuyou"] = "阿瞒，你竟忘恩负义！！",
}

local pengyang = General(extension, "ld__pengyang", "shu", 3)
pengyang.subkingdom = "qun"
local tongling = fk.CreateTriggerSkill{
  name = "ld__tongling",
  anim_type = "offensive",
  events = {fk.Damage},
  can_trigger = function (self, event, target, player, data)
    return player == target and player:hasSkill(self) and player:usedSkillTimes(self.name, Player.HistoryPhase) == 0 and not data.to.dead
      and not H.compareKingdomWith(player, data.to) and player.phase == Player.Play
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local targets = table.map(table.filter(room.alive_players, function(p)
      return H.compareKingdomWith(p, player) end), Util.IdMapper)
    if #targets > 0 then
      local victim = data.to.id
      local to = room:askForChoosePlayers(player, targets, 1, 1, "#ld__tongling-choose::" .. victim, self.name, true)
      if #to > 0 then
        local user = room:getPlayerById(to[1])
        local cardNames = {}
        local selfCards = {"peach", "analeptic", "ex_nihilo"} -- FIXME: how to tell ex_niholo from AOE and AG?
        for _, id in ipairs(user:getCardIds(Player.Hand)) do
          local card = Fk:getCardById(id)
          if card.skill:modTargetFilter(victim, {}, user.id, card, true) and not table.contains(selfCards, card.name) and card.type ~= Card.TypeEquip then -- FIXME
            table.insert(cardNames, card.name)
          end
        end
        local prompt = data.card and "#ld__tongling_card-use:" .. player.id .. ":" .. victim .. ":" .. data.card:toLogString() or "#ld__tongling_nocard-use:" .. player.id .. ":" .. data.to.id
        local use = room:askForUseCard(user, "", table.concat(cardNames, ","), prompt, true, {include_targets = {victim}, bypass_times = true }) -- ……
        if use then
          use.extra_data = use.extra_data or {}
          use.extra_data.ld__tonglingUser = player.id
          if data.card then
            use.extra_data.ld__tonglingCard = data.card
          end
          use.extra_data.ld__tonglingTo = victim
          use.extra_data.ld__tonglingFrom = to[1]
          use.extraUse = true
          room:useCard(use)
        end
      end
    end
  end,
}

local tongling_delay = fk.CreateTriggerSkill{
  name = "#ld__tongling_delay",
  anim_type = "offensive",
  mute = true,
  events = {fk.CardUseFinished},
  can_trigger = function (self, event, target, player, data)
    return (data.extra_data or {}).ld__tonglingUser == player.id
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    local room = player.room
    if data.damageDealt then
      local other = room:getPlayerById(data.extra_data.ld__tonglingFrom)
      if other ~= player then
        player:drawCards(2, self.name)
      end
      other:drawCards(2, self.name)
    else
      local card = data.extra_data.ld__tonglingCard
      if not card then return end
      if U.hasFullRealCard(room, card) then
        room:obtainCard(room:getPlayerById(data.extra_data.ld__tonglingTo),
          card, false, fk.ReasonJustMove)
      end
    end
  end,
}


local jinxian = fk.CreateTriggerSkill{
  name = "ld__jinxian",
  anim_type = "offensive",
  events = {fk.GeneralRevealed},
  can_trigger = function(self, event, target, player, data)
    if player == target and player:hasSkill(self) then
      for _, v in pairs(data) do
        if table.contains(Fk.generals[v]:getSkillNameList(), self.name) then return true end
      end
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local targets = table.map(table.filter(room.alive_players, function(p) return player:distanceTo(p) <= 1 and player:distanceTo(p) >= 0 end), Util.IdMapper)
    room:sortPlayersByAction(targets)
    for _, id in ipairs(targets) do
      local p = room:getPlayerById(id)
      if not p.dead then
        if H.getGeneralsRevealedNum(p) == 2 then
            H.doHideGeneral(room, p, p, self.name)
        else
          room:askForDiscard(p, 2, 2, true, self.name, false)
        end
      end
    end
  end,
}

tongling:addRelatedSkill(tongling_delay)
pengyang:addSkill(tongling)
pengyang:addSkill(jinxian)

Fk:loadTranslationTable{
  ["ld__pengyang"] = "彭羕",
  ["#ld__pengyang"] = "误身的狂士",
  ["illustrator:ld__pengyang"] = "匠人绘-零一",
  ["designer:ld__pengyang"] = "韩旭",

  ["ld__tongling"] = "通令",
  ["#ld__tongling_delay"] = "通令",
  [":ld__tongling"] = "每阶段限一次，当你于出牌阶段内对其它势力角色造成伤害后，你可令一名与你势力相同的角色对其使用一张牌，然后若此牌：造成伤害，你与其各摸两张牌；未造成伤害，其获得你对其造成伤害的牌。",

  ["#ld__tongling-choose"] = "通令：选择一名与你势力相同的角色，其可以对%dest使用一张牌",
  ["#ld__tongling_card-use"] = "通令：你可对 %dest 使用一张牌，若此牌造成伤害，你与 %src 各摸两张牌，若此牌未造成伤害，受伤角色获得%arg",
  ["#ld__tongling_nocard-use"] = "通令：你可对 %dest 使用一张牌，若此牌造成伤害，你与 %src 各摸两张牌",

  ["ld__jinxian"] = "近陷",
  [":ld__jinxian"] = "当你明置此武将牌后，你令所有你计算距离不大于1的角色执行：若其武将牌均明置，暗置一张武将牌（若为你则改为此阶段结束时暗置）；若其武将牌仅明置一张或均暗置，其弃置两张牌。",

  ["$ld__tongling1"] = "孝直溢美之言，特以此小利报之，还望笑纳。",
  ["$ld__tongling2"] = "孟起，莫非甘心为他人座下之客。",
  ["$ld__jinxian1"] = "如此荒辈之徒为主，成何用也。",
  ["$ld__jinxian2"] = "公既如此，恕在下诚难留之。",
  ["~ld__pengyang"] = "人言我心大志寡，难可保安，果然如此，唉……",
}


local zhonghui = General(extension, "ld__zhonghui", "wild", 4)
zhonghui:addCompanions("ld__jiangwei")
local quanji = fk.CreateTriggerSkill{
  name = "ld__quanji",
  mute = true,
  derived_piles = "ld__zhonghui_power",
  events = {fk.Damaged, fk.Damage},
  can_trigger = function(self, event, target, player, data)
    if target ~= player or not player:hasSkill(self) or player.dead then return false end
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
    return player:hasSkill(self) and #player:getPile("ld__zhonghui_power") or 0
  end,
}
quanji:addRelatedSkill(quanji_maxcards)
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
  ["#ld__zhonghui"] = "桀骜的野心家",
  ["designer:ld__zhonghui"] = "韩旭",
  ["illustrator:ld__zhonghui"] = "磐蒲",

  ["ld__quanji"] = "权计",
  [":ld__quanji"] = "每回合各限一次，当你受到伤害后或当你造成伤害后，你可摸一张牌，然后将一张牌置于武将牌上（称为“权”）；你的手牌上限+X（X为“权”数）。",
  ["ld__paiyi"] = "排异",
  [":ld__paiyi"] = "出牌阶段限一次，你可将一张“权”置入弃牌堆并选择一名角色，其摸X张牌，若其手牌数大于你，你对其造成1点伤害（X为“权”的数量且至多为7）。",

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
    return player:hasSkill(self) and player == target and not player:isKongcheng()
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, nil, "#ld__zhaoxin-ask")
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:showCards(player.player_cards[Player.Hand])
    local targets = table.map(table.filter(room:getOtherPlayers(player, false), function(p)
      return (p:getHandcardNum() <= player:getHandcardNum()) end), Util.IdMapper)
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
    if player:hasSkill(self) and player:getMark("@ld__suzhi-turn") < 3 and room.current == player then
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
    if target == player and player:hasSkill(self) and data.from and not data.from.dead then
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
  ["#ld__simazhao"] = "嘲风开天",
  ["designer:ld__simazhao"] = "韩旭",
  ["illustrator:ld__simazhao"] = "凝聚永恒",

  ["ld__zhaoxin"] = "昭心",
  [":ld__zhaoxin"] = "当你受到伤害后，你可展示所有手牌，然后与一名手牌数不大于你的角色交换手牌。",
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

local sunchen = General(extension, "ld__sunchen", "wild", 4)
local shilus = fk.CreateTriggerSkill{
  name = "shilus",
  anim_type = "drawcard",
  events = {fk.Deathed, fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self) then return false end
    if event == fk.EventPhaseStart then
      return player == target and player.phase == Player.Start and type(player:getMark("@&massacre")) == "table" and #player:getMark("@&massacre") > 0
    elseif event == fk.Deathed then
      return true
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if event == fk.EventPhaseStart then
      local x = #player:getMark("@&massacre")
      local cards = room:askForDiscard(player, 1, x, true, self.name, true, ".", "#shilus-cost:::" .. tostring(x), true)
      if #cards > 0 then
        self.cost_data = cards
        return true
      end
    else
      if room:askForSkillInvoke(player, self.name, nil, "#shilus-invoke::"..target.id) then
        room:doIndicate(player.id, {target.id})
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.EventPhaseStart then
      room:throwCard(self.cost_data, self.name, player, player)
      if not player.dead then
        room:drawCards(player, #self.cost_data, self.name)
      end
    elseif event == fk.Deathed then
      local cards = {}
      if not target.general:startsWith("blank_") and target.general ~= "anjiang" then
        room:findGeneral(target.general)
        table.insert(cards, target.general)
      end
      if target.deputyGeneral and target.deputyGeneral ~= "" and not target.deputyGeneral:startsWith("blank_") and target.deputyGeneral ~= "anjiang" then
        room:findGeneral(target.deputyGeneral)
        table.insert(cards, target.deputyGeneral)
      end
      if data.damage and data.damage.from == player then
        table.insertTableIfNeed(cards, room:getNGenerals(2))
      end
      if #cards > 0 then
        local generals = player:getMark("@&massacre")
        if generals == 0 then generals = {} end
        table.insertTableIfNeed(generals, cards)
        room:setPlayerMark(player, "@&massacre", generals)
      end
    end
  end,

  refresh_events = {fk.EventLoseSkill, fk.GeneralHidden, fk.BuryVictim},
  can_refresh = function(self, event, target, player, data)
    if player:getMark("@&massacre") == 0 or player ~= target then return false end
    if event == fk.EventLoseSkill then
      return data == self
    elseif event == fk.BuryVictim then
      return true
    elseif event == fk.GeneralHidden then
      return table.contains(Fk.generals[data]:getSkillNameList(), self.name)
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    room:returnToGeneralPile(U.getMark(player, "@&massacre"), "bottom")
    room:setPlayerMark(player, "@&massacre", 0)
  end,
}
local xiongnve = fk.CreateTriggerSkill{
  name = "xiongnve",
  anim_type = "drawcard",
  events = {fk.EventPhaseStart, fk.EventPhaseEnd},
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if player == target and player:hasSkill(self) and player.phase == Player.Play then
      local x = type(player:getMark("@&massacre")) == "table" and #player:getMark("@&massacre") or 0
      return x > 1 or (event == fk.EventPhaseStart and x == 1)
    end
  end,
  on_cost = function(self, event, target, player, data)
    if event == fk.EventPhaseStart then
      local result = player.room:askForCustomDialog(player, self.name,
        "packages/utility/qml/ChooseGeneralsAndChoiceBox.qml", {
          player:getMark("@&massacre"),
          {"xiongnve_choice1", "xiongnve_choice2", "xiongnve_choice3"},
          "#xiongnve-chooose",
          {"Cancel"}
        })
      if result ~= "" then
        local reply = json.decode(result)
        if reply.choice ~= "Cancel" then
          self.cost_data = {reply.cards, reply.choice}
          return true
        end
      end
    else
      local result = player.room:askForCustomDialog(player, self.name,
      "packages/utility/qml/ChooseGeneralsAndChoiceBox.qml", {
        player:getMark("@&massacre"),
        {"OK"},
        "#xiongnve-defence",
        {"Cancel"},
        2,
        2
      })
      if result ~= "" then
        local reply = json.decode(result)
        if reply.choice == "OK" then
          self.cost_data = {reply.cards}
          return true
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke(self.name)
    if event == fk.EventPhaseStart then
      room:notifySkillInvoked(player, self.name, self.cost_data[2] == "xiongnve_choice2" and "control" or "offensive")
    else
      room:notifySkillInvoked(player, self.name, "defensive")
    end
    room:returnToGeneralPile(self.cost_data[1], "bottom")
    local generals = player:getMark("@&massacre")
    if generals == 0 then generals = {} end
    for _, name in ipairs(self.cost_data[1]) do
      table.removeOne(generals, name)
    end
    room:setPlayerMark(player, "@&massacre", generals)
    if event == fk.EventPhaseStart then
      room:setPlayerMark(player, "@xiongnve_choice-phase", "xiongnve_effect" .. string.sub(self.cost_data[2], 16, 16))
      local general = Fk.generals[self.cost_data[1][1]]
      local kingdoms = {general.kingdom}
      if general.subkingdom then
        table.insert(kingdoms, general.subkingdom)
      end
      room:setPlayerMark(player, "@xiongnve_kindom-phase", kingdoms)
    elseif event == fk.EventPhaseEnd then
      room:setPlayerMark(player, "@xiongnve_choice", "xiongnve_defence")
    end
  end,

  refresh_events = {fk.TurnStart},
  can_refresh = function(self, event, target, player, data)
    return target == player and player:getMark("@xiongnve_choice") ~= 0
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@xiongnve_choice", 0)
  end,
}

local function compareXiongNveKingdom(player, target)
  local mark = player:getMark("@xiongnve_kindom-phase")
  return type(mark) == "table" and table.contains(mark, target.kingdom)
end

local xiongnve_delay = fk.CreateTriggerSkill{
  name = "#xiongnve_delay",
  events = {fk.DamageCaused, fk.DamageInflicted},
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if player.dead or player ~= target then return false end
    if event == fk.DamageCaused then
      if not data.to.dead and compareXiongNveKingdom(player, data.to) then
        local effect_name = player:getMark("@xiongnve_choice-phase")
        if effect_name == "xiongnve_effect1" then
          return true
        elseif effect_name == "xiongnve_effect2" then
          return #data.to.player_cards[Player.Equip] > 0 or (not data.to:isKongcheng() and data.to ~= player)
        end
      end
    else
      return player:getMark("@xiongnve_choice") == "xiongnve_defence" and data.from and data.from ~= player
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke("xiongnve")
    if event == fk.DamageCaused then
      room:doIndicate(player.id, {data.to.id})
      local effect_name = player:getMark("@xiongnve_choice-phase")
      if effect_name == "xiongnve_effect1" then
        room:notifySkillInvoked(player, self.name, "offensive")
        data.damage = data.damage + 1
      elseif effect_name == "xiongnve_effect2" then
        room:notifySkillInvoked(player, self.name, "control")
        local flag =  data.to == player and "e" or "he"
        local card = room:askForCardChosen(player, data.to, flag, self.name)
        room:obtainCard(player.id, card, false, fk.ReasonPrey)
      end
    else
      room:notifySkillInvoked(player, self.name, "defensive")
      data.damage = data.damage - 1
    end
  end,
}
local xiongnve_targetmod = fk.CreateTargetModSkill{
  name = "#xiongnve_targetmod",
  bypass_times = function(self, player, skill, scope, card, to)
    return to and player:getMark("@xiongnve_choice-phase") == "xiongnve_effect3" and compareXiongNveKingdom(player, to)
  end,
}
xiongnve:addRelatedSkill(xiongnve_delay)
xiongnve:addRelatedSkill(xiongnve_targetmod)
sunchen:addSkill(shilus)
sunchen:addSkill(xiongnve)

Fk:loadTranslationTable{
  ["ld__sunchen"] = "孙綝",
  ["#ld__sunchen"] = "食髓的朝堂客",
  ["designer:ld__sunchen"] = "逍遥鱼叔",
  ["illustrator:ld__sunchen"] = "depp",

  ["shilus"] = "嗜戮",
  [":shilus"] = "当一名角色死亡后，你可将其所有武将牌置于你的武将牌旁（称为“戮”），若你为来源，你从剩余武将牌堆额外获得两张“戮”。"..
  "准备阶段，你可以弃置至多X张牌（X为“戮”数），摸等量的牌。",
  ["xiongnve"] = "凶虐",
  [":xiongnve"] = "出牌阶段开始时，你可以移去一张“戮”，令你本回合对此“戮”势力角色获得下列效果中的一项："..
  "1.对其造成伤害时，令此伤害+1；2.对其造成伤害时，你获得其一张牌；3.对其使用牌无次数限制。"..
  "出牌阶段结束时，你可以移去两张“戮”，然后直到你的下回合，当你受到其他角色造成的伤害时，此伤害-1。",

  ["@&massacre"] = "戮",
  ["#shilus-cost"] = "发动 嗜戮，弃置至多%arg张牌并摸等量的牌",
  ["#shilus-invoke"] = "发动 嗜戮，获得%dest的武将牌作为“戮”",

  ["#xiongnve-chooose"] = "发动 凶虐，弃置一张“戮”，获得一项效果",
  ["xiongnve_choice1"] = "增加伤害",
  ["xiongnve_choice2"] = "造成伤害时拿牌",
  ["xiongnve_choice3"] = "用牌无次数限制",
  ["#xiongnve-defence"] = "发动 凶虐，弃置两张“戮”，直到下回合，受到伤害-1",

  ["@xiongnve_choice-phase"] = "凶虐",
  ["@xiongnve_kindom-phase"] = "凶虐",
  ["@xiongnve_choice"] = "凶虐",
  ["xiongnve_defence"] = "减少伤害",
  ["xiongnve_effect1"] = "增加伤害",
  ["xiongnve_effect2"] = "造伤拿牌",
  ["xiongnve_effect3"] = "无限用牌",
  
  ["#xiongnve_delay"] = "凶虐",

  ["$shilus1"] = "以杀立威，谁敢反我？",
  ["$shilus2"] = "将这些乱臣贼子，尽皆诛之！",
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
      return (not p:isNude()) end), Util.IdMapper), 1, #throw, "#ld__huaiyi-choose:::"..tostring(#throw), self.name, true)
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
  derived_piles = "ld__gongsunyuan_infidelity",
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self) or player ~= target then return false end
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
  ["#ld__gongsunyuan"] = "狡黠的投机者",
  ["designer:ld__gongsunyuan"] = "逍遥鱼叔",
  ["illustrator:ld__gongsunyuan"] = "猎枭",

  ["ld__huaiyi"] = "怀异",
  [":ld__huaiyi"] = "出牌阶段限一次，你可展示所有手牌，若其中包含两种颜色，则你弃置其中一种颜色的牌，然后获得至多X名角色的各一张牌"..
  "（X为你以此法弃置的手牌数）。你将以此法获得的装备牌置于武将牌上（称为“异”）。",
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

