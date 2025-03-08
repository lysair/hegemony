local chengliu = fk.CreateSkill {
  name = "zq__chengliu",
}

local U = require("packages/utility/utility")

chengliu:addEffect("active", {
  anim_type = "offensive",
  prompt = "#zq__chengliu-active",
  can_use = function (self, player)
    return player:usedSkillTimes(chengliu.name, Player.HistoryPhase) == 0 and table.find(Fk:currentRoom().alive_players, function(p)
      return #p:getCardIds(Player.Equip) < #player:getCardIds(Player.Equip)
    end)
  end,
  card_num = 0,
  card_filter = Util.FalseFunc,
  target_num = 1,
  target_filter = function (self, player, to_select, selected, selected_cards)
    return #to_select:getCardIds(Player.Equip) < #player:getCardIds(Player.Equip) and #selected == 0
  end,
  on_use = function (self, room, skillUseEvent)
    local player = skillUseEvent.from
    local target = skillUseEvent.tos[1]
    room:damage{
      from = player,
      to = target,
      damage = 1,
      skillName = chengliu.name,
    }
    if player:isAlive() and target:isAlive() and
      room:askToChoice(player, { choices = { "zq__chengliu_swap::" .. target.id, "Cancel" }, skill_name = chengliu.name }) ~= "Cancel" then
        room:swapAllCards(player, {player, target}, chengliu.name, "e")
        if player:isAlive() and table.find(Fk:currentRoom().alive_players, function(p)
          return #p:getCardIds("e") < #player:getCardIds("e")
        end) then
          room:askToUseActiveSkill(player, { skill_name = chengliu.name, cancelable = true, prompt = "#zq__chengliu_repeat" })
        end
    end
  end
})

Fk:loadTranslationTable{
  ["zq__chengliu"] = "乘流",
  [":zq__chengliu"] = "出牌阶段限一次，你可以对一名装备区牌数小于你的角色造成1点伤害，然后你可以与其交换装备区的所有牌并重复此流程。",

  ["#zq__chengliu-active"] = "乘流：你可以对一名装备区牌数小于你的角色造成1点伤害，然后你可以与其交换装备区的所有牌并重复此流程。",
  ["zq__chengliu_swap"] = "与%dest交换装备区的所有牌",
  ["#zq__chengliu_repeat"] = "你可以重复发动“乘流”",
}

return chengliu
