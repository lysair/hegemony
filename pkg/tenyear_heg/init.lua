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

  ["~ty_heg__miheng"] = "恶口……终至杀身……",
}

General:new(extension, "ty_heg__xunchen", "qun", 3):addSkills{"ty_heg__anyong", "ty_heg__fenglve"}

Fk:loadTranslationTable{
  ["ty_heg__xunchen"] = "荀谌",
  ["#ty_heg__xunchen"] = "三公谋主",
  ["designer:ty_heg__xunchen"] = "韩旭",
  ["illustrator:ty_heg__xunchen"] = "凝聚永恒",
  ["ty_heg__fenglve"] = "锋略",
  [":ty_heg__fenglve"] = "出牌阶段限一次，你可和一名其他角色拼点，若你赢，该角色交给你其区域内的两张牌；若其赢，你交给其一张牌。"..
  "<br><font color=\"blue\">◆纵横：交换〖锋略〗描述中的“一张牌”和“两张牌”。<font><br><font color=\"grey\">\"<b>纵横</b>\"："..
  "当拥有“纵横”效果技能发动结算完成后，可以令技能目标角色获得对应修订描述后的技能，直到其下回合结束。",

  ["#ty_heg__fenglve-active"] = "发动“锋略”，与一名角色拼点",
  ["#ty_heg__fenglve-give"] = "锋略：选择 %arg 张牌交给 %dest",
  ["ty_heg__fenglve_mn_ask"] = "令%dest获得〖锋略（纵横）〗直到其下回合结束",
  ["@@ty_heg__fenglve_manoeuvre"] = "锋略 纵横",

  ["ty_heg__fenglve_manoeuvre"] = "锋略⇋",
  [":ty_heg__fenglve_manoeuvre"] = "出牌阶段限一次，你可以和一名其他角色拼点，若你赢，该角色交给你其区域内的一张牌；若其赢，你交给其两张牌。",

  ["ty_heg__anyong"] = "暗涌",
  ["#ty_heg__anyong-invoke"] = "暗涌：是否令 %src 对 %dest 造成的 %arg 点伤害翻倍！",
  [":ty_heg__anyong"] = "每回合限一次，当与你势力相同的一名角色对另一名其他角色造成伤害时，你可令此伤害翻倍，然后若受到伤害的角色："..
  "武将牌均明置，你失去1点体力并失去此技能；只明置了一张武将牌，你弃置两张手牌。",

  ["$ty_heg__fenglve1"] = "冀州宝地，本当贤者居之。",
  ["$ty_heg__fenglve2"] = "当今敢称贤者，唯袁氏本初一人。",
  ["$ty_heg__anyong1"] = "冀州暗潮汹涌，群仕居危思变。",
  ["$ty_heg__anyong2"] = "殿上太守且相看，殿下几人还拥韩。",
  ["~ty_heg__xunchen"] = "为臣当不贰，贰臣不当为。",
}

