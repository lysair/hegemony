local hegRule = fk.CreateSkill{
  name = "heg_rule",
}

local H = require "packages/hegemony/util"

local wildKingdoms = {"heg_qin", "heg_qi", "heg_chu", "heg_yan", "heg_zhao", "heg_hanr", "heg_jin", "heg_han", "heg_xia", "heg_shang", "heg_zhou", "heg_liang"} -- hanr 韩
local kingdomMapper = { ["ld__zhonghui"] = "heg_han", ["ld__simazhao"] = "heg_jin", ["ld__gongsunyuan"] = "heg_yan", ["ld__sunchen"] = "heg_chu" }

--- 野心家选择国家
---@param room Room
---@param player ServerPlayer
---@param generalName string
local function wildChooseKingdom(room, player, generalName)
  local allKingdoms = room:getBanner("all_kingdoms")
  table.insertTable(allKingdoms, {"unknown", "hidden"})

  local choice
  local all_choices = table.clone(wildKingdoms)
  local choices = table.clone(all_choices)
  for _, p in ipairs(room.players) do
    table.removeOne(choices, p.role)
  end
  if player.general == generalName and kingdomMapper[generalName] and kingdomMapper[generalName] ~= player.role then -- 野心家钦定
    if table.contains(choices, kingdomMapper[generalName]) then
      choice = kingdomMapper[generalName]
    else
      choice = room:askToChoice(player, {choices = choices, skill_name = "heg_rule", prompt = "#wild-choose", cancelable = false, all_choices = all_choices})
    end
  elseif table.contains(allKingdoms, player.role) then
    choice = room:askToChoice(player, {choices = choices, skill_name = "heg_rule", prompt = "#wild-choose", cancelable = false, all_choices = all_choices})
  end
  if choice then
    player.role = choice
    room:setPlayerProperty(player, "role_shown", true)
    room:broadcastProperty(player, "role")
    room:sendLog{
      type = "#WildChooseKingdom",
      from = player.id,
      arg = choice,
      arg2 = "wild",
    }
  end
end

--- 询问加入建国
---@param room Room
---@param player ServerPlayer
---@param generalName string
---@param isActive boolean
---@return boolean
local function AskForBuildCountry(room, player, generalName, isActive)
  if not (player.general == generalName and kingdomMapper[generalName]) then return false end
  local choices = {"heg_rule_join_country:"..player.id.."::"..player.role, "Cancel"}
  for _, p in ipairs(room:getAlivePlayers()) do
    if p:getMark("__heg_join_wild") == 0 and p.kingdom ~= "wild" and not string.find(p.general, "lord")
      and (not isActive or p.general ~= "anjiang") then
      local choice = room:askToChoice(p, {choices = choices, skill_name = "heg_rule", prompt = "#wild_join-choose"})
      if choice ~= "Cancel" then
        p.role = player.role
        room:setPlayerProperty(p, "role_shown", true)
        room:broadcastProperty(p, "role")
        room:sendLog{
          type = "#WildChooseKingdom",
          from = p.id,
          arg = player.role,
          arg2 = "wild",
        }
        room:setPlayerProperty(p, "kingdom", "wild")
        room:setPlayerMark(p, "__heg_join_wild", 1)
        room:setPlayerMark(player, "__heg_construct_wild", 1)
        room:sendLog{
          type = "#SuccessBuildCountry",
          from = player.id,
          arg = player.role,
          arg2 = p.general
        }
        if p:isWounded() then
          room:recover({
            who = p,
            num = 1,
            recoverBy = player,
            skillName = "heg_rule",
          })
        end
        if p:getHandcardNum() < 4 then
          p:drawCards(4 - p:getHandcardNum(), "heg_rule")
        end
        return true
      end
    end
  end
  return false
end

local can_trigger = function(self, event, target, player, data)
  return target == player
end

hegRule:addEffect(fk.BeforeTurnStart, {
  priority = 0,
  can_trigger = can_trigger,
  on_trigger = function(self, event, target, player, data)
    local room = player.room
    -- 鏖战
    if #room.alive_players < (#room.players > 6 and 5 or 4) and not room:getTag("BattleRoyalMode") then
      local ret = true
      for _, v in pairs(H.getKingdomPlayersNum(room)) do
        if v and v > 1 then
          ret = false
          break
        end
      end
      if ret then
        room:doBroadcastNotify("ShowToast", Fk:translate("#EnterBattleRoyalMode"))
        room:sendLog{
          type = "#EnterBattleRoyalModeLog",
        }
        room:setTag("BattleRoyalMode", true)
        room:setBanner("@[:]BattleRoyalDummy", "BattleRoyalMode")
        for _, p in ipairs(room.alive_players) do
          -- p:addFakeSkill("battle_royal&")
          -- p:addFakeSkill("battle_royal_prohibit&")
          room:handleAddLoseSkills(p, "battle_royal&", nil, false, true)
        end
      end
    end
  end,
})

