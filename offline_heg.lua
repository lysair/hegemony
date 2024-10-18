local extension = Package:new("offline_heg")
extension.extensionName = "hegemony"
extension.game_modes_whitelist = { 'nos_heg_mode', 'new_heg_mode' }

local H = require "packages/hegemony/util"
local U = require "packages/utility/utility"

Fk:loadTranslationTable{
  ["offline_heg"] = "国战-线下卡专属",
  ["of_heg"] = "线下",
}

local xurong = General(extension, "of_heg__xurong", "qun", 4)
local xionghuo = fk.CreateActiveSkill{
  name = "of_heg__xionghuo",
  anim_type = "offensive",
  card_num = 0,
  target_num = 1,
  prompt = "#of_heg__xionghuo-active",
  can_use = function(self, player)
    return player:getMark("@of_heg__baoli") > 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, to_select, selected)
    local target = Fk:currentRoom():getPlayerById(to_select)
    return #selected == 0 and to_select ~= Self.id and target:getMark("@of_heg__baoli") == 0 and not H.compareKingdomWith(Self, target)
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    room:removePlayerMark(player, "@of_heg__baoli", 1)
    room:addPlayerMark(target, "@of_heg__baoli", 1)
  end,
}
local xionghuo_record = fk.CreateTriggerSkill{
  name = "#of_heg__xionghuo_record",
  main_skill = xionghuo,
  anim_type = "offensive",
  events = {fk.GeneralRevealed, fk.DamageCaused, fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(xionghuo.name) then
      if event == fk.GeneralRevealed then
        if player:usedSkillTimes(self.name, Player.HistoryGame) == 0 then
          for _, v in pairs(data) do
            if table.contains(Fk.generals[v]:getSkillNameList(), xionghuo.name) then return true end
          end
        end
      elseif event == fk.DamageCaused then
        return target == player and data.to ~= player and data.to:getMark("@of_heg__baoli") > 0 and data.card and data.to:getMark("@@of_heg__baoli_damage-turn") == 0
      else
        return target ~= player and target:getMark("@of_heg__baoli") > 0 and target.phase == Player.Play
      end
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke("of_heg__xionghuo")
    if event == fk.GeneralRevealed then
      room:addPlayerMark(player, "@of_heg__baoli", 3)
    elseif event == fk.DamageCaused then
      room:doIndicate(player.id, {data.to.id})
      data.damage = data.damage + 1
      room:setPlayerMark(data.to, "@@of_heg__baoli_damage-turn", 1)
    else
      room:doIndicate(player.id, {target.id})
      room:setPlayerMark(target, "@of_heg__baoli", 0)
      local rand = math.random(1, target:isNude() and 2 or 3)
      if rand == 1 then
        room:damage {
          from = player,
          to = target,
          damage = 1,
          damageType = fk.FireDamage,
          skillName = "of_heg__xionghuo",
        }
        if not (player.dead or target.dead) then
          local mark = U.getMark(target, "of_heg__xionghuo_prohibit-turn")
          table.insert(mark, player.id)
          room:setPlayerMark(target, "of_heg__xionghuo_prohibit-turn", mark)
        end
      elseif rand == 2 then
        room:loseHp(target, 1, "of_heg__xionghuo")
        if not target.dead then
          room:addPlayerMark(target, "MinusMaxCards-turn", 1)
        end
      else
        local cards = table.random(target:getCardIds(Player.Hand), 1)
        table.insertTable(cards, table.random(target:getCardIds(Player.Equip), 1))
        room:obtainCard(player, cards, false, fk.ReasonPrey)
      end
    end
  end,

  refresh_events = {fk.BuryVictim, fk.EventLoseSkill},
  can_refresh = function(self, event, target, player, data)
    if event == fk.BuryVictim then
      return player == target and player:hasSkill(xionghuo, true, true) and table.every(player.room.alive_players, function (p)
        return not p:hasSkill(xionghuo, true)
      end)
    elseif event == fk.EventLoseSkill then
      return player == target and data == xionghuo and table.every(player.room.alive_players, function (p)
        return not p:hasSkill(xionghuo, true)
      end)
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    for _, p in ipairs(room.alive_players) do
      if p:getMark("@of_heg__baoli") > 0 then
        room:setPlayerMark(p, "@of_heg__baoli", 0)
      end
    end
  end,
}
local xionghuo_prohibit = fk.CreateProhibitSkill{
  name = "#of_heg__xionghuo_prohibit",
  is_prohibited = function(self, from, to, card)
    return card.trueName == "slash" and table.contains(U.getMark(from, "of_heg__xionghuo_prohibit-turn") ,to.id)
  end,
}

xionghuo:addRelatedSkill(xionghuo_record)
xionghuo:addRelatedSkill(xionghuo_prohibit)
xurong:addSkill(xionghuo)

Fk:loadTranslationTable{
  ["of_heg__xurong"] = "徐荣",
  ["#of_heg__xurong"] = "玄菟战魔",
  ["cv:of_heg__xurong"] = "曹真",
  ["designer:of_heg__xurong"] = "Loun老萌",
  ["illustrator:of_heg__xurong"] = "青岛磐蒲",

  ["of_heg__xionghuo"] = "凶镬",
  [":of_heg__xionghuo"] = "①当你首次明置此武将牌后，你获得三枚“暴戾”标记。②出牌阶段，你可以交给一名与你势力不同的角色一枚“暴戾”标记。③每回合每名角色限一次，当你使用牌对拥有“暴戾”标记的其他角色造成伤害时，此伤害+1。④拥有“暴戾”标记的其他角色出牌阶段开始时，其移去“暴戾”标记并随机执行：1.你对其造成1点火焰伤害，其本回合不能对你使用【杀】；2.其失去1点体力且本回合手牌上限-1；3.你获得其装备区里的一张牌，然后获得其一张手牌。",
  
  ["#of_heg__xionghuo_record"] = "凶镬",
  ["@of_heg__baoli"] = "暴戾",
  ["#of_heg__xionghuo-active"] = "发动 凶镬，将“暴戾”交给其他角色",
  ["@@of_heg__baoli_damage-turn"] = "凶镬 已造伤",

  ["$of_heg__xionghuo1"] = "战场上的懦夫，可不会有好结局！",
  ["$of_heg__xionghuo2"] = "用最残忍的方式，碾碎敌人！",
  ["~of_heg__xurong"] = "死于战场……是个不错的结局……",
}
return extension
