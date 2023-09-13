local H = {}

-- 势力相关

--- 获取势力（野心家为role）
---@param player ServerPlayer
---@return string
H.getKingdom = function(player)
  local ret = player.kingdom
  if ret == "wild" then
    ret = player.role
  end
  return ret
end

--- from与to势力是否相同
---
--- diff为false为相同，true为不同
---@param from Player
---@param to Player
---@param diff bool
---@return boolean
H.compareKingdomWith = function(from, to, diff)
  if from == to then
    return not diff
  end
  if from.kingdom == "unknown" or to.kingdom == "unknown" then
    return false
  end

  local ret = H.getKingdom(from) == H.getKingdom(to)
  if diff then ret = not ret end
  return ret
end

--- 获取势力角色数列表
---@param room Room
H.getKingdomPlayersNum = function(room)
  assert(room)
  local kingdomMapper = {}
  for _, p in ipairs(room.alive_players) do
    local kingdom = H.getKingdom(p)
    if kingdom ~= "unknown" then
      kingdomMapper[kingdom] = (kingdomMapper[kingdom] or 0) + 1
    end
  end
  return kingdomMapper
end

--- 判断角色是否为大势力角色
---@param player ServerPlayer
---@return boolean
H.isBigKingdomPlayer = function(player)
  if player.kingdom == "unknown" then return false end
  local room = Fk:currentRoom()

  local status_skills = room.status_skills[H.BigKingdomSkill] or Util.DummyTable
  for _, skill in ipairs(status_skills) do
    for _, p in ipairs(room.alive_players) do
      if skill:getFixed(p) then
        return H.compareKingdomWith(p, player)
      end
    end
  end

  local mapper = H.getKingdomPlayersNum(room)
  local num = mapper[H.getKingdom(player)]
  if num < 2 then return false end
  for k, n in pairs(mapper) do
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

-- 阵型

--- 获取下N家
---@param player Player
---@param n integer
---@param ignoreRemoved bool
---@return player ServerPlayer
H.getNextNAlive = function(player, n, ignoreRemoved)
  n = n or 1
  local ret = player
  for _ = 1, n do
    ret = ret:getNextAlive(ignoreRemoved)
  end
  return ret
end

--- 获取上N家
---@param player Player
---@param n integer
---@param ignoreRemoved bool
---@return player ServerPlayer
H.getLastNAlive = function(player, n, ignoreRemoved)
  n = n or 1
  local room = Fk:currentRoom()
  local index = ignoreRemoved and #room.alive_players or #table.filter(room.alive_players, function(p) return not p:isRemoved() end) - n
  return H.getNextNAlive(player, index, ignoreRemoved)
end

--- 获取与角色成队列的其余角色
---@param player ServerPlayer
---@return players ServerPlayer[]|nil @ 队列中的角色
H.getFormationRelation = function(player)
  local players = Fk:currentRoom():getAlivePlayers()
  local index = table.indexOf(players, player) -- ABCDEF, C
  local targets = table.slice(players, index)
  table.insertTable(targets, table.slice(players, 1, index)) -- CDEFAB
  players = {}
  for i = 2, #targets do
    local p = targets[i] ---@type ServerPlayer
    if not p:isRemoved() then
      if H.compareKingdomWith(p, player) then
        table.insert(players, p)
      else
        break
      end
    end
  end
  for i = #targets, 2, -1 do
    local p = targets[i] ---@type ServerPlayer
    if not p:isRemoved() then
      if H.compareKingdomWith(p, player) then
        table.insert(players, p)
      else
        break
      end
    end
  end
  return players
end

--- 确认与某角色是否处于围攻关系
---@param player ServerPlayer @ 围攻角色1
---@param target ServerPlayer @ 围攻角色2
---@param victim ServerPlayer @ 被围攻角色
---@return bool
H.inSiegeRelation = function(player, target, victim)
  if H.compareKingdomWith(player, victim) or not H.compareKingdomWith(player, target) or victim.kingdom == "unknown" then return false end
  if player == target then
    return (player:getNextAlive() == victim and H.getNextNAlive(player, 2) ~= player and H.compareKingdomWith(H.getNextNAlive(player, 2), player))
    or (H.getLastNAlive(player) == victim and H.getLastNAlive(player, 2) ~= player and H.compareKingdomWith(H.getLastNAlive(player, 2), player))
  else
    return (player:getNextAlive() == victim and H.getNextNAlive(player, 2) == target)
    or (H.getLastNAlive(player) == victim and H.getLastNAlive(player, 2) == target)
  end
