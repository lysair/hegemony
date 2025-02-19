local extension = Package:new("offline_heg")
extension.extensionName = "hegemony"
extension.game_modes_whitelist = { 'nos_heg_mode', 'new_heg_mode' }

local H = require "packages/hegemony/util"
local U = require "packages/utility/utility"

Fk:loadTranslationTable{
  ["offline_heg"] = "国战-线下卡专属",
  ["of_heg"] = "线下",
}

local lifeng = General (extension,"of_heg__lifeng","shu",3) --李丰
local tunchu = fk.CreateTriggerSkill{
  name = "of_heg__tunchu",
  anim_type = "drawcard",
  derived_piles = "of_heg__lifeng_liang",
  events = {fk.DrawNCards, fk.AfterDrawNCards},
  can_trigger = function(self, event, target, player, data)
    if target == player then
      if event == fk.DrawNCards then
        return player:hasSkill(self) 
      else
        return player:usedSkillTimes(self.name, Player.HistoryPhase) > 0 and not player:isKongcheng()
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    if event == fk.DrawNCards then
      return player.room:askForSkillInvoke(player, self.name)
    else
      local cards = player.room:askForCard(player, 1, 2, false, self.name, false, ".", "#of_heg__tunchu-put")
      if #cards > 0 then
        self.cost_data = cards
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    if event == fk.DrawNCards then
      data.n = data.n + 2
      player.room:setPlayerMark(player, "@@of_heg__tunchu_prohibit-turn", 1)
    else
      player:addToPile("of_heg__lifeng_liang", self.cost_data, true, self.name)
    end
  end,
}
local tunchu_prohibit = fk.CreateProhibitSkill{
  name = "#of_heg__tunchu_prohibit",
  prohibit_use = function(self, player, card)
    return player:hasSkill(tunchu) and player:getMark("@@of_heg__tunchu_prohibit-turn") > 0 and card.trueName == "slash"
  end,
}
local shuliang = fk.CreateTriggerSkill{
  name = "of_heg__shuliang",
  anim_type = "support",
  expand_pile = "of_heg__lifeng_liang",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and target.phase == Player.Finish and (target == player or (H.compareKingdomWith(target, player) and player:distanceTo(target) <= #(player:getPile("of_heg__lifeng_liang") or {}))) and
    #player:getPile("of_heg__lifeng_liang") > 0
  end,
  on_cost = function(self, event, target, player, data)
    local card = player.room:askForCard(player, 1, 1, false, self.name, true,
      ".|.|.|of_heg__lifeng_liang|.|.", "#of_heg__shuliang-invoke::"..target.id, "of_heg__lifeng_liang")
    if #card > 0 then
      self.cost_data = card
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:doIndicate(player.id, {target.id})
    room:moveCards({
      from = player.id,
      ids = self.cost_data,
      toArea = Card.DiscardPile,
      moveReason = fk.ReasonPutIntoDiscardPile,
      skillName = self.name,
      specialName = self.name,
    })
    if not target.dead then
      target:drawCards(2, self.name)
    end
  end,
}
tunchu:addRelatedSkill(tunchu_prohibit)
lifeng:addSkill(tunchu)
lifeng:addSkill(shuliang)
Fk:loadTranslationTable{
  ["of_heg__lifeng"] = "李丰",
  ["#of_heg__lifeng"] = "朱提太守",
  ["cv:of_heg__lifeng"] = "秦且歌",
  ["illustrator:of_heg__lifeng"] = "NOVART",
  ["of_heg__tunchu"] = "屯储",
  [":of_heg__tunchu"] = "摸牌阶段，你可以多摸两张牌，然后将至多两张手牌置于你的武将牌上，称为“粮”；然后本回合你不能使用【杀】。",
  ["of_heg__shuliang"] = "输粮",
  [":of_heg__shuliang"] = "一名与你势力相同角色的结束阶段，若你与其距离不大于“粮”数，你可以移去一张“粮”，然后该角色摸两张牌。",
  ["of_heg__lifeng_liang"] = "粮",
  ["@@of_heg__tunchu_prohibit-turn"] = "屯储",
  ["#of_heg__tunchu-put"] = "屯储：你可以将至多两张手牌置为“粮”",
  ["#of_heg__shuliang-invoke"] = "输粮：你可以移去一张“粮”，令 %dest 摸两张牌",
  ["of_heg__tunchu"] = "屯储",
  ["$of_heg__tunchu1"] = "屯粮事大，暂不与尔等计较。",
  ["$of_heg__tunchu2"] = "屯粮待战，莫动刀枪。",
  ["$of_heg__shuliang1"] = "将军驰劳，酒肉慰劳。",
  ["$of_heg__shuliang2"] = "将军，牌来了。",
  ["~of_heg__lifeng"] = "吾，有负丞相重托。",
}

local yangwan = General(extension, "ty_heg__yangwan", "shu", 3, 3,General.Female) -- 保留原本的前缀

local youyan = fk.CreateTriggerSkill{
  name = "ty_heg__youyan",
  anim_type = "drawCards",
  events = {fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) and player:usedSkillTimes(self.name, Player.HistoryTurn) == 0 and player.room.current == player then
      local suits = {"spade", "club", "heart", "diamond"}
      local can_invoked = false
      for _, move in ipairs(data) do
        if move.toArea == Card.DiscardPile and move.moveReason == fk.ReasonDiscard then
          if move.from == player.id then
            for _, info in ipairs(move.moveInfo) do
              if info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip then
                table.removeOne(suits, Fk:getCardById(info.cardId, true):getSuitString())
                can_invoked = true
              end
            end
          end
        end
      end
      return can_invoked and #suits > 0
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local suits = {"spade", "club", "heart", "diamond"}
    for _, move in ipairs(data) do
      if move.toArea == Card.DiscardPile and move.moveReason == fk.ReasonDiscard then
        if move.from == player.id then
          for _, info in ipairs(move.moveInfo) do
            if info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip then
              table.removeOne(suits, Fk:getCardById(info.cardId, true):getSuitString())
            end
          end
        end
      end
    end
    if #suits > 0 then
      local show_num = 4
      local cards = room:getNCards(show_num)
      room:moveCards{
        ids = cards,
        toArea = Card.Processing,
        moveReason = fk.ReasonJustMove,
        skillName = self.name,
        proposer = player.id
      }
      room:delay(1000)
      local to_get = table.filter(cards, function(id)
        return table.contains(suits, Fk:getCardById(id, true):getSuitString())
      end)
      if #to_get > 0 then
        room:obtainCard(player.id, to_get, true, fk.ReasonJustMove)
      end
      cards = table.filter(cards, function (id)
        return room:getCardArea(id) == Card.Processing
      end)
      if #cards > 0 then
        room:moveCardTo(cards, Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile, self.name)
      end
    end
  end,
}

---@param room Room
---@param player ServerPlayer
---@param add bool
---@param isDamage bool
local function handleZhuihuan(room, player, add, isDamage)
  local mark_name = isDamage and "ty_heg__zhuihuan-damage" or "ty_heg__zhuihuan-discard"
  room:setPlayerMark(player, "@@" .. mark_name, add and 1 or 0)
  room:handleAddLoseSkills(player, add and "#" .. mark_name or "-#" .. mark_name, nil, false, true)
end

local zhuihuan = fk.CreateTriggerSkill{
  name = "ty_heg__zhuihuan",
  anim_type = "defensive",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and player.phase == Player.Finish
  end,
  on_cost = function(self, event, target, player, data)
    local to = player.room:askForChoosePlayers(player, table.map(player.room.alive_players, Util.IdMapper), 1, 2, "#ty_heg__zhuihuan-choose", self.name, true, true)
    if #to > 0 then
      self.cost_data = to
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local tos = self.cost_data
    local choices = {"zhuihuan-damage::" ..tos[1], "zhuihuan-discard::" ..tos[1]}
    if #tos == 1 then
      local choice = room:askForChoice(player, choices, self.name)
      local target = room:getPlayerById(tos[1])
      if choice:startsWith("zhuihuan-damage") then
        handleZhuihuan(room, target, true, true)
      elseif choice:startsWith("zhuihuan-discard") then
        handleZhuihuan(room, target, true, false)
      end
    elseif #tos == 2 then
      local choice = room:askForChoice(player, choices, self.name)
      local target1 = room:getPlayerById(tos[1])
      local target2 = room:getPlayerById(tos[2])
      if choice:startsWith("zhuihuan-damage") then
        handleZhuihuan(room, target1, true, true)
        handleZhuihuan(room, target2, true, false)
      elseif choice:startsWith("zhuihuan-discard") then
        handleZhuihuan(room, target2, true, true)
        handleZhuihuan(room, target1, true, false)
      end
    end
  end,

  refresh_events = {fk.BuryVictim, fk.TurnStart, fk.Death},
  can_refresh = function (self, event, target, player, data)
    if event == fk.BuryVictim then
      return target:getMark("@@ty_heg__zhuihuan-damage") == 1 or target:getMark("@@ty_heg__zhuihuan-discard") == 1
    end
    if event == fk.TurnStart then
      return player:hasSkill(self) and target == player
    end
    if event == fk.Death then
      return player:hasSkill(self, false, true) and player == target
    end
  end,
  on_refresh = function (self, event, target, player, data)
    local room = player.room
    if event == fk.TurnStart or event == fk.Death then
      for _, p in ipairs(room.alive_players) do
        if p:getMark("@@ty_heg__zhuihuan-damage") == 1 then
          handleZhuihuan(room, p, false, true)
        end
        if p:getMark("@@ty_heg__zhuihuan-discard") == 1 then
          handleZhuihuan(room, p, false, false)
        end
      end
    elseif target:getMark("@@ty_heg__zhuihuan-damage") == 1 then
      handleZhuihuan(room, target, false, true)
    elseif target:getMark("@@ty_heg__zhuihuan-discard") == 1 then
      handleZhuihuan(room, target, false, false)
    end
  end,
}

local zhuihuan_damage = fk.CreateTriggerSkill{
  name = "#ty_heg__zhuihuan-damage",
  anim_type = "offensive",
  events = {fk.Damaged},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and data.from and not data.from.dead and player == target
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    handleZhuihuan(room, target, false, true)
    room:damage{
      from = player,
      to = data.from,
      damage = 1,
      skillName = self.name,
    }
  end,
}

local zhuihuan_discard = fk.CreateTriggerSkill{
  name = "#ty_heg__zhuihuan-discard",
  anim_type = "offensive",
  events = {fk.Damaged},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and data.from and not data.from.dead and player == target
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local from = data.from
    room:askForDiscard(from, 2, 2, false, self.name, false)
    handleZhuihuan(room, target, false, false)
  end,
}

yangwan:addCompanions("hs__machao")
yangwan:addSkill(youyan)
yangwan:addSkill(zhuihuan)
Fk:addSkill(zhuihuan_damage)
Fk:addSkill(zhuihuan_discard)

Fk:loadTranslationTable{
  ["ty_heg__yangwan"] = "杨婉",
  ["#ty_heg__yangwan"] = "融沫之鲡",
  --["designer:yangwan"] = "",
  ["illustrator:ty_heg__yangwan"] = "木美人",

  ["ty_heg__youyan"] = "诱言",
  [":ty_heg__youyan"] = "每回合限一次，当你的牌于你回合内因弃置而置入弃牌堆后，你可展示牌堆顶四张牌，获得其中与此置入弃牌堆花色均不相同的牌。",
  ["ty_heg__zhuihuan"] = "追还",
  [":ty_heg__zhuihuan"] = "结束阶段，你可选择分配以下效果给至多两名角色直至你下回合开始（各限触发一次）："..
  "1.受到伤害后，伤害来源弃置两张手牌；2.受到伤害后，对伤害来源造成1点伤害。",
  ["#ty_heg__zhuihuan-choose"] = "追还：选择一至两名角色分配对应效果",

  ["@@ty_heg__zhuihuan-discard"] = "追还",
  ["@@ty_heg__zhuihuan-damage"] = "追还",
  ["#ty_heg__zhuihuan-discard"] = "追还",
  ["#ty_heg__zhuihuan-damage"] = "追还",
  ["zhuihuan-damage"] = "对 %dest 分配伤害效果",
  ["zhuihuan-discard"] = "对 %dest 分配弃牌效果",

  ["$ty_heg__youyan1"] = "诱言者，为人所不齿。",
  ["$ty_heg__youyan2"] = "诱言之弊，不可不慎。",
  ["$ty_heg__zhuihuan1"] = "伤人者，追而还之！",
  ["$ty_heg__zhuihuan2"] = "追而还击，皆为因果。",
  ["~ty_heg__yangwan"] = "遇人不淑……",
}

local lingcao = General(extension, "of_heg__lingcao", "wu", 4)--凌操
local dujin = fk.CreateTriggerSkill{
 name ="of_heg__dujin",
 anim_type = "drawcard",
 events = {fk.DrawNCards,fk.GeneralRevealed},
 can_trigger = function (self, event, target, player, data)
    if target ~= player or not player:hasSkill(self) then return false end
      if event == fk.GeneralRevealed then
        if player:usedSkillTimes(self.name, Player.HistoryGame) == 0 then
          for _, v in pairs(data) do
            if table.contains(Fk.generals[v]:getSkillNameList(), self.name) then return true end
          end
        end
      else
        return player.phase == Player.Draw
      end
 end,
 on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.GeneralRevealed then
      if player and H.getKingdomPlayersNum(room,true)[H.getKingdom(player)] == 1 then
        H.addHegMark(player.room, player, "vanguard")
      end
    else
      data.n = data.n + math.ceil(#player:getCardIds(Player.Equip) / 2) 
    end 
 end,
}




lingcao:addSkill(dujin)
Fk:loadTranslationTable{
 ["of_heg__lingcao"]= "凌操",
 ["#of_heg__lingcao"] = "激流勇进",
  ["illustrator:of_heg__lingcao"] = "樱花闪乱",
 ["of_heg__dujin"]="独进",
 [":of_heg__dujin"]="摸牌阶段，你可以多摸X张牌（X为你装备区牌数的一半，向上取整）。当你首次明置此武将牌后，若没有与你势力相同的{其他角色或已死亡的角色}，你获得1枚“先驱”标记。 ",
 ["#of_heg__reveral"]="独进",
 ["$of_heg__dujin1"] = "带兵十万，不如老夫多甲一件！",
 ["$of_heg__dujin2"] = "轻舟独进，破敌先锋！",
 ["~of_heg__lingcao"] = "呃啊！（扑通）此箭……何来……",
}


local himiko = General(extension, "os_heg__himiko", "qun", 3, 3, General.Female) -- 保留原本的前缀

local guishu = fk.CreateViewAsSkill{
  name = "guishu",
  pattern = "known_both,befriend_attacking",
  anim_type = "drawcard",
  interaction = function()
    local names = {}
    local all_choices = {"befriend_attacking", "known_both"}
    for _, name in ipairs(all_choices) do
      if Self:getMark("_guishu-turn") ~= name and Self:canUse(Fk:cloneCard(name)) then
        table.insertIfNeed(names, name)
      end
    end
    if #names == 0 then return end
    return UI.ComboBox {choices = names, all_choices = all_choices }
  end,
  card_filter = function(self, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).suit == Card.Spade
      and Fk:currentRoom():getCardArea(to_select) == Player.Hand
  end,
  view_as = function(self, cards)
    if #cards ~= 1 or self.interaction.data == nil then return end
    local card = Fk:cloneCard(self.interaction.data)
    card.skillName = self.name
    card:addSubcard(cards[1])
    return card
  end,
  before_use = function(self, player, use)
    player.room:setPlayerMark(player, "_guishu-turn", use.card.name)
  end
}

local yuanyuk = fk.CreateTriggerSkill{
  name = "yuanyuk",
  anim_type = "defensive",
  frequency = Skill.Compulsory,
  events = {fk.DamageInflicted},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.from and not data.from:inMyAttackRange(target)
  end,
  on_use = function(self, event, target, player, data)
    data.damage = data.damage - 1
  end
}

himiko:addSkill(guishu)
himiko:addSkill(yuanyuk)

Fk:loadTranslationTable{
  ['os_heg__himiko'] = '卑弥呼', -- 十年心版
  ["#os_heg__himiko"] = "邪马台的女王",
  ["illustrator:os_heg__himiko"] = "聚一_小道恩",
  ["designer:os_heg__himiko"] = "淬毒",

  ["guishu"] = "鬼术",
  [":guishu"] = "出牌阶段，你可将一张♠手牌当【远交近攻】或【知己知彼】使用（不可与你此回合上一次以此法使用的牌相同）。",
  ["yuanyuk"] = "远域",
  [":yuanyuk"] = "锁定技，当你受到伤害时，若有伤害来源且你不在伤害来源的攻击范围内，此伤害-1。",

  ["$guishu1"] = "契约已定！",
  ["$guishu2"] = "准备好，听候女王的差遣了吗？",
  ["$yuanyuk1"] = "是你，在召唤我吗？",
  ["$yuanyuk2"] = "这片土地的人，真是太有趣了。",
  ["~os_heg__himiko"] = "我还会从黄泉比良坂回来的……",
}

local xurong = General(extension, "of_heg__xurong", "qun", 4)
local xionghuo = fk.CreateActiveSkill{
  name = "of_heg__xionghuo",
  anim_type = "offensive",
  card_num = 0,
  target_num = 1,
  prompt = "#of_heg__xionghuo-active",
  can_use = function(self, player)
    return player:getMark("@of_heg__baoli") > 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, to_select, selected)
    local target = Fk:currentRoom():getPlayerById(to_select)
    return #selected == 0 and to_select ~= Self.id and target:getMark("@of_heg__baoli") == 0 and not H.compareKingdomWith(Self, target)
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    room:removePlayerMark(player, "@of_heg__baoli", 1)
    room:addPlayerMark(target, "@of_heg__baoli", 1)
  end,
}
local xionghuo_record = fk.CreateTriggerSkill{
  name = "#of_heg__xionghuo_record",
  main_skill = xionghuo,
  anim_type = "offensive",
  events = {fk.GeneralRevealed, fk.DamageCaused, fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(xionghuo) then
      if event == fk.GeneralRevealed then
        if player:usedSkillTimes(xionghuo.name, Player.HistoryGame) == 0 then
          for _, v in pairs(data) do
            if table.contains(Fk.generals[v]:getSkillNameList(), xionghuo.name) then return true end
          end
        end
      elseif event == fk.DamageCaused then
        return target == player and data.to ~= player and data.to:getMark("@of_heg__baoli") > 0 and data.card and data.to:getMark("@@of_heg__baoli_damage-turn") == 0
      else
        return target ~= player and target:getMark("@of_heg__baoli") > 0 and target.phase == Player.Play
      end
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke("of_heg__xionghuo")
    if event == fk.GeneralRevealed then
      room:addPlayerMark(player, "@of_heg__baoli", 3)
    elseif event == fk.DamageCaused then
      room:doIndicate(player.id, {data.to.id})
      data.damage = data.damage + 1
      room:setPlayerMark(data.to, "@@of_heg__baoli_damage-turn", 1)
    else
      room:doIndicate(player.id, {target.id})
      room:setPlayerMark(target, "@of_heg__baoli", 0)
      local rand = math.random(1, target:isNude() and 2 or 3)
      if rand == 1 then
        room:damage {
          from = player,
          to = target,
          damage = 1,
          damageType = fk.FireDamage,
          skillName = "of_heg__xionghuo",
        }
        if not (player.dead or target.dead) then
          room:addTableMark(target, "of_heg__xionghuo_prohibit-turn", player.id)
        end
      elseif rand == 2 then
        room:loseHp(target, 1, "of_heg__xionghuo")
        if not target.dead then
          room:addPlayerMark(target, "MinusMaxCards-turn", 1)
        end
      else
        local cards = table.random(target:getCardIds(Player.Hand), 1)
        table.insertTable(cards, table.random(target:getCardIds(Player.Equip), 1))
        room:obtainCard(player, cards, false, fk.ReasonPrey)
      end
    end
  end,

  refresh_events = {fk.BuryVictim, fk.EventLoseSkill},
  can_refresh = function(self, event, target, player, data)
    if event == fk.BuryVictim then
      return player == target and player:hasSkill(xionghuo, true, true) and table.every(player.room.alive_players, function (p)
        return not p:hasSkill(xionghuo, true)
      end)
    elseif event == fk.EventLoseSkill then
      return player == target and data == xionghuo and table.every(player.room.alive_players, function (p)
        return not p:hasSkill(xionghuo, true)
      end)
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    for _, p in ipairs(room.alive_players) do
      if p:getMark("@of_heg__baoli") > 0 then
        room:setPlayerMark(p, "@of_heg__baoli", 0)
      end
    end
  end,
}
local xionghuo_prohibit = fk.CreateProhibitSkill{
  name = "#of_heg__xionghuo_prohibit",
  is_prohibited = function(self, from, to, card)
    return card.trueName == "slash" and table.contains(from:getTableMark("of_heg__xionghuo_prohibit-turn") ,to.id)
  end,
}

xionghuo:addRelatedSkill(xionghuo_record)
xionghuo:addRelatedSkill(xionghuo_prohibit)
xurong:addSkill(xionghuo)

Fk:loadTranslationTable{
  ["of_heg__xurong"] = "徐荣",
  ["#of_heg__xurong"] = "玄菟战魔",
  ["cv:of_heg__xurong"] = "曹真",
  ["designer:of_heg__xurong"] = "Loun老萌",
  ["illustrator:of_heg__xurong"] = "青岛磐蒲",

  ["of_heg__xionghuo"] = "凶镬",
  [":of_heg__xionghuo"] = "①当你首次明置此武将牌后，你获得三枚“暴戾”标记。②出牌阶段，你可以交给一名与你势力不同的角色一枚“暴戾”标记。③每回合每名角色限一次，当你使用牌对拥有“暴戾”标记的其他角色造成伤害时，此伤害+1。④拥有“暴戾”标记的其他角色出牌阶段开始时，其移去“暴戾”标记并随机执行：1.你对其造成1点火焰伤害，其本回合不能对你使用【杀】；2.其失去1点体力且本回合手牌上限-1；3.你获得其装备区里的一张牌，然后获得其一张手牌。",

  ["#of_heg__xionghuo_record"] = "凶镬",
  ["@of_heg__baoli"] = "暴戾",
  ["#of_heg__xionghuo-active"] = "发动 凶镬，将“暴戾”交给其他角色",
  ["@@of_heg__baoli_damage-turn"] = "凶镬 已造伤",

  ["$of_heg__xionghuo1"] = "战场上的懦夫，可不会有好结局！",
  ["$of_heg__xionghuo2"] = "用最残忍的方式，碾碎敌人！",
  ["~of_heg__xurong"] = "死于战场……是个不错的结局……",
}

return extension
