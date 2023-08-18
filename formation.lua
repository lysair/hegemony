local extension = Package:new("formation")
extension.extensionName = "hegemony"
extension.game_modes_whitelist = { 'nos_heg_mode', 'new_heg_mode' }

local H = require "packages/hegemony/util"

Fk:loadTranslationTable{
  ["formation"] = "君临天下·阵",
  ["ld"] = "君临",
}

local jiangfei = General(extension, "ld__jiangwanfeiyi", "shu", 3)
local shengxi = fk.CreateTriggerSkill{
  name = "ld__shengxi",
  anim_type = "drawcard",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return player == target and player:hasSkill(self.name) and player.phase == Player.Finish and 
      #player.room.logic:getEventsOfScope(GameEvent.ChangeHp, 1, function (e)
        local damage = e.data[5]
        if damage and target == damage.from then
          return true
        end
      end, Player.HistoryTurn) == 0
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(2, self.name)
  end,
}

local shoucheng = fk.CreateTriggerSkill{
  name = "shoucheng",
  anim_type = "support",
  events = {fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self.name) then return end
    for _, move in ipairs(data) do
      if move.from then
        local from = player.room:getPlayerById(move.from)
        if from:isKongcheng() and H.compareKingdomWith(from, player) and from.phase == Player.NotActive then
          for _, info in ipairs(move.moveInfo) do
            if info.fromArea == Card.PlayerHand then
              return true
            end
          end
        end
      end
    end
  end,
  on_trigger = function(self, event, target, player, data)
    local targets = {}
    local room = player.room
    for _, move in ipairs(data) do
      if move.from then
        local from = room:getPlayerById(move.from)
        if from:isKongcheng() and H.compareKingdomWith(from, player) and from.phase == Player.NotActive then
          for _, info in ipairs(move.moveInfo) do
            if info.fromArea == Card.PlayerHand then
              table.insertIfNeed(targets, from.id)
            end
          end
        end
      end
    end
    room:sortPlayersByAction(targets)
    for _, p in ipairs(targets) do
      local to = room:getPlayerById(p)
      if to.dead or not player:hasSkill(self.name) then break end
      self:doCost(event, p, player, nil)
    end
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, nil, "#shoucheng-draw::" .. target)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:doIndicate(player.id, {target})
    room:getPlayerById(target):drawCards(1, self.name)
  end,
}

jiangfei:addSkill(shengxi)
jiangfei:addSkill(shoucheng)

Fk:loadTranslationTable{
  ["ld__jiangwanfeiyi"] = "蒋琬费祎",
  ["ld__shengxi"] = "生息",
  [":ld__shengxi"] = "结束阶段开始时，若你未于此回合内造成过伤害，你可摸两张牌。",
  ["shoucheng"] = "守成",
  [":shoucheng"] = "与你势力相同的角色于其回合外失去最后的手牌后，你可令其摸一张牌。",

  ["#shoucheng-draw"] = "守成：你可令 %dest 摸一张牌",

  ["$ld__shengxi1"] = "国之生计，在民生息。",
  ["$ld__shengxi2"] = "安民止战，兴汉室！",
  ["$shoucheng1"] = "待吾等助将军一臂之力！",
  ["$shoucheng2"] = "国库盈余，可助军威。",
  ["~ld__jiangwanfeiyi"] = "墨守成规，终为其害啊……",
}

local xusheng = General(extension, "ld__xusheng", "wu", 4)

local yicheng = fk.CreateTriggerSkill{
  name = "yicheng",
  anim_type = "defensive",
  events = {fk.TargetConfirmed},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self.name) and H.compareKingdomWith(target, player) and data.card.trueName == "slash"
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, nil, "#yicheng-ask::" .. target.id)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:doIndicate(player.id, {target.id})
    target:drawCards(1, self.name)
    if not target.dead then
      room:askForDiscard(target, 1, 1, true, self.name, false)
    end
  end
}

