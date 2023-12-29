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
    if event == fk.Damage then
      return target == player and player:hasSkill(self) and data.to ~= player and not data.to.dead and not data.to:isNude()
    else
      return target == player and player:hasSkill(self) and player:getMark("poyuan-turn") == 0 and H.isBigKingdomPlayer(data.to) 
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
      local choices = {}
      if not data.to:isKongcheng() then
        table.insert(choices, "poyuan_discard-hand")
      end
      if #data.to:getCardIds("e") > 0 then
        table.insert(choices, "poyuan_discard-equip")
      end
      if #choices == 0 then return end
      local choice = room:askForChoice(player, choices, self.name)
      if choice:startsWith("poyuan_discard-hand") then
        room:askForDiscard(data.to, 1, 1, false, self.name, false)
      end
      if choice:startsWith("poyuan_discard-equip") then
        local id = room:askForCardChosen(player, data.to, "e", self.name)
        room:throwCard(id, self.name, data.to, player)
      end
    else
      room:setPlayerMark(player, "poyuan-turn", 1)
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
      return player == target and player:hasSkill(self) and player:getMark("@!yinyangfish") <= 2
    else
      return player:hasSkill(self) and H.compareKingdomWith(player, target) and player:getMark("choulue_virtual") == 0 and #AimGroup:getAllTargets(data.tos) == 1
       and data.card.type == Card.TypeTrick and data.card.sub_type ~= Card.SubtypeDelayedTrick and player:getMark("@!yinyangfish") ~= 0
    end
  end,
  on_cost = function (self, event, target, player, data)
    if event == fk.Damaged then
      return player.room:askForSkillInvoke(player, self.name, nil, "#wk_heg__choulue-getfish")
    else
      return player.room:askForSkillInvoke(player, self.name, nil, "#wk_heg__choulue-twice")
    end
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
      room:setPlayerMark(player, "choulue_tos", AimGroup:getAllTargets(data.tos))
    end
  end,

  refresh_events = {fk.CardUseFinished},
  can_refresh = function(self, event, target, player, data)
    if H.compareKingdomWith(player, target) and player:hasSkill(self) then
      return player:getMark("choulue_tos") ~= 0
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local targets = player:getMark("choulue_tos")
    room:setPlayerMark(player, "choulue_tos", 0)
    local tos = table.simpleClone(targets)
    if player.dead then return end
    room:sortPlayersByAction(tos)
    room:setPlayerMark(player, "choulue_virtual", 1)
    room:useVirtualCard(data.card.name, nil, target, table.map(tos, function(id) return room:getPlayerById(id) end), self.name, true)
    room:setPlayerMark(player, "choulue_virtual", 0)
  end,
}

liuye:addSkill(poyuan)
liuye:addSkill(choulue)
Fk:loadTranslationTable{
  ["wk_heg__liuye"] = "刘晔",
  ["wk_heg__poyuan"] = "破垣",
  [":wk_heg__poyuan"] = "当你对其他角色造成伤害后，你可以选择一项：1.弃置其一张装备区内的牌；2.令其弃置一张手牌；当你于一名角色的回合内首次对大势力角色造成伤害时，此伤害+1。",
  ["wk_heg__choulue"] = "筹略",
  [":wk_heg__choulue"] = "当你受到伤害后，若你的“阴阳鱼”标记数不大于2，你可以获得一个“阴阳鱼”标记；与你势力相同的角色使用普通锦囊牌指定唯一目标后，你可以移去一个“阴阳鱼”标记，令此牌结算两次。",
  
  ["#wk_heg__poyuan-discard"] = "破垣：是否令受伤角色弃置一张手牌，或你弃置受伤角色装备区内一张牌",
  ["poyuan_discard-hand"] = "令其弃置一张手牌",
  ["poyuan_discard-equip"] = "弃置其一张装备区内的牌",
  
  ["#wk_heg__choulue-getfish"] = "筹略：是否获得一个“阴阳鱼”标记",
  ["#wk_heg__choulue-twice"] = "筹略：是否移去一个“阴阳鱼”标记，令此牌结算两次",

  ["$wk_heg__poyuan1"] = "砲石飞空，坚垣难存。",
  ["$wk_heg__poyuan2"] = "声若霹雳，人马俱摧。",
  ["$wk_heg__choulue1"] = "筹画所料，无有不中。",
  ["$wk_heg__choulue2"] = "献策破敌，所谋皆应。",
  ["~wk_heg__liuye"] = "功名富贵，到头来，不过黄土一抔...",
}

