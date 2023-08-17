local extension = Package:new("power")
extension.extensionName = "hegemony"
extension.game_modes_whitelist = { 'nos_heg_mode', 'new_heg_mode' }
local H = require "packages/hegemony/util"

Fk:loadTranslationTable{
  ["power"] = "君临天下·权",
}

local zhangxiu = General(extension, "ld__zhangxiu", "qun", 4)
local fudi = fk.CreateTriggerSkill{
  name = 'ld__fudi',
  events = { fk.Damaged },
  anim_type = "masochism",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and data.from and data.from ~= player
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local c = room:askForCard(player, 1, 1, false, self.name, true,
      '.|.|.|hand', '#ld__fudi-give:' .. data.from.id)[1]

    if c then
      self.cost_data = c
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:obtainCard(data.from, self.cost_data, false, fk.ReasonGive)

    local p = data.from
    local max = p.hp
    local k = p.kingdom
    if k == "unknown" then return end
    for _, _p in ipairs(room.alive_players) do
      if H.compareKingdomWith(p, _p) then max = math.max(max, _p.hp) end
    end
    if max < player.hp then return end
    local targets = table.filter(room.alive_players, function(_p)
      return _p.kingdom == k and _p.hp == max
    end)
    local to = room:askForChoosePlayers(player, table.map(targets, Util.IdMapper),
      1, 1, '#ld__fudi-dmg', self.name, false)[1]

    room:damage {
      from = player,
      to = room:getPlayerById(to),
      damage = 1,
      skillName = self.name,
    }
  end,
}
local congjian = fk.CreateTriggerSkill{
  name = 'ld__congjian',
  anim_type = "offensive",
  events = { fk.DamageInflicted, fk.DamageCaused },
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    if not (target == player and player:hasSkill(self.name)) then return end
    if event == fk.DamageInflicted then
      return player.phase ~= Player.NotActive
    elseif event == fk.DamageCaused then
      return player.phase == Player.NotActive
    end
  end,
  on_use = function(_, _, _, _, data)
    data.damage = data.damage + 1
  end,
}
zhangxiu:addSkill(fudi)
zhangxiu:addSkill(congjian)
Fk:loadTranslationTable{
  ['ld__zhangxiu'] = '张绣',
  ['ld__fudi'] = '附敌',
  [':ld__fudi'] = '当你受到其他角色造成的伤害后，你可以交给伤害来源一张手牌。若如此做，你对与其势力相同的角色中体力值最多且不小于你的一名角色造成1点伤害。',
  ['#ld__fudi-give'] = '附敌：你可以交给 %src 一张手牌，然后对其势力体力最大造成一点伤害',
  ['#ld__fudi-dmg'] = '附敌：选择要造成伤害的目标',
  ['ld__congjian'] = '从谏',
  [':ld__congjian'] = '锁定技，当你于回合外造成伤害时或于回合内受到伤害时，伤害值+1。',
}

return extension
