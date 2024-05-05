local H = require "packages/hegemony/util"
local U = require "packages/utility/utility"
local extension = Package:new("work_heg")
extension.extensionName = "hegemony"
extension.game_modes_whitelist = { 'nos_heg_mode', 'new_heg_mode' }

Fk:loadTranslationTable{
  ["work_heg"] = "国战-工作室专属",
  ["wk_heg"] = "日月",
}

local liuye = General(extension, "wk_heg__liuye", "wei", 3)
local poyuan = fk.CreateTriggerSkill{
  name = "wk_heg__poyuan",
  anim_type = "offensive",
  events = {fk.Damage, fk.DamageCaused},
  can_trigger = function (self, event, target, player, data)
    if not (target == player and player:hasSkill(self) and player:isAlive()) then return false end
    if event == fk.Damage then
      return data.to ~= player and not data.to.dead and #data.to:getCardIds("e") > 0
    else
      if not H.isBigKingdomPlayer(data.to) then return false end
      local events = player.room.logic:getActualDamageEvents(1, function(e)
        return e.data[1].from == player and H.isBigKingdomPlayer(e.data[1].to)
      end, Player.HistoryTurn)
      return #events == 0
    end
  end,
  on_cost = function (self, event, target, player, data)
    if event == fk.Damage then
      return player.room:askForSkillInvoke(player, self.name, nil, "#wk_heg__poyuan-discard")
    else
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    if event == fk.Damage then
      local id = room:askForCardChosen(player, data.to, "e", self.name)
      room:throwCard(id, self.name, data.to, player)
    else
      data.damage = data.damage + 1
    end
  end,
}

local choulue = fk.CreateTriggerSkill{
  name = "wk_heg__choulue",
  anim_type = "offensive",
  events = {fk.Damaged, fk.TargetSpecified},
  can_trigger = function (self, event, target, player, data)
    if event == fk.Damaged then
      return player == target and player:hasSkill(self) and player:getMark("@!yinyangfish") < player.maxHp
    else
      return player:hasSkill(self) and H.compareKingdomWith(player, target) and #AimGroup:getAllTargets(data.tos) == 1
        and data.card:isCommonTrick() and player:getMark("@!yinyangfish") ~= 0
    end
  end,
  on_cost = function (self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, nil, event == fk.Damaged and "#wk_heg__choulue-getfish" or "#wk_heg__choulue-twice")
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    if event == fk.Damaged then
      H.addHegMark(room, player, "yinyangfish")
    else
      room:removePlayerMark(player, "@!yinyangfish")
      if player:getMark("@!yinyangfish") == 0 then
        player:loseFakeSkill("yinyangfish_skill&")
      end
      data.additionalEffect = 1
    end
  end,
}

liuye:addSkill(poyuan)
liuye:addSkill(choulue)
Fk:loadTranslationTable{
  ["wk_heg__liuye"] = "刘晔",
  ["#wk_heg__liuye"] = "画策谁迎",
  ["designer:wk_heg__liuye"] = "教父&卧雏",

  ["wk_heg__poyuan"] = "破垣",
  [":wk_heg__poyuan"] = "①当你对其他角色造成伤害后，你可弃置其一张装备区内的牌；②当你于一回合首次对大势力角色造成伤害时，此伤害+1。",
  ["wk_heg__choulue"] = "筹略",
  [":wk_heg__choulue"] = "①当你受到伤害后，若你的“阴阳鱼”标记数小于你体力上限，你可获得一个“阴阳鱼”标记；②当与你势力相同的角色使用普通锦囊牌指定唯一目标后，你可移去一个“阴阳鱼”标记，令此牌结算两次。",

  ["#wk_heg__poyuan-discard"] = "破垣：是否弃置受伤角色装备区内一张牌",
  ["poyuan_discard-hand"] = "令其弃置一张手牌",
  ["poyuan_discard-equip"] = "弃置其一张装备区内的牌",

  ["#wk_heg__choulue-getfish"] = "筹略：是否获得一个“阴阳鱼”标记",
  ["#wk_heg__choulue-twice"] = "筹略：是否移去一个“阴阳鱼”标记，令此牌结算两次",

  ["$wk_heg__poyuan1"] = "砲石飞空，坚垣难存。",
  ["$wk_heg__poyuan2"] = "声若霹雳，人马俱摧。",
  ["$wk_heg__choulue1"] = "筹画所料，无有不中。",
  ["$wk_heg__choulue2"] = "献策破敌，所谋皆应。",
  ["~wk_heg__liuye"] = "功名富贵，到头来，不过黄土一抔…",
}

