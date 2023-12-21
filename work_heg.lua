local H = require "packages/hegemony/util"
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

return extension
