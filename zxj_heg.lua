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
    return H.compareKingdomWith(player, target) and player:hasSkill(self)
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
  frequency = Skill.Compulsory,
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
        room:obtainCard(player.id, card, false, fk.ReasonGive)
      end
      room:setPlayerMark(target, "zx_heg__fuli_prohibit-turn", 1)
      room:setPlayerMark(target, "@zx_heg__fuli-turn", Fk:getCardById(card):getSuitString())
  end,
}

local fuli_prohibit = fk.CreateProhibitSkill{
  name = "#zx_heg__fuli_prohibit",
  prohibit_use = function(self, player, card)
    return (player:getMark("zx_heg__fuli_prohibit-turn") ~= 0) and (player:getMark("@zx_heg__fuli-turn") == card:getSuitString())
  end,
  prohibit_response = function(self, player, card)
    return (player:getMark("zx_heg__fuli_prohibit-turn") ~= 0) and (player:getMark("@zx_heg__fuli-turn") == card:getSuitString())
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
        U.askForPlayCard(room, p, nil, ".", self.name)
      end
    end
    local used_color = {}
    U.getEventsByRule(room, GameEvent.UseCard, 998, function (e)
      local use = e.data[1]
      if not table.contains(used_color, use.card.suit) and use.card.suit ~= 0 then
        table.insert(used_color, use.card.suit)
      end
      return false
    end, room.logic:getCurrentEvent():findParent(GameEvent.Turn, true).id)
    if #used_color == 4 then
      player:drawCards(2, self.name)
      if player.hp < player.maxHp then
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

Fk:loadTranslationTable{
    ["zx_heg__simafu"] = "司马孚", --魏国
    ["designer:zx_heg__simafu"] = "程昱",
    ["zx_heg__zhangding"] = "彰定",
    [":zx_heg__zhangding"] = "锁定技，摸牌阶段，你多摸三张牌；摸牌阶段开始时，若你的手牌数、体力值、与你势力相同的角色数每有一项为全场最多，你便弃置一张牌，若你未以此法弃牌，你跳过本回合的出牌阶段和弃牌阶段。",
    ["zx_heg__tongjun"] = "恸君",
    [":zx_heg__tongjun"] = "大势力角色进入濒死状态时，你可选择你与其各一张手牌，然后你交换这两张牌。",
}

Fk:loadTranslationTable{
    ["zx_heg__qiaozhou"] = "谯周", --蜀国
    ["designer:zx_heg__qiaozhou"] = "紫乔",
    ["zx_heg__huiming"] = "汇命",
    [":zx_heg__huiming"] = "每轮限一次，已确定势力角色的准备阶段，你可观看牌堆顶三张牌并将其中任意张牌置入弃牌堆，其余的牌以任意顺序置于牌堆顶，然后若你以此法将牌置入弃牌堆，其可受到1点无来源伤害，获得你以此法置入弃牌堆的牌。",
    ["zx_heg__jiguo"] = "寄国",
    [":zx_heg__jiguo"] = "限定技，其他角色死亡后，你可令所有与你势力相同的角色依次交给伤害来源一张牌并回复1点体力。",
}

Fk:loadTranslationTable{
    ["zx_heg__huoyi"] = "霍弋", --蜀国
    ["designer:zx_heg__huoyi"] = "时雨",
    ["zx_heg__jinhun"] = "烬魂",
    [":zx_heg__jinhun"] = "锁定技，当你受到伤害时，若你横置或叠置，你弃置至少一张牌并防止等量的伤害，然后若你没有手牌或体力值为1，你复原武将牌。",
    ["zx_heg__guyuan"] = "孤援",
    [":zx_heg__guyuan"] = "出牌阶段，若你平置，你可叠置，视为使用任意一张伤害类锦囊牌，若没有与你势力相同的其他角色，此牌不可被响应。",
}

Fk:loadTranslationTable{
    ["zx_heg__taohuang"] = "陶璜", --吴国
    ["designer:zx_heg__taohuang"] = "紫乔",
    ["zx_heg__luyi"] = "赂遗",
    [":zx_heg__luyi"] = "出牌阶段限一次，你可展示一张非基本手牌，令其他两名角色拼点，赢的角色获得展示牌。",
    ["zx_heg__pofu"] = "破伏",
    [":zx_heg__pofu"] = "你可将【闪】当【无懈可击】使用，若此牌的目标为指定你为唯一目标的普通锦囊牌，你选择一项：1.获得此锦囊牌；2.对此牌使用者造成1点伤害。",
}

Fk:loadTranslationTable{
    ["zx_heg__sunjun"] = "孙峻", --吴国
    ["designer:zx_heg__sunjun"] = "紫乔",
    ["zx_heg__suchao"] = "肃朝",
    [":zx_heg__suchao"] = "出牌阶段限一次，你可对至多三名手牌数大于你的角色各造成1点伤害，若如此做，此阶段结束时，这些角色依次回复1点体力并可以对你使用一张无距离限制的【杀】。",
    ["zx_heg__zhulian"] = "株连",
    [":zx_heg__zhulian"] = "锁定技，其他角色于你的回合内使用【桃】或成为【桃】的目标后，你令其受到的伤害于此回合内+1。",
}

Fk:loadTranslationTable{
    ["zx_heg__liuyu"] = "刘虞", --群雄
    ["designer:zx_heg__liuyu"] = "紫星居",
    ["zx_heg__suifu"] = "绥抚",
    [":zx_heg__suchao"] = "其他角色的结束阶段，若本回合有至少两名小势力角色受到过伤害，你可令其将所有手牌置于牌堆顶，然后其视为使用一张【五谷丰登】。",
    ["zx_heg__anjing"] = "安境",
    [":zx_heg__zhulian"] = "每回合限一次，与你势力相同的角色受到伤害后，你可令所有与你势力相同的角色各摸一张牌。",
}

return extension