local dongyun = General(extension, "wk_heg__dongyun", "shu", 3, 3, General.Male)
local yizan = fk.CreateTriggerSkill{
  name = "wk_heg__yizan",
  anim_type = "drawcard",
  events = {fk.EventPhaseStart},
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(self) and player.phase == Player.Discard
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    if event == fk.EventPhaseStart then
      if player.room:askForSkillInvoke(player, self.name, nil, "#wk_heg__yizan-invoke") then
        local targets = table.map(table.filter(room:getOtherPlayers(player), function(p)
          return (p:getHandcardNum() < player:getHandcardNum()) end), function(p) return p.id end)
        if #targets > 0 then
          local to = room:askForChoosePlayers(player, targets, 1, 1, "#wk_heg__yizan-choose", self.name, true)
          self.cost_data = to[1]
          if #to > 0 then
            return true
          end
        end
      end
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(self.cost_data)
    to:drawCards(math.min(player:getHandcardNum() - #to.player_cards[Player.Hand], 5), self.name)
    room:setPlayerMark(player, "wk_heg__yizan-phase", self.cost_data)
  end,
}

local yizan_delay = fk.CreateTriggerSkill{
  name = "#wk_heg__yizan_delay",
  anim_type = "special",
  events = {fk.EventPhaseEnd},
  can_trigger = function (self, event, target, player, data)
    if not (player:hasSkill(self) and player.phase == Player.Discard and player:getMark("wk_heg__yizan-phase") ~= 0) then return false end 
    local logic = player.room.logic
    local x = 0
    logic:getEventsOfScope(GameEvent.MoveCards, 1, function (e)
      for _, move in ipairs(e.data) do
        if move.from == player.id and move.moveReason == fk.ReasonDiscard and move.skillName == "game_rule" then
          x = x + #move.moveInfo
          if x > 1 then return true end
        end
      end
      return false
    end, Player.HistoryTurn)
    return x > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(player:getMark("wk_heg__yizan-phase"))
    local throw_num = #to.player_cards[Player.Hand] - to.maxHp
    if throw_num > 0 then
      room:askForDiscard(to, throw_num, throw_num, false, self.name, false)
    end
  end,
}

local juanshe = fk.CreateTriggerSkill{
  name = "wk_heg__juanshe",
  anim_type = "recover",
  events = {fk.EventPhaseStart},
  can_trigger = function (self, event, target, player, data)
    -- local current = player.room.current
    local events = target.room.logic:getEventsOfScope(GameEvent.UseCard, 999, function(e) 
      local use = e.data[1]
      return use.from == target.id 
    end, Player.HistoryTurn)
    return #events < target:getMaxCards() and H.compareKingdomWith(player, target) 
      and target.phase == Player.Finish and player:hasSkill(self) and not target:isKongcheng()
  end,
  on_cost = function (self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, nil, "#wk_heg__juanshe-invoke")
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    room:askForDiscard(target, 1, 1, false, self.name, false)
    if target:isWounded() then
      room:recover({
        who = target,
        num = 1,
        recoverBy = player,
        skillName = self.name,
      })
    end
    room:setPlayerMark(target, "wk_heg__juanshe", 1)
  end,

  refresh_events = {fk.EventPhaseChanging, fk.BuryVictim, fk.Damaged},
  can_refresh = function(self, event, target, player, data)
    if event == fk.EventPhaseChanging then
      return player.room.current:getMark("wk_heg__juanshe") > 0 and data.from == Player.NotActive
    elseif event == fk.BuryVictim or event == fk.Damaged then
      return player == target and player:hasSkill(self)
    end
  end,
  on_refresh = function(self, event, target, player, data)
    if event == fk.EventPhaseChanging then
      player.room:setPlayerMark(player.room.current, "wk_heg__juanshe", 0)
    elseif event == fk.BuryVictim or event == fk.Damaged then
      for _, p in ipairs(player.room.alive_players) do
        if p:getMark("wk_heg__juanshe") > 0 then
          player.room:setPlayerMark(p, "wk_heg__juanshe", 0)
        end
      end
    end
  end,
}

local juanshe_prohibit = fk.CreateProhibitSkill{
  name = "#wk_heg__juanshe_prohibit",
  prohibit_use = function(self, player, card)
    if player:getMark("wk_heg__juanshe") == 0 then return false end 
    local subcards = Card:getIdList(card)
    return #subcards > 0 and table.every(subcards, function(id)
      return table.contains(player:getCardIds(Player.Hand), id)
    end)
  end,
}

dongyun:addCompanions("ld__jiangwanfeiyi")
yizan:addRelatedSkill(yizan_delay)
juanshe:addRelatedSkill(juanshe_prohibit)
dongyun:addSkill(yizan)
dongyun:addSkill(juanshe)
Fk:loadTranslationTable{
  ["wk_heg__dongyun"] = "董允",
  ["#wk_heg__dongyun"] = "匡主正堂",
  ["designer:wk_heg__dongyun"] = "教父&修功&风箫",

  ["wk_heg__yizan"] = "翼赞",
  [":wk_heg__yizan"] = "弃牌阶段开始时，你可令一名手牌数小于你的角色将手牌摸至与你相同（至多摸五张），然后此阶段结束时，若你于此阶段内弃置过牌，其将手牌弃至体力上限。",
  ["wk_heg__juanshe"] = "蠲奢",
  [":wk_heg__juanshe"] = "与你势力相同角色的结束阶段，若其本回合使用牌数小于其手牌上限，你可令其弃置一张手牌并回复1点体力，然后直至其回合开始或你受到伤害，其不能使用手牌。",

  ["#wk_heg__yizan_delay"] = "翼赞",
  ["#wk_heg__yizan-invoke"] = "翼赞：是否令一名手牌数小于你的角色将手牌摸至与你相同，然后其根据你的弃牌情况执行对应操作。",
  ["#wk_heg__yizan-choose"] = "翼赞：选择一名手牌数小于你的角色，令其将手牌摸至与你相同。",
  ["#wk_heg__juanshe-invoke"] = "蠲奢：是否令当前回合角色弃置一张手牌，然后其回复1点体力。",

  ["$wk_heg__yizan1"] = "公事为重，宴席不去也罢。",
  ["$wk_heg__yizan2"] = "还是改日吧。",

  ["$wk_heg__juanshe1"] = "自古，就是邪不胜正！。",
  ["$wk_heg__juanshe2"] = "主公面前，岂容小人搬弄是非。",

  ["~wk_heg__dongyun"] = "大汉，要亡于宦官之手了...",
}

local luotong = General(extension, "wk_heg__luotong", "wu", 3)
local mingzheng = fk.CreateTriggerSkill{
  name = "wk_heg__mingzheng",
  anim_type = "drawcard",
  events = {fk.GeneralRevealed, fk.EventPhaseStart},
  can_trigger = function (self, event, target, player, data)
    if not (player:hasSkill(self) and H.compareKingdomWith(target, player) and not target.dead) then return false end
    if event == fk.GeneralRevealed then
      return H.getGeneralsRevealedNum(target) == 2
    else
      return target.phase == Player.Play
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    local room = player.room
    if event == fk.EventPhaseStart then
      local targets = table.map(table.filter(room.alive_players, function(p) return H.compareKingdomWith(p, player) and p ~= target end), Util.IdMapper)
      if #targets > 0 then
        local to = room:askForChoosePlayers(target, targets, 1, 1, "#wk_heg__mingzheng-choose", self.name, false)
        local p = room:getPlayerById(to[1])
        room:askForCardsChosen(target, p, 0, 0, {
          card_data = {
            { "$Hand", p:getCardIds(Player.Hand) }
          }
        }, self.name, "wk_heg__mingzheng-hand::"..to[1])
      end
    end
    if event == fk.GeneralRevealed then
      target:reset()
      room:addPlayerMark(target, "@!yinyangfish", 1)
      target:addFakeSkill("yinyangfish_skill&")
      target:prelightSkill("yinyangfish_skill&", true)
    end
  end,
}

local yujian = fk.CreateTriggerSkill{
  name = "wk_heg__yujian",
  anim_type = "control",
  events = {fk.Damage},
  can_trigger = function (self, event, target, player, data)
    if not (player:hasSkill(self) and target ~= player and data.from.phase == Player.Play and H.compareKingdomWith(player, data.to)) then return false end
    local events = player.room.logic:getActualDamageEvents(2, function(e)
      return H.compareKingdomWith(e.data[1].to, player) and data.from == player.room.current and data.from and data.from.phase == Player.Play
    end, Player.HistoryTurn)
    return #events == 1
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local current = room.current
    if target.hp <= player.hp then
      U.swapHandCards(room, player, player, current, self.name)
      room:setPlayerMark(player, "@@wk_heg__yujian_exchange-turn", 1)
    end
    if H.getGeneralsRevealedNum(target) == 2 and room:askForChoice(player, {"wk_heg__yujian_hide::" .. target.id, "Cancel"}, self.name) ~= "Cancel" then
      for _, p in ipairs({target}) do
        local isDeputy = H.doHideGeneral(room, player, p, self.name)
        room:setPlayerMark(p, "@wk_heg__yujian_reveal-turn", H.getActualGeneral(p, isDeputy))
        local record = type(p:getMark(MarkEnum.RevealProhibited .. "-turn")) == "table" and p:getMark(MarkEnum.RevealProhibited .. "-turn") or {}
        table.insert(record, isDeputy and "d" or "m")
        room:setPlayerMark(p, MarkEnum.RevealProhibited .. "-turn", record)
      end
    end
  end,
}

local yujian_delay = fk.CreateTriggerSkill{
  name = "#wk_heg__yujian_delay",
  anim_type = "special",
  events = {fk.TurnEnd},
  can_trigger = function (self, event, target, player, data)
    return player:getMark("@@wk_heg__yujian_exchange-turn") > 0 and not player.dead and not player.room.current.deat
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local current = room.current
    U.swapHandCards(room, player, player, current, self.name)
  end
}

yujian:addRelatedSkill(yujian_delay)
luotong:addSkill(mingzheng)
luotong:addSkill(yujian)
Fk:loadTranslationTable{
  ["wk_heg__luotong"] = "骆统",
  ["#wk_heg__luotong"] = "达弼政辅",
  ["designer:wk_heg__luotong"] = "教父",

  ["wk_heg__mingzheng"] = "明政",
  [":wk_heg__mingzheng"] = "与你势力相同的角色：1.明置武将牌后，若其武将牌均明置，其复原武将牌，然后获得一个“阴阳鱼”标记; 2.出牌阶段开始时，其观看除其外一名与你势力相同的角色的手牌。",
  ["wk_heg__yujian"] = "御谏",
  [":wk_heg__yujian"] = "其他角色于其出牌阶段内首次对与你势力相同的角色造成伤害后，你可依次执行每个满足条件的项：1.若其体力值不大于你，你可以与其交换手牌，若如此做，此回合结束时，你与其交换手牌；"..
  "2.若其武将牌均明置，你可以暗置其一张武将牌且直至本回合结束不能明置之。",

  ["#wk_heg__mingzheng-choose"] = "明政：选择一名与你势力相同的其他角色观看手牌",
  ["wk_heg__mingzheng-hand"] = "明政：观看%dest的手牌",
  ["wk_heg__yujian_hide"] = "暗置%dest一张武将牌且本回合不能明置",

  ["#wk_heg__yujian_delay"] = "御谏",
  ["@@wk_heg__yujian_exchange-turn"] = "御谏 交换手牌",

  ["#wk_heg__yujian-invoke"] = "御谏：你可根据条件与当前回合角色交换手牌或暗置当前回合角色武将牌",
  ["@wk_heg__yujian_reveal-turn"] = "御谏 禁亮",

  ["$wk_heg__mingzheng1"] = "仁政如水，可润万物",
  ["$wk_heg__mingzheng2"] = "为官一任，当造福一方",
  ["$wk_heg__yujian1"] = "臣代天子牧民，闻苛自当谏之。",
  ["$wk_heg__yujian2"] = "为将者死战，为臣者死谏。",
  ["~wk_heg__luotong"] = "而立之年，奈何早逝。",
}

local jvshou = General(extension, "wk_heg__jvshou", "qun", 3)

local tugui = fk.CreateTriggerSkill{
  name = "wk_heg__tugui",
  anim_type = "defensive",
  events = {fk.AfterCardsMove, fk.EnterDying, fk.EventPhaseEnd},
  can_trigger = function (self, event, target, player, data)
    local ret = false
    if event == fk.AfterCardsMove then
      if not player:hasSkill(self) or not player:isKongcheng() then return end
      for _, move in ipairs(data) do
        if move.from == player.id then
          for _, info in ipairs(move.moveInfo) do
            if info.fromArea == Card.PlayerHand and player:usedSkillTimes(self.name, Player.HistoryTurn) == 0 then
              ret = true
              break
            end
          end
        end
      end
      if ret then
        return table.find(player.room.alive_players, function(p) return player:distanceTo(p) == 1 and not p:isKongcheng() end)
      end
    elseif event == fk.EnterDying then
      if player == target and player:hasSkill(self) and player:usedSkillTimes(self.name, Player.HistoryTurn) == 0 then
        ret = true
      end
      if ret then
        return table.find(player.room.alive_players, function(p) return player:distanceTo(p) == 1 and not p:isKongcheng() end)
      end
    else
      return player:hasSkill(self) and player == target and player.phase == Player.Play and player:getMark("wk_heg__tugui") ~= 0 
    end
  end,
  on_cost = function (self, event, target, player, data)
    if event == fk.AfterCardsMove or event == fk.EnterDying then
      return player.room:askForSkillInvoke(player, self.name, nil, "#wk_heg__tugui-ask")
    else
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.AfterCardsMove or event == fk.EnterDying then
      local targets = table.map(table.filter(room.alive_players, function(p) return player:distanceTo(p) == 1 and not p:isKongcheng() end), Util.IdMapper)
      if #targets > 0 then
        local to = room:askForChoosePlayers(player, targets, 1, 1, "#wk_heg__tugui-choose", self.name, false)
        local card = room:askForCardChosen(player, room:getPlayerById(to[1]), "h", self.name)
        room:obtainCard(player.id, card, false, fk.ReasonPrey)
        player:showCards(card)
        local mark = U.getMark(player, "wk_heg__tugui")
        table.insert(mark, {player.id, card})
        room:setPlayerMark(player, "wk_heg__tugui", mark)
      end
    else
      for _, t in ipairs(player:getMark("wk_heg__tugui")) do
        local p = player.room:getPlayerById(t[1])
        if p and table.contains(p:getCardIds("he"), t[2]) then
          H.removeGeneral(room, player, player.deputyGeneral == "wk_heg__jvshou")
          break
        end
      end
      room:setPlayerMark(player, "wk_heg__tugui", 0)
    end
  end,
}

local yingshou = fk.CreateTriggerSkill{
  name = "wk_heg__yingshou",
  anim_type = "drawcard",
  events = {fk.EventPhaseStart},
  can_trigger = function (self, event, target, player, data)
    return player == target and player.phase == Player.Finish and player:hasSkill(self)
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local targets = table.map(table.filter(room.alive_players, function(p) return H.compareKingdomWith(player, p) end), Util.IdMapper)
    local tos = room:askForChoosePlayers(player, targets, 1, 1, "#wk_heg__yingshou-choose")
    if #tos > 0 then
      local to = room:getPlayerById(tos[1])
      to:drawCards(2, self.name)
      room:setPlayerMark(to, "@@wk_heg__yingshou", 1)
    end
  end,
}

local yingshou_delay = fk.CreateTriggerSkill{
  name = "#wk_heg__yingshou_delay",
  anim_type = "special",
  events = {fk.Damage},
  can_trigger = function (self, event, target, player, data)
    return data.from:getMark("@@wk_heg__yingshou") > 0 and not data.from:isNude() and data.from.phase == Player.Play and player:hasSkill(self)
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    player.room:askForDiscard(data.from, 1, 1, true, self.name, false)
  end,

  refresh_events = {fk.EventPhaseEnd},
  can_refresh = function (self, event, target, player, data)
    return target:getMark("@@wk_heg__yingshou") > 0 and target.phase == Player.Play
  end,
  on_refresh = function (self, event, target, player, data)
    player.room:setPlayerMark(target, "@@wk_heg__yingshou", 0)
  end,
}

yingshou:addRelatedSkill(yingshou_delay)
jvshou:addSkill(tugui)
jvshou:addSkill(yingshou)

Fk:loadTranslationTable{
  ["wk_heg__jvshou"] = "沮授",
  ["#wk_heg__jvshou"] = "志北挽魂",
  ["designer:wk_heg__jvshou"] = "教父&小曹神",

  ["wk_heg__tugui"] = "图归",
  [":wk_heg__tugui"] = "①每回合限一次，当你失去最后的手牌后或当你进入濒死状态后，你可获得与你距离为1的其他角色的一张手牌并展示之；②出牌阶段结束时，若你未失去以此法获得的所有牌，你移除此武将牌。",
  ["wk_heg__yingshou"] = "营守",
  [":wk_heg__yingshou"] = "结束阶段，你可令一名与你势力相同的角色摸两张牌，若如此做，当其于下个出牌阶段内造成伤害后，其弃置一张牌。",

  ["#wk_heg__tugui-ask"] = "图归：是否获得与你距离为1的其他角色的一张手牌",
  ["#wk_heg__tugui-choose"] = "图归：选择一名与你距离为1的其他角色",

  ["#wk_heg__yingshou_delay"] = "营守",
  ["#wk_heg__yingshou-choose"] = "营守：选择一名与你势力相同的角色",
  ["@@wk_heg__yingshou"] = "营守",

  ["$wk_heg__tugui1"] = "矢志于北，尽忠于国。",
  ["$wk_heg__tugui2"] = "命系袁氏，一心向北。",
  ["$wk_heg__yingshou1"] = "由缓至急，循循而进。",
  ["$wk_heg__yingshou2"] = "事须缓图，欲速不达也。",
  ["~wk_heg__jvshou"] = "身处河南，魂归河北...",
}

--- 推举
---@param room Room
---@param player ServerPlayer
---@param skillName string
---@return ServerPlayer?
local function DoElectedChange(room, player, skillName)
  local kingdom = player:getMark("__heg_kingdom")
  if kingdom == "wild" then
    kingdom = player:getMark("__heg_init_kingdom")
  end
  local generals = room:findGenerals(function(g)
    return Fk.generals[g].kingdom == player.kingdom
  end, 1)
  local general = room:askForGeneral(player, generals, 1, true) ---@type string
  room:sendLog{
    type = "#ElectedChangeLog",
    from = player.id,
    arg = general,
    arg2 = skillName,
    toast = true,
  }
  local targets = table.map(table.filter(room.alive_players, function(p) return H.compareKingdomWith(p, player) end), Util.IdMapper)
  room:sortPlayersByAction(targets)
  local ret
  for _, pid in ipairs(targets) do
    local p = room:getPlayerById(pid)
    local choices = {"Cancel"}
    if p.general ~= "anjiang" and not p.general:startsWith("ld__lord") and not general.subkingdom then
      table.insert(choices, "#elected_change_main:::" .. general)
    end
    if p.deputyGeneral ~= "anjiang" then
      table.insert(choices, "#elected_change_deputy:::" .. general)
    end
    local choice = room:askForChoice(p, choices, "ElectedChange", "#elected_change-ask:" .. player.id .. "::" .. general)
    if choice ~= "Cancel" then
      if choice:startsWith("#elected_change_main") then
        generals = {H.getActualGeneral(p, false)}
        room:changeHero(p, general, false, false, true, false, false)
      else
        generals = {H.getActualGeneral(p, true)}
        room:changeHero(p, general, false, true, true, false, false)
      end
      ret = p
      break
    end
  end
  room:returnToGeneralPile(generals)
  return {ret, general}
end

Fk:loadTranslationTable{
  ["ElectedChange"] = "推举",
  ["#Elected"] = "推举了",
  ["#ElectedChangeLog"] = "%from 由于 “%arg2”，推举了 %arg",
  ["#elected_change_main"] = "选用：将%arg作为主将",
  ["#elected_change_deputy"] = "选用：将%arg作为副将",
  ["#elected_change-ask"] = "%src 推举了 %arg，你可 选用 为你的主将或副将",
}

local chenqun = General(extension, "wk_heg__chenqun", "wei", 3)
local dingpin = fk.CreateTriggerSkill{
  name = "wk_heg__dingpin",
  anim_type = "support",
  events = {fk.EventPhaseStart},
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(self) and player == target and not player.chained and player.phase == Player.Finish
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local targets = table.map(table.filter(room.alive_players, function(p) return H.compareKingdomWith(p, player) end), Util.IdMapper)
    local to = room:askForChoosePlayers(player, targets, 1, 1, "#wk_heg__dingpin-choose", self.name, true)
    if #to > 0 then
      self.cost_data = to[1]
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    player:setChainState(true)
    local to = room:getPlayerById(self.cost_data)
    if not to.chained then
      to:setChainState(true)
    end
    room:setPlayerMark(to, "_wk_heg__dingpin", player.id)
    to:gainAnExtraTurn(true, self.name)
  end,
}
local dingpin_delay = fk.CreateTriggerSkill{
  name = "#wk_heg__dingpin_delay",
  events = {fk.EventPhaseStart, fk.TurnEnd, fk.EventPhaseChanging},
  anim_type = "special",
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if event == fk.EventPhaseStart then
      return (target.phase == Player.Play and target:getCurrentExtraTurnReason() == "wk_heg__dingpin" and target:getMark("_wk_heg__dingpin") == player.id and H.compareKingdomWith(player, target))
    else
      return target == player and target:getCurrentExtraTurnReason() == "wk_heg__dingpin"
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.EventPhaseStart then
      room:notifySkillInvoked(player, self.name, "support")
      player:broadcastSkillInvoke(self.name)
      local p_table = DoElectedChange(room, target, self.name)
    elseif event == fk.TurnEnd then
      if target:getHandcardNum() > target.maxHp then
        room:askForDiscard(target, target:getHandcardNum() - target.hp, target:getHandcardNum() - target.hp, false, self.name, false)
      end
      if target:getHandcardNum() < target.maxHp then
        target:drawCards(target.hp - target:getHandcardNum(), self.name)
      end
      room:setPlayerMark(target, "_wk_heg__dingpin", 0)
      target:turnOver()
    else
      local excludePhases = { Player.Start, Player.Judge, Player.Draw, Player.Discard, Player.Finish }
      for _, phase in ipairs(excludePhases) do
        table.removeOne(player.phases, phase)
      end
    end
  end,
}
dingpin:addRelatedSkill(dingpin_delay)

local faen = fk.CreateTriggerSkill{
  name = "wk_heg__faen",
  anim_type = "offensive",
  events = {fk.TurnedOver, fk.ChainStateChanged},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and ((event == fk.TurnedOver and not target.faceup) or (event == fk.ChainStateChanged and target.chained)) and H.compareKingdomWith(player, target)
  end,
  on_cost = function(self, event, target, player, data)
    if event == fk.TurnedOver then
      return player.room:askForSkillInvoke(player, self.name, nil, "#wk_heg__faen_turn-invoke")
    else
      return player.room:askForSkillInvoke(target, self.name, nil, "#wk_heg__faen_chained-invoke")
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.TurnedOver then
      room:askForDiscard(target, 2, 2, true, self.name, false)
      target:turnOver()
    else
      local card = room:askForCard(target, 1, 1, true, self.name, true)
      room:recastCard(card, target, self.name)
    end
  end,
}
chenqun:addSkill(dingpin)
chenqun:addSkill(faen)

chenqun:addCompanions("hs__caopi")
chenqun:addCompanions("hs__simayi")
Fk:loadTranslationTable{
  ["wk_heg__chenqun"] = "陈群",
  ["designer:wk_heg__chenqun"] = "教父&635",

  ["wk_heg__dingpin"] = "定品",
  [":wk_heg__dingpin"] = "结束阶段，你可横置你与一名与你势力相同的角色，令其于此回合结束后执行一个仅有出牌阶段的额外回合，此额外回合：1.出牌阶段开始时，其推举；2.回合结束时，其将手牌数摸或弃至体力值，然后叠置。<br />" ..
  "<font color = 'gray'>推举：推举角色展示一张与其势力相同的武将牌，每名与其势力相同的角色选择是否将此武将牌作为其新的主将或副将。" ..
  "若有角色选择是，称为该角色<u>选用</u>，停止对后续角色的询问，结束推举流程。</font>",
  ["wk_heg__faen"] = "法恩",
  [":wk_heg__faen"] = "与你势力相同的角色：1.横置后，其可重铸一张牌；2.叠置后，你可令其弃置两张牌，然后其平置。",

  ["@@wk_heg__dingpin_extra"] = "定品",
  ["#wk_heg__dingpin-choose"] = "定品：你可以选择一名与你势力相同的角色，横置你与其，令其于此回合结束后执行一个仅有出牌阶段的额外的回合",
  ["#wk_heg__dingpin_delay"] = "定品",

  ["#wk_heg__faen_turn-invoke"] = "法恩：是否令其弃置两张牌，然后其平置",
  ["#wk_heg__faen_chained-invoke"] = "法恩：是否重铸一张牌",

  ["$wk_heg__dingpin1"] = "取才赋职，论能行赏。",
  ["$wk_heg__dingpin2"] = "定品寻良骥，中正探人杰。",
  ["$wk_heg__faen1"] = "礼法容情，皇恩浩荡。",
  ["$wk_heg__faen2"] = "法理有度，恩威并施。",
  ["~wk_heg__chenqun"] = "吾身虽陨，典律昭彰。",
}

local xujing = General(extension, "wk_heg__xujing", "shu", 3, 3, General.Male)
local yuyan = fk.CreateTriggerSkill{
  name = "wk_heg__yuyan",
  anim_type = "support",
  events = {fk.AfterCardsMove},
  can_trigger = function (self, event, target, player, data)
    if not player:hasSkill(self) or player.room.current == player then return end
    local n = 0
    for _, move in ipairs(data) do
      if move.to and move.to == player.id and move.from and move.from ~= player.id then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip then
            n = n + 1
          end
        end
      end
    end
    if n > 0 then
      self.cost_data = n
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local current = room.current
    local n = self.cost_data
    local cards2
    if #player:getCardIds("he") <= n then
      cards2 = player:getCardIds("he")
    else
      cards2 = room:askForCard(player, n, n, true, self.name, false, ".",
        "#wk_heg__yuyan-give::"..current.id..":"..n)
    end
    room:moveCardTo(cards2, Card.PlayerHand, current, fk.ReasonGive, self.name, nil, false, player.id)
  end,
}

local caixia_filter = fk.CreateActiveSkill{
  name = "#wk_heg__caixia_filter",
  min_card_num = 1,
  max_card_num = 99,
  visible = false,
  card_filter = function(self, to_select, selected)
    return table.every(selected, function(id)
      return Fk:getCardById(to_select).trueName == Fk:getCardById(id).trueName 
    end) and Fk:currentRoom():getCardArea(to_select) == Player.Hand
  end,
  target_filter = Util.FalseFunc,
  can_use = Util.FalseFunc,
}
local caixia = fk.CreateTriggerSkill{
  name = "wk_heg__caixia",
  anim_type = "defensive",
  events = {fk.Damaged, fk.Damage},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and player == target and not player:isKongcheng() and player:usedSkillTimes(self.name, Player.HistoryTurn) == 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local result, dat = room:askForUseActiveSkill(player, "#wk_heg__caixia_filter", "#wk_heg__caixia", true)
    if result then
      self.cost_data = dat.cards
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    player:showCards(self.cost_data)
    player:drawCards(math.min(#self.cost_data, player.hp), self.name)
  end,
}
local yuyan_delay = fk.CreateTriggerSkill{
  name = "#wk_heg__yuyan_delay",
  events = {fk.TurnEnd},
  anim_type = "special",
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return player:usedSkillTimes(yuyan.name, Player.HistoryTurn) > 0 and H.compareKingdomWith(player, player.room.current)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    if player.hp < player.maxHp then
      player.room:recover{
        who = player,
        num = 1,
        recoverBy = player,
        skillName = self.name,
      }
    else
      local p_table = DoElectedChange(player.room, target, self.name)
    end
  end,
}

yuyan:addRelatedSkill(yuyan_delay)
xujing:addSkill(yuyan)
caixia:addRelatedSkill(caixia_filter)
xujing:addSkill(caixia)
xujing:addCompanions("ld__fazheng")
Fk:loadTranslationTable{
  ["wk_heg__xujing"] = "许靖",
  ["#wk_heg__xujing"] = "尺瑜寸瑕",
  ["designer:wk_heg__xujing"] = "教父&635&二四",

  ["wk_heg__yuyan"] = "誉言",
  [":wk_heg__yuyan"] = "①你是与你势力相同且手牌数大于你角色“合纵”的合法目标；②当你于回合外获得其他角色的牌后，你可将等量张牌交给当前回合角色，若如此做，此回合结束时，若其与你势力相同，你推举，若你已受伤，则改为回复1点体力。<br />"..
    "<font color = 'gray'>推举：推举角色展示一张与其势力相同的武将牌，每名与其势力相同的角色选择是否将此武将牌作为其新的主将或副将。" ..
  "若有角色选择是，称为该角色<u>选用</u>，停止对后续角色的询问，结束推举流程。</font>",
  ["wk_heg__caixia"] = "才瑕",
  [":wk_heg__caixia"] = "每回合限一次，当你造成或受到伤害后，你可展示任意张同名手牌，然后摸等量的牌（至多摸你体力值张）。",

  ["#wk_heg__yuyan-give"] = "誉言：交给 %dest 共计 %arg 张牌",
  ["#wk_heg__yuyan_delay"] = "誉言",
  ["#wk_heg__caixia_filter"] = "才瑕",
  ["#wk_heg__caixia"] = "才瑕：你可以展示任意张同名手牌，然后摸等量的牌。",

  ["$wk_heg__yuyan1"] = "君满腹才学，当为国之大器。",
  ["$wk_heg__yuyan2"] = "一腔青云之志，正待梦日之时。",
  ["$wk_heg__caixia1"] = "吾习扫天下之术，不善净一屋之秽。",
  ["$wk_heg__caixia2"] = "玉有十色五光，微瑕难掩其瑜。",
  ["~wk_heg__xujing"] = "时人如江鲫，所逐者功利尔...",
}

local buzhi = General(extension, "wk_heg__buzhi", "wu", 4)
buzhi.deputyMaxHpAdjustedValue = -1
local hongde = fk.CreateTriggerSkill{
  name = "wk_heg__hongde",
  anim_type = "drawcard",
  events = {fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) and #player:getCardIds("he") > 0 and player:usedSkillTimes(self.name, Player.HistoryTurn) == 0 then
      for _, move in ipairs(data) do
        if #move.moveInfo > 1 and ((move.from == player.id and move.to ~= player.id) or
          (move.to == player.id and move.toArea == Card.PlayerHand)) then
          return true
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local targets = table.map(room:getOtherPlayers(player), Util.IdMapper)
    local tos, id = room:askForChooseCardAndPlayers(player, targets, 1, 1, ".", "#wk_heg__hongde-give", self.name, false)
    room:obtainCard(tos[1], id, false, fk.ReasonGive)
    if not player.dead then
      player:drawCards(1, self.name)
    end
  end,
}

local shucai = fk.CreateTriggerSkill{
  name = "wk_heg__shucai",
  relate_to_place = 'd',
  anim_type = "support",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and target == player and player.phase == Player.Finish and #player:getCardIds("e") > 0 and
      table.find(player.room.alive_players, function(p) return player:canMoveCardsInBoardTo(p, "e") end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.map(table.filter(room.alive_players, function (p)
      return player:canMoveCardsInBoardTo(p, "e")
    end), Util.IdMapper)
    targets = room:askForChoosePlayers(player, targets, 1, 1, "#wk_heg__shucai-ask", self.name, true)
    if #targets > 0 then
      self.cost_data = targets[1]
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    target = room:getPlayerById(self.cost_data)
    room:askForMoveCardInBoard(player, player, target, self.name, "e", player)
    if player.dead or target.dead then return end
    local p_table = DoElectedChange(room, player, self.name)
    if not player.dead then
      room:setPlayerMark(player, "wk_heg__dingpan_notagged", 1)
      room:handleAddLoseSkills(player, "-wk_heg__shucai|wk_heg__shucai_notag|wk_heg__dingpan_notag", nil)
    end
  end,
}
local dingpan = fk.CreateActiveSkill{
  name = "wk_heg__dingpan",
  relate_to_place = 'm',
  anim_type = "offensive",
  can_use = function(self, player)
    local room = Fk:currentRoom()
    local n = 0
    for _, p in ipairs(room.alive_players) do
      if p.kingdom == "wild" then
        n = n + 1
      end
    end
    return player:usedSkillTimes(self.name, Player.HistoryPhase) < n + 1
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, to_select, selected)
    return #selected == 0 and to_select ~= Self.id and
      (not H.compareKingdomWith(Fk:currentRoom():getPlayerById(to_select), Self))
  end,
  target_num = 1,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    target:drawCards(1, self.name)
    local n = target:getAttackRange()
    local choices = {"wk_heg__dingpan_use:"..effect.from}
    if n <= #target:getCardIds("he") then
      table.insert(choices, "#wk_heg__dingpan_give:::"..n)
    end
    local choice = room:askForChoice(target, choices, self.name)
    if choice:startsWith("wk_heg__dingpan_use") then
      room:useVirtualCard("slash", nil, player, target, self.name, true)
    else
      local cards = room:askForCardsChosen(target, target, n, n, "he", self.name)
      room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonGive, self.name, nil, false, player.id)
    end
  end,
}

local shucai_notag = fk.CreateTriggerSkill{
  name = "wk_heg__shucai_notag",
  anim_type = "support",
  events = {fk.EventPhaseStart},
  main_skill = shucai, -- 绷
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and target == player and player.phase == Player.Finish and #player:getCardIds("e") > 0 and
      table.find(player.room.alive_players, function(p) return player:canMoveCardsInBoardTo(p, "e") end) and player:usedSkillTimes(self.main_skill.name, Player.HistoryPhase) == 0 -- 假装是一个技能
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.map(table.filter(room.alive_players, function (p)
      return player:canMoveCardsInBoardTo(p, "e")
    end), Util.IdMapper)
    targets = room:askForChoosePlayers(player, targets, 1, 1, "#wk_heg__shucai-ask", self.name, true)
    if #targets > 0 then
      self.cost_data = targets[1]
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    target = room:getPlayerById(self.cost_data)
    room:askForMoveCardInBoard(player, player, target, self.name, "e", player)
    if player.dead or target.dead then return end
    DoElectedChange(room, player, self.name)
  end,
}
local shucai_retag = fk.CreateTriggerSkill{
  name = "#wk_heg__shucai_retag",
  events = {fk.EnterDying},
  mute = true,
  can_trigger = function (self, event, target, player, data)
    return player == target and player:getMark("wk_heg__dingpan_notagged") > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    player.room:handleAddLoseSkills(player, "-wk_heg__shucai_notag|-wk_heg__dingpan_notag|wk_heg__shucai", nil)
  end,
}
shucai_notag:addRelatedSkill(shucai_retag)
local dingpan_notag = fk.CreateActiveSkill{
  name = "wk_heg__dingpan_notag",
  anim_type = "offensive",
  main_skill = dingpan,
  can_use = function(self, player)
    local room = Fk:currentRoom()
    local n = 0
    for _, p in ipairs(room.alive_players) do
      if p.kingdom == "wild" then
        n = n + 1
      end
    end
    return player:usedSkillTimes(self.main_skill.name, Player.HistoryPhase) < n + 1 -- 绷
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, to_select, selected)
    return #selected == 0 and to_select ~= Self.id and
      (not H.compareKingdomWith(Fk:currentRoom():getPlayerById(to_select), Self))
  end,
  target_num = 1,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    target:drawCards(1, self.name)
    local n = target:getAttackRange()
    local choices = {"wk_heg__dingpan_use:"..effect.from}
    if n <= #target:getCardIds("he") then
      table.insert(choices, "#wk_heg__dingpan_give:::"..n)
    end
    local choice = room:askForChoice(target, choices, self.name)
    if choice:startsWith("wk_heg__dingpan_use") then
      room:useVirtualCard("slash", nil, player, target, self.name, true)
    else
      local cards = room:askForCardsChosen(target, target, n, n, "he", self.name)
      room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonGive, self.name, nil, false, player.id)
    end
  end,
}