General:new(extension, "ty_heg__jianggan", "wei", 3):addSkills{"ty_heg__weicheng", "ty_heg__daoshu"}
Fk:loadTranslationTable{
  ["ty_heg__jianggan"] = "蒋干",
  ["#ty_heg__jianggan"] = "锋谪悬信",
  ["designer:ty_heg__jianggan"] = "韩旭",
  ["illustrator:ty_heg__jianggan"] = "biou09",
  ["ty_heg__weicheng"] = "伪诚",
  [":ty_heg__weicheng"] = "你交给其他角色手牌，或你的手牌被其他角色获得后，若你的手牌数小于体力值，你可以摸一张牌。",
  ["ty_heg__daoshu"] = "盗书",
  [":ty_heg__daoshu"] = "出牌阶段限一次，你可以选择一名其他角色并选择一种花色，然后获得其一张手牌。若此牌与你选择的花色："..
  "相同，你对其造成1点伤害且此技能视为未发动过；不同，你交给其一张其他花色的手牌（若没有需展示所有手牌）。",
  ["#ty_heg__DaoshuLog"] = "%from 对 %to 发动了 “%arg2”，选择了 %arg",
  ["#ty_heg__daoshu-give"] = "盗书：交给 %dest 一张非%arg手牌",

  ["$ty_heg__weicheng1"] = "略施谋略，敌军便信以为真。",
  ["$ty_heg__weicheng2"] = "吾只观雅规，而非说客。",
  ["$ty_heg__daoshu1"] = "得此文书，丞相定可高枕无忧。",
  ["$ty_heg__daoshu2"] = "让我看看，这是什么机密。",
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

  ["ty_heg__zhukou"] = "逐寇",
  [":ty_heg__zhukou"] = "当你于每回合的出牌阶段首次造成伤害后，你可摸X张牌（X为本回合你已使用的牌数且至多为5）。",
  ["ty_heg__duannian"] = "断念",
  [":ty_heg__duannian"] = "出牌阶段结束时，你可弃置所有手牌，然后将手牌摸至体力上限。",
  ["ty_heg__lianyou"] = "莲佑",
  [":ty_heg__lianyou"] = "当你死亡时，你可令一名其他角色获得“兴火”。",
  ["#ty_heg__lianyou-choose"] = "莲佑：选择一名角色，其获得“兴火”。",
  ["ty_heg__xinghuo"] = "兴火",
  [":ty_heg__xinghuo"] = "锁定技，当你造成火属性伤害时，你令此伤害+1。",

  ["#ty_heg__zhukou"] = "逐寇：你可摸 %arg 张牌",

  ["$ty_heg__zhukou1"] = "草莽贼寇，不过如此。",
  ["$ty_heg__zhukou2"] = "轻装上阵，利剑出鞘。",
  ["$ty_heg__duannian1"] = "断思量，莫思量。",
  ["$ty_heg__duannian2"] = "一别两宽，不负相思。",
  ["$ty_heg__xinghuo1"] = "莲花佑兴，业火可兴。",
  ["$ty_heg__xinghuo2"] = "昔日莲花开，今日红火燃。",
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

  ["ty_heg__guowu"] = "帼武",
  ["#ty_heg__guowu_delay"] = "帼武",
  [":ty_heg__guowu"] = "出牌阶段开始时，你可展示所有手牌，若包含的类别数：不小于1，你从弃牌堆中获得一张【杀】；不小于2，你本阶段使用牌无距离限制；"..
  "不小于3，你本阶段使用【杀】可以多指定两个目标（限一次）。",
  ["ty_heg__zhuangrong"] = "妆戎",
  [":ty_heg__zhuangrong"] = "出牌阶段限一次，你可以弃置一张锦囊牌，然后获得“无双”至此阶段结束。",
  ["ty_heg__shenwei"] = "神威",
  [":ty_heg__shenwei"] = "主将技，此武将牌上单独的阴阳鱼个数-1。①摸牌阶段，若你的体力值为全场最高，你多摸两张牌。②你的手牌上限+2。",
  ["ty_heg__zhuanrong_hs_wushuang"] = "无双",
  ["@@ty_heg__zhuanrong_hs_wushuang"] = "无双",
  [":ty_heg__zhuanrong_hs_wushuang"] = "锁定技，当你使用【杀】指定一个目标后，该角色需依次使用两张【闪】才能抵消此【杀】；当你使用【决斗】指定一个目标后，或成为一名角色使用【决斗】的目标后，该角色每次响应此【决斗】需依次打出两张【杀】。",
  ["#ty_heg__guowu-choose"] = "帼武：你可以为%arg增加至多两个目标",

  ["$ty_heg__guowu1"] = "方天映黛眉，赤兔牵红妆。",
  ["$ty_heg__guowu2"] = "武姬青丝利，巾帼女儿红。",
  ["$ty_heg__shenwei1"] = "锋镝鸣手中，锐戟映秋霜。",
  ["$ty_heg__shenwei2"] = "红妆非我愿，学武觅封侯。",
  ["$ty_heg__zhuangrong1"] = "继父神威，无坚不摧！",
  ["$ty_heg__zhuangrong2"] = "我乃温侯吕奉先之女！",
  ["$ty_heg__wushuang1"] = "猛将策良骥，长戟破敌营。",
  ["$ty_heg__wushuang2"] = "杀气腾剑戟，严风卷戎装。",
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

  ["ty_heg__gongxiu"] = "共修",
  [":ty_heg__gongxiu"] = "摸牌阶段，你可少摸一张牌，然后选择一项：1.令至多X名角色各摸一张牌；"..
  "2.令至多X名角色各弃置一张牌。（X为你的体力上限，不能连续选择同一项）",
  ["ty_heg__jinghe"] = "经合",
  [":ty_heg__jinghe"] = "出牌阶段限一次，你可展示至多X张牌名各不同的手牌并选择等量有明置武将牌的角色，从“写满技能的天书”随机展示X个技能，这些角色依次选择并"..
  "获得其中一个技能，直到你下回合开始 （X为你的体力上限）。",

  ["#ty_heg__gongxiu-choice"] = "共修：选择令角色摸牌或弃牌",
  ["#ty_heg__gongxiu_0-ask"] = "是否发动 共修，令至多%arg名角色各摸一张牌或各弃置一张牌",
  ["#ty_heg__gongxiu_1-ask"] = "是否发动 共修，令至多%arg名角色各弃置一张牌",
  ["#ty_heg__gongxiu_2-ask"] = "是否发动 共修，令至多%arg名角色各摸一张牌",
  ["ty_heg__gongxiu_draw"] = "令至多%arg名角色各摸一张牌",
  ["ty_heg__gongxiu_discard"] = "令至多%arg名角色各弃置一张牌",

  ["#ty_heg__gongxiu_draw-choose"] = "共修：选择至多%arg名角色各摸一张牌",
  ["#ty_heg__gongxiu_discard-choose"] = "共修：选择至多%arg名角色各弃置一张牌",

  ["#ty_heg__jinghe"] = "经合：展示至多四张牌名各不同的手牌，令等量的角色获得技能",
  ["#ty_heg__jinghe-choice"] = "经合：选择你要获得的技能",
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

  ["$ty_heg__gongxiu1"] = "福祸与共，业山可移。",
  ["$ty_heg__gongxiu2"] = "修行退智，遂之道也。",
  ["$ty_heg__jinghe1"] = "大哉乾元，万物资始。",
  ["$ty_heg__jinghe2"] = "无极之外，复无无极。",
  ["~ty_heg__nanhualaoxian"] = "道亦有穷时……",
}
--]]
return extension
