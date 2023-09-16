local extension = Package:new("power")
extension.extensionName = "hegemony"
extension.game_modes_whitelist = { 'nos_heg_mode', 'new_heg_mode' }
local H = require "packages/hegemony/util"

Fk:loadTranslationTable{
  ["power"] = "君临天下·权",
}
--[[
Fk:loadTranslationTable{
  ["ld__cuiyanmaojie"] = "崔琰毛玠",
  ["zhengbi"] = "征辟",
  [":zhengbi"] = "出牌阶段开始时，你可选择：1.选择一名没有势力的角色，你于此回合内对其使用牌无距离关系的限制，且对包括其在内的角色使用牌无次数限制；2.将一张基本牌交给一名有势力的角色，若其有牌且牌数：为1，其将所有牌交给你；大于1，其将一张不是基本牌的牌或两张基本牌交给你。",
  ["ld__fengying"] = "奉迎",
  [":ld__fengying"] = "限定技，出牌阶段，你可将所有手牌当【挟天子以令诸侯】（无目标的限制）使用，当此牌被使用时，你选择所有与你势力相同的角色，这些角色各将手牌补至X张（X为其体力上限）。",

  ["$zhengbi1"] = "跅弛之士，在御之而已。",
  ["$zhengbi2"] = "	内不避亲，外不避仇。",
  ["$ld__fengying1"] = "二臣恭奉，以迎皇嗣。	",
  ["$ld__fengying2"] = "奉旨典选，以迎忠良。",
  ["~ld__cuiyanmaojie"] = "为世所痛惜，冤哉……",
}
]]
local yujin = General(extension, "ld__yujin", "wei", 4)
local jieyue = fk.CreateTriggerSkill{
  name = "ld__jieyue",
  anim_type = "control",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and player.phase == Player.Start and not player:isKongcheng() and table.find(player.room.alive_players, function(p) return
      p.kingdom ~= "wei"
    end)
  end,
  on_cost = function(self, event, target, player, data)
    local plist, cid = player.room:askForChooseCardAndPlayers(player, table.map(table.filter(player.room.alive_players, function(p) return
      p.kingdom ~= "wei" and p ~= player
    end), Util.IdMapper), 1, 1, ".|.|.|hand", "#ld__jieyue-target", self.name, true)
    if #plist > 0 then
      self.cost_data = {plist[1], cid}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = self.cost_data[1]
    local target = room:getPlayerById(to)
    room:moveCardTo(self.cost_data[2], Player.Hand, target, fk.ReasonGive, self.name, nil, false, player.id)
    if H.askCommandTo(player, target, self.name) then
      player:drawCards(1, self.name)
    else
      room:addPlayerMark(player, "_ld__jieyue-turn")
    end
  end
}
local jieyue_draw = fk.CreateTriggerSkill{
  name = "#ld__jieyue_draw",
  mute = true,
  frequency = Skill.Compulsory,
  events = {fk.DrawNCards},
  can_use = function(self, event, target, player, data)
    return target == player and target:getMark("_ld__jieyue-turn") > 0
  end,
  on_use = function(self, event, target, player, data)
    data.n = data.n + 3 * target:getMark("_ld__jieyue-turn")
  end,
}
jieyue:addRelatedSkill(jieyue_draw)

yujin:addSkill(jieyue)
yujin:addCompanions("hs__xiahoudun")

Fk:loadTranslationTable{
  ['ld__yujin'] = '于禁',
  ['ld__jieyue'] = '节钺',
  [':ld__jieyue'] = '准备阶段开始时，你可将一张手牌交给不是魏势力或没有势力的一名角色，对其发起军令。若其：执行，你摸一张牌；不执行，摸牌阶段，你令额定摸牌数+3。',

  ["#ld__jieyue-target"] = "节钺：你可将一张手牌交给不是魏势力或没有势力的一名角色，对其发起军令",
  ["#ld__jieyue_draw"] = "节钺",

  ["$ld__jieyue1"] = "杀我？你做不到！",
  ["$ld__jieyue2"] = "阳关大道，你不选吗？",
  ["~ld__yujin"] = "晚节不保……",
}

