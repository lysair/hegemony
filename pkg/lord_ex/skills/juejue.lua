local juejue = fk.CreateSkill{
    name = "ld__juejue",
}

Fk:loadTranslationTable{
    ["ld__juejue"] = "决绝",
    [":ld__juejue"] = "①弃牌阶段开始时，你可失去1点体力，若如此做，此阶段结束时，若你于此阶段内弃置过牌，你令所有其他角色选择一项：1.将X张手牌置入弃牌堆；2.受到你造成的1点伤害（X为你于此阶段内弃置的牌数）；②你杀死与你势力相同的角色不执行奖惩。",
    ["#ld__juejue-ask"] = "决绝：你可失去1点体力",

    ["ld__juejue_damage"] = "受到伤害",
    ["ld__juejue_putcard"] = "将牌置入弃牌堆",
}

local H = require "packages/hegemony/util"

juejue:addEffect(fk.EventPhaseStart,{
    anim_type = "offensive",
    can_trigger = function(self, event, target, player, data)
        if not player:hasSkill(juejue.name) then return end
          return target == player and player.phase == Player.Discard
      end,
    on_cost = function(self, event, target, player, data)
          return player.room:askToSkillInvoke(player, {skill_name = juejue.name, data =  data, prompt = "#ld__juejue-ask"})
      end,
    on_use = function (self, event, target, player, data)
          local room = player.room
          room:loseHp(player, 1, juejue.name)
      end,
})

juejue:addEffect(fk.EventPhaseEnd,{
    is_delay_effect = true,
    can_trigger = function (self, event, target, player, data)
        if not (target == player and player.phase == Player.Discard and player:isAlive() and player:usedSkillTimes(juejue.name, Player.HistoryPhase) > 0) then return false end
        local x = 0
        local logic = player.room.logic
        logic:getEventsOfScope(GameEvent.MoveCards, 1, function (e)
          for _, move in ipairs(e.data) do
            if move.from == player and move.moveReason == fk.ReasonDiscard and move.skillName == "phase_discard"  then
              x = x + #move.moveInfo
              if x > 1 then return true end
            end
          end
          return false
        end, Player.HistoryTurn)
        event:setCostData(self,{num = x})
        return x > 0
      end,
      on_cost = Util.TrueFunc,
      on_use = function (self, event, target, player, data)
        local room = player.room
        local targets = room:getOtherPlayers(player)
        local n = event:getCostData(self).num
        for _, p in ipairs(targets) do
          if not p.dead then
            local choices = {"ld__juejue_damage"}
            if #p:getCardIds("h") >= n then
              table.insert(choices, "ld__juejue_putcard")
            end
            local choice = room:askToChoice(p, {choices = choices, skill_name = juejue.name})
            if choice == "ld__juejue_damage" then
              room:damage{
                from = player,
                to = p,
                damage = 1,
                skillName = juejue.name,
              }
            else
              local card = room:askToCards(p,{
                min_num = n,
                max_num = n,
                include_equip = false,
                skill_name = juejue.name,
                pattern = ".|.|.|hand",
                cancelable = false,
              })
              room:moveCardTo(card, Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile, juejue.name)
            end
          end
        end
      end,
})

juejue:addEffect(fk.BuryVictim,{
    can_trigger = function(self, event, target, player, data)
        if not player:hasSkill(juejue.name) then return end
          return data.damage and data.damage.from == player and H.compareKingdomWith(player, target)
      end,
    on_cost = Util.TrueFunc,
    on_use = function (self, event, target, player, data)
        local room = player.room
          local deathEvent = room.logic:getCurrentEvent():findParent(GameEvent.Death, true).data
          deathEvent.extra_data = deathEvent.extra_data or {}
          deathEvent.extra_data.ignorePunishment = true
      end,
})

return juejue