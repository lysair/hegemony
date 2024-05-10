local extension = Package:new("transformation")
extension.extensionName = "hegemony"
extension.game_modes_whitelist = { 'nos_heg_mode', 'new_heg_mode' }

local H = require "packages/hegemony/util"
local U = require "packages/utility/utility"

Fk:loadTranslationTable{
  ["transformation"] = "君临天下·变",
  ["transform_deputy"] = "变更副将",
}
local xunyou = General(extension, "ld__xunyou", "wei", 3)
local ld__qice = fk.CreateActiveSkill{
  name = "ld__qice",
  prompt = "#ld__qice-active",
  interaction = function()
    local handcards = Self:getCardIds(Player.Hand)
    local names, all_names = {} , {}
    for _, id in ipairs(Fk:getAllCardIds()) do
      local card = Fk:getCardById(id)
      if card:isCommonTrick() and not card.is_derived and not table.contains(all_names, card.name) then
        table.insert(all_names, card.name)
        local to_use = Fk:cloneCard(card.name)
        to_use:addSubcards(handcards)
        if Self:canUse(to_use) and not Self:prohibitUse(to_use) then
          local x = 0
          if to_use.multiple_targets and to_use.skill:getMinTargetNum() == 0 then
            for _, p in ipairs(Fk:currentRoom().alive_players) do
              if not Self:isProhibited(p, card) and card.skill:modTargetFilter(p.id, {}, Self.id, card, true) then
                x = x + 1
              end
            end
          end
          if x <= Self:getHandcardNum() then
            table.insert(names, card.name)
          end
        end
      end
    end
    if #names == 0 then return end
    return UI.ComboBox {choices = names, all_choices = all_names}
  end,
  card_num = 0,
  min_target_num = 0,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0 and not player:isKongcheng()
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, to_select, selected, selected_cards)
    if self.interaction.data == nil then return false end
    local to_use = Fk:cloneCard(self.interaction.data)
    to_use.skillName = self.name
    to_use:addSubcards(Self:getCardIds(Player.Hand))
    if not to_use.skill:targetFilter(to_select, selected, selected_cards, to_use) then return false end
    if (#selected == 0 or to_use.multiple_targets) and
    Self:isProhibited(Fk:currentRoom():getPlayerById(to_select), to_use) then return false end
    if to_use.multiple_targets then
      if #selected >= Self:getHandcardNum() then return false end
      if to_use.skill:getMaxTargetNum(Self, to_use) == 1 then
        local x = 0
        for _, p in ipairs(Fk:currentRoom().alive_players) do
          if p.id == to_select or (not Self:isProhibited(p, to_use) and to_use.skill:modTargetFilter(p.id, {to_select}, Self.id, to_use, true)) then
            x = x + 1
          end
        end
        if x > Self:getHandcardNum() then return false end
      end
    end
    return true
  end,
  feasible = function(self, selected, selected_cards)
    if self.interaction.data == nil then return false end
    local to_use = Fk:cloneCard(self.interaction.data)
    to_use.skillName = self.name
    to_use:addSubcards(Self:getCardIds(Player.Hand))
    return to_use.skill:feasible(selected, selected_cards, Self, to_use)
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local use = {
      from = player.id,
      tos = table.map(effect.tos, function (id)
        return {id}
      end),
      card = Fk:cloneCard(self.interaction.data),
    }
    use.card:addSubcards(player:getCardIds(Player.Hand))
    use.card.skillName = self.name
    room:useCard(use)
    if not player.dead and player:getMark("@@ld__qice_transform") == 0 and room:askForChoice(player, {"transform_deputy", "Cancel"}, self.name) ~= "Cancel" then
      room:setPlayerMark(player, "@@ld__qice_transform", 1)
      H.transformGeneral(room, player)
    end
  end,
}
xunyou:addSkill(ld__qice)
xunyou:addSkill("zhiyu")
xunyou:addCompanions("hs__xunyu")

