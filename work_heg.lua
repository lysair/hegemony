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
--   events = {fk.Damage, fk.DamageCaused},
  events = {fk.Damage},
  can_trigger = function (self, event, target, player, data)
    -- if event == fk.Damage then
    return target == player and player:hasSkill(self) and data.to ~= player and not data.to.dead and not data.to:isNude()
    -- else
    --   return target == player and player:hasSkill(self) and player:getMark("poyuan-turn") == 0 and H.isBigKingdomPlayer(data.to) and player == player.room.current
    -- end
  end,
--   on_cost = function (self, event, target, player, data)
--     if event == fk.Damage then
--       return player.room:askForSkillInvoke(player, self.name, nil, "#wk_heg__poyuan-discard")
--     else
--       return true
--     end
--   end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    -- if event == fk.Damage then
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
    -- else
    --   room:setPlayerMark(player, "poyuan-turn", 1)
    --   data.damage = data.damage + 1
    -- end
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
  -- [":wk_heg__poyuan"] = "①当你对其他角色造成伤害后，你可选择一项：1.弃置其一张装备区内的牌；2.令其弃置一张手牌；②当你于回合内首次对大势力角色造成伤害时，此伤害+1。",
  [":wk_heg__poyuan"] = "当你对其他角色造成伤害后，你可选择一项：1.弃置其一张装备区内的牌；2.令其弃置一张手牌。",
  ["wk_heg__choulue"] = "筹略",
  [":wk_heg__choulue"] = "①当你受到伤害后，若你的“阴阳鱼”标记数小于你体力上限，你可获得一个“阴阳鱼”标记；②当与你势力相同的角色使用普通锦囊牌指定唯一目标后，你可移去一个“阴阳鱼”标记，令此牌结算两次。",

  ["#wk_heg__poyuan-discard"] = "破垣：是否令受伤角色弃置一张手牌，或你弃置受伤角色装备区内一张牌",
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
  events = {fk.EventPhaseStart, fk.EventPhaseEnd},
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(self) and player.phase == Player.Discard and (event == fk.EventPhaseStart or player:getMark("wk_heg__yizan-phase"))
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

juanshe:addRelatedSkill(juanshe_prohibit)
dongyun:addSkill(yizan)
dongyun:addSkill(juanshe)
Fk:loadTranslationTable{
  ["wk_heg__dongyun"] = "董允",
  ["#wk_heg__dongyun"] = "匡主正堂",
  ["designer:wk_heg__dongyun"] = "修功&风箫",

  ["wk_heg__yizan"] = "翼赞",
  [":wk_heg__yizan"] = "弃牌阶段开始时，你可令一名手牌数小于你的角色将手牌摸至与你相同（至多摸五张），然后此阶段结束时，若你于此阶段内弃置过牌，其将手牌弃至体力上限。",
  ["wk_heg__juanshe"] = "蠲奢",
  [":wk_heg__juanshe"] = "与你势力相同角色的结束阶段，若其本回合使用牌数小于其手牌上限，你可令其弃置一张手牌并回复1点体力，然后直至其回合开始或你受到伤害，其不能使用手牌。",

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
        local to = room:askForChoosePlayers(target, targets, 1, 1, "#wk_heg__mingzheng-choose", self.name, true)
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
  events = {fk.TargetSpecified, fk.TurnEnd},
  can_trigger = function (self, event, target, player, data)
    if event == fk.TargetSpecified then
      if not (player:hasSkill(self) and target ~= player and target.phase == Player.Play and data.card.trueName == "slash" and data.firstTarget) then return false end
      local events = target.room.logic:getEventsOfScope(GameEvent.UseCard, 1, function(e) 
        local use = e.data[1]
        return use.from == target.id and use.card.trueName == "slash"
      end, Player.HistoryTurn)
      return #events == 1 and events[1].id == target.room.logic:getCurrentEvent().id
    elseif event == fk.TurnEnd then
      return player:getMark("@@wk_heg__yujian_exchange-turn") > 0
    end
  end,
  on_cost = function (self, event, target, player, data)
    if event == fk.TargetSpecified then
      return player.room:askForSkillInvoke(player, self.name, nil, "#wk_heg__yujian-invoke")
    else
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local current = room.current
    if event == fk.TargetSpecified then
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
  ["#wk_heg__luotong"] = "达弼政辅",
  ["designer:wk_heg__luotong"] = "教父",

  ["wk_heg__mingzheng"] = "明政",
  [":wk_heg__mingzheng"] = "与你势力相同的角色：1.明置武将牌后，若其武将牌均明置，其复原武将牌，然后获得一个“阴阳鱼”标记; 2.出牌阶段开始时，其观看除其外一名与你势力相同的角色的手牌。",
  ["wk_heg__yujian"] = "御谏",
  [":wk_heg__yujian"] = "其他角色于其出牌阶段内使用首张【杀】指定目标后，你可依次执行每个满足条件的项：1.若其体力值不大于你，你可以与其交换手牌，若如此做，此回合结束时，你与其交换手牌；"..
  "2.若其武将牌均明置，你可以暗置其一张武将牌且直至本回合结束不能明置之。",

  ["#wk_heg__mingzheng-choose"] = "明政：选择一名与你势力相同的其他角色观看手牌",
  ["wk_heg__mingzheng-hand"] = "明政：观看%dest的手牌",
  ["wk_heg__yujian_hide"] = "暗置%dest一张武将牌且本回合不能明置",

  ["@@wk_heg__yujian_exchange-turn"] = "御谏 交换手牌",

  ["#wk_heg__yujian-invoke"] = "御谏：你可根据条件与当前回合角色交换手牌或暗置当前回合角色武将牌",
  ["@wk_heg__yujian_reveal-turn"] = "御谏 禁亮",

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
  ["#wk_heg__jvshou"] = "志北挽魂",
  ["designer:wk_heg__jvshou"] = "教父&小曹神",

  ["wk_heg__tugui"] = "图归",
  [":wk_heg__tugui"] = "①每回合限一次，当你失去最后的手牌后或当你进入濒死状态后，你可获得与你距离为1的其他角色的一张手牌并展示之；②出牌阶段结束时，若你未失去以此法获得的所有牌，你移除此武将牌。",
  ["wk_heg__yingshou"] = "营守",
  [":wk_heg__yingshou"] = "结束阶段，你可令一名与你势力相同的角色摸两张牌，若如此做，当其于下个回合的出牌阶段内造成伤害后，其弃置一张牌。",

  ["#wk_heg__tugui-ask"] = "图归：是否获得与你距离为1的其他角色的一张手牌",
  ["#wk_heg__tugui-choose"] = "图归：选择一名与你距离为1的其他角色",

  ["#wk_heg__yingshou-choose"] = "营守：选择一名与你势力相同的角色",
  ["@@wk_heg__yingshou"] = "营守",

  ["$wk_heg__tugui1"] = "矢志于北，尽忠于国。",
  ["$wk_heg__tugui2"] = "命系袁氏，一心向北。",
  ["$wk_heg__yingshou1"] = "由缓至急，循循而进。",
  ["$wk_heg__yingshou2"] = "事须缓图，欲速不达也。",
  ["~wk_heg__jvshou"] = "智士凋亡，河北哀矣…",
}

