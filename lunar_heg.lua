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

return extension
