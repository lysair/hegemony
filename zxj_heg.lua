local H = require "packages/hegemony/util"
local U = require "packages/utility/utility"
local extension = Package:new("zxj_heg")
extension.extensionName = "hegemony"
extension.game_modes_whitelist = { 'nos_heg_mode', 'new_heg_mode' }

Fk:loadTranslationTable{
  ["zxj_heg"] = "国战-紫星居设计",
  ["zx_heg"] = "紫星",
}

local zhanghua = General(extension, "zx_heg__zhanghua", "wei", 3)

local fuli = fk.CreateTriggerSkill{
  name = "zx_heg__fuli",
  anim_type = "support",
  events = {fk.DrawNCards},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and H.compareKingdomWith(player, target)
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(target, "#zx_heg__fuli-invoke")
  end,
  on_use = function(self, event, target, player, data)
    data.n = data.n + 1
  end,
}

local fuli_delay = fk.CreateTriggerSkill{
  name = "#zx_heg__fuli_delay",
  events = {fk.AfterDrawNCards},
  mute = true,
  anim_type = "drawcard",
  visible = false,
  can_trigger = function(self, event, target, player, data)
    return player:usedSkillTimes("zx_heg__fuli", Player.HistoryPhase) > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local card = room:askForCardChosen(target, target, "h", self.name)
    target:showCards(card)
    if target ~= player and not player.dead then
      room:obtainCard(player.id, card, false, fk.ReasonGive, player.id)
    end
    local suit = Fk:getCardById(card):getSuitString(true)
    if suit ~= "log_nosuit" then
      room:setPlayerMark(target, "@zx_heg__fuli-turn", suit)
    end
  end,
}

local fuli_prohibit = fk.CreateProhibitSkill{
  name = "#zx_heg__fuli_prohibit",
  prohibit_use = function(self, player, card)
    return player:getMark("@zx_heg__fuli-turn") == card:getSuitString(true)
  end,
  prohibit_response = function(self, player, card)
    return player:getMark("@zx_heg__fuli-turn") == card:getSuitString(true)
  end,
}

local fengwu = fk.CreateActiveSkill{
  name = "zx_heg__fengwu",
  anim_type = "control",
  card_num = 0,
  min_target_num = 1,
  max_target_num = 3,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function (self, to_select, selected)
    return not Fk:currentRoom():getPlayerById(to_select):isNude() and #selected < 3
  end,
  on_use = function (self, room, effect)
    local player = room:getPlayerById(effect.from)
    room:sortPlayersByAction(effect.tos)
    for _, id in ipairs(effect.tos) do
      local p = room:getPlayerById(id)
      if not p.dead and not p:isNude() then
        U.askForPlayCard(room, p, nil, ".", self.name, nil, {bypass_times = true})
      end
    end
    local used_color = {}
    U.getEventsByRule(room, GameEvent.UseCard, 1, function (e)
      local use = e.data[1]
      if use.card.suit ~= 0 then
        table.insertIfNeed(used_color, use.card.suit)
        return #used_color == 4
      end
      return false
    end, room.logic:getCurrentEvent():findParent(GameEvent.Turn, true).id)
    if #used_color == 4 then
      player:drawCards(2, self.name)
      if player.hp < player.maxHp and not player.dead then
        room:recover({
          who = player,
          num = 1,
          recoverBy = player,
          skillName = self.name
        })
      end
    end
  end
}

fuli:addRelatedSkill(fuli_prohibit)
fuli:addRelatedSkill(fuli_delay)
zhanghua:addSkill(fuli)
zhanghua:addSkill(fengwu)
Fk:loadTranslationTable{
  ["zx_heg__zhanghua"] = "张华", --魏国
  ["designer:zx_heg__zhanghua"] = "聆星",
  ["zx_heg__fuli"] = "复礼",
  [":zx_heg__fuli"] = "与你势力相同角色的摸牌阶段，其可多摸一张牌，若如此做，此阶段结束时，其展示并交给你一张牌且本回合不能使用或打出与此牌花色相同的牌。",
  ["zx_heg__fengwu"] = "风物",
  [":zx_heg__fengwu"] = "出牌阶段限一次，你可令至多三名角色依次选择是否使用一张牌，然后若本回合所有花色的牌均被使用过，你摸两张牌并回复1点体力。",

  ["@zx_heg__fuli-turn"] = "复礼",
  ["#zx_heg__fuli_delay"] = "复礼",
  ["#zx_heg__fuli-invoke"] = "复礼",

  ["$zx_heg__fuli1"] = "",
  ["$zx_heg__fuli2"] = "",
  ["$zx_heg__fengwu1"] = "",
  ["$zx_heg__fengwu2"] = "",
  ["~zx_heg__zhanghua"] = "",
}

