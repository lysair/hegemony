local H = require "packages/hegemony/util"
local extension = Package:new("momentum")
extension.extensionName = "hegemony"
extension.game_modes_whitelist = { 'nos_heg_mode', 'new_heg_mode' }

Fk:loadTranslationTable{
  ["momentum"] = "君临天下·势",
}

local lidian = General(extension, "ld__lidian", "wei", 3)
lidian:addSkill("xunxun")
lidian:addSkill("wangxi")
lidian:addCompanions("hs__yuejin")
Fk:loadTranslationTable{
  ["ld__lidian"] = "李典",
  ["~ld__lidian"] = "报国杀敌，虽死犹荣……",
}

local madai = General(extension, "ld__madai", "shu", 4)
local madai_mashu = fk.CreateDistanceSkill{
  name = "heg_madai__mashu",
  frequency = Skill.Compulsory,
  correct_func = function(self, from, to)
    if from:hasSkill(self.name) then
      return -1
    end
  end,
}
madai:addSkill(madai_mashu)
madai:addSkill("re__qianxi")
madai:addCompanions("machao")
Fk:loadTranslationTable{
  ["ld__madai"] = "马岱",
  ["heg_madai__mashu"] = "马术",
  [":heg_madai__mashu"] = "锁定技，你与其他角色的距离-1。",
  ["$re__qianxi1"] = "暗影深处，袭敌斩首！",
  ["$re__qianxi2"] = "擒贼先擒王，打蛇打七寸！",
  ["~ld__madai"] = "我怎么会死在这里……",
}

--[[
local zangba = General(extension, "ld__zangba", "wei", 4)
local hjmax = fk.CreateMaxCardsSkill{
  name = '#hengjiang_maxcard',
  correct_func = function(self, player)
    return player:getMark("@hengjiang-turn")
  end
}
local hengjiang = fk.CreateTriggerSkill{
  name = "hengjiang",
  anim_type = "masochism",
  events = { fk.Damaged },
}
hengjiang:addRelatedSkill(hjmax)
zangba:addSkill(hengjiang)
Fk:loadTranslationTable{
  ['ld__zangba'] = '臧霸',
  ['hengjiang'] = '横江',
  [':hengjiang'] = '当你受到伤害后，你可以令当前回合角色本回合手牌上限-X（X为伤害值）。' ..
    '然后若其本回合弃牌阶段内没有弃牌，你摸一张牌。',
}
--]]

local sunce = General(extension, "ld__sunce", "wu", 4)
sunce.deputyMaxHpAdjustedValue = -1
sunce:addCompanions { "hs__zhouyu", "hs__taishici", "hs__daqiao" }
sunce:addSkill("jiang")
local yingyang = fk.CreateTriggerSkill{
  name = "yingyang",
  events = {fk.PindianCardsDisplayed},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self.name) and (player == data.from or data.results[player.id])
  end,
  on_cost = function(self, event, target, player, data)
    local choice = player.room:askForChoice(player, { 'yingyang_plus3', 'yingyang_sub3', 'Cancel' }, self.name)
    if choice ~= "Cancel" then
      self.cost_data = choice
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local card
    if player == data.from then
      card = data.fromCard
    elseif data.results[player.id] then
      card = data.results[player.id].toCard
    end
    if self.cost_data == "yingyang_plus3" then
      card.number = math.min(card.number + 3, 13)
    elseif self.cost_data == "yingyang_sub3" then
      card.number = math.max(card.number - 3, 1)
    end
  end,
}
sunce:addSkill(yingyang)
local hunshang = fk.CreateTriggerSkill{
  name = 'hunshang',
  relate_to_place = 'd',
  events = {fk.EventPhaseStart},
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and
      player.phase == Player.Start and player.hp == 1
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:handleAddLoseSkills(player, 'heg_sunce__yingzi|heg_sunce__yinghun')
    local logic = room.logic
    logic:getCurrentEvent():findParent(GameEvent.Turn):addExitFunc(function()
      room:handleAddLoseSkills(player, '-heg_sunce__yingzi|-heg_sunce__yinghun')
    end)
  end,
}
sunce:addSkill(hunshang)