Fk:loadTranslationTable{
  ["ld__xunyou"] = "荀攸",
  ["#ld__xunyou"] = "曹魏的谋主",
  ["designer:ld__xunyou"] = "淬毒",
  ["illustrator:ld__xunyou"] = "心中一凛",

  ["ld__qice"] = "奇策",
  [":ld__qice"] = "出牌阶段限一次，你可将所有手牌当任意一张普通锦囊牌使用，你不能以此法使用目标数大于X的牌（X为你的手牌数），然后你可变更副将。",

  ["#ld__qice-active"] = "发动 奇策，将所有手牌当一张锦囊牌使用",
  ["@@ld__qice_transform"] = "奇策 已变更",

  ["$ld__qice1"] = "倾力为国，算无遗策。",
  ["$ld__qice2"] = "奇策在此，谁与争锋？",
  ["~ld__xunyou"] = "主公，臣下……先行告退……",
}


local bianfuren = General(extension, "ld__bianfuren", "wei", 3)
local wanwei = fk.CreateTriggerSkill{
  name = "ld__wanwei",
  events = {fk.BeforeCardsMove},
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self) then return end
    local _data = {}
    for index, move in ipairs(data) do
      local num = 0
      if (move.moveReason == fk.ReasonPrey or move.moveReason == fk.ReasonDiscard) and move.from == player.id and move.proposer ~= player.id then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerEquip or info.fromArea == Card.PlayerHand then
            num = num + 1
          end
        end
      end
      if num ~= 0 then
        table.insert(_data, {index, num})
      end
    end
    if #_data == 0 then return end
    self.cost_data = _data
    return true
  end,
  on_use = function(self, event, target, player, data)
    if player.dead then return end
    local room = player.room
    local _data = self.cost_data
    for _, tab in ipairs(_data) do
      local index, num = tab[1], tab[2]
      local ids = room:askForCardsChosen(player, player, num, num, "he", self.name, "#ld__wanwei-choose")
      if #ids == num then
        local moveInfo = {}
        for _, id in ipairs(ids) do
          local from = room:getCardArea(id)
          local info = {}
          info.cardId = id
          info.fromArea = from
          table.insertIfNeed(moveInfo, info)
        end
        if #moveInfo == num then
          data[index].moveInfo = moveInfo
        end
      end
    end
  end,
}

local yuejian = fk.CreateTriggerSkill{
  name = "ld__yuejian",
  frequency = Skill.Compulsory,
  events = {fk.EventPhaseStart, fk.EventPhaseEnd},
  can_trigger = function(self, event, target, player, data)
    if event == fk.EventPhaseStart then
      return H.compareKingdomWith(player, target) and player:hasSkill(self) and target.phase == Player.Discard 
        and target:getMark("ld__yuejian-turn") == 0 and player.room.current == target
    else
      return H.compareKingdomWith(player, target) and player:hasSkill(self) and target.phase == Player.Discard 
        and target:getMark("ld__yuejian-add") == 1 and player.room.current == target
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    if event == fk.EventPhaseStart then
      player.room:addPlayerMark(target, MarkEnum.AddMaxCards, target.maxHp - target.hp)
      player.room:setPlayerMark(target, "ld__yuejian-add", 1)
    else
      player.room:addPlayerMark(target, MarkEnum.MinusMaxCards, target.maxHp - target.hp)
      player.room:setPlayerMark(target, "ld__yuejian-add", 0)
    end
  end,

  refresh_events = {fk.TargetSpecified},
  can_refresh = function(self, event, target, player, data)
    return H.compareKingdomWith(target, player) and target == player.room.current 
      and target:getMark("ld__yuejian-turn") == 0 and data.firstTarget and data.card.type ~= Card.TypeEquip
  end,
  on_refresh = function(self, event, target, player, data)
    if #AimGroup:getAllTargets(data.tos) == 0 then return end
    for _, id in ipairs(AimGroup:getAllTargets(data.tos)) do
      if not H.compareKingdomWith(player.room:getPlayerById(id), target) then
        player.room:addPlayerMark(target, "ld__yuejian-turn", 1)
        break
      end
    end
  end,
}

bianfuren:addCompanions("hs__caocao")
bianfuren:addSkill(wanwei)
bianfuren:addSkill(yuejian)

