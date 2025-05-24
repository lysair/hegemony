local zhiman = fk.CreateSkill{
  name = "ld__zhiman",
}
local H = require "packages/hegemony/util"
zhiman:addEffect(fk.DamageCaused, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(zhiman.name) and data.to ~= player
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = zhiman.name,
      prompt = "#ld__zhiman-invoke::"..data.to.id,
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    data:preventDamage()
    local target = data.to
    if #target:getCardIds("ej") > 0 then -- 开摆！
      local card = room:askToChooseCard(player, {
        target = target,
        flag = "ej",
        skill_name = zhiman.name,
      })
      room:obtainCard(player.id, card, true, fk.ReasonPrey)
    end
    if H.compareKingdomWith(target, player) and player:getMark("@@ld__zhiman_transform") == 0
      and room:askForChoice(player, {"ld__zhiman_transform::" .. target.id, "Cancel"}, zhiman.name) ~= "Cancel"
      and room:askForChoice(target, {"transformDeputy", "Cancel"}, zhiman.name) ~= "Cancel" then
        room:setPlayerMark(player, "@@ld__zhiman_transform", 1)
        H.transformGeneral(room, target)
    end
  end
})

Fk:loadTranslationTable{
  ["ld__zhiman"] = "制蛮",
  [":ld__zhiman"] = "当你对其他角色造成伤害时，你可防止此伤害，你获得其装备区或判定区里的一张牌。若其与你势力相同，你可令其选择是否变更。",

  ["#ld__zhiman-invoke"] = "制蛮：你可以防止对 %dest 造成的伤害，获得其场上的一张牌。若其与你势力相同，你可令其选择是否变更副将",
  ["ld__zhiman_transform"] = "令%dest选择是否变更副将",
  ["@@ld__zhiman_transform"] = "制蛮 已变更",

  ["$ld__zhiman1"] = "兵法谙熟于心，取胜千里之外！",
  ["$ld__zhiman2"] = "丞相多虑，且看我的！",
}
return zhiman