end

-- 军令
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

-- 国无懈

local hegNullificationSkill = fk.CreateActiveSkill{
  name = "heg__nullification_skill",
  can_use = function()
    return false
  end,
  on_use = function(self, room, use)
    if use.responseToEvent.to and #TargetGroup:getRealTargets(use.responseToEvent.tos) > 1 then 
      local from = room:getPlayerById(use.from)
      local to = room:getPlayerById(use.responseToEvent.to)
      if to.kingdom ~= "unknown" then
        local choices = {"hegN-single::" .. to.id, "hegN-all:::" .. to.kingdom}
        local choice = room:askForChoice(from, choices, self.name, "#hegN-ask")
        local ret = Fk:translate(from.general) .. '/' .. Fk:translate(from.deputyGeneral) .. Fk:translate("chose") .. Fk:translate("hegN_toast")
        local arg
        if choice:startsWith("hegN-all") then
          arg = Fk:translate(to.kingdom)
          room:sendLog{
            type = "#HegNullificationAll",
            from = from.id,
            arg = to.kingdom,
            card = Card:getIdList(use.card),
          }
          use.extra_data = use.extra_data or {}
          use.extra_data.hegN_all = true
        else
          arg = Fk:translate(to.general) .. '/' .. Fk:translate(to.deputyGeneral)
          room:sendLog{
            type = "#HegNullificationSingle",
            from = from.id,
            to = {to.id},
            card = Card:getIdList(use.card),
          }
        end
        room:doBroadcastNotify("ShowToast", ret .. arg)
      else
        room:delay(1200)
      end
    else
      room:delay(1200)
    end
  end,
  on_effect = function(self, room, effect)
    if effect.responseToEvent then
      effect.responseToEvent.isCancellOut = true
      if (effect.extra_data or {}).hegN_all then
        local to = room:getPlayerById(effect.responseToEvent.to)
        effect.responseToEvent.disresponsiveList = effect.responseToEvent.disresponsiveList or {}
        for _, p in ipairs(room.alive_players) do
          if H.compareKingdomWith(p, to) then
            table.insertIfNeed(effect.responseToEvent.nullifiedTargets, p.id)
            table.insertIfNeed(effect.responseToEvent.disresponsiveList, p.id)
          end
        end
      end
    end
  end
}
H.hegNullification = fk.CreateTrickCard{
  name = "heg__nullification",
  suit = Card.Spade,
  number = 11,
  skill = hegNullificationSkill,
}

Fk:loadTranslationTable{
  ["heg__nullification"] = "无懈可击·国",
  ["heg__nullification_skill"] = "无懈可击·国",
  [":heg__nullification"] = "锦囊牌<br/><b>时机</b>：当锦囊牌对目标生效前<br/><b>目标</b>：此牌<br/><b>效果</b>：抵消此牌。你令对对应的角色为与其势力相同的角色的目标结算的此牌不是【无懈可击】的合法目标，当此牌对对应的角色为这些角色中的一名的目标生效前，抵消此牌。",
  ["#hegN-ask"] = "无懈可击·国：请选择",
  ["hegN-single"] = "对%dest使用",
  ["hegN-all"] = "对%arg势力使用",
  ["hegN_toast"] = " 【无懈可击·国】对 ",
  ["#HegNullificationSingle"] = "%from 选择此 %card 对 %to 生效",
  ["#HegNullificationAll"] = "%from 选择此 %card 对 %arg 势力生效",
}

-- 武将牌相关

--- 是否珠联璧合
---@param general General
---@param deputy General
---@return boolean
H.isCompanionWith = function(general, deputy) -- 缺君主
  return table.contains(general.companions, deputy.name) or table.contains(deputy.companions, general.name)
end

