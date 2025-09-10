local lingren = fk.CreateSkill{
    name = "tyta__lingren",
}

Fk:loadTranslationTable{
    ["tyta__lingren"] = "凌人",
    [":tyta__lingren"] = "每回合限一次，当你使用伤害类牌指定一个目标后，若其手牌数不大于你，你可以选择一项：1.摸两张牌；2.今此牌对其造成的伤害+1。",

    ["tyta__lingren_drawcards"] = "摸两张牌",
    ["tata__lingren_damage"] = "今此牌对%src造成的伤害+1",

    ["$tyta__lingren1"] = "敌势已缓，休要走了老贼！",
    ["$tyta__lingren2"] = "精兵如炬，困龙难飞！",
}

lingren:addEffect(fk.TargetSpecified,{
    anim_type = "offensive",
    can_trigger = function (self, event, target, player, data)
        return target == player and player:hasSkill(lingren.name) and data.to and (data.to:getHandcardNum() <= player:getHandcardNum())
        and player:usedSkillTimes(lingren.name, Player.HistoryTurn) == 0 and data.card and data.card.is_damage_card
    end,
    on_use = function (self, event, target, player, data)
        local room = player.room
        local choice = room:askToChoice(player, {choices = {"tyta__lingren_drawcards","tata__lingren_damage:"..data.to.id}, skill_name = lingren.name})
        if choice == "tyta__lingren_drawcards" then
            player:drawCards(2, lingren.name)
        else
            data.extra_data = data.extra_data or {}
            data.extra_data.lingren = data.extra_data.lingren or {}
            table.insert(data.extra_data.lingren, data.to.id)
        end
    end,
})

lingren:addEffect(fk.DamageInflicted, {
  mute = true,
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    if player.dead or data.card == nil or target ~= player then return false end
    local room = player.room
    local use_event = room.logic:getCurrentEvent():findParent(GameEvent.UseCard)
    if not use_event then return false end
    local use = use_event.data
    return use.extra_data and use.extra_data.lingren and table.contains(use.extra_data.lingren, player.id)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data:changeDamage(1)
  end,
})

return lingren
