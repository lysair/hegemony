local jilix = fk.CreateSkill {
  name = "ld__jilix",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable {
  ["ld__jilix"] = "寄篱",
  [":ld__jilix"] = "锁定技，①当你成为红色基本牌或红色普通锦囊牌的唯一目标后，你令此牌结算两次；②当你于一回合内第二次受到伤害时，你移除此武将牌，防止之。",

  ["$ld__jilix1"] = "处处受制于人，难施拳脚。",
  ["$ld__jilix2"] = "寄居人下，终是气短！",
}

local H = require "packages/hegemony/util"

jilix:addEffect(fk.TargetConfirmed, {
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(jilix.name) and target == player and data.card.color == Card.Red
        and (data.card.type == Card.TypeBasic or data.card:isCommonTrick()) and #data:getAllTargets() == 1
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data.use.additionalEffect = (data.use.additionalEffect or 0) + 1
  end,
})

jilix:addEffect(fk.DamageInflicted, {
  can_trigger = function(self, event, target, player, data)
    if not (player:hasSkill(jilix.name) and target == player) then return false end
    local events = player.room.logic:getActualDamageEvents(2, function(e) return e.data.to == player end,
      Player.HistoryTurn)
    return #events == 1
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local isDeputy = H.inGeneralSkills(player, jilix.name)
    if isDeputy then
      H.removeGeneral(player, isDeputy == "d")
      data:preventDamage()
    end
  end,
})

return jilix
