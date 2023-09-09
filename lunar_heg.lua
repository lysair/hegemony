local H = require "packages/hegemony/util"
local extension = Package:new("lunar_heg")
extension.extensionName = "hegemony"
extension.game_modes_whitelist = { 'nos_heg_mode', 'new_heg_mode' }

Fk:loadTranslationTable{
  ["lunar_heg"] = "国战-新月杀专属",
  ["fk_heg"] = "新月",
}

local guohuai = General(extension, "fk_heg__guohuai", "wei", 4)
local jingce = fk.CreateTriggerSkill{
  name = "fk_heg__jingce",
  anim_type = "drawcard",
  events = {fk.EventPhaseEnd},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and player.phase == Player.Play and player:getMark("jingce-turn") >= player.hp
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(2, self.name)
  end,

  refresh_events = {fk.CardUsing},
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and player.phase < Player.Discard
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:addPlayerMark(player, "jingce-turn", 1)
  end,
}
guohuai:addSkill(jingce)
guohuai:addCompanions { "hs__zhanghe", "hs__xiahouyuan" }
Fk:loadTranslationTable{
  ["fk_heg__guohuai"] = "郭淮",
  ["fk_heg__jingce"] = "精策",
  [":fk_heg__jingce"] = "出牌阶段结束时，若你本回合已使用的牌数大于或等于你的体力值，你可以摸两张牌。",
}

local caozhang = General(extension, "fk_heg__caozhang", "wei", 4)
caozhang:addSkill("jiangchi")
Fk:loadTranslationTable{
  ["fk_heg__caozhang"] = "曹彰",
}

local caoang = General(extension, "fk_heg__caoang", "wei", 4)
caoang:addSkill("kangkai")
caoang:addCompanions("hs__dianwei")
Fk:loadTranslationTable{
  ["fk_heg__caoang"] = "曹昂",
}

local wangyi = General(extension, "fk_heg__wangyi", "wei", 3, 3, General.Female)
wangyi:addSkill("zhenlie")
wangyi:addSkill("miji")
Fk:loadTranslationTable{
  ["fk_heg__wangyi"] = "王异",
}

local maliang = General(extension, "fk_heg__maliang", "shu", 3)
maliang:addSkill("xiemu")
maliang:addSkill("naman")
Fk:loadTranslationTable{
  ["fk_heg__maliang"] = "马良",
}

local yijik = General(extension, "fk_heg__yijik", "shu", 3)
yijik:addSkill("jijie")
local jiyuan = fk.CreateTriggerSkill{
  name = "fk_heg__jiyuan",
  anim_type = "support",
  events = {fk.EnterDying},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self.name)
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, nil, "#jiyuan-trigger::" .. target.id)
  end,
  on_use = function(self, event, target, player, data)
    player.room:doIndicate(player.id, {target.id})
    target:drawCards(1, self.name)
  end,
}
yijik:addSkill(jiyuan)

Fk:loadTranslationTable{
  ["fk_heg__yijik"] = "伊籍",
  ["fk_heg__jiyuan"] = "急援",
  [":fk_heg__jiyuan"] = "当一名角色进入濒死时，你可令其摸一张牌。",
}

local mazhong = General(extension, "fk_heg__mazhong", "shu", 4)
mazhong:addSkill("fuman")
Fk:loadTranslationTable{
  ['fk_heg__mazhong'] = '马忠',
}

local jianyong = General(extension, "fk_heg__jianyong", "shu", 3)
jianyong:addSkill("qiaoshui")
jianyong:addSkill("zongshij")
Fk:loadTranslationTable{
  ["fk_heg__jianyong"] = "简雍",
}

local handang = General(extension, "fk_heg__handang", "wu", 4)
handang:addSkill("gongqi")
handang:addSkill("jiefan")
Fk:loadTranslationTable{
  ["fk_heg__handang"] = "韩当",
}

local panma = General(extension, "fk_heg__panzhangmazhong", "wu", 4)
panma:addSkill("duodao")
panma:addSkill("anjian")
Fk:loadTranslationTable{
  ['fk_heg__panzhangmazhong'] = '潘璋马忠',
}

local zhuzhi = General(extension, "fk_heg__zhuzhi", "wu", 4)
zhuzhi:addSkill("nos__anguo")
Fk:loadTranslationTable{
  ['fk_heg__zhuzhi'] = '朱治',
}

local zhuhuan = General(extension, "fk_heg__zhuhuan", "wu", 4)
zhuhuan:addSkill("youdi")
Fk:loadTranslationTable{
  ['fk_heg__zhuhuan'] = '朱桓',
}

local hjls = General(extension, "fk_heg__huangjinleishi", "qun", 3, 3, General.Female)
hjls:addSkill("fulu")
hjls:addSkill("zhuji")
hjls:addCompanions("hs__zhangjiao")
Fk:loadTranslationTable{
  ["fk_heg__huangjinleishi"] = "黄巾雷使",
}

