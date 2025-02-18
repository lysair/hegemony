local knownBothSkill = fk.CreateSkill{
  name = "known_both_skill",
}

local U = require "packages/utility/utility"

knownBothSkill:addEffect("active", {
  prompt = "#known_both_skill",
  can_use = Util.CanUse,
  target_num = 1,
  mod_target_filter = function(self, player, to_select, selected)
    return player ~= to_select and (not to_select:isKongcheng() or to_select.general == "anjiang" or to_select.deputyGeneral == "anjiang")
  end,
  target_filter = Util.CardTargetFilter,
  on_effect = function(self, room, effect)
    local player = effect.from
    local target = effect.to
    if target.dead or player.dead then return end
    local all_choices = {"known_both_main", "known_both_deputy", "known_both_hand"}
    local choices = table.clone(all_choices)
    if target:isKongcheng() then
      table.remove(choices)
    end
    if target.general ~= "anjiang" then
      table.remove(choices, 1)
    end
    if target.deputyGeneral ~= "anjiang" then
      table.removeOne(choices, "known_both_deputy")
    end
    if #choices == 0 then return end
    local choice = room:askForChoice(player, choices, knownBothSkill.name, "#known_both-choice::"..target.id, false, all_choices)
    if choice == "known_both_hand" then
      U.viewCards(player, target:getCardIds(Player.Hand), knownBothSkill.name, "#known_both-hand::"..target.id)
      room:sendLog{
        type = "#know_hand",
        from = player.id,
        toast = true,
      }
    else
      local general = choice == "known_both_main" and {target:getMark("__heg_general"), target.deputyGeneral, tostring(target.seat)} or {target.general, target:getMark("__heg_deputy"), tostring(target.seat)}
      room:askForCustomDialog(player, knownBothSkill.name, "packages/hegemony/qml/KnownBothBox.qml", general)
      room:sendLog{
        type = "#know_general",
        from = player.id,
        toast = true,
      }
    end
  end,
})

Fk:loadTranslationTable{
  ["known_both"] = "知己知彼",
  ["known_both_skill"] = "知己知彼",
  [":known_both"] = "锦囊牌<br/><b>时机</b>：出牌阶段<br/><b>目标</b>：一名其他角色<br/><b>效果</b>：观看目标角色一张暗置的武将牌或其手牌。",
  ["#known_both-choice"] = "知己知彼：选择对 %dest 执行的一项",
  ["known_both_main"] = "观看主将",
  ["known_both_deputy"] = "观看副将",
  ["known_both_hand"] = "观看手牌",
  ["#KnownBothGeneral"] = "观看 %1 武将",
  ["#known_both-hand"] = "知己知彼：观看%dest的手牌",
  ["#known_both_skill"] = "选择一名其他角色，观看其一张暗置的武将牌或其手牌",
  ["#know_hand"] = "%from 观看了手牌",
  ["#know_general"] = "%from 观看了武将",
}

return knownBothSkill
