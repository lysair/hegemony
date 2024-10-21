local heg_description = [==[
本模式仅为 **国战模式** 的 **开局全亮** 版本，请参考 **国战模式** 的说明
]==]

local H = require "packages/hegemony/util"

local heg

---@class HegLogic: GameLogic
local HegLogic = {}

function HegLogic:assignRoles()
  local room = self.room
  for _, p in ipairs(room.players) do
    p.role_shown = false
    p.role = "hidden"
    room:broadcastProperty(p, "role")
  end

  -- for adjustSeats
  room.players[1].role = "lord"
end

function HegLogic:prepareDrawPile()
  local room = self.room
  local allCardIds = Fk:getAllCardIds()

  for i = #allCardIds, 1, -1 do
    local card = Fk:getCardById(allCardIds[i])
    if card.is_derived or (H.convertCards[card.name] and table.find(H.convertCards[card.name], function(c)
        return table.contains(allCardIds, c.id)
      end)) then
      local id = allCardIds[i]
      table.removeOne(allCardIds, id)
      table.insert(room.void, id)
      room:setCardArea(id, Card.Void, nil)
    end
    if table.contains(H.allianceCards, card) then
      room:setCardMark(card, "@@alliance", 1)
    end
  end

  table.shuffle(allCardIds)
  room.draw_pile = allCardIds
  for _, id in ipairs(room.draw_pile) do
    room:setCardArea(id, Card.DrawPile, nil)
  end
end

