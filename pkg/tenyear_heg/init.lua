local extension = Package:new("tenyear_heg")
extension.extensionName = "hegemony"
extension.game_modes_whitelist = { 'nos_heg_mode', 'new_heg_mode' }

extension:loadSkillSkelsByPath("./packages/hegemony/pkg/tenyear_heg/skills")

local H = require "packages/hegemony/util"
local U = require "packages/utility/utility"

Fk:loadTranslationTable{
  ["tenyear_heg"] = "国战-十周年专属",
  ["ty_heg"] = "新服",
}

General:new(extension, "ty_heg__huaxin", "wei", 3):addSkills{"ty_heg__wanggui", "ty_heg__xibing"}

Fk:loadTranslationTable{
  ["ty_heg__huaxin"] = "华歆",
  ["#ty_heg__huaxin"] = "渊清玉洁",
  ["designer:ty_heg__huaxin"] = "韩旭",
  ["illustrator:ty_heg__huaxin"] = "秋呆呆",
  ["~ty_heg__huaxin"] = "大举发兵，劳民伤国。",
}

General:new(extension, "ty_heg__yanghu", "wei", 3):addSkills{"ty_heg__deshao", "ty_heg__mingfa"}
Fk:loadTranslationTable{
  ["ty_heg__yanghu"] = "羊祜",
  ["#ty_heg__yanghu"] = "制纮同轨",
  ["designer:ty_heg__yanghu"] = "韩旭",
  ["illustrator:ty_heg__yanghu"] = "匠人绘",
  ["~ty_heg__yanghu"] = "臣死之后，杜元凯可继之……",
}

General:new(extension, "ty_heg__zongyu", "shu", 3):addSkills{"ty_heg__qiao", "ty_heg__chengshang"}

Fk:loadTranslationTable{
  ["ty_heg__zongyu"] = "宗预",
  ["#ty_heg__zongyu"] = "九酝鸿胪",
  ["designer:ty_heg__zongyu"] = "韩旭",
  ["illustrator:ty_heg__zongyu"] = "铁杵文化",
  ["~ty_heg__zongyu"] = "吾年逾七十，唯少一死耳……",
}

General:new(extension, "ty_heg__dengzhi", "shu", 3):addSkills{"ty_heg__jianliang", "ty_heg__weimeng"}
Fk:loadTranslationTable{
  ["ty_heg__dengzhi"] = "邓芝",
  ["#ty_heg__dengzhi"] = "绝境的外交家",
  ["designer:ty_heg__dengzhi"] = "韩旭",
  ["illustrator:ty_heg__dengzhi"] = "凝聚永恒",
  ["~ty_heg__dengzhi"] = "伯约啊，我帮不了你了……",
}

General:new(extension, "ty_heg__luyusheng", "wu", 3, 3, General.Female):addSkills{"ty_heg__zhente", "ty_heg__zhiwei"}

Fk:loadTranslationTable{
  ["ty_heg__luyusheng"] = "陆郁生",
  ["#ty_heg__luyusheng"] = "义姑",
  ["designer:ty_heg__luyusheng"] = "韩旭",
  ["illustrator:ty_heg__luyusheng"] = "君桓文化",
  ["~ty_heg__luyusheng"] = "父亲，郁生甚是想念……",
}

General:new(extension, "ty_heg__fengxiw", "wu", 3):addSkills{"ty_heg__yusui", "ty_heg__boyan"}
Fk:loadTranslationTable{
  ["ty_heg__fengxiw"] = "冯熙",
  ["#ty_heg__fengxiw"] = "东吴苏武",
  ["designer:ty_heg__fengxiw"] = "韩旭",
  ["illustrator:ty_heg__fengxiw"] = "匠人绘",
  ["~ty_heg__fengxiw"] = "乡音未改双鬓苍，身陷北国有义求。",
}

local miheng = General:new(extension, "ty_heg__miheng", "qun", 3)
miheng:addCompanions("hs__kongrong")
miheng:addSkills{"ty_heg__kuangcai", "ty_heg__shejian"}
Fk:loadTranslationTable{
  ["ty_heg__miheng"] = "祢衡",
  ["#ty_heg__miheng"] = "狂傲奇人",
  ["designer:ty_heg__miheng"] = "韩旭",
  ["illustrator:ty_heg__miheng"] = "MuMu",
  ["~ty_heg__miheng"] = "恶口……终致杀身……",
}

