local H = require "packages/hegemony/util"
local extension = Package:new("lunar_heg")
extension.extensionName = "hegemony"
extension.game_modes_whitelist = { 'nos_heg_mode', 'new_heg_mode' }

Fk:loadTranslationTable{
  ["lunar_heg"] = "国战-新月杀专属",
  ["fk_heg"] = "新月",
}

local guohuai = General(extension, "fk_heg__guohuai", "wei", 4)
guohuai:addSkill("jingce")
guohuai:addCompanions { "hs__zhanghe", "hs__xiahouyuan" }
Fk:loadTranslationTable{
  ["fk_heg__guohuai"] = "郭淮",
  ["fk_heg__jingce"] = "精策",
  ["#fk_heg__guohuai"] = "垂问秦雍",
  ["illustrator:fk_heg__guohuai"] = "张帅", -- 御蜀屏障

  [":fk_heg__jingce"] = "出牌阶段结束时，若你本回合已使用的牌数大于或等于你的体力值，你可以摸两张牌。",
}

local caozhang = General(extension, "fk_heg__caozhang", "wei", 4)
caozhang:addSkill("jiangchi")
Fk:loadTranslationTable{
  ["fk_heg__caozhang"] = "曹彰",
}

--[[
local caoang = General(extension, "fk_heg__caoang", "wei", 4)
caoang:addSkill("kangkai")
caoang:addCompanions("hs__dianwei")
Fk:loadTranslationTable{
  ["fk_heg__caoang"] = "曹昂",
  ["~fk_heg__caoang"] = "典将军，还是你赢了……",
}
--]]

local wangyi = General(extension, "fk_heg__wangyi", "wei", 3, 3, General.Female)
wangyi:addSkill("zhenlie")
wangyi:addSkill("miji")
Fk:loadTranslationTable{
  ["fk_heg__wangyi"] = "王异",
}

local zhouxuan = General(extension, "fk_heg__zhouxuan", "wei", 3)
local wumei = fk.CreateTriggerSkill{
  name = "fk_heg__wumei",
  anim_type = "support",
  events = {fk.BeforeTurnStart},
  frequency = Skill.Limited,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) 
     and player:usedSkillTimes(self.name, Player.HistoryGame) == 0
     and player.hp <= player.room:getTag("RoundCount")
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local to = room:askForChoosePlayers(player, table.map(table.filter(room.alive_players, function (p)
      return p:getMark("@@fk_heg__wumei_extra") == 0 end), Util.IdMapper), 1, 1, "#fk_heg__wumei-choose", self.name, true)
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
local wumei_delay = fk.CreateTriggerSkill{
  name = "#fk_heg__wumei_delay",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return player == target and player.phase == Player.Finish and player:getMark("@@fk_heg__wumei_extra") > 0
  end,
  on_cost = function() return true end,
  on_use = function(self, event, target, player, data)
    local room = player.room
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
    if target == player and player:hasSkill(self) and player.room.current == player then
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
  ["#fk_heg__zhouxuan"] = "夜华青乌",
  ["designer:fk_heg__zhouxuan"] = "世外高v狼",
  ["illustrator:fk_heg__zhouxuan"] = "匠人绘",

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


local yanrou = General(extension, "fk_heg__yanrou", "wei", 4)
local choutao = fk.CreateTriggerSkill{
  name = "fk_heg__choutao",
  anim_type = "offensive",
  events ={fk.TargetSpecified, fk.TargetConfirmed},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.card.trueName == "slash" and data.firstTarget and
      not player.room:getPlayerById(data.from):isNude()
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, nil, "#fk_heg__choutao-invoke::"..data.from)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local from = room:getPlayerById(data.from)
    local id = room:askForCardChosen(player, from, "he", self.name)
    room:throwCard({id}, self.name, from, player)
    data.disresponsive = true
  end,
}

yanrou:addSkill(choutao)
Fk:loadTranslationTable{
  ["fk_heg__yanrou"] = "阎柔",
  ["designer:fk_heg__yanrou"] = "notify",
  ["#fk_heg__yanrou"] = "冠玉啸北",
  ["illustrator:fk_heg__yanrou"] = "凝聚永恒",

  ["fk_heg__choutao"] = "仇讨",
  [":fk_heg__choutao"] = "当你使用【杀】指定目标后或成为【杀】的目标后，你可以弃置使用者一张牌，令此【杀】不能被响应。",
  ["#fk_heg__choutao-invoke"] = "仇讨：你可以弃置 %dest 一张牌令此【杀】不能被响应",

  ["$fk_heg__choutao1"] = "大恨深仇，此剑讨之！",
  ["$fk_heg__choutao2"] = "是非恩怨，此役决之！",
  ["~fk_heg__yanrou"] = "寒风折戍矛，铁衣裹枯骨……",
}