function HegLogic:chooseGenerals()
  local room = self.room
  local generalNum = math.max(room.settings.generalNum, 5)
  room:doBroadcastNotify("ShowToast", Fk:translate("#HegInitialNotice"))

  local lord = room:getLord()
  room.current = lord
  lord.role = "hidden"

  local players = room.players
  local generals = room:getNGenerals(#players * generalNum) -- Fk:getGeneralsRandomly
  table.shuffle(generals)
  for k, p in ipairs(players) do
    -- local arg = { map = table.map }
    local arg = table.slice(generals, (k - 1) * generalNum + 1, k * generalNum + 1)
    table.sort(arg, function(a, b) return Fk.generals[a].kingdom > Fk.generals[b].kingdom end)

    for idx, _ in ipairs(arg) do
      local g = Fk.generals[arg[idx]]
      local g2 = Fk.generals[arg[idx + 1]]
      if (g.kingdom == g2.kingdom and g.kingdom ~= "wild") or (g.kingdom == "wild" and g2.kingdom ~= "wild") or
        (g.subkingdom ~= nil and g.subkingdom == g2.subkingdom) or g.kingdom == g2.subkingdom or g.subkingdom == g2.kingdom then
          p.default_reply = arg[idx] .. "+" .. arg[idx + 1]
          break
      end
    end

    p.request_data = json.encode{ arg, 2, false, true }
  end

  room:notifyMoveFocus(players, "AskForGeneral")
  room:doBroadcastRequest("AskForGeneral", players)

  local selected = {}
  for _, p in ipairs(players) do
    local general, deputy
    if p.general == "" and p.reply_ready then
      local general_ret = json.decode(p.client_reply)
      general = general_ret[1]
      deputy = general_ret[2]
      room:setPlayerGeneral(p, general, true)
      room:setDeputyGeneral(p, deputy)
    else
      local general_ret = string.split(p.default_reply, "+")
      general = general_ret[1]
      deputy = general_ret[2]
    end
    table.insertTableIfNeed(selected, {general, deputy})

--[[ -- FIXME
    p:setMark("__heg_general", general) 
    p:setMark("__heg_deputy", deputy)
    p:doNotify("SetPlayerMark", json.encode{ p.id, "__heg_general", general})
    p:doNotify("SetPlayerMark", json.encode{ p.id, "__heg_deputy", deputy})
]]

    room:setPlayerMark(p, "__heg_general", general)
    room:setPlayerMark(p, "__heg_deputy", deputy)

    room:setPlayerGeneral(p, "anjiang", true)
    room:setDeputyGeneral(p, "anjiang")

    p.default_reply = ""
  end

  generals = table.filter(generals, function(g) return not table.contains(selected, g) end)
  room:returnToGeneralPile(generals)

  local allKingdoms = {}
  table.forEach(room.general_pile, function(name) table.insertIfNeed(allKingdoms, Fk.generals[name].kingdom) end)
  table.removeOne(allKingdoms, "wild")
  table.sort(allKingdoms)

  for _, p in ipairs(players) do
    local curGeneral = Fk.generals[p:getMark("__heg_general")]
    local kingdoms = {curGeneral.kingdom, curGeneral.subkingdom}
    curGeneral = Fk.generals[p:getMark("__heg_deputy")]
    if kingdoms[1] == "wild" then
      kingdoms = {curGeneral.kingdom, curGeneral.subkingdom}
      room:setPlayerMark(p, "__heg_wild", 1)
    else
      kingdoms = table.filter(kingdoms, function(k) return curGeneral.kingdom == k or curGeneral.subkingdom == k end)
    end

    p.default_reply = kingdoms[1]

    local data = json.encode({ kingdoms, allKingdoms, "AskForKingdom", "#ChooseHegInitialKingdom" })
    p.request_data = data
  end

  room:notifyMoveFocus(players, "AskForKingdom")
  room:doBroadcastRequest("AskForChoice", players)

  for _, p in ipairs(players) do
    local kingdomChosen
    if p.reply_ready then
      kingdomChosen = p.client_reply
    else
      kingdomChosen = p.default_reply
    end
    room:setPlayerMark(p, "__heg_kingdom", kingdomChosen)
    room:setPlayerMark(p, "__heg_init_kingdom", kingdomChosen)
    p.default_reply = ""
    -- p.kingdom = kingdomChosen
    --room:notifyProperty(p, p, "kingdom")
  end
end

function HegLogic:broadcastGeneral()
  local room = self.room
  local players = room.players

  for _, p in ipairs(players) do
    assert(p.general ~= "")
    local general = Fk.generals[p:getMark("__heg_general")]
    local deputy = Fk.generals[p:getMark("__heg_deputy")]
    local dmaxHp = deputy.maxHp + deputy.deputyMaxHpAdjustedValue
    local gmaxHp = general.maxHp + general.mainMaxHpAdjustedValue
    p.maxHp = (dmaxHp + gmaxHp) // 2
    -- p.hp = math.floor((deputy.hp + general.hp) / 2)
    p.hp = p.maxHp
    -- p.shield = math.min(general.shield + deputy.shield, 5)
    p.shield = 0
    -- TODO: setup AI here

    room:broadcastProperty(p, "general")
    room:broadcastProperty(p, "deputyGeneral")
    room:broadcastProperty(p, "maxHp")
    room:broadcastProperty(p, "hp")
    room:broadcastProperty(p, "shield")

    p.role = p:getMark("__heg_wild") == 1 and "wild" or p:getMark("__heg_kingdom") -- general.kingdom -- 为了死亡时log有势力提示

    if (dmaxHp + gmaxHp) % 2 == 1 then
      p:setMark("HalfMaxHpLeft", 1)
      p:doNotify("SetPlayerMark", json.encode{ p.id, "HalfMaxHpLeft", 1})
    end
    if general:isCompanionWith(deputy) then
      p:setMark("CompanionEffect", 1)
      p:doNotify("SetPlayerMark", json.encode{ p.id, "CompanionEffect", 1})
    end
  end
end

local function addHegSkill(player, skill, room)
  if skill.frequency == Skill.Compulsory then
    player:addFakeSkill("reveal_skill&")
  end
  player:addFakeSkill(skill)
  local toget = {table.unpack(skill.related_skills)}
  table.insert(toget, skill)
  for _, s in ipairs(toget) do
    if s:isInstanceOf(TriggerSkill) then
      room.logic:addTriggerSkill(s)
    end
  end
end

function HegLogic:attachSkillToPlayers()
  local room = self.room
  local players = room.players

  room:handleAddLoseSkills(players[1], "#_heg_invalid", nil, false, true)

  for _, p in ipairs(room.alive_players) do
    -- UI
    p:setMark("@seat", "seat#" .. tostring(p.seat))
    p:doNotify("SetPlayerMark", json.encode{ p.id, "@seat", "seat#" .. tostring(p.seat)})

    local general = Fk.generals[p:getMark("__heg_general")]
    local skills = table.connect(general.skills, table.map(general.other_skills, Util.Name2SkillMapper))
    for _, s in ipairs(skills) do
      if s.relate_to_place ~= "d" then
        addHegSkill(p, s, room)
      end
    end

    local deputy = Fk.generals[p:getMark("__heg_deputy")]
    if deputy then
      skills = table.connect(deputy.skills, table.map(deputy.other_skills, Util.Name2SkillMapper))
      for _, s in ipairs(skills) do
        if s.relate_to_place ~= "m" then
          addHegSkill(p, s, room)
        end
      end
    end
  end

  room:setTag("SkipNormalDeathProcess", true)
  room:doBroadcastNotify("ShowToast", Fk:translate("#HegInitialNotice"))
end

local heg_getlogic = function()
  local h = GameLogic:subclass("HegLogic")
  for k, v in pairs(HegLogic) do
    h[k] = v
  end
  return h
end

local heg_invalid = fk.CreateInvaliditySkill{
  name = "#_heg_invalid",
  invalidity_func = function(self, player, skill)
  end,
}

local wildKingdoms = {"heg_qin", "heg_qi", "heg_chu", "heg_yan", "heg_zhao", "heg_hanr", "heg_jin", "heg_han", "heg_xia", "heg_shang", "heg_zhou", "heg_liang"} -- hanr 韩
local kingdomMapper = { ["ld__zhonghui"] = "heg_han", ["ld__simazhao"] = "heg_jin", ["ld__gongsunyuan"] = "heg_yan", ["ld__sunchen"] = "heg_chu" }

--- 野心家选择国家
---@param room Room
---@param player ServerPlayer
---@param generalName string
local function wildChooseKingdom(room, player, generalName)
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
      choice = room:askForChoice(player, choices, "#heg_rule", "#wild-choose", false, all_choices)
    end
  elseif table.contains({"wei", "shu", "wu", "qun", "jin", "unknown", "hidden"}, player.role) then
    choice = room:askForChoice(player, choices, "#heg_rule", "#wild-choose", false, all_choices)
  end
  if choice then
    player.role = choice
    player.role_shown = true
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
  local targets = table.map(room.alive_players, Util.IdMapper)
  room:sortPlayersByAction(targets)
  for _, pid in ipairs(targets) do
    local p = room:getPlayerById(pid)
    if p:getMark("__heg_join_wild") == 0 and p.kingdom ~= "wild" and not string.find(p.general, "lord")
      and (not isActive or p.general ~= "anjiang") then
      local choice = room:askForChoice(p, choices, "#heg_rule", "#wild_join-choose")
      if choice ~= "Cancel" then
        p.role = player.role
        p.role_shown = true
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
            skillName = "#heg_rule",
          })
        end
        if p:getHandcardNum() < 4 then
          p:drawCards(4 - p:getHandcardNum(), "#heg_rule")
        end
        return true
      end
    end
  end
  return false
