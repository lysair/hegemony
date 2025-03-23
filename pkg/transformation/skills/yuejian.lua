
local yuejian = fk.CreateSkill{
  name = "ld__yuejian",
  tags = {Skill.Compulsory}
}
local H = require "packages/hegemony/util"
yuejian:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return H.compareKingdomWith(player, target) and player:hasSkill(yuejian.name) and target.phase == Player.Discard
      and target:getMark("ld__yuejian-turn") == 0 and player.room.current == target
  end,
  on_cost = function(self, event, target, player, data)
    event:setCostData(self, { tos = {target} })
    return true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:addPlayerMark(target, "_yuejian_maxcard-turn", 1)
  end,
})
yuejian:addEffect(fk.TargetSpecified, {
  can_refresh = function(self, event, target, player, data)
    return H.compareKingdomWith(target, player) and target == player.room.current
      and target:getMark("ld__yuejian-turn") == 0 and data.firstTarget and data.card.type ~= Card.TypeEquip
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    for _, p in ipairs(data:getAllTargets()) do
      if not H.compareKingdomWith(p, target) then
        room:addPlayerMark(target, "ld__yuejian-turn", 1)
        break
      end
    end
  end,
})
yuejian:addEffect("maxcards", {
  fixed_func = function(self, player)
    if player:getMark("_yuejian_maxcard-turn") > 0 then
      return player.maxHp
    end
  end
})

Fk:loadTranslationTable{
  ["ld__yuejian"] = "约俭",
  [":ld__yuejian"] = "锁定技，与你势力相同角色的弃牌阶段开始时，若其本回合处于与你势力相同状态时未对其他势力角色使用过牌，其本回合的手牌上限改为其体力上限。",

  ["$ld__yuejian1"] = "常闻君子以俭德辟难，不可荣以禄。",
  ["$ld__yuejian2"] = "如今世事未定，不可铺张浪费。",
}

return yuejian