buzhi:addSkill(hongde)
buzhi:addSkill(shucai)
buzhi:addSkill(dingpan)
Fk:addSkill(shucai_notag)
Fk:addSkill(dingpan_notag)
Fk:loadTranslationTable{
  ["wk_heg__buzhi"] = "步骘",
  ["#wk_heg__buzhi"] = "博研沈深",
  ["designer:wk_heg__buzhi"] = "教父&风箫",

  ["wk_heg__hongde"] = "弘德",
  [":wk_heg__hongde"] = "每回合限一次，当你一次性获得或失去两张牌后，你可交给一名其他角色一张牌，然后摸一张牌。",
  ["wk_heg__dingpan"] = "定叛",
  [":wk_heg__dingpan"] = "主将技，出牌阶段限X次，你可令一名其他势力角色摸一张牌，然后其选择：1.交给你其攻击范围数张牌；2.你视为对其使用一张【杀】（X为野心家角色数+1）。",
  ["wk_heg__shucai"] = "疏才",
  [":wk_heg__shucai"] = "副将技，此武将牌上单独的阴阳鱼个数-1；结束阶段，你可将你装备区内一张牌移动至其他角色装备区内，然后推举并删除此武将牌所有技能标签至你进入濒死状态。<br />"..
  "<font color = 'gray'>推举：推举角色展示一张与其势力相同的武将牌，每名与其势力相同的角色选择是否将此武将牌作为其新的主将或副将。" ..
  "若有角色选择是，称为该角色<u>选用</u>，停止对后续角色的询问，结束推举流程。</font>",

  ["#wk_heg__hongde-give"] = "弘德：选择一名其他角色，交给其一张牌",
  ["#wk_heg__shucai-ask"] = "疏才：你可选择一名其他角色，将装备区内一张牌移动至其装备区内",
  ["wk_heg__dingpan_use"] = "视为%src对你使用【杀】",
  ["#wk_heg__dingpan_give"] = "交出%arg张牌",
  ["#wk_heg__shucai_retag"] = "疏才",

  ["wk_heg__dingpan_notag"] = "定叛",
  [":wk_heg__dingpan_notag"] = "出牌阶段限X次，你可令一名其他势力角色摸一张牌，然后其选择：1.交给你其攻击范围数张牌；2.你视为对其使用一张【杀】（X为野心家角色数+1）。",
  ["wk_heg__shucai_notag"] = "疏才",
  [":wk_heg__shucai_notag"] = "结束阶段，你可将你装备区内一张牌移动至其他角色装备区内，然后推举，若未被选用，你删除此武将牌所有技能标签。<br />"..
  "<font color = 'gray'>推举：推举角色展示一张与其势力相同的武将牌，每名与其势力相同的角色选择是否将此武将牌作为其新的主将或副将。" ..
  "若有角色选择是，称为该角色<u>选用</u>，停止对后续角色的询问，结束推举流程。</font>",

  ["$wk_heg__hongde1"] = "江南重义，东吴尚德。",
  ["$wk_heg__hongde2"] = "德无单行，福必双至。",
  ["$wk_heg__dingpan1"] = "从孙者生，从刘者死！",
  ["$wk_heg__dingpan2"] = "多行不义必自毙！",
  ["$wk_heg__shucai1"] = "督军之才，子明强于我甚多。",
  ["$wk_heg__shucai2"] = "此间重任，公卿可担之。",
  ["~wk_heg__buzhi"] = "交州已定，主公尽可放心。",
}