end

local heg_rule = fk.CreateTriggerSkill{
  name = "#nos_heg_rule",
  priority = 0.001,
  events = {fk.BeforeTurnStart, fk.TurnStart, fk.GameOverJudge, fk.Deathed, fk.GeneralRevealed, fk.EventPhaseChanging, fk.GeneralShown, fk.GameStart},
  can_trigger = function(self, event, target, player, data)
    return target == player
  end,
  on_trigger = function(self, event, target, player, data)
    local room = player.room
    if event == fk.BeforeTurnStart then
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
    elseif event == fk.TurnStart then
      H.askForRevealGenerals(room, player, self.name, true, true, true, true, true) -- lord
    elseif event == fk.GameOverJudge then
      -- if table.every(room.alive_players, function (p) return H.compareKingdomWith(p, player) end) then
      player:revealGeneral(false)
      player:revealGeneral(true)
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
          --强制亮主游戏开始，野人不拉拢
        --   for _, p in ipairs(room.alive_players) do
        --     if p:getMark("__heg_wild") == 1 then
        --       wildChooseKingdom(room, p, p.general)
        --       AskForBuildCountry(room, p, p.general, false)
        --       room:setPlayerMark(p, "_wild_gained", 1)
        --     end
        --   end
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
    elseif event == fk.Deathed then
      local damage = data.damage
      if damage and damage.from then
        local killer = damage.from
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
        local players = table.map(table.filter(room.players, function(p) return
          (p:getMark("__heg_kingdom") == player.kingdom or (p.dead and p.kingdom == player.kingdom)) and p ~= player and p.kingdom ~= "wild"
        end), Util.IdMapper)
        room:sortPlayersByAction(players)
        for _, pid in ipairs(players) do
          local p = room:getPlayerById(pid)
          local oldKingdom = p.kingdom
          room:setPlayerMark(p, "__heg_kingdom", "wild")
          if oldKingdom ~= "unknown" then
            room:setPlayerProperty(p, "kingdom", "wild")
            if not p.dead then wildChooseKingdom(room, p, p.general) end
          end
        end
      end
    elseif event == fk.GeneralRevealed then
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
    elseif event == fk.EventPhaseChanging then
      if data.to == Player.Play then
        player:addFakeSkill("alliance&")
      elseif data.from == Player.Play then
        player:loseFakeSkill("alliance&")
      end
    elseif event == fk.GeneralShown then
      if not room:getTag("TheFirstToShowRewarded") then
        room:setTag("TheFirstToShowRewarded", player.id)
      end
      local general_name = data["m"] or data["d"]
      if general_name and string.find(general_name, "lord") then
        local kingdom = player:getMark("__heg_kingdom")
        for _, p in ipairs(room.players) do
          if p:getMark("__heg_kingdom") == kingdom and p.kingdom == "wild" and p:getMark("__heg_wild") == 0 then
            room:setPlayerProperty(p, "kingdom", kingdom)
            p.role_shown = false
            room:setPlayerProperty(p, "role", kingdom)
          end
        end
      end
      if player.kingdom == "wild" and not player.dead and player:getMark("_wild_gained") == 0 then
        wildChooseKingdom(room, player, general_name)
        -- -- 野人亮出来的时候询问拉拢
        -- -- 游戏开始强制亮主，野人不拉拢
        -- local choices = {"Cancel"}
        -- if player:getMark("__heg_wild") == 1 and player:getMark("_wild_final_end") == 0 then
        --   table.insert(choices, "heg_build_country:::" .. player.role)
        -- end
        -- if room:askForChoice(player, choices, "#heg_rule") ~= "Cancel" then
        --   AskForBuildCountry(room, player, general_name, true)
        --   room:setPlayerMark(player, "_wild_gained", 1)
        -- end
      elseif player:getMark("__heg_join_wild") == 0 and player:getMark("__heg_construct_wild") == 0 then
        player.role = player.kingdom
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
            -- --有野人则依次询问拉拢
            -- -- 游戏开始强制亮主，野人不拉拢
            -- for _, p in ipairs(room.alive_players) do
            --   if p:getMark("__heg_wild") == 1 then
            --     wildChooseKingdom(room, p, p.general)
            --     AskForBuildCountry(room, p, p.general, false)
            --     room:setPlayerMark(p, "_wild_gained", 1)
            --   end
            -- end
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
    elseif event == fk.GameStart then
      for _, p in ipairs(room.players) do
        p:setMark("@seat", 0)
        p:doNotify("SetPlayerMark", json.encode{ p.id, "@seat", 0})
        -- 强制亮主规避 bug
        p:revealGeneral(false)
      end
    end
  end,
}
Fk:addSkill(heg_rule)

