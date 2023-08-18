local extension = Package:new("power")
extension.extensionName = "hegemony"
extension.game_modes_whitelist = { 'nos_heg_mode', 'new_heg_mode' }
local H = require "packages/hegemony/util"

Fk:loadTranslationTable{
  ["power"] = "君临天下·权",
}

local yujin = General(extension, "ld__yujin", "wei", 4)
local jieyue = fk.CreateTriggerSkill{
  name = "ld__jieyue",
  anim_type = "control",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and player.phase == Player.Start and not player:isKongcheng() and table.find(player.room.alive_players, function(p) return
      p.kingdom ~= "wei"
    end)
  end,
  on_cost = function(self, event, target, player, data)
    local plist, cid = player.room:askForChooseCardAndPlayers(player, table.map(table.filter(player.room.alive_players, function(p) return
      p.kingdom ~= "wei"
    end), Util.IdMapper), 1, 1, ".|.|.|hand", "#ld__jieyue-target", self.name, true)
    if #plist > 0 then
      self.cost_data = {plist[1], cid}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = self.cost_data[1]
    local target = room:getPlayerById(to)
    room:moveCardTo(self.cost_data[2], Player.Hand, target, fk.ReasonGive, self.name, nil, false, player.id)
    if H.askCommandTo(player, target, self.name) then
      player:drawCards(1, self.name)
    else
      room:addPlayerMark(player, "_ld__jieyue-turn")
    end
  end
}
local jieyue_draw = fk.CreateTriggerSkill{
  name = "#ld__jieyue_draw",
  mute = true,
  frequency = Skill.Compulsory,
  events = {fk.DrawNCards},
  can_use = function(self, event, target, player, data)
    return target == player and target:getMark("_ld__jieyue-turn") > 0
  end,
  on_use = function(self, event, target, player, data)
    data.n = data.n + 3 * target:getMark("_ld__jieyue-turn")
  end,
}
jieyue:addRelatedSkill(jieyue_draw)

yujin:addSkill(jieyue)

Fk:loadTranslationTable{
  ['ld__yujin'] = '于禁',
  ['ld__jieyue'] = '节钺',
  [':ld__jieyue'] = '准备阶段开始时，你可将一张手牌交给不是魏势力或没有势力的一名角色，对其发起军令。若其：执行，你摸一张牌；不执行，摸牌阶段，你令额定摸牌数+3。',

  ["#ld__jieyue-target"] = "节钺：你可将一张手牌交给不是魏势力或没有势力的一名角色，对其发起军令",
  ["#ld__jieyue_draw"] = "节钺",
}

local wuguotai = General(extension, "ld__wuguotai", "wu", 3, 3, General.Female)
local buyi = fk.CreateTriggerSkill{
  name = "ld__buyi",
  anim_type = "support",
  events = {fk.AfterDying},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self.name) and target and H.compareKingdomWith(target, player) and not target.dead 
      and data.damage and data.damage.from and not data.damage.from.dead
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, nil, "#ld__buyi-ask:" .. target.id .. ":" .. data.damage.from.id)
  end,
  on_use = function(self, event, target, player, data)
    if not H.askCommandTo(player, data.damage.from, self.name) then
      player.room:recover({
        who = target,
        num = 1,
        recoverBy = player,
        skillName = self.name,
      })
    end
  end,
}

wuguotai:addSkill(buyi)
wuguotai:addSkill("ganlu")

Fk:loadTranslationTable{
  ['ld__wuguotai'] = '吴国太',
  ['ld__buyi'] = '补益',
  [':ld__buyi'] = '与你势力相同的角色的濒死结算结束后，若其存活，你可对伤害来源发起军令。若来源不执行，则你令该角色回复1点体力。',

  ["#ld__buyi-ask"] = "补益：你可对 %dest 发起军令。若来源不执行，则 %src 回复1点体力",
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
    local x = player.hp
    if not p or p.dead then return end
    local targets = {}
    for _, _p in ipairs(room.alive_players) do
      if H.compareKingdomWith(_p, p) then
        if _p.hp >= x then
          if _p.hp > x then
            targets = {}
            x = _p.hp
          end
          table.insert(targets, _p)
        end
      end
    end
    local to
    if #targets == 0 then return
    elseif #targets == 1 then
      to = targets[1].id
    else
      to = room:askForChoosePlayers(player, table.map(targets, Util.IdMapper),
        1, 1, '#ld__fudi-dmg', self.name, false)[1]
    end

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