--- 推举
---@param room Room
---@param player ServerPlayer
---@param skillName string
---@return ServerPlayer?
local function DoElectedChange(room, player, skillName)
  local generals = room:findGenerals(function(g)
    return Fk.generals[g].kingdom == player.kingdom
  end, 1)
  local general = room:askForGeneral(player, generals, 1, true) ---@type string
  room:sendLog{
    type = "#ElectedChange",
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
    local choice = room:askForChoice(p, {"#elected_change:::" .. general, "Cancel"}, "ElectedChange", "#elected_change-ask:" .. player.id .. "::" .. general)
    if choice ~= "Cancel" then
      generals = {H.getActualGeneral(p, true)}
      room:changeHero(p, general, false, true, true, false)
      ret = p
      break
    end
  end
  room:returnToGeneralPile(generals)
  return ret
end

Fk:loadTranslationTable{
  ["ElectedChange"] = "推举",
  ["#ElectedChange"] = "%from 由于 “%arg2”，推举了 %arg",
  ["#elected_change"] = "将%arg作为副将",
  ["#elected_change-ask"] = "%src 推举了 %arg，你可 选用 为你的副将",
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
    local targets = table.map(table.filter(room.alive_players, function(p) return p ~= player and not p.chained end), Util.IdMapper)
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
    to:setChainState(true)
    room:setPlayerMark(to, "_wk_heg__dingpin", player.id)
    U.gainAnExtraTurn(to, true, self.name)
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
      local p = DoElectedChange(room, target, self.name)
      if p then
        if not target.dead then
          target:drawCards(1, self.name)
        end
        if p ~= target and not p.dead then
          p:drawCards(1, self.name)
        end
      end
    elseif event == fk.TurnEnd then
      if target:getHandcardNum() > target.maxHp then
        room:askForDiscard(target, target:getHandcardNum() - target.maxHp, target:getHandcardNum() - target.maxHp, false, self.name, false)
      end
      if target:getHandcardNum() < target.maxHp then
        target:drawCards(target.maxHp - target:getHandcardNum(), self.name)
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
  [":wk_heg__dingpin"] = "结束阶段，你可横置你与一名其他角色，令其于此回合结束后执行一个仅有出牌阶段的额外回合，此额外回合：1.出牌阶段开始时，若其与你势力相同，其推举，然后与选用的角色各摸一张牌；2.回合结束时，其将手牌数摸或弃至体力上限，然后叠置。<br />" ..
  "<font color = 'gray'>推举：推举角色展示一张与其势力相同的武将牌，每名与其势力相同的角色选择是否将此武将牌作为其新的副将。" ..
  "若有角色选择是，称为该角色<u>选用</u>，停止对后续角色的访问，结束推举流程。</font>",
  ["wk_heg__faen"] = "法恩",
  [":wk_heg__faen"] = "与你势力相同的角色：1.横置后，其可重铸一张牌；2.叠置后，你可令其弃置两张牌，然后其平置。",

  ["@@wk_heg__dingpin_extra"] = "定品",
  ["#wk_heg__dingpin-choose"] = "定品：你可以选择一名其他角色，横置你与其，令其于此回合结束后执行一个仅有出牌阶段的额外的回合",
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
          n = n + 1
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
    player:drawCards(math.min(#self.cost_data, player.maxHp), self.name)
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
    local p = DoElectedChange(player.room, target, self.name)
    if p and player.hp < player.maxHp then
      player.room:recover{
        who = player,
        num = 1,
        recoverBy = player,
        skillName = self.name,
      }
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
  [":wk_heg__yuyan"] = "当你于回合外获得其他角色的牌后，你可将等量张牌交给当前回合角色，若如此做，此回合结束时，若其与你势力相同，你推举，若被选用，你回复1点体力。<br />"..
    "<font color = 'gray'>推举：推举角色展示一张与其势力相同的武将牌，每名与其势力相同的角色选择是否将此武将牌作为其新的副将。" ..
  "若有角色选择是，称为该角色<u>选用</u>，停止对后续角色的访问，结束推举流程。</font>",
  ["wk_heg__caixia"] = "才瑕",
  [":wk_heg__caixia"] = "每回合限一次，当你造成或受到伤害后，你可展示任意张同名手牌，然后摸等量的牌（至多摸你体力上限数张）。",

  ["#wk_heg__yuyan-give"] = "誉言：交给 %dest 共计 %arg 张牌",

  ["#wk_heg__caixia"] = "才瑕：你可以展示任意张同名手牌，然后摸等量的牌。",
}

local huanfan = General(extension, "wk_heg__huanfan", "wei", 3, 3, General.Male)
local liance_viewas = fk.CreateViewAsSkill{
  name = "wk_heg__liance_viewas",
  interaction = function()
    local names = {}
    local mark = Self:getMark("liance-phase")
    for _, id in ipairs(Fk:getAllCardIds()) do
      local card = Fk:getCardById(id, true)
      if table.contains(mark, card.trueName) then
        table.insertIfNeed(names, card.name)
      end
    end
    if table.contains(mark, "sa__drowning") then
      table.insertIfNeed(names, "sa__drowning")
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
  on_use = function(self, event, target, player, data)
    local room = player.room
    local discards = room:askForDiscard(player, 1, 1, true, self.name, false)
    if #discards == 1 then
      player.room:setPlayerMark(target, "liance-phase", self.cost_data)
      local success, dat = player.room:askForUseActiveSkill(target, "wk_heg__liance_viewas", "#wk_heg__liance-choose", true)
      if not success then
        H.askCommandTo(player, target, self.name, true)
      else
        local card = Fk.skills["wk_heg__liance_viewas"]:viewAs(self.cost_data.cards)
          room:useCard{
          from = target.id,
          tos = table.map(dat.targets, function(id) return {id} end),
          card = card,
        }
      end
    end
  end,
}

local shilun_active = fk.CreateActiveSkill{
  name = "wk_heg__shilun_active",
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
    local _, ret = room:askForUseActiveSkill(player, "wk_heg__shilun_active", "#wk_heg__shilun_active-choose", false)
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
        local dummy = Fk:cloneCard("dilu")
        dummy:addSubcards(get)
        room:obtainCard(player, dummy, false, fk.ReasonPrey)
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

  ["#wk_heg__liance"] = "连策：是否弃置一张牌令当前回合视为使用同名牌",
  ["#wk_heg__shilun_active-choose"] = "世论：选择花色各不相同的手牌各一张",
  ["#wk_heg__shilun-move"] = "世论：你可以移动场上一张牌",

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
  ["$wk_heg__fenduan1"] = "丞相新丧，吾当继之。",
  ["$wk_heg__fenduan2"] = "规划分部，筹度粮谷。",
  ["$wk_heg__choucuo1"] = "早知如此，投靠魏国又如何！",
  ["$wk_heg__choucuo2"] = "我岂能与魏延这种莽夫共事。",

  ["~wk_heg__yangyi"] = "魏延庸奴，吾，誓杀汝！",
}

local kuaizi = General(extension, "wk_heg__kuaizi", "qun", 3, 3, General.Male)
local yonglun = fk.CreateTriggerSkill{
  name = "wk_heg__yonglun",
  events = {fk.CardUseFinished},
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player:usedSkillTimes(self.name, Player.HistoryTurn) == 0
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    room:loseHp(player, 1)
    local targets = table.map(room:getOtherPlayers(player), Util.IdMapper)
    local tos = room:askForChoosePlayers(player, targets, 1, 1, "#wk_heg__yonglun_choose", self.name, true)
    local to = room:getPlayerById(tos[1])
    local num = #table.filter(to:getCardIds(Player.Hand), function(id)
      return Fk:getCardById(id).type == Card.TypeBasic end)
    if num > 0 then
      local card = room:askForCard(to, 1, 1, false, self.name, false, ".|.|.|.|.|basic", "#wk_heg__yonglun-give")
      room:moveCardTo(card, Player.Hand, player, fk.ReasonGive, self.name, nil, false, tos[1])
      local mark = {}
      table.insert(mark, card[1])
      room:setCardMark(Fk:getCardById(card[1]), "@@alliance", 1)
      room:setPlayerMark(player, "wk_heg__yonglun", mark)
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
    if player.dead or type(player:getMark("wk_heg__yonglun")) ~= "table" then return false end
    local mark = player:getMark("wk_heg__yonglun")
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
    local mark = player:getMark("wk_heg__yonglun")
    table.forEach(self.cost_data, function(id) table.removeOne(mark, id) end)
    table.forEach(self.cost_data, function(id) player.room:setCardMark(Fk:getCardById(id), "@@alliance", 0) end)
    player.room:setPlayerMark(player, "wk_heg__yonglun", #mark > 0 and mark or 0)
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
    return data.from:getMark("wk_heg__shenshi_draw-turn") > 0 and H.compareKingdomWith(data.to, player)
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
      local isDeputy = H.inGeneralSkills(player, shenshi.name)
      if isDeputy then
        isDeputy = isDeputy == "d"
        player:hideGeneral(isDeputy)
      end
      local record = U.getMark(player, MarkEnum.RevealProhibited)
      table.insert(record, isDeputy and "d" or "m")
      room:setPlayerMark(player, MarkEnum.RevealProhibited, record)
      room:setPlayerMark(player, "@wk_heg__shenshi_reveal", H.getActualGeneral(player, isDeputy))
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
kuaizi:addSkill(yonglun)
kuaizi:addSkill(shenshi)

Fk:loadTranslationTable{
  ["wk_heg__kuaizi"] = "蒯越蒯良",
  ["#wk_heg__kuaizi"] = "雍论臼谋",
  ["designer:wk_heg__kuaizi"] = "教父&风箫",

  ["wk_heg__yonglun"] = "纵迫",
  [":wk_heg__yonglun"] = "每回合限一次，当你使用牌结算后，你可失去1点体力，令一名其他角色交给你一张基本牌，此牌于你的手牌区内视为拥有“合纵”标记，然后其获得你使用的牌。",
  ["wk_heg__shenshi"] = "审时",
  [":wk_heg__shenshi"] = "其他角色获得你的牌后，若你与其的大小势力状态不同，你可令其摸一张牌，若如此做，此回合结束时，若此回合内所有以此法摸牌的角色于以此法摸牌后未对与你势力相同的角色造成过伤害，与你势力相同的角色各摸一张牌，否则你暗置此武将牌且不能明置直至你回合开始。",

  ["@wk_heg__shenshi_reveal"] = "审时 禁亮",
  ["#wk_heg__yonglun_choose"] = "纵迫：选择一名其他角色，令其交给你一张基本牌",
  ["#wk_heg__yonglun-give"] = "纵迫：交给蒯越蒯良一张基本牌",

  ["#wk_heg__shenshi_delay"] = "审时",
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

zhuran:addSkill(danshou)
Fk:loadTranslationTable{
  ["wk_heg__zhuran"] = "朱然",
  ["#wk_heg__zhuran"] = "胆略无双",
  ["designer:wk_heg__zhuran"] = "教父&二四",

  ["wk_heg__danshou"] = "胆守",
  [":wk_heg__danshou"] = "当你成为其他角色使用牌的目标后，你可将手牌弃置至X张，对其造成1点伤害（X为你本回合成为过牌目标的次数）；一名角色的回合结束时，若你此回合内受到过伤害，你可摸一张牌。",

  ["#wk_heg__danshou-damage"] = "胆守：你可以弃置 %arg 张牌，对 %dest 造成1点伤害",
  ["#wk_heg__danshou"] = "胆守：是否摸一张牌"
}
return extension