heg = fk.CreateGameMode{
  name = "nos_heg_mode",
  minPlayer = 2,
  maxPlayer = 10,
  rule = heg_rule,
  logic = heg_getlogic,
  is_counted = function(self, room)
    return #room.players >= 6
  end,
  whitelist = {
    "hegemony_cards",
    "hegemony_standard",
    "formation",
    "momentum",
    "transformation",
    "power",
    "strategic_advantage",
    "tenyear_heg",
    "overseas_heg",
    "lord_ex",
    "offline_heg",

    "formation_cards",
    "momentum_cards",
    "transformation_cards",
    "power_cards",
  },
  winner_getter = function(self, victim)
    local room = victim.room
    local alive = table.filter(room.alive_players, function(p)
      return not p.surrendered
    end)
    if #alive == 1 then
      local p = alive[1] ---@type ServerPlayer
      p:revealGeneral(false)
      p:revealGeneral(true)
      return p.role
    end

    local winner -- = alive[1]
    for _, p in ipairs(alive) do
      if p.kingdom ~= "unknown" then
        winner = p
        break
      end
    end
    if not winner then return "" end
    local kingdom = H.getKingdom(winner)
    local i = H.getKingdomPlayersNum(room, true)[kingdom]
    for _, p in ipairs(alive) do
      if not H.compareExpectedKingdomWith(p, winner) then
        return ""
      end
      if p.kingdom == "unknown" then
        i = i + 1
      end
    end
    if i > #room.players // 2 and not H.getHegLord(room, winner) then return "" end
    return kingdom
  end,
  surrender_func = function(self, playedTime)
    local winner
    local kingdomCheck = true
    for _, p in ipairs(Fk:currentRoom().alive_players) do
      -- 场上有未明置的主将时不能投降
      if p.general == "anjiang" then
        kingdomCheck = false
        break
      end
      if p ~= Self then
        if not winner then
          winner = p
        elseif not H.compareKingdomWith(winner, p) then
          kingdomCheck = false
          break
        end
      end
    end
    return { { text = "heg: besieged on all sides", passed = kingdomCheck } }
  end,
}

Fk:loadTranslationTable{
  ["nos_heg_mode"] = "国战[全亮]",
  [":nos_heg_mode"] = heg_description,
  ["#nos_heg_rule"] = "全亮国战",
  }

return heg