local huanfan = General(extension, "wk_heg__huanfan", "wei", 3, 3, General.Male)
local liance_viewas = fk.CreateViewAsSkill{
  name = "#wk_heg__liance_viewas",
  interaction = function()
    local names = {}
    local mark = Self:getMark("wk_heg__liance-phase")
    for _, id in ipairs(Fk:getAllCardIds()) do
      local card = Fk:getCardById(id, true)
      if table.contains(mark, card.name) then
        table.insertIfNeed(names, card.name)
      end
    end
    return UI.ComboBox {choices = names}
  end,
  card_filter = Util.FalseFunc,
  view_as = function(self, cards)
    if not self.interaction.data then return end
    local card = Fk:cloneCard(self.interaction.data)
    return card
  end,
}
local liance = fk.CreateTriggerSkill{
  name = "wk_heg__liance",
  anim_type = "offensive",
  events = {fk.EventPhaseEnd},
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self) or not target.phase == Player.Play or player == target or player:isNude() then return false end
    local usedCardNames = {}     
    local events = player.room.logic:getEventsOfScope(GameEvent.UseCard, 998, function(e) 
      local use = e.data[1]
      if table.contains(usedCardNames, e.data[1].card.name) then
        return use.from == target.id and (use.card.type == Card.TypeTrick or use.card.type == Card.TypeBasic)
      else
        table.insertIfNeed(usedCardNames, e.data[1].card.name)
        return false
      end
    end, Player.HistoryPhase)
    if #events > 0 then
      local usedCardTwice = {}
      table.forEach(events, function(e)
        table.insertIfNeed(usedCardTwice, e.data[1].card.name)
      end)
      self.cost_data = usedCardTwice
      return #usedCardTwice > 0
    end
  end,
  on_cost = function(self, event, target, player, data)
    local cards = player.room:askForDiscard(player, 1, 1, true, self.name, true, ".", "#wk_heg__liance-invoke::"..target.id, true)
    if #cards == 1 then
      self.cost_data = cards
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:throwCard(self.cost_data, self.name, player, player)
    room:setPlayerMark(target, "wk_heg__liance-phase", self.cost_data)
    local success, dat = player.room:askForUseActiveSkill(target, "#wk_heg__liance_viewas", "#wk_heg__liance-choose", true)
    if not success then
      H.askCommandTo(player, target, self.name, true)
    else
      local card = Fk.skills["#wk_heg__liance_viewas"]:viewAs(self.cost_data.cards)
        room:useCard{
        from = target.id,
        tos = table.map(dat.targets, function(id) return {id} end),
        card = card,
      }
    end
  end,
}

