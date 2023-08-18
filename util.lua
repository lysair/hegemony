local H = {}

--- from与to势力是否相同
---
--- diff为false为相同，true为不同
---@param from ServerPlayer
---@param to ServerPlayer
---@param diff bool
---@return boolean
H.compareKingdomWith = function(from, to, diff)
  if from == to then
    return not diff
  end
  for _, p in ipairs({from, to}) do
    if p.kingdom == "unknown" and p.deputyGeneral ~= "anjiang" then
      local oldKingdom = Fk.generals[p.deputyGeneral].kingdom
      if #table.filter(Fk:currentRoom():getOtherPlayers(p),
        function(p)
          return p.kingdom == oldKingdom
        end) >= #Fk:currentRoom().players // 2 then
        if RoomInstance then
          RoomInstance:setPlayerProperty(p, "kingdom", "wild")
        end
      else
        if RoomInstance then
          RoomInstance:setPlayerProperty(p, "kingdom", oldKingdom)
        end
      end
    end
  end
  if from.kingdom == "unknown" or to.kingdom == "unknown" then
    return false
  end

  local ret = from.kingdom == to.kingdom
  if diff then ret = not ret end
  return ret
end

---@param room Room
H.getKingdomPlayersNum = function(room)
  local kingdomMapper = {}
  for _, p in ipairs(room.alive_players) do
    local kingdom = p.kingdom -- p.role
    if kingdom ~= "unknown" then
      if kingdom == "wild" then --权宜
        kingdom = tostring(p.id)
      end
      kingdomMapper[kingdom] = kingdomMapper[kingdom] or 0 
      kingdomMapper[kingdom] = kingdomMapper[kingdom] + 1
    end
  end
  return kingdomMapper
end

--- 判断角色是否为大势力角色
---@param player ServerPlayer
---@return boolean
H.isBigKingdomPlayer = function(player)
  if player.kingdom == "unknown" then return false end
  --if (hasShownOneGeneral() && hasTreasure("JadeSeal")) return true;
  local room = Fk:currentRoom()
  local num = H.getKingdomPlayersNum(room)[player.kingdom == "wild" and tostring(player.id) or player.kingdom]
  if num < 2 then return false end
  for k, n in pairs(H.getKingdomPlayersNum(room)) do
    if n > num then return false end
  end
  return true
end

--- 判断角色是否为小势力角色
---@param player ServerPlayer
---@return boolean
H.isSmallKingdomPlayer = function(player)
  if H.isBigKingdomPlayer(player) then return false end
  return table.find(Fk:currentRoom().alive_players, function(p) return H.isBigKingdomPlayer(p) end)
end

--- 对某角色发起军令（抽取、选择、询问）
---@param from ServerPlayer @ 军令发起者
---@param to ServerPlayer @ 军令执行者
---@param skill_name string @ 技能名
---@return boolean @ 是否执行
H.askCommandTo = function(from, to, skill_name)
  local index = H.startCommand(from, skill_name)
  local invoke = H.doCommand(to, skill_name, index, from)
  return invoke
end

--- 军令发起者抽取并选择军令
---@param from ServerPlayer @ 军令发起者
---@param skill_name string @ 技能名
---@return index integer @ 是否执行
H.startCommand = function(from, skill_name)
  local allcommands = {"command1", "command2", "command3", "command4", "command5", "command6"}
  local commands = table.random(allcommands, 2)

  local room = from.room
  local choice = room:askForChoice(from, commands, "start_command", nil, true)

  room:sendLog{
    type = "#CommandChoice",
    from = from.id,
    arg = ":"+choice,
  }
  room:doBroadcastNotify("ShowToast", Fk:translate(from.general) .. "/" .. Fk:translate(from.deputyGeneral) .. Fk:translate("chose") .. Fk:translate(":"+choice))

  return table.indexOf(allcommands, choice)
end

