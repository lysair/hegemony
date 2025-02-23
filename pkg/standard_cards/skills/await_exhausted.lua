local awaitExhaustedSkill = fk.CreateSkill{
  name = "await_exhausted_skill",
}

local H = require "packages/hegemony/util"

awaitExhaustedSkill:addEffect("cardskill", {
  prompt = "#await_exhausted_skill",
  mod_target_filter = function(self, player, to_select, selected)
    return H.compareKingdomWith(to_select, player, false)
  end,
  can_use = function(self, player, card)
    if player:prohibitUse(card) then return end
    for _, p in ipairs(Fk:currentRoom().alive_players) do
      if not player:isProhibited(p, card) and self:modTargetFilter(player, p, {}, card, true) then
        return true
      end
    end
  end,
  on_use = function(self, room, use)
    if not use.tos or #use.tos == 0 then
      local player = use.from
      if player.kingdom == "unknown" then
        use.tos = { use.from }
      else
        use.tos = {}
        for _, p in ipairs(room:getAlivePlayers()) do
          if not player:isProhibited(p, use.card) and H.compareKingdomWith(p, player) then
            use:addTarget(p)
          end
        end
      end
    end
  end,
  on_effect = function(self, room, effect)
    local target = effect.to
    if target.dead then return end
    target:drawCards(2, "await_exhausted")
    if target.dead then return end
    room:askToDiscard(target, {min_num = 2, max_num = 2, include_equip = true,
      skill_name = "await_exhausted", cancelable = false})
  end,
})

awaitExhaustedSkill:addTest(function (room, me)
  local card = Fk:cloneCard("await_exhausted")
  FkTest.runInRoom(function()
    local targets = table.filter(room.alive_players, function(p) return p.kingdom == me.kingdom end)
    for i = 1, #targets do
      room:obtainCard(targets[i], 2 * i - 1, true)
      room:obtainCard(targets[i], 2 * i, true)
    end
    room:useCard{
      from = me,
      card = card,
      tos = { },
    }
  end)
  lu.assertEquals(me:getHandcardNum(), 2)
end)

Fk:loadTranslationTable{
  ["await_exhausted"] = "以逸待劳",
  ["await_exhausted_skill"] = "以逸待劳",
  [":await_exhausted"] = "锦囊牌<br/><b>时机</b>：出牌阶段<br/><b>目标</b>：你和与你势力相同的角色<br/><b>效果</b>：每名目标角色各摸两张牌，"..
  "然后弃置两张牌。",
  ["#await_exhausted_skill"] = "你和与你势力相同的角色各摸两张牌，然后弃置两张牌",
}

return awaitExhaustedSkill
