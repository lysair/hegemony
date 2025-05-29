local fengyang = fk.CreateSkill{
    name = "ld__fengyang",
    tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
    ["ld__fengyang"] = "风扬",
    [":ld__fengyang"] = "阵法技，与你处于同一<a href='heg_formation'>队列</a>的角色装备区内的牌被与你势力不同的角色弃置或获得时，取消之。",

    ["$ld__fengyang1"] = "谁也休想染指江东寸土。",
    ["$ld__fengyang2"] = "如此咽喉要地，吾当倾力守之。",
}

local H = require "packages/hegemony/util"

fengyang:addEffect("arraysummon", {
    array_type = "formation",
})

fengyang:addEffect(fk.BeforeCardsMove,{
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(fengyang.name) or #player.room.alive_players < 4  then return false end
    for _, move in ipairs(data) do
      if move.from and H.inFormationRelation(player, move.from)and player:hasShownSkill(fengyang.name) and
        (move.moveReason == fk.ReasonDiscard or (move.toArea == Card.PlayerHand and move.to ~= move.from and move.moveReason ~= fk.ReasonGive))
        and move.proposer and not H.compareKingdomWith(move.proposer, player)  then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerEquip then
            return true
          end
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local ids, targets = {}, {}
    room:notifySkillInvoked(player, fengyang.name, "defensive")
    player:broadcastSkillInvoke(fengyang.name)
    for _, move in ipairs(data) do
      if move.from and H.inFormationRelation(player, move.from) and
        (move.moveReason == fk.ReasonDiscard or (move.toArea == Card.PlayerHand and move.to ~= move.from and move.moveReason ~= fk.ReasonGive))
        and move.proposer and not H.compareKingdomWith(move.proposer, player) then
        local move_info = {}
        for _, info in ipairs(move.moveInfo) do
          local id = info.cardId
          if info.fromArea == Card.PlayerEquip then
            table.insert(ids, id)
          else
            table.insert(move_info, info)
          end
          if #ids > 0 then
            table.insertIfNeed(targets, move.from)
            move.moveInfo = move_info
          end
        end
      end
    end
    if #ids > 0 then
      room:doIndicate(player.id, targets)
      room:sendLog{
        type = "#cancelDismantle",
        card = ids,
        arg = fengyang.name,
      }
    end
  end,
})

return fengyang