General:new(extension, "ty_heg__xunchen", "qun", 3):addSkills{"ty_heg__fenglve", "ty_heg__anyong"}

Fk:loadTranslationTable{
  ["ty_heg__xunchen"] = "荀谌",
  ["#ty_heg__xunchen"] = "三公谋主",
  ["designer:ty_heg__xunchen"] = "韩旭",
  ["illustrator:ty_heg__xunchen"] = "凝聚永恒",
  ["~ty_heg__xunchen"] = "为臣当不贰，贰臣不当为。",
}

General:new(extension, "ty_heg__jianggan", "wei", 3):addSkills{"ty_heg__weicheng", "ty_heg__daoshu"}
Fk:loadTranslationTable{
  ["ty_heg__jianggan"] = "蒋干",
  ["#ty_heg__jianggan"] = "锋谪悬信",
  ["designer:ty_heg__jianggan"] = "韩旭",
  ["illustrator:ty_heg__jianggan"] = "biou09",
  ["~ty_heg__jianggan"] = "丞相，再给我一次机会啊！",
}

local zhouyi = General:new(extension, "ty_heg__zhouyi", "wu", 3,3,General.Female)
zhouyi:addSkills{"ty_heg__zhukou", "ty_heg__duannian", "ty_heg__lianyou"}
zhouyi:addRelatedSkill("ty_heg__xinghuo")

Fk:loadTranslationTable{
  ["ty_heg__zhouyi"] = "周夷",
  ["#ty_heg__zhouyi"] = "靛情雨黛",
  ["designer:ty_heg__zhouyi"] = "韩旭",
  ["illustrator:ty_heg__zhouyi"] = "Tb罗根",
  ["~ty_heg__zhouyi"] = "江水寒，萧瑟起……",
}

local lvlingqi = General:new(extension, "ty_heg__lvlingqi", "qun", 4,4,General.Female)
lvlingqi.mainMaxHpAdjustedValue = -1
lvlingqi:addSkills{"ty_heg__guowu", "ty_heg__zhuangrong", "ty_heg__shenwei"}
lvlingqi:addRelatedSkill("ty_heg__zhuanrong_hs_wushuang")

