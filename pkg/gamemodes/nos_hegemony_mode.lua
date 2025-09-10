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
    room:setPlayerProperty(p, "role_shown", false)
    p.role = "hidden"
    room:broadcastProperty(p, "role")
  end

  -- for adjustSeats
  room.players[1].role = "lord"
end

function HegLogic:chooseGenerals()
  local room = self.room
  local generalNum = math.max(room.settings.generalNum, 5)
  room:doBroadcastNotify("ShowToast", Fk:translate("#HegInitialNotice"))

  local lord = room:getLord() --[[@as ServerPlayer]]
  room:setCurrent(lord)
  lord.role = "hidden"

  local allKingdoms = {} ---@type string[]
  table.forEach(room.general_pile, function(name)
    table.insertIfNeed(allKingdoms, Fk.generals[name].kingdom) -- 假设不会有只出现在副势力的势力
  end)
  table.removeOne(allKingdoms, "wild") -- 野心家势力不包括
  if #allKingdoms > 4 then
    local kingdoms = table.random(allKingdoms, 4)
    local unused = table.filter(allKingdoms, function(k)
      return not table.contains(kingdoms, k)
    end)
    room:sendLog{
      type = "#KingdomFiltered",
      arg = table.concat(table.map(unused, Util.TranslateMapper), " "),
      arg2 = table.concat(table.map(kingdoms, Util.TranslateMapper), " "),
      toast = true,
    }
    for i = #room.general_pile, 1, -1 do
      local g = Fk.generals[room.general_pile[i]]
      if table.contains(unused, g.kingdom) or table.contains(unused, g.subkingdom) then
        table.remove(room.general_pile, i)
      end
    end
    -- 然后把武将牌堆弄好
    allKingdoms = kingdoms
  end
  table.sort(allKingdoms)
  room:setBanner("all_kingdoms", allKingdoms)

  local players = room.players
  local generals = room:getNGenerals(#players * generalNum) -- Fk:getGeneralsRandomly
  table.shuffle(generals)
  local req = Request:new(players, "AskForGeneral")
  req.timeout = self.room.settings.generalTimeout
  for k, p in ipairs(players) do
    -- local arg = { map = table.map }
    local arg = table.slice(generals, (k - 1) * generalNum + 1, k * generalNum + 1)
    table.sort(arg, function(a, b) return Fk.generals[a].kingdom > Fk.generals[b].kingdom end)

    for idx, _ in ipairs(arg) do
      local g = Fk.generals[arg[idx]]
      local g2 = Fk.generals[arg[idx + 1]]
      if (g.kingdom == g2.kingdom and g.kingdom ~= "wild") or (g.kingdom == "wild" and g2.kingdom ~= "wild") or
        (g.subkingdom ~= nil and g.subkingdom == g2.subkingdom) or g.kingdom == g2.subkingdom or g.subkingdom == g2.kingdom then
          req:setDefaultReply(p, {arg[idx], arg[idx + 1]})
          break
      end
    end

    req:setData(p, {arg, 2, false, true})
  end

  local selected = {}
  for _, p in ipairs(players) do
    local general_ret = req:getResult(p)
    local general, deputy = general_ret[1], general_ret[2]
    room:setPlayerGeneral(p, general, true)
    room:setDeputyGeneral(p, deputy)
    table.insertTableIfNeed(selected, {general, deputy})

    room:setPlayerMark(p, "__heg_general", general)
    room:setPlayerMark(p, "__heg_deputy", deputy)

    room:setPlayerGeneral(p, "anjiang", true)
    room:setDeputyGeneral(p, "anjiang")
  end

  generals = table.filter(generals, function(g) return not table.contains(selected, g) end)
  room:returnToGeneralPile(generals)

  req = Request:new(players, "AskForChoice")
  req.focus_text = "AskForKingdom"
  req.receive_decode = false

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

    if not table.contains(allKingdoms, "wu") and
      (p:getMark("__heg_deputy") == "mouxusheng" or p:getMark("__heg_general") == "mouxusheng") then -- 方便测
        table.insert(kingdoms, "wu")
        table.insert(allKingdoms, "wu")
    end

    req:setData(p, {kingdoms, allKingdoms, "AskForKingdom", "#ChooseHegInitialKingdom"})
    req:setDefaultReply(p, kingdoms[1])
  end

  for _, p in ipairs(players) do
    local kingdomChosen = req:getResult(p)
    room:setPlayerMark(p, "__heg_kingdom", kingdomChosen) -- 变野后变为wild
    room:setPlayerMark(p, "__heg_init_kingdom", kingdomChosen) -- 保存初始势力
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
      p:doNotify("SetPlayerMark", { p.id, "HalfMaxHpLeft", 1})
    end
    if general:isCompanionWith(deputy) then
      p:setMark("CompanionEffect", 1)
      p:doNotify("SetPlayerMark", { p.id, "CompanionEffect", 1})
    end
  end
end

function HegLogic:prepareDrawPile()
  GameLogic.prepareDrawPile(self)

  local room = self.room
  local allianceCards = table.clone(H.allianceCards)
  local addAllianceMark = function(c)
    for i = #allianceCards, 1, -1 do
      local cc = allianceCards[i]
      if c.name == cc[1] and c.suit == cc[2] and c.number == cc[3] then
        room:setCardMark(c, "@@alliance-public", 1)
        table.remove(allianceCards, i)
        break
      end
    end
  end
  for _, cid in ipairs(room.draw_pile) do
    addAllianceMark(Fk:getCardById(cid))
  end
  for _, cid in ipairs(room.void) do
    addAllianceMark(Fk:getCardById(cid))
  end
end

local function addHegSkill(player, skill, room)
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
  for _, p in ipairs(room.alive_players) do
    -- UI
    p:setMark("@seat", "seat#" .. tostring(p.seat))
    p:doNotify("SetPlayerMark", { p.id, "@seat", "seat#" .. tostring(p.seat)})

    local general = Fk.generals[p:getMark("__heg_general")]
    local skills = table.connect(general.skills, table.map(general.other_skills, Util.Name2SkillMapper))
    local hasRevealSkill = false
    for _, s in ipairs(skills) do
      if not s:hasTag(Skill.DeputyPlace) then
        addHegSkill(p, s, room)
        if not hasRevealSkill and s:hasTag(Skill.Compulsory) then
          hasRevealSkill = true
        end
      end
    end

    local deputy = Fk.generals[p:getMark("__heg_deputy")]
    if deputy then
      skills = table.connect(deputy.skills, table.map(deputy.other_skills, Util.Name2SkillMapper))
      for _, s in ipairs(skills) do
        if not s:hasTag(Skill.MainPlace) then
          addHegSkill(p, s, room)
          if not hasRevealSkill and s:hasTag(Skill.Compulsory) then
            hasRevealSkill = true
          end
        end
      end
    end

    if hasRevealSkill then
      p:addFakeSkill("reveal_skill&")
    end
  end

  room:doBroadcastNotify("ShowToast", Fk:translate("#HegInitialNotice"))
end

local heg_getLogic = function()
  local h = GameLogic:subclass("HegLogic")
  for k, v in pairs(HegLogic) do
    h[k] = v
  end
  return h
end

heg = fk.CreateGameMode{
  name = "nos_heg_mode",
  minPlayer = 2,
  maxPlayer = 10,
  rule = "heg_rule",
  logic = heg_getLogic,
  main_mode = "heg_mode",
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
    "zqdl",
    "sixiangfengyin",

    "lord_cards",
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

  build_draw_pile = function(self)
    local draw, void = GameMode.buildDrawPile(self)

    for i = #draw, 1, -1 do
      local card = Fk:getCardById(draw[i])
      if H.convertCards[card.name] then
        local name = H.convertCards[card.name]
        if table.find(draw, function(c)
          return Fk:getCardById(c).name == name
        end) then
          local id = table.remove(draw, i)
          table.insert(void, id)
        end
      end
    end

    return draw, void
  end
}

Fk:loadTranslationTable{
  ["nos_heg_mode"] = "国战[全亮]",
  [":nos_heg_mode"] = heg_description,
}

return heg
