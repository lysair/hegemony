local extension = Package:new("transformation")
extension.extensionName = "hegemony"
extension.game_modes_whitelist = { 'nos_heg_mode', 'new_heg_mode' }

extension:loadSkillSkelsByPath("./packages/hegemony/pkg/transformation/skills")

Fk:loadTranslationTable{
  ["transformation"] = "君临天下·变",
  ["transformDeputy"] = "变更副将",
}
local xunyou = General:new(extension, "ld__xunyou", "wei", 3)
xunyou:addSkills{"ld__qice", "ld__zhiyu"}
xunyou:addCompanions("hs__xunyu")

Fk:loadTranslationTable{
  ["ld__xunyou"] = "荀攸",
  ["#ld__xunyou"] = "曹魏的谋主",
  ["designer:ld__xunyou"] = "淬毒",
  ["illustrator:ld__xunyou"] = "心中一凛",
  ["~ld__xunyou"] = "主公，臣下……先行告退……",
}

local bianfuren = General:new(extension, "ld__bianfuren", "wei", 3)
bianfuren:addCompanions("hs__caocao")
bianfuren:addSkills{"ld__wanwei", "ld__yuejian"}

Fk:loadTranslationTable{
  ["ld__bianfuren"] = "卞夫人",
  ["#ld__bianfuren"] = "奕世之雍容",
  ["illustrator:ld__bianfuren"] = "雪君S",
  ["~ld__bianfuren"] = "子桓，兄弟之情，不可轻忘…",
}

local shamoke = General:new(extension, "ld__shamoke", "shu", 4)

shamoke:addSkill("ld__jilis")
Fk:loadTranslationTable{
  ['ld__shamoke'] = '沙摩柯',
  ["#ld__shamoke"] = "五溪蛮王",
  ["illustrator:ld__shamoke"] = "LiuHeng",
  ["designer:ld__shamoke"] = "韩旭",
  ['~ld__shamoke'] = '五溪蛮夷，不可能输！',
}

General:new(extension, "ld__masu", "shu", 3):addSkills{"ld__sanyao", "ld__zhiman"}
Fk:loadTranslationTable{
  ['ld__masu'] = '马谡',
  ["#ld__masu"] = "帷幄经谋",
  ["designer:ld__masu"] = "点点",
  ["illustrator:ld__masu"] = "蚂蚁君",
  ["~ld__masu"] = "败军之罪，万死难赎……" ,
}

local lingtong = General:new(extension, "ld__lingtong", "wu", 4)
lingtong:addSkills{"xuanlve", "yongjin"}
lingtong:addCompanions("hs__ganning")
Fk:loadTranslationTable{
  ['ld__lingtong'] = '凌统',
  ["#ld__lingtong"] = "豪情烈胆",
  ["designer:ld__lingtong"] = "韩旭",
  ["illustrator:ld__lingtong"] = "F.源",
  ["~ld__lingtong"] = "大丈夫，不惧死亡……",
}

local lvfan = General:new(extension, "ld__lvfan", "wu", 3)
lvfan:addSkills{"diaodu", "diancai"}

Fk:loadTranslationTable{
  ['ld__lvfan'] = '吕范',
  ["#ld__lvfan"] = "忠笃亮直",
  ["designer:ld__lvfan"] = "韩旭",
  ["illustrator:ld__lvfan"] = "铭zmy",
  ["~ld__lvfan"] = "闻主公欲授大司马之职，容臣不能……谢恩了……",
}

local zuoci = General:new(extension, "ld__zuoci", "qun", 3)
zuoci:addCompanions("ld__yuji")
zuoci:addSkills{"ld__xinsheng", "ld__huashen"}
Fk:loadTranslationTable{
  ["ld__zuoci"] = "左慈",
  ["#ld__zuoci"] = "鬼影神道",
  ["illustrator:ld__zuoci"] = "吕阳",
  ["~ld__zuoci"] = "仙人之逝，魂归九天…",
}

local lijueguosi = General:new(extension, "ld__lijueguosi", "qun", 4)
lijueguosi:addCompanions("hs__jiaxu")
lijueguosi:addSkill("xiongsuan")
Fk:loadTranslationTable{
  ['ld__lijueguosi'] = '李傕郭汜',
  ["#ld__lijueguosi"] = "犯祚倾祸",
  ["designer:ld__lijueguosi"] = "千幻",
  ["illustrator:ld__lijueguosi"] = "旭",
  ["~ld__lijueguosi"] = "异心相争，兵败战损……",
}
--[[
local lordsunquan = General:new(extension, "ld__lordsunquan", "wu", 4)
lordsunquan.hidden = true
H.lordGenerals["hs__sunquan"] = "ld__lordsunquan"

local jiahe = fk.CreateTriggerSkill{
  name = "jiahe",
  anim_type = "support",
  frequency = Skill.Compulsory,
  events = {fk.GeneralRevealed},
  derived_piles = "lord_fenghuo",
  can_trigger = function (self, event, target, player, data)
    if target == player and player:hasSkill(self, true) then
      for _, v in pairs(data) do
        if table.contains(Fk.generals[v]:getSkillNameList(), self.name) then return true end
      end
    end
  end,
  on_use = function (self, event, target, player, data)
    player.room:handleAddLoseSkills(player, '#fenghuotu')
  end,
}

local fenghuotu = fk.CreateTriggerSkill{
  name = "#fenghuotu",
  anim_type = "support",
  frequency = Skill.Compulsory,
  events = {fk.EventPhaseStart, fk.Damaged},
  can_trigger = function (self, event, target, player, data)
    if event == fk.EventPhaseStart then
      return H.compareKingdomWith(player, target) and player:hasSkill(self) and #player:getPile("lord_fenghuo") > 0 and target.phase == Player.Start
    else
      local type_remove = data.card and (data.card.type == Card.TypeTrick or data.card.trueName == "slash")
      if table.find(player.room.alive_players, function (p) return p:getMark("@@wk_heg__huanglong_change") ~= 0 end) then
        type_remove = data.card and (data.card.trueName == "slash")
      end
      return player == target and player:hasSkill(self) and #player:getPile("lord_fenghuo") > 0 and type_remove
    end
  end,
  on_cost = function (self, event, target, player, data)
    if event == fk.EventPhaseStart then
      return true
    else
      local card = player.room:askForCard(player, 1, 1, false, self.name, false, ".|.|.|lord_fenghuo", "#ld__jiahe_damaged", "lord_fenghuo")
      if #card > 0 then
        self.cost_data = card
        return true
    end
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    if event == fk.EventPhaseStart then
      local skills = {"ld__lordsunquan_yingzi", "ld__lordsunquan_haoshi", "ld__lordsunquan_shelie", "ld__lordsunquan_duoshi"}
      local num = #player:getPile("lord_fenghuo") >= 5 and 2 or 1
      local result = room:askForCustomDialog(target, self.name,
      "packages/utility/qml/ChooseSkillBox.qml", {
        table.slice(skills, 1, #player:getPile("lord_fenghuo") + 1), 0, num, "#fenghuotu-choose:::" .. tostring(num)
      })
      if result == "" then return false end
      local choice = json.decode(result)
      if #choice > 0 then
        room:handleAddLoseSkills(target, table.concat(choice, "|"), nil, true, false)
        room.logic:getCurrentEvent():findParent(GameEvent.Turn):addCleaner(function()
          room:handleAddLoseSkills(target, '-' .. table.concat(choice, "|-"), nil, true, false)
        end)
      end
    else
      room:moveCardTo(self.cost_data, Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile, self.name, "lord_fenghuo", true, player.id)
    end
  end,

  refresh_events = {fk.EventAcquireSkill, fk.EventLoseSkill, fk.Deathed, fk.GeneralRevealed},
  can_refresh = function(self, event, target, player, data)
    if player ~= target then return false end
    if event == fk.Deathed then return player:hasSkill(self, true, true)
    elseif event == fk.EventAcquireSkill or event == fk.EventLoseSkill then return data == self
    else return true end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local players = room.alive_players
    local lordsunquans = table.filter(players, function(p) return p:hasShownSkill(self) end)
    local jiahe_map = {}
    for _, p in ipairs(players) do
      local will_attach = false
      for _, ld in ipairs(lordsunquans) do
        if H.compareKingdomWith(ld, p) then
          will_attach = true
          break
        end
      end
      jiahe_map[p] = will_attach
    end
    for p, v in pairs(jiahe_map) do
      if v ~= p:hasSkill("ld__jiahe_other&") then
        room:handleAddLoseSkills(p, v and "ld__jiahe_other&" or "-ld__jiahe_other&", nil, false, true)
      end
    end
  end,
}

local jiaheOther = fk.CreateActiveSkill{
  name = "ld__jiahe_other&",
  prompt = function()
    local to = H.getHegLord(Fk:currentRoom(), Self)
    return "#ld__jiahe_other:" .. to.id
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0 and H.getHegLord(Fk:currentRoom(), player) and H.getHegLord(Fk:currentRoom(), player):hasSkill("jiahe")
  end,
  card_num = 1,
  card_filter = function(self, to_select, selected)
    return #selected < 1 and Fk:getCardById(to_select).type == Card.TypeEquip
  end,
  target_num = 0,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local to = H.getHegLord(room, player)
    if to and to:hasSkill("jiahe") then
      to:addToPile("lord_fenghuo", effect.cards, true, self.name)
    end
  end,
}

local ld__yingzi = fk.CreateTriggerSkill{
  name = "ld__lordsunquan_yingzi",
  anim_type = "drawcard",
  frequency = Skill.Compulsory,
  events = {fk.DrawNCards},
  on_use = function(self, event, target, player, data)
    data.n = data.n + 1
  end,

  refresh_events = {fk.EventPhaseStart},
  can_refresh = function(self, event, target, player, data)
    return player == target and player:hasSkill(self) and player.phase == Player.Discard and not player:isFakeSkill(self.name)
  end,
  on_refresh = function(self, event, target, player, data)
    player:broadcastSkillInvoke(self.name)
    player.room:notifySkillInvoked(player, self.name, "defensive")
  end,
}
local ld__yingzi_maxcards = fk.CreateMaxCardsSkill{
  name = "#ld__lordsunquan_yingzi_maxcards",
  fixed_func = function(self, player)
    if player:hasSkill("ld__lordsunquan_yingzi") then
      return player.maxHp
    end
  end
}

local ld__haoshi = fk.CreateTriggerSkill{
  name = "ld__lordsunquan_haoshi",
  anim_type = "drawcard",
  events = {fk.DrawNCards},
  on_use = function(self, event, target, player, data)
    data.n = data.n + 2
  end,
}
local ld__haoshi_delay = fk.CreateTriggerSkill{
  name = "#ld__lordsunquan_haoshi_delay",
  events = {fk.AfterDrawNCards},
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return not player.dead and player:usedSkillTimes(ld__haoshi.name, Player.HistoryPhase) > 0 and
    #player.player_cards[Player.Hand] > 5 and #player.room.alive_players > 1
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local x = player:getHandcardNum() // 2
    local targets = {}
    local n = 0
    for _, p in ipairs(room.alive_players) do
      if p ~= player then
        if #targets == 0 then
          table.insert(targets, p.id)
          n = p:getHandcardNum()
        else
          if p:getHandcardNum() < n then
            targets = {p.id}
            n = p:getHandcardNum()
          elseif p:getHandcardNum() == n then
            table.insert(targets, p.id)
          end
        end
      end
    end
    local tos, cards = room:askForChooseCardsAndPlayers(player, x, x, targets, 1, 1,
    ".|.|.|hand", "#haoshi-give:::" .. x, "ld__lordsunquan_haoshi", false)
    room:moveCardTo(cards, Card.PlayerHand, room:getPlayerById(tos[1]), fk.ReasonGive, "haoshi", nil, false, player.id)
  end,
}
local ld__shelie = fk.CreateTriggerSkill{
  name = "ld__lordsunquan_shelie",
  anim_type = "drawcard",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Draw
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = room:getNCards(5)
    room:moveCards({
      ids = cards,
      toArea = Card.Processing,
      moveReason = fk.ReasonPut,
      skillName = self.name,
      proposer = player.id,
    })
    local get = {}
    for _, id in ipairs(cards) do
      local suit = Fk:getCardById(id).suit
      if table.every(get, function (id2)
        return Fk:getCardById(id2).suit ~= suit
      end) then
        table.insert(get, id)
      end
    end
    get = room:askForArrangeCards(player, self.name, cards, "#ld__lordsunquan_shelie-choose",
      false, 0, {5, 4}, {0, #get}, ".", "shelie", {{}, get})[2]
    if #get > 0 then
      room:obtainCard(player, get, true, fk.ReasonPrey)
    end
    cards = table.filter(cards, function(id) return room:getCardArea(id) == Card.Processing end)
    if #cards > 0 then
      room:moveCardTo(cards, Card.DiscardPile, nil, fk.ReasonJustMove, self.name)
    end
    return true
  end,
}

local ld__duoshi = fk.CreateTriggerSkill{
  name = "ld__lordsunquan_duoshi",
  anim_type = "drawcard",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    local card = Fk:cloneCard("await_exhausted")
    return player:hasSkill(self) and player == target and player.phase == Player.Play and not player:prohibitUse(card)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room.alive_players, function(p) return
      H.compareKingdomWith(p, player) end)
    room:useVirtualCard("await_exhausted", {}, player, targets, self.name)
  end,
}

local lianzi = fk.CreateActiveSkill{
  name = "lianzi",
  anim_type = "drawcard",
  card_num = 1,
  target_num = 0,
  prompt = function()
    local show_num = #Self:getPile("lord_fenghuo")
    for _, p in ipairs(Fk:currentRoom().alive_players) do
      if H.compareKingdomWith(p, Self) then
        show_num = show_num + #p.player_cards[Player.Equip]
      end
    end
    return "#lianzi:::" .. show_num
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0 and not player:isKongcheng()
  end,
  card_filter = function(self, to_select, selected)
    return #selected == 0 and not Self:prohibitDiscard(to_select) and Fk:currentRoom():getCardArea(to_select) == Player.Hand
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local cardType = Fk:getCardById(effect.cards[1]).type
    room:throwCard(effect.cards, self.name, player)
    if player.dead then return end
    local show_num = #player:getPile("lord_fenghuo")
    for _, p in ipairs(room.alive_players) do
      if H.compareKingdomWith(p, player) then
        show_num = show_num + #p.player_cards[Player.Equip]
    end
    end
    if show_num == 0 then return end
    local cards = room:getNCards(show_num)
    room:turnOverCardsFromDrawPile(player, cards, lianzi.name)
    local to_get = table.filter(cards, function (id)
      return Fk:getCardById(id, true).type == cardType
    end)
    if #to_get > 0 then
      room:obtainCard(player.id, to_get, true, fk.ReasonJustMove)
      if #to_get > 3 then
        room:handleAddLoseSkills(player, "ld__lordsunquan_zhiheng|-lianzi", nil)
      end
    end
    cards = table.filter(cards, function (id)
      return room:getCardArea(id) == Card.Processing
    end)
    if #cards > 0 then
      room:moveCardTo(cards, Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile, self.name)
    end
  end,
}

local ld__zhiheng = fk.CreateActiveSkill{
  name = "ld__lordsunquan_zhiheng",
  anim_type = "drawcard",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  target_num = 0,
  min_card_num = 1,
  max_card_num = function()
    return table.find(Self:getEquipments(Card.SubtypeTreasure), function(cid)
      return Fk:getCardById(cid).name == "luminous_pearl"
    end) and 998 or Self.maxHp
  end,
  card_filter = function(self, to_select, selected)
    if #selected >= Self.maxHp then
      return table.find(Self:getEquipments(Card.SubtypeTreasure), function(cid)
        return Fk:getCardById(cid).name == "luminous_pearl" and not table.contains(selected, cid) and to_select ~= cid
      end)
    end
    return #selected < Self.maxHp and not Self:prohibitDiscard(Fk:getCardById(to_select))
  end,
  on_use = function(self, room, effect)
    local from = room:getPlayerById(effect.from)
    room:throwCard(effect.cards, self.name, from, from)
    if not from.dead then
      from:drawCards(#effect.cards, self.name)
    end
  end
}

local jubao = fk.CreateTriggerSkill{
  name = "jubao",
  anim_type = "drawcard",
  frequency = Skill.Compulsory,
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    if not (target == player and player:hasSkill(self) and player.phase == Player.Finish) then return false end
    for _, id in ipairs(player.room.discard_pile) do
      if Fk:getCardById(id).name == "luminous_pearl" then
        return true
      end
    end
    return table.find(Fk:currentRoom().alive_players, function(p)
      return table.find(p:getEquipments(Card.SubtypeTreasure), function(cid)
        return Fk:getCardById(cid).name == "luminous_pearl"
      end)
    end)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:drawCards(1, self.name)
    local targets = table.map(table.filter(room.alive_players, function(p)
      return table.find(p:getEquipments(Card.SubtypeTreasure), function(cid)
        return Fk:getCardById(cid).name == "luminous_pearl"
      end) end), Util.IdMapper)
    if #targets > 0 then
      for _, pid in ipairs(targets) do
        local p = room:getPlayerById(pid)
        if p == player then
          local card = room:askToChooseCard(player, {
    target = p,
    flag = "e",
    skill_name = self.name,
  })
          room:obtainCard(player.id, card, false, fk.ReasonPrey)
        else
          local card = room:askToChooseCard(player, {
    target = p,
    flag = "he",
    skill_name = self.name,
  })
          room:obtainCard(player.id, card, false, fk.ReasonPrey)
        end
      end
    end
  end,
}

local jubao_move = fk.CreateTriggerSkill{
  name = "#jubao_move",
  events = {fk.BeforeCardsMove},
  frequency = Skill.Compulsory,
  anim_type = "defensive",
  -- main_skill = "jubao",
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self) or not (player:getEquipment(Card.SubtypeTreasure)) then return false end
    for _, move in ipairs(data) do
      if move.from == player.id and move.to ~= move.from and move.toArea == Card.PlayerHand then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerEquip and Fk:getCardById(info.cardId).sub_type == Card.SubtypeTreasure then
            return true
          end
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local ids = {}
    player.room:notifySkillInvoked(player, "jubao", "defensive")
    player:broadcastSkillInvoke("jubao")
    for _, move in ipairs(data) do
      if move.from == player.id and move.to ~= move.from and move.toArea == Card.PlayerHand then
        local move_info = {}
        for _, info in ipairs(move.moveInfo) do
          local id = info.cardId
          if info.fromArea == Card.PlayerEquip and Fk:getCardById(id).sub_type == Card.SubtypeTreasure then
            table.insert(ids, id)
          else
            table.insert(move_info, info)
          end
        end
        if #ids > 0 then
          move.moveInfo = move_info
        end
      end
    end
    if #ids > 0 then
      player.room:sendLog{
        type = "#cancelDismantle",
        card = ids,
        arg = self.name,
      }
    end
  end,
}

ld__yingzi:addRelatedSkill(ld__yingzi_maxcards)
ld__haoshi:addRelatedSkill(ld__haoshi_delay)

lordsunquan:addSkill(jiahe)
Fk:addSkill(fenghuotu)
lordsunquan:addRelatedSkill(ld__yingzi)
lordsunquan:addRelatedSkill(ld__haoshi)
lordsunquan:addRelatedSkill(ld__shelie)
lordsunquan:addRelatedSkill(ld__duoshi)
Fk:addSkill(jiaheOther)

lordsunquan:addSkill(lianzi)
Fk:addSkill(ld__zhiheng)

jubao:addRelatedSkill(jubao_move)
lordsunquan:addSkill(jubao)

Fk:loadTranslationTable{
  ["ld__lordsunquan"] = "君孙权",
  ["#ld__lordsunquan"] = "虎踞江东",
  ["designer:ld__lordsunquan"] = "韩旭",
  ["illustrator:ld__lordsunquan"] = "瞌瞌一休",
  ["jubao"] = "聚宝",
  [":jubao"] = "锁定技，①结束阶段，若弃牌堆或场上存在【定澜夜明珠】，你摸一张牌，然后获得拥有【定澜夜明珠】的角色的一张牌；②其他角色获得你装备区内的宝物牌时，取消之。",
  ["jiahe"] = "嘉禾",
  [":jiahe"] = "<b><font color='goldenrod'>君主技</font></b>，你拥有“缘江烽火图”。<br>" ..
  "#<b>缘江烽火图</b>：①吴势力角色出牌阶段限一次，其可将一张装备牌置于“缘江烽火图”上，称为“烽火”。<br>" ..
  "②吴势力角色的准备阶段，其可根据“烽火”数量选择获得对应的技能直至其回合结束：<br>"..
  "不小于一，〖英姿〗；不小于二，〖好施〗；不小于三，〖涉猎〗；不小于四，〖度势〗；不小于五，可额外选择一项。<br>"..
  "③锁定技，当你受到【杀】或锦囊牌造成的伤害后，你将一张“烽火”置入弃牌堆。",
  ["lianzi"] = "敛资",
  [":lianzi"] = "出牌阶段限一次，你可以弃置一张手牌并展示牌堆顶X张牌（X为吴势力角色装备区内牌数与“烽火”数之和），你获得其中与你弃置的牌类型相同的牌，将其余牌置入弃牌堆，然后若你因此获得至少四张牌，你失去〖敛资〗，获得〖制衡〗。",

  ["$jiahe"] = "嘉禾生，大吴兴！",
  ["$jubao1"] = "四海之宝，孤之所爱。",
  ["$jubao2"] = "夷洲，扶南，辽东，皆大吴臣邦也！",
  ["$lianzi1"] = "税以足食，赋以足兵。",
  ["$lianzi2"] = "府库充盈，国家方能强盛！",
  ["$ld__lordsunquan_zhiheng1"] = "二宫并阙，孤之所愿。",
  ["$ld__lordsunquan_zhiheng2"] = "鲁王才兼文武，堪比太子。",
  ["~ld__lordsunquan"] = "朕的江山，要倒下了么……",

  ["$ld__lordsunquan_yingzi1"] = "大吴江山，儒将辈出。",
  ["$ld__lordsunquan_yingzi2"] = "千夫奉儒将，百兽伏麒麟",

  ["$ld__lordsunquan_haoshi1"] = "朋友有难，当倾囊相助。",
  ["$ld__lordsunquan_haoshi2"] = "好东西，就要与朋友分享。",

  ["$ld__lordsunquan_shelie1"] = "军中多务，亦当涉猎。",
  ["$ld__lordsunquan_shelie2"] = "少说话，多看书。",

  ["$ld__lordsunquan_duoshi1"] = "广施方略，以观其变。",
  ["$ld__lordsunquan_duoshi2"] = "莫慌，观察好局势再做行动。",

  ["#jubao_move"] = "聚宝",
  ["#ld__jiahe_damaged"] = "缘江烽火图：将一张“烽火”置入弃牌堆",
  ["ld__jiahe_other&"] = "烽火图",
  [":ld__jiahe_other&"] = "①出牌阶段限一次，你可以将一张装备牌置于“缘江烽火图”上，称为“烽火”。<br>" ..
  "②准备阶段，你可以根据“烽火”数量选择获得对应的技能直至其回合结束：<br>"..
  "不小于一，〖英姿〗；不小于二，〖好施〗；不小于三，〖涉猎〗；不小于四，〖度势〗；不小于五，可额外选择一项。",
  ["#fenghuotu"] = "缘江烽火图",
  ["#ld__jiahe_other"] = "缘江烽火图：将一张装备牌置于%src的“缘江烽火图”上，称为“烽火”",
  ["lord_fenghuo"] = "烽火",
  ["#ld__lordsunquan_haoshi_delay"] = "好施",
  ["#ld__lordsunquan_shelie-choose"] = "涉猎：获得不同花色的牌各一张",

  ["$fenghuotu1"] = "保卫国家，人人有责。",
  ["$fenghuotu2"] = "连绵的烽火，就是对敌人最好的震慑！",
  ["$fenghuotu3"] = "有敌来犯，速速御敌。",
  ["$fenghuotu4"] = "来，扶孤上马迎敌！",

  ["#fenghuotu-choose"] = "缘江烽火图：可选择%arg个技能",
  ["ld__lordsunquan_yingzi"] = "英姿",
  ["ld__lordsunquan_haoshi"] = "好施",
  ["ld__lordsunquan_shelie"] = "涉猎",
  ["ld__lordsunquan_duoshi"] = "度势",

  ["#lianzi"] = "敛资：你可以弃置一张手牌，然后亮出牌堆顶%arg张牌，获得其中与你弃置的牌类型相同的牌",

  [":ld__lordsunquan_yingzi"] = "锁定技，摸牌阶段，你多摸一张牌。你的手牌上限为你的体力上限。 ",
  [":ld__lordsunquan_haoshi"] = "摸牌阶段，你可以多摸两张牌，若如此做，此阶段结束时，若你的手牌数大于5，你将一半的手牌（向下取整）交给一名手牌数最小的其他角色。",
  [":ld__lordsunquan_shelie"] = "摸牌阶段，你可以改为亮出牌堆顶的五张牌，获得其中每种花色的牌各一张。 ",
  [":ld__lordsunquan_duoshi"] = "出牌阶段开始时，你可以视为使用一张【以逸待劳】。 ",

  ["ld__lordsunquan_zhiheng"] = "制衡",
  [":ld__lordsunquan_zhiheng"] = "出牌阶段限一次，你可以弃置至多X张牌（X为你体力上限），摸等量的牌。",
}


local extension_card = Package("transformation_cards", Package.CardPack)
extension_card.extensionName = "hegemony"
extension_card.game_modes_whitelist = { 'nos_heg_mode', 'new_heg_mode' }

Fk:loadTranslationTable{
  ["transformation_cards"] = "君临天下·变卡牌",
}

local luminousPearlSkill = fk.CreateActiveSkill{
  name = "luminous_pearl_skill",
  attached_equip = "luminous_pearl",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  target_num = 0,
  min_card_num = 1,
  max_card_num = function()
    return Self.maxHp
  end,
  card_filter = function(self, to_select, selected)
    return #selected < Self.maxHp and not Self:prohibitDiscard(Fk:getCardById(to_select)) and Fk:getCardById(to_select).name ~= "luminous_pearl"
  end,
  on_use = function(self, room, effect)
    local from = room:getPlayerById(effect.from)
    room:notifySkillInvoked(from, "luminous_pearl", "drawcard")
    room:throwCard(effect.cards, self.name, from, from)
    if not from.dead then
      from:drawCards(#effect.cards, self.name)
    end
  end
}
local luminousPearlTrig = fk.CreateTriggerSkill{
  name = "#luminous_pearl_trigger",
  refresh_events = {fk.EventAcquireSkill, fk.EventLoseSkill},
  can_refresh = function(self, event, target, player, data)
    return player == target and (data == Fk.skills["hs__zhiheng"] or data == Fk.skills["ld__lordsunquan_zhiheng"] or data == Fk.skills["wk_heg__zhiheng"]) and table.find(player:getEquipments(Card.SubtypeTreasure), function(cid)
      return Fk:getCardById(cid).name == "luminous_pearl"
    end)
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:handleAddLoseSkills(player, event == fk.EventAcquireSkill and "-luminous_pearl_skill" or "luminous_pearl_skill", nil, false, true)
  end,
}
luminousPearlSkill:addRelatedSkill(luminousPearlTrig)
Fk:addSkill(luminousPearlSkill)

local luminousPearl = fk.CreateTreasure{
  name = "luminous_pearl",
  suit = Card.Diamond,
  number = 6,
  equip_skill = luminousPearlSkill,
  on_install = function(self, room, player)
    Treasure.onInstall(self, room, player)
    if (player:hasSkill("hs__zhiheng") or player:hasSkill("ld__lordsunquan_zhiheng") or player:hasSkill("wk_heg__zhiheng")) then room:handleAddLoseSkills(player, "-luminous_pearl_skill", nil, false, true) end
  end,
}
H.addCardToConvertCards(luminousPearl, "six_swords")
extension_card:addCard(luminousPearl)

Fk:loadTranslationTable{
  ["luminous_pearl"] = "定澜夜明珠",
  [":luminous_pearl"] = "装备牌·宝物<br/><b>宝物技能</b>：锁定技，若你没有〖制衡〗，你视为拥有〖制衡〗；若你有〖制衡〗，取消〖制衡〗的数量限制。",
  ["luminous_pearl_skill"] = "制衡",
  [":luminous_pearl_skill"] = "出牌阶段限一次，你可弃置至多X张牌（X为你的体力上限），然后你摸等量的牌。<font color='grey'><small>此为【制衡（定澜夜明珠）】</small></font>",
}
--]]
return extension