local shilun_active = fk.CreateActiveSkill{
  name = "#wk_heg__shilun_active",
  can_use = Util.FalseFunc,
  target_num = 0,
  card_num = function()
    local cards = Self.player_cards[Player.Hand]
    local suits = {}
    for _, id in ipairs(cards) do
      local suit = Fk:getCardById(id).suit
      if suit ~= Card.NoSuit then
        if not table.contains(suits, suit) then
          table.insert(suits, suit)
        end
      end
    end
    return #suits
  end,
  card_filter = function(self, to_select, selected)
    if Fk:currentRoom():getCardArea(to_select) == Player.Equip then return end
    return table.every(selected, function (id) return Fk:getCardById(to_select).suit ~= Fk:getCardById(id).suit end)
  end,
}

local shilun = fk.CreateTriggerSkill{
  name = "wk_heg__shilun",
  events = {fk.Damaged},
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return player == target and player:hasSkill(self) and not player:isKongcheng()
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local cards = player.player_cards[Player.Hand]
    player:showCards(cards)
    local _, ret = room:askForUseActiveSkill(player, "#wk_heg__shilun_active", "#wk_heg__shilun_active-choose", false)
    local to_remain
    if ret then
      to_remain = ret.cards
    end
    local cards = table.filter(player:getCardIds{Player.Hand}, function (id)
      return not (table.contains(to_remain, id) or player:prohibitDiscard(Fk:getCardById(id)))
    end)
    if #cards > 0 then
      room:throwCard(cards, self.name, player)
    end
    local cards = player.player_cards[Player.Hand]
    if #cards == 4 then
      if #room:canMoveCardInBoard() > 0 then
        local targets = room:askForChooseToMoveCardInBoard(player, "#wk_heg__shilun-move", self.name, true, nil)
        if #targets ~= 0 then
          targets = table.map(targets, function(id) return room:getPlayerById(id) end)
          room:askForMoveCardInBoard(player, targets[1], targets[2], self.name)
        end
      end
    else
      local suits = {Card.Spade, Card.Heart, Card.Diamond, Card.Club}
      for _, id in ipairs(cards) do
        local suit = Fk:getCardById(id).suit
        if suit ~= Card.NoSuit then
          table.removeOne(suits, suit)
        end
      end
      local patternTable = { ["heart"] = {}, ["diamond"] = {}, ["spade"] = {}, ["club"] = {} }
      for _, id in ipairs(room.draw_pile) do
        local card = Fk:getCardById(id)
        if table.contains(suits, card.suit) then
          table.insert(patternTable[card:getSuitString()], id)
        end
      end
      local get = {}
      for _, ids in pairs(patternTable) do
        if #ids > 0 then
          table.insert(get, table.random(ids))
        end
      end
      if #get > 0 then
        room:obtainCard(player, get, false, fk.ReasonPrey)
      end
    end
  end,
}

huanfan:addSkill(liance)
huanfan:addSkill(shilun)
Fk:addSkill(liance_viewas)
Fk:addSkill(shilun_active)
Fk:loadTranslationTable{
  ["wk_heg__huanfan"] = "桓范",
  ["#wk_heg__huanfan"] = "雍国立世",
  ["designer:wk_heg__huanfan"] = "教父",

  ["wk_heg__liance"] = "连策",
  [":wk_heg__liance"] = "其他角色的出牌阶段结束时，若其于此阶段内使用过同名牌，你可弃置一张牌，令其选择是否视为使用此回合内其使用过的其中一张同名牌，若其未以此法使用牌，你对其发起强制执行的“军令”。",
  ["wk_heg__shilun"] = "世论",
  [":wk_heg__shilun"] = "当你受到伤害后，你可展示所有手牌并弃至每种花色各一张，然后若你的手牌：包含四种花色，你可移动场上一张牌；不包含四种花色，你从牌堆中检索并获得手牌中没有的花色牌各一张。",

  ["#wk_heg__liance-invoke"] = "连策：你可以弃置一张牌，令 %dest 视为使用锦囊牌或执行强制“军令”",
  ["#wk_heg__shilun_active-choose"] = "世论：选择花色各不相同的手牌各一张",
  ["#wk_heg__shilun-move"] = "世论：你可以移动场上一张牌",
  ["#wk_heg__liance_viewas"] = "连策",
  ["#wk_heg__liance_active"] = "世论",

  ["$wk_heg__liance1"] = "将军今出洛阳，恐难再回。",
  ["$wk_heg__liance2"] = "贼示弱于外，必包藏祸心。",
  ["$wk_heg__shilun1"] = "某有良谋，可为将军所用。",
  ["$wk_heg__shilun2"] = "吾负十斗之囊，其盈一石之智。",
  ["~wk_heg__huanfan"] = "有良言而不用，君何愚哉……",
}

local yangyi = General(extension, "wk_heg__yangyi", "shu", 3, 3, General.Male)
local juanxia = fk.CreateTriggerSkill{
  name = "wk_heg__juanxia",
  anim_type = "offensive",
  events = {fk.EventPhaseStart},
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(self) and target == player and player.phase == Player.Finish and U.canUseCard(player.room, player, Fk:cloneCard("slash"))
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local targets = {}
    local slash = Fk:cloneCard("slash")
    for _, p in ipairs(room:getOtherPlayers(player)) do
      if not player:isProhibited(p, slash) then
        table.insert(targets, p.id)
      end
    end
    local tos = room:askForChoosePlayers(player, targets, 1, 1, "#wk_heg__juanxia-choose", self.name, true)
    if #tos > 0 then
      self.cost_data = tos[1]
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(self.cost_data)
    room:useVirtualCard("slash", nil, player, to, self.name, true)
    local choices = {"start_command", "Cancel"}
    if not to.dead and room:askForChoice(to, choices, self.name) == "start_command" and not H.askCommandTo(to, player, self.name) then
      room:damage{
        from = to,
        to = player,
        damage = 1,
        skillName = self.name,
      }
    end
  end,
}

