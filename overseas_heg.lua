local extension = Package:new("overseas_heg")
extension.extensionName = "hegemony"
extension.game_modes_whitelist = { 'nos_heg_mode', 'new_heg_mode' }

local H = require "packages/hegemony/util"

Fk:loadTranslationTable{
  ["overseas_heg"] = "国际服-国战专属",
  ["os_heg"] = "国际",
}

local yangxiu = General(extension, "os_heg__yangxiu", "wei", 3)
yangxiu:addSkill("danlao")
yangxiu:addSkill("jilei")
Fk:loadTranslationTable{
  ['os_heg__yangxiu'] = '杨修',
  ["~os_heg__yangxiu"] = "我固自以死之晚也……",
}

local fuwan = General(extension, "os_heg__fuwan", "qun", 4)
fuwan:addSkill("moukui")
Fk:loadTranslationTable{
  ['os_heg__fuwan'] = '伏完',
  ["~os_heg__fuwan"] = "后会有期……",
}
--[[
local huaxiong = General(extension, "os__huaxiong", "qun", 4)

local yaowu = fk.CreateTriggerSkill{
  name = "os__yaowu",
  frequency = Skill.Limited,
  events = {fk.Damage},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and player:usedSkillTimes(self.name, Player.HistoryGame) == 0 and not table.contains(player.player_skills, self) 
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:changeMaxHp(player, 2)
    room:recover({
      who = player,
      num = 2,
      recoverBy = player,
      skillName = self.name
    })
  end,
}
local yaowuDeath = fk.CreateTriggerSkill{
  name = "#os__yaowu_death",
  events = {fk.Deathed},
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:usedSkillTimes(yaowu.name, Player.HistoryGame) > 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local targets = table.map(table.filter(room.alive_players, function(p) return H.compareKingdomWith(p, player) end), Util.IdMapper)
    if #targets == 0 then return end
    room:doIndicate(player.id, targets)
    room:sortPlayersByAction(targets)
    for _, pid in ipairs(targets) do
      local p = room:getPlayerById(pid)
      if not p.dead then
        room:loseHp(p, 1, self.name)
      end
    end
  end,
}
yaowu:addRelatedSkill(yaowuDeath)

local shiyong = fk.CreateTriggerSkill{
  name = "os__shiyong",
  frequency = Skill.Compulsory,
  events = {fk.Damaged},
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and data.card
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke(self.name)
    if player:usedSkillTimes(yaowu.name, Player.HistoryGame) == 0 then
      if data.card.color ~= Card.Red then
        room:notifySkillInvoked(player, self.name, "drawcard")
        player:drawCards(1, self.name)
      end
    elseif data.card.color ~= Card.Black and data.from and not data.from.dead then
      room:notifySkillInvoked(player, self.name, "negative")
      data.from:drawCards(1, self.name)
    end
  end,
}

huaxiong:addSkill(yaowu)
huaxiong:addSkill(shiyong)

Fk:loadTranslationTable{
  ['os__huaxiong'] = '华雄',
  ["os__yaowu"] = "耀武",
  [":os__yaowu"] = "限定技，当你造成伤害后，你可明置此武将牌，加2点体力上限，回复2点体力，“升级”〖恃勇〗，且当你死亡后，与你势力相同的角色各失去1点体力。",
  ["os__shiyong"] = "恃勇",
  [":os__shiyong"] = "锁定技，当你受到伤害后，1级：若造成伤害的牌不为红色，你摸一张牌；2级：若造成伤害的牌不为黑色，伤害来源摸一张牌。",

  ["#os__yaowu_death"] = "耀武",

  ["$os__yaowu1"] = "潘凤已被我斩了，谁还来领死！",
  ["$os__yaowu2"] = "十八路诸侯？！哼！乌合之众。",
  ["$os__shiyong1"] = "你们不要笑得太早。",
  ["$os__shiyong2"] = "哼，不痛不痒。",
  ["~os__huaxiong"] = "我掉以轻心了……",
}
]]


return extension
