local xionghuo = fk.CreateSkill{
  name = "of_heg__xionghuo",
}
local H = require "packages/hegemony/util"
xionghuo:addEffect("active", {
  anim_type = "offensive",
  card_num = 0,
  target_num = 1,
  prompt = "#of_heg__xionghuo-active",
  can_use = function(self, player)
    return player:getMark("@of_heg__baoli") > 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected)
    return #selected == 0 and to_select ~= player and
      to_select:getMark("@of_heg__baoli") == 0 and
      not H.compareKingdomWith(player, to_select)
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    room:removePlayerMark(player, "@of_heg__baoli", 1)
    room:addPlayerMark(target, "@of_heg__baoli", 1)
  end,
})
xionghuo:addEffect(fk.GeneralRevealed, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(xionghuo.name) then
      if player:usedSkillTimes(xionghuo.name, Player.HistoryGame) == 0 then
        for _, v in pairs(data) do
          if table.contains(Fk.generals[v]:getSkillNameList(), xionghuo.name) then return true end
        end
      end
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:addPlayerMark(player, "@of_heg__baoli", 3)
  end,
})
xionghuo:addEffect(fk.DamageCaused, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(xionghuo.name) and target == player
      and data.to ~= player and data.to:getMark("@of_heg__baoli") > 0
      and data.card and data.to:getMark("@@of_heg__baoli_damage-turn") == 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:doIndicate(player.id, {data.to.id})
    data:changeDamage(1)
    room:setPlayerMark(data.to, "@@of_heg__baoli_damage-turn", 1)
  end,
})
xionghuo:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(xionghuo.name) and target ~= player and
      target:getMark("@of_heg__baoli") > 0 and target.phase == Player.Play
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
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
        room:addTableMark(target, "of_heg__xionghuo_prohibit-turn", player.id)
      end
    elseif rand == 2 then
      room:loseHp(target, 1, "of_heg__xionghuo")
      if not target.dead then
        room:addPlayerMark(target, "MinusMaxCards-turn", 1)
      end
    else
      local cards = table.random(target:getCardIds("h"), 1)
      table.insertTable(cards, table.random(target:getCardIds("e"), 1))
      room:obtainCard(player, cards, false, fk.ReasonPrey)
    end
  end,
})
xionghuo:addLoseEffect(function (self, player, is_death)
  for _, p in ipairs(player.room.alive_players) do
    if p:getMark("@of_heg__baoli") > 0 then
      player.room:setPlayerMark(p, "@of_heg__baoli", 0)
    end
  end
end)
xionghuo:addEffect("prohibit", {
  is_prohibited = function(self, from, to, card)
    return card.trueName == "slash" and table.contains(from:getTableMark("of_heg__xionghuo_prohibit-turn") ,to.id)
  end,
})

Fk:loadTranslationTable{
  ["of_heg__xionghuo"] = "凶镬",
  [":of_heg__xionghuo"] = "①当你首次明置此武将牌后，你获得三枚“暴戾”标记。"..
    "②出牌阶段，你可以交给一名与你势力不同的角色一枚“暴戾”标记。"..
    "③每回合每名角色限一次，当你使用牌对拥有“暴戾”标记的其他角色造成伤害时，此伤害+1。"..
    "④拥有“暴戾”标记的其他角色出牌阶段开始时，其移去“暴戾”标记并随机执行："..
    "1.你对其造成1点火焰伤害，其本回合不能对你使用【杀】；2.其失去1点体力且本回合手牌上限-1；"..
    "3.你获得其装备区里的一张牌，然后获得其一张手牌。",

  ["#of_heg__xionghuo_record"] = "凶镬",
  ["@of_heg__baoli"] = "暴戾",
  ["#of_heg__xionghuo-active"] = "发动 凶镬，将“暴戾”交给其他角色",
  ["@@of_heg__baoli_damage-turn"] = "凶镬 已造伤",

  ["$of_heg__xionghuo1"] = "战场上的懦夫，可不会有好结局！",
  ["$of_heg__xionghuo2"] = "用最残忍的方式，碾碎敌人！",
}

return xionghuo
