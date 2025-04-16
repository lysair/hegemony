local huanshi = fk.CreateSkill{
  name = "os_heg__huanshi",
}
local H = require "packages/hegemony/util"
huanshi:addEffect(fk.AskForRetrial, {
  anim_type = "control",
  events = {fk.AskForRetrial},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(huanshi.name) and not player:isNude() and
      H.compareKingdomWith(target, player)
  end,
  on_cost = function(self, event, target, player, data)
    local cards = player.room:askToCards(player, {skill_name = huanshi.name,
      min_num = 1, max_num = 1,
      pattern = ".|.|.|hand,equip|.|", prompt = "#os_heg__huanshi-ask::" .. target.id .. ":" .. data.reason,
      cancelable = true})
    if #cards > 0 then
      event:setCostData(self, {cards = cards, tos = {target} })
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:changeJudge({
      card = Fk:getCardById(event:getCostData(self).cards[1]),
      player = player,
      data = data,
      skill_name = huanshi.name,
      response = true,
    })
  end,
})

Fk:loadTranslationTable{
  ["os_heg__huanshi"] = "缓释",
  [":os_heg__huanshi"] = "当与你势力相同的角色的判定牌生效前，你可打出一张牌代替之。",

  ["#os_heg__huanshi-ask"] = "缓释：你可打出一张牌代替 %dest 的 %arg 判定",

  ["$os_heg__huanshi1"] = "缓乐之危急，释兵之困顿。",
  ["$os_heg__huanshi2"] = "尽死生之力，保友邦之安。",
}

return huanshi