--- 交换主副将
---@param room Room
---@param player ServerPlayer
---@return boolean
local function SwapMainAndDeputy(room, player)
  local general1 = player.general
  local general2 = player.deputyGeneral
  if not (general1 and general2) then return false end
  if general1 == "anjiang" then player:revealGeneral(false, true) end
  if general2 == "anjiang" then player:revealGeneral(true, true) end
  general1 = player.general
  general2 = player.deputyGeneral
  if string.find(general1, "lord") then return false end
  room:changeHero(player, "blank_shibing", false, true, false, false, false)
  room:changeHero(player, general2, false, false, true, false, false)
  room:changeHero(player, general1, false, true, true, false, false)
  return true
end

local fenduan = fk.CreateTriggerSkill{
  name = "wk_heg__fenduan",
  anim_type = "offensive",
  relate_to_place = "m",
  events = {"fk.ChooseDoCommand", "fk.AfterCommandUse"},
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(self) and data.to == player and (event == "fk.AfterCommandUse" or not player.chained)
  end,
  on_cost = function (self, event, target, player, data)
    if event == "fk.ChooseDoCommand" then
      return player.room:askForSkillInvoke(player, self.name, nil, "#wk_heg__fenduan-invoke")
    else
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    if event == "fk.ChooseDoCommand" then
      player:setChainState(true)
      return true
    else
      room:askForDiscard(data.from, 2, 2, false, self.name, false)
      SwapMainAndDeputy(room, player)
    end
  end,
}

local choucuo = fk.CreateTriggerSkill{
  name = "wk_heg__choucuo",
  anim_type = "drawcard",
  relate_to_place = "d",
  events = {fk.EventPhaseStart},
  can_trigger = function (self, event, target, player, data)
    return player == target and player:hasSkill(self) and player.phase == Player.Play
  end,
  on_cost = function (self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, nil, "#wk_heg__choucuo-invoke")
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local cards = player:drawCards(2)
    player:showCards(cards)
    if not player.dead then
      local mark = {}
      for _, id in ipairs(cards) do
        if room:getCardArea(id) == Card.PlayerHand and room:getCardOwner(id) == player then
          table.insert(mark, id)
          room:setCardMark(Fk:getCardById(id), "@@wk_heg__choucuo_inhand-phase", 1)
        end
      end
      room:setPlayerMark(player, "wk_heg__choucuo-phase", mark)
    end
  end,

  refresh_events = {fk.AfterCardsMove},
  can_refresh = function(self, event, target, player, data)
    if type(player:getMark("wk_heg__choucuo-phase")) ~= "table" then return false end
    local mark = player:getMark("wk_heg__choucuo-phase")
    local toLose = {}
    for _, move in ipairs(data) do
      if move.from == player.id then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerHand and table.contains(mark, info.cardId) then
            table.insert(toLose, info.cardId)
          end
        end
      end
    end
    if #toLose > 0 then
      self.cost_data = toLose
      return true
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local mark = player:getMark("wk_heg__choucuo-phase")
    table.forEach(self.cost_data, function(id) table.removeOne(mark, id) end)
    player.room:setPlayerMark(player, "wk_heg__choucuo-phase", #mark > 0 and mark or 0)
  end,
}
local choucuo_delay = fk.CreateTriggerSkill{
  name = "#wk_heg__choucuo_delay",
  mute = true,
  events = {fk.EventPhaseEnd},
  can_trigger = function (self, event, target, player, data)
    return player:usedSkillTimes(choucuo.name, Player.HistoryPhase) > 0 and player.phase == Player.Play and #player.room.logic:getEventsOfScope(GameEvent.UseCard, 998, function(e)
      local use = e.data[1]
      return use.from == player.id
    end, Player.HistoryPhase) >= player.hp
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    local room = player.room
    room:notifySkillInvoked(player, choucuo.name, "special")
    player:broadcastSkillInvoke(choucuo.name)
    SwapMainAndDeputy(room, player)
  end,
}
choucuo:addRelatedSkill(choucuo_delay)
local choucuo_prohibit = fk.CreateProhibitSkill{
  name = "#wk_heg__choucuo_prohibit",
  prohibit_use = function(self, player, card)
    if player:getMark("wk_heg__choucuo-phase") == 0 then return false end
    local cards = card:isVirtual() and card.subcards or {card.id}
    return table.find(cards, function(id) return Fk:getCardById(id):getMark("@@wk_heg__choucuo_inhand-phase") == 0 end)
  end,
}
choucuo:addRelatedSkill(choucuo_prohibit)
yangyi:addSkill(juanxia)
yangyi:addSkill(fenduan)
yangyi:addSkill(choucuo)
Fk:loadTranslationTable{
  ["wk_heg__yangyi"] = "杨仪",
  ["#wk_heg__yangyi"] = "狷恙逆跋",
  ["designer:wk_heg__yangyi"] = "教父",

  ["wk_heg__juanxia"] = "狷狭",
  [":wk_heg__juanxia"] = "结束阶段，你可选择一名其他角色，视为对其使用一张【杀】，然后若其存活，其可对你发起“军令”，若你不执行，其对你造成1点伤害。",
  ["wk_heg__fenduan"] = "忿断",
  [":wk_heg__fenduan"] = "主将技，当你选择执行“军令”时，若你未横置，你可改为横置；当你成为“军令”的目标结算完成后，你令此“军令”的发起者弃置两张手牌，然后你交换主副将。",
  ["wk_heg__choucuo"] = "筹措",
  [":wk_heg__choucuo"] = "副将技，出牌阶段开始时，你可摸两张牌并展示之，若如此做，你不能使用其它牌直至你失去这些牌或此阶段结束，且此阶段结束时，若你于此阶段内使用的牌数不小于体力值，你交换主副将。",

  ["#wk_heg__juanxia-choose"] = "狷狭：你可选择一名其他角色，视为对其使用一张【杀】",

  ["#wk_heg__fenduan-invoke"] = "忿断：是否将此次执行的军令改为横置",
  ["#wk_heg__choucuo-invoke"] = "筹措：是否摸两张牌",
  ["#wk_heg__choucuo_delay"] = "筹措",
  ["@@wk_heg__choucuo_inhand-phase"] = "筹措",

  ["$wk_heg__juanxia1"] = "汝有何功，竟能居我之上！",
  ["$wk_heg__juanxia2"] = "恃才傲立，恩怨必偿。",
  ["$wk_heg__fenduan1"] = "北伐之事，丞相亦听我定夺。",
  ["$wk_heg__fenduan2"] = "早知如此，投靠魏国又如何！",
  ["$wk_heg__choucuo1"] = "丞相新丧，吾当继之。",
  ["$wk_heg__choucuo2"] = "规划分部，筹度粮谷。",

  ["~wk_heg__yangyi"] = "魏延庸奴，吾，誓杀汝！",
}

