local extension = Package:new("formation")
extension.extensionName = "hegemony"
extension.game_modes_whitelist = { 'nos_heg_mode', 'new_heg_mode' }

local H = require "packages/hegemony/util"
local U = require "packages/utility/utility"

Fk:loadTranslationTable{
  ["formation"] = "君临天下·阵",
  ["ld"] = "君临",
}

local dengai = General(extension, "ld__dengai", "wei", 4)
dengai.mainMaxHpAdjustedValue = -1
local tuntian = fk.CreateTriggerSkill{
  name = "ld__tuntian",
  anim_type = "special",
  derived_piles = "ld__dengai_field",
  events = {fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) and player.phase == Player.NotActive then
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
    if judge.card.suit ~= Card.Heart and room:getCardArea(judge.card.id) == Card.DiscardPile and
      room:askForSkillInvoke(player, self.name, nil, "ld__tuntian_field:::" .. judge.card:toLogString()) then
      player:addToPile("ld__dengai_field", judge.card, true, self.name)
    end
  end,
}
local tuntian_distance = fk.CreateDistanceSkill{
  name = "#ld__tuntian_distance",
  correct_func = function(self, from, to)
    if from:hasSkill(self) then
      return -#from:getPile("ld__dengai_field")
    end
  end,
}
tuntian:addRelatedSkill(tuntian_distance)

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
    return player:hasSkill(self) and H.compareKingdomWith(player, target) and not target.dead and #player:getPile("ld__dengai_field") > 0
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
  ["#ld__dengai"] = "矫然的壮士",
  ["designer:ld__dengai"] = "KayaK（淬毒）",
  ["illustrator:ld__dengai"] = "Amo",

  ["ld__tuntian"] = "屯田",
  [":ld__tuntian"] = "当你于回合外失去牌后，你可判定：若结果不为<font color='red'>♥</font>，你可将弃牌堆里的此判定牌置于武将牌上（称为“田”）。你至其他角色的距离-X（X为“田”数）。",
  ["ld__jixi"] = "急袭",
  [":ld__jixi"] = "主将技，此武将牌上的单独阴阳鱼个数-1。你可将一张“田”当【顺手牵羊】使用。",
  ["ziliang"] = "资粮",
  [":ziliang"] = "副将技，当与你势力相同的角色受到伤害后，你可将一张“田”交给其。",

  ["ld__dengai_field"] = "田",
  ["ld__tuntian_field"] = "屯田：将%arg置于武将牌上（称为“田”）",
  ["#ziliang-card"] = "资粮：你可将一张“田”交给 %dest",

  ["$ld__tuntian1"] = "留得良田在，何愁不破敌？",
  ["$ld__tuntian2"] = "击鼓于此，以致四方。",
  ["$ziliang1"] = "兵，断不可无粮啊。",
  ["$ziliang2"] = "吃饱了，才有力气为国效力。",
  ["$ld__jixi1"] = "谁占到先机，谁就胜了。",
  ["$ld__jixi2"] = "哪里走！！",
  ["~ld__dengai"] = "君不知臣，臣不知君。罢了……罢了！",
}

local caohong = General(extension, "ld__caohong", "wei", 4)

local heyi = H.CreateArraySummonSkill{
  name = "heyi",
  array_type = "formation",
}
local heyiTrig = fk.CreateTriggerSkill{ -- FIXME
  name = '#heyi_trigger',
  visible = false,
  frequency = Skill.Compulsory,
  refresh_events = {fk.TurnStart, fk.GeneralRevealed, fk.EventAcquireSkill, "fk.RemoveStateChanged", fk.EventLoseSkill, fk.GeneralHidden},
  can_refresh = function(self, event, target, player, data)
    if event == fk.EventLoseSkill then return data == heyi
    elseif event == fk.GeneralHidden then return player == target 
    else return H.hasShownSkill(player, self.name, true, true) end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room

    local ret = #room.alive_players > 3 and player:hasSkill(self)
    for _, p in ipairs(room.alive_players) do
      if H.inFormationRelation(p, player) then
        room:handleAddLoseSkills(p, ret and 'ld__feiying' or "-ld__feiying", nil, false, true)
      end
    end
  end,
}
heyi:addRelatedSkill(heyiTrig)
local feiying = fk.CreateDistanceSkill{
  name = "ld__feiying",
  correct_func = function(self, from, to)
    if to:hasSkill(self) then
      return 1
    end
    return 0
  end,
}

