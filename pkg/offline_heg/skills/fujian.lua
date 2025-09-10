local fujian = fk.CreateSkill {
    name = "tyta__fujian",
}

Fk:loadTranslationTable {
    ["tyta__fujian"] = "伏间",
    [":tyta__fujian"] = "准备阶段和结束阶段，你可以视为对一名手牌数不大于你的其他角色使用一张【知己知彼】。",
    ["#tyta__fujian_choose"] = "伏间：选择一名手牌数不大于你的其他角色，视为对其使用一张【知己知彼】",

    ["$tyta__fujian1"] = "兵者，诡道也。",
    ["$tyta__fujian2"] = "粮资军备，一览无遗。",
}

fujian:addEffect(fk.EventPhaseStart, {
    anim_type = "special",
    can_trigger = function(self, event, target, player, data)
        return target == player and player:hasSkill(fujian.name) and player.phase == Player.Start and
            not player:prohibitUse(Fk:cloneCard("known_both"))
            and
            table.find(player.room.alive_players,
                function(p) return p ~= player and #p:getCardIds("h") <= #player:getCardIds("h") end)
    end,
    on_cost = function(self, event, target, player, data)
        local room = player.room
        local targets = table.filter(room.alive_players,
            function(p) return p ~= player and #p:getCardIds("h") <= #player:getCardIds("h") end)
        if #targets > 0 then
            local to = room:askToChoosePlayers(player, {
                targets = targets,
                min_num = 1,
                max_num = 1,
                prompt = "#tyta__fujian_choose",
                skill_name = fujian.name,
            })
            if #to > 0 then
                event:setCostData(self, { to = to })
                return true
            end
        end
    end,
    on_use = function(self, event, target, player, data)
        local room = player.room
        local to = event:getCostData(self).to[1]
        if player.dead or to.dead then return end
        room:useVirtualCard("known_both", nil, player, to, fujian.name, true)
    end,
})

fujian:addEffect(fk.EventPhaseStart, {
    anim_type = "special",
    can_trigger = function(self, event, target, player, data)
        return target == player and player:hasSkill(fujian.name) and player.phase == Player.Finish and
            not player:prohibitUse(Fk:cloneCard("known_both"))
            and
            table.find(player.room.alive_players,
                function(p) return p ~= player and #p:getCardIds("h") <= #player:getCardIds("h") end)
    end,
    on_cost = function(self, event, target, player, data)
        local room = player.room
        local targets = table.filter(room.alive_players,
            function(p) return p ~= player and #p:getCardIds("h") <= #player:getCardIds("h") end)
        if #targets > 0 then
            local to = room:askToChoosePlayers(player, {
                targets = targets,
                min_num = 1,
                max_num = 1,
                prompt = "#tyta__fujian_choose",
                skill_name = fujian.name,
            })
            if #to > 0 then
                event:setCostData(self, { to = to })
                return true
            end
        end
    end,
    on_use = function(self, event, target, player, data)
        local room = player.room
        local to = event:getCostData(self).to[1]
        if player.dead or to.dead then return end
        room:useVirtualCard("known_both", nil, player, to, fujian.name, true)
    end,
})

return fujian