hegRule:addEffect(fk.TurnStart, {
  priority = 0,
  can_trigger = can_trigger,
  on_trigger = function(self, event, target, player, data)
    H.askForRevealGenerals(player.room, player, self.name, true, true, true, true, true) -- lord
  end
})
hegRule:addEffect(fk.GameOverJudge, {
  priority = 0,
  can_trigger = can_trigger,
  on_trigger = function(self, event, target, player, data)
    local room = player.room
    player:revealGeneral(false)
    player:revealGeneral(true)
    if player.kingdom == "wild" then
      wildChooseKingdom(room, player, player.general)
    end
    local winner = Fk.game_modes[room.settings.gameMode]:getWinner(player)
    if winner ~= "" then
      for _, ps in ipairs(room.alive_players) do
        -- 先检测并询问主将是不是野人
        if ps.general == "anjiang" then 
          -- 是野人则强制亮出来
          if ps:getMark("__heg_wild") == 1 then
            room:setPlayerMark(ps, "_wild_final_end", 1)
            ps:revealGeneral(false)
          end
        end
      end
      -- 强制亮完野人后检测场上有没有野人
      if table.find(room.alive_players, function(p) return p:getMark("__heg_wild") == 1 end) then
        --有野人则依次询问拉拢
        for _, p in ipairs(room.alive_players) do
          if p:getMark("__heg_wild") == 1 then
            wildChooseKingdom(room, p, p.general)
            AskForBuildCountry(room, p, p.general, false)
            room:setPlayerMark(p, "_wild_gained", 1)
          end
        end
      end
      -- 然后判断场上所有人势力是否相同
      local _kingdom2 = {}
      for _, p in ipairs(room.alive_players) do
        if not table.contains(_kingdom2, p.kingdom) then
          table.insert(_kingdom2, p.kingdom)
        end
      end
      if #_kingdom2 == 1 then
        -- 若所有人势力相同则全部亮将
        for _, p in ipairs(room.alive_players) do
          if p.general == "anjiang" then p:revealGeneral(false) end
          if p.deputyGeneral == "anjiang" then p:revealGeneral(true) end
        end
        room:gameOver(winner)
        return true
      end
    end
    room:setTag("SkipGameRule", true)
  end
})
hegRule:addEffect(fk.Deathed, {
  priority = 0,
  can_trigger = can_trigger,
  on_trigger = function(self, event, target, player, data)
    local room = player.room
    local killer = data.killer
    if killer then
      if killer.kingdom ~= "unknown" and not killer.dead then
        -- 因为建国，修改奖惩；如果还没建国
        if killer.kingdom == "wild" and killer:getMark("__heg_construct_wild") == 0 and killer:getMark("__heg_join_wild") == 0 then
          killer:drawCards(3, "kill")
        elseif H.compareKingdomWith(killer, player) then
          if not (room.logic:getCurrentEvent():findParent(GameEvent.Death, true).data[1].extra_data or {}).ignorePunishment then
            killer:throwAllCards("he")
          end
        else
          killer:drawCards(H.getSameKingdomPlayersNum(room, player) + 1, "kill")
        end
      end
    end
    if string.find(player.general, "lord") then
      local players = (table.filter(room.players, function(p) return
        (p:getMark("__heg_kingdom") == player.kingdom or (p.dead and p.kingdom == player.kingdom)) and p ~= player and p.kingdom ~= "wild"
      end))
      room:sortByAction(players)
      for _, p in ipairs(players) do
        local oldKingdom = p.kingdom
        room:setPlayerMark(p, "__heg_kingdom", "wild")
        if oldKingdom ~= "unknown" then
          room:setPlayerProperty(p, "kingdom", "wild")
          if not p.dead then wildChooseKingdom(room, p, p.general) end
        end
      end
    end
  end
})
hegRule:addEffect(fk.GeneralRevealed, {
  priority = 0,
  can_trigger = can_trigger,
  on_trigger = function(self, event, target, player, data)
    local room = player.room
    for _, general_name in pairs(data) do
      if room:getTag("TheFirstToShowRewarded") == player.id and player:getMark("_vanguard_gained") == 0 then
        room:setPlayerMark(player, "_vanguard_gained", 1)
        H.addHegMark(room, player, "vanguard")
      end
      if player:getMark("hasShownMainGeneral") == 1 and Fk.generals[general_name].kingdom == "wild" and player:getMark("_wild_gained") == 0 then
        room:setPlayerMark(player, "_wild_gained", 1)
        H.addHegMark(room, player, "wild")
      end
      if player.general == "anjiang" or player.deputyGeneral == "anjiang" then return false end
      if player:getMark("HalfMaxHpLeft") > 0 then
        room:setPlayerMark(player, "HalfMaxHpLeft", 0)
        H.addHegMark(room, player, "yinyangfish")
      end
      if player:getMark("CompanionEffect") > 0 then
        room:setPlayerMark(player, "CompanionEffect", 0)
        H.addHegMark(room, player, "companion")
      end
    end
  end
})
hegRule:addEffect(fk.EventPhaseStart, {
  priority = 0,
  can_trigger = function(self, event, target, player, data)
    return target == player and data.phase == Player.Play
  end,
  on_trigger = function(self, event, target, player, data)
    player:addFakeSkill("alliance&")
  end
})
hegRule:addEffect(fk.EventPhaseEnd, {
  priority = 0,
  can_trigger = function(self, event, target, player, data)
    return target == player and data.phase == Player.Play
  end,
  on_trigger = function(self, event, target, player, data)
    player:loseFakeSkill("alliance&")
  end
})
hegRule:addEffect(fk.GeneralShown, {
  priority = 0,
  can_trigger = can_trigger,
  on_trigger = function(self, event, target, player, data)
    local room = player.room
    if not room:getTag("TheFirstToShowRewarded") then
      room:setTag("TheFirstToShowRewarded", player.id)
    end
    local general_name = data["m"] or data["d"]
    -- 君主拉回野人
    if general_name and string.find(general_name, "lord") then
      local kingdom = player:getMark("__heg_kingdom")
      for _, p in ipairs(room.players) do
        if p:getMark("__heg_kingdom") == kingdom and p.kingdom == "wild" and p:getMark("__heg_wild") == 0 then
          room:setPlayerProperty(p, "kingdom", kingdom)
          room:setPlayerProperty(p, "role_shown", false)
          room:setPlayerProperty(p, "role", kingdom)
        end
      end
    end
    if player.kingdom == "wild" and not player.dead and player:getMark("_wild_gained") == 0 then
      wildChooseKingdom(room, player, general_name)
      -- 野人亮出来的时候询问拉拢
      local choices = {"Cancel"}
      if player:getMark("__heg_wild") == 1 and player:getMark("_wild_final_end") == 0 then
        table.insert(choices, "heg_build_country:::" .. player.role)
      end
      -- if room:askForChoice(player, choices, "heg_rule") ~= "Cancel" then
      --   AskForBuildCountry(room, player, general_name, true)
      --   room:setPlayerMark(player, "_wild_gained", 1)
      -- end
    elseif player:getMark("__heg_join_wild") == 0 and player:getMark("__heg_construct_wild") == 0 then
      if player:getMark("__heg_wild") == 1 then
        player.role = player.kingdom
      else
        room:setPlayerProperty(player, "role", player.kingdom)
      end
    end

    for _, v in pairs(H.getKingdomPlayersNum(room)) do
      if v == #room.alive_players then
        local winner = Fk.game_modes[room.settings.gameMode]:getWinner(player)
        for _, p in ipairs(room.alive_players) do
          -- 先检测并询问主将是不是野人
          if p.general == "anjiang" then 
            -- 是野人则强制亮出来
            if p:getMark("__heg_wild") == 1 then
              room:setPlayerMark(p, "_wild_final_end", 1)
              p:revealGeneral(false)
            end
          end
        end
        -- 强制亮完野人后检测场上有没有野人
        if table.find(room.alive_players, function(p) return p:getMark("__heg_wild") == 1 end) then
          --有野人则依次询问拉拢
          for _, p in ipairs(room.alive_players) do
            if p:getMark("__heg_wild") == 1 then
              wildChooseKingdom(room, p, p.general)
              AskForBuildCountry(room, p, p.general, false)
              room:setPlayerMark(p, "_wild_gained", 1)
            end
          end
        end
        -- 然后判断场上所有人势力是否相同
        if table.every(room.alive_players, function(p) return H.compareKingdomWith(p, player) end) then
          -- 若所有人势力相同则全部亮将
          for _, p in ipairs(room.alive_players) do
            if p.general == "anjiang" then p:revealGeneral(false) end
            if p.deputyGeneral == "anjiang" then p:revealGeneral(true) end
          end
          room:gameOver(winner)
          return true
        end
      else
        break
      end
    end
    if player:getMark("hasShownMainGeneral") == 0 and data["m"] then -- 首次亮主将
      room:setPlayerMark(player, "hasShownMainGeneral", 1)
    end
  end
})
hegRule:addEffect(fk.GameStart, {
  priority = 0,
  can_trigger = can_trigger,
  on_trigger = function(self, event, target, player, data)
    local room = player.room
    for _, p in ipairs(room.players) do
      p:setMark("@seat", 0)
      p:doNotify("SetPlayerMark", json.encode{ p.id, "@seat", 0})
    end
    if room.settings.gameMode == "nos_heg_mode" then -- 藕一下算了
      for _, p in ipairs(room.alive_players) do
        if p:isAlive() then p:revealGeneral(false) end
      end
      for _, p in ipairs(room.alive_players) do
        if p:isAlive() then p:revealGeneral(true) end
      end
    end
  end
})

return hegRule