xusheng:addSkill(yicheng)

Fk:loadTranslationTable{
  ["ld__xusheng"] = "徐盛",
  ["yicheng"] = "疑城",
  [":yicheng"] = "当一名与你势力相同的角色成为【杀】的目标后，你可令其摸一张牌，然后其弃置一张牌。",

  ["#yicheng-ask"] = "疑城：你可令 %dest 摸一张牌，然后其弃置一张牌",

  ["$yicheng1"] = "不怕死，就尽管放马过来！",
  ["$yicheng2"] = "待末将布下疑城，以退曹贼。",
  ["~ld__xusheng"] = "可怜一身胆略，尽随一抔黄土……",
}

local yuji = General(extension, "ld__yuji", "qun", 3)
local qianhuan = fk.CreateTriggerSkill{
  name = "qianhuan",
  events = {fk.Damaged, fk.TargetConfirming},
  anim_type = "defensive",
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self.name) or not H.compareKingdomWith(target, player) then return false end
    if event == fk.Damaged then
      return not target.dead and not player:isNude() and #player:getPile("yuji_sorcery") < 4
    else
      return table.contains({Card.TypeBasic, Card.TypeTrick}, data.card.type) and #player:getPile("yuji_sorcery") > 0
    end
  end,
  on_cost = function(self, event, target, player, data)
    local card
    if event == fk.Damaged then
      local suits = {}
      for _, id in ipairs(player:getPile("yuji_sorcery")) do
        table.insert(suits, Fk:getCardById(id):getSuitString())
      end
      suits = table.concat(suits, ",")
      card = player.room:askForCard(player, 1, 1, true, self.name, true, ".|.|^(" .. suits .. ")", "#qianhuan-dmg", "yuji_sorcery")
    else
      card = player.room:askForCard(player, 1, 1, false, self.name, true, ".|.|.|yuji_sorcery", "#qianhuan-def::" .. target.id .. ":" .. data.card:toLogString(), "yuji_sorcery")
    end
    if #card > 0 then
      self.cost_data = card
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:broadcastSkillInvoke("qianhuan")
    if event == fk.Damaged then
      room:notifySkillInvoked(player, "qianhuan", "masochism")
      player:addToPile("yuji_sorcery", self.cost_data, true, self.name)
    else
      room:notifySkillInvoked(player, "qianhuan", "defensive")
      room:moveCardTo(self.cost_data, Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile, self.name, "yuji_sorcery")
      AimGroup:cancelTarget(data, player.id)
    end
  end,
}
yuji:addSkill(qianhuan)
Fk:loadTranslationTable{
  ["ld__yuji"] = "于吉",
  ["qianhuan"] = "千幻",
  [":qianhuan"] = "当一名与你势力相同的角色受到伤害后，你可将一张与你武将牌上花色均不同的牌置于你的武将牌上（称为“幻”）。当一名与你势力相同的角色成为基本牌或锦囊牌的唯一目标时，你可将一张“幻”置入弃牌堆，取消此目标。",

  ["#qianhuan-dmg"] = "千幻：你可一张与“幻”花色均不同的牌置于你的武将牌上（称为“幻”）",
  ["#qianhuan-def"] = "千幻：你可一张“幻”置入弃牌堆，取消%arg的目标 %dest",
  ["yuji_sorcery"] = "幻",

  ["$qianhuan1"] = "幻化于阴阳，藏匿于乾坤。",
  ["$qianhuan2"] = "幻变迷踪，虽飞鸟亦难觅踪迹。",
  ["~ld__yuji"] = "幻化之物，终是算不得真呐。",
}

local hetaihou = General(extension, "ld__hetaihou", "qun", 3, 3, General.Female)
hetaihou:addSkill("zhendu")
hetaihou:addSkill("qiluan")
Fk:loadTranslationTable{
  ["ld__hetaihou"] = "何太后",
}

return extension
