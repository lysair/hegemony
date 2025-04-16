local dujin = fk.CreateSkill{
  name = "of_heg__dujin",
}
local H = require "packages/hegemony/util"
dujin:addEffect(fk.DrawNCards, {
  anim_type = "drawcard",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(dujin.name)
  end,
  on_use = function(self, event, target, player, data)
    data.n = data.n + math.ceil(#player:getCardIds(Player.Equip) / 2)
  end,
})
dujin:addEffect(fk.GeneralRevealed, {
  can_trigger = function (self, event, target, player, data)
    if target == player and player:hasSkill(dujin.name) and player:usedSkillTimes(dujin.name, Player.HistoryGame) == 0 then -- FIXME
      for _, v in pairs(data) do
        if table.contains(Fk.generals[v]:getSkillNameList(), dujin.name) then return true end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if player and H.getKingdomPlayersNum(room,true)[H.getKingdom(player)] == 1 then
      H.addHegMark(room, player, "vanguard")
    end
  end,
})

Fk:loadTranslationTable{
  ["of_heg__dujin"] = "独进",
  [":of_heg__dujin"] = "①摸牌阶段，你可以多摸X张牌（X为你装备区牌数的一半，"..
    "向上取整）。②当你首次明置此武将牌后，若没有与你势力相同的{其他角色或已死亡的角色}，你获得1枚“先驱”标记。",
  ["#of_heg__reveral"] = "独进",
  ["$of_heg__dujin1"] = "带兵十万，不如老夫多甲一件！",
  ["$of_heg__dujin2"] = "轻舟独进，破敌先锋！",
}

return dujin