Fk:loadTranslationTable{
  ["ty_heg__lvlingqi"] = "吕玲绮",
  ["#ty_heg__lvlingqi"] = "无双虓姬",
  ["designer:ty_heg__lvlingqi"] = "xat1k",
  ["illustrator:ty_heg__lvlingqi"] = "君桓文化",

  ["$ty_heg__zhuanrong_hs_wushuang1"] = "猛将策良骥，长戟破敌营。",
  ["$ty_heg__zhuanrong_hs_wushuang2"] = "杀气腾剑戟，严风卷戎装。",
  ["~ty_heg__lvlingqi"] = "父亲，女儿好累……",
}
--[[
local nanhualaoxian = General:new(extension, "ty_heg__nanhualaoxian", "qun", 4)

local ty_heg__leiji = fk.CreateTriggerSkill{
  name = "ty_heg__leiji",
  anim_type = "offensive",
  events = {fk.CardUsing, fk.CardResponding},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and target == player and data.card.name == "jink"
  end,
  on_cost = function(self, event, target, player, data)
    local to = player.room:askForChoosePlayers(player, table.map(player.room:getOtherPlayers(player, false), Util.IdMapper), 1, 1, "#ty_heg__leiji-choose", self.name, true)
    if #to > 0 then
      self.cost_data = to[1]
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local tar = room:getPlayerById(self.cost_data)
    local judge = {
      who = tar,
      reason = self.name,
      pattern = ".|.|spade",
    }
    room:judge(judge)
    if judge.card.suit == Card.Spade then
      room:damage{
        from = player,
        to = tar,
        damage = 2,
        damageType = fk.ThunderDamage,
        skillName = self.name,
      }
    end
end,
}
local ty_heg__yinbingn = fk.CreateTriggerSkill{
  name = "ty_heg__yinbingn",
  anim_type = "offensive",
  frequency = Skill.Compulsory,
  events = {fk.PreDamage, fk.HpLost},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) then
      if event == fk.PreDamage then
        return target == player and data.card and data.card.trueName == "slash"
      else
        return target ~= player
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.PreDamage then
      room:loseHp(data.to, data.damage, self.name)
      return true
    else
      player:drawCards(1, self.name)
    end
  end,
}
local ty_heg__huoqi = fk.CreateActiveSkill{
  name = "ty_heg__huoqi",
  anim_type = "support",
  card_num = 1,
  target_num = 1,
  prompt = "#huoqi",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0 and not player:isNude()
  end,
  card_filter = function(self, to_select, selected)
    return #selected == 0
  end,
  target_filter = function(self, to_select, selected)
    if #selected == 0 then
      local target = Fk:currentRoom():getPlayerById(to_select)
      return target:isWounded() and table.every(Fk:currentRoom().alive_players, function(p) return target.hp <= p.hp end)
    end
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    room:throwCard(effect.cards, self.name, player, player)
    if target:isWounded() then
      room:recover({
        who = target,
        num = 1,
        recoverBy = player,
        skillName = self.name
      })
    end
    if not target.dead then
      target:drawCards(1, self.name)
    end
  end,
}
local ty_heg__guizhu = fk.CreateTriggerSkill{
  name = "ty_heg__guizhu",
  anim_type = "drawcard",
  events = {fk.EnterDying},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and player:usedSkillTimes(self.name, Player.HistoryTurn) == 0
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(2, self.name)
  end,
}
local ty_heg__xianshou = fk.CreateActiveSkill{
  name = "ty_heg__xianshou",
  anim_type = "support",
  card_num = 0,
  target_num = 1,
  prompt = "#xianshou",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, to_select, selected)
    return #selected == 0
  end,
  on_use = function(self, room, effect)
    local target = room:getPlayerById(effect.tos[1])
    local n = not target:isWounded() and 2 or 1
    target:drawCards(n, self.name)
  end
}
local ty_heg__lundao = fk.CreateTriggerSkill{
  name = "ty_heg__lundao",
  anim_type = "masochism",
  events = {fk.Damaged},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.from and not data.from.dead and
      data.from:getHandcardNum() ~= player:getHandcardNum()
  end,
  on_cost = function(self, event, target, player, data)
    if data.from:getHandcardNum() > player:getHandcardNum() then
      return player.room:askForSkillInvoke(player, self.name, nil, "#ty_heg__lundao-invoke::"..data.from.id)
    else
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local from = data.from
    if data.from:getHandcardNum() > player:getHandcardNum() then
      room:doIndicate(player.id, {from.id})
      local id = room:askForCardChosen(player, from, "he", self.name)
      room:throwCard({id}, self.name, from, player)
    else
      player:drawCards(1, self.name)
    end
  end
}
local ty_heg__guanyue = fk.CreateTriggerSkill{
  name = "ty_heg__guanyue",
  anim_type = "control",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Finish
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local result = room:askForGuanxing(player, room:getNCards(2), {1, 2}, {1, 1}, self.name, true, {"Top", "prey"})
    if #result.top > 0 then
      table.removeOne(room.draw_pile, result.top[1])
      table.insert(room.draw_pile, 1, result.top[1])
      room:sendLog{
        type = "#GuanxingResult",
        from = player.id,
        arg = 1,
        arg2 = 0,
      }
    end
    if #result.bottom > 0 then
      room:obtainCard(player.id, result.bottom[1], false, fk.ReasonJustMove)
    end
  end,
}
local ty_heg__yanzhengn = fk.CreateTriggerSkill{
  name = "ty_heg__yanzhengn",
  anim_type = "offensive",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Start and player:getHandcardNum() > 1
  end,
  on_cost = function(self, event, target, player, data)
    local targets = table.map(player.room.alive_players, Util.IdMapper)
    local tos, card = player.room:askForChooseCardAndPlayers(player, targets, 1, player:getHandcardNum() - 1, ".|.|.|hand",
      "#yanzhengn-invoke:::"..(player:getHandcardNum() - 1), self.name, true)
    if #tos > 0 and card then
      player.room:sortPlayersByAction(tos)
      self.cost_data = {tos, card}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local ids = player:getCardIds("h")
    table.removeOne(ids, self.cost_data[2])
    room:throwCard(ids, self.name, player, player)
    for _, id in ipairs(self.cost_data[1]) do
      local p = room:getPlayerById(id)
      if not p.dead then
        room:damage{
          from = player,
          to = p,
          damage = 1,
          skillName = self.name,
        }
      end
    end
  end,
}
nanhualaoxian:addSkill(gongxiu)
nanhualaoxian:addSkill(jinghe)
jinghe:addRelatedSkill(jinghe_trigger)