local simafu = General(extension, "zx_heg__simafu", "wei", 3)
local zhangding = fk.CreateTriggerSkill{
  name = "zx_heg__zhangding",
  anim_type = "drawcard",
  frequency = Skill.Compulsory,
  events = {fk.DrawNCards, fk.EventPhaseStart},
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(self) and target == player and (event == fk.DrawNCards or player.phase == Player.Draw)
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    if event == fk.DrawNCards then
      data.n = data.n + 3
    else
      local num = 0
      if table.every(player.room.alive_players, function(p) return player:getHandcardNum() >= p:getHandcardNum() end) then
        num = num + 1
      end
      if table.every(player.room.alive_players, function(p) return player.hp >= p.hp end) then
        num = num + 1
      end
      local kingdomMapper = H.getKingdomPlayersNum(room)
      local n_self = kingdomMapper[H.getKingdom(player)]
      local is_max = true
      for _, n in pairs(kingdomMapper) do
        if n > n_self then is_max = false end
      end
      if is_max then num = num + 1 end
      room:askForDiscard(player, num, num, true, self.name, false)
      if num == 0 then
        player:skip(Player.Play)
        player:skip(Player.Discard)
      end
    end
  end,
}

local tongjun = fk.CreateTriggerSkill{
  name = "zx_heg__tongjun",
  anim_type = "special",
  events = {fk.EnterDying},
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(self) and target ~= player and H.isBigKingdomPlayer(target) and not player:isKongcheng() and not target:isKongcheng()
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local id1 = room:askForCardChosen(player, target, "h", self.name)
    local card = room:askForCard(player, 1, 1, false, self.name, true, ".", "#zx_heg__tongjun")
    if #card > 0 then
      local id2 = card[1]
      if player.dead then return end
      local move1 = {
        from = player.id,
        ids = {id2},
        to = target.id,
        toArea = Card.PlayerHand,
        moveReason = fk.ReasonJustMove,
        proposer = player.id,
        skillName = self.name,
      }
      local move2 = {
        from = target.id,
        ids ={id1},
        to = player.id,
        toArea = Card.PlayerHand,
        moveReason = fk.ReasonJustMove,
        proposer = player.id,
        skillName = self.name,
      }
    room:moveCards(move1, move2)
    end
  end,
}

simafu:addSkill(zhangding)
simafu:addSkill(tongjun)
Fk:loadTranslationTable{
  ["zx_heg__simafu"] = "司马孚", --魏国
  ["designer:zx_heg__simafu"] = "程昱",
  ["zx_heg__zhangding"] = "彰定",
  [":zx_heg__zhangding"] = "锁定技，摸牌阶段，你多摸三张牌；摸牌阶段开始时，若你的手牌数、体力值、与你势力相同的角色数每有一项为全场最多，你便弃置一张牌，若你未以此法弃牌，你跳过本回合的出牌阶段和弃牌阶段。",
  ["zx_heg__tongjun"] = "恸君",
  [":zx_heg__tongjun"] = "大势力角色进入濒死状态时，你可选择你与其各一张手牌，然后你交换这两张牌。",

  ["#zx_heg__tongjun"] = "恸君：选择处于濒死状态角色的一张牌",

  ["$zx_heg__zhangding1"] = "",
  ["$zx_heg__zhangding2"] = "",
  ["$zx_heg__tongjun1"] = "",
  ["$zx_heg__tongjun2"] = "",
  ["~zx_heg__simafu"] = "",
}


local qianzhou = General(extension, "zx_heg__qiaozhou", "shu", 3)

