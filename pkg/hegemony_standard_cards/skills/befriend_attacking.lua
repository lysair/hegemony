local befriendAttackingSkill = fk.CreateSkill{
  name = "befriend_attacking_skill",
}

local H = require "packages/hegemony/util"

befriendAttackingSkill:addEffect("cardskill", {
  prompt = "#befriend_attacking_skill",
  target_num = 1,
  mod_target_filter = function(self, player, to_select, selected)
    return player ~= to_select and H.compareKingdomWith(to_select, player, true)
  end,
  target_filter = Util.CardTargetFilter,
  can_use = function(self, player, card)
    return player.kingdom ~= "unknown" and not player:prohibitUse(card)
  end,
  on_effect = function(self, room, effect)
    local player = effect.from
    local target = effect.to
    if target.dead then return end
    target:drawCards(1, "befriend_attacking")
    if player.dead then return end
    player:drawCards(3, "befriend_attacking")
  end
})

befriendAttackingSkill:addTest(function (room, me)
  local card = Fk:cloneCard("befriend_attacking")
  local target = table.find(room.players, function(p) return
    p ~= me and (p.kingdom == "unknown" or p.kingdom == me.kingdom)
  end)
  if target then lu.assertEvalToFalse(me:canUseTo(card, target)) end

  target = table.find(room.players, function(p) return
    p ~= me and p.kingdom ~= "unknown" and p.kingdom ~= me.kingdom
  end)
  if target then
    FkTest.runInRoom(function()
      room:useCard{
        from = me,
        tos = {target},
        card = card,
      }
    end)
    lu.assertEquals(target:getHandcardNum(), 1)
    lu.assertEquals(me:getHandcardNum(), 3)
  end
end)

Fk:loadTranslationTable{
  ["befriend_attacking"] = "远交近攻",
  ["befriend_attacking_skill"] = "远交近攻",
  [":befriend_attacking"] = "锦囊牌<br/><b>时机</b>：出牌阶段<br/><b>目标</b>：有明置武将且势力与你不同的一名角色<br/><b>效果</b>：目标角色"..
    "摸一张牌，然后你摸三张牌。",
  ["#befriend_attacking_skill"] = "选择势力与你不同的一名角色，其摸一张牌，你摸三张牌",
}

return befriendAttackingSkill
