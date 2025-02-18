local allianceFeastSkill = fk.CreateSkill{
  name = "alliance_feast_skill",
}

local H = require "packages/hegemony/util"

allianceFeastSkill:addEffect('active', {
  prompt = "#alliance_feast_skill",
  target_num = 1,
  mod_target_filter = function(self, player, to_select, selected, card, distance_limited)
    if to_select == player then return true end
    if to_select.kingdom == "unknown" then return false end
    if #selected == 0 then
      return H.compareKingdomWith(to_select, player, true)
    end
    local target = selected[1]
    return H.compareKingdomWith(to_select, target)
  end,
  target_filter = function(self, player, to_select, selected, _, card, extra_data)
    return #selected == 0 and to_select ~= player and Util.TargetFilter(self, to_select.id, selected, _, card, extra_data, player)
  end,
  can_use = function(self, player, card)
    return not (player:prohibitUse(card) or player:isProhibited(player, card)) and player.kingdom ~= "unknown"
  end,
  on_use = function(self, room, use)
    local card = use.card
    local player = use.from
    local kingdom
    if use.tos and #use.tos > 0 then
      if not player:isProhibited(player, card) then
        use:addTarget(use.from)
      end
      for _, _p in ipairs(use.tos) do
        if _p ~= use.from then
          kingdom = H.getKingdom(_p)
          for _, p in ipairs(room:getAlivePlayers()) do
            if H.compareKingdomWith(p, _p) and p ~= _p and player:canUseTo(use.card, p) then
              use:addTarget(p)
            end
          end
          break
        end
      end
    elseif not player:isProhibited(player, card) then
      use.tos = { use.from }
    end
    use.extra_data = use.extra_data or {}
    use.extra_data.AFTargetKingdom = kingdom
  end,
  on_effect = function(self, room, cardEffectEvent)
    local from = cardEffectEvent.from
    local to = cardEffectEvent.to
    if from == to then
      local num = H.getSameKingdomPlayersNum(room, nil, (cardEffectEvent.extra_data or {}).AFTargetKingdom)
      local choices = {}
      for i = 0, math.min(num, from:getLostHp()) do
        table.insert(choices, "#AFrecover:::" .. i .. ":" .. num - i)
      end
      local number = table.indexOf(choices, room:askToChoice(from, {choices = choices, skill_name = "alliance_feast_skill"})) - 1
      if number > 0 then
        room:recover{
          who = from,
          recoverBy = from,
          card = cardEffectEvent.card,
          num = number,
          skillName = "alliance_feast_skill"
        }
      end
      from:drawCards(num - number, "alliance_feast")
    else
      to:drawCards(1, "alliance_feast")
      if to.chained then to:setChainState(false) end
    end
  end,
})

allianceFeastSkill:addTest(function(room, me)
  local card = Fk:cloneCard("alliance_feast")
  local to = table.find(room:getOtherPlayers(me, false), function(p)
    return H.compareKingdomWith(me, p, true)
  end)
  if to then
    FkTest.runInRoom(function()
      room:loseHp(me, 3)
      local num = H.getSameKingdomPlayersNum(room, to)
      to:setChainState(true)
      FkTest.setNextReplies(me, { "#AFrecover:::" .. 1 .. ":" .. num - 1 })
      room:useCard{
        from = me,
        card = card,
        tos = {to},
      }
    end)
    lu.assertEquals(me.hp, 2)
    lu.assertEquals(me:getHandcardNum(), 1)
    lu.assertEquals(to:getHandcardNum(), 1)
    lu.assertEquals(to.chained, false)
  end
end)

Fk:loadTranslationTable{
  ["alliance_feast"] = "联军盛宴",
  [":alliance_feast"] = "锦囊牌<br/><b>时机</b>：出牌阶段<br/><b>目标</b>：有势力的你和除你的势力外的一个势力的所有角色<br/><b>效果</b>：若目标角色：为你，你摸X张牌，回复（Y-X）点体力（Y为该势力的角色数）（X为你选择的自然数且不大于Y）；不为你，其摸一张牌，重置。<br/><font color='grey'>操作提示：选择一名与你势力不同的角色，目标为你和该势力的所有角色</font>",
  ["alliance_feast_skill"] = "联军盛宴",
  ["#AFrecover"] = "回复%arg点体力，摸%arg2张牌",
  ["#alliance_feast_skill"] = "选择除你的势力外的一个势力的所有角色，<br/>你选择X（不大于Y），摸X张牌，回复Y-X点体力（Y为该势力的角色数）；<br/>这些角色各摸一张牌，重置",
}

return allianceFeastSkill
