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

return extension
