local midao = fk.CreateSkill{
    name = "ld__midao",
}

Fk:loadTranslationTable{
  ["ld__midao"] = "米道",
  [":ld__midao"] = "①当你明置此武将牌后，你摸两张牌，然后将两张牌置于武将牌上，称为“米”②一名角色的判定牌生效前，你可以打出一张“米”替换之。",

  ["#ld__midao-choose"] = "布施：选择至多你体力上限数名角色各摸一张牌",
  ["#ld__midao-ask"] = "米道：你可打出一张牌替换 %dest 的 %arg 判定",
  ["#ld__midao"] = "米道：请将两张牌置于武将牌上，称为“米”。",

  ["$ld__midao1"] = "恩结天地，法惠八荒。",
  ["$ld__midao2"] = "行五斗米道，可知暖饱。",
}

midao:addEffect(fk.GeneralRevealed,{
    anim_type = "offensive",
    derived_piles = "ld__midao_rice",
    can_trigger = function (self, event, target, player, data)
      if player:hasSkill(midao.name) then
        for _, v in pairs(data) do
          if table.contains(Fk.generals[v]:getSkillNameList(), midao.name) then return true end
        end
      end
    end,
    on_cost = Util.FalseFunc,
    on_use = function (self, event, target, player, data)
      player:drawCards(2, midao.name)
      if player:isNude() then return end
      local cards
      if #player:getCardIds("he") < 3 then
        cards = player:getCardIds("he")
      else
        cards = player.room:askToCards(player,{
            min_num = 2,
             max_num = 2,
            include_equip = true,
            skill_name = midao.name,
            prompt = "#ld__midao",
            cancelable = false,
        })
      end
        player:addToPile("ld__midao_rice", cards, true, midao.name)
    end,
})

midao:addEffect(fk.AskForRetrial,{
    anim_type = "offensive",
    derived_piles = "ld__midao_rice",
    can_trigger = function (self, event, target, player, data)
       return player:hasSkill(midao.name) and #player:getPile("ld__midao_rice") > 0
    end,
     on_cost = function (self, event, target, player, data)
      local card = player.room:askToCards(player,{
        min_num = 1,
        max_num = 1,
        include_equip = false,
        skill_name = midao.name,
        pattern = ".|.|.|ld__midao_rice",
        prompt = "#ld__midao-ask::" .. target.id .. ":" .. data.reason,
        expand_pile = "ld__midao_rice",
        cancelable = true,
    })
      if #card > 0 then
        event:setCostData(self, { cards = card })
        return true
      end
    end,
    on_use = function (self, event, target, player, data)
      player.room:changeJudge{
      card = Fk:getCardById(event:getCostData(self).cards[1]),
      player = player,
      data = data,
      skillName = midao.name,
      response = true,
    }
    end,
})

return midao