local huiming = fk.CreateTriggerSkill{
  name = "zx_heg__huiming",
  events = {fk.EventPhaseStart},
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(self) and player:usedSkillTimes(self.name, Player.HistoryRound) == 0 and target 
    and H.getGeneralsRevealedNum(target) > 0 and target.phase == Player.Start
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local card = room:askForGuanxing(player, room:getNCards(3), nil, nil, self.name, true, {"zx_heg__huiming_top", "zx_heg__huiming_pidp"})
    if #card.top > 0 then
      for i = #card.top, 1, -1 do
        table.insert(room.draw_pile, 1, card.top[i])
      end
      room:sendLog{
        type = "#GuanxingResult",
        from = player.id,
        arg = #card.top,
        arg2 = #card.bottom,
      }
    end
    if #card.bottom > 0 then
      room:moveCardTo(card.bottom, Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile, self.name, nil, false, player.id)
      local choice = room:askForChoice(target, {"zx_heg__huiming-get", "Cancel"}, self.name)
      if choice == "zx_heg__huiming-get" then
        room:damage{
          to = target,
          damage = 1,
          skillName = self.name,
        }
        local get = table.filter(card.bottom, function (id) return room:getCardArea(id) == Card.DiscardPile end)
        if #get ~= 0 or not target.dead then 
          room:moveCardTo(get, Card.PlayerHand, target, fk.ReasonPrey, self.name, nil, false, player.id)
        end
      end
    end
  end
}

local jiguo = fk.CreateTriggerSkill{
  name = "zx_heg__jiguo",
  frequency = Skill.Limited,
  events = {fk.AfterDying},
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(self) and player:usedSkillTimes(self.name, Player.HistoryGame) == 0 
      and target and target ~= player and target.dead and data.damage and data.damage.from 
      and table.find(player.room:getAlivePlayers(), function (e) return H.compareKingdomWith(player, target) and e ~= data.damage.from and not e:isNude() end)
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local ps = table.filter(room:getAlivePlayers(), function (e) return H.compareKingdomWith(player, target) and e ~= data.damage.from end)
    for _, p in ipairs(ps) do
      if not p:isNude() then
        local card = room:askForCardChosen(p, p, "he", self.name, "#zx_heg__jiguo-give"..data.damage.from.id)
        room:moveCardTo(card, Card.PlayerHand, data.damage.from, fk.ReasonGive, self.name, nil, false, player.id)
        if not p.dead then
          room:recover({
           who = p,
           num = 1,
           recoverBy = player,
           skillName = self.name
         })
        end
      end
    end
  end,
}
qianzhou:addSkill(huiming)
qianzhou:addSkill(jiguo)

Fk:loadTranslationTable{
  ["zx_heg__qiaozhou"] = "谯周", --蜀国
  ["designer:zx_heg__qiaozhou"] = "紫乔",
  ["zx_heg__huiming"] = "汇命",
  [":zx_heg__huiming"] = "每轮限一次，已确定势力角色的准备阶段，你可观看牌堆顶三张牌并将其中任意张牌置入弃牌堆，其余的牌以任意顺序置于牌堆顶，然后若你以此法将牌置入弃牌堆，其可受到1点无来源伤害，获得你以此法置入弃牌堆的牌。",
  ["zx_heg__jiguo"] = "寄国",
  [":zx_heg__jiguo"] = "限定技，其他角色死亡后，你可令所有与你势力相同的角色依次交给伤害来源一张牌并回复1点体力。",
  ["zx_heg__huiming_top"] = "置于牌堆顶",
  ["zx_heg__huiming_pidp"] = "置入弃牌堆",
  ["zx_heg__huiming-get"] = "受到一点无来源伤害并获得这些牌",
  ["#zx_heg__jiguo-give"] = "寄国：你可以交给 %src 一张牌，然后回复一点体力",

  ["$zx_heg__huiming1"] = "",
  ["$zx_heg__huiming2"] = "",
  ["$zx_heg__jiguo1"] = "",
  ["$zx_heg__jiguo2"] = "",
  ["~zx_heg__qiaozhou"] = "",
}