local kuaizi = General(extension, "wk_heg__kuaizi", "qun", 3, 3, General.Male)
local zongpo = fk.CreateTriggerSkill{
  name = "wk_heg__zongpo",
  events = {fk.CardUseFinished},
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player:usedSkillTimes(self.name, Player.HistoryTurn) == 0
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    room:loseHp(player, 1)
    if player.dead then return false end
    local targets = table.map(room:getOtherPlayers(player), Util.IdMapper)
    local tos = room:askForChoosePlayers(player, targets, 1, 1, "#wk_heg__zongpo_choose", self.name, true)
    local to = room:getPlayerById(tos[1])
    if table.find(to:getCardIds("h"), function(id) return Fk:getCardById(id).type == Card.TypeBasic end) then
      local card, _ = U.askforChooseCardsAndChoice(player, table.filter(to:getCardIds("h"), function(id) return Fk:getCardById(id).type == Card.TypeBasic end), 
      {"OK"}, self.name, "", nil, 1, 1, to:getCardIds("h"))
      room:moveCardTo(card, Player.Hand, player, fk.ReasonPrey, self.name, nil, false, tos[1])
      local mark = {}
      table.insert(mark, card[1])
      room:setCardMark(Fk:getCardById(card[1]), "@@alliance-inhand", 1)
      room:setPlayerMark(player, "wk_heg__zongpo", mark)
    else
      U.viewCards(player, to:getCardIds("h"), self.name)
    end
    if to.dead then return false end
    local card_ids = Card:getIdList(data.card)
    if #card_ids == 0 then return false end
    if data.card.type == Card.TypeEquip then
      if not table.every(card_ids, function (id)
        return room:getCardArea(id) == Card.PlayerEquip and room:getCardOwner(id) == player
      end) then return false end
    else
      if not table.every(card_ids, function (id)
        return room:getCardArea(id) == Card.Processing
      end) then return false end
    end
    room:moveCardTo(card_ids, Player.Hand, to, fk.ReasonPrey, self.name, nil, false, targets[1])
  end,

  refresh_events = {fk.AfterCardsMove},
  can_refresh = function(self, event, target, player, data)
    if player.dead or type(player:getMark("wk_heg__zongpo")) ~= "table" then return false end
    local mark = player:getMark("wk_heg__zongpo")
    local toLose = {}
    for _, move in ipairs(data) do
      if move.from == player.id then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerHand and table.contains(mark, info.cardId) then
            table.insert(toLose, info.cardId)
          end
        end
      end
    end
    if #toLose > 0 then
      self.cost_data = toLose
      return true
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local mark = player:getMark("wk_heg__zongpo")
    table.forEach(self.cost_data, function(id) table.removeOne(mark, id) end)
    table.forEach(self.cost_data, function(id) player.room:setCardMark(Fk:getCardById(id), "@@alliance-inhand", 0) end)
    player.room:setPlayerMark(player, "wk_heg__zongpo", #mark > 0 and mark or 0)
  end,
}
local shenshi = fk.CreateTriggerSkill{
  name = "wk_heg__shenshi",
  anim_type = "defensive",
  events = {fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    local room = player.room
    if not player:hasSkill(self) then return false end
    for _, move in ipairs(data) do
      if move.from and move.from == player.id and move.to and move.to ~= player.id and move.toArea == Card.PlayerHand then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip then
            self.cost_data = move.to
            local from = room:getPlayerById(move.from)
            local to = room:getPlayerById(move.to)
            return (H.isBigKingdomPlayer(from) and H.isSmallKingdomPlayer(to)) or (H.isSmallKingdomPlayer(from) and H.isBigKingdomPlayer(to))
          end
        end
      end
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(self.cost_data)
    to:drawCards(1, self.name)
    room:setPlayerMark(to, "wk_heg__shenshi_draw-turn", 1)
  end,

  refresh_events = {fk.DamageCaused},
  can_refresh = function(self, event, target, player, data)
    return data.from and data.from:getMark("wk_heg__shenshi_draw-turn") > 0 and H.compareKingdomWith(data.to, player)
  end,
  on_refresh = function (self, event, target, player, data)
    player.room:setPlayerMark(player, "wk_heg__shenshi_damage-turn", 1)
  end,
}

local shenshi_delay = fk.CreateTriggerSkill{
  name = "#wk_heg__shenshi_delay",
  mute = true,
  events = {fk.TurnEnd},
  can_trigger = function (self, event, target, player, data)
    return player:usedSkillTimes(shenshi.name, Player.HistoryTurn) > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    local room = player.room
    if player:getMark("wk_heg__shenshi_damage-turn") == 0 then
      local targets = table.map(table.filter(room.alive_players, function(p) return H.compareKingdomWith(p, player) end), Util.IdMapper)
      room:sortPlayersByAction(targets)
      for _, pid in ipairs(targets) do
        local p = room:getPlayerById(pid)
        if not p.dead then
          p:drawCards(1, self.name)
        end
      end
    else
      local isDeputy = H.hideBySkillName(player, self.name)
      if isDeputy then
        local record = U.getMark(player, MarkEnum.RevealProhibited)
        table.insert(record, isDeputy)
        room:setPlayerMark(player, MarkEnum.RevealProhibited, record)
        room:setPlayerMark(player, "@wk_heg__shenshi_reveal", H.getActualGeneral(player, isDeputy == "d"))
      end
    end
  end,

  refresh_events = {fk.TurnStart, fk.Death},
  can_refresh = function(self, event, target, player, data)
    if event == fk.TurnStart then
      return target == player and player:getMark("@wk_heg__shenshi_reveal") ~= 0
    end
    if event == fk.Death then
      return player:hasSkill(shenshi, false, true) and player == target
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, MarkEnum.RevealProhibited, 0)
    room:setPlayerMark(player, "@wk_heg__shenshi_reveal", 0)
  end,
}
shenshi:addRelatedSkill(shenshi_delay)
kuaizi:addSkill(zongpo)
kuaizi:addSkill(shenshi)

Fk:loadTranslationTable{
  ["wk_heg__kuaizi"] = "蒯越蒯良",
  ["#wk_heg__kuaizi"] = "雍论臼谋",
  ["designer:wk_heg__kuaizi"] = "教父&风箫",

  ["wk_heg__zongpo"] = "纵迫",
  [":wk_heg__zongpo"] = "每回合限一次，当你使用牌结算后，你可失去1点体力，观看一名其他角色所有手牌并获得其中一张基本牌，此牌于你的手牌区内视为拥有“合纵”标记，然后其获得你使用的牌。",
  ["wk_heg__shenshi"] = "审时",
  [":wk_heg__shenshi"] = "其他角色获得你的牌后，若你与其的大小势力状态不同，你可令其摸一张牌，若如此做，此回合结束时，若此回合内所有以此法摸牌的角色于以此法摸牌后未对与你势力相同的角色造成过伤害，与你势力相同的角色各摸一张牌，否则你暗置此武将牌且不能明置直至你回合开始。",

  ["@wk_heg__shenshi_reveal"] = "审时 禁亮",
  ["#wk_heg__zongpo_choose"] = "纵迫：选择一名其他角色，令其交给你一张基本牌",
  ["#wk_heg__zongpo-give"] = "纵迫：交给蒯越蒯良一张基本牌",

  ["#wk_heg__shenshi_delay"] = "审时",

  ["$wk_heg__zongpo1"] = "得遇曹公，吾之幸也。",
  ["$wk_heg__zongpo2"] = "曹公得荆不喜，喜得吾二人足以。",
  ["$wk_heg__shenshi1"] = "深中足智，鉴时审情。",
  ["$wk_heg__shenshi2"] = "数语之言，审时度势。",
  ["~wk_heg__kuaizi"] = "表不能善用，所憾也",
}

local zhuran = General(extension, "wk_heg__zhuran", "wu", 4, 4, General.Male)
local danshou = fk.CreateTriggerSkill{
  name = "wk_heg__danshou",
  events = {fk.TargetConfirmed, fk.TurnEnd},
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self) then return false end
    if event == fk.TargetConfirmed then
      if target == player and data.from ~= player.id then
        local events = player.room.logic:getEventsOfScope(GameEvent.UseCard, 999, function(e)
          local use = e.data[1]
          return table.contains(TargetGroup:getRealTargets(use.tos), player.id)
        end, Player.HistoryTurn)
        local n = #events
        if player:getHandcardNum() > n then
          self.cost_data = n
          return true
        end
      end
    else
      return #player.room.logic:getActualDamageEvents(1, function(e)
        return e.data[1].to == player
      end, Player.HistoryTurn) > 0
    end
  end,
  on_cost = function(self, event, target, player, data)
    if event == fk.TargetConfirmed then
      local n = player:getHandcardNum() - self.cost_data
      local cards = player.room:askForDiscard(player, n, n, false, self.name, true, ".", "#wk_heg__danshou-damage::"..data.from..":"..n, true)
      if #cards == n then
        self.cost_data = cards
        return true
      end
    else
      return player.room:askForSkillInvoke(player, self.name, nil, "#wk_heg__danshou")
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.TargetConfirmed then
      local to = room:getPlayerById(data.from)
      room:doIndicate(player.id, {data.from})
      room:throwCard(self.cost_data, self.name, player, player)
      if not to.dead then 
        room:damage{
          from = player,
          to = to,
          damage = 1,
          skillName = self.name,
        }
      end
    else
      player:drawCards(1, self.name)
    end
  end,
}

zhuran:addCompanions("hs__lvmeng")
zhuran:addSkill(danshou)
Fk:loadTranslationTable{
  ["wk_heg__zhuran"] = "朱然",
  ["#wk_heg__zhuran"] = "胆略无双",
  ["designer:wk_heg__zhuran"] = "教父&二四",

  ["wk_heg__danshou"] = "胆守",
  [":wk_heg__danshou"] = "当你成为其他角色使用牌的目标后，你可将手牌弃置至X张，对其造成1点伤害（X为你本回合成为过牌目标的次数）；一名角色的回合结束时，若你此回合内受到过伤害，你可摸一张牌。",

  ["#wk_heg__danshou-damage"] = "胆守：你可以弃置 %arg 张牌，对 %dest 造成1点伤害",
  ["#wk_heg__danshou"] = "胆守：是否摸一张牌",

  ["$wk_heg__danshou1"] = "到此为止了！",
  ["$wk_heg__danshou2"] = "以胆为守，扼敌咽喉！",
  ["~wk_heg__zhuran"] = "何人竟有如此之胆！？",
}

local guanning = General(extension, "wk_heg__guanning", "qun", 3, 3, General.Male)
local xuci = fk.CreateTriggerSkill{
  name = "wk_heg__xuci",
  events = {fk.TargetSpecified},
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return player:hasShownSkill(self) and U.isOnlyTarget(player, data, event) and
      target:canMoveCardsInBoardTo(player) and (data.card.trueName == "slash" or data.card:isCommonTrick())
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(target, self.name, nil, "#wk_heg__xuci-ask::" .. player.id)
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    room:askForMoveCardInBoard(target, target, player, self.name, nil, target)
    local choices = {"wk_heg__xuci_draw"}
    if not player:isNude() then
      table.insert(choices, "wk_heg__xuci_give")
    end
    local choice = room:askForChoice(player, choices, self.name)
    if choice == "wk_heg__xuci_draw" then
      target:drawCards(1, self.name)
      if not player.dead then
        player:drawCards(1, self.name)
        table.insertIfNeed(data.nullifiedTargets, player.id)
      end
      if not target.dead and not player.dead then
        room:damage{
          from = target,
          to = player,
          damage = 1,
          skillName = self.name,
        }
      end
    else
      local card = room:askForCard(player, 1, 1, true, self.name, false, ".", "#wk_heg__xuci-give")
      room:obtainCard(target, card[1], false, fk.ReasonGive)
      room:setPlayerMark(player, "@@lure_tiger-turn", 1)
      room:setPlayerMark(player, MarkEnum.PlayerRemoved .. "-turn", 1)
      room:handleAddLoseSkills(player, "#lure_tiger_hp|#lure_tiger_prohibit", nil, false, true) -- global...
      room.logic:trigger("fk.RemoveStateChanged", player, nil) -- FIXME
    end
  end
}

---@param object Card|Player
---@param markname string
---@param suffixes string[]
---@return boolean
local function hasMark(object, markname, suffixes)
  if not object then return false end
  for mark, _ in pairs(object.mark) do
    if mark == markname then return true end
    if mark:startsWith(markname .. "-") then
      for _, suffix in ipairs(suffixes) do
        if mark:find(suffix, 1, true) then return true end
      end
    end
  end
  return false
end

local gaojie = fk.CreateTriggerSkill{
  name = "wk_heg__gaojie",
  events = {fk.TargetConfirming, fk.AfterCardsMove},
  anim_type = "defensive",
  frequency = Skill.Compulsory,
  can_trigger = function (self, event, target, player, data)
    if not player:hasSkill(self) then return false end
    if event == fk.TargetConfirming then
      return target == player and data.card and data.card:isCommonTrick() and data.card.package.name == "strategic_advantage"
    else
      local cardInfo = {}
      for _, move in ipairs(data) do
        if move.to and move.to == player.id and move.toArea == Card.PlayerHand then
          for _, info in ipairs(move.moveInfo) do
            if hasMark(Fk:getCardById(info.cardId), "@@alliance", MarkEnum.CardTempMarkSuffix) then
              table.insert(cardInfo, info.cardId)
            end
          end
        end
      end
      if #cardInfo > 0 then
        self.cost_data = cardInfo
        return true
      end
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    if event == fk.TargetConfirming then
      AimGroup:cancelTarget(data, player.id)
      return true
    else
      if #self.cost_data > 0 then
        player.room:throwCard(self.cost_data, self.name, player, player)
        if player:isWounded() and not player.dead then
          player.room:recover({
            who = player,
            num = 1,
            recoverBy = player,
            skillName = self.name,
          })
        end
      end
    end
  end,
}

guanning:addSkill(xuci)
guanning:addSkill(gaojie)
Fk:loadTranslationTable{
  ["wk_heg__guanning"] = "管宁",
  ["designer:wk_heg__guanning"] = "教父&卧雏",
  ["wk_heg__xuci"] = "絮辞",
  [":wk_heg__xuci"] = "其他角色使用【杀】或普通锦囊牌指定你为唯一目标后，其可将其场上的一张牌移动至你的对应区域内，然后你选择一项：1.交给其一张牌，调离你至此回合结束；2.你与其各摸一张牌，此牌对你无效，然后其对你造成1点伤害。",
  ["wk_heg__gaojie"] = "高节",
  [":wk_heg__gaojie"] = "锁定技，当你成为势备篇锦囊牌的目标时，取消之；当你获得带有“合纵”标记的牌后，你弃置之，然后回复1点体力。<br />"..
  "<font color = 'gray'>注：势备篇锦囊牌包括【勠力同心】【联军盛宴】【挟天子以令诸侯】【敕令】【调虎离山】【水淹七军】【火烧连营】。</font>",

  ["#wk_heg__xuci-ask"] = "絮辞：你可以将你场上一张牌移动至 %dest 的对应区域内，然后其选择交给你牌或你与其各摸牌",
  ["wk_heg__xuci_give"] = "交给牌，然后调离至此回合结束",
  ["wk_heg__xuci_draw"] = "各摸牌，此牌对你无效并受到伤害",
  ["#wk_heg__xuci-give"] = "絮辞：请选择一张牌",

  ["$wk_heg__xuci1"] = "",
  ["$wk_heg__xuci2"] = "",
  ["$wk_heg__gaojie1"] = "",
  ["$wk_heg__gaojie2"] = "",

  ["~wk_heg__guanning"] = "",
}

local caorui = General(extension, "wk_heg__caorui", "wei", 3, 3, General.Male)
local yuchen = fk.CreateTriggerSkill{
  name = "wk_heg__yuchen",
  events = {fk.EventPhaseStart},
  anim_type = "support",
  can_trigger = function (self, event, target, player, data)
    if not (player:hasSkill(self) and target ~= player and target.phase == Player.Finish and #player:getCardIds("he") > 1) then return false end
    return #player.room.logic:getActualDamageEvents(1, function(e)
      return e.data[1].from == target
    end, Player.HistoryTurn) == 0
  end,
  on_cost = function (self, event, target, player, data)
    local cards = player.room:askForCard(player, 2, 2, true, self.name, true, ".", "#wk_heg__yuchen-give")
      if #cards == 2 then
        self.cost_data = cards
        return true
      end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    room:obtainCard(target, self.cost_data, false, fk.ReasonGive)
    if not target.dead then
      room:setPlayerMark(target, "@@wk_heg__yuchen-turn", 1)
      target:gainAnExtraPhase(Player.Play)
    end
  end
}

local yuchen_delay = fk.CreateTriggerSkill{
  name = "#wk_heg__yuchen_delay",
  events = {fk.EventPhaseEnd},
  anim_type = "support",
  frequency = Skill.Compulsory,
  can_trigger = function (self, event, target, player, data)
    if not (target:getMark("@@wk_heg__yuchen-turn") > 0 and target.phase == Player.Play and player:usedSkillTimes(yuchen.name, Player.HistoryTurn) > 0 and player:isAlive()) then return false end
    return #player.room.logic:getActualDamageEvents(1, function(e)
      return e.data[1].from == target
    end, Player.HistoryPhase) == 0
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    room:damage{
      from = player,
      to = target,
      damage = 1,
      skillName = self.name,
    }
  end,
}

local mingsong = fk.CreateTriggerSkill{
  name = "wk_heg__mingsong",
  events = {fk.DamageCaused},
  anim_type = "support",
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(self) and H.compareKingdomWith(player, target) and #target:getCardIds("e") > 0
      and table.find(player.room.alive_players, function(p) return target:canMoveCardsInBoardTo(p, "e") end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.map(table.filter(room.alive_players, function (p)
      return target:canMoveCardsInBoardTo(p, "e")
    end), Util.IdMapper)
    targets = room:askForChoosePlayers(player, targets, 1, 1, "#wk_heg__mingsong-ask::"..target, self.name, true)
    if #targets > 0 then
      self.cost_data = targets[1]
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(self.cost_data)
    room:askForMoveCardInBoard(player, target, to, self.name, "e", target)
    local targets = {}
    local num = 999
    for _, p in ipairs(room.alive_players) do
      local n = p.hp
      if n <= num then
        if n < num then
          num = n
          targets = {}
        end
        if n < p.maxHp then
          table.insert(targets, p.id)
        end
      end
    end
    if #targets > 0 then
      local tmp = room:askForChoosePlayers(player, targets, 1, 1, "#wk_heg__mingsong-choose", self.name, true)
      local ret = room:getPlayerById(tmp[1])
      if ret.hp < ret.maxHp then
        room:recover{
          who = ret,
          num = 1,
          recoverBy = player,
          skillName = self.name,
        }
      end
    end
    local x = 0
    num = 999
    for _, p in ipairs(room.alive_players) do
      local n = p.hp
      if n <= num then
        if n < num then
          num = n
          x = 0
        end
        x = x + 1
      end
    end
    local n = player:getHandcardNum() - math.min(x, player.maxHp)
    if n > 0 then
      room:askForDiscard(player, n, n, false, self.name, false)
    else
      player:drawCards(-n, self.name)
    end
    return true
  end,
}

caorui:addSkill(yuchen)
yuchen:addRelatedSkill(yuchen_delay)
caorui:addSkill(mingsong)
Fk:loadTranslationTable{
  ["wk_heg__caorui"] = "曹叡",
  ["designer:wk_heg__caorui"] = "小曹神",
  ["wk_heg__yuchen"] = "驭臣",
  [":wk_heg__yuchen"] = "其他角色的结束阶段，若其本回合未造成过伤害，你可以交给其两张牌，令其执行一个额外的出牌阶段，若如此做，此额外的阶段结束时，若其于此阶段未造成过伤害，你对其造成1点伤害。",
  ["wk_heg__mingsong"] = "明讼",
  [":wk_heg__mingsong"] = "与你势力相同的角色造成伤害时，你可以移动其装备区里的一张牌，防止此伤害，令一名体力值最小的角色回复1点体力，然后你将手牌摸或弃至X张（X为体力值最小的角色数，至多为你体力上限）",

  ["@@wk_heg__yuchen-turn"] = "驭臣",
  ["#wk_heg__yuchen_delay"] = "驭臣",

  ["#wk_heg__yuchen-give"] = "驭臣：你可以交给其两张牌，令其执行一个额外的出牌阶段",
  ["#wk_heg__mingsong-ask"] = "明讼：你可以选择一名角色，将 %dest 装备区内的一张牌移动至其装备区内，防止此伤害并令一名体力值最小的角色回复1点体力",
  ["#wk_heg__mingsong-choose"] = "明讼：选择一名体力值最小的角色回复1点体力",
}

local luji = General(extension, "wk_heg__luji", "wu", 3, 3, General.Male)
local huaiju = fk.CreateTriggerSkill{
  name = "wk_heg__huaiju",
  events = {fk.CardUseFinished},
  anim_type = "special",
  can_trigger = function (self, event, target, player, data)
    if not (player:hasSkill(self) and target ~= player and data.tos and
    table.find(TargetGroup:getRealTargets(data.tos), function(id) return id == player.id end)) then return false end
    return data.card.is_damage_card and not table.every(Card:getIdList(data.card), function (id) return player.room:getCardArea(id) == Card.Processing end)
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local targets = table.map(table.filter(room.alive_players, function(p) return p ~= target end), Util.IdMapper)
    local tos = room:askForChoosePlayers(player, targets, 1, 1, "#wk_heg__huaiju_choose", self.name, true)
    if #tos > 0 then
      self.cost_data = tos[1]
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local card_ids = Card:getIdList(data.card)
    if #card_ids == 0 then return false end
    room:moveCardTo(card_ids, Player.Hand, room:getPlayerById(self.cost_data), fk.ReasonPrey, self.name, nil, true, player.id)
    local choices = {"Cancel"}
    if player:isAlive() and #player:getCardIds("he") > 0 then
      table.insert(choices, "#wk_heg__huaiju_discard_choose::" .. player.id)
    end
    local choice = room:askForChoice(target, choices, self.name)
    if choice ~= "Cancel" then
      local cid = room:askForCardChosen(target, player, "he", self.name)
      room:throwCard({cid}, self.name, player, target)
    end
  end,
}

local zhenglun = fk.CreateTriggerSkill{
  name = "wk_heg__zhenglun",
  anim_type = "special",
  events = {fk.DrawNCards},
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:drawCards(1, self.name)
    player:showCards(player:getCardIds(Player.Hand))
    while true do
      local cards = player.player_cards[Player.Hand]
      -- player:showCards(cards)
      local suits = {}
      for _, id in ipairs(cards) do
        local suit = Fk:getCardById(id).suit
        if suit ~= Card.NoSuit then
          table.insertIfNeed(suits, suit)
        end
      end
      if player:getHandcardNum() > #room.alive_players or #suits == 4 then
        room:delay(1000)
        player:showCards(cards) -- 睿智
        break
      else
        room:delay(500)
        player:drawCards(1, self.name)
      end
    end
    local suitMapper = { [1] = {}, [2] = {}, [3] = {}, [4] = {} }
    table.forEach(player:getCardIds(Player.Hand), function(id)
      if Fk:getCardById(id).suit ~= Card.NoSuit then
        table.insert(suitMapper[Fk:getCardById(id).suit], id)
      end
    end)
    local maxNum = -1
    local all_suits = {"log_spade", "log_club", "log_heart", "log_diamond"}
    local choices = {}
    for i, j in ipairs(suitMapper) do
      local num = #j
      if num >= maxNum then
        if num > maxNum then
          maxNum = num
          choices = {}
        end
        table.insert(choices, all_suits[i])
      end
    end
    local choice = room:askForChoice(player, choices, self.name, "#wk_heg__zhenglun-discard")
    local cid = suitMapper[table.indexOf(all_suits, choice)]
    room:throwCard(cid, self.name, player, player)
    return true
  end,
}

luji:addSkill(huaiju)
luji:addSkill(zhenglun)
Fk:loadTranslationTable{
  ["wk_heg__luji"] = "陆绩",
  ["designer:wk_heg__luji"] = "静谦",
  ["wk_heg__huaiju"] = "怀橘",
  [":wk_heg__huaiju"] = "其他角色的指定你为目标的非伤害牌结算后，你可令一名除使用者以外的角色获得此牌，然后使用者可以弃置你的一张牌。",
  ["wk_heg__zhenglun"] = "整论",
  [":wk_heg__zhenglun"] = "摸牌阶段，你可改为摸一张牌并展示所有手牌，然后若你手牌数大于存活角色数或其中包含四种花色，则你弃置手牌中数量最多的一种花色的所有牌，否则你重复此流程。",

  ["#wk_heg__huaiju_choose"] = "怀橘：你可以将此牌交给一名除使用者外的角色",
  ["#wk_heg__huaiju_discard_choose"] = "弃置 %dest 的一张牌",
  ["#wk_heg__zhenglun-discard"] = "整论：弃置手牌中数量最多的一种花色的所有牌",

  ["$wk_heg__huaiju1"] = "",
  ["$wk_heg__huaiju2"] = "",
  ["$wk_heg__zhenglun1"] = "",
  ["$wk_heg__zhenglun2"] = "",

  ["~wk_heg__luji"] = "",
}

return extension
