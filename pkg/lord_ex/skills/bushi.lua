local bushi = fk.CreateSkill{
    name = "ld__bushi",
}

Fk:loadTranslationTable{
    ["ld__bushi"] = "布施",
    [":ld__bushi"] = "一名角色的结束阶段，若你于此回合内造成或受到过伤害，你可移去一张“米”，令至多X名角色各摸一张牌（X为你的体力上限），以此法摸牌的角色可依次将一张牌置于你武将牌上，称为“米”。",
    ["#ld__bushi_discard"] = "布施：你可以移去一张“米”，令至多你体力上限名角色各摸一张牌。",
    ["#ld__bushi"] = "布施：你可以将一张牌置于张鲁武将牌上，称为“米”。",
    ["ld__midao_rice"] = "米",

    ["$ld__bushi1"] = "争斗，永远没有赢家。",
    ["$ld__bushi2"] = "和平，永远没有输家。",
}

bushi:addEffect(fk.EventPhaseStart,{
    anim_type = "drawcard",
    can_trigger = function (self, event, target, player, data)
       return player:hasSkill(bushi.name) and target.phase == Player.Finish
       and player:getMark("ld__bushi-turn") > 0 and #player:getPile("ld__midao_rice") > 0
    end,
    on_cost = function(self, event, target, player, data)
       local card = player.room:askToCards(player,{
          min_num = 1,
          max_num = 1,
          include_equip = false,
          skill_name = bushi.name,
          pattern = ".|.|.|ld__midao_rice",
          prompt = "#ld__bushi_discard",
          expand_pile = "ld__midao_rice",
          cancelable = true,
      })
      if #card > 0 then
        event:setCostData(self, {card = card})
        return true
       end
    end,
    on_use = function (self, event, target, player, data)
      local room = player.room
      room:moveCardTo(event:getCostData(self).card, Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile, bushi.name, "ld__midao_rice", true, player)
      local targets =room.alive_players
      local tos = room:askToChoosePlayers(player,{
           targets = targets,
           min_num = 1,
           max_num = player.maxHp,
           prompt = "#ld__midao-choose",
           skill_name = bushi.name,
           cancelable = false
      })
      room:sortByAction(tos)
      if #tos == 0 then
        tos = table.random(targets, 1)
      end
      for _, p in ipairs(tos) do
        if not p.dead then
          p:drawCards(1, bushi.name)
        end
      end
      for _, p in ipairs(tos) do
        if not p.dead then
          local card = room:askToCards(p,{
              min_num = 1,
              max_num = 1,
              include_equip = true,
              skill_name = bushi.name,
              prompt = "#ld__bushi",
        })
        if #card > 0 then
            player:addToPile("ld__midao_rice", card, true, bushi.name)
          end
        end
      end
    end,
})

local bushi_spec = {
    can_refresh = function(self, event, target, player, data)
      return target == player and player:hasSkill(bushi.name)
    end,
    on_refresh = function(self, event, target, player, data)
      player.room:addPlayerMark(player, "ld__bushi-turn", 1)
    end,
}

bushi:addEffect(fk.Damage, bushi_spec)
bushi:addEffect(fk.Damaged, bushi_spec)

return bushi