local wangping = General(extension, "ld__wangping", "shu", 4)
wangping:addCompanions("ld__jiangwanfeiyi")
local jianglue = fk.CreateActiveSkill{
  name = "jianglue",
  frequency = Skill.Limited,
  anim_type = "support",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local index = H.startCommand(player, self.name)
    local kingdom = H.getKingdom(player)
    for _, p in ipairs(room:getAlivePlayers()) do -- 双势力，君主……
      if p.kingdom == "unknown" and not p.dead then
        if H.getKingdomPlayersNum(room)[kingdom] >= #room.players // 2 then break end
        local main = Fk.generals[p:getMark("__heg_general")].kingdom == kingdom
        local deputy = Fk.generals[p:getMark("__heg_deputy")].kingdom == kingdom
        H.askForRevealGenerals(room, p, self.name, main, deputy)
      end
    end
    local targets = table.map(table.filter(room.alive_players, function(p) return H.compareKingdomWith(p, player) and p ~= player end), Util.IdMapper)
    local tos = {}
    if #targets > 0 then
      room:doIndicate(player.id, targets)
      room:sortPlayersByAction(targets)
      for _, pid in ipairs(targets) do
        local p = room:getPlayerById(pid)
        if player.dead then break end
        if not p.dead and H.doCommand(p, self.name, index, player) then
          table.insert(tos, pid)
        end
      end
    end
    room:changeMaxHp(player, 1)
    room:recover({
      who = player,
      num = 1,
      recoverBy = player,
      skillName = self.name
    })
    if #tos == 0 then return false end
    local num = 0
    room:sortPlayersByAction(tos)
    for _, pid in ipairs(tos) do
      local p = room:getPlayerById(pid)
      room:changeMaxHp(p, 1)
      if room:recover({
        who = p,
        num = 1,
        recoverBy = player,
        skillName = self.name
      }) then
        num = num + 1
      end
    end
    if num > 0 then player:drawCards(num, self.name) end
  end
}
wangping:addSkill(jianglue)

Fk:loadTranslationTable{
  ["ld__wangping"] = "王平",
  ["jianglue"] = "将略",
  [":jianglue"] = "限定技，出牌阶段，你可从随机两项军令中选择一项，然后发动势力召唤。你选择所有与你势力相同的其他角色，这些角色各选择是否执行此军令。你加1点体力上限，回复1点体力，所有选择是的角色各加1点体力上限，回复1点体力。然后你摸X张牌（X为以此法回复过体力的角色数）。",

  ["$jianglue1"] = "奇谋为短，将略为要。",
  ["$jianglue2"] = "为将者，需有谋略。",
  ["~ld__wangping"] = "无当飞军，也有困于深林之时……",
}

local fazheng = General(extension, "ld__fazheng", "shu", 3)
fazheng:addCompanions("hs__liubei")
local enyuan = fk.CreateTriggerSkill{
  name = "ld__enyuan",
  events = {fk.TargetConfirmed, fk.Damaged},
  frequency = Skill.Compulsory,
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if target ~= player or not player:hasSkill(self.name) then return false end
    if event == fk.Damaged then
      return data.from and not data.from.dead
    else
      return data.card.trueName == "peach" and data.from ~= player.id and not player.room:getPlayerById(data.from).dead
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.TargetConfirmed then
      room:notifySkillInvoked(player, self.name, "support")
      player:broadcastSkillInvoke(self.name, 2)
      local from = data.from
      if from and not room:getPlayerById(from).dead then
        room:doIndicate(player.id, {from})
        room:getPlayerById(from):drawCards(1, self.name)
      end
    else
      room:notifySkillInvoked(player, self.name, "masochism")
      player:broadcastSkillInvoke(self.name, 1)
      local from = data.from
      if from and not from.dead then
        room:doIndicate(player.id, {from.id})
        if from == player then
          room:loseHp(player, 1, self.name)
        else
          local card = room:askForCard(from, 1, 1, false, self.name, true, ".|.|.|hand", "#ld__enyuan-give:"..player.id)
          if #card > 0 then
            room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonGive, self.name, nil, false, player.id)
          else
            room:loseHp(from, 1, self.name)
          end
        end
      end
    end
  end,
}
local wushengXH = fk.CreateViewAsSkill{
  name = "xuanhuo__hs__wusheng",
  anim_type = "offensive",
  pattern = "slash",
  card_filter = function(self, to_select, selected)
    if #selected == 1 then return false end
    return Fk:getCardById(to_select).color == Card.Red
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
local paoxiaoTriggerXH = fk.CreateTriggerSkill{
  name = "#xuanhuo__hs__paoxiaoTrigger",
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

  refresh_events = {fk.CardUsing},
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and
      data.card.trueName == "slash" and
      player:usedCardTimes("slash") > 1
  end,
  on_refresh = function(self, event, target, player, data)
    player:broadcastSkillInvoke("hs__paoxiao")
    player.room:doAnimate("InvokeSkill", {
      name = "paoxiao",
      player = player.id,
      skill_type = "offensive",
    })
  end,
}
local paoxiaoXH = fk.CreateTargetModSkill{
  name = "xuanhuo__hs__paoxiao",
  frequency = Skill.Compulsory,
  bypass_times = function(self, player, skill, scope)
    if player:hasSkill(self.name) and skill.trueName == "slash_skill"
      and scope == Player.HistoryPhase then
      return true
    end
  end,
}
paoxiaoXH:addRelatedSkill(paoxiaoTriggerXH)
local longdanXH = fk.CreateViewAsSkill{
  name = "xuanhuo__hs__longdan",
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
local longdanAfterXH = fk.CreateTriggerSkill{
  name = "#xuanhuo__longdan_after",
  anim_type = "offensive",
  visible = false,
  events = {fk.CardEffectCancelledOut},
  can_trigger = function(self, event, target, player, data)
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
longdanXH:addRelatedSkill(longdanAfterXH)
local tieqiXH = fk.CreateTriggerSkill{
  name = "xuanhuo__hs__tieqi",
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
        if Fk.skills[skill_name].frequency ~= Skill.Compulsory then
          table.insertIfNeed(mark, skill_name)
        end
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
local tieqiInvalidityXH = fk.CreateInvaliditySkill {
  name = "#xuanhuo__hs__tieqi_invalidity",
  invalidity_func = function(self, from, skill)
    if from:getMark("_hs__tieqi-turn") ~= 0 then
      return table.contains(from:getMark("_hs__tieqi-turn"), skill.name) and
      (skill.frequency ~= Skill.Compulsory and skill.frequency ~= Skill.Wake) and not skill.name:endsWith("&")
    end
  end
}
tieqiXH:addRelatedSkill(tieqiInvalidityXH)
local liegongXH = fk.CreateTriggerSkill{
  name = "xuanhuo__hs__liegong",
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
local kuangguXH = fk.CreateTriggerSkill{
  name = "xuanhuo__hs__kuanggu",
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
    return data.damageEvent and player == data.damageEvent.from and player:distanceTo(target) < 2 and player:distanceTo(target) > -1
  end,
  on_refresh = function(self, event, target, player, data)
    data.damageEvent.extra_data = data.damageEvent.extra_data or {}
    data.damageEvent.extra_data.kuanggucheak = true
  end,
}
local xuanhuo = fk.CreateTriggerSkill{
  name = "ld__xuanhuo",
  mute = true,
  refresh_events = {fk.EventAcquireSkill, fk.EventLoseSkill, fk.Deathed, fk.GeneralRevealed, fk.GeneralHidden},
  can_refresh = function(self, event, target, player, data)
    if player ~= target then return false end
    if event == fk.Deathed then return player:hasSkill(self.name, true, true)
    elseif event == fk.EventAcquireSkill or event == fk.EventLoseSkill then return data == self
    else return true end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local players = room.alive_players
    local fazhengs = table.filter(players, function(p) return table.contains(p.player_skills, self) end)
    local xuanhuo_map = {}
    for _, p in ipairs(players) do
      local will_attach = false
      for _, fazheng in ipairs(fazhengs) do
        if (fazheng ~= p and H.compareKingdomWith(fazheng, p)) then
          will_attach = true
          break
        end
      end
      xuanhuo_map[p] = will_attach
    end
    for p, v in pairs(xuanhuo_map) do
      if v ~= player:hasSkill("ld__xuanhuo_other&") then
        room:handleAddLoseSkills(p, v and "ld__xuanhuo_other&" or "-ld__xuanhuo_other&", nil, false, true)
      end
    end
  end,
}
local xuanhuoOther = fk.CreateActiveSkill{
  name = "ld__xuanhuo_other&",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0 and table.find(Fk:currentRoom().alive_players, function(p)
      return table.contains(p.player_skills, xuanhuo) and H.compareKingdomWith(p, player) and p ~= Self
    end)
  end,
  card_num = 1,
  card_filter = function(self, to_select, selected)
    return #selected < 2 and Fk:currentRoom():getCardArea(to_select) == Player.Hand
  end,
  target_num = 0,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local targets = table.filter(room:getOtherPlayers(player), function(p) return table.contains(p.player_skills, xuanhuo) and H.compareKingdomWith(p, player) end)
    if #targets == 0 then return false end
    local to
    if #targets == 1 then
      to = targets[1]
    else
      to = room:getPlayerById(room:askForChoosePlayers(player, table.map(targets, function(p) return p.id end), 1, 1, nil, self.name, false)[1])
    end
    room:doIndicate(player.id, {to.id})
    to:broadcastSkillInvoke(self.name)
    room:moveCardTo(effect.cards, Player.Hand, to, fk.ReasonGive, self.name, nil, false, to.id)
    if player:isNude() or not room:askForDiscard(player, 1, 1, true, self.name, false, nil, "#ld__xuanhuo-ask") then return false end
    if player.dead then return false end
    local all_choices = {"xuanhuo__hs__wusheng", "xuanhuo__hs__paoxiao", "xuanhuo__hs__longdan","xuanhuo__hs__tieqi", "xuanhuo__hs__liegong", "xuanhuo__hs__kuanggu"}
    -- {"hs__wusheng", "hs__paoxiao", "hs__longdan","hs__tieqi", "hs__liegong", "hs__kuanggu"}
    local choices = {}
    local skills = {}
    for _, p in ipairs(room.alive_players) do
      for _, s in ipairs(p.player_skills) do
        table.insert(skills, s.name)
      end
    end
    for _, skill in ipairs(all_choices) do
      local skillNames = {skill, skill:sub(10)}
      local can_choose = true
      for _, sname in ipairs(skills) do
        if table.contains(skillNames, sname) then
          can_choose = false
          break
        end
      end
      if can_choose then table.insert(choices, skill) end
    end
    if #choices == 0 then return false end

    local choice = room:askForChoice(player, choices, self.name, "#ld__xuanhuo-choice", true, all_choices)
    room:handleAddLoseSkills(player, choice, nil)
    local record = type(player:getMark("@ld__xuanhuo_skills-turn")) == "table" and player:getMark("@ld__xuanhuo_skills-turn") or {}
    table.insert(record, choice)
    room:setPlayerMark(player, "@ld__xuanhuo_skills-turn", record)
  end,
}
local xuanhuoOtherLose = fk.CreateTriggerSkill{
  name = "#ld__xuanhuo_other_lose&",
  visible = false,
  refresh_events = {fk.EventPhaseStart, fk.GeneralRevealed},
  can_refresh = function(self, event, target, player, data)
    if type(player:getMark("@ld__xuanhuo_skills-turn")) ~= "table" then return false end
    if event == fk.EventPhaseStart then
      return target == player and player.phase == Player.NotActive
    else
      return true
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    if event == fk.EventPhaseStart then
      local _skills = player:getMark("@ld__xuanhuo_skills-turn")
      local skills = "-" .. table.concat(_skills, "|-")
      room:handleAddLoseSkills(player, skills, nil)
      room:setPlayerMark(player, "@ld__xuanhuo_skills-turn", 0)
    else
      local skills = {}
      table.forEach(room.alive_players, function(p) table.insertTable(skills, p.player_skills) end)
      local xuanhuoSkills = player:getMark("@ld__xuanhuo_skills-turn")
      if type(xuanhuoSkills) == "table" then
        local detachList = {}
        for _, skill in ipairs(skills) do
          local skillName = "xuanhuo__" .. skill.name
          if (table.contains(xuanhuoSkills, skillName)) then
            table.removeOne(xuanhuoSkills, skillName)
            table.insert("-" .. skillName)
          end
        end
        if #detachList > 0 then
          room:handleAddLoseSkills(player, table.concat(detachList, "|"), nil)
          room:setPlayerMark(player, "@ld__xuanhuo_skills-turn", #xuanhuoSkills > 0 and xuanhuoSkills or 0)
        end
      end
    end
  end,
}
xuanhuoOther:addRelatedSkill(xuanhuoOtherLose)
Fk:addSkill(xuanhuoOther)

fazheng:addSkill(enyuan)
fazheng:addSkill(xuanhuo)
fazheng:addRelatedSkill(wushengXH)
fazheng:addRelatedSkill(paoxiaoXH)
fazheng:addRelatedSkill(longdanXH)
fazheng:addRelatedSkill(tieqiXH)
fazheng:addRelatedSkill(liegongXH)
fazheng:addRelatedSkill(kuangguXH)

Fk:loadTranslationTable{
  ["ld__fazheng"] = "法正",
  ["ld__enyuan"] = "恩怨",
  [":ld__enyuan"] = "锁定技，当你成为【桃】的目标后，若使用者不为你，其摸一张牌；当你受到伤害后，伤害来源需交给你一张手牌，否则失去1点体力。",
  ["ld__xuanhuo"] = "眩惑",
  [":ld__xuanhuo"] = "与你势力相同的其他角色的出牌阶段限一次，其可交给你一张手牌，然后其弃置一张牌，选择下列技能中的一个：〖武圣〗〖咆哮〗〖龙胆〗〖铁骑〗〖烈弓〗〖狂骨〗（场上已有的技能无法选择）。其于此回合内或明置有其以此法选择的技能的武将牌之前拥有其以此法选择的技能。",

  ["ld__xuanhuo_other&"] = "眩惑",
  [":ld__xuanhuo_other&"] = "你可交给法正一张手牌，然后弃置一张牌，选择下列技能中的一个：〖武圣〗〖咆哮〗〖龙胆〗〖铁骑〗〖烈弓〗〖狂骨〗（场上已有的技能无法选择）。你于此回合内或明置有以此法选择的技能的武将牌之前拥有以此法选择的技能。",
  ["xuanhuo__hs__wusheng"] = "武圣",
  ["xuanhuo__hs__paoxiao"] = "咆哮",
  ["xuanhuo__hs__longdan"] = "龙胆",
  ["xuanhuo__hs__tieqi"] = "铁骑",
  ["xuanhuo__hs__liegong"] = "烈弓",
  ["xuanhuo__hs__kuanggu"] = "狂骨",
  [":xuanhuo__hs__wusheng"] = "你可将一张红色牌当【杀】使用或打出。",
  [":xuanhuo__hs__paoxiao"] = "锁定技，你使用【杀】无次数限制。当你于出牌阶段使用第二张【杀】时，你摸一张牌。",
  [":xuanhuo__hs__longdan"] = "你可将【闪】当【杀】使用或打出，当此【杀】被一名角色使用的【闪】抵消后，你可对另一名角色造成1点伤害。你可将【杀】当【闪】使用或打出，当一名角色使用的【杀】被此【闪】抵消后，你可令另一名其他角色回复1点体力。",
  [":xuanhuo__hs__tieqi"] = "当你使用【杀】指定目标后，你可判定，令其本回合一张明置的武将牌非锁定技失效，其需弃置一张与判定结果花色相同的牌，否则其不能使用【闪】抵消此【杀】。",
  [":xuanhuo__hs__liegong"] = "当你于出牌阶段内使用【杀】指定目标后，若其手牌数不小于你的体力值或不大于你的攻击范围，你可令其不能使用【闪】响应此【杀】。",
  [":xuanhuo__hs__kuanggu"] = "当你对距离1以内的角色造成1点伤害后，你可摸一张牌或回复1点体力。",
  ["#xuanhuo__hs__paoxiaoTrigger"] = "咆哮",
  ["#xuanhuo__longdan_after"] = "龙胆",

  ["#ld__enyuan-give"] = "恩怨：交给 %src 一张手牌，否则失去1点体力",
  ["#ld__xuanhuo-ask"] = "眩惑：弃置一张牌",
  ["@ld__xuanhuo_skills-turn"] = "眩惑",
  
  ["$ld__enyuan1"] = "伤了我，休想全身而退！",
  ["$ld__enyuan2"] = "报之以李，还之以桃。",
  ["~ld__fazheng"] = "汉室复兴，我，是看不到了……",
}

local lukang = General(extension, "ld__lukang", "wu", 3, 3, General.Male)
local keshou_filter = fk.CreateActiveSkill{
  name = "#ld__keshou_filter",
  min_card_num = 2,
  max_card_num = 2,
  card_filter = function(self, to_select, selected)
    return table.every(selected, function(id)
      return Fk:getCardById(to_select).color == Fk:getCardById(id).color
    end)
  end,
  target_filter = function (self, to_select, selected)
    return false
  end,
}
Fk:addSkill(keshou_filter)
local keshou = fk.CreateTriggerSkill{
  name = "ld__keshou",
  anim_type = "defensive",
  events = {fk.DamageInflicted},
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(self.name) and player == target and #target:getCardIds("he") > 1
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local result, dat = room:askForUseActiveSkill(player, "#ld__keshou_filter", "@ld__keshou", true)
    if result then
      self.cost_data = dat.cards
      return true
    end
    
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room 
    room:throwCard(self.cost_data, self.name, player, player)
    data.damage = data.damage - 1
    if player and #table.filter(room.alive_players, function(p) return H.compareKingdomWith(p, player, true) end) == 1 then
        local judge = {
          who = player,
          reason = self.name,
          pattern = ".|.|heart,diamond|.|.|.",
        }
        room:judge(judge)
        if judge.card.suit == Card.Red then
           player:drawCards(1, self.name)
        end
      end
  end,
}

local zhuwei = fk.CreateTriggerSkill{
  name = "ld__zhuwei",
  anim_type = "drawcard",
  events = {fk.FinishJudge},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) 
     and player.room:getCardArea(data.card) == Card.Processing
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:obtainCard(player.id, data.card, true, fk.ReasonJustMove)
    local current = room.current
    local choices = {"ld__zhuwei_ask::" .. current.id, "Cancel"}
    if room:askForChoice(player, choices, self.name) ~= "Cancel" then
      if current:getMark("@ld__zhuwei_buff-turn") == 0 then
        room:addPlayerMark(current, "@ld__zhuwei_buff-turn", 1)
      else
        room:setPlayerMark(current, "@ld__zhuwei_buff-turn", current:getMark("@ld__zhuwei_buff-turn") + 1)
      end
    end
  end,
}

local zhuwei_maxcards = fk.CreateMaxCardsSkill{
  name = "#ld__zhuwei_maxcards",
  correct_func = function(self, player)
    return player:getMark("@ld__zhuwei_buff-turn")
  end,
}

local zhuwei_targetmod = fk.CreateTargetModSkill{
  name = "#ld__zhuwei_targetmod",
  residue_func = function(self, player, skill, scope)
    if skill.trueName == "slash_skill" and player:getMark("@ld__zhuwei_buff-turn") > 0 and scope == Player.HistoryPhase then
      return player:getMark("@ld__zhuwei_buff-turn")
    end
  end,
}


lukang:addSkill(keshou)
zhuwei:addRelatedSkill(zhuwei_targetmod)
zhuwei:addRelatedSkill(zhuwei_maxcards)
lukang:addSkill(zhuwei)
lukang:addCompanions("hs__luxun")
Fk:loadTranslationTable{
  ["ld__lukang"] = "陆抗",
  ["ld__keshou"] = "恪守",
  [":ld__keshou"] = "当你受到伤害时，你可弃置两张颜色相同的牌，令此伤害值-1，然后若没有与你势力相同的其他角色，你判定，若结果为红色，你摸一张牌。",
  ["@ld__keshou"] = "恪守：是否弃置两张牌，令你受到的伤害-1",
  ["ld__zhuwei"] = "筑围",
  [":ld__zhuwei"] = "当你进行的判定结果确定后，你可获得此牌，然后你可令当前回合角色手牌上限和使用【杀】的次数上限于此回合内+1。",
  ["ld__zhuwei_ask"] = "令当前回合角色手牌上限和使用【杀】的次数上限于此回合内+1",
  ["@ld__zhuwei_buff"] = "筑围",

  ["$ld__keshou1"] = "仁以待民，自处不败之势。",
  ["$ld__keshou2"] = "宽济百姓，则得战前养备之机。",
  ["$ld__zhuwei1"] = "背水一战，只为破敌。",
  ["$ld__zhuwei2"] = "全线并进，连战克晋。",
  ["~ld__ld__lukang"] = "抗仅以君子之交待叔子，未有半分背国之念啊。",
}

local wuguotai = General(extension, "ld__wuguotai", "wu", 3, 3, General.Female)
local buyi = fk.CreateTriggerSkill{
  name = "ld__buyi",
  anim_type = "support",
  events = {fk.AfterDying},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self.name) and player:usedSkillTimes(self.name) == 0 and target and not target.dead and
    H.compareKingdomWith(target, player) and data.damage and data.damage.from and not data.damage.from.dead
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, nil, "#ld__buyi-ask:" .. target.id .. ":" .. data.damage.from.id)
  end,
  on_use = function(self, event, target, player, data)
    player.room:doIndicate(player.id, {data.damage.from.id})
    if not H.askCommandTo(player, data.damage.from, self.name) then
      player.room:recover({
        who = target,
        num = 1,
        recoverBy = player,
        skillName = self.name,
      })
    end
  end,
}

wuguotai:addSkill(buyi)
wuguotai:addSkill("ganlu")
wuguotai:addCompanions("hs__sunjian")

Fk:loadTranslationTable{
  ['ld__wuguotai'] = '吴国太',
  ['ld__buyi'] = '补益',
  [':ld__buyi'] = '每回合限一次，与你势力相同的角色的濒死结算结束后，若其存活，你可对伤害来源发起军令。若来源不执行，则你令该角色回复1点体力。',

  ["#ld__buyi-ask"] = "补益：你可对 %dest 发起军令。若来源不执行，则 %src 回复1点体力",

  ["$ganlu_ld__wuguotai1"] = "玄德，实乃佳婿呀！", -- 特化
	["$ganlu_ld__wuguotai2"] = "好一个郎才女貌，真是天作之合啊。",
	["$ld__buyi1"] = "有我在，定保贤婿无余！",
	["$ld__buyi2"] = "东吴，岂容汝等儿戏！",
	["~ld__wuguotai"] = "诸位卿家，还请尽力辅佐仲谋啊……",
}

local yuanshu = General(extension, "ld__yuanshu", "qun", 4)
yuanshu:addCompanions("hs__jiling")
local yongsi = fk.CreateTriggerSkill{
  name = "ld__yongsi",
  anim_type = "drawcard",
  frequency = Skill.Compulsory,
  events = {fk.EventPhaseStart, fk.DrawNCards, fk.TargetConfirmed},
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if target ~= player or not player:hasSkill(self.name) then return false end
    if event == fk.TargetConfirmed then
      return data.card.trueName == "known_both" and not player:isKongcheng()
    else
      if not H.isBigKingdomPlayer(player) or table.find(player.room.alive_players, function(p)
        return table.find(p:getEquipments(Card.SubtypeTreasure), function(cid)
          return Fk:getCardById(cid).name == "jade_seal"
        end)
      end) then return false end
      return event == fk.DrawNCards or player.phase == Player.Play
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if event == fk.EventPhaseStart then
      local card = Fk:cloneCard("known_both")
      local max_num = card.skill:getMaxTargetNum(player, card)
      local targets = {}
      for _, p in ipairs(room:getOtherPlayers(player)) do
        if not player:isProhibited(p, card) then
          table.insert(targets, p.id)
        end
      end
      if #targets == 0 or max_num == 0 then return end
      local to = room:askForChoosePlayers(player, targets, 1, max_num, "#yongsi__jade_seal-ask", self.name, false)
      if #to > 0 then
        self.cost_data = to
        return true
      end
    else
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke(self.name)
    if event == fk.EventPhaseStart then
      room:notifySkillInvoked(player, self.name, "control")
      local targets = table.map(self.cost_data, Util.Id2PlayerMapper)
      room:useVirtualCard("known_both", nil, player, targets, self.name)
    elseif event == fk.DrawNCards then
      room:notifySkillInvoked(player, self.name, "drawcard")
      data.n = data.n + 1
    else
      room:notifySkillInvoked(player, self.name, "negative")
      if not player:isKongcheng() then
        player:showCards(player:getCardIds(Player.Hand))
      end
    end
  end,
}
local yongsiBig = H.CreateBigKingdomSkill{
  name = "#yongsi_big",
  fixed_func = function(self, player)
    return player:hasSkill(self.name) and player.kingdom ~= "unknown" and not table.find(Fk:currentRoom().alive_players, function(p)
      return table.find(p:getEquipments(Card.SubtypeTreasure), function(cid)
        return Fk:getCardById(cid).name == "jade_seal"
      end)
    end)
  end
}
yongsi:addRelatedSkill(yongsiBig)
local weidi = fk.CreateActiveSkill{
  name = "ld__weidi",
  anim_type = "control",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,
  card_filter = Util.FalseFunc,
  target_num = 1,
  target_filter = function(self, to_select, selected)
    return to_select ~= Self.id and Fk:currentRoom():getPlayerById(to_select):getMark("_ld__weidi-turn") > 0
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    if not H.askCommandTo(player, target, self.name) and not target:isKongcheng() then
      local cards = Fk:cloneCard("dilu")
      cards:addSubcards(target:getCardIds(Player.Hand))
      room:obtainCard(player, cards, false, fk.ReasonPrey)
      local num = #cards.subcards
      local cids
      if #player:getCardIds{Player.Hand} > num then
        cids = room:askForCard(player, num, num, true, self.name, false, nil, "#ld__weidi-cards::" .. target.id .. ":" .. num)
      else
        cids = player:getCardIds{Player.Hand}
      end
      if #cids > 0 then
        room:moveCardTo(cids, Player.Hand, target, fk.ReasonGive, self.name, nil, false, player.id)
      end
    end
  end,
}
local weidiRecorder = fk.CreateTriggerSkill{
  name = "#ld__weidi_recorder",
  visible = false,
  refresh_events = {fk.AfterCardsMove, fk.EventAcquireSkill},
  can_refresh = function(self, event, target, player, data)
    return event == fk.AfterCardsMove or (target == player and data == weidi)
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    if event == fk.AfterCardsMove then
      for _, move in ipairs(data) do
        if move.toArea == Card.PlayerHand and move.to then
          local target = room:getPlayerById(move.to)
          if target and target:getMark("_ld__weidi-turn") == 0 then
            for _, info in ipairs(move.moveInfo) do
              if info.fromArea == Card.DrawPile and target:getMark("_ld__weidi-turn") == 0 then
                room:setPlayerMark(target, "_ld__weidi-turn", 1)
              end
            end
          end
        end
      end
    else
      room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function(e)
        local move = e.data[1]
        if move.toArea == Card.PlayerHand and move.to then
          local target = room:getPlayerById(move.to)
          if target and target:getMark("_ld__weidi-turn") == 0 then
            for _, info in ipairs(move.moveInfo) do
              if info.fromArea == Card.DrawPile and target:getMark("_ld__weidi-turn") == 0 then
                room:setPlayerMark(target, "_ld__weidi-turn", 1)
              end
            end
          end
        end
      end, Player.HistoryTurn)
    end
  end,
}
weidi:addRelatedSkill(weidiRecorder)
yuanshu:addSkill(yongsi)
yuanshu:addSkill(weidi)

Fk:loadTranslationTable{
  ['ld__yuanshu'] = '袁术',
  ['ld__yongsi'] = "庸肆",
  [':ld__yongsi'] = "锁定技，若所有角色的装备区里均没有【玉玺】，你视为装备着【玉玺】；当你成为【知己知彼】的目标后，展示所有手牌。",
  ['ld__weidi'] = "伪帝",
  [':ld__weidi'] = "出牌阶段限一次，你可选择一名本回合从牌堆获得过牌的其他角色，对其发起军令。若其不执行，则你获得其所有手牌，然后交给其等量的牌。",

  ["#yongsi__jade_seal-ask"] = "庸肆：受到【玉玺】的效果，视为你使用一张【知己知彼】",
  ["#ld__weidi-cards"] = "伪帝：交给 %dest %arg 张牌",

  ["$ld__yongsi1"] = "大汉天下，已半入我手。",
  ["$ld__yongsi2"] = "玉玺在手，天下我有。",
  ["$ld__weidi1"] = "你们都得听我的号令！",
  ["$ld__weidi2"] = "我才是皇帝！",
  ["~ld__yuanshu"] = "可恶！就差……一步了……",
}

local zhangxiu = General(extension, "ld__zhangxiu", "qun", 4)
local fudi = fk.CreateTriggerSkill{
  name = 'ld__fudi',
  events = { fk.Damaged },
  anim_type = "masochism",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and data.from and data.from ~= player
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local c = room:askForCard(player, 1, 1, false, self.name, true,
      '.|.|.|hand', '#ld__fudi-give:' .. data.from.id)[1]

    if c then
      self.cost_data = c
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:obtainCard(data.from, self.cost_data, false, fk.ReasonGive)

    local p = data.from
    local x = player.hp
    if not p or p.dead then return end
    local targets = {}
    for _, _p in ipairs(room.alive_players) do
      if H.compareKingdomWith(_p, p) then
        if _p.hp >= x then
          if _p.hp > x then
            targets = {}
            x = _p.hp
          end
          table.insert(targets, _p)
        end
      end
    end
    local to
    if #targets == 0 then return
    elseif #targets == 1 then
      to = targets[1].id
    else
      to = room:askForChoosePlayers(player, table.map(targets, Util.IdMapper),
        1, 1, '#ld__fudi-dmg', self.name, false)[1]
    end

    room:damage {
      from = player,
      to = room:getPlayerById(to),
      damage = 1,
      skillName = self.name,
    }
  end,
}
local congjian = fk.CreateTriggerSkill{
  name = 'ld__congjian',
  anim_type = "offensive",
  events = { fk.DamageInflicted, fk.DamageCaused },
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    if not (target == player and player:hasSkill(self.name)) then return end
    if event == fk.DamageInflicted then
      return player.phase ~= Player.NotActive
    elseif event == fk.DamageCaused then
      return player.phase == Player.NotActive
    end
  end,
  on_use = function(_, _, _, _, data)
    data.damage = data.damage + 1
  end,
}
zhangxiu:addSkill(fudi)
zhangxiu:addSkill(congjian)
zhangxiu:addCompanions("hs__jiaxu")
Fk:loadTranslationTable{
  ['ld__zhangxiu'] = '张绣',
  ['ld__fudi'] = '附敌',
  [':ld__fudi'] = '当你受到其他角色造成的伤害后，你可以交给伤害来源一张手牌。若如此做，你对与其势力相同的角色中体力值最多且不小于你的一名角色造成1点伤害。',
  ['#ld__fudi-give'] = '附敌：你可以交给 %src 一张手牌，然后对其势力体力最大造成一点伤害',
  ['#ld__fudi-dmg'] = '附敌：选择要造成伤害的目标',
  ['ld__congjian'] = '从谏',
  [':ld__congjian'] = '锁定技，当你于回合外造成伤害时或于回合内受到伤害时，伤害值+1。',

  ['$ld__fudi1'] = '弃暗投明，为明公计！',
	['$ld__fudi2'] = '绣虽有降心，奈何贵营难容。',
	['~ld__zhangxiu'] = '若失文和，吾将何归？',
}

return extension