nanhualaoxian:addRelatedSkill(ty_heg__leiji)
nanhualaoxian:addRelatedSkill(ty_heg__yinbingn)
nanhualaoxian:addRelatedSkill(ty_heg__huoqi)
nanhualaoxian:addRelatedSkill(ty_heg__guizhu)
nanhualaoxian:addRelatedSkill(ty_heg__xianshou)
nanhualaoxian:addRelatedSkill(ty_heg__lundao)
nanhualaoxian:addRelatedSkill(ty_heg__guanyue)
nanhualaoxian:addRelatedSkill(ty_heg__yanzhengn)
Fk:loadTranslationTable{
  ["ty_heg__nanhualaoxian"] = "南华老仙",
  ["#ty_heg__nanhualaoxian"] = "仙人指路",
  ["designer:ty_heg__nanhualaoxian"] = "韩旭",
  ["illustrator:ty_heg__nanhualaoxian"] = "君桓文化",

  ["ty_heg__leiji"] = "雷击",
  [":ty_heg__leiji"] = "当你使用或打出【闪】时，你可以令一名其他角色进行一次判定，若结果为：♠，你对其造成2点雷电伤害。",
  ["#ty_heg__leiji-choose"] = "雷击：令一名角色进行判定，若为♠，你对其造成2点雷电伤害。",
  ["ty_heg__yinbingn"] = "阴兵",
  [":ty_heg__yinbingn"] = "锁定技，你使用【杀】即将造成的伤害视为失去体力。当其他角色失去体力后，你摸一张牌。",
  ["ty_heg__huoqi"] = "活气",
  [":ty_heg__huoqi"] = "出牌阶段限一次，你可以弃置一张牌，然后令一名体力最少的角色回复1点体力并摸一张牌。",
  ["#ty_heg__huoqi"] = "活气：弃置一张牌，令一名体力最少的角色回复1点体力并摸一张牌",
  ["ty_heg__guizhu"] = "鬼助",
  [":ty_heg__guizhu"] = "每回合限一次，当一名角色进入濒死状态时，你可以摸两张牌。",
  ["ty_heg__xianshou"] = "仙授",
  [":ty_heg__xianshou"] = "出牌阶段限一次，你可以令一名角色摸一张牌。若其未受伤，则多摸一张牌。",
  ["#ty_heg__xianshou"] = "仙授：令一名角色摸一张牌，若其未受伤则多摸一张牌",
  ["ty_heg__lundao"] = "论道",
  [":ty_heg__lundao"] = "当你受到伤害后，若伤害来源的手牌多于你，你可以弃置其一张牌；若伤害来源的手牌数少于你，你摸一张牌。",
  ["#ty_heg__lundao-invoke"] = "论道：你可以弃置 %dest 一张牌",
  ["ty_heg__guanyue"] = "观月",
  [":ty_heg__guanyue"] = "结束阶段，你可以观看牌堆顶的两张牌，然后获得其中一张，将另一张置于牌堆顶。",
  ["prey"] = "获得",
  ["ty_heg__yanzhengn"] = "言政",
  [":ty_heg__yanzhengn"] = "准备阶段，若你的手牌数大于1，你可以选择一张手牌并弃置其余的牌，然后对至多等于弃置牌数的角色各造成1点伤害。",
  ["#ty_heg__yanzhengn-invoke"] = "言政：你可以选择保留一张手牌，弃置其余的手牌，对至多%arg名角色各造成1点伤害",

  ["~ty_heg__nanhualaoxian"] = "道亦有穷时……",
}
--]]
return extension