Fk:loadTranslationTable{
  ["ld__bianfuren"] = "卞夫人",
  ["#ld__bianfuren"] = "奕世之雍容",
  ["illustrator:ld__bianfuren"] = "雪君S",

  ["ld__wanwei"] = "挽危",
  [":ld__wanwei"] = "当你的牌被其他角色弃置或获得时，你可改为你选择的等量的牌。",
  ["ld__yuejian"] = "约俭",
  [":ld__yuejian"] = "锁定技，与你势力相同角色的弃牌阶段开始时，若其本回合处于与你势力相同状态时未对其他势力角色使用过牌，其本回合的手牌上限改为其体力上限。",

  ["#ld__wanwei-choose"] = "挽危：请选择等量即将被其他角色弃置或获得的牌",

  ["$ld__wanwei1"] = "吉凶未可知，何故自乱？",
  ["$ld__wanwei2"] = "虽为水火之势，亦当虑而后动。",
  ["$ld__yuejian1"] = "常闻君子以俭德辟难，不可荣以禄。",
  ["$ld__yuejian2"] = "如今世事未定，不可铺张浪费。",
  ["~ld__bianfuren"] = "子桓，兄弟之情，不可轻忘…",
}

local shamoke = General(extension, "ld__shamoke", "shu", 4)
shamoke:addSkill("jilis")
Fk:loadTranslationTable{
  ['ld__shamoke'] = '沙摩柯',
  ["#ld__shamoke"] = "五溪蛮王",
  ["illustrator:ld__shamoke"] = "LiuHeng",
  ["designer:ld__shamoke"] = "韩旭",
  ['~ld__shamoke'] = '五溪蛮夷，不可能输！',
}

local masu = General(extension, "ld__masu", "shu", 3)
local zhiman = fk.CreateTriggerSkill{
  name = "ld__zhiman",
  events = {fk.DamageCaused},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.to ~= player
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, nil, "#ld__zhiman-invoke::"..data.to.id)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local target = data.to
    if #target:getCardIds{Player.Equip, Player.Judge} > 0 then -- 开摆！
      local card = room:askForCardChosen(player, target, "ej", self.name)
      room:obtainCard(player.id, card, true, fk.ReasonPrey)
    end
    if H.compareKingdomWith(target, player) and player:getMark("@@ld__zhiman_transform") == 0
      and room:askForChoice(player, {"ld__zhiman_transform::" .. target.id, "Cancel"}, self.name) ~= "Cancel"
      and room:askForChoice(target, {"transform_deputy", "Cancel"}, self.name) ~= "Cancel" then
        room:setPlayerMark(player, "@@ld__zhiman_transform", 1)
        H.transformGeneral(room, target)
    end
    return true
  end
}
masu:addSkill("sanyao")
masu:addSkill(zhiman)
Fk:loadTranslationTable{
  ['ld__masu'] = '马谡',
  ["#ld__masu"] = "帷幄经谋",
  ["designer:ld__masu"] = "点点",
  ["illustrator:ld__masu"] = "蚂蚁君",
  ["ld__zhiman"] = "制蛮",
  [":ld__zhiman"] = "当你对其他角色造成伤害时，你可防止此伤害，你获得其装备区或判定区里的一张牌。若其与你势力相同，你可令其选择是否变更。",

  ["#ld__zhiman-invoke"] = "制蛮：你可以防止对 %dest 造成的伤害，获得其场上的一张牌。若其与你势力相同，你可令其选择是否变更副将",
  ["ld__zhiman_transform"] = "令%dest选择是否变更副将",
  ["@@ld__zhiman_transform"] = "制蛮 已变更",

  ["$ld__zhiman1"] = "兵法谙熟于心，取胜千里之外！",
  ["$ld__zhiman2"] = "丞相多虑，且看我的！",
  ["~ld__masu"] = "败军之罪，万死难赎……" ,
}

