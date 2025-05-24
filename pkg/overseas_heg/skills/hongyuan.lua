local hongyuan = fk.CreateSkill{
  name = "os_heg__hongyuan",
}

---@param object Card|Player
---@param markname string
---@param suffixes string[]
---@return boolean
local function hasMark(object, markname, suffixes)
  if not object then return false end
  for mark, _ in pairs(object.mark) do
    if mark == markname then return true end
    if mark:startsWith(markname .. "-") then
      for _, suffix in ipairs(suffixes) do
        if mark:find(suffix, 1, true) then return true end
      end
    end
  end
  return false
end

hongyuan:addEffect("active", {
  anim_type = "support",
  can_use = function(self, player)
    return player:usedEffectTimes(self.name, Player.HistoryPhase) == 0 and not player:isKongcheng()
  end,
  card_num = 1,
  card_filter = function(self, player, to_select, selected)
    if #selected > 0 then return false end
    return Fk:currentRoom():getCardArea(to_select) == Card.PlayerHand and not hasMark(Fk:getCardById(to_select), "@@alliance", MarkEnum.CardTempMarkSuffix)
  end,
  target_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local card = effect.cards[1]
    room:setCardMark(Fk:getCardById(card), "@@alliance-inhand-turn", 1)
  end,
})
local H = require "packages/hegemony/util"
hongyuan:addEffect(fk.BeforeDrawCard, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(hongyuan.name) and data.skillName == "alliance&" and
      table.find(player.room.alive_players, function(p) return H.compareKingdomWith(p, player) and p ~= player end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room.alive_players, function(p) return H.compareKingdomWith(p, player) and p ~= player end)
    local tos = room:askToChoosePlayers(player, {
      targets = targets,
      min_num = 1,
      max_num = 1,
      prompt = "#os_heg__hongyuan-ask:::" .. data.num,
      skill_name = hongyuan.name,
      cancelable = true
    })
    if #tos > 0 then
      event:setCostData(self, {tos = tos})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    data.who = event:getCostData(self).tos[1]
  end,
})

hongyuan:addTest(function (room, me)
  local hongyuan_to = table.filter(room.alive_players, function(p) return H.compareKingdomWith(p, me) and p ~= me end)[1]
  local alliance_to = table.filter(room.alive_players, function(p) return H.compareKingdomWith(p, me, true) end)[1]
  local function createThreeTimesClosure() -- 第四次询问时断点
    local i = 0
    return function()
      i = i + 1
      return i == 3
    end
  end
  FkTest.setRoomBreakpoint(me, "PlayCard", createThreeTimesClosure())
  FkTest.setNextReplies(me, {
    json.encode {
      card = { skill = "os_heg__hongyuan", subcards = {1} }
    },
    json.encode {
      card = { skill = "alliance&", subcards = {1} },
      targets = { alliance_to.id },
    },
    json.encode {
      card = { skill = "choose_players_skill", subcards = {} },
      targets = { hongyuan_to.id }
    }
  })
  local times
  FkTest.runInRoom(function ()
    room:changeHero(me, "os_heg__zhugejin", true, true, true, true, false)
    room:handleAddLoseSkills(me, "alliance&")
    room:obtainCard(me, 1)
    room:moveCardTo(2, Card.DrawPile)
    GameEvent.Turn:create(TurnData:new(me, "game_rule", { Player.Play })):exec()
  end)
  lu.assertEquals(alliance_to:getCardIds("h"), { 1 })
  lu.assertEquals(hongyuan_to:getCardIds("h"), { 2 })
  times = {me:usedSkillTimes(hongyuan.name, Player.HistoryPhase),
      me:usedEffectTimes(hongyuan.name, Player.HistoryPhase)}
  lu.assertEquals(times[1], 2)
  lu.assertEquals(times[2], 1)
  FkTest.resumeRoom() -- 继续

  FkTest.setNextReplies(me, {
    json.encode {
      card = { skill = "alliance&", subcards = {1} },
      targets = { alliance_to.id },
    },
    json.encode {
      card = { skill = "choose_players_skill", subcards = {} },
      targets = { hongyuan_to.id }
    }, "1" -- 确认亮将
  })
  FkTest.runInRoom(function ()
    me:hideGeneral(true)
    me:prelightSkill(hongyuan.name, true)
    room:obtainCard(me, 1, nil, nil, nil, nil, "@@alliance-inhand-turn")
    room:moveCardTo(2, Card.DrawPile, nil, nil, nil, nil, true)
    GameEvent.Turn:create(TurnData:new(me, "game_rule", { Player.Play })):exec()
  end)
  lu.assertEquals(alliance_to:getCardIds("h"), { 1 })
  lu.assertEquals(hongyuan_to:getCardIds("h"), { 2 })
end)

Fk:loadTranslationTable{
  ["os_heg__hongyuan"] = "弘援",
  [":os_heg__hongyuan"] = "①当你因合纵摸牌时，你可改为令与你势力相同的一名其他角色摸牌。②出牌阶段限一次，你可令一张无合纵标记的手牌于本回合视为有合纵标记。",

  ["#os_heg__hongyuan-ask"] = "弘援：你将摸%arg张牌，可改为令与你势力相同的一名其他角色摸牌",

  ["$os_heg__hongyuan1"] = "诸将莫慌，粮草已到。",
  ["$os_heg__hongyuan2"] = "自舍其身，施于天下。",
}

return hongyuan
