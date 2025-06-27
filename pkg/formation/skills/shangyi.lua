local shangyi = fk.CreateSkill{
  name = "shangyi",
}
local H = require "packages/hegemony/util"
shangyi:addEffect("active", {
  anim_type = "control",
  card_num = 0,
  target_num = 1,
  prompt = "shangyi",
  can_use = function(self, player)
    return player:usedSkillTimes(shangyi.name, Player.HistoryPhase) == 0 and not player:isKongcheng()
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected, selected_cards)
    return #selected == 0 and to_select ~= player
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    if player.dead or target.dead or player:isKongcheng() then return end
    room:viewCards(target, { cards = player:getCardIds("h"), skill_name = shangyi.name })
    local choices = {}
    if not H.allGeneralsRevealed(target) then
      table.insert(choices, "shangyi_hidden")
    end
    if not target:isKongcheng() then
      table.insert(choices, "shangyi_card")
    end
    if #choices == 0 then return end
    local choice = room:askToChoice(player, {
      choices = choices,
      skill_name = shangyi.name,
    })
    if choice == "shangyi_hidden" then
      local general = {target:getMark("__heg_general"), target:getMark("__heg_deputy"), target.seat}
      room:askToCustomDialog(player, {
        skill_name = shangyi.name,
        qml_path = "packages/hegemony/qml/KnownBothBox.qml",
        extra_data = general,
      })
    elseif choice == "shangyi_card" then
      local black = table.filter(target:getCardIds("h"), function(id) return Fk:getCardById(id).color == Card.Black end)
      if #black > 0 then
        local card, _ = room:askToChooseCardsAndChoice(player, {
          cards = black,
          skill_name = shangyi.name,
          prompt = "#shangyi_card:" .. target.id,
          min_num = 1,
          max_num = 1,
          all_cards = target:getCardIds("h")
        })
        room:throwCard(card, shangyi.name, target, player)
      else
        room:viewCards(player, { cards = target:getCardIds("h"), skill_name = shangyi.name })
      end
    end
  end,
})

Fk:loadTranslationTable{
  ["shangyi"] = "尚义",
  [":shangyi"] = "出牌阶段限一次，你可令一名其他角色观看你所有手牌，然后你选择一项：1.观看其所有手牌并弃置其中一张黑色牌；2.观看其所有暗置的武将牌",

  ["shangyi_hidden"] = "观看暗置的武将牌",
  ["shangyi_card"] = "观看所有手牌",

  ["#shangyi_card"] = "尚义：请观看 %src 的手牌并弃置其中一张黑色牌",

  ["$shangyi1"] = "大丈夫为人坦荡，看下手牌算什么。",
  ["$shangyi2"] = "敌情已了然于胸，即刻出发！",
}

return shangyi