local huoyi = General(extension, "zx_heg__huoyi", "shu", 4)
local jinhun = fk.CreateTriggerSkill{
  name = "zx_heg__jinhun",
  anim_type = "defensive",
  frequency = Skill.Compulsory,
  events = {fk.DamageInflicted},
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(self) and player == target and (player.chained or not player.faceup) and not player:isNude()
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local cards = room:askForDiscard(player, 1, player:getHandcardNum(), true, self.name, false, ".", "#zx_heg__jinhun-discard", true)
    room:throwCard(cards, self.name, player, player)
    data.damage = data.damage - math.min(#cards, data.damage)
    if player:isKongcheng() or player.hp == 1 then
      target:reset()
    end
  end,
}

local guyuan = fk.CreateViewAsSkill{
  name = "zx_heg__guyuan",
  prompt = "#zx_heg__guyuan-active",
  interaction = function()
    local all_names = table.filter(U.getAllCardNames("t"), function(name) return Fk:cloneCard(name).is_damage_card end)
    local names = U.getViewAsCardNames(Self, "zx_heg__guyuan", all_names)
    return UI.ComboBox {choices = names, all_choices = all_names}
  end,
  card_filter = Util.FalseFunc,
  view_as = function(self, cards, player)
    local card = Fk:cloneCard(self.interaction.data)
    card.skillName = self.name
    card.extra_data = player.id
    return card
  end,
  enabled_at_play = function(self, player)
    return player.faceup
  end,
}

local guyuan_effect = fk.CreateTriggerSkill{
  name = "#zx_heg__guyuan_effect",
  mute = true,
  frequency = Skill.Compulsory,
  events = {fk.CardUsing},
  can_trigger = function (self, event, target, player, data)
    return data.card.skillName == guyuan.name and data.card.extra_data == player.id
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    player:turnOver()
    if player and H.getKingdomPlayersNum(player.room)[H.getKingdom(player)] == 1 then
      data.disresponsiveList = data.disresponsiveList or {}
      for _, p in ipairs(room.alive_players) do
        table.insertIfNeed(data.disresponsiveList, p.id)
      end
    end
  end,
}

huoyi:addSkill(jinhun)
huoyi:addSkill(guyuan)
guyuan:addRelatedSkill(guyuan_effect)
Fk:loadTranslationTable{
  ["zx_heg__huoyi"] = "霍弋", --蜀国
  ["designer:zx_heg__huoyi"] = "时雨",
  ["zx_heg__jinhun"] = "烬魂",
  [":zx_heg__jinhun"] = "锁定技，当你受到伤害时，若你横置或叠置，你弃置至少一张牌并防止等量的伤害，然后若你没有手牌或体力值为1，你复原武将牌。",
  ["zx_heg__guyuan"] = "孤援",
  [":zx_heg__guyuan"] = "出牌阶段，若你平置，你可叠置，视为使用任意一张伤害类锦囊牌，若没有与你势力相同的其他角色，此牌不可被响应。",

  ["#zx_heg__guyuan-active"] = "孤援：你可叠置，视为使用任意一张伤害类锦囊牌，若没有与你势力相同的其他角色，此牌不可被响应",

  ["$zx_heg__jinhun1"] = "",
  ["$zx_heg__jinhun2"] = "",
  ["$zx_heg__guyuan1"] = "",
  ["$zx_heg__guyuan2"] = "",
  ["~zx_heg__huoyi"] = "",
}


local taohuang = General(extension, "zx_heg__taohuang", "wu", 4)
local luyi = fk.CreateActiveSkill{
  name = "zx_heg__luyi",
  card_num = 1,
  target_num = 2,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = function(self, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).type ~= Card.TypeBasic and Fk:currentRoom():getCardArea(to_select) == Player.Hand
  end,
  target_filter = function (self, to_select, selected)
    local target = Fk:currentRoom():getPlayerById(to_select)
    return target ~= Self and target:getHandcardNum() > 0 and #selected < 2 and Self:canPindian(target)
  end,
  on_use = function (self, room, effect)
    local player = room:getPlayerById(effect.from)
    local card = Fk:getCardById(effect.cards[1])
    local target1 = room:getPlayerById(effect.tos[1])
    local target2 = room:getPlayerById(effect.tos[2])
    player:showCards(card)
    local pindian = target1:pindian({target2}, self.name)
    if pindian.results[target2.id].winner then
      local winner = pindian.results[target2.id].winner == target1 and target1 or target2
      if winner and not winner.dead then
        room:moveCardTo(card, Card.PlayerHand, winner, fk.ReasonPrey, self.name, nil, false, player.id)
      end
    end
  end,
}

local pofu = fk.CreateViewAsSkill{
  name = "zx_heg__pofu",
  anim_type = "control",
  pattern = "nullification",
  prompt = "#zx_heg__pofu-viewas",
  card_filter = function(self, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).trueName == "jink"
  end,
  view_as = function(self, cards)
    if #cards ~= 1 then return end
    local card = Fk:cloneCard("nullification")
    card.skillName = self.name
    card.extra_data = player.id
    card:addSubcard(cards[1])
    return card
  end,
}

local pofu_effect = fk.CreateTriggerSkill{
  name = "#zx_heg__pofu_effect",
  anim_type = "special",
  frequency = Skill.Compulsory,
  events = {fk.CardUseFinished, fk.CardRespondFinished},
  can_trigger = function(self, event, target, player, data)
    return data.card.extra_data == player.id and data.responseToEvent and data.card.skillName == pofu.name
      and not table.find(TargetGroup:getRealTargets(data.responseToEvent.tos), function(id) return id ~= player.id end)
      and ((event == fk.CardUseFinished and data.toCard and data.toCard.trueName ~= "nullification" and data.toCard:isCommonTrick()) or 
        (event == fk.CardRespondFinished and data.responseToEvent.card and data.responseToEvent.card.trueName ~= "nullification" and data.responseToEvent.card:isCommonTrick()))
      and (not data.responseToEvent.from.dead or room:getCardArea(data.responseToEvent.card) == Card.Processing)
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local choices = {}
    if not data.responseToEvent.from.dead then
      table.insert(choices, "zx_heg__pofu_effect-damage")
    end
    if room:getCardArea(data.responseToEvent.card) == Card.Processing then
      table.insert(choices, "zx_heg__pofu_effect-getcard")
    end
    local choice = room:askForChoice(player, choices, self.name)
    if choice == "zx_heg__pofu_effect-damage" then
      room:damage{
        from = player,
        to = data.responseToEvent.from,
        damage = 1,
        skillName = self.name,
      }
    else
      room:obtainCard(player, data.responseToEvent.card, false, fk.ReasonPrey)
    end
  end,
}

pofu:addRelatedSkill(pofu_effect)
taohuang:addSkill(luyi)
taohuang:addSkill(pofu)
Fk:loadTranslationTable{
  ["zx_heg__taohuang"] = "陶璜", --吴国
  ["designer:zx_heg__taohuang"] = "紫乔",
  ["zx_heg__luyi"] = "赂遗",
  [":zx_heg__luyi"] = "出牌阶段限一次，你可展示一张非基本手牌，令其他两名角色拼点，赢的角色获得展示牌。",
  ["zx_heg__pofu"] = "破伏",
  [":zx_heg__pofu"] = "你可将【闪】当【无懈可击】使用，若此牌的目标为指定你为唯一目标的普通锦囊牌，你选择一项：1.获得此锦囊牌；2.对此牌使用者造成1点伤害。",

  ["zx_heg__pofu_effect-damage"] = "造成伤害",
  ["zx_heg__pofu_effect-getcard"] = "获得被响应的锦囊牌",

  ["#zx_heg__pofu-viewas"] = "破伏：你可将【闪】当【无懈可击】使用",

  ["$zx_heg__luyi1"] = "",
  ["$zx_heg__luyi2"] = "",
  ["$zx_heg__pofu1"] = "",
  ["$zx_heg__pofu2"] = "",
  ["~zx_heg__taohuang"] = "",
}

local sunjun = General(extension, "zx_heg__sunjun", "wu", 4)
local suchao = fk.CreateActiveSkill{
  name = "zx_heg__suchao",
  anim_type = "offensive",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_num = 0,
  card_filter = Util.FalseFunc,
  min_target_num = 1,
  max_target_num = 3,
  target_filter = function(self, to_select, selected, selected_cards)
    local room = Fk:currentRoom()
    local target = room:getPlayerById(to_select)
    return target:getHandcardNum() > Self:getHandcardNum()
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local targets = table.clone(effect.tos)
    room:sortPlayersByAction(targets)
    for _, id in ipairs(targets) do
      if not target.dead then
        local target = room:getPlayerById(id)
        room:setPlayerMark(target, "zx_heg__suchao-phase", 1)
        room:damage{ 
          from = player, 
          to = target, 
          damage = 1, 
          skillName = self.name 
        }
      end
    end
  end,
}

local suchao_effect = fk.CreateTriggerSkill{
  name = "#ld__suchao_effect",
  mute = true,
  events = {fk.EventPhaseEnd},
  can_trigger = function(self, event, target, player, data)
    return player.phase == Player.Play and player:usedSkillTimes(suchao.name, Player.HistoryPhase) > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    for _, target in ipairs(room.alive_players) do
      if target:getMark("zx_heg__suchao-phase") > 0 and not target.dead then
        room:recover({
          who = target,
          num = 1,
          recoverBy = player,
          skillName = self.name,
        })
      end
    end
    for _, target in ipairs(room.alive_players) do
      if target:getMark("zx_heg__suchao-phase") > 0 and not target.dead and not player.dead then
        local use = room:askForUseCard(target, "slash", "slash", "#zx_heg__suchao-ask:" .. player.id, true, {include_targets = {player.id}, bypass_distances = true })
        if use then
          room:notifySkillInvoked(player, self.name, "offensive")
          player:broadcastSkillInvoke(self.name)
          use.extraUse = true
          room:useCard(use)
        end
      end
    end
  end,
}

local zhulian = fk.CreateTriggerSkill{
  name = "zx_heg__zhulian",
  anim_type = "offensive",
  frequency = Skill.Compulsory,
  events = {fk.DamageInflicted},
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(self) and player.phase ~= Player.NotActive and data.to:getMark("zx_heg__zhulian-turn") > 0
  end,
  on_use = function (self, event, target, player, data)
    data.damage = data.damage + 1
  end,

  refresh_events = {fk.CardUsing, fk.TargetConfirmed},
  can_refresh = function (self, event, target, player, data)
    return player ~= target and player.phase ~= Player.NotActive and data.card.trueName == "peach"
  end,
  on_refresh = function (self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(target, "zx_heg__zhulian-turn", 1)
  end,
}

sunjun:addSkill(suchao)
suchao:addRelatedSkill(suchao_effect)
sunjun:addSkill(zhulian)
Fk:loadTranslationTable{
  ["zx_heg__sunjun"] = "孙峻", --吴国
  ["designer:zx_heg__sunjun"] = "紫乔",
  ["zx_heg__suchao"] = "肃朝",
  [":zx_heg__suchao"] = "出牌阶段限一次，你可对至多三名手牌数大于你的角色各造成1点伤害，若如此做，此阶段结束时，这些角色依次回复1点体力并可以对你使用一张无距离限制的【杀】。",
  ["zx_heg__zhulian"] = "株连",
  [":zx_heg__zhulian"] = "锁定技，其他角色于你的回合内受到伤害时，若其此回合内使用过【桃】或成为过【桃】的目标，此伤害+1。",

  ["#zx_heg__suchao-ask:"] = "肃朝：你可对 %src 使用一张【杀】",

  ["$zx_heg__suchao1"] = "",
  ["$zx_heg__suchao2"] = "",
  ["$zx_heg__zhulian1"] = "",
  ["$zx_heg__zhulian2"] = "",
  ["~zx_heg__sunjun"] = "",
}

local liuyu = General(extension, "zx_heg__liuyu", "qun", 3)
local suifu = fk.CreateTriggerSkill{
  name = "zx_heg__suifu",
  anim_type = "special",
  events = {fk.EventPhaseStart},
  can_trigger = function (self, event, target, player, data)
    if not (player:hasSkill(self) and player ~= target and target.phase == Player.Finish) then return false end
    local small_damage = {}
    return #player.room.logic:getActualDamageEvents(2, function(e)
      if H.isSmallKingdomPlayer(e.data[1].to) then
        return table.insertIfNeed(small_damage, e.data[1].to) 
      end
    end, Player.HistoryTurn) > 1
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local cards = target:getCardIds("h")
    room:moveCards({
      ids = cards,
      from = target.id,
      fromArea = Card.PlayerHand,
      toArea = Card.DrawPile,
      moveReason = fk.ReasonJustMove,
      skillName = self.name,
    })
    room:useVirtualCard("amazing_grace", {}, player, room.alive_players, self.name)
  end,
}

local anjing = fk.CreateTriggerSkill{
  name = "zx_heg__anjing",
  anim_type = "drawcard",
  events = {fk.Damaged},
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(self) and H.compareKingdomWith(data.to, player) and player:usedSkillTimes(self.name, Player.HistoryTurn) == 0
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

liuyu:addSkill(suifu)
liuyu:addSkill(anjing)
Fk:loadTranslationTable{
  ["zx_heg__liuyu"] = "刘虞", --群雄
  ["designer:zx_heg__liuyu"] = "紫星居",
  ["zx_heg__suifu"] = "绥抚",
  [":zx_heg__suifu"] = "其他角色的结束阶段，若本回合有至少两名小势力角色受到过伤害，你可令其将所有手牌置于牌堆顶，然后其视为使用一张【五谷丰登】。",
  ["zx_heg__anjing"] = "安境",
  [":zx_heg__anjing"] = "每回合限一次，与你势力相同的角色受到伤害后，你可令所有与你势力相同的角色各摸一张牌。",

  ["$zx_heg__suifu1"] = "",
  ["$zx_heg__suifu2"] = "",
  ["$zx_heg__anjing1"] = "",
  ["$zx_heg__anjing2"] = "",
  ["~zx_heg__liuyu"] = "",
}

return extension