local huyuan = fk.CreateTriggerSkill{
  name = 'ld__huyuan',
  anim_type = "defensive",
  events = {fk.EventPhaseStart},
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(self) and player.phase == Player.Finish and not player:isNude()
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local choices = {}
    if not player:isKongcheng() then
      table.insert(choices, "ld__huyuan_give")
    end
    local cards = player.player_cards[Player.Hand]
    if #player:getCardIds("e") > 0 then
      table.insert(choices, "ld__huyuan_equip")
    else
      for _, id in ipairs(cards) do
        if Fk:getCardById(id).type == Card.TypeEquip then
          table.insert(choices, "ld__huyuan_equip")
          break
        end
      end
    end

    local choice = room:askForChoice(player, choices, self.name)
    if choice == "ld__huyuan_give" then
      local card = room:askForCard(player, 1, 1, true, self.name, false, ".", nil)
      local dummy2 = Fk:cloneCard("dilu")
      dummy2:addSubcards(card)
      local targets = table.map(room:getOtherPlayers(player, false), Util.IdMapper)
      local to = room:askForChoosePlayers(player, targets, 1, 1, "#ld__huyuan-choose", self.name, false, true)
      room:obtainCard(room:getPlayerById(to[1]), dummy2, false, fk.ReasonGive)
    elseif choice == "ld__huyuan_equip" then
      local card = room:askForCard(player, 1, 1, true, self.name, false, ".|.|.|.|.|equip", nil)
      local targets = table.map(table.filter(room.alive_players, function(p) 
        return p:hasEmptyEquipSlot(Fk:getCardById(card[1]).sub_type) end), Util.IdMapper)
      local to = room:askForChoosePlayers(player, targets, 1, 1, "#ld__huyuan-choose", self.name, false, true)
      room:moveCards({
        ids = card,
        from = player.id,
        to = to[1],
        toArea = Card.PlayerEquip,
        moveReason = fk.ReasonPut,
      })
      local targets2 = table.map(table.filter(room.alive_players, function(p) 
        return #p:getCardIds("ej") > 0 end), Util.IdMapper)
      local to2 = room:askForChoosePlayers(player, targets2, 1, 1, "#ld__huyuan_discard-choose", self.name, false, true)
      local cid = room:askForCardChosen(player, room:getPlayerById(to2[1]), "ej", self.name)
      room:throwCard({cid}, self.name, room:getPlayerById(to2[1]), player)
    end
  end,
}

caohong:addSkill(heyi)
caohong:addSkill(huyuan)
Fk:addSkill(feiying)
caohong:addCompanions("hs__caoren")
Fk:loadTranslationTable{
  ["ld__caohong"] = "曹洪",
  ["#ld__caohong"] = "魏之福将",
  ["designer:ld__caohong"] = "韩旭（淬毒）",
  ["illustrator:ld__caohong"] = "YellowKiss",
  ["cv:ld__caohong"] = "绯川陵彦",

  ["heyi"] = "鹤翼",
  [":heyi"] = "阵法技，与你处于同一队列的角色拥有〖飞影〗。",
  ["ld__huyuan"] = "护援",
  [":ld__huyuan"] = "结束阶段，你可选择一项：1.交给一名其他角色一张手牌；2.将一张装备牌置入一名角色的装备区，然后弃置场上的一张牌。",

  ["ld__huyuan_give"] = "交给一名其他角色一张手牌",
  ["ld__huyuan_equip"] = "将一张装备牌置入一名角色的装备区",

  ["#ld__huyuan-choose"] = "护援：选择一名角色",
  ["#ld__huyuan_discard-choose"] = "护援：选择一名角色，弃置其场上的一张牌",

  ["ld__feiying"] = "飞影",
  [":ld__feiying"] = "锁定技，其他角色计算与你的距离+1。",

  ["$ld__huyuan1"] = "舍命献马，护我曹公！",
  ["$ld__huyuan2"] = "拼将性命，定保曹公周全。",
  ["~ld__caohong"] = "曹公，可安好...",

}

local jiangwei = General(extension, "ld__jiangwei", "shu", 4)
jiangwei:addCompanions("hs__zhugeliang")
jiangwei.deputyMaxHpAdjustedValue = -1
local tianfu = H.CreateArraySummonSkill{
  name = "tianfu",
  array_type = "formation",
  relate_to_place = "m",
}
local tianfuTrig = fk.CreateTriggerSkill{ -- FIXME
  name = '#tianfu_trigger',
  visible = false,
  frequency = Skill.Compulsory,
  refresh_events = {fk.TurnStart, fk.GeneralRevealed, fk.EventAcquireSkill, "fk.RemoveStateChanged", fk.EventLoseSkill, fk.GeneralHidden},
  can_refresh = function(self, event, target, player, data)
    if event == fk.EventLoseSkill then return data == tianfu
    elseif event == fk.GeneralHidden then return player == target
    else return H.hasShownSkill(player, self.name, true, true) end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local ret = H.inFormationRelation(room.current, player) and #room.alive_players > 3 and player:hasSkill(self)
    room:handleAddLoseSkills(player, ret and 'ld__kanpo' or "-ld__kanpo", nil, false, true)
  end,
}
tianfu:addRelatedSkill(tianfuTrig)
local kanpo = fk.CreateViewAsSkill{
  name = "ld__kanpo",
  anim_type = "control",
  pattern = "nullification",
  prompt = "#kanpo",
  card_filter = function(self, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).color == Card.Black and Fk:currentRoom():getCardArea(to_select) == Player.Hand
  end,
  view_as = function(self, cards)
    if #cards ~= 1 then return end
    local card = Fk:cloneCard("nullification")
    card.skillName = self.name
    card:addSubcard(cards[1])
    return card
  end,
}

local yizhi = fk.CreateTriggerSkill{
  name = "yizhi",
  refresh_events = {fk.GeneralRevealed, fk.GeneralHidden, fk.EventLoseSkill},
  relate_to_place = "d",
  frequency = Skill.Compulsory,
  can_refresh = function(self, event, target, player, data)
    return target == player
  end,
  on_refresh = function(self, event, target, player, data)
    local has_head_guanxing = false
    for _, sname in ipairs(Fk.generals[player.general]:getSkillNameList()) do
      if Fk.skills[sname].trueName == "guanxing" then
        has_head_guanxing = true
        break
      end
    end
    local ret = H.hasShownSkill(player, self.name) and not (has_head_guanxing and player.general ~= "anjiang")
    player.room:handleAddLoseSkills(player, ret and "ld__guanxing" or "-ld__guanxing", nil, false, true)
  end
}
local guanxing = fk.CreateTriggerSkill{
  name = "ld__guanxing",
  anim_type = "control",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and
      player.phase == Player.Start
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:askForGuanxing(player, room:getNCards(math.min(5, #room.alive_players)))
  end,
}

jiangwei:addSkill("tiaoxin")
jiangwei:addSkill(tianfu)
jiangwei:addRelatedSkill(kanpo)
jiangwei:addSkill(yizhi)
jiangwei:addRelatedSkill(guanxing)

Fk:loadTranslationTable{
  ["ld__jiangwei"] = "姜维",
  ["#ld__jiangwei"] = "龙的衣钵",
  ["designer:ld__jiangwei"] = "KayaK（淬毒）",
  ["illustrator:ld__jiangwei"] = "木美人",

  ["tianfu"] = "天覆",
  [":tianfu"] = "主将技，阵法技，你于与你处于同一队列的角色的回合内拥有〖看破〗。",
  ["yizhi"] = "遗志",
  [":yizhi"] = "副将技，此武将牌上单独的阴阳鱼个数-1；若你的主将的武将牌：有〖观星〗且处于明置状态，此〖观星〗改为固定观看五张牌；没有〖观星〗或处于暗置状态，你拥有〖观星〗。",

  ["ld__kanpo"] = "看破",
  [":ld__kanpo"] = "你可将一张黑色手牌当【无懈可击】使用。",
  ["ld__guanxing"] = "观星",
  [":ld__guanxing"] = "准备阶段，你可将牌堆顶的X张牌（X为角色数且至多为5}）扣置入处理区（对你可见），你将其中任意数量的牌置于牌堆顶，将其余的牌置于牌堆底。",

  ["$tiaoxin_ld__jiangwei1"] = "小小娃娃，乳臭未干。",
  ["$tiaoxin_ld__jiangwei2"] = "快滚回去，叫你主将出来！",
  ["$ld__kanpo1"] = "丞相已教我识得此计。",
  ["$ld__kanpo2"] = "哼！有破绽！",
  ["$ld__guanxing1"] = "天文地理，丞相所教，维铭记于心。",
  ["$ld__guanxing2"] = "哪怕只有一线生机，我也不会放弃！",
  ["~ld__jiangwei"] = "臣等正欲死战，陛下何故先降？",
}

local jiangfei = General(extension, "ld__jiangwanfeiyi", "shu", 3)
local shengxi = fk.CreateTriggerSkill{
  name = "ld__shengxi",
  anim_type = "drawcard",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return player == target and player:hasSkill(self) and player.phase == Player.Finish and 
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
    if not player:hasSkill(self) then return end
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
      if to.dead or not player:hasSkill(self) then break end
      self:doCost(event, to, player, nil)
    end
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, nil, "#shoucheng-draw::" .. target.id)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:doIndicate(player.id, {target.id})
    target:drawCards(1, self.name)
  end,
}

jiangfei:addSkill(shengxi)
jiangfei:addSkill(shoucheng)
jiangfei:addCompanions("hs__zhugeliang")

Fk:loadTranslationTable{
  ["ld__jiangwanfeiyi"] = "蒋琬费祎",
  ["#ld__jiangwanfeiyi"] = "社稷股肱",
  ["designer:ld__jiangwanfeiyi"] = "淬毒",
  ["illustrator:ld__jiangwanfeiyi"] = "cometrue",

  ["ld__shengxi"] = "生息",
  [":ld__shengxi"] = "结束阶段开始时，若你于此回合内未造成过伤害，你可摸两张牌。",
  ["shoucheng"] = "守成",
  [":shoucheng"] = "与你势力相同的角色于其回合外失去手牌后，若其没有手牌，你可令其摸一张牌。",

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
    return player:hasSkill(self) and H.compareKingdomWith(target, player) and data.card.trueName == "slash"
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
  ["#ld__xusheng"] = "江东的铁壁",
  ["designer:ld__xusheng"] = "淬毒",
  ["illustrator:ld__xusheng"] = "天信",
  ["yicheng"] = "疑城",
  [":yicheng"] = "当与你势力相同的角色成为【杀】的目标后，你可令其摸一张牌，然后其弃置一张牌。",

  ["#yicheng-ask"] = "疑城：你可令 %dest 摸一张牌，然后其弃置一张牌",

  ["$yicheng1"] = "不怕死，就尽管放马过来！",
  ["$yicheng2"] = "待末将布下疑城，以退曹贼。",
  ["~ld__xusheng"] = "可怜一身胆略，尽随一抔黄土……",
}

local jiangqin = General(extension, "ld__jiangqin", "wu", 4)

local niaoxiang = H.CreateArraySummonSkill{
  name = "niaoxiang",
  array_type = "siege",
}
local niaoxiangTrigger = fk.CreateTriggerSkill{
  name = "#niaoxiang_trigger",
  visible = false,
  events = {fk.TargetSpecified},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and data.card.trueName == "slash" and H.inSiegeRelation(target, player, player.room:getPlayerById(data.to)) 
      and #player.room.alive_players > 3
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data.fixedResponseTimes = data.fixedResponseTimes or {}
    data.fixedResponseTimes["jink"] = 2
  end
}

local shangyi = fk.CreateActiveSkill{
  name = 'ld__shangyi',
  anim_type = "control",
  card_num = 0,
  target_num = 1,
  prompt = "ld__shangyi",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0 and not player:isKongcheng()
  end,
  target_filter = function(self, to_select, selected, selected_cards)
    return #selected == 0 and to_select ~= Self.id 
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    if player.dead or target.dead or player:isKongcheng() then return end
    U.viewCards(target, player:getCardIds("h"), self.name)
    local choices = {}
    if H.getGeneralsRevealedNum(target) ~= 2 then
      table.insert(choices, "ld__shangyi_hidden")
    end
    if not target:isKongcheng() then
      table.insert(choices, "ld__shangyi_card")
    end
    if #choices == 0 then return end
    local choice = room:askForChoice(player, choices, self.name)
    if choice == "ld__shangyi_hidden" then
      local general = {target:getMark("__heg_general"), target:getMark("__heg_deputy"), target.seat}
      room:askForCustomDialog(player, self.name, "packages/hegemony/qml/KnownBothBox.qml", general)
    elseif choice == "ld__shangyi_card" then
      if table.find(target:getCardIds("h"), function(id) return Fk:getCardById(id).color == Card.Black end) then
        local card, _ = U.askforChooseCardsAndChoice(player, table.filter(target:getCardIds("h"), function(id) return Fk:getCardById(id).color == Card.Black end), 
        {"OK"}, self.name, "", nil, 1, 1, target:getCardIds("h"))
        room:throwCard(card, self.name, target, player)
      else
        U.viewCards(player, target:getCardIds("h"), self.name)
      end
    end
  end,
}

niaoxiang:addRelatedSkill(niaoxiangTrigger)
jiangqin:addSkill(niaoxiang)
jiangqin:addSkill(shangyi)
jiangqin:addCompanions("hs__zhoutai")
Fk:loadTranslationTable{
  ["ld__jiangqin"] = "蒋钦",
  ["#ld__jiangqin"] = "祁奚之器",
  ["designer:ld__jiangqin"] = "淬毒",
  ["illustrator:ld__jiangqin"] = "天空之城",
  ["cv:ld__jiangqin"] = "小六",

  ["niaoxiang"] = "鸟翔",
  [":niaoxiang"] = "阵法技，若你是围攻角色，此围攻关系中的围攻角色使用【杀】指定被围攻角色为目标后，你令被围攻角色响应此【杀】的方式改为依次使用两张【闪】。",
  ["ld__shangyi"] = "尚义",
  [":ld__shangyi"] = "出牌阶段限一次，你可令一名其他角色观看你所有手牌，然后你选择一项：1.观看其所有手牌并弃置其中一张黑色牌；2.观看其所有暗置的武将牌",

  ["ld__shangyi_hidden"] = "观看暗置的武将牌",
  ["ld__shangyi_card"] = "观看所有手牌",

  ["$ld__shangyi1"] = "大丈夫为人坦荡，看下手牌算什么。",
  ["$ld__shangyi2"] = "敌情已了然于胸，即刻出发！",
  ["$ld__niaoxiang1"] = "此战，必是有死无生！",
  ["$ld__niaoxiang2"] = "抢占先机，占尽优势！",
  ["~ld__jiangqin"] = "竟破我阵法...",
}

local yuji = General(extension, "ld__yuji", "qun", 3)
local qianhuan = fk.CreateTriggerSkill{
  name = "qianhuan",
  events = {fk.Damaged, fk.TargetConfirming, fk.BeforeCardsMove},
  anim_type = "defensive",
  derived_piles = "yuji_sorcery",
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self) then return false end
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
      return true
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
Fk:loadTranslationTable{
  ["ld__yuji"] = "于吉",
  ["#ld__yuji"] = "魂绕左右",
  ["designer:ld__yuji"] = "淬毒",
  ["illustrator:ld__yuji"] = "G.G.G.",

  ["qianhuan"] = "千幻",
  [":qianhuan"] = "①当与你势力相同的角色受到伤害后，你可将一张与你武将牌上花色均不同的牌置于你的武将牌上（称为“幻”）。②当与你势力相同的角色成为基本牌或锦囊牌的唯一目标时，你可将一张“幻”置入弃牌堆，取消此目标。",

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
  ["#ld__hetaihou"] = "弄权之蛇蝎",
  ["cv:ld__hetaihou"] = "水原",
  ["illustrator:ld__hetaihou"] = "KayaK&木美人",
  ["designer:ld__hetaihou"] = "淬毒",
  ["~ld__hetaihou"] = "你们男人造的孽，非要说什么红颜祸水……",
}

local lordliubei = General(extension, "ld__lordliubei", "shu", 4)
lordliubei.hidden = true
H.lordGenerals["hs__liubei"] = "ld__lordliubei"

local zhangwu = fk.CreateTriggerSkill{
  name = "zhangwu",
  anim_type = 'drawcard',
  events = {fk.BeforeCardsMove, fk.AfterCardsMove},
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self) then return false end
    if event == fk.BeforeCardsMove then
      for _, move in ipairs(data) do
        if move.from == player.id and move.moveReason ~= fk.ReasonUse and (move.to ~= player.id or (move.toArea ~= Card.PlayerEquip and move.toArea ~= Card.PlayerHand)) then
          for _, info in ipairs(move.moveInfo) do
            if (info.fromArea == Card.PlayerEquip or info.fromArea == Card.PlayerHand) and Fk:getCardById(info.cardId).name == "dragon_phoenix" then
              return true
            end
          end
        end
      end
    else
      for _, move in ipairs(data) do
        if move.to ~= player.id and (move.toArea == Card.PlayerEquip or move.toArea == Card.DiscardPile) then
          for _, info in ipairs(move.moveInfo) do
            if Fk:getCardById(info.cardId).name == "dragon_phoenix" then
              return true
            end
          end
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local ids = {}
    if event == fk.BeforeCardsMove then
      local mirror_moves = {}
      for _, move in ipairs(data) do
        if move.from == player.id and move.moveReason ~= fk.ReasonUse and (move.to ~= player.id or (move.toArea ~= Card.PlayerEquip and move.toArea ~= Card.PlayerHand)) then
          local move_info = {}
          local mirror_info = {}
          for _, info in ipairs(move.moveInfo) do
            local id = info.cardId
            if (info.fromArea == Card.PlayerEquip or info.fromArea == Card.PlayerHand) and Fk:getCardById(info.cardId).name == "dragon_phoenix" then
              table.insert(ids, id)
              table.insert(mirror_info, info)
            else
              table.insert(move_info, info)
            end
          end
          if #mirror_info > 0 then
            move.moveInfo = move_info
            local mirror_move = table.clone(move)
            mirror_move.to = nil
            mirror_move.toArea = Card.DrawPile
            mirror_move.drawPilePosition = -1
            mirror_move.moveInfo = mirror_info
            table.insert(mirror_moves, mirror_move)
          end
        end
      end
      player:showCards(ids)
      table.insertTable(data, mirror_moves)
      if not player.dead then
        player:drawCards(2, self.name) -- 大摆特摆
      end
    else
      for _, move in ipairs(data) do
        if move.to ~= player.id and (move.toArea == Card.PlayerEquip or move.toArea == Card.DiscardPile) then
          for _, info in ipairs(move.moveInfo) do
            if Fk:getCardById(info.cardId).name == "dragon_phoenix" then
              table.insert(ids, info.cardId)
            end
          end
        end
      end
      local dummy = Fk:cloneCard("dilu")
      dummy:addSubcards(ids)
      player.room:obtainCard(player, dummy, true, fk.ReasonPrey)
    end
  end,
}

local shouyue = fk.CreateTriggerSkill{
  name = "shouyue",
  anim_type = "support",
  events = {fk.GeneralRevealed},
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self, true) then
      for _, v in pairs(data) do
        if table.contains(Fk.generals[v]:getSkillNameList(), self.name) then return true end
      end
    end
  end,
}

local jizhao = fk.CreateTriggerSkill{
  name = "jizhao",
  anim_type = "support",
  frequency = Skill.Limited,
  events = {fk.AskForPeaches},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.dying and player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if player:getHandcardNum() < player.maxHp then
      room:drawCards(player, player.maxHp - player:getHandcardNum(), self.name)
    end
    if player.hp < 2 then
      room:recover({
        who = player,
        num = 2 - player.hp,
        recoverBy = player,
        skillName = self.name,
      })
    end
    room:handleAddLoseSkills(player, "-shouyue|ex__rende", nil) -- 乐
  end,
}

lordliubei:addSkill(zhangwu)
lordliubei:addSkill(shouyue)
lordliubei:addSkill(jizhao)
lordliubei:addRelatedSkill("ex__rende")

Fk:loadTranslationTable{
  ["ld__lordliubei"] = "君刘备",
  ["#ld__lordliubei"] = "龙横蜀汉",
  ["designer:ld__lordliubei"] = "韩旭",
  ["illustrator:ld__lordliubei"] = "LiuHeng",

  ["zhangwu"] = "章武",
  [":zhangwu"] = "锁定技，①当【飞龙夺凤】移至弃牌堆或其他角色的装备区后，你获得此【飞龙夺凤】；②当你非因使用【飞龙夺凤】而失去【飞龙夺凤】前，你展示此【飞龙夺凤】，将此【飞龙夺凤】的此次移动的目标区域改为牌堆底，摸两张牌。",
  ["shouyue"] = "授钺",
  [":shouyue"] = "<b><font color='goldenrod'>君主技</font></b>，你拥有“五虎将大旗”。<br>" ..
  "#<b>五虎将大旗</b>：存活的蜀势力角色拥有的〖武圣〗、〖咆哮〗、〖龙胆〗、〖铁骑〗和〖烈弓〗分别按以下规则修改：<br>" ..
  "〖武圣〗：将“红色牌”改为“任意牌”；<br>"..
  "〖咆哮〗：增加描述“你使用的【杀】无视其他角色的防具”；<br>"..
  "〖龙胆〗：增加描述“当你使用/打出因〖龙胆〗转化的普【杀】或【闪】时，你摸一张牌”；<br>"..
  "〖铁骑〗：将“一张明置的武将牌的非锁定技失效”改为“所有明置的武将牌的非锁定技失效”；<br>"..
  "〖烈弓〗：增加描述“你的攻击范围+1”。",
  ["jizhao"] = "激诏",
  [":jizhao"] = "限定技，当你处于濒死状态时，你可将手牌摸至X张（X为你的体力上限），将体力回复至2点，失去〖授钺〗并获得〖仁德〗。",

  ["$shouyue"] = "布德而昭仁，见旗如见朕!",
  ["$zhangwu1"] = "遁剑归一，有凤来仪。",
  ["$zhangwu2"] = "剑气化龙，听朕雷动！",
  ["$jizhao1"] = "仇未报，汉未兴，朕志犹在！",
  ["$jizhao2"] = "王业不偏安，起师再兴汉！",
  ["$ex__rende_ld__lordliubei1"] = "勿以恶小而为之，勿以善小而不为。",
  ["$ex__rende_ld__lordliubei2"] = "君才十倍于丕，必能安国成事。",
  ["~ld__lordliubei"] = "若嗣子可辅，辅之。如其不才，君可自取……",
}

local extension_card = Package("formation_cards", Package.CardPack)
extension_card.extensionName = "hegemony"
extension_card.game_modes_whitelist = { 'nos_heg_mode', 'new_heg_mode' }

Fk:loadTranslationTable{
  ["formation_cards"] = "君临天下·阵卡牌",
}

local dragonPhoenixSkill = fk.CreateTriggerSkill{
  name = "#dragon_phoenix_skill",
  attached_equip = "dragon_phoenix",
  events = {fk.TargetSpecified, fk.EnterDying},
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self) then return end
    if event == fk.TargetSpecified then
      if target == player and data.card and data.card.trueName == "slash" then
        return not player.room:getPlayerById(data.to):isNude()
      end
    else
      return data.damage and data.damage.from == player and not target:isKongcheng() and U.damageByCardEffect(player.room) and data.damage.card.trueName == "slash"
    end
  end,
  on_cost = function(self, event, target, player, data)
    local prompt = event == fk.TargetSpecified and "#dragon_phoenix-slash::" .. data.to or "#dragon_phoenix-dying::" .. target.id
    return player.room:askForSkillInvoke(player, self.name, data, prompt)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:notifySkillInvoked(player, "dragon_phoenix", "control")
    -- room:setEmotion(player, "./packages/hegemony/image/anim/dragon_phoenix")
    if event == fk.TargetSpecified then
      local to = player.room:getPlayerById(data.to)
      room:askForDiscard(to, 1, 1, true, self.name, false, ".", "#dragon_phoenix-invoke")
    else
      local card = room:askForCardChosen(player, target, "h", self.name)
      room:obtainCard(player, card, false, fk.ReasonPrey)
    end
  end,
}
Fk:addSkill(dragonPhoenixSkill)

local dragonPhoenix = fk.CreateWeapon{
  name = "dragon_phoenix",
  suit = Card.Spade,
  number = 2,
  attack_range = 2,
  equip_skill = dragonPhoenixSkill,
}
H.addCardToConvertCards(dragonPhoenix, "double_swords")
extension_card:addCard(dragonPhoenix)

Fk:loadTranslationTable{
  ["dragon_phoenix"] = "飞龙夺凤",
  [":dragon_phoenix"] = "装备牌·武器<br/><b>攻击范围</b>：２ <br/><b>武器技能</b>：①当你使用【杀】指定目标后，你可令目标弃置一张牌。②当一名角色因执行你使用的【杀】的效果而受到你造成的伤害而进入濒死状态后，你可获得其一张手牌。",
  ["#dragon_phoenix_skill"] = "飞龙夺凤",
  ["#dragon_phoenix-slash"] = "飞龙夺凤：你可令 %dest 弃置一张牌",
  ["#dragon_phoenix-dying"] = "飞龙夺凤：你可获得 %dest 一张手牌",
  ["#dragon_phoenix-invoke"] = "受到“飞龙夺凤”影响，你需弃置一张牌",
}

return {
  extension,
  extension_card,
}