--- 判断有无主将/副将
---@param player ServerPlayer
---@param isDeputy bool
---@return bool
H.hasGeneral = function(player, isDeputy)
  local orig = isDeputy and (player.deputyGeneral or "") or player.general
  return orig ~= "" and not orig:startsWith("blank_")
end

--- 获得真正的主将/副将（而非暗将）
---@param player ServerPlayer
---@param isDeputy bool
---@return string
H.getActualGeneral = function(player, isDeputy)
  if isDeputy then
    return player.deputyGeneral == "anjiang" and player:getMark("__heg_deputy") or player.deputyGeneral or ""
  else
    return player.general == "anjiang" and player:getMark("__heg_general") or player.general
  end
end

--- 获取明置的武将牌数
---@param player ServerPlayer
---@return integer
H.getGeneralsRevealedNum = function(player)
  local num = 0
  if player.general ~= "anjiang" then num = num + 1 end
  if player.deputyGeneral and player.deputyGeneral ~= "anjiang" then num = num + 1 end
  return num
end

--- 暗置武将牌
---@param room Room
---@param player ServerPlayer
---@param target ServerPlayer
---@param skill_name string
---@return isDeputy bool
H.doHideGeneral = function(room, player, target, skill_name)
  if player.dead or target.dead then return end
  local choices = {}
  if target.general ~= "anjiang" and not target.general:startsWith("blank_") then  -- 君主 还要再处理
    table.insert(choices, target.general)
  end
  if target.deputyGeneral and target.deputyGeneral ~= "anjiang" and not target.deputyGeneral:startsWith("blank_") then
    table.insert(choices, target.deputyGeneral)
  end
  if #choices == 0 then return end
  local choice = room:askForChoice(player, choices, skill_name, "#hide_general-ask::" .. target.id .. ":" .. skill_name)
  local isDeputy = choice == target.deputyGeneral
  target:hideGeneral(isDeputy)
  room:sendLog{
    type = "#HideOtherGeneral",
    from = player.id,
    to = {target.id},
    arg = isDeputy and "deputyGeneral" or "mainGeneral",
    arg2 = isDeputy and target:getMark("__heg_deputy") or target:getMark("__heg_general"),
  }
  return isDeputy
end
Fk:loadTranslationTable{
  ["#hide_general-ask"] = "%arg：暗置 %dest 一张武将牌",
  ["#HideOtherGeneral"] = "%from 暗置了 %to 的 %arg %arg2",
}


-- 移除武将牌
---@param room Room
---@param player ServerPlayer
---@param isDeputy bool @ 是否为副将，默认主将
H.removeGeneral = function(room, player, isDeputy)
  player:setMark("CompanionEffect", 0)
  player:setMark("HalfMaxHpLeft", 0)
  player:doNotify("SetPlayerMark", json.encode{ player.id, "CompanionEffect", 0})
  player:doNotify("SetPlayerMark", json.encode{ player.id, "HalfMaxHpLeft", 0})

  --if player.kingdom == "unknown" then player:revealGeneral(isDeputy, true) end 
  player:revealGeneral(isDeputy, true) -- 先摆

  local orig = isDeputy and (player.deputyGeneral or "") or player.general

  if orig:startsWith("blank_") then return false end

  orig = Fk.generals[orig]

  local orig_skills = orig and orig:getSkillNameList() or Util.DummyTable

  local new_general = orig.gender == General.Male and "blank_shibing" or "blank_nvshibing"

  orig_skills = table.map(orig_skills, function(e)
    return "-" .. e
  end)

  room:handleAddLoseSkills(player, table.concat(orig_skills, "|"), nil, false)

  if isDeputy then
    room:setPlayerProperty(player, "deputyGeneral", new_general)
  else
    room:setPlayerProperty(player, "general", new_general)
  end

  player:filterHandcards()
  room:sendLog{
    type = "#GeneralRemoved",
    from = player.id,
    arg = isDeputy and "deputyGeneral" or "mainGeneral",
    arg2 = orig.name,
  }
  room.logic:trigger("fk.GeneralRemoved", player, orig.name)
end
Fk:loadTranslationTable{
  ["#GeneralRemoved"] = "%from 移除了 %arg %arg2",
}

