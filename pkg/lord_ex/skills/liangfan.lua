local liangfan = fk.CreateSkill{
    name = "ld__liangfan",
    tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
    ["ld__liangfan"] = "量反",
    [":ld__liangfan"] = "锁定技，准备阶段，若你有“函”，你获得之，然后失去1点体力，当你于此回合内使用以此法获得的牌造成伤害后，你可以获得受伤角色的一张牌。",

    ["@@ld__mengda_letter-turn"] = "函",

    ["$ld__liangfan1"] = "今举兵投魏，必可封王拜相，一展宏图。",
    ["$ld__liangfan2"] = "今举义军事若成，吾为复汉元勋也。",
}


liangfan:addEffect(fk.EventPhaseStart,{
    anim_type = "offensive",
    can_trigger = function(self, event, target, player, data)
        return player:hasSkill(liangfan.name) and player.phase == Player.Start and #player:getPile("ld__mengda_letter") > 0
    end,
    on_cost = Util.TrueFunc,
    on_use = function (self, event, target, player, data)
      local room = player.room
        for _, id in ipairs(player:getPile("ld__mengda_letter")) do
          room:setCardMark(Fk:getCardById(id), "@@ld__mengda_letter-turn", 1)
        end
        room:obtainCard(player, player:getPile("ld__mengda_letter"), true)
        room:loseHp(player, 1, liangfan.name)
    end,
})

liangfan:addEffect(fk.Damage,{
    anim_type = "offensive",
    can_trigger = function(self, event, target, player, data)
          return target == player and player:hasSkill(liangfan.name) and data.card and data.card:getMark("@@ld__mengda_letter-turn") > 0
            and not data.to:isNude() and not player.dead and not data.to.dead and data.to ~= player
      end,
      on_cost = Util.TrueFunc,
      on_use = function (self, event, target, player, data)
        local room = player.room
        local card = room:askToChooseCard(player,{
            target = data.to,
            flag = "he",
            skill_name = liangfan.name,
        })
        room:obtainCard(player, card, false, fk.ReasonPrey, player.id,liangfan.name)
      end,
})

return liangfan