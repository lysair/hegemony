local extension = Package:new("momentum")
extension.extensionName = "hegemony"
extension.game_modes_whitelist = { 'nos_heg_mode', 'new_heg_mode' }

Fk:loadTranslationTable{
  ["momentum"] = "君临天下·势",
}

local lidian = General(extension, "ld__lidian", "wei", 3)
lidian:addSkill("xunxun")
lidian:addSkill("wangxi")
Fk:loadTranslationTable{
  ["ld__lidian"] = "李典",
}

local madai = General(extension, "ld__madai", "shu", 4)
madai:addSkill("mashu")
madai:addSkill("qianxi")
Fk:loadTranslationTable{
  ["ld__madai"] = "马岱",
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
}

return extension