--- 变更武将牌
---@param room Room
---@param player ServerPlayer
---@param isMain bool @ 是否为主将，默认副将
H.transformGeneral = function(room, player, isMain)
  local orig = isMain and player.general or player.deputyGeneral 
  if not orig then return false end
  if orig == "anjiang" then player:revealGeneral(not isMain, true) end
  local existingGenerals = {}
  for _, p in ipairs(room.players) do
    table.insert(existingGenerals, p.general == "anjiang" and p:getMark("__heg_general") or p.general)
    table.insert(existingGenerals, p.deputyGeneral == "anjiang" and p:getMark("__heg_deputy") or p.deputyGeneral)
  end
  room.logic:trigger("fk.GeneralTransforming", player, orig)
  local generals = table.map(Fk:getGeneralsRandomly(3, Fk:getAllGenerals(), existingGenerals, function(p) return (p.kingdom ~= player.kingdom) end), Util.NameMapper)
  local general = room:askForGeneral(player, generals, 1, true)
  room:changeHero(player, general, false, not isMain, true, false)
end

-- 合纵

H.allianceCards = {}

--- 向合纵库中加载一张卡牌。
---@param card Card @ 要加载的卡牌
H.addCardToAllianceCards = function(card)
  assert(card.class:isSubclassOf(Card))
  table.insertIfNeed(H.allianceCards, card)
end

-- 大势力

--- 视为大势力技
---@class BigKingdomSkill : StatusSkill
H.BigKingdomSkill = StatusSkill:subclass("BigKingdomSkill")

---@param player Player
---@return bool
function H.BigKingdomSkill:getFixed(player)
  return false
end

local function readCommonSpecToSkill(skill, spec)
  skill.mute = spec.mute
  skill.anim_type = spec.anim_type

  if spec.attached_equip then
    assert(type(spec.attached_equip) == "string")
    skill.attached_equip = spec.attached_equip
  end

  if spec.switch_skill_name then
    assert(type(spec.switch_skill_name) == "string")
    skill.switchSkillName = spec.switch_skill_name
  end

  if spec.relate_to_place then
    assert(type(spec.relate_to_place) == "string")
    skill.relate_to_place = spec.relate_to_place
  end
end

local function readStatusSpecToSkill(skill, spec)
  readCommonSpecToSkill(skill, spec)
  if spec.global then
    skill.global = spec.global
  end
end

---@class StatusSkillSpec: StatusSkill

---@class BigKingdomSkill: StatusSkillSpec
---@field public fixed_func nil|fun(self: BigKingdomSkill, player: Player): bool

---@param spec BigKingdomSkillSpec
---@return BigKingdomSkill
H.CreateBigKingdomSkill = function(spec)
  assert(type(spec.name) == "string")
  assert(type(spec.fixed_func) == "function")

  local skill = H.BigKingdomSkill:new(spec.name)
  readStatusSpecToSkill(skill, spec)

  if spec.fixed_func then
    skill.getFixed = spec.fixed_func
  end

  return skill
end

-- 清理武将牌上的牌技能
---@param skill Skill
---@param expand_pile string
H.CreateClearSkill = function(skill, expand_pile)
  assert(skill:isInstanceOf(Skill))
  assert(type(expand_pile) == "string")
  local skill_name = skill.name
  local clear_skill = fk.CreateTriggerSkill{
    name = "#" .. skill_name .. "-clear",
    anim_type = "negative",
    expand_pile = expand_pile,
    refresh_events = {fk.EventLoseSkill, fk.GeneralHidden},
    can_refresh = function(self, event, target, player, data)
      -- if target ~= player then return false end
      if #player:getPile(expand_pile) == 0 then return false end
      if event == fk.EventLoseSkill then
        return target == player and data == Fk.skills[skill_name]
      else
        return table.contains(Fk.generals[data]:getSkillNameList(), skill_name)
      end
    end,
    on_refresh = function(self, event, target, player, data)
      local room = player.room
      room:moveCardTo(player:getPile(expand_pile), Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile, self.name, expand_pile, true)
    end,
  }
  skill:addRelatedSkill(clear_skill)
end

return H