local chengui = General(extension, "fk_heg__chengui", "qun", 3)
local yingtu = fk.CreateTriggerSkill{
  name = "fk_heg__yingtu",
  anim_type = "control",
  events = {fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self.name) and player:usedSkillTimes(self.name, Player.HistoryRound) == 0 then
      for _, move in ipairs(data) do
        if move.to ~= nil and move.toArea == Card.PlayerHand then
          local p = player.room:getPlayerById(move.to)
          if p.phase ~= Player.Draw and (p:getNextAlive() == player or player:getNextAlive() == p) and not p:isKongcheng() then
            return true
          end
        end
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = {}
    for _, move in ipairs(data) do
      if move.to ~= nil and move.toArea == Card.PlayerHand then
        local p = player.room:getPlayerById(move.to)
        if p.phase ~= Player.Draw and (p:getNextAlive() == player or player:getNextAlive() == p) and not p:isKongcheng() then
          table.insertIfNeed(targets, move.to)
        end
      end
    end
    if #targets == 1 then
      if room:askForSkillInvoke(player, self.name, nil, "#yingtu-invoke::"..targets[1]) then
        self.cost_data = targets[1]
        return true
      end
    elseif #targets > 1 then
      local tos = room:askForChoosePlayers(player, targets, 1, 1, "#yingtu-invoke-multi", self.name, true)
      if #tos > 0 then
        self.cost_data = tos[1]
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local from = room:getPlayerById(self.cost_data)
    local lastplayer = (player:getNextAlive() == from)
    local card = room:askForCardChosen(player, from, "he", self.name)
    room:obtainCard(player.id, card, false, fk.ReasonPrey)
    local to = player:getNextAlive()
    if lastplayer then
      to = table.find(room.alive_players, function (p)
        return p:getNextAlive() == player
      end)
    end
    if to == nil or to == player then return false end
    local id = room:askForCard(player, 1, 1, true, self.name, false, ".", "#yingtu-choose::"..to.id)[1]
    room:obtainCard(to, id, false, fk.ReasonGive)
    local to_use = Fk:getCardById(id)
    if to_use.type == Card.TypeEquip and not to.dead and room:getCardOwner(id) == to and room:getCardArea(id) == Card.PlayerHand and
        not to:prohibitUse(to_use) then
      --FIXME: stupid 赠物 and 废除装备栏
      room:useCard({
        from = to.id,
        tos = {{to.id}},
        card = to_use,
      })
    end
  end,
}
local congshi = fk.CreateTriggerSkill{
  name = "fk_heg__congshi",
  anim_type = "drawcard",
  frequency = Skill.Compulsory,
  events = {fk.CardUseFinished},
  can_trigger = function(self, event, target, player, data)
    return not target.dead and H.isBigKingdomPlayer(target) and player:hasSkill(self.name) and data.card.type == Card.TypeEquip and table.every(player.room.alive_players, function(p)
      return #target.player_cards[Player.Equip] >= #p.player_cards[Player.Equip]
    end)
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, self.name)
  end,
}
chengui:addSkill(yingtu)
chengui:addSkill(congshi)
Fk:loadTranslationTable{
  ["fk_heg__chengui"] = "陈珪",
  ["fk_heg__yingtu"] = "营图",
  [":fk_heg__yingtu"] = "每轮限一次，当一名角色于其摸牌阶段外获得牌后，若其是你的上家或下家，你可以获得该角色的一张牌，然后交给你的下家或上家一张牌。若以此法给出的牌为装备牌，获得牌的角色使用之。",
  ["fk_heg__congshi"] = "从势",
  [":fk_heg__congshi"] = "锁定技，当大势力角色使用一张装备牌结算结束后，若其装备区里的牌数为全场最多的，你摸一张牌。",

  ["$fk_heg__yingtu1"] = "不过略施小计，聊戏莽夫耳。",
  ["$fk_heg__yingtu2"] = "栖虎狼之侧，安能不图存身？",
  ["$fk_heg__congshi1"] = "阁下奉天子以令诸侯，珪自当相从。",
  ["$fk_heg__congshi2"] = "将军率六师以伐不臣，珪何敢相抗？",
  ["~fk_heg__chengui"] = "终日戏虎，竟为虎所噬。",
}

local gongsunzan = General(extension, "fk_heg__gongsunzan", "qun", 4)
gongsunzan:addSkill("yicong")
gongsunzan:addSkill("qiaomeng")
Fk:loadTranslationTable{
  ["fk_heg__gongsunzan"] = "公孙瓒",
}