local maliang = General(extension, "fk_heg__maliang", "shu", 3)
maliang:addCompanions("ld__masu")
maliang:addSkill("xiemu")
maliang:addSkill("naman")
Fk:loadTranslationTable{
  ["fk_heg__maliang"] = "马良",
  ["~fk_heg__maliang"] = "皇叔为何不听我之言？",
}

local yijik = General(extension, "fk_heg__yijik", "shu", 3)
yijik:addSkill("jijie")
local jiyuan = fk.CreateTriggerSkill{
  name = "fk_heg__jiyuan",
  anim_type = "support",
  events = {fk.EnterDying},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self)
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

local liuchen = General(extension, "fk_heg__liuchen", "shu", 4)
liuchen:addSkill("zhanjue")
Fk:loadTranslationTable{
  ["fk_heg__liuchen"] = "刘谌",
}

local liuyong = General(extension, "fk_heg__liuyong", "shu", 3)

local danxin = fk.CreateActiveSkill{
  name = "fk_heg__danxin",
  anim_type = "control",
  card_num = 2,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = function(self, to_select, selected)
    return Fk:currentRoom():getCardArea(to_select) == Player.Hand or Fk:currentRoom():getCardArea(to_select) == Player.Equip
  end,
  target_filter = function(self, to_select, selected)
    return #selected == 0 and to_select ~= Self.id
  end,
  on_use = function (self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    local cards = effect.cards
    room:moveCardTo(cards, Card.PlayerHand, target, fk.ReasonGive, self.name, nil, false, player.id)
    if player.dead or target:isNude() or target.dead then return end
    local cards2
    if #target:getCardIds("he") <= 2 then
      cards2 = target:getCardIds("he")
    else
      cards2 = room:askForCard(target, 2, 2, true, self.name, false, ".", "#fk_heg__danxin-give")
      if #cards2 < 2 then
        cards2 = table.random(player:getCardIds("he"), 2)
      end
    end
    room:moveCardTo(cards2, Card.PlayerHand, player, fk.ReasonGive, self.name, nil, false, player.id)
    if #cards2 > 0 then
      local card1 = Fk:getCardById(cards2[1])
      if #cards2 > 1 then
        local card2 = Fk:getCardById(cards2[2])
        if card1.suit == Card.Heart or card2.suit == Card.Heart then
          room:addPlayerMark(player, MarkEnum.SlashResidue.."-turn")
        end
      else
        if card1.suit == Card.Heart then
          room:addPlayerMark(player, MarkEnum.SlashResidue.."-turn")
        end
      end
    end
  end,
}

local fengxiang = fk.CreateTriggerSkill{
  name = "fk_heg__fengxiang",
  events = {fk.Damaged},
  frequency = Skill.Compulsory,
  anim_type = "masochism",
  can_trigger = function(self, event, target, player, data)
    return player == target and player:hasSkill(self)
      and table.find(player.room.alive_players, function(p) return player:inMyAttackRange(p) and (#player:getCardIds(Player.Equip) > 0 or #p:getCardIds(Player.Equip) > 0) end)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local hasEquip = #player:getCardIds(Player.Equip) > 0
    local tos = player.room:askForChoosePlayers(player, table.map(table.filter(room.alive_players, function (p)
      return player:inMyAttackRange(p) and (hasEquip or #p:getCardIds(Player.Equip) > 0)
    end), Util.IdMapper), 1, 1, "#fk_heg__fengxiang-choose", self.name, false)
    local to = room:getPlayerById(tos[1])
    local num = 0
    local cards1 = player:getCardIds("e")
    local cards2 = to:getCardIds("e")
    local moveInfos = {}
    if #cards1 > 0 then
      table.insert(moveInfos, {
        from = player.id,
        ids = cards1,
        toArea = Card.Processing,
        moveReason = fk.ReasonExchange,
        proposer = player.id,
        skillName = self.name,
      })
    end
    if #cards2 > 0 then
      table.insert(moveInfos, {
        from = to.id,
        ids = cards2,
        toArea = Card.Processing,
        moveReason = fk.ReasonExchange,
        proposer = player.id,
        skillName = self.name,
      })
    end
    if #moveInfos > 0 then
      room:moveCards(table.unpack(moveInfos))
    end

    moveInfos = {}

    if not to.dead then
      local to_ex_cards1 = table.filter(cards1, function (id)
        return room:getCardArea(id) == Card.Processing and to:getEquipment(Fk:getCardById(id).sub_type) == nil
      end)
      if #to_ex_cards1 > 0 then
        table.insert(moveInfos, {
          ids = to_ex_cards1,
          fromArea = Card.Processing,
          to = to.id,
          toArea = Card.PlayerEquip,
          moveReason = fk.ReasonExchange,
          proposer = player.id,
          skillName = self.name,
        })
      end
    end
    if not player.dead then
      local to_ex_cards = table.filter(cards2, function (id)
        return room:getCardArea(id) == Card.Processing and player:getEquipment(Fk:getCardById(id).sub_type) == nil
      end)
      num = #cards1 - #to_ex_cards
      if #to_ex_cards > 0 then
        table.insert(moveInfos, {
          ids = to_ex_cards,
          fromArea = Card.Processing,
          to = player.id,
          toArea = Card.PlayerEquip,
          moveReason = fk.ReasonExchange,
          proposer = player.id,
          skillName = self.name,
        })
      end
    end
    if #moveInfos > 0 then
      room:moveCards(table.unpack(moveInfos))
    end

    if num > 0 and not player.dead and player:isWounded() then
      room:recover{
        who = player,
        num = 1,
        skillName = self.name,
      }
    end
  end,
}
liuyong:addSkill(danxin)
liuyong:addSkill(fengxiang)

Fk:loadTranslationTable{
  ["fk_heg__liuyong"] = "刘永",
  ["#fk_heg__liuyong"] = "甘陵王",
	["illustrator:fk_heg__liuyong"] = "君桓文化",
  ["designer:fk_heg__liuyong"] = "陈桓",

  ["fk_heg__danxin"] = "丹心",
  [":fk_heg__danxin"] = "出牌阶段限一次，你可交给一名其他角色两张牌，然后其交给你两张牌，若你以此法获得红桃牌，你本回合使用【杀】次数上限+1。",
  ["fk_heg__fengxiang"] = "封乡",
  [":fk_heg__fengxiang"] = "锁定技，当你受到伤害后，你与你攻击范围内的一名角色交换装备区内所有牌，若你装备区内牌数因此减少，你回复1点体力。",

  ["@fk_heg__danxin_buff-turn"] = "丹心",
  ["#fk_heg__danxin-give"] = "丹心：请交给刘永两张牌",
  ["#fk_heg__fengxiang-choose"] = "封乡：选择攻击范围内的一名角色，与其交换装备区内所有牌",

  ["$fk_heg__danxin1"] = "此剑半丈，当斩奸佞人头！",
  ["$fk_heg__danxin2"] = "此身八尺，甘为柱国之石。",
  ["$fk_heg__fengxiang1"] = "北风摧蜀地，王爵换乡侯。",
  ["$fk_heg__fengxiang2"] = "汉皇可负我，我不负父兄。",
  ["~fk_heg__liuyong"] = "他日若是凛风起，你自长哭我自笑。",
}

-- local jianyong = General(extension, "fk_heg__jianyong", "shu", 3)
-- jianyong:addSkill("qiaoshui")
-- jianyong:addSkill("zongshij")
-- Fk:loadTranslationTable{
--   ["fk_heg__jianyong"] = "简雍",
-- }

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

local jurui = fk.CreateTriggerSkill{
  name = "fk_heg__jurui",
  events = {fk.Damage},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and target == player and data.to and not player:isKongcheng() and not data.to.dead and player:usedSkillTimes(self.name, Player.HistoryTurn) < 1
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:doIndicate(player.id, {data.to.id})
    local cardid = room:askForCardChosen(data.to, player, "h", self.name)
    if Fk:getCardById(cardid).trueName ~= "slash" then
      room:throwCard({cardid}, self.name, player, data.to)
      local choices = {}
      if player:isWounded() then
        table.insert(choices, "fk_heg_jurui_recover")
      end
      if player:getHandcardNum() < player.maxHp then
        table.insert(choices, "fk_heg_jurui_draw")
      end
      if #choices == 0 then return end
      local choice = room:askForChoice(player, choices, self.name)
      if choice == "fk_heg_jurui_recover" then
        room:recover{
          who = player,
          num = 1,
          skillName = self.name,
        }
      else
        player:drawCards(player.maxHp - player:getHandcardNum(), self.name)
      end
    else
      room:throwCard({cardid}, self.name, player, data.to)
    end
  end,
}
zhuhuan:addSkill(jurui)

Fk:loadTranslationTable{
  ['fk_heg__zhuhuan'] = '朱桓',
  ['designer:fk_heg__zhuzhi'] = '教父',

  ['fk_heg__jurui'] = '拒锐',
  [':fk_heg__jurui'] = '每回合限一次，当你造成伤害后，你可令受伤角色弃置你一张手牌，若此牌不为【杀】，你可回复1点体力或将手牌摸至体力上限。',

  ["fk_heg_jurui_recover"] = "回复1点体力",
  ["fk_heg_jurui_draw"] = "将手牌摸至体力上限",
}

local guyong = General(extension, "fk_heg__guyong", "wu", 3)
local bingyi = fk.CreateTriggerSkill{
  name = "fk_heg__bingyi",
  anim_type = "defensive",
  events = {fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) and player:usedSkillTimes(self.name, Player.HistoryTurn) < 1 and not player:isKongcheng() then
      for _, move in ipairs(data) do
        if move.from == player.id and move.moveReason == fk.ReasonDiscard then
          for _, info in ipairs(move.moveInfo) do
            if info.fromArea == Card.PlayerHand then
              return true
            end
          end
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = player.player_cards[Player.Hand]
    player:showCards(cards)
    if #cards > 1 then
      for _, id in ipairs(cards) do
        if Fk:getCardById(id).color == Card.NoColor or Fk:getCardById(id).color ~= Fk:getCardById(cards[1]).color then
          return false
        end
      end
    end
    local tos = room:askForChoosePlayers(player, table.map(room:getOtherPlayers(player, false), Util.IdMapper), 1, #cards, "#fk_heg__bingyi-choose:::"..#cards, self.name, true)
    table.insert(tos, player.id)
    room:sortPlayersByAction(tos)
    for _, pid in ipairs(tos) do
      local p = room:getPlayerById(pid)
      if not p.dead and p ~= player then
        room:drawCards(p, 1, self.name)
      end
    end
  end,
}

local shenxing = fk.CreateActiveSkill{
  name = "fk_heg__shenxing",
  anim_type = "drawcard",
  card_num = 2,
  target_num = 0,
  can_use = function(self, player)
    return not player:isNude() and player:usedSkillTimes(self.name, Player.HistoryPhase) < 4
  end,
  card_filter = function(self, to_select, selected)
    return #selected < 2 and not Self:prohibitDiscard(to_select)
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    room:throwCard(effect.cards, self.name, player, player)
    player:drawCards(1, self.name)
  end
}

guyong:addSkill(shenxing)
guyong:addSkill(bingyi)
Fk:loadTranslationTable{
  ["fk_heg__guyong"] = "顾雍",
  ["#fk_heg__guyong"] = "庙堂的玉磐",
  ["designer:fk_heg__guyong"] = "玄蝶",

  ["fk_heg__bingyi"] = "秉壹",
  [":fk_heg__bingyi"] = "每回合限一次，当你的手牌被弃置后，你可以展示所有手牌，若颜色均相同，你令至多X名其他角色各摸一张牌（X为你的手牌数）。",
  ["#fk_heg__bingyi-choose"] = "秉壹：你可以令至多%arg名其他角色各摸一张牌",
  ["fk_heg__shenxing"] = "慎行",
  [":fk_heg__shenxing"] = "出牌阶段限四次，你可以弃置两张牌，然后摸一张牌。",

  ["$fk_heg__guyong1"] = "上兵伐谋，三思而行。",
  ["$fk_heg__guyong2"] = "精益求精，慎之再慎。",
  ["$fk_heg__bingyi1"] = "秉直进谏，勿藏私心！",
  ["$fk_heg__bingyi2"] = "秉公守一，不负圣恩！",
  ["~fk_heg__guyong"] = "此番患疾，吾必不起……",
}

--[====[

local zhangxuan = General(extension, "fk_heg__zhangxuan", "wu", 3, 3, General.Female)
local tongli = fk.CreateTriggerSkill{
  name = "fk_heg__tongli",
  anim_type = "offensive",
  events = {fk.TargetSpecified},
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self) and player.phase == Player.Play and data.firstTarget and player:usedSkillTimes(self.name, Player.HistoryPhase) < 1 and
      (not data.card:isVirtual() or #data.card.subcards > 0) and not table.contains(data.card.skillNames, self.name) and
      data.card.type ~= Card.TypeEquip and data.card.sub_type ~= Card.SubtypeDelayedTrick and
      not (table.contains({"peach", "analeptic"}, data.card.trueName) and table.find(player.room.alive_players, function(p) return p.dying end)) then
      local suits = {}
      for _, id in ipairs(player.player_cards[Player.Hand]) do
        if Fk:getCardById(id).suit ~= Card.NoSuit then
          table.insertIfNeed(suits, Fk:getCardById(id).suit)
        end
      end
      return #suits == player:getMark("@tongli-turn")
    end
  end,
  on_use = function(self, event, target, player, data)
    data.extra_data = data.extra_data or {}
    -- data.extra_data.tongli = player:getMark("@tongli-turn")
    data.extra_data.tongli = 1
    player.room:setPlayerMark(player, "tongli_tos", AimGroup:getAllTargets(data.tos))
  end,

  refresh_events = {fk.AfterCardUseDeclared, fk.CardUseFinished},
  can_refresh = function(self, event, target, player, data)
    if target == player and player:hasSkill(self) then
      if event == fk.AfterCardUseDeclared then
        return player.phase == Player.Play and not table.contains(data.card.skillNames, self.name)
      else
        return data.extra_data and data.extra_data.tongli and player:getMark("tongli_tos") ~= 0
      end
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    if event == fk.AfterCardUseDeclared then
      room:addPlayerMark(player, "@tongli-turn", 1)
    else
      local n = data.extra_data.tongli
      local targets = player:getMark("tongli_tos")
      room:setPlayerMark(player, "tongli_tos", 0)
      local tos = table.simpleClone(targets)
      for i = 1, n, 1 do
        if player.dead then return end
        for _, id in ipairs(targets) do
          if room:getPlayerById(id).dead then
            return
          end
        end
        if table.contains({"savage_assault", "archery_attack"}, data.card.name) then  --to modify tenyear's stupid processing
          for _, p in ipairs(room:getOtherPlayers(player)) do
            if not player:isProhibited(p, Fk:cloneCard(data.card.name)) then
              table.insertIfNeed(tos, p.id)
            end
          end
        elseif table.contains({"amazing_grace", "god_salvation"}, data.card.name) then
          for _, p in ipairs(room:getAlivePlayers()) do
            if not player:isProhibited(p, Fk:cloneCard(data.card.name)) then
              table.insertIfNeed(tos, p.id)
            end
          end
        end
        room:sortPlayersByAction(tos)
        room:useVirtualCard(data.card.name, nil, player, table.map(tos, function(id) return room:getPlayerById(id) end), self.name, true)
      end
    end
  end,
}
local shezang = fk.CreateTriggerSkill{
  name = "fk_heg__shezang",
  anim_type = "drawcard",
  events = {fk.EnterDying},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and target == player
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    H.removeGeneral(room, player, player.deputyGeneral == "fk_heg__zhangxuan")
    local suits = {"spade", "club", "heart", "diamond"}
    local cards = {}
    while #suits > 0 do
      local pattern = table.random(suits)
      table.removeOne(suits, pattern)
      table.insertTable(cards, room:getCardsFromPileByRule(".|.|"..pattern))
    end
    if #cards > 0 then
      room:moveCards({
        ids = cards,
        to = player.id,
        toArea = Card.PlayerHand,
        moveReason = fk.ReasonJustMove,
        proposer = player.id,
        skillName = self.name,
      })
    end
  end,
}
zhangxuan:addSkill(tongli)
zhangxuan:addSkill(shezang)
Fk:loadTranslationTable{
  ["fk_heg__zhangxuan"] = "张嫙",
  ["fk_heg__tongli"] = "同礼",
  [":fk_heg__tongli"] = "出牌阶段限一次，当你使用牌指定目标后，若你手牌中的花色数等于你此阶段已使用牌的张数，你可令此牌效果额外执行一次。",
  ["fk_heg__shezang"] = "奢葬",
  [":fk_heg__shezang"] = "当你进入濒死状态时，你可以移除此武将牌，然后从牌堆获得不同花色的牌各一张。",
  ["@tongli-turn"] = "同礼",

  ["$fk_heg__tongli1"] = "胞妹殊礼，妾幸同之。",
  ["$fk_heg__tongli2"] = "夫妻之礼，举案齐眉。",
  ["$fk_heg__shezang1"] = "世间千百物，物物皆相思。",
  ["$fk_heg__shezang2"] = "伊人将逝，何物为葬？",
  ["~fk_heg__zhangxuan"] = "陛下，臣妾绝无异心！",
}

local hjls = General(extension, "fk_heg__huangjinleishi", "qun", 3, 3, General.Female)
hjls:addSkill("fulu")
hjls:addSkill("zhuji")
hjls:addCompanions("hs__zhangjiao")
Fk:loadTranslationTable{
  ["fk_heg__huangjinleishi"] = "黄巾雷使",
  ["~fk_heg__huangjinleishi"] = "速报大贤良师……大事已泄……",
}
--]====]

local chengui = General(extension, "fk_heg__chengui", "qun", 3)
local yingtu = fk.CreateTriggerSkill{
  name = "fk_heg__yingtu",
  anim_type = "control",
  events = {fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) and player:usedSkillTimes(self.name, Player.HistoryRound) == 0 then
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
    local card = room:askForCardChosen(player, from, "he", self.name)
    room:obtainCard(player.id, card, false, fk.ReasonPrey)
    local to = player:getNextAlive() == from and player:getLastAlive() or player:getNextAlive()
    if not to or to == player then return false end
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
    return not target.dead and H.isBigKingdomPlayer(target) and player:hasSkill(self) and data.card.type == Card.TypeEquip and table.every(player.room.alive_players, function(p)
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
  ["#fk_heg__chengui"] = "弄虎如婴",
  ["illustrator:fk_heg__chengui"] = "游漫美绘",
  ["designer:fk_heg__chengui"] = "狗设计的",

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

--[==[
local wanglie = General(extension, "fk_heg__wanglie", "qun", 3)
local chongwang = fk.CreateTriggerSkill{
  name = "fk_heg__chongwang",
  anim_type = "control",
  events = {fk.CardUsing},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) and target ~= player and (data.card.type == Card.TypeBasic or data.card:isCommonTrick()) then
      local mark = player:getMark(self.name)
      if mark ~= 0 and #mark > 1 then
        return mark[2] == player.id
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local choices = {"Cancel", "fk_heg__chongwang-invalid"}
    local choice = player.room:askForChoice(player, choices, self.name, "#fk_heg__chongwang-invoke")
    if choice ~= "Cancel" then
      self.cost_data = choice
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    if self.cost_data == "fk_heg__chongwang-invalid" then
      if data.toCard ~= nil then
        data.toCard = nil
      else
        data.nullifiedTargets = TargetGroup:getRealTargets(data.tos)
      end
    end
  end,

  refresh_events = {fk.CardUsing, fk.EventAcquireSkill},
  can_refresh = function(self, event, target, player, data)
    if event == fk.CardUsing then
      return player:hasSkill(self.name, true)
    else
      return data == self
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    if event == fk.CardUsing then
      if target == player and player:hasSkill(self) then
        room:setPlayerMark(player, "@@fk_heg__chongwang", 1)
      else
        room:setPlayerMark(player, "@@fk_heg__chongwang", 0)
      end
      local mark = player:getMark(self.name)
      if mark == 0 then mark = {} end
      if #mark == 2 then
        mark[2] = mark[1]  --mark2上一张牌使用者，mark1这张牌使用者
        mark[1] = data.from
      else
        table.insert(mark, 1, data.from)
      end
      room:setPlayerMark(player, self.name, mark)
    else
      --[[local events = room.logic:getEventsOfScope(GameEvent.UseCard, 999, function(e)
        local use = e.data[1]
        return use.from == player.id
      end, Player.HistoryPhase)
      room:addPlayerMark(player, "zuojian-phase", #events)
      room:addPlayerMark(player, "@zuojian-phase", #events)]]  --TODO: 需要一个反向查找记录
    end
  end,
}
local huagui = fk.CreateActiveSkill{
  name = "fk_heg__huagui",
  anim_type = "control",
  card_num = 0,
  min_target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
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
    room:sortPlayersByAction(targets)
    for _, id in ipairs(targets) do
      local target = room:getPlayerById(id)
      if not target.dead then
        local card1 = room:askForCard(target, 1, 1, true, self.name, false, ".", "#fk_heg__huagui-give:"..player.id)
        local dummy1 = Fk:cloneCard("dilu")
        dummy1:addSubcards(card1)
        room:obtainCard(player, dummy1, false, fk.ReasonGive)
      end
    end
    for _, id in ipairs(targets) do
      local target = room:getPlayerById(id)
      if not player.dead then
        local card2 = room:askForCard(player, 1, 1, true, self.name, false, ".", "#fk_heg__huagui-give:"..target.id)
        local dummy2 = Fk:cloneCard("dilu")
        dummy2:addSubcards(card2)
        room:obtainCard(target, dummy2, false, fk.ReasonGive)
      end
    end
  end,
}

wanglie:addSkill(chongwang)
wanglie:addSkill(huagui)
Fk:loadTranslationTable{
  ["fk_heg__wanglie"] = "王烈",
  ["fk_heg__chongwang"] = "崇望",
  [":fk_heg__chongwang"] = "其他角色使用一张基本牌或普通锦囊牌时，若你为上一张牌的使用者，你可以令此牌无效。",
  ["fk_heg__huagui"] = "化归",
  [":fk_heg__huagui"] = "出牌阶段限一次，你可令至多三名势力各不相同或未确定势力的的角色依次交给你一张牌，然后你交给这些角色各一张牌。",

  ["@@fk_heg__chongwang"] = "崇望",
  ["#fk_heg__chongwang-invoke"] = "崇望：你可以令此牌无效",
  ["fk_heg__chongwang-invalid"] = "此牌无效",
  
  ["#fk_heg__huagui-give"] = "化归：将一张牌交给 %src",

  ["$fk_heg__chongwang1"] = "乡人所崇者，烈之义行也。",
  ["$fk_heg__chongwang2"] = "诸家争讼曲直，可质于我。",
  ["$fk_heg__huagui1"] = "烈不才，难为君之朱紫。",
  ["$fk_heg__huagui2"] = "一身风雨，难坐高堂。",
  ["~fk_heg__wanglie"] = "烈尚不能自断，何断人乎？",
}
--]==]

local liru = General(extension, "fk_heg__liru", "qun", 3)
local fencheng = fk.CreateActiveSkill{
  name = "fk_heg__fencheng",
  anim_type = "offensive",
  card_num = 0,
  target_num = 0,
  frequency = Skill.Limited,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local targets = room:getOtherPlayers(player)
    local n = 0
    for _, target in ipairs(targets) do
      local total = #target:getCardIds{Player.Hand, Player.Equip}
      if total < n + 1 then
        room:damage{
          from = player,
          to = target,
          damage = 1,
          damageType = fk.FireDamage,
          skillName = self.name,
        }
        n = 0
      else
        local cards = room:askForDiscard(target, n + 1, 999, true, self.name, true, ".", "#fk_heg__fencheng-discard:::"..tostring(n + 1))
        if #cards == 0 then
          room:damage{
            from = player,
            to = target,
            damage = 1,
            damageType = fk.FireDamage,
            skillName = self.name,
          }
          n = 0
        else
          n = #cards
        end
      end
    end
  end
}

liru:addSkill("juece")
liru:addSkill("mieji")
liru:addSkill(fencheng)
Fk:loadTranslationTable{
  ["fk_heg__liru"] = "李儒",
  ["fk_heg__juece"] = "绝策",
  [":fk_heg__juece"] = "结束阶段，你可以对一名没有手牌的其他角色造成1点伤害。",
  ["fk_heg__mieji"] = "灭计",
  [":fk_heg__mieji"] = "出牌阶段限一次，你可以将一张黑色锦囊牌置于牌堆顶并选择一名其他角色，然后令该角色选择一项：1.弃置一张锦囊牌；2.依次弃置两张非锦囊牌。",
  ["fk_heg__fencheng"] = "焚城",
  [":fk_heg__fencheng"] = "限定技，出牌阶段，你可以令所有其他角色依次选择一项：1.弃置至少X+1张牌（X为该角色的上家以此法弃置牌的数量）；"..
  "2.受到你造成的1点火焰伤害。",
  ["#fk_heg__fencheng-discard"] = "焚城：弃置至少%arg张牌，否则受到1点火焰伤害",

  ["$fk_heg__juece1"] = "哼！你走投无路了。",
  ["$fk_heg__juece2"] = "无用之人，死！",
  ["$fk_heg__mieji1"] = "宁错杀，无放过！",
  ["$fk_heg__mieji2"] = "你能逃得出我的手掌心吗？",
  ["$fk_heg__fencheng1"] = "我得不到的，你们也别想得到！",
  ["$fk_heg__fencheng2"] = "让这一切都灰飞烟灭吧！哼哼哼哼……",
  ["~fk_heg__liru"] = "如遇明主，大业必成……",
}

local quyi = General(extension, "fk_heg__quyi", "qun", 4)
local fuji = fk.CreateTriggerSkill{
  name = "fk_heg__fuji",
  anim_type = "offensive",
  events = {fk.TargetSpecified, fk.AfterDying},
  can_trigger = function (self, event, target, player, data)
    if target ~= player or not player:hasSkill(self) then return end
    if event == fk.TargetSpecified then
      return player:isFakeSkill(self)
    else
      return H.inGeneralSkills(player, self.name) and not player:isFakeSkill(self)
    end
  end,
  on_cost = function (self, event, target, player, data)
    if event == fk.TargetSpecified then
      return player.room:askForSkillInvoke(player, self.name, nil, "#fk_heg__fuji-invoke")
    else
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    if event == fk.TargetSpecified then
      data.disresponsiveList = data.disresponsiveList or {}
      for _, p in ipairs(room.alive_players) do
        table.insertIfNeed(data.disresponsiveList, p.id)
      end
    else
      H.hideBySkillName(player, self.name)
    end
  end,
}

local jiaozi = fk.CreateTriggerSkill{
  name = "fk_heg__jiaozi",
  anim_type = "offensive",
  frequency = Skill.Compulsory,
  events = {fk.DamageCaused, fk.DamageInflicted},
  can_trigger = function (self, event, target, player, data)
    local targets = table.filter(player.room:getOtherPlayers(player), function(p) return H.compareKingdomWith(player, p) end)
    return player:hasSkill(self) and player == target and #targets > 0 
      and table.every(targets, function(p) return player:getHandcardNum() > p:getHandcardNum() end)
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    data.damage = data.damage + 1
  end,
}

quyi:addSkill(fuji)
quyi:addSkill(jiaozi)
Fk:loadTranslationTable{
  ["fk_heg__quyi"] = "麴义",
  ["designer:fk_heg__quyi"] = "notify&风箫&教父",

  ["fk_heg__fuji"] = "伏骑",
  [":fk_heg__fuji"] = "当你使用牌指定目标后，若此武将牌处于暗置状态，你可以明置此武将牌，令此牌不能被响应；当你脱离濒死状态后，若此武将牌处于明置状态，暗置此武将牌。",
  ["fk_heg__jiaozi"] = "骄恣",
  [":fk_heg__jiaozi"] = "锁定技，当你受到或造成伤害时，若你为与你势力相同的角色中手牌数唯一最多的角色，且存在与你势力相同的其他角色，此伤害+1。",
  ["#fk_heg__fuji-invoke"] = "伏骑：你可以亮出麴义，令此牌不能被响应",

  ["$fk_heg__fuji1"] = "白马？不足挂齿！",
  ["$fk_heg__fuji2"] = "掌握之中，岂可逃之？",
  ["$fk_heg__jiaozi1"] = "数战之功，吾应得此赏！",
  ["$fk_heg__jiaozi2"] = "无我出力，怎会连胜？",
  ["~fk_heg__quyi"] = "主公，我无异心啊！",
}

local chengong = General(extension, "fk_heg__chengong", "qun", 3)
--[[
local mingce = fk.CreateActiveSkill{
  name = "fk_heg__mingce",
  anim_type = "support",
  card_num = 1,
  target_num = 1,
  prompt = "#fk_heg__mingce",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0 and not player:isKongcheng()
  end,
  card_filter = function(self, to_select, selected)
    return #selected == 0 and (Fk:getCardById(to_select).trueName == "slash" or Fk:getCardById(to_select).type == Card.TypeEquip)
  end,
  target_filter = function(self, to_select, selected)
    return #selected == 0 and to_select ~= Self.id
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    room:obtainCard(target.id, Fk:getCardById(effect.cards[1]), false, fk.ReasonGive)
    if player.dead or target.dead then return end
    if H.askCommandTo(player, target, self.name) then
      player:drawCards(1, self.name)
      local targets = table.map(table.filter(room:getOtherPlayers(target), function(p)
        return target:inMyAttackRange(p) end), Util.IdMapper)
      if #targets > 0 then
        local tos = room:askForChoosePlayers(player, targets, 1, 1, "#fk_heg__mingce-choose::"..target.id, self.name, false, true)
        local to
        if #tos > 0 then
          to = tos[1]
        else
          to = table.random(targets)
        end
        room:doIndicate(target.id, {to})
        room:useVirtualCard("slash", nil, target, room:getPlayerById(to), self.name, true)
      end
    end
  end,
}
--]]
chengong:addSkill("zhichi")
chengong:addSkill("mingce")
Fk:loadTranslationTable{
  ["fk_heg__chengong"] = "陈宫",
  -- ["fk_heg__mingce"] = "明策",
  -- [":fk_heg__mingce"] = "出牌阶段限一次，你可以交给一名其他角色一张装备牌或【杀】，令其执行一次“军令”，若其执行，你摸一张牌，然后令其视为对其攻击范围内一名你指定的角色使用一张【杀】。",

  -- ["#fk_heg__mingce"] = "明策：交给一名角色一张装备牌或【杀】，令其执行一次“军令”",
  -- ["#fk_heg__mingce-choose"] = "明策：选择 %dest 视为使用【杀】的目标",

  -- ["$fk_heg__mingce1"] = "如此，霸业可图也。",
  -- ["$fk_heg__mingce2"] = "如此，一击可擒也。",
  ["~fk_heg__chengong"] = "请出就戮！",
}
return extension
