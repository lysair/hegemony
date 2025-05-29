local wenji = fk.CreateSkill{
    name = "ld__wenji",
}

Fk:loadTranslationTable{
    ["ld__wenji"] = "问计",
    [":ld__wenji"] = "出牌阶段开始时，你可令一名角色交给你一张牌，然后若其：与你势力相同或未确定势力，你于此回合内使用此牌无距离与次数限制且不能被响应；与你势力不同，你交给其另一张牌。",

    ["#wenji-choose"] = "问计：选择一名其他角色，令其交给你一张牌，然后根据其势力执行不同效果。",
    ["#wenji-give"] = "问计：交给 %dest 一张牌",

    ["$ld__wenji1"] = "言出子口，入于吾耳，可以言未？",
    ["$ld__wenji2"] = "还望先生救我！。",
}

local H = require "packages/hegemony/util"

wenji:addEffect(fk.EventPhaseStart,{
    anim_type = "control",
    can_trigger = function(self, event, target, player, data)
        return target == player and player:hasSkill(wenji.name) and player.phase == Player.Play and
        not table.every(player.room:getOtherPlayers(player, false), function(p) return (p:isNude()) end)
      end,
    on_cost = function(self, event, target, player, data)
        local room = player.room
        local to = room:askToChoosePlayers(player,{
            targets = table.filter(room:getOtherPlayers(player, false), function(p) return not p:isNude() end),
            min_num = 1,
            max_num = 1,
            prompt = "#wenji-choose",
            skill_name = wenji.name,
            cancelable = true,
        })
        if #to > 0 then
          event:setCostData(self,{to = to})
          return true
        end
      end,
    on_use = function(self, event, target, player, data)
        local room = player.room
        local to = event:getCostData(self).to[1]
        local card = room:askToCards(to,{
            min_num = 1,
            max_num = 1,
            include_equip = true,
            prompt = "#wenji-give::"..player.id,
            skill_name = wenji.name,
            cancelable = false,
        })
        if H.compareKingdomWith(player, to, true) then
          if not player:isNude() then
            room:obtainCard(player, card[1], false, fk.ReasonGive)
            local card_back = room:askToCards(player,{
                min_num = 1,
                max_num = 1,
                include_equip = true,
                skill_name = wenji.name,
                prompt = "#wenji-give::"..to.id,
                pattern = ".|.|.|.|.|.|^" .. card[1],
                cancelable = false,
            })
            room:obtainCard(to, card_back[1], false, fk.ReasonGive)
          end
        else
          room:obtainCard(player, card[1], false, fk.ReasonGive)
          room:setPlayerMark(player, "ld__wenji-turn", card[1])
        end
      end,
})

wenji:addEffect("targetmod",{
    bypass_times = function(self, player, skill, scope, card, to)
      return card and card.id == player:getMark("ld__wenji-turn") and not card:isVirtual()
    end,
    bypass_distances =  function(self, player, skill, card, to)
      return card and card.id == player:getMark("ld__wenji-turn") and not card:isVirtual()
    end,
})

wenji:addEffect(fk.CardUsing,{
    mute = true,
    can_trigger = function(self, event, target, player, data)
      return target == player and player:usedSkillTimes(wenji.name, Player.HistoryTurn) > 0 and player:getMark("ld__wenji-turn") ~= 0 and
      player:getMark("ld__wenji-turn") == data.card.id
    end,
    on_cost = Util.TrueFunc,
    on_use = function(self, event, target, player, data)
      data.disresponsiveList = player.room.players
    end,
})

return wenji