--- 询问军令执行者是否执行军令（执行效果也在这里）
---@param to ServerPlayer @ 军令执行者
---@param skill_name string @ 技能名
---@param index integer @ 军令序数
---@param from ServerPlayer @ 军令发起者
---@return boolean @ 是否执行
H.doCommand = function(to, skill_name, index, from)
  if to.dead or from.dead then return false end
  local room = to.room
  
  local allcommands = {"command1", "command2", "command3", "command4", "command5", "command6"}
  local choice = room:askForChoice(to, {allcommands[index], "Cancel"}, "do_command", nil, true)

  local result = choice == "Cancel" and "#commandselect_no" or "#commandselect_yes"
  room:sendLog{
    type = "#CommandChoice",
    from = to.id,
    arg = result,
  }
  room:doBroadcastNotify("ShowToast", Fk:translate(to.general) .. "/" .. Fk:translate(to.deputyGeneral) .. Fk:translate("chose") .. Fk:translate(result))

  if choice == "Cancel" then return false end
  if index == 1 then
    local dest = room:askForChoosePlayers(from, table.map(room.alive_players, Util.IdMapper), 1, 1, "#command1-damage::" .. to.id, skill_name)[1]
    room:sendLog{
      type = "#Command1Damage",
      from = from.id,
      to = {dest},
    }
    room:doIndicate(from.id, {dest})
    room:damage{
      from = to,
      to = room:getPlayerById(dest),
      damage = 1,
      skillName = "command",
    }
  elseif index == 2 then
    to:drawCards(1, "command")
    if to == from or to:isNude() then return true end
    local cards = {}
    if #to:getCardIds{Player.Hand, Player.Equip} == 1 then
      cards = to:getCardIds{Player.Hand, Player.Equip}
    else
      cards = room:askForCard(to, 2, 2, true, "command", false, nil, "#command2-give::" .. from.id)
    end
    room:moveCardTo(cards, Player.Hand, from, fk.ReasonGive, "command", nil, false, from.id)
  elseif index == 3 then
    room:loseHp(to, 1, "command")
  elseif index == 4 then
    room:setPlayerMark(to, "_command4_effect-turn", 1)
    room:addPlayerMark(to, MarkEnum.UncompulsoryInvalidity .. "-turn")
    room:handleAddLoseSkills(to, "#command4_prohibit", nil, false, true) --为了不全局，流汗了
  elseif index == 5 then
    to:turnOver()
    room:setPlayerMark(to, "_command5_effect-turn", 1)
    room:handleAddLoseSkills(to, "#command5_cannotrecover", nil, false, true) --为了不全局，流汗了
  elseif index == 6 then
    if to:getHandcardNum() < 2 and #to:getCardIds(Player.Equip) < 2 then return true end
    local to_remain = {}
    if not to:isKongcheng() then
      table.insert(to_remain, to:getCardIds(Player.Hand)[1])
    end
    if #to:getCardIds(Player.Equip) > 0 then
      table.insert(to_remain, to:getCardIds(Player.Equip)[1])
    end
    local _, ret = room:askForUseActiveSkill(to, "#command6_select", "#command6-select", false)
    if ret then
      to_remain = ret.cards
    end
    local cards = table.filter(to:getCardIds{Player.Hand, Player.Equip}, function (id)
      return not (table.contains(to_remain, id) or to:prohibitDiscard(id))
    end)
    if #cards > 0 then
      room:throwCard(cards, "command", to)
    end
  end
  return true
end

Fk:loadTranslationTable{
  ["command"] = "军令",

  ["#StartCommand"] = "%arg：请选择一项军令<br>%arg2；<br>%arg3",
  ["command1"] = "军令一",
  ["command2"] = "军令二",
  ["command3"] = "军令三",
  ["command4"] = "军令四",
  ["command5"] = "军令五",
  ["command6"] = "军令六",

  [":command1"] = "军令一：对发起者指定的角色造成1点伤害",
  [":command2"] = "军令二：摸一张牌，然后交给发起者两张牌",
  [":command3"] = "军令三：失去1点体力",
  [":command4"] = "军令四：本回合不能使用或打出手牌且所有非锁定技失效",
  [":command5"] = "军令五：叠置，本回合不能回复体力",
  [":command6"] = "军令六：选择一张手牌和一张装备区里的牌，弃置其余的牌",

  ["start_command"] = "发起军令",
  ["#CommandChoice"] = "%from 选择了 %arg",
  ["chose"] = "选择了",

  ["do_command"] = "执行军令",
  ["#commandselect_yes"] = "执行军令",
  ["#commandselect_no"] = "不执行军令",

  ["#command1-damage"] = "军令：请选择 %dest 伤害的目标",
  ["#Command1Damage"] = "%from 选择对 %to 造成伤害",
  ["#command2-give"] = "军令：请选择两张牌交给 %dest",
  ["#command6-select"] = "军令：请选择要保留的一张手牌和一张装备",
}


return H
