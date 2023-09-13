local extension = Package:new("formation")
extension.extensionName = "hegemony"
extension.game_modes_whitelist = { 'nos_heg_mode', 'new_heg_mode' }

local H = require "packages/hegemony/util"

Fk:loadTranslationTable{
  ["formation"] = "君临天下·阵",
  ["ld"] = "君临",
}

local dengai = General(extension, "ld__dengai", "wei", 4)
dengai.mainMaxHpAdjustedValue = -1
local tuntian = fk.CreateTriggerSkill{
  name = "ld__tuntian",
  anim_type = "special",
  events = {fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self.name) and player.phase == Player.NotActive then
      for _, move in ipairs(data) do
        if move.from == player.id then
          for _, info in ipairs(move.moveInfo) do
            if info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip then
              return true
            end
          end
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local judge = {
      who = player,
      reason = self.name,
      pattern = ".|.|spade,club,diamond",
    }
    room:judge(judge)
    if judge.card.suit ~= Card.Heart and room:getCardArea(judge.card.id) == Card.DiscardPile and room:askForChoice(player, {"ld__tuntian_field:::" .. judge.card:toLogString(), "Cancel"}, self.name) ~= "Cancel" then
      player:addToPile("ld__dengai_field", judge.card, true, self.name)
    end
  end,
}
local tuntian_distance = fk.CreateDistanceSkill{
  name = "#ld__tuntian_distance",
  correct_func = function(self, from, to)
    if from:hasSkill(self.name) then
      return -#from:getPile("ld__dengai_field")
    end
  end,
}
tuntian:addRelatedSkill(tuntian_distance)
H.CreateClearSkill(tuntian, "ld__dengai_field")

local jixi = fk.CreateViewAsSkill{
  name = "ld__jixi",
  anim_type = "control",
  pattern = "snatch",
  relate_to_place = "m",
  expand_pile = "ld__dengai_field",
  enabled_at_play = function(self, player)
    return #player:getPile("ld__dengai_field") > 0
  end,
  enabled_at_response = function(self, player)
    return #player:getPile("ld__dengai_field") > 0
  end,
  card_filter = function(self, to_select, selected)
    return #selected == 0 and Self:getPileNameOfId(to_select) == "ld__dengai_field"
  end,
  view_as = function(self, cards)
    if #cards ~= 1 then
      return nil
    end
    local c = Fk:cloneCard("snatch")
    c.skillName = self.name
    c:addSubcard(cards[1])
    return c
  end,
}

local ziliang = fk.CreateTriggerSkill{
  name = "ziliang",
  anim_type = "support",
  relate_to_place = "d",
  events = {fk.Damaged},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self.name) and H.compareKingdomWith(player, target) and not target.dead and #player:getPile("ld__dengai_field") > 0
  end,
  on_cost = function(self, event, target, player, data)
    local card = player.room:askForCard(player, 1, 1, false, self.name, true, ".|.|.|ld__dengai_field", "#ziliang-card::" .. target.id, "ld__dengai_field")
    if #card > 0 then
      self.cost_data = card
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:moveCardTo(self.cost_data, Card.PlayerHand, target, fk.ReasonGive, self.name, "ld__dengai_field", true, player.id)
  end,
}

dengai:addSkill(tuntian)
dengai:addSkill(jixi)
dengai:addSkill(ziliang)

Fk:loadTranslationTable{
  ["ld__dengai"] = "邓艾",
  ["ld__tuntian"] = "屯田",
  [":ld__tuntian"] = "当你于回合外失去牌后，你可判定：若结果不为<font color='red'>♥</font>，你可将弃牌堆里的此判定牌置于武将牌上（称为“田”）。你至其他角色的距离-X（X为“田”数）。",
  ["ld__jixi"] = "急袭",
  [":ld__jixi"] = "主将技，此武将牌上的单独阴阳鱼个数-1。你可将一张“田”当【顺手牵羊】使用。",
  ["ziliang"] = "资粮",
  [":ziliang"] = "副将技，当与你势力相同的一名角色受到伤害后，你可将一张“田”交给其。",

  ["ld__dengai_field"] = "田",
  ["ld__tuntian_field"] = "将%arg置于武将牌上（称为“田”）",
  ["#ziliang-card"] = "资粮：你可将一张“田”交给 %dest",

  ["$ld__tuntian1"] = "留得良田在，何愁不破敌？",
  ["$ld__tuntian2"] = "击鼓于此，以致四方。",
  ["$ziliang1"] = "兵，断不可无粮啊。",
  ["$ziliang2"] = "吃饱了，才有力气为国效力。",
  ["$ld__jixi1"] = "谁占到先机，谁就胜了。",
  ["$ld__jixi2"] = "哪里走！！",
  ["~ld__dengai"] = "君不知臣，臣不知君。罢了……罢了！",
}
--[[
local jiangwei = General(extension, "ld__jiangwei", "shu", 4)
jiangwei:addCompanions("hs__zhugeliang")
jiangwei.deputyMaxHpAdjustedValue = -1
local tianfu = H.CreateBattleArraySkill{
  name = 'tianfu',
  -- relate_to_place = 'm',
  array_type = "formation",
  refresh_events = {fk.RoundStart},
  can_refresh = function(self, event, target, player, data)
    return player:hasSkill(self.name, true, true) and not player:isFakeSkill(self.name)
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local formation = H.getFormationRelation(target)
    room:handleAddLoseSkills(player, (table.contains(formation, player) or (target == player and #formation > 0)) and #room.alive_players > 3 and 'tianfu' or "-tianfu", nil)
  end,
}
jiangwei:addSkill("tiaoxin")
jiangwei:addSkill(tianfu)

Fk:loadTranslationTable{
  ["ld__jiangwei"] = "姜维",
  ["tianfu"] = "天覆",
}
]]
local jiangfei = General(extension, "ld__jiangwanfeiyi", "shu", 3)
local shengxi = fk.CreateTriggerSkill{
  name = "ld__shengxi",
  anim_type = "drawcard",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return player == target and player:hasSkill(self.name) and player.phase == Player.Finish and 
      #player.room.logic:getEventsOfScope(GameEvent.ChangeHp, 1, function (e)
        local damage = e.data[5]
        if damage and target == damage.from then
          return true
        end
      end, Player.HistoryTurn) == 0
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(2, self.name)
  end,
}

local shoucheng = fk.CreateTriggerSkill{
  name = "shoucheng",
  anim_type = "support",
  events = {fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self.name) then return end
    for _, move in ipairs(data) do
      if move.from then
        local from = player.room:getPlayerById(move.from)
        if from:isKongcheng() and H.compareKingdomWith(from, player) and from.phase == Player.NotActive then
          for _, info in ipairs(move.moveInfo) do
            if info.fromArea == Card.PlayerHand then
              return true
            end
          end
        end
      end
    end
  end,
  on_trigger = function(self, event, target, player, data)
    local targets = {}
    local room = player.room
    for _, move in ipairs(data) do
      if move.from then
        local from = room:getPlayerById(move.from)
        if from:isKongcheng() and H.compareKingdomWith(from, player) and from.phase == Player.NotActive then
          for _, info in ipairs(move.moveInfo) do
            if info.fromArea == Card.PlayerHand then
              table.insertIfNeed(targets, from.id)
            end
          end
        end
      end
    end
    room:sortPlayersByAction(targets)
    for _, p in ipairs(targets) do
      local to = room:getPlayerById(p)
      if to.dead or not player:hasSkill(self.name) then break end
      self:doCost(event, p, player, nil)
    end
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, nil, "#shoucheng-draw::" .. target)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:doIndicate(player.id, {target})
    room:getPlayerById(target):drawCards(1, self.name)
  end,
}

jiangfei:addSkill(shengxi)
jiangfei:addSkill(shoucheng)
jiangfei:addCompanions("hs__zhugeliang")

Fk:loadTranslationTable{
  ["ld__jiangwanfeiyi"] = "蒋琬费祎",
  ["ld__shengxi"] = "生息",
  [":ld__shengxi"] = "结束阶段开始时，若你未于此回合内造成过伤害，你可摸两张牌。",
  ["shoucheng"] = "守成",
  [":shoucheng"] = "与你势力相同的角色于其回合外失去最后的手牌后，你可令其摸一张牌。",

  ["#shoucheng-draw"] = "守成：你可令 %dest 摸一张牌",

  ["$ld__shengxi1"] = "国之生计，在民生息。",
  ["$ld__shengxi2"] = "安民止战，兴汉室！",
  ["$shoucheng1"] = "待吾等助将军一臂之力！",
  ["$shoucheng2"] = "国库盈余，可助军威。",
  ["~ld__jiangwanfeiyi"] = "墨守成规，终为其害啊……",
}

local xusheng = General(extension, "ld__xusheng", "wu", 4)

local yicheng = fk.CreateTriggerSkill{
  name = "yicheng",
  anim_type = "defensive",
  events = {fk.TargetConfirmed},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self.name) and H.compareKingdomWith(target, player) and data.card.trueName == "slash"
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, nil, "#yicheng-ask::" .. target.id)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:doIndicate(player.id, {target.id})
    target:drawCards(1, self.name)
    if not target.dead then
      room:askForDiscard(target, 1, 1, true, self.name, false)
    end
  end
}

xusheng:addSkill(yicheng)
xusheng:addCompanions("hs__dingfeng")

Fk:loadTranslationTable{
  ["ld__xusheng"] = "徐盛",
  ["yicheng"] = "疑城",
  [":yicheng"] = "当一名与你势力相同的角色成为【杀】的目标后，你可令其摸一张牌，然后其弃置一张牌。",

  ["#yicheng-ask"] = "疑城：你可令 %dest 摸一张牌，然后其弃置一张牌",

  ["$yicheng1"] = "不怕死，就尽管放马过来！",
  ["$yicheng2"] = "待末将布下疑城，以退曹贼。",
  ["~ld__xusheng"] = "可怜一身胆略，尽随一抔黄土……",
}

