local extension = Package:new("transformation")
extension.extensionName = "hegemony"
extension.game_modes_whitelist = { 'nos_heg_mode', 'new_heg_mode' }

local H = require "packages/hegemony/util"

Fk:loadTranslationTable{
  ["transformation"] = "君临天下·变",
  ["transform_deputy"] = "变更副将",
}

local shamoke = General(extension, "ld__shamoke", "shu", 4)
shamoke:addSkill("jilis")
Fk:loadTranslationTable{
  ['ld__shamoke'] = '沙摩柯',
  ['~ld__shamoke'] = '五溪蛮夷，不可能输！',
}

local masu = General(extension, "ld__masu", "shu", 3)
local zhiman = fk.CreateTriggerSkill{
  name = "ld__zhiman",
  events = {fk.DamageCaused},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and data.to ~= player
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
    if not player:hasSkill(self.name) then return end
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
  ['xuanlve'] = '旋略',
  [':xuanlve'] = '当你失去装备区的牌后，你可以弃置一名其他角色的一张牌。',
  ['#xuanlve-discard'] = '旋略：你可以弃置一名其他角色的一张牌',
  ["yongjin"] = "勇进",
  [":yongjin"] = "限定技，出牌阶段，你可以依次移动场上至多三张装备牌。" .. 
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
    if not player:hasSkill(self.name) then return false end
    if event == fk.CardUsing then return H.compareKingdomWith(target, player) and data.card.type == Card.TypeEquip
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
    if not player:hasSkill(self.name) or target.phase ~= Player.Play or target == player then return false end
    local num = 0
    player.room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function(e)
      local move = e.data[1]
      if move and move.from and move.from == player.id and ((move.to and move.to ~= player.id) or not table.contains({Card.PlayerHand, Card.PlayerEquip}, move.toArea)) then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip then
            num = num + 1
          end
        end
      end
    end, Player.HistoryTurn)
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
  ['diaodu'] = '调度',
  [':diaodu'] = '当与你势力相同的角色使用装备牌时，其可摸一张牌。出牌阶段开始时，你可获得与你势力相同的一名角色装备区里的一张牌，若其为你，你将此牌交给一名角色；若不为你，你可将此牌交给另一名角色。',
  ["diancai"] = "典财",
  [":diancai"] = "其他角色的出牌阶段结束时，若你于此阶段失去过不少于X张牌（X为你的体力值），则你可将手牌摸至Y（Y为你的体力上限），然后你可变更。",

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
  events = {fk.EventPhaseChanging},
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and data.to == Player.NotActive and type(player:getMark("_xiongsuan-turn")) == "table"
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local skill = player:getMark("_xiongsuan-turn")[1]
    local target = room:getPlayerById(player:getMark("_xiongsuan-turn")[2])
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
  ["xiongsuan"] = "凶算",
  [":xiongsuan"] = "限定技，出牌阶段，你可弃置一张手牌并选择与你势力相同的一名角色，你对其造成1点伤害，摸三张牌，选择其一个已发动过的限定技，然后此回合结束前，你令此技能于此局游戏内的发动次数上限+1。",
  ["#xiongsuan-reset"] = "凶算：请重置%dest的一项技能",
  ["#xiongsuanDelay"] = "凶算",
  ["#XiongsuanReset"] = "%from 重置了限定技“%arg”",

  ["$xiongsuan1"] = "此战虽凶，得益颇高。",
  ["$xiongsuan2"] = "谋算计策，吾二人尚有险招。",
  ["~ld__lijueguosi"] = "异心相争，兵败战损……",
}

return extension
