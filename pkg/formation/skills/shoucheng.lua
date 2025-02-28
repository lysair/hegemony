
local shoucheng = fk.CreateSkill{
  name = "shoucheng",
}

local H = require "packages/hegemony/util"

shoucheng:addEffect(fk.AfterCardsMove, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(shoucheng.name) then return end
    for _, move in ipairs(data) do
      if move.from then
        if move.from:isKongcheng() and H.compareKingdomWith(move.from, player) and player.room.current ~= move.from then
          for _, info in ipairs(move.moveInfo) do
            if info.fromArea == Card.PlayerHand then
              return true
            end
          end
        end
      end
    end
  end,
  on_trigger = function(self, event, target, player, data)
    local targets = {}
    local room = player.room
    for _, move in ipairs(data) do
      if move.from then
        if move.from:isKongcheng() and H.compareKingdomWith(move.from, player) and player.room.current ~= move.from then
          for _, info in ipairs(move.moveInfo) do
            if info.fromArea == Card.PlayerHand then
              table.insertIfNeed(targets, move.from)
            end
          end
        end
      end
    end
    room:sortByAction(targets)
    for _, _p in ipairs(targets) do
      if not player:hasSkill(shoucheng.name) then break end
      if _p:isAlive() then
        self:doCost(event, _p, player, nil)
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, shoucheng.name, nil, "#shoucheng-draw::" .. target.id)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:doIndicate(player.id, {target.id})
    target:drawCards(1, shoucheng.name)
  end,
})

Fk:loadTranslationTable{
  ["shoucheng"] = "守成",
  [":shoucheng"] = "与你势力相同的角色于其回合外失去手牌后，若其没有手牌，你可令其摸一张牌。",

  ["#shoucheng-draw"] = "守成：你可令 %dest 摸一张牌",

  ["$shoucheng1"] = "待吾等助将军一臂之力！",
  ["$shoucheng2"] = "国库盈余，可助军威。",
}

return shoucheng
