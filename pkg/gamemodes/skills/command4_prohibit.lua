-- 军令四
local command4_prohibit = fk.CreateSkill{
  name = "#command4_prohibit",
}
command4_prohibit:addEffect("prohibit", {
  -- global = true,
  prohibit_use = function(self, player, card)
    if player:getMark("@@command4_effect-turn") > 0 then
      local subcards = card:isVirtual() and card.subcards or {card.id}
      return #subcards > 0 and table.every(subcards, function(id) return table.contains(player:getCardIds(Player.Hand), id) end)
    end
  end,
  prohibit_response = function(self, player, card)
    if player:getMark("@@command4_effect-turn") > 0 then
      local subcards = card:isVirtual() and card.subcards or {card.id}
      return #subcards > 0 and table.every(subcards, function(id) return table.contains(player:getCardIds(Player.Hand), id) end)
    end
  end,
})
return command4_prohibit