local lingtong = General(extension, "ld__lingtong", "wu", 4)
local xuanlve = fk.CreateTriggerSkill{
  name = "xuanlve",
  anim_type = "control",
  events = {fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self) then return end
    local room = player.room
    for _, move in ipairs(data) do
      if move.from == player.id then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerEquip then
            return table.find(room:getOtherPlayers(player), function(p)
              return not p:isNude()
            end) ~= nil
          end
        end
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room:getOtherPlayers(player), function(p)
      return not p:isNude()
    end)

    targets = table.map(targets, Util.IdMapper)
    local pid = room:askForChoosePlayers(player, targets, 1, 1, '#xuanlve-discard',
      self.name, true)[1]

    if pid then
      self.cost_data = pid
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(self.cost_data)
    local id = room:askForCardChosen(player, to, "he", self.name)
    room:throwCard(id, self.name, to, player)
  end,
}
local yongjin = fk.CreateActiveSkill{
  name = "yongjin",
  anim_type = "offensive",
  frequency = Skill.Limited,
  card_num = 0,
  target_num = 0,
  card_filter = function()
    return false
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    for i = 1, 3, 1 do
      if #room:canMoveCardInBoard("e") == 0 or player.dead then break end
      local to = room:askForChooseToMoveCardInBoard(player, "#yongjin-choose", self.name, true, "e", false)
      if #to == 2 then
        local result = room:askForMoveCardInBoard(player, room:getPlayerById(to[1]), room:getPlayerById(to[2]), self.name, "e", nil)
        if not result then
          break
        end
      else
        break
      end
    end
  end,
}
lingtong:addSkill(xuanlve)
lingtong:addSkill(yongjin)
lingtong:addCompanions("hs__ganning")
Fk:loadTranslationTable{
  ['ld__lingtong'] = '凌统',
  ["#ld__lingtong"] = "豪情烈胆",
  ["designer:ld__lingtong"] = "韩旭",
  ["illustrator:ld__lingtong"] = "F.源",
  ['xuanlve'] = '旋略',
  [':xuanlve'] = '当你失去装备区的牌后，你可以弃置一名其他角色的一张牌。',
  ['#xuanlve-discard'] = '旋略：你可以弃置一名其他角色的一张牌',
  ["yongjin"] = "勇进",
  [":yongjin"] = "限定技，出牌阶段，你可依次移动场上至多三张装备牌。" .. 
  "<font color='grey'><br />注：可以多次移动同一张牌。",
  ["#yongjin-choose"] = "勇进：你可以移动场上的一张装备牌",

  ["$xuanlve1"] = "舍辎简装，袭掠如风！",
  ["$xuanlve2"] = "卸甲奔袭，摧枯拉朽！",
  ["$yongjin1"] = "急流勇进，覆戈倒甲！",
  ["$yongjin2"] = "长缨缚敌，先登夺旗！",
  ["~ld__lingtong"] = "大丈夫，不惧死亡……",
}