local dongyun = General(extension, "wk_heg__dongyun", "shu", 3, 3, General.Male)
local yizan = fk.CreateTriggerSkill{
  name = "wk_heg__yizan",
  anim_type = "drawcard",
  events = {fk.EventPhaseStart, fk.EventPhaseEnd},
  can_trigger = function (self, event, target, player, data)
    if event == fk.EventPhaseStart then
      return player:hasSkill(self.name) and player.phase == Player.Discard
    else
      return player:hasSkill(self.name) and player.phase == Player.Discard and player:getMark("wk_heg__yizan-phase")
    end
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
    else
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(self.cost_data)
    if event == fk.EventPhaseStart then
      to:drawCards(math.min(player:getHandcardNum() - #to.player_cards[Player.Hand], 5), self.name)
      room:setPlayerMark(player, "wk_heg__yizan-phase", player:getHandcardNum())
    elseif player:getMark("wk_heg__yizan-phase") > player:getMaxCards() then
      local throw_num = #to.player_cards[Player.Hand] - to.maxHp
      if throw_num > 0 then
        room:askForDiscard(to, throw_num, throw_num, false, self.name, false)
      end
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
     and target.phase == Player.Finish and player:hasSkill(self.name) and not target:isKongcheng()
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
      return player == target and player:hasSkill(self.name)
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

juanshe:addRelatedSkill(juanshe_prohibit)
dongyun:addSkill(yizan)
dongyun:addSkill(juanshe)
Fk:loadTranslationTable{
  ["wk_heg__dongyun"] = "董允",
  ["wk_heg__yizan"] = "翼赞",
  [":wk_heg__yizan"] = "弃牌阶段开始时，你可以令一名手牌数小于你的角色将手牌摸至与你相同（至多摸五张），然后此阶段结束时，若你于此阶段内弃置过牌，其将手牌弃至体力上限。",
  ["wk_heg__juanshe"] = "蠲奢",
  [":wk_heg__juanshe"] = "与你势力相同角色的结束阶段，若其本回合使用牌数小于其手牌上限，你可以令其弃置一张手牌并回复1点体力，然后直至其回合开始或你受到伤害，其不能使用手牌。",

  ["#wk_heg__yizan-invoke"] = "翼赞：是否令一名手牌数小于你的角色将手牌摸至与你相同，然后其根据你的弃牌情况执行对应操作。",
  ["#wk_heg__yizan-choose"] = "翼赞：选择一名手牌数小于你的角色，令其将手牌摸至与你相同。",
  ["#wk_heg__juanshe-invoke"] = "蠲奢：是否令当前回合角色弃置一张手牌，然后其回复1点体力。",

  ["$wk_heg__yizan1"] = "还是改日吧。",
  ["$wk_heg__yizan2"] = "今日之宴，恕某不能奉陪。",

  ["$wk_heg__juanshe1"] = "自古，就是邪不胜正！。",
  ["$wk_heg__juanshe2"] = "主公面前，岂容小人搬弄是非。",

  ["~wk_heg__dongyun"] = "大汉，要亡于宦官之手了...",
}

local function swapHandCards(room, from, to1, to2, skillname)
  local target1 = room:getPlayerById(to1)
  local target2 = room:getPlayerById(to2)
  local cards1 = table.clone(target1.player_cards[Player.Hand])
  local cards2 = table.clone(target2.player_cards[Player.Hand])
  local moveInfos = {}
  if #cards1 > 0 then
    table.insert(moveInfos, {
      from = to1,
      ids = cards1,
      toArea = Card.Processing,
      moveReason = fk.ReasonExchange,
      proposer = from,
      skillName = skillname,
    })
  end
  if #cards2 > 0 then
    table.insert(moveInfos, {
      from = to2,
      ids = cards2,
      toArea = Card.Processing,
      moveReason = fk.ReasonExchange,
      proposer = from,
      skillName = skillname,
    })
  end
  if #moveInfos > 0 then
    room:moveCards(table.unpack(moveInfos))
  end
  moveInfos = {}
  if not target2.dead then
    local to_ex_cards1 = table.filter(cards1, function (id)
      return room:getCardArea(id) == Card.Processing
    end)
    if #to_ex_cards1 > 0 then
      table.insert(moveInfos, {
        ids = to_ex_cards1,
        fromArea = Card.Processing,
        to = to2,
        toArea = Card.PlayerHand,
        moveReason = fk.ReasonExchange,
        proposer = from,
        skillName = skillname,
      })
    end
  end
  if not target1.dead then
    local to_ex_cards2 = table.filter(cards2, function (id)
      return room:getCardArea(id) == Card.Processing
    end)
    if #to_ex_cards2 > 0 then
      table.insert(moveInfos, {
        ids = to_ex_cards2,
        fromArea = Card.Processing,
        to = to1,
        toArea = Card.PlayerHand,
        moveReason = fk.ReasonExchange,
        proposer = from,
        skillName = skillname,
      })
    end
  end
  if #moveInfos > 0 then
    room:moveCards(table.unpack(moveInfos))
  end
  table.insertTable(cards1, cards2)
  local dis_cards = table.filter(cards1, function (id)
    return room:getCardArea(id) == Card.Processing
  end)
  if #dis_cards > 0 then
    local dummy = Fk:cloneCard("dilu")
    dummy:addSubcards(dis_cards)
    room:moveCardTo(dummy, Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile, skillname)
  end
end

local luotong = General(extension, "wk_heg__luotong", "wu", 3)
local mingzheng = fk.CreateTriggerSkill{
  name = "wk_heg__mingzheng",
  anim_type = "drawcard",
  events = {fk.GeneralRevealed, fk.EventPhaseStart},
  can_trigger = function (self, event, target, player, data)
    if event == fk.GeneralRevealed then
      return player:hasSkill(self) and H.compareKingdomWith(target, player) and not target.dead and H.getGeneralsRevealedNum(target) == 2
    else
      return player:hasSkill(self) and H.compareKingdomWith(target, player) and not target.dead and target.phase == Player.Play
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    local room = player.room
    if event == fk.EventPhaseStart then
      local targets = table.map(table.filter(room.alive_players, function(p) return H.compareKingdomWith(p, player) and p ~= target end), Util.IdMapper)
      if #targets > 0 then
        local to = room:askForChoosePlayers(player, targets, 1, 1, "#wk_heg__mingzheng-choose", self.name, true)
        local p = room:getPlayerById(to[1])
        room:askForCardsChosen(target, p, 0, 0, {
          card_data = {
            { "$Hand", p:getCardIds(Player.Hand) }
          }
        }, self.name, "wk_heg__mingzheng-hand::"..to[1])
      end
    end
    if event == fk.GeneralRevealed then
      if not target.faceup then
        target:turnOver()
      end
      if target.chained then
        target:setChainState(false)
      end
      room:addPlayerMark(target, "@!yinyangfish", 1)
      target:addFakeSkill("yinyangfish_skill&")
      target:prelightSkill("yinyangfish_skill&", true)
    end
  end,
}

local yujian = fk.CreateTriggerSkill{
  name = "wk_heg__yujian",
  anim_type = "control",
  events = {fk.Damage, fk.TurnEnd},
  can_trigger = function (self, event, target, player, data)
    if event == fk.Damage then
      return player:hasSkill(self) and player:usedSkillTimes(self.name, Player.HistoryTurn) == 0 and data.from == player.room.current and data.from.phase == Player.Play and data.from ~= player
    elseif event == fk.TurnEnd then
      return player:getMark("@@wk_heg__yujian_exchange-turn") > 0
    end
  end,
  on_cost = function (self, event, target, player, data)
    if event == fk.Damage then
      return player.room:askForSkillInvoke(player, self.name, nil, "#wk_heg__yujian-invoke")
    else
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local current = room.current
    if event == fk.Damage then
      if target.hp <= player.hp then
        swapHandCards(room, player.id, player.id, current.id, self.name)
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
    end
    
    if event == fk.TurnEnd then
      if player:getMark("@@wk_heg__yujian_exchange-turn") > 0 then
        swapHandCards(room, player.id, player.id, current.id, self.name)
      end
    end
  end,
}

luotong:addSkill(mingzheng)
luotong:addSkill(yujian)
Fk:loadTranslationTable{
  ["wk_heg__luotong"] = "骆统",
  ["wk_heg__mingzheng"] = "明政",
  [":wk_heg__mingzheng"] = "与你势力相同的角色：1.明置武将牌后，若其武将牌均明置，其复原武将牌，然后获得一个“阴阳鱼”标记; 2.出牌阶段开始时，其观看除其外一名与你势力相同的角色的手牌。",
  ["wk_heg__yujian"] = "御谏",
  [":wk_heg__yujian"] = "每回合限一次，其他角色于其出牌阶段内造成伤害后，你可以依次执行任意项：1.若其体力值不大于你，你可以与其交换手牌，若如此做，此回合结束时，你与其交换手牌；"..
  "2.若其武将牌均明置，你可以暗置其一张武将牌且直至本回合结束不能明置之。",

  ["#wk_heg__mingzheng-choose"] = "明政：选择一名以你势力相同的其他角色观看手牌",
  ["wk_heg__mingzheng-hand"] = "明政：观看%dest的手牌",
  ["wk_heg__yujian_hide"] = "暗置%dest一张武将牌且本回合不能明置",

  ["@@wk_heg__yujian_exchange-turn"] = "御谏 交换手牌",

  ["#wk_heg__yujian-invoke"] = "御谏：你可根据条件与当前回合角色交换手牌或暗置当前回合角色武将牌",
  ["@wk_heg__yujian_reveal-turn"] = "御谏 不能明置",

  ["$wk_heg__mingzheng1"] = "仁政如水，可润万物",
  ["$wk_heg__mingzheng2"] = "为官一任，当造福一方",
  ["$wk_heg__yujian1"] = "臣代天子牧民，闻苛自当谏之。",
  ["$wk_heg__yujian2"] = "为将者死战，为臣者死谏。",
  ["~wk_heg__chengui"] = "臣统之大愿，可以死而不朽矣。",
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
        local to = room:askForChoosePlayers(player, targets, 1, 1, "#wk_heg__tugui-choose")
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
  events = {fk.EventPhaseStart, fk.Damage},
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

  refresh_events = {fk.Damage, fk.EventPhaseEnd},
  can_refresh = function (self, event, target, player, data)
    if event == fk.Damage then
      return data.from:getMark("@@wk_heg__yingshou") > 0 and not data.from:isNude() and data.from.phase == Player.Play and player:hasSkill(self)
    else
      return target:getMark("@@wk_heg__yingshou") > 0 and target.phase == Player.Play
    end
  end,
  on_refresh = function (self, event, target, player, data)
    if event == fk.Damage then
      player.room:askForDiscard(data.from, 1, 1, true, self.name, false)
    else
      player.room:setPlayerMark(target, "@@wk_heg__yingshou", 0)
    end
  end,
}

jvshou:addSkill(tugui)
jvshou:addSkill(yingshou)

Fk:loadTranslationTable{
  ["wk_heg__jvshou"] = "沮授",
  ["wk_heg__tugui"] = "图归",
  [":wk_heg__tugui"] = "①每回合限一次，当你失去最后的手牌后或当你进入濒死状态后，你可以获得与你距离为1的其他角色的一张手牌并展示之；②出牌阶段结束时，若你未失去以此法获得的所有牌，你移除此武将牌。",
  ["wk_heg__yingshou"] = "营守",
  [":wk_heg__yingshou"] = "结束阶段，你可以令一名与你势力相同的角色摸两张牌，若如此做，当其于下个回合的出牌阶段内造成伤害后，其弃置一张牌。",

  ["#wk_heg__tugui-ask"] = "图归：是否获得与你距离为1的其他角色的一张手牌",
  ["#wk_heg__tugui-choose"] = "图归：选择一名与你距离为1的其他角色",

  ["#wk_heg__yingshou-choose"] = "营守：选择一名与你势力相同的角色",
  ["@@wk_heg__yingshou"] = "营守",

  ["$wk_heg__tugui1"] = "矢志于北，尽忠于国。",
  ["$wk_heg__tugui2"] = "命系袁氏，一心向北。",
  ["$wk_heg__yingshou1"] = "由缓至急，循循而进。",
  ["$wk_heg__yingshou2"] = "事须缓图，欲速不达也。",
  ["~wk_heg__jvshou"] = "智士凋亡，河北哀矣...",
}


---@param room Room
---@param player ServerPlayer
local function DoElectedChange(room, player, data) --- 推举
  local existingGenerals = {}
  for _, p in ipairs(room.players) do
    table.insert(existingGenerals, H.getActualGeneral(p, false))
    table.insert(existingGenerals, H.getActualGeneral(p, true))
  end
  local generals = room:findGenerals(function(g)
    return Fk.generals[g].kingdom == Fk.generals[H.getActualGeneral(player, false)].kingdom
  end, 1)
  local general = room:askForGeneral(player, generals, 1, true)
  local targets = table.map(table.filter(room.alive_players, function(p) return H.compareKingdomWith(p, player) end), Util.IdMapper)
  room:sortPlayersByAction(targets)
  for _, pid in ipairs(targets) do
  -- for _, p in ipairs(room.alive_players) do
    local p = room:getPlayerById(pid)
    if H.compareKingdomWith(p, player) then
      local choices = {general, "Cancel"}
      local choice = room:askForChoice(p, choices, "ElectedChange")
      if choice ~= "Cancel" then
        table.removeOne(generals, general)
        table.insert(generals, false)
        room:returnToGeneralPile(generals)
        room:changeHero(p, general, false, true, true, false)
        return {p, true}
      end
    end
  end
  return {0, false}
end

Fk:loadTranslationTable{
  ["ElectedChange"] = "推举",
}

local chenqun = General(extension, "wk_heg__chenqun", "wei", 3)
local dingpin = fk.CreateTriggerSkill{
  name = "wk_heg__dingpin",
  anim_type = "support",
  events = {fk.EventPhaseStart, fk.AfterTurnEnd},
  can_trigger = function (self, event, target, player, data)
    if event == fk.EventPhaseStart then
      return (target == player and player:hasSkill(self) and not player.chained and player.phase == Player.Finish)
       or (player:hasSkill(self) and target.phase == Player.Play and target:getMark("@@wk_heg__dingpin_extra") > 0 and H.compareKingdomWith(player, target))
    elseif event == fk.AfterTurnEnd then
      return player:hasSkill(self) and player == target
    end
  end,
  on_cost = function (self, event, target, player, data)
    if event == fk.EventPhaseStart and player.phase == Player.Finish then 
      if player.room:askForSkillInvoke(player, self.name, nil, "#wk_heg__dingpin-invoke") then
        local room = player.room
        local targets = table.map(table.filter(room.alive_players, function(p) return p ~= player and not p.chained end), Util.IdMapper)
        local target = room:askForChoosePlayers(player, targets, 1, 1, "#wk_heg__dingpin-choose", self.name, true)
        self.cost_data = target[1]
        return true
      end
    else
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    if event == fk.EventPhaseStart and player.phase == Player.Finish then
      player:setChainState(true)
      local to = room:getPlayerById(self.cost_data)
      to:setChainState(true)
    elseif event == fk.EventPhaseStart and target.phase == Player.Play then
      local accept = DoElectedChange(room, target, self.name)
      if accept[2] == true then
        target:drawCards(1, self.name)
        local p = accept[1]
        if p ~= target then
          p:drawCards(1, self.name)
        end
      else
        return true
      end
    elseif event == fk.AfterTurnEnd then
      if self.cost_data ~= 0 then
        local to = room:getPlayerById(self.cost_data)
        room:addPlayerMark(to, "@@wk_heg__dingpin_extra", 1)
        self.cost_data = 0
        to:gainAnExtraTurn()
      end
    end
  end,

  refresh_events = {fk.TurnEnd},
  can_refresh = function (self, event, target, player, data)
    return target:getMark("@@wk_heg__dingpin_extra") > 0
  end,
  on_refresh = function (self, event, target, player, data)
    target:turnOver()
    player.room:addPlayerMark(target, "@@wk_heg__dingpin_extra", -1)
  end,
}

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
    if event == fk.TurnedOver then
      player.room:askForDiscard(target, 2, 2, true, self.name, false)
      target:turnOver()
    else
      local card = player.room:askForCard(target, 1, 1, true, self.name, true)
      player.room:recastCard(card, target, self.name)
    end
  end,
}
chenqun:addSkill(dingpin)
chenqun:addSkill(faen)

chenqun:addCompanions("hs__caopi")
chenqun:addCompanions("hs__simayi")
Fk:loadTranslationTable{
  ["wk_heg__chenqun"] = "陈群",
  ["wk_heg__dingpin"] = "定品",
  [":wk_heg__dingpin"] = "结束阶段，你可以横置你与一名其他角色，令其于此回合结束后执行一个额外的回合，此额外回合：出牌阶段开始时，若其与你势力相同，其推举，然后与选用的角色各摸一张牌，若未被选用，其结束此阶段；回合结束时，其叠置",
  ["wk_heg__faen"] = "法恩",
  [":wk_heg__faen"] = "与你势力相同的角色：1.横置后，其可以重铸一张牌；2.叠置后，你可以令其弃置两张牌，然后其平置",

  ["@@wk_heg__dingpin_extra"] = "定品",
  ["#wk_heg__dingpin-invoke"] = "定品：是否令一名其他角色执行一个额外的回合",
  ["#wk_heg__dingpin-choose"] = "定品：选择一名不处于横置状态的其他角色",

  ["#wk_heg__faen_turn-invoke"] = "法恩：是否令其弃置两张牌，然后其平置",
  ["#wk_heg__faen_chained-invoke"] = "法恩：是否重铸一张牌",

  ["$wk_heg__dingpin1"] = "取才赋值，论能行赏。",
  ["$wk_heg__dingpin2"] = "定品寻良骥，中正探人杰。",
  ["$wk_heg__faen1"] = "礼法容情，皇恩浩荡。",
  ["$wk_heg__faen2"] = "法理有度，恩威并施。",
  ["~wk_heg__chenqun"] = "吾身虽陨，典律昭彰。",
}

local yangyi = General(extension, "wk_heg__yangyi", "shu", 3, 3, General.Male)
local juanxia = fk.CreateTriggerSkill{
  name = "wk_heg__juanxia",
  anim_type = "offensive",
  events = {fk.EventPhaseStart},
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(self.name) and player.phase == Player.Finish
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local targets = {}
    local slash = Fk:cloneCard("slash")
    for _, p in ipairs(room:getOtherPlayers(player)) do
      if not player:isProhibited(p, slash) then
        table.insert(targets, p.id)
      end
    end
    local tos = room:askForChoosePlayers(player, targets, 1, 1, "#wk_heg__juanxia-choose", self.name, true)
    local to = {tos}
    slash.skillName = self.name
    room:useCard({
      from = target.id,
      tos = table.map(to[1], function(pid) return { pid } end),
      card = slash,
      extraUse = true,
    })
    local choices = {"wk_heg__juanxia_askCommand", "Cancel"}
    local aim = room:getPlayerById(tos[1])
    if room:askForChoice(aim, choices, self.name) ~= "Cancel" then
      if not H.askCommandTo(aim, player, self.name) then
        room:damage{
          from = aim,
          to = player,
          damage = 1,
          skillName = self.name,
        }
      end
    end
  end,
}

--- 交换主副将
---@param room Room
---@param player ServerPlayer
local function SwapMainAndDeputy(room, player)
  local orig1 = player.general
  local orig2 = player.deputyGeneral
  if not orig1 then return false end
  if not orig2 then return false end
  if orig1 == "anjiang" then player:revealGeneral(false, true) end
  if orig2 == "anjiang" then player:revealGeneral(true, true) end
  if string.find(player.general, "lord") then return end
  local general1 = player.general
  local general2 = player.deputyGeneral
  room:changeHero(player, "blank_shibing", false, true, false, false, false)
  room:changeHero(player, general2, false, false, true, false, false)
  room:changeHero(player, general1, false, true, true, false, false)
  
end

local fenduan = fk.CreateTriggerSkill{
  name = "wk_heg__fenduan",
  anim_type = "offensive",
  relate_to_place = "m",
  events = {"fk.ChooseDoCommand", "fk.AfterCommandUse"},
  can_trigger = function (self, event, target, player, data)
    if event == "fk.ChooseDoCommand" then
      return player:hasSkill(self) and data.to == player and not player.chained
    else
      return player:hasSkill(self) and data.to == player
    end
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
      room:setPlayerMark(player, "StopCommand", 1)
      player:setChainState(true)
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
  events = {fk.EventPhaseStart, fk.EventPhaseEnd, fk.CardUsing},
  can_trigger = function (self, event, target, player, data)
    if event == fk.EventPhaseStart then
      return player:hasSkill(self) and player.phase == Player.Play
    elseif event == fk.EventPhaseEnd then
      return player:hasSkill(self) and player.phase == Player.Play and player:getMark("wk_heg__choucuo_use-phase") >= player.hp
    else
      return player:hasSkill(self) and player:getMark("wk_heg__choucuo_draw-phase") > 0 and target == player
    end
  end,
  on_cost = function (self, event, target, player, data)
    if event == fk.EventPhaseStart then
      return player.room:askForSkillInvoke(player, self.name, nil, "#wk_heg__choucuo-invoke")
    else
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    if event == fk.EventPhaseStart then
      local cards = player:drawCards(2)
      player:showCards(cards)
      room:setPlayerMark(player, "wk_heg__choucuo_draw-phase", 1)
      if #cards > 0 then
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
      end

    elseif event == fk.EventPhaseEnd then
      SwapMainAndDeputy(room, player)
    else
      room:addPlayerMark(player, "wk_heg__choucuo_use-phase", 1)
    end
  end,

  refresh_events = {fk.AfterCardsMove},
  can_refresh = function(self, event, target, player, data)
    if player.dead or type(player:getMark("wk_heg__choucuo-phase")) ~= "table" then return false end
    local mark = player:getMark("wk_heg__choucuo-phase")
    for _, move in ipairs(data) do
      if move.from == player.id then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerHand and table.contains(mark, info.cardId) then
            return true
          end
        end
      end
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local mark = player:getMark("wk_heg__choucuo-phase")
    for _, move in ipairs(data) do
      if move.from == player.id then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerHand then
            table.removeOne(mark, info.cardId)
          end
        end
      end
    end
    room:setPlayerMark(player, "wk_heg__choucuo-phase", #mark > 0 and mark or 0)
  end,
}

local choucuo_prohibit = fk.CreateProhibitSkill{
  name = "#wk_heg__choucuo_prohibit",
  prohibit_use = function(self, player, card)
    if player:getMark("wk_heg__choucuo-phase") == 0 then return false end 
    local cards = card:isVirtual() and card.subcards or {card.id}
    return table.find(cards, function(id) return Fk:getCardById(id):getMark("@@wk_heg__choucuo_inhand-phase") == 0 end)
  end,
}

yangyi:addSkill(juanxia)
yangyi:addSkill(fenduan)
choucuo:addRelatedSkill(choucuo_prohibit)
yangyi:addSkill(choucuo)
Fk:loadTranslationTable{
  ["wk_heg__yangyi"] = "杨仪",
  ["wk_heg__juanxia"] = "狷狭",
  [":wk_heg__juanxia"] = "结束阶段，你可以视为使用一张无距离限制的【杀】，若如此做，其可以令你执行一次“军令”，若你不执行，其对你造成1点伤害。",
  ["wk_heg__fenduan"] = "忿断",
  [":wk_heg__fenduan"] = "主将技，当你选择执行“军令”时，若你未横置，你可以改为横置；当你成为“军令”的目标结算完成后，你令此“军令”的发起者弃置两张手牌，然后你交换主副将。",
  ["wk_heg__choucuo"] = "筹措",
  [":wk_heg__choucuo"] = "副将技，出牌阶段开始时，你可以摸两张牌并展示之，若如此做，你不能使用其它牌直至你失去这些牌或此阶段结束，且此阶段结束时，若你于此阶段内使用的牌数不小于体力值，你交换主副将。",

  ["#wk_heg__juanxia-choose"] = "狷狭：选择一名其他角色，视为对其使用一张【杀】",
  ["wk_heg__juanxia_askCommand"] = "发起军令",

  ["#wk_heg__fenduan-invoke"] = "忿断：是否将此次执行的军令改为横置",
  ["#wk_heg__choucuo-invoke"] = "筹措：是否摸两张牌",

  ["@@wk_heg__choucuo_inhand-phase"] = "筹措",

  ["$wk_heg__juanxia1"] = "汝有何功，竟能居我之上！",
  ["$wk_heg__juanxia2"] = "恃才傲立，恩怨必偿。",
  ["$wk_heg__fenduan1"] = "丞相新丧，吾当继之",
  ["$wk_heg__fenduan2"] = "规划分布，筹度粮谷。",
  ["$wk_heg__choucuo1"] = "早知如此，投靠魏国又如何！",
  ["$wk_heg__choucuo2"] = "我岂能与魏延这等莽夫共事。",

  ["~wk_heg__yangyi"] = "魏延庸奴，吾势杀汝！",
}

return extension
