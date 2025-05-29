local qiance = fk.CreateSkill{
    name = "ld__qiance",
}

Fk:loadTranslationTable{
    ["ld__qiance"] = "谦策",
    [":ld__qiance"] = "当与你势力相同的角色使用锦囊牌指定目标后，其可令所有大势力角色不能响应此牌。",

    ["#ld__qiance-ask"] = "谦策：是否令所有大势力角色不能响应此牌",

    ["$ld__qiance1"] = "既遇明主，天下可图！",
    ["$ld__qiance2"] = "弃武从文，安邦卫国！",
  }

local H = require "packages/hegemony/util"

qiance:addEffect(fk.CardUsing,{
    can_trigger = function (self, event, target, player, data)
      return H.compareKingdomWith(target, player) and player:hasSkill(qiance.name) and data.card:isCommonTrick()
      and (player:hasShownSkill(qiance.name) or target == player)
    end,
    on_cost = function (self, event, target, player, data)
      return player.room:askToSkillInvoke(target, {skill_name = qiance.name, prompt = "#ld__qiance-ask"})
    end,
    on_use = function (self, event, target, player, data)
        local room = player.room
        local targets = table.filter(room.alive_players, function(p) return H.isBigKingdomPlayer(p) end)
        if #targets > 0 then
          data.disresponsiveList = data.disresponsiveList or {}
          for _, p in ipairs(targets) do
          table.insertIfNeed(data.disresponsiveList, p)
        end
      end
    end,
})

return qiance