local lvfan = General(extension, "ld__lvfan", "wu", 3)
local diaodu = fk.CreateTriggerSkill{
  name = "diaodu",
  anim_type = "drawcard",
  events = {fk.CardUsing, fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self) then return false end
    if event == fk.CardUsing then return H.compareKingdomWith(target, player) and data.card.type == Card.TypeEquip and (player:hasShownSkill(self) or player == target)
    else return target == player and target.phase == Player.Play and table.find(player.room.alive_players, function(p)
    return H.compareKingdomWith(p, player) and #p:getCardIds(Player.Equip) > 0 end) end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if event == fk.CardUsing then
      return room:askForSkillInvoke(target, self.name, nil, "#diaodu-invoke")
    else
      local targets = table.map(table.filter(room.alive_players, function(p)
        return H.compareKingdomWith(p, player) and #p:getCardIds(Player.Equip) > 0 end), Util.IdMapper)
      if #targets == 0 then return false end
      local target = room:askForChoosePlayers(player, targets, 1, 1, "#diaodu-choose", self.name, true)
      if #target > 0 then
        self.cost_data = target[1]
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    if event == fk.CardUsing then
      target:drawCards(1, self.name)
    else
      local room = player.room
      local target = room:getPlayerById(self.cost_data)
      local cid = room:askForCardChosen(player, target, "e", self.name)
      room:obtainCard(player, cid, true, fk.ReasonPrey)
      if not table.contains(player:getCardIds(Player.Hand), cid) then return false end
      local card = Fk:getCardById(cid)
      if player.dead then return false end
      local targets = table.map(table.filter(room.alive_players, function(p) return p ~= player and p ~= target end), Util.IdMapper)
      local to = room:askForChoosePlayers(player, targets, 1, 1, "#diaodu-give:::" .. card:toLogString(), self.name, target ~= player)
      if #to > 0 then
        room:moveCardTo(card, Card.PlayerHand, room:getPlayerById(to[1]), fk.ReasonGive, self.name, nil, true, player.id)
      end
    end
  end,
}
local diancai = fk.CreateTriggerSkill{
  name = "diancai",
  events = {fk.EventPhaseEnd},
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self) or target.phase ~= Player.Play or target == player then return false end
    local num = 0
    player.room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function(e)
      for _, move in ipairs(e.data) do
        if move and move.from and move.from == player.id and ((move.to and move.to ~= player.id) or not table.contains({Card.PlayerHand, Card.PlayerEquip}, move.toArea)) then
          for _, info in ipairs(move.moveInfo) do
            if info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip then
              num = num + 1
            end
          end
        end
      end
      return false
    end, Player.HistoryPhase)
    return num >= player.hp
  end,
  on_use = function(self, event, target, player, data)
    local num = player.maxHp - player:getHandcardNum()
    local room = player.room
    if num > 0 then
      player:drawCards(num, self.name)
    end
    if player:getMark("@@ld__diancai_transform") == 0 and room:askForChoice(player, {"transform_deputy", "Cancel"}, self.name) ~= "Cancel" then
      room:setPlayerMark(player, "@@ld__diancai_transform", 1)
      H.transformGeneral(room, player)
    end
  end,
}

lvfan:addSkill(diaodu)
lvfan:addSkill(diancai)

Fk:loadTranslationTable{
  ['ld__lvfan'] = '吕范',
  ["#ld__lvfan"] = "忠笃亮直",
  ["designer:ld__lvfan"] = "韩旭",
  ["illustrator:ld__lvfan"] = "铭zmy",

  ['diaodu'] = '调度',
  [':diaodu'] = '①当与你势力相同的角色使用装备牌时，其可摸一张牌。②出牌阶段开始时，你可获得与你势力相同的一名角色装备区里的一张牌，若其：为你，你将此牌交给一名角色；不为你，你可将此牌交给另一名角色。',
  ["diancai"] = "典财",
  [":diancai"] = "其他角色的出牌阶段结束时，若你于此阶段失去过不少于X张牌（X为你的体力值），则你可将手牌摸至你体力上限，然后你可变更。",

  ["#diaodu-invoke"] = "调度：你可摸一张牌",
  ["#diaodu-choose"] = "调度：你可获得与你势力相同的一名角色装备区里的一张牌",
  ["#diaodu-give"] = "调度：将%arg交给另一名角色",
  ["#diancai-ask"] = "典财：你可摸 %arg 张牌，然后你可变更副将",

  ["@@ld__diancai_transform"] = "典财 已变更",

  ["$diaodu1"] = "诸军兵器战具，皆由我调配！",
  ["$diaodu2"] = "甲胄兵器，按我所说之法分发！",
  ["$diancai1"] = "军资之用，不可擅作主张！",
  ["$diancai2"] = "善用资财，乃为政上法！",
  ["~ld__lvfan"] = "闻主公欲授大司马之职，容臣不能……谢恩了……",
}

local zuoci = General(extension, "ld__zuoci", "qun", 3)
---@param player ServerPlayer
---@param skillName string
local addFangkeSkill = function(player, skillName)
  local room = player.room
  local skill = Fk.skills[skillName]
  if (not skill) or skill.lordSkill or skill.switchSkillName
    or skill.frequency > 2 or skill.relate_to_place == "m" or skill.relate_to_place == "d"
    or player:hasSkill(skill) then
    return
  end

  local fangke_skills = U.getMark(player, "ld__xing_skills")
  table.insert(fangke_skills, skillName)
  room:setPlayerMark(player, "ld__xing_skills", fangke_skills)
  player:addFakeSkill(skill)
  player:prelightSkill(skill, true)
end

---@param player ServerPlayer
---@param skillName string
local removeFangkeSkill = function(player, skillName)
  local room = player.room
  local skill = Fk.skills[skillName]

  local fangke_skills = U.getMark(player, "ld__xing_skills")
  if not table.contains(fangke_skills, skillName) then
    return
  end
  table.removeOne(fangke_skills, skillName)
  room:setPlayerMark(player, "ld__xing_skills", fangke_skills)

  player:loseFakeSkill(skill)
end

---@param player ServerPlayer
---@param general General
---@param addSkill bool
local function addFangke(player, general, addSkill)
  local room = player.room
  local glist = player:getMark("@&ld__xing")
  if glist == 0 then glist = {} end
  table.insertIfNeed(glist, general.name)
  room:setPlayerMark(player, "@&ld__xing", glist)

  if not addSkill then return end
  for _, s in ipairs(general.skills) do
    addFangkeSkill(player, s.name)
  end
  for _, sname in ipairs(general.other_skills) do
    addFangkeSkill(player, sname)
  end
end

---@param player ServerPlayer
---@param general string
local function removeFangke(player, general)
  local room = player.room
  local glist = U.getMark(player, "@&ld__xing")
  if table.removeOne(glist, general) then
    if #glist == 0 then glist = 0 end
    room:setPlayerMark(player, "@&ld__xing", glist)
    for _, sname in ipairs(Fk.generals[general]:getSkillNameList()) do
      removeFangkeSkill(player, sname)
    end
  end
end

local xinsheng = fk.CreateTriggerSkill{
  name = "ld__xinsheng",
  events = {fk.EventPhaseStart, fk.Damaged},
  can_trigger = function(self, event, target, player, _)
    if not (target == player and player:hasSkill(self)) then return end
    return event == fk.Damaged or player.phase == Player.Start
  end,
  on_use = function(self, event, _, player, _)
    local room = player.room
    local generals = {}
    if event == fk.EventPhaseStart then
      local m = player:getMark("@&ld__xing")
      if m == 0 or #m < 2 then
        local all_xing = room:getNGenerals(5)
        local result = room:askForCustomDialog(player, self.name,
        "packages/utility/qml/ChooseGeneralsAndChoiceBox.qml", {
          all_xing,
          {"OK"},
          "#ld__xinshen_xing2",
          {},
          2,
          2
        })
        if result ~= "" then
          local reply = json.decode(result)
          generals = reply.cards
        else
          generals = table.random(all_xing, 2)
        end
      else
        local choices = player:getMark("@&ld__xing")
        local choice
        local result = room:askForCustomDialog(player, self.name,
        "packages/utility/qml/ChooseGeneralsAndChoiceBox.qml", {
          choices,
          {"OK"},
          "#ld__xinshen_xing_recast"
        })
        if result ~= "" then
          local reply = json.decode(result)
          choice = reply.cards[1]
        else
          choice = table.random(choices) ---@type string
        end
        removeFangke(player, choice)
        generals = room:getNGenerals(1)
      end
    else
      generals = room:getNGenerals(1)
    end
    table.forEach(generals, function(g) addFangke(player, Fk.generals[g], true) end)
  end,

  refresh_events = {fk.EventLoseSkill, fk.GeneralHidden, fk.BuryVictim},
  can_refresh = function(self, event, target, player, data)
    if player:getMark("@&ld__xing") == 0 or player ~= target then return false end
    if event == fk.EventLoseSkill then
      return data == self
    elseif event == fk.BuryVictim then
      return true
    elseif event == fk.GeneralHidden then
      return table.contains(Fk.generals[data]:getSkillNameList(), self.name)
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local record = table.simpleClone(player:getMark("@&ld__xing"))
    for _, s in ipairs(record) do
      removeFangke(player, s)
    end
  end,
}

local huashen = fk.CreateTriggerSkill{
  name = "ld__huashen",
  events = {fk.AfterSkillEffect},
  can_trigger = function(self, _, target, player, data)
    return target == player and player:hasSkill(self) and
      table.contains(U.getMark(player, "ld__xing_skills"), data.name)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, _, target, player, data)
    local all_xing = player:getMark("@&ld__xing")
    local choices = {}
    for _, s in ipairs(all_xing) do
      local general = Fk.generals[s]
      local skills = general:getSkillNameList()
      if table.contains(skills, data.name) then
        table.insert(choices, s)
      end
    end
    local choice = player.room:askForChoice(player, choices, self.name, "#ld__huashen_remove")
    removeFangke(player, choice)
  end,
}

