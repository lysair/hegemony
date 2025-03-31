
local daoshu = fk.CreateSkill{
  name = "ty_heg__daoshu",
}
daoshu:addEffect("active", {
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(daoshu.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected)
    return #selected == 0 and to_select ~= player and not to_select:isKongcheng()
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    local suits = {"log_spade", "log_club", "log_heart", "log_diamond"}
    local choice = room:askForChoice(player, suits, daoshu.name)
    room:sendLog{
      type = "#ty_heg__daoshuLog",
      from = player.id,
      to = effect.tos,
      arg = choice,
      arg2 = daoshu.name,
      toast = true,
    }
    local card = room:askForCardChosen(player, target, "h", daoshu.name)
    room:obtainCard(player, card, true, fk.ReasonPrey)
    if Fk:getCardById(card):getSuitString(true) == choice then
      room:damage{
        from = player,
        to = target,
        damage = 1,
        skillName = daoshu.name,
      }
      player:addSkillUseHistory(daoshu.name, -1)
    else
      local suit = Fk:getCardById(card):getSuitString(true)
      table.removeOne(suits, suit)
      suits = table.map(suits, function(s) return s:sub(5) end)
      local others = table.filter(player:getCardIds(Player.Hand), function(id) return Fk:getCardById(id):getSuitString(true) ~= suit end)
      if #others > 0 then
        local cards = room:askForCard(player, 1, 1, false, daoshu.name, false, ".|.|"..table.concat(suits, ","),
          "#ty_heg__daoshu-give::"..target.id..":"..suit)
        room:obtainCard(target, cards, true, fk.ReasonGive)
      else
        player:showCards(player:getCardIds(Player.Hand))
      end
    end
  end,
})

Fk:loadTranslationTable{
  ["ty_heg__daoshu"] = "盗书",
  [":ty_heg__daoshu"] = "出牌阶段限一次，你可以选择一名其他角色并选择一种花色，然后获得其一张手牌。若此牌与你选择的花色："..
  "相同，你对其造成1点伤害且此技能视为未发动过；不同，你交给其一张其他花色的手牌（若没有需展示所有手牌）。",
  ["#ty_heg__daoshuLog"] = "%from 对 %to 发动了 “%arg2”，选择了 %arg",
  ["#ty_heg__daoshu-give"] = "盗书：交给 %dest 一张非%arg手牌",

  ["$ty_heg__daoshu1"] = "得此文书，丞相定可高枕无忧。",
  ["$ty_heg__daoshu2"] = "让我看看，这是什么机密。",
}

return daoshu
