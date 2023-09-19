local H = require "packages/hegemony/util"
local extension = Package:new("lord_ex")
extension.extensionName = "hegemony"
extension.game_modes_whitelist = { 'nos_heg_mode', 'new_heg_mode' }

Fk:loadTranslationTable{
  ["lord_ex"] = "君临天下·EX/不臣篇",
}

local dongzhao = General(extension, "ld__dongzhao", "wei", 3)

local quanjin = fk.CreateActiveSkill{
  name = "quanjin",
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
    return target == player and player:hasSkill(self.name) and data.card:isCommonTrick()
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
    return player:hasSkill(self.name) and H.compareKingdomWith(player, data.to)
     and data.damage >= data.to.hp
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
    return "#ld__paiyi-active:::" .. #Self:getPile("ld__zhonghui_power") - 1
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

local function swapHandCards(room, from, to1, to2, skillname)
  local target1 = room:getPlayerById(to1)
  local target2 = room:getPlayerById(to2)
  local cards1 = table.clone(target1.player_cards[Player.Hand])
  local cards2 = table.clone(target2.player_cards[Player.Hand])
  local moveInfos = {}
  if #cards1 > 0 then
    table.insert(moveInfos, {
      from = to1,
      ids = cards1,
      toArea = Card.Processing,
      moveReason = fk.ReasonExchange,
      proposer = from,
      skillName = skillname,
    })
  end
  if #cards2 > 0 then
    table.insert(moveInfos, {
      from = to2,
      ids = cards2,
      toArea = Card.Processing,
      moveReason = fk.ReasonExchange,
      proposer = from,
      skillName = skillname,
    })
  end
  if #moveInfos > 0 then
    room:moveCards(table.unpack(moveInfos))
  end
  moveInfos = {}
  if not target2.dead then
    local to_ex_cards1 = table.filter(cards1, function (id)
      return room:getCardArea(id) == Card.Processing
    end)
    if #to_ex_cards1 > 0 then
      table.insert(moveInfos, {
        ids = to_ex_cards1,
        fromArea = Card.Processing,
        to = to2,
        toArea = Card.PlayerHand,
        moveReason = fk.ReasonExchange,
        proposer = from,
        skillName = skillname,
      })
    end
  end
  if not target1.dead then
    local to_ex_cards2 = table.filter(cards2, function (id)
      return room:getCardArea(id) == Card.Processing
    end)
    if #to_ex_cards2 > 0 then
      table.insert(moveInfos, {
        ids = to_ex_cards2,
        fromArea = Card.Processing,
        to = to1,
        toArea = Card.PlayerHand,
        moveReason = fk.ReasonExchange,
        proposer = from,
        skillName = skillname,
      })
    end
  end
  if #moveInfos > 0 then
    room:moveCards(table.unpack(moveInfos))
  end
  table.insertTable(cards1, cards2)
  local dis_cards = table.filter(cards1, function (id)
    return room:getCardArea(id) == Card.Processing
  end)
  if #dis_cards > 0 then
    local dummy = Fk:cloneCard("dilu")
    dummy:addSubcards(dis_cards)
    room:moveCardTo(dummy, Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile, skillname)
  end
end

local simazhao = General(extension, "ld__simazhao", "wei", 3)
local zhaoxin = fk.CreateTriggerSkill{
  name = "ld__zhaoxin",
  anim_type = "control",
  events = {fk.Damaged},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self.name) and #player:getCardIds("h") > 0 and not player.dead and player == target
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, nil, "#ld__zhaoxin-ask") 
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = player.player_cards[Player.Hand]
    player:showCards(cards)
    local targets = table.map(table.filter(room:getOtherPlayers(player), function(p)
      return (p:getHandcardNum() <= player:getHandcardNum()) end), function(p) return p.id end)
    if #targets > 0 then
      local to = room:getPlayerById(room:askForChoosePlayers(player, targets, 1, 1, nil, self.name, true)[1])
      swapHandCards(room, player.id, player.id, to.id, self.name)
    end
  end,
}

local suzhi = fk.CreateTriggerSkill{
  name = "ld__suzhi",
  anim_type = "offensive",
  mute = true,
  frequency = Skill.Compulsory,
  events = {fk.CardUsing, fk.DamageCaused, fk.AfterCardsMove, fk.EventPhaseChanging},
  can_trigger = function(self, event, target, player, data)
    if player:getMark("@ld__suzhi-turn") < 3 and player.room.current == player then
      if event == fk.EventPhaseChanging then
        return (data.to == player.NotActive or data.from == player.NotActive) and player == target and player:hasSkill(self.name)
      end

      if event == fk.CardUsing then
        return target == player and player:hasSkill(self.name) and data.card:isCommonTrick() and
        (not data.card:isVirtual() or #data.card.subcards == 0)
      end
      if event == fk.DamageCaused then
        return target == player and player:hasSkill(self.name) and
        not data.chain and data.card and (data.card.trueName == "slash" or data.card.name == "duel")
      end
      if event == fk.AfterCardsMove and player:hasSkill(self.name) then
        for _, move in ipairs(data) do
          if move.from ~= player.id and move.moveReason == fk.ReasonDiscard then
            for _, info in ipairs(move.moveInfo) do
              if info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip then
                self.cost_data = move.from
                return true
              end
            end
          end
        end
      end
    end
  end,

  on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.EventPhaseChanging then
      if data.from == player.NotActive then
        if player:getMark("@ld__fankui_simazhao") > 0 then
          room:setPlayerMark(player, "@ld__fankui_simazhao", 0)
          room:handleAddLoseSkills(player, "-fankui-simazhao", nil)
        end
        room:handleAddLoseSkills(player, "#ld__suzhi_target", nil)
      elseif data.to == player.NotActive then
        room:setPlayerMark(player, "@ld__fankui_simazhao", 1)
        room:handleAddLoseSkills(player, "fankui-simazhao", nil)
        if player:getMark("@ld__suzhi-turn") < 3 then
          room:handleAddLoseSkills(player, "-#ld__suzhi_target", nil)
        end
      end
    elseif event == fk.CardUsing or event == fk.DamageCaused or event == fk.AfterCardsMove then
      if event == fk.CardUsing then
        player:drawCards(1, self.name)
      elseif event == fk.DamageCaused then
        data.damage = data.damage + 1
      elseif event == fk.AfterCardsMove then
        local card = room:askForCardChosen(player, room:getPlayerById(self.cost_data), "he", self.name)
        room:obtainCard(player.id, card, false, fk.ReasonPrey)
      end
      room:setPlayerMark(player, "@ld__suzhi-turn", player:getMark("@ld__suzhi-turn") + 1)
      if player:getMark("@ld__suzhi-turn") >= 3 then
        room:handleAddLoseSkills(player, "-#ld__suzhi_target", nil)
      end
    end
  end,
}

local fankui_simazhao = fk.CreateTriggerSkill{
  name = "fankui-simazhao",
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
    local flag =  from == player and "e" or "he"
    local card = room:askForCardChosen(player, from, flag, self.name)
    room:obtainCard(player.id, card, false, fk.ReasonPrey)
  end
}

local suzhi_target = fk.CreateTargetModSkill{
  name = "#ld__suzhi_target",
  frequency = Skill.Compulsory,
  bypass_distances = function(self, player, skill, card)
    return player:hasSkill(self.name) and card and card.type == Card.TypeTrick
  end,
}

Fk:addSkill(fankui_simazhao)
Fk:addSkill(suzhi_target)
simazhao:addSkill(zhaoxin)
simazhao:addSkill(suzhi)
Fk:loadTranslationTable{
  ["ld__simazhao"] = "司马昭",
  ["ld__zhaoxin"] = "昭心",
  [":ld__zhaoxin"] = "当你受到伤害后，你可以展示所有手牌，然后与一名手牌数不大于你的角色交换手牌",
  ["#ld__zhaoxin-ask"] = "昭心：你可以展示所有手牌，然后与一名手牌数不大于你的角色交换手牌",
  
  ["ld__suzhi"] = "夙智",
  [":ld__suzhi"] = "锁定技，你的回合内：1.你执行【杀】或【决斗】的效果而造成伤害时，此伤害+1；2.你使用普通锦囊牌时摸一张牌且无距离限制；3.其他角色的牌被弃置后，你获得其一张牌"..
    "当你于一回合内触发上述效果三次后，此技能于此回合内失效。回合结束时，你获得“反馈”直至回合开始。",
  ["@ld__suzhi-turn"] = "夙智",
  ["@ld__fankui_simazhao"] = "拥有 反馈",

  ["fankui-simazhao"] = "反馈",

  ["$ld__zhaoxin1"] = "向你摊牌吧，我只有这个想法。",
  ["$ld__zhaoxin2"] = "大局已定，你要投降，还是投死？",
  ["$ld__suzhi1"] = "想封侯？给你一剑封喉！",
  ["$ld__suzhi2"] = "弱者，只怨别人强大，自己反省一下。",
  ["$ld__suzhi3"] = "孙家跨不过的槛，孔明翻不过的山，都不在我眼内。",
  ["$ld__suzhi4"] = "有人说我为国开疆太操心，这心呐，不操不行。",
  ["$ld__suzhi5"] = "弃子，也有它的作用",
  ["$ld__suzhi6"] = "人在绝望时，突然捞他一把，也许还你三代。",
  
  ["$fankui-simazhao1"] = "小小试探，紧张个啥？",
  ["$fankui-simazhao2"] = "事不过三，你懂的",

  ["~ld__simazhao"] = "志虽弥坚，也难挡众口铄金...",
}


local gongsunyuan = General(extension, "ld__gongsunyuan", "wild", 4)
local huaiyi = fk.CreateActiveSkill{
  name = "ld__huaiyi",
  anim_type = "control",
  card_num = 0,
  target_num = 0,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0 and not player:isKongcheng()
  end,
  card_filter = function()
    return false
  end,
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
      local get = {}
      for _, p in ipairs(targets) do
        local id = room:askForCardChosen(player, room:getPlayerById(p), "he", self.name)
        table.insert(get, id)
      end
      for _, id in ipairs(get) do
        room:obtainCard(player, id, false, fk.ReasonPrey)
        if Fk:getCardById(id).type == Card.TypeEquip then
          player:addToPile("ld__gongsunyuan_infidelity", Fk:getCardById(id), true, self.name)
        end
      end
    end
  end,
}

local zisui = fk.CreateTriggerSkill{
  name = "ld__zisui",
  anim_type = "drawcard",
  frequency = Skill.Compulsory,
  events = {fk.DrawNCards, fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    if event == fk.DrawNCards and player:hasSkill(self.name) and #player:getPile("ld__gongsunyuan_infidelity") > 0 then
      return true
    elseif event == fk.EventPhaseStart and player.phase == Player.Finish and #player:getPile("ld__gongsunyuan_infidelity") > player.maxHp then
      return true
    end
  end,
  on_cost = function(self, event, target, player, data)
    return true
  end,
  on_use = function(self, event, target, player, data)
    if event == fk.DrawNCards then
      data.n = data.n + #player:getPile("ld__gongsunyuan_infidelity")
    elseif fk.EventPhaseStart then
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
  ["#ld__huaiyi-choose"] = "怀异：你可以获得至多%arg名角色各一张牌",
  ["ld__gongsunyuan_infidelity"] = "异",

  ["ld__zisui"] = "恣睢",
  [":ld__zisui"] = "锁定技，摸牌阶段，你多摸“异”数量的牌。结束阶段，若“异”数量大于你的体力上限，你死亡。",

  ["$ld__huaiyi1"] = "魏隔山，吴隔海，想活，照我意思做。",
  ["$ld__huaiyi2"] = "我已给出条件，要钱，要命，由你说。",
  ["$ld__zisui1"] = "北风吹醒群狼日，丈夫复兴辽东时。",
  ["$ld__zisui2"] = "你可知道，我公孙家等了几个世代。",
  ["~ld__gongsunyuan"] = "说我公孙家是反贼，司马家有忠臣吗，呃啊啊...",
}


return extension

