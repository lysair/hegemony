local H = require "packages/hegemony/util"
local U = require "packages/utility/utility"
local extension = Package:new("zxj_heg")
extension.extensionName = "hegemony"
extension.game_modes_whitelist = { 'nos_heg_mode', 'new_heg_mode' }

Fk:loadTranslationTable{
  ["zxj_heg"] = "国战-紫星&三设",
  ["zx_heg"] = "紫星",
  ["ss_heg"] = "三设",
}

local zhanghua = General(extension, "zx_heg__zhanghua", "wei", 3)

local fuli = fk.CreateTriggerSkill{
  name = "zx_heg__fuli",
  anim_type = "support",
  events = {fk.DrawNCards},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and H.compareKingdomWith(player, target) and (player:hasShownSkill(self) or player == target)
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

  ["$zx_heg__fuli1"] = "辅弼天家，以扶超纲。",
  ["$zx_heg__fuli2"] = "为国治政，尽忠匡辅。",
  ["$zx_heg__fengwu1"] = "身临朝阙，腰悬太阿。",
  ["$zx_heg__fengwu2"] = "位登三事，当配龙泉。",
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

  ["$zx_heg__zhangding1"] = "陛下所托，臣必尽心尽力。",
  ["$zx_heg__zhangding2"] = "纵吾荏弱难持，亦不推诿君命。",
  ["$zx_heg__tongjun1"] = "臣心怀二心，不可事君也。",
  ["$zx_heg__tongjun2"] = "竭力致身，以尽臣节。",
  ["~zx_heg__simafu"] = "",
}


local qianzhou = General(extension, "zx_heg__qiaozhou", "shu", 3)

local zhengtian = fk.CreateTriggerSkill{
  name = "zx_heg__zhengtian",
  events = {fk.EventPhaseStart},
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(self) and player:usedSkillTimes(self.name, Player.HistoryRound) == 0 and target 
    and H.getGeneralsRevealedNum(target) > 0 and target.phase == Player.Start
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local card = room:askForGuanxing(player, room:getNCards(3), nil, nil, self.name, true, {"zx_heg__zhengtian_top", "zx_heg__zhengtian_pidp"})
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
      local choice = room:askForChoice(target, {"zx_heg__zhengtian-get", "Cancel"}, self.name)
      if choice == "zx_heg__zhengtian-get" then
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
      and table.find(player.room.alive_players, function (e) return H.compareKingdomWith(player, e) and e ~= data.damage.from and not e:isNude() end)
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local ps = table.filter(room:getAlivePlayers(), function (e) return H.compareKingdomWith(player, e) and e ~= data.damage.from end)
    for _, p in ipairs(ps) do
      if not p:isNude() then
        local card = room:askForCardChosen(p, p, "he", self.name, "#zx_heg__jiguo-give"..data.damage.from.id)
        room:moveCardTo(card, Card.PlayerHand, data.damage.from, fk.ReasonGive, self.name, nil, false, player.id)
        if not p.dead then
          room:recover{
            who = p,
            num = 1,
            recoverBy = player,
            skillName = self.name
          }
        end
      end
    end
  end,
}
qianzhou:addSkill(zhengtian)
qianzhou:addSkill(jiguo)

Fk:loadTranslationTable{
  ["zx_heg__qiaozhou"] = "谯周", --蜀国
  ["designer:zx_heg__qiaozhou"] = "紫乔",
  ["zx_heg__zhengtian"] = "征天",
  [":zx_heg__zhengtian"] = "已确定势力角色的准备阶段，你可观看牌堆顶三张牌并将其中任意张牌置入弃牌堆，其余的牌以任意顺序置于牌堆顶，然后此技能于本轮内失效，若你以此法将牌置入弃牌堆，其可受到1点无来源伤害，获得你以此法置入弃牌堆的牌。",
  ["zx_heg__jiguo"] = "寄国",
  [":zx_heg__jiguo"] = "限定技，其他角色死亡后，你可令所有与你势力相同的角色依次交给伤害来源一张牌并回复1点体力。",
  ["zx_heg__zhengtian_top"] = "置于牌堆顶",
  ["zx_heg__zhengtian_pidp"] = "置入弃牌堆",
  ["zx_heg__zhengtian-get"] = "受到一点无来源伤害并获得这些牌",
  ["#zx_heg__jiguo-give"] = "寄国：你可以交给 %src 一张牌，然后回复一点体力",

  ["$zx_heg__zhengtian1"] = "今天命在北，我等已尽人事。",
  ["$zx_heg__zhengtian2"] = "益州国疲民弊，非人力可续之。",
  ["$zx_heg__jiguo1"] = "典午忽兮，月酉没兮。",
  ["$zx_heg__jiguo2"] = "周慕孔子遗风，可与刘扬同轨。",
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
    local cards = room:askForDiscard(player, 1, #player:getCardIds("he"), true, self.name, false, ".", "#zx_heg__jinhun-discard", true)
    room:throwCard(cards, self.name, player, player)
    if not player.dead then
      data.damage = math.max(data.damage - #cards, 0)
      if player:isKongcheng() or player.hp == 1 then
        player:reset()
      end
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
  view_as = function(self, _)
    local card = Fk:cloneCard(self.interaction.data)
    card.skillName = self.name
    return card
  end,
  before_use = function (self, player, use)
    player:turnOver()
    if H.getKingdomPlayersNum(player.room)[H.getKingdom(player)] == 1 then
      use.disresponsiveList = use.disresponsiveList or {}
      table.forEach(player.room.alive_players, function(p) table.insertIfNeed(use.disresponsiveList, p.id) end)
    end
  end,
  enabled_at_play = function(self, player)
    return player.faceup
  end,
  enabled_at_response = Util.FalseFunc,
}

huoyi:addSkill(jinhun)
huoyi:addSkill(guyuan)
Fk:loadTranslationTable{
  ["zx_heg__huoyi"] = "霍弋", --蜀国
  ["designer:zx_heg__huoyi"] = "时雨",
  ["zx_heg__jinhun"] = "烬魂",
  [":zx_heg__jinhun"] = "锁定技，当你受到伤害时，若你横置或叠置，你弃置至少一张牌并防止等量的伤害，然后若你没有手牌或体力值为1，你复原武将牌。",
  ["zx_heg__guyuan"] = "孤援",
  [":zx_heg__guyuan"] = "出牌阶段，若你平置，你可叠置，视为使用任意一张伤害类锦囊牌，若没有与你势力相同的其他角色，此牌不可被响应。",

  ["#zx_heg__guyuan-active"] = "孤援：你可叠置，视为使用任意一张伤害类锦囊牌，若没有与你势力相同的其他角色，此牌不可被响应",

  ["$zx_heg__jinhun1"] = "戍守孤城，其势不侵。",
  ["$zx_heg__jinhun2"] = "吾头可得，而城不可得",
  ["$zx_heg__guyuan1"] = "哀兵必胜，换吾众志成城。",
  ["$zx_heg__guyuan2"] = "扼守孤城，试问万夫谁开。",
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
    if not (data.responseToEvent and data.card.skillName == pofu.name) then return false end
    if table.find(TargetGroup:getRealTargets(data.responseToEvent.tos), function(p) return p ~= player end) then return false end
    if ((data.responseToEvent and data.responseToEvent.from.dead) and player.room:getCardArea(data.responseToEvent.card) ~= Card.Processing) then return false end
    if event == fk.CardUseFinished then
      return data.toCard and data.toCard.trueName ~= "nullification" and data.toCard:isCommonTrick()
    else
      return data.responseToEvent.card and data.responseToEvent.card.trueName ~= "nullification" and data.responseToEvent.card:isCommonTrick()
    end
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
      local target = room:getPlayerById(id)
      if not target.dead then
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
  on_use = function(self, _, _, player, _)
    local room = player.room
    for _, target in ipairs(room:getAlivePlayers()) do
      if target:getMark("zx_heg__suchao-phase") > 0 and not target.dead then
        room:recover({
          who = target,
          num = 1,
          recoverBy = player,
          skillName = self.name,
        })
      end
    end
    for _, target in ipairs(room:getAlivePlayers()) do
      if target:getMark("zx_heg__suchao-phase") > 0 and not target.dead and not player.dead then
        local use = room:askForUseCard(target, "slash", "slash", "#zx_heg__suchao-ask:"..player.id, true, {include_targets = {player.id}, bypass_distances = true, bypass_times = true })
        if use then
          room:notifySkillInvoked(player, suchao.name, "offensive")
          player:broadcastSkillInvoke(suchao.name)
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
    return player:hasSkill(self) and player.room.current == player and target ~= player and
    #player.room.logic:getEventsOfScope(GameEvent.UseCard, 1, function (e)
      local use = e.data[1]
      return use.card.trueName == "peach" and (use.from == target.id or TargetGroup:includeRealTargets(use.tos, target.id))
    end, Player.HistoryTurn) > 0
  end,
  on_use = function (self, event, target, player, data)
    data.damage = data.damage + 1
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

  ["#zx_heg__suchao-ask"] = "肃朝：你可对 %src 使用一张【杀】",

  ["$zx_heg__suchao1"] = "不顺我意者，当填在野之壑。",
  ["$zx_heg__suchao2"] = "吾令不从者，当膏霜锋之锷。",
  ["$zx_heg__zhulian1"] = "你们，都要为我殉葬！",
  ["$zx_heg__zhulian2"] = "杀了我，你们也别想活！",
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
    room:useVirtualCard("amazing_grace", {}, player, room:getAlivePlayers(false), self.name)
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
    room:doIndicate(player.id, targets)
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
  [":zx_heg__suifu"] = "其他角色的结束阶段，若本回合有至少两名小势力角色受到过伤害，你可令其将所有手牌置于牌堆顶，然后你视为使用一张【五谷丰登】。",
  ["zx_heg__anjing"] = "安境",
  [":zx_heg__anjing"] = "每回合限一次，与你势力相同的角色受到伤害后，你可令所有与你势力相同的角色各摸一张牌。",

  ["$zx_heg__suifu1"] = "以柔克刚，方是良策。",
  ["$zx_heg__suifu2"] = "镇抚边疆，为国家计。",
  ["$zx_heg__anjing1"] = "群寇来袭，愿和将军同御外侮。",
  ["$zx_heg__anjing2"] = "天下不宁，愿与阁下共守此州。",
  ["~zx_heg__liuyu"] = "",
}

local yangbiao = General(extension, "zx_heg__yangbiao", "qun", 3, 3, General.Male)
local rangjie = fk.CreateTriggerSkill{
  name = "zx_heg__rangjie",
  events = {fk.Damaged},
  anim_type = "defensive",
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(self) and player == target and data.card and data.card.trueName == "slash" and not player:isKongcheng() and not data.from.dead
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local id = room:askForCardChosen(data.from, player, "h", self.name)
    player:showCards({id})
    if player.dead then return end
    if Fk:getCardById(id).suit ~= Card.Heart then
      room:throwCard(id, self.name, player, player)
      if not player.dead and player.hp < player.maxHp then
        room:recover{
          who = player,
          num = 1,
          recoverBy = player,
          skillName = self.name,
        }
      end
    elseif player:getMark("@@zx_heg__rangjie_transform") == 0 then
      room:setPlayerMark(player, "@@zx_heg__rangjie_transform", 1)
      H.transformGeneral(room, player)
    end
  end,
}

local yichi = fk.CreateActiveSkill{
  name = "zx_heg__yichi",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function (self, to_select, selected)
    local target = Fk:currentRoom():getPlayerById(to_select)
    return target.hp > Self.hp and #selected < 1 and Self:canPindian(target)
  end,
  on_use = function (self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    local pindian = player:pindian({target}, self.name)
    if pindian.results[target.id].winner then
      local winner = pindian.results[target.id].winner ---@type ServerPlayer
      local loser = winner == player and target or player
      if not winner.dead and not loser:isNude() then
        local card = room:askForCardChosen(winner, loser, "he", self.name)
        room:obtainCard(winner, card, false, fk.ReasonPrey)
      end
    end
    if pindian.fromCard:compareColorWith(pindian.results[target.id].toCard, true) and not player.dead then
      player:drawCards(1, self.name)
    end
  end,
}

yangbiao:addSkill(rangjie)
yangbiao:addSkill(yichi)
Fk:loadTranslationTable{
  ["zx_heg__yangbiao"] = "杨彪", --群雄
  ["designer:zx_heg__guanning"] = "时雨",
  ["zx_heg__rangjie"] = "让节",
  [":zx_heg__rangjie"] = "当你受到【杀】造成的伤害后，你可令伤害来源展示你一张手牌，若此牌不为红桃，你弃置之并回复1点体力，否则你变更副将。",
  ["zx_heg__yichi"] = "义叱",
  [":zx_heg__yichi"] = "出牌阶段限一次，你可以与体力值大于你的一名角色拼点，赢的角色获得没赢的角色的一张牌，若两张拼点牌颜色不同，你摸一张牌。",

  ["@@zx_heg__rangjie_transform"] = "让节 已变更",

  ["$zx_heg__rangjie1"] = "公既执掌权柄，又何必令君臣遭乱。",
  ["$zx_heg__rangjie2"] = "公虽权倾朝野，亦当尊圣上之意。",
  ["$zx_heg__yichi1"] = "一人劫天子，一人质公卿，此可行邪？",
  ["$zx_heg__yichi2"] = "诸君举事，当上顺天子，奈何如是！",

  ["~zx_heg__yangbiao"] = "未能效死佑汉，只因宗族之踵。",
}

-- local qinmi = General(extension, "ss_heg__qinmi", "shu", 3, 3, General.Male)
-- local zhuandui = fk.CreateTriggerSkill{
--   name = "ss_heg__zhuandui",
--   frequency = Skill.Compulsory,
--   anim_type = "special",
--   events = {fk.CardUsing},
--   can_trigger = function (self, event, target, player, data)
--     local room = player.room
--     if not (player:hasSkill(self) and room.current == player and player == target) then return false end
--     local first = room.logic:getEventsOfScope(GameEvent.UseCard, 1, function(e) 
--       local use = e.data[1]
--       return use.from == player.id
--     end, Player.HistoryTurn)
--     if #first > 0 and first[1].data[1] == data then 
--       self.cost_data = data.card.number
--       return true 
--     end

--     local turn_event = room.logic:getCurrentEvent():findParent(GameEvent.Turn)
--     if turn_event == nil then return false end
--     local use_event = room.logic:getCurrentEvent():findParent(GameEvent.UseCard, true)
--     if use_event == nil then return false end
--     local mark = target:getTableMark("ss_heg__zhuandui-turn")
--     if table.contains(mark, use_event.id) then
--       return #mark > 1 and mark[2] == use_event.id
--     end
--     if #mark > 1 then return false end
--     mark = {}
--     room.logic:getEventsOfScope(GameEvent.UseCard, 2, function(e)
--       local use = e.data[1]
--       if use.from == player.id then
--         table.insert(mark, e.id)
--         return true
--       end
--       return false
--     end, Player.HistoryTurn)
--     room:setPlayerMark(target, "ss_heg__zhuandui-turn", mark)
--     if not (#mark > 1 and mark[2] == use_event.id) then return false end
--     local events = room.logic.event_recorder[GameEvent.UseCard] or {}
--     local last_find = false
--     for i = #events, 1, -1 do
--       local e = events[i]
--       if e.id < turn_event.id then return false end
--       if e.id == use_event.id then
--         last_find = true
--       elseif last_find then
--         if e.data[1].card.number < data.card.number then
--           self.cost_data = 0
--           return true
--         end
--       end
--     end
--   end,
--   on_use = function (self, event, target, player, data)
--     if self.cost_data ~= 0 then
--       player.room:setPlayerMark(player, "@ss_heg__zhuandui_forbidden-turn", self.cost_data)
--     else
--       player:drawCards(1, self.name)
--     end
--   end,
-- }

-- local zhuandui_prohibit = fk.CreateProhibitSkill{
--   name = "#ss_heg__zhuandui_prohibit",
--   prohibit_use = function(self, player, card)
--     local mark = player:getMark("@ss_heg__zhuandui_forbidden-turn")
--     return not card:isVirtual() and card.number < mark
--   end,
--   prohibit_response = function(self, player, card)
--     local mark = player:getMark("@ss_heg__zhuandui_forbidden-turn")
--     return not card:isVirtual() and card.number < mark
--   end,
-- }

-- local jianzheng = fk.CreateTriggerSkill{
--   name = "ss_heg__jianzheng",
--   anim_type = "special",
--   events = {fk.EventPhaseStart},
--   can_trigger = function (self, event, target, player, data)
--     return player:hasSkill(self) and H.compareKingdomWith(player, target) and target.phase == Player.Play
--   end,
--   on_use = function (self, event, target, player, data)
--     local room = player.room
--     local targets = table.map(table.filter(room.alive_players, function(p) return not H.compareKingdomWith(p, player) end), Util.IdMapper)
--     local tos = room:askForChoosePlayers(targets, targets, 1, 1, "#ss_heg__jianzheng-choose", self.name, true)
--     if #tos > 0 then
--       local to = room:getPlayerById(tos[1])
--       room:useVirtualCard("befriend_attacking", nil, target, to, self.name)
--       room:setPlayerMark(target, "ss_heg__jianzheng-turn", 1)
--     end
--   end,
-- }

-- local jianzheng_delay = fk.CreateTriggerSkill{
--   name = "#ss_heg__jianzheng_delay",
--   events = {fk.CardUseFinished},
--   can_trigger = function (self, event, target, player, data)
--     return player:usedSkillTimes(jianzheng.name, Player.HistoryTurn) > 0 and data.card.trueName == "slash" 
--      and target:getMark("ss_heg__jianzheng-turn") > 0 and not player.dead
--   end,
--   on_cost = util.TrueFunc,
--   on_use = function (self, event, target, player, data)
--     local isDeputy = H.inGeneralSkills(player, jianzheng.name)
--     if isDeputy then
--       H.removeGeneral(player.room, player, isDeputy == "d")
--     end
--   end,
-- }

-- zhuandui:addRelatedSkill(zhuandui_prohibit)
-- jianzheng:addRelatedSkill(jianzheng_delay)
-- qinmi:addSkill(zhuandui)
-- qinmi:addSkill(jianzheng)

-- Fk:loadTranslationTable{
--   ["ss_heg__qinmi"] = "秦宓", --蜀国
--   ["designer:ss_heg__guanning"] = "",
--   ["ss_heg__zhuandui"] = "专对",
--   [":ss_heg__zhuandui"] = "锁定技，当你于回合内使用：首张牌时，所有其他角色本回合不能使用或打出点数小于此牌的牌；第二张牌时，若此牌的点数大于本回合上一张被使用的牌，你摸一张牌。",
--   ["ss_heg__jianzheng"] = "谏征",
--   [":ss_heg__jianzheng"] = "与你势力相同角色的出牌阶段开始时，你可令其选择是否视为使用一张【远交近攻】，若如此做，本回合其使用【杀】结算后，你移除此武将牌。",

--   ["~ss_heg__qinmi"] = "",
-- }

local liuyan = General(extension, "ss_heg__liuyan", "qun", 3, 3, General.Male)

local jueguan_active = fk.CreateActiveSkill{
  name = "#ss_heg__jueguan_active",
  can_use = Util.FalseFunc,
  target_num = 0,
  card_filter = function(self, to_select, selected)
    if Fk:currentRoom():getCardArea(to_select) == Player.Equip then return end
    return table.every(selected, function (id) return Fk:getCardById(to_select).suit ~= Fk:getCardById(id).suit end)
  end,
}

local jueguan = fk.CreateTriggerSkill{
  name = "ss_heg__jueguan",
  events = {fk.EventPhaseStart},
  anim_type = "offensive",
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(self) and player == target and player.phase == Player.Play
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local _, ret = room:askForUseActiveSkill(player, "#ss_heg__jueguan_active", "#ss_heg__jueguan-choose", false)
    local to_remain
    if ret then
      to_remain = ret.cards
    end
    player:showCards(to_remain)
    local suits = {}
    for _, id in ipairs(to_remain) do
      local card = Fk:getCardById(id)
      room:setCardMark(card, "@@ss_heg__jueguan-inhand-turn", 1)
      local suit = card.suit
      if suit ~= Card.NoSuit then
        table.insert(suits, suit)
      end
    end
    room:setPlayerMark(player, "@ss_heg__jueguan_suit-phase", suits)
  end,
}

local jueguan_maxcards = fk.CreateMaxCardsSkill{
  name = "#ss_heg__jueguan_maxcards",
  frequency = Skill.Compulsory,
  exclude_from = function(self, player, card)
    return player:hasSkill(jueguan.name) and card:getMark("@@ss_heg__jueguan-inhand-turn") > 0
  end,
}

local jueguan_prohibit = fk.CreateProhibitSkill{
  name = "#ss_heg__jueguan_prohibit",
  prohibit_use = function(self, player, card)
    local mark = player:getMark("@ss_heg__jueguan_suit-phase")
    return type(mark) == "table" and table.contains(mark, card.suit)
  end,
}

local limu_filter = fk.CreateActiveSkill{
  name = "#ss_heg__limu_filter",
  card_num = 1,
  visible = false,
  card_filter = function(self, to_select, selected)
    return table.contains(Self:getMark("ss_heg__limu-turn"), Fk:getCardById(to_select).suit)
  end,
  target_filter = Util.FalseFunc,
  can_use = Util.FalseFunc,
}

local limu = fk.CreateTriggerSkill{
  name = "ss_heg__limu",
  events = {fk.EventPhaseStart},
  anim_type = "special",
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(self) and player == target and player.phase == Player.Finish
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local targets = table.map(room.alive_players, Util.IdMapper)
    if #targets == 0 then return end
    local tos = room:askForChoosePlayers(player, targets, 1, 1, "#ss_heg__limu-choose", self.name, false)
    local to = room:getPlayerById(tos[1])
    local no_used_color = {Card.Spade, Card.Heart, Card.Diamond, Card.Club}
    player.room.logic:getEventsOfScope(GameEvent.UseCard, 999, function(e)
      local use = e.data[1]
      if use.from == player.id and use.card.suit ~= Card.NoSuit then
        table.removeOne(no_used_color, use.card.suit)
      end
    end, Player.HistoryTurn)
    room:setPlayerMark(player, "ss_heg__limu-turn", no_used_color)
    local result, dat = room:askForUseActiveSkill(player, "#ss_heg__limu_filter", "#ss_heg__limu", true)
    if result then
      room:throwCard(dat.cards, self.name, to, to)
    else
      to:drawCards(4-#no_used_color, self.name)
      if H.hasGeneral(to, true) then
        H.removeGeneral(room, to, true)
        if not to.dead then
          to:gainAnExtraTurn(true, self.name)
        end
      end
    end
  end,
}

jueguan:addRelatedSkill(jueguan_active)
jueguan:addRelatedSkill(jueguan_maxcards)
jueguan:addRelatedSkill(jueguan_prohibit)
limu:addRelatedSkill(limu_filter)
liuyan:addSkill(limu)
liuyan:addSkill(jueguan)

Fk:loadTranslationTable{
  ["ss_heg__liuyan"] = "刘焉", --群雄
  ["designer:ss_heg__liuyan"] = "静谦",
  ["ss_heg__jueguan"] = "绝关",
  [":ss_heg__jueguan"] = "出牌阶段开始时，你可以展示任意张花色各不相同的牌，令所有角色于此阶段内均不能使用或打出这些花色的牌且这些牌本回合不计入你手牌上限。",
  ["ss_heg__limu"] = "立牧",
  [":ss_heg__limu"] = "结束阶段，你可以令一名角色选择一项：1.弃置一张你本回合未使用过的花色的牌；2.摸X张牌，然后移除副将并执行一个额外回合（X为你本回合使用过的花色数）。",

  ["jueguan"] = "绝关",
  ["@@ss_heg__jueguan-inhand"] = "绝关",
  ["@ss_heg__jueguan_suit-phase"] = "绝关",
  ["@ss_heg__jueguan_suit"] = "绝关",
  ["@@ss_heg__jueguan-inhand-turn"] = "绝关",
  ["#ss_heg__jueguan_prohibit"] = "绝关",
  ["#ss_heg__jueguan_active"] = "绝关",
  ["#ss_heg__jueguan-choose"] = "绝关：选择任意张花色各不相同的牌",

  ["#ss_heg__limu-choose"] = "立牧：选择一名角色，令其弃置你本回合未使用花色的牌，或移除副将并执行一个额外的回合",
  ["#ss_heg__limu_filter"] = "立牧",
  ["#ss_heg__limu"] = "立牧：弃置一张本回合未使用花色的牌，或摸牌移除副将并执行一个额外的回合",

  ["~ss_heg__liuyan"] = "",
}

return extension