zuoci:addCompanions("ld__yuji")
zuoci:addSkill(xinsheng)
zuoci:addSkill(huashen)
Fk:loadTranslationTable{
  ["ld__zuoci"] = "左慈",
  ["#ld__zuoci"] = "鬼影神道",
  ["illustrator:ld__zuoci"] = "吕阳",
  ["ld__huashen"] = "化身",
  [":ld__huashen"] = "当你需要发动“形”拥有的技能时，你可以于对应的时机发动“形”拥有的一个无技能标签的技能，然后于此技能结算后将拥有此技能的“形”置入武将牌堆。<br><font color = 'grey'>注：不要报有关左慈的任何技能触发bug，有极小可能性导致游戏崩溃的除外。</font>",
  ["ld__xinsheng"] = "新生",
  [":ld__xinsheng"] = "准备阶段，若你的“形”：少于两张，你可以观看武将牌堆中的随机五张武将牌，选择其中的两张置于你的武将牌上（称为“形”）；不少于两张，你可以将一张“形”置入武将牌堆，然后随机将武将牌堆中的一张武将牌置于你的武将牌上（称为“形”）。"..
    "当你受到伤害后，你可以随机将武将牌堆中的一张武将牌置于你的武将牌上（称为“形”）。",

  ["@&ld__xing"] = "形",

  ["#ld__xinshen_xing1"] = "新生：选择一张武将牌置于你的武将牌上，称为“形”",
  ["#ld__xinshen_xing2"] = "新生：选择两张武将牌置于你的武将牌上，称为“形”",
  ["#ld__xinshen_xing_recast"] = "新生：移去一张“形”，然后随机将一张武将牌置于你的武将牌上，称为“形”",
  ["#ld__huashen_remove"] = "化身：移去一张“形”",

  ["$ld__huashen1"] = "世间万物，贫道皆可化为其形。",
  ["$ld__huashen2"] = "尘身土塑，唯魂魄难得。",
  ["$ld__xinsheng1"] = "大成若缺，损益无妨。",
  ["$ld__xinsheng2"] = "大盈若冲，心神自现。",
  ["~ld__zuoci"] = "仙人之逝，魂归九天…",
}