local yuji = General(extension, "ld__yuji", "qun", 3)
local qianhuan = fk.CreateTriggerSkill{
  name = "qianhuan",
  events = {fk.Damaged, fk.TargetConfirming, fk.BeforeCardsMove},
  anim_type = "defensive",
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self.name) then return false end
    if event == fk.Damaged then
      return not target.dead and H.compareKingdomWith(target, player) and not player:isNude() and #player:getPile("yuji_sorcery") < 4
    elseif event == fk.TargetConfirming then
      return H.compareKingdomWith(target, player) and #player:getPile("yuji_sorcery") > 0 and
      (data.card.type == Card.TypeBasic or data.card:isCommonTrick()) and #AimGroup:getAllTargets(data.tos) == 1
    elseif event == fk.BeforeCardsMove then
      for _, move in ipairs(data) do
        if move.to ~= nil and move.toArea == Card.PlayerJudge then
          local friend = player.room:getPlayerById(move.to)
          return H.compareKingdomWith(friend, player) and #move.moveInfo > 0
        end
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local card = {}
    local room = player.room
    if event == fk.Damaged then
      local suits = {}
      for _, id in ipairs(player:getPile("yuji_sorcery")) do
        table.insert(suits, Fk:getCardById(id):getSuitString())
      end
      suits = table.concat(suits, ",")
      card = room:askForCard(player, 1, 1, true, self.name, true, ".|.|^(" .. suits .. ")", "#qianhuan-dmg", "yuji_sorcery")
    elseif event == fk.TargetConfirming then
      card = room:askForCard(player, 1, 1, false, self.name, true, ".|.|.|yuji_sorcery", "#qianhuan-def::" .. target.id .. ":" .. data.card:toLogString(), "yuji_sorcery")
    elseif event == fk.BeforeCardsMove then
      local delayed_trick = nil
      local friend = nil
      for _, move in ipairs(data) do
        if move.to ~= nil and move.toArea == Card.PlayerJudge then
          friend = move.to
          for _, info in ipairs(move.moveInfo) do
            local id = info.cardId
            local source = player
            if info.fromArea == Card.PlayerJudge then
              source = room:getPlayerById(move.from) or player
            end
            delayed_trick = source:getVirualEquip(id)
            if delayed_trick == nil then delayed_trick = Fk:getCardById(id) end
            break
          end
          if delayed_trick then break end
        end
      end
      if delayed_trick then
        card = player.room:askForCard(player, 1, 1, false, self.name, true, ".|.|.|yuji_sorcery",
        "#qianhuan-def::" .. friend .. ":" .. delayed_trick:toLogString(), "yuji_sorcery")
      end
    end
    if #card > 0 then
      self.cost_data = card
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke("qianhuan")
    if event == fk.Damaged then
      room:notifySkillInvoked(player, "qianhuan", "masochism")
      player:addToPile("yuji_sorcery", self.cost_data, true, self.name)
    elseif event == fk.TargetConfirming then
      room:notifySkillInvoked(player, "qianhuan", "defensive")
      room:moveCardTo(self.cost_data, Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile, self.name, "yuji_sorcery")
      AimGroup:cancelTarget(data, target.id)
    elseif event == fk.BeforeCardsMove then
      room:moveCardTo(self.cost_data, Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile, self.name, "yuji_sorcery")
      local mirror_moves = {}
      local ids = {}
      for _, move in ipairs(data) do
        if move.toArea == Card.PlayerJudge then
          local move_info = {}
          local mirror_info = {}
          for _, info in ipairs(move.moveInfo) do
            local id = info.cardId
            table.insert(mirror_info, info)
            table.insert(ids, id)
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
  end,
}
yuji:addSkill(qianhuan)
H.CreateClearSkill(qianhuan, "yuji_sorcery")
Fk:loadTranslationTable{
  ["ld__yuji"] = "于吉",
  ["qianhuan"] = "千幻",
  [":qianhuan"] = "当一名与你势力相同的角色受到伤害后，你可将一张与你武将牌上花色均不同的牌置于你的武将牌上（称为“幻”）。当一名与你势力相同的角色成为基本牌或锦囊牌的唯一目标时，你可将一张“幻”置入弃牌堆，取消此目标。",

  ["#qianhuan-dmg"] = "千幻：你可一张与“幻”花色均不同的牌置于你的武将牌上（称为“幻”）",
  ["#qianhuan-def"] = "千幻：你可一张“幻”置入弃牌堆，取消%arg的目标 %dest",
  ["yuji_sorcery"] = "幻",

  ["$qianhuan1"] = "幻化于阴阳，藏匿于乾坤。",
  ["$qianhuan2"] = "幻变迷踪，虽飞鸟亦难觅踪迹。",
  ["~ld__yuji"] = "幻化之物，终是算不得真呐。",
}

local hetaihou = General(extension, "ld__hetaihou", "qun", 3, 3, General.Female)
hetaihou:addSkill("zhendu")
hetaihou:addSkill("qiluan")
Fk:loadTranslationTable{
  ["ld__hetaihou"] = "何太后",
  ["~ld__hetaihou"] = "你们男人造的孽，非要说什么红颜祸水……",
}

return extension
