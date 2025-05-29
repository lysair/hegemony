local xuanhuo = fk.CreateSkill{
    name = "ld__xuanhuo",
    attached_skill_name = "ld__xuanhuo_other&",
}

local H = require "packages/hegemony/util"

local xuanhuo_spec = {
    can_refresh = function(self, event, target, player, data)
        return target == player
      end,
    on_refresh = function(self, event, target, player, data)
        local room = player.room
        local players = room.alive_players
        local fazhengs = table.filter(players, function(p) return p:hasShownSkill(xuanhuo.name) end)
        local xuanhuo_map = {}
        for _, p in ipairs(players) do
          local will_attach = false
          for _, fazheng in ipairs(fazhengs) do
            if (fazheng ~= p and H.compareKingdomWith(fazheng, p)) then
              will_attach = true
              break
            end
          end
          xuanhuo_map[p] = will_attach
        end
        for p, v in pairs(xuanhuo_map) do
          if v ~= p:hasSkill("ld__xuanhuo_other&") then
            room:handleAddLoseSkills(p, v and xuanhuo.attached_skill_name or "-" .. xuanhuo.attached_skill_name, nil, false, true)
          end
        end
      end,
      on_acquire = function(self, player)
        local room = player.room
        for _, p in ipairs(room.alive_players) do
          if p ~= player and H.compareKingdomWith(player, p) then
            room:handleAddLoseSkills(p, xuanhuo.attached_skill_name, nil, false, true)
          end
        end
      end,
      on_lose = function (self, player, is_death)
        local room = player.room
        for _, p in ipairs(room.alive_players) do
          if p ~= player and H.compareKingdomWith(player, p) then
            room:handleAddLoseSkills(p, "-" .. xuanhuo.attached_skill_name, nil, false, true)
          end
        end
      end,
}

xuanhuo:addEffect(fk.AfterPropertyChange,{
    can_refresh = xuanhuo_spec.can_refresh,
    on_refresh = xuanhuo_spec.on_refresh,
    on_acquire = xuanhuo_spec.on_acquire,
    on_lose = xuanhuo_spec.on_lose,
})

xuanhuo:addEffect(fk.GeneralRevealed,{
    can_refresh = xuanhuo_spec.can_refresh,
    on_refresh = xuanhuo_spec.on_refresh,
    on_acquire = xuanhuo_spec.on_acquire,
    on_lose = xuanhuo_spec.on_lose,

})

xuanhuo:addEffect(fk.GeneralHidden,{
    can_refresh = xuanhuo_spec.can_refresh,
    on_refresh = xuanhuo_spec.on_refresh,
    on_acquire = xuanhuo_spec.on_acquire,
    on_lose = xuanhuo_spec.on_lose,

})

xuanhuo:addEffect(fk.Deathed,{
    can_refresh = xuanhuo_spec.can_refresh,
    on_refresh = xuanhuo_spec.on_refresh,
    on_acquire = xuanhuo_spec.on_acquire,
    on_lose = xuanhuo_spec.on_lose,

})

Fk:loadTranslationTable{
    ["ld__xuanhuo"] = "眩惑",
    [":ld__xuanhuo"] = "与你势力相同的其他角色的出牌阶段限一次，其可交给你一张手牌，然后其弃置一张牌，选择下列技能中的一个：〖武圣〗〖咆哮〗〖龙胆〗〖铁骑〗〖烈弓〗〖狂骨〗（场上已有的技能无法选择）。其于此回合内或明置有其以此法选择的技能的武将牌之前拥有其以此法选择的技能。",

    ["$ld__xuanhuo1"] = "给你的，十倍奉还给我！",
    ["$ld__xuanhuo2"] = "重用许靖，以眩远近。",
}

return xuanhuo