local zhouxuan = General(extension, "fk_heg__zhouxuan", "wei", 3)
local wumei = fk.CreateTriggerSkill{
  name = "fk_heg__wumei",
  anim_type = "support",
  events = {fk.BeforeTurnStart},
  frequency = Skill.Limited,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) 
     and player:usedSkillTimes(self.name, Player.HistoryGame) == 0
     and player.hp <= player.room:getTag("RoundCount")
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local to = room:askForChoosePlayers(player, table.map(table.filter(room.alive_players, function (p)
      return p:getMark("@@fk_heg__wumei_extra") == 0 end), function(p) return p.id end), 1, 1, "#fk_heg__wumei-choose", self.name, true)
    if #to > 0 then
      self.cost_data = to[1]
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(self.cost_data)
    room:addPlayerMark(to, "@@fk_heg__wumei_extra", 1)
    local hp_record = {}
    for _, p in ipairs(room.alive_players) do
      table.insert(hp_record, {p.id, p.hp})
    end
    room:setPlayerMark(to, "fk_heg__wumei_record", hp_record)
    to:gainAnExtraTurn()
  end,

  refresh_events = {fk.AfterTurnEnd},
  can_refresh = function(self, event, target, player, data)
    return target == player and player:getMark("@@fk_heg__wumei_extra") > 0
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "@@fk_heg__wumei_extra", 0)
    room:setPlayerMark(player, "fk_heg__wumei_record", 0)
  end,
}
local fk_heg__wumei_delay = fk.CreateTriggerSkill{
  name = "#fk_heg__wumei_delay",
  events = {fk.EventPhaseStart},
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return player == target and player.phase == Player.Finish and player:getMark("@@fk_heg__wumei_extra") > 0
  end,
  on_cost = function() return true end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:notifySkillInvoked(player, fk_heg__wumei.name, "special")
    local hp_record = player:getMark("fk_heg__wumei_record")
    if type(hp_record) ~= "table" then return false end
    for _, p in ipairs(room:getAlivePlayers()) do
      local p_record = table.find(hp_record, function (sub_record)
        return #sub_record == 2 and sub_record[1] == p.id
      end)
      if p_record then
        p.hp = math.min(p.maxHp, p_record[2])
        room:broadcastProperty(p, "hp")
      end
    end
  end,
}
local zhanmeng = fk.CreateTriggerSkill{
  name = "fk_heg__zhanmeng",
  events = {fk.CardUsing},
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self.name) and player.room.current == player then
      for i = 1, 3, 1 do
        if player:getMark(self.name .. tostring(i).."-turn") == 0 then
          return true
        end
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local choices = {}
    self.cost_data = {}
    if player:getMark("fk_heg__zhanmeng1-turn") == 0 and not table.contains(room:getTag("fk_heg__zhanmeng1") or {}, data.card.trueName) then
      table.insert(choices, "fk_heg__zhanmeng1")
    end
    if player:getMark("fk_heg__zhanmeng2-turn") == 0 then
      table.insert(choices, "fk_heg__zhanmeng2")
    end
    local targets = {}
    if player:getMark("fk_heg__zhanmeng3-turn") == 0 then
      for _, p in ipairs(room:getOtherPlayers(player)) do
        if not p:isNude() then
          table.insertIfNeed(choices, "fk_heg__zhanmeng3")
          table.insert(targets, p.id)
        end
      end
    end
    table.insert(choices, "Cancel")
    local choice = room:askForChoice(player, choices, self.name)
    if choice == "Cancel" then return end
    self.cost_data[1] = choice
    if choice == "fk_heg__zhanmeng3" then
      local to = room:askForChoosePlayers(player, targets, 1, 1, "#fk_heg__zhanmeng-choose", self.name, false)
      if #to > 0 then
        self.cost_data[2] = to[1]
      else
        self.cost_data[2] = table.random(targets)
      end
    end
    return true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local choice = self.cost_data[1]
    room:setPlayerMark(player, choice.."-turn", 1)
    if choice == "fk_heg__zhanmeng1" then
      local cards = {}
      for i = 1, #room.draw_pile, 1 do
        local card = Fk:getCardById(room.draw_pile[i])
        if not card.is_damage_card then
          table.insertIfNeed(cards, room.draw_pile[i])
        end
      end
      if #cards > 0 then
        local card = table.random(cards)
        room:moveCards({
          ids = {card},
          to = player.id,
          toArea = Card.PlayerHand,
          moveReason = fk.ReasonJustMove,
          proposer = player.id,
          skillName = self.name,
        })
      end
    elseif choice == "fk_heg__zhanmeng2" then
      room:setPlayerMark(player, "fk_heg__zhanmeng2_invoke", data.card.trueName)
    elseif choice == "fk_heg__zhanmeng3" then
      local p = room:getPlayerById(self.cost_data[2])
      local n = math.min(1, #p:getCardIds{Player.Hand, Player.Equip})
      local cards = room:askForDiscard(p, n, 1, true, self.name, false, ".", "#fk_heg__zhanmeng-discard:"..player.id.."::"..tostring(n))
    end
  end,
}
local zhanmeng_record = fk.CreateTriggerSkill{
  name = "#fk_heg__zhanmeng_record",

  refresh_events = {fk.CardUsing, fk.EventPhaseStart},
  can_refresh = function(self, event, target, player, data)
    if target == player then
      if event == fk.CardUsing then
        return true
      else
        return player.phase == Player.Start
      end
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    if event == fk.CardUsing then
      local fk_heg__zhanmeng2 = room:getTag("fk_heg__zhanmeng2") or {}
      if not table.contains(fk_heg__zhanmeng2, data.card.trueName) then
        table.insert(fk_heg__zhanmeng2, data.card.trueName)
        room:setTag("fk_heg__zhanmeng2", fk_heg__zhanmeng2)
      end
      for _, p in ipairs(room:getAlivePlayers()) do
        if p:getMark("fk_heg__zhanmeng2_get-turn") == data.card.trueName then
          room:setPlayerMark(p, "fk_heg__zhanmeng2_get-turn", 0)
          local cards = {}
          for i = 1, #room.draw_pile, 1 do
            local card = Fk:getCardById(room.draw_pile[i])
            if card.is_damage_card then
              table.insertIfNeed(cards, room.draw_pile[i])
            end
          end
          if #cards > 0 then
            local card = table.random(cards)
            room:moveCards({
              ids = {card},
              to = p.id,
              toArea = Card.PlayerHand,
              moveReason = fk.ReasonJustMove,
              proposer = p.id,
              skillName = "fk_heg__zhanmeng",
            })
          end
        end
      end
    else
      local fk_heg__zhanmeng2 = room:getTag("fk_heg__zhanmeng2") or {}
      room:setTag("fk_heg__zhanmeng1", fk_heg__zhanmeng2)  --上回合使用的牌
      fk_heg__zhanmeng2 = {}
      room:setTag("fk_heg__zhanmeng2", fk_heg__zhanmeng2)  --当前回合使用的牌
      for _, p in ipairs(room:getAlivePlayers()) do
        if type(p:getMark("fk_heg__zhanmeng2_invoke")) == "string" then
          room:setPlayerMark(p, "fk_heg__zhanmeng2_get-turn", p:getMark("fk_heg__zhanmeng2_invoke"))
          room:setPlayerMark(p, "fk_heg__zhanmeng2_invoke", 0)
        end
      end
    end
  end,
}
wumei:addRelatedSkill(wumei_delay)
zhanmeng:addRelatedSkill(zhanmeng_record)
zhouxuan:addSkill(wumei)
zhouxuan:addSkill(zhanmeng)
Fk:loadTranslationTable{
  ["fk_heg__zhouxuan"] = "周宣",
  ["fk_heg__wumei"] = "寤寐",
  ["#fk_heg__wumei_delay"] = "寤寐",
  [":fk_heg__wumei"] = "限定技，回合开始前，若你的体力值不大于游戏轮数，你可以令一名角色执行一个额外的回合：该回合结束时，将所有存活角色的体力值调整为此额外回合开始时的数值。",
  ["fk_heg__zhanmeng"] = "占梦",
  [":fk_heg__zhanmeng"] = "你的回合内，你使用牌时，可以执行以下一项（每回合每项各限一次）：<br>"..
  "1.上一回合内，若没有同名牌被使用，你获得一张非伤害牌。<br>"..
  "2.下一回合内，当同名牌首次被使用后，你获得一张伤害牌。<br>"..
  "3.令一名其他角色弃置一张牌。",
  ["#fk_heg__wumei-choose"] = "寤寐: 你可以令一名角色执行一个额外的回合",
  ["@@fk_heg__wumei_extra"] = "寤寐",
  ["fk_heg__zhanmeng1"] = "你获得一张非伤害牌",
  ["fk_heg__zhanmeng2"] = "下一回合内，当同名牌首次被使用后，你获得一张伤害牌",
  ["fk_heg__zhanmeng3"] = "令一名其他角色弃置一张牌",
  ["#fk_heg__zhanmeng-choose"] = "占梦: 令一名其他角色弃置一张牌",
  ["#fk_heg__zhanmeng-discard"] = "占梦：弃置%arg张牌",

  ["$fk_heg__wumei1"] = "大梦若期，皆付一枕黄粱。",
  ["$fk_heg__wumei2"] = "日所思之，故夜所梦之。",
  ["$fk_heg__zhanmeng1"] = "梦境缥缈，然有迹可占。",
  ["$fk_heg__zhanmeng2"] = "万物有兆，唯梦可卜。",
  ["~fk_heg__zhouxuan"] = "人生如梦，假时亦真。",
}

return extension