local lijueguosi = General(extension, "ld__lijueguosi", "qun", 4)
lijueguosi:addCompanions("hs__jiaxu")
local xiongsuan = fk.CreateActiveSkill{
  name = "xiongsuan",
  anim_type = "offensive",
  frequency = Skill.Limited,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,
  card_num = 1,
  target_num = 1,
  card_filter = function(self, to_select, selected)
    return #selected < 1 and Fk:currentRoom():getCardArea(to_select) == Player.Hand
  end,
  target_filter = function(self, to_select, selected)
    return #selected == 0 and H.compareKingdomWith(Fk:currentRoom():getPlayerById(to_select), Self)
  end,
  on_use = function (self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    room:throwCard(effect.cards, self.name, player, player)
    if player.dead or target.dead then return false end
    room:damage{
      from = player,
      to = target,
      damage = 1,
      skillName = self.name,
    }
    if player.dead then return false end
    player:drawCards(3, self.name)
    if target.dead then return false end
    local skills = table.filter(target.player_skills, function(s)
      return s.frequency == Skill.Limited and target:usedSkillTimes(s.name, Player.HistoryGame) > 0
    end)
    if #skills == 0 then return false end
    local skillNames = table.map(skills, function(s)
      return s.name
    end)
    local skill = room:askForChoice(player, skillNames, self.name, "#xiongsuan-reset::" .. target.id)
    room:setPlayerMark(player, "_xiongsuan-turn", {skill, target.id})
  end,
}
local xiongsuan_delay = fk.CreateTriggerSkill{
  name = "#xiongsuanDelay",
  visible = false,
  frequency = Skill.Compulsory,
  events = {fk.TurnEnd},
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and type(player:getMark("_xiongsuan-turn")) == "table"
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local skill = player:getMark("_xiongsuan-turn")[1]
    target = room:getPlayerById(player:getMark("_xiongsuan-turn")[2])
    target:addSkillUseHistory(skill, -1)
    room:sendLog{
      type = "#XiongsuanReset",
      from = target.id,
      arg = skill,
    }
  end,
}
xiongsuan:addRelatedSkill(xiongsuan_delay)
lijueguosi:addSkill(xiongsuan)
Fk:loadTranslationTable{
  ['ld__lijueguosi'] = '李傕郭汜',
  ["#ld__lijueguosi"] = "犯祚倾祸",
  ["designer:ld__lijueguosi"] = "千幻",
  ["illustrator:ld__lijueguosi"] = "旭",
  ["xiongsuan"] = "凶算",
  [":xiongsuan"] = "限定技，出牌阶段，你可弃置一张手牌并选择与你势力相同的一名角色，你对其造成1点伤害，摸三张牌，选择其一个已发动过的限定技，然后此回合结束前，你令此技能于此局游戏内的发动次数上限+1。",
  ["#xiongsuan-reset"] = "凶算：请重置%dest的一项技能",
  ["#xiongsuanDelay"] = "凶算",
  ["#XiongsuanReset"] = "%from 重置了限定技“%arg”",

  ["$xiongsuan1"] = "此战虽凶，得益颇高。",
  ["$xiongsuan2"] = "谋算计策，吾二人尚有险招。",
  ["~ld__lijueguosi"] = "异心相争，兵败战损……",
}

local lordsunquan = General(extension, "ld__lordsunquan", "wu", 4)
lordsunquan.hidden = true
H.lordGenerals["hs__sunquan"] = "ld__lordsunquan"

local jiahe = fk.CreateTriggerSkill{
  name = "jiahe",
  anim_type = "support",
  frequency = Skill.Compulsory,
  events = {fk.GeneralRevealed},
  derived_piles = "lord_fenghuo",
  can_trigger = function (self, event, target, player, data)
    if target == player and player:hasSkill(self.name, true) then
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
      return player == target and player:hasSkill(self) and data.card and #player:getPile("lord_fenghuo") > 0 and (data.card.type == Card.TypeTrick or data.card.trueName == "slash")
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
    if event == fk.Deathed then return player:hasSkill(self.name, true, true)
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
    local tos, cards = U.askForChooseCardsAndPlayers(room, player, x, x, targets, 1, 1,
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
    get = U.askForArrangeCards(player, self.name, cards, "#ld__lordsunquan_shelie-choose",
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

local ld__duoshi = fk.CreateViewAsSkill{
  name = "ld__lordsunquan_duoshi",
  anim_type = "drawcard",
  pattern = "await_exhausted",
  card_filter = function(self, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).color == Card.Red and Fk:currentRoom():getCardArea(to_select) == Player.Hand
  end,
  view_as = function(self, cards)
    if #cards ~= 1 then
      return nil
    end
    local c = Fk:cloneCard("await_exhausted")
    c.skillName = self.name
    c:addSubcard(cards[1])
    return c
  end,
  enabled_at_play = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryTurn) < 4
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
    room:moveCards{
      ids = cards,
      toArea = Card.Processing,
      moveReason = fk.ReasonJustMove,
      skillName = self.name,
      proposer = player.id
    }
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
          local card = room:askForCardChosen(player, p, "e", self.name)
          room:obtainCard(player.id, card, false, fk.ReasonPrey)
        else
          local card = room:askForCardChosen(player, p, "he", self.name)
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
  [":ld__lordsunquan_duoshi"] = "出牌阶段限四次，你可将一张红色手牌当【以逸待劳】使用。 ",

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
    return player == target and (data == Fk.skills["hs__zhiheng"] or data == Fk.skills["ld__lordsunquan_zhiheng"]) and table.find(player:getEquipments(Card.SubtypeTreasure), function(cid)
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
    if (player:hasSkill("hs__zhiheng") or player:hasSkill("ld__lordsunquan_zhiheng")) then room:handleAddLoseSkills(player, "-luminous_pearl_skill", nil, false, true) end
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

return {
  extension,
  extension_card,
}