local yingzi = fk.CreateTriggerSkill{
  name = "heg_sunce__yingzi",
  anim_type = "drawcard",
  frequency = Skill.Compulsory,
  events = {fk.DrawNCards},
  on_use = function(self, event, target, player, data)
    data.n = data.n + 1
  end,
}
local yingzi_maxcards = fk.CreateMaxCardsSkill{
  name = "#heg_sunce__yingzi_maxcards",
  fixed_func = function(self, player)
    if player:hasSkill(self.name) then
      return player.maxHp
    end
  end
}
yingzi:addRelatedSkill(yingzi_maxcards)
sunce:addRelatedSkill(yingzi)
local yinghun = fk.CreateTriggerSkill{
  name = "heg_sunce__yinghun",
  anim_type = "drawcard",
  mute = true,
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and player.phase == Player.Start and player:isWounded()
  end,
  on_cost = function(self, event, target, player, data)
    local to = player.room:askForChoosePlayers(player, table.map(player.room:getOtherPlayers(player), function (p)
      return p.id end), 1, 1, "#yinghun-choose:::"..player:getLostHp()..":"..player:getLostHp(), self.name, true)
    if #to > 0 then
      self.cost_data = to[1]
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(self.cost_data)
    local n = player:getLostHp()
    local choice = room:askForChoice(player, {"#yinghun-draw:::" .. n,  "#yinghun-discard:::" .. n}, self.name)
    if choice:startsWith("#yinghun-draw") then
      player:broadcastSkillInvoke(self.name, 1)
      room:notifySkillInvoked(player, self.name, "support")
      to:drawCards(n, self.name)
      room:askForDiscard(to, 1, 1, true, self.name, false)
    else
      player:broadcastSkillInvoke(self.name, 2)
      room:notifySkillInvoked(player, self.name, "control")
      to:drawCards(1, self.name)
      room:askForDiscard(to, n, n, true, self.name, false)
    end
  end,
}
sunce:addRelatedSkill(yinghun)
Fk:loadTranslationTable{
  ['ld__sunce'] = '孙策',
  ['yingyang'] = '鹰扬',
  [':yingyang'] = '当你的拼点牌亮出后，你可以令其点数+3或-3。',
  ['hunshang'] = '魂殇',
  [':hunshang'] = '副将技，锁定技，此武将牌减少半个阴阳鱼；准备阶段，若你的体力值为1，本回合内你拥有技能“英姿”和“英魂”。',
  ['heg_sunce__yingzi'] = '英姿',
  [":heg_sunce__yingzi"] = "锁定技，摸牌阶段，你多摸一张牌；你的手牌上限等同于你的体力上限。",
  ["heg_sunce__yinghun"] = "英魂",
  [":heg_sunce__yinghun"] = "准备阶段，若你已受伤，你可以选择一名其他角色并选择一项：1.令其摸X张牌，然后弃置一张牌；2.令其摸一张牌，然后弃置X张牌（X为你已损失的体力值）。",
}

local chengdong = General(extension, "ld__chenwudongxi", "wu", 4)
local duanxie = fk.CreateActiveSkill{
  name = 'ld__duanxie',
  anim_type = 'offensive',
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = function() return false end,
  target_filter = function(self, to_select, selected)
    return #selected == 0 and to_select ~= Self.id and
      not Fk:currentRoom():getPlayerById(to_select).chained
  end,
  target_num = 1,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])

    if not target.chained then
      target:setChainState(true)
    end

    if not player.chained then
      player:setChainState(true)
    end
  end,
}
local fenming = fk.CreateTriggerSkill{
  name = 'ld__fenming',
  anim_type = 'control',
  events = { fk.EventPhaseStart },
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and
      player.phase == Player.Finish and player.chained
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    for _, p in ipairs(room.alive_players) do
      if p.chained and not p:isNude() then
        local c = room:askForCardChosen(player, p, "he", self.name)
        room:throwCard(c, self.name, p, player)
      end
    end
  end,
}
chengdong:addSkill(duanxie)
chengdong:addSkill(fenming)
Fk:loadTranslationTable{
  ['ld__chenwudongxi'] = '陈武董袭',
  ['ld__duanxie'] = '断绁',
  [':ld__duanxie'] = '出牌阶段限一次，你可以令一名其他角色横置，然后你横置。',
  ['ld__fenming'] = '奋命',
  [':ld__fenming'] = '结束阶段开始时，若你处于连环状态，你可弃置处于连环状态的每名角色的一张牌。',

  ["$ld__duanxie1"] = "区区绳索就想挡住吾等去路？！",
	["$ld__duanxie2"] = "以身索敌，何惧同伤！",
	["$ld__fenming1"] = "东吴男儿，岂是贪生怕死之辈？",
	["$ld__fenming2"] = "不惜性命，也要保主公周全！",
  ["~ld__chenwudongxi"] = "杀身卫主，死而无憾！",
}

local dongzhuo = General(extension, "ld__dongzhuo", "qun", 4)
local hengzheng = fk.CreateTriggerSkill{
  name = 'hengzheng',
  anim_type = "control",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and player.phase == Player.Draw and
      (player.hp == 1 or player:isKongcheng()) and
      table.find(player.room:getOtherPlayers(player), function(p) return not p:isAllNude() end)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    for _, p in ipairs(room:getOtherPlayers(player, true)) do
      if not p:isAllNude() then
        local id = room:askForCardChosen(player, p, "hej", self.name)
        room:obtainCard(player, id, false)
      end
    end
    return true
  end,
}
dongzhuo:addSkill(hengzheng)
local baoling = fk.CreateTriggerSkill{
  name = "baoling",
  relate_to_place = 'm',
  anim_type = "big",
  events = {fk.EventPhaseEnd},
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and player.phase == Player.Play and
      player.general ~= "anjiang" and H.hasGeneral(player, true)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    H.removeGeneral(room, player, true)
    room:changeMaxHp(player, 3)
    room:recover {
      who = player,
      num = 3,
      skillName = self.name
    }
    room:handleAddLoseSkills(player, "benghuai")
  end,
}
dongzhuo:addSkill(baoling)
dongzhuo:addRelatedSkill("benghuai")
Fk:loadTranslationTable{
  ['ld__dongzhuo'] = '董卓',
  ['hengzheng'] = '横征',
  [':hengzheng'] = '摸牌阶段，若你体力值为1或者没有手牌，你可以改为获得所有其他角色区域内各一张牌。',
  ['baoling'] = '暴凌',
  [':baoling'] = '主将技，锁定技，出牌阶段结束时，若此武将已明置且你有副将，则你移除副将，加三点体力上限并回复三点体力，然后获得技能“崩坏”。',
}

return extension
