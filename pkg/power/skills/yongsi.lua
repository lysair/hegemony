
local yongsi = fk.CreateSkill{
  name = "ld__yongsi",
  tags = {Skill.Compulsory}
}
local H = require "packages/hegemony/util"

--- 没有角色有玉玺
---@param player ServerPlayer
---@return boolean
local canYongsi = function (player)
  return not table.find(player.room.alive_players, function(p)
    return not not table.find(p:getEquipments(Card.SubtypeTreasure), function(cid)
      return Fk:getCardById(cid).name == "jade_seal"
    end)
  end)
end
yongsi:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    if target ~= player or not player:hasSkill(yongsi.name) or
      not canYongsi(player) or player.phase ~= Player.Play then return false end
    local card = Fk:cloneCard("known_both")
    return player:canUse(card)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local card = Fk:cloneCard("known_both")
    local max_num = card.skill:getMaxTargetNum(player, card)
    local targets = table.filter(room:getOtherPlayers(player, false), function (p)
      return not player:isProhibited(p, card)
    end)
    if #targets == 0 or max_num == 0 then return end
    local to = room:askToChoosePlayers(player, {
      targets = targets, min_num = 1, max_num = max_num,
      prompt = "#yongsi__jade_seal-ask", skill_name = yongsi.name, cancelable = false
    })
    if #to > 0 then
      event:setCostData(self, {tos = to})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:useVirtualCard("known_both", nil, player, event:getCostData(self).tos, yongsi.name)
  end,
})
yongsi:addEffect(fk.DrawNCards, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(yongsi.name) and canYongsi(player)
  end,
  on_use = function(self, event, target, player, data)
    data.n = data.n + 1
  end,
})
yongsi:addEffect("bigkingdom", {
  fixed_func = function(self, player)
    return player:hasShownSkill(yongsi.name) and player.kingdom ~= "unknown" and canYongsi(player)
  end
})
yongsi:addEffect(fk.TargetConfirmed, {
  anim_type = "negative",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(yongsi.name) and
      data.card.trueName == "known_both" and not player:isKongcheng()
  end,
  on_use = function(self, event, target, player, data)
    if not player:isKongcheng() then
      player:showCards(player:getCardIds(Player.Hand))
    end
  end,
})

Fk:loadTranslationTable{
  ['ld__yongsi'] = "庸肆",
  [':ld__yongsi'] = "锁定技，①若所有角色的装备区里均没有【玉玺】，你视为装备着【玉玺】；②当你成为【知己知彼】的目标后，展示所有手牌。",

  ["#yongsi__jade_seal-ask"] = "庸肆：受到【玉玺】的效果，视为你使用一张【知己知彼】",

  ["$ld__yongsi1"] = "大汉天下，已半入我手。",
  ["$ld__yongsi2"] = "玉玺在手，天下我有。",
}

return yongsi
