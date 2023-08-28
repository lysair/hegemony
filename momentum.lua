local H = require "packages/hegemony/util"
local extension = Package:new("momentum")
extension.extensionName = "hegemony"
extension.game_modes_whitelist = { 'nos_heg_mode', 'new_heg_mode' }

Fk:loadTranslationTable{
  ["momentum"] = "君临天下·势",
}

local lidian = General(extension, "ld__lidian", "wei", 3)
lidian:addSkill("xunxun")
lidian:addSkill("wangxi")
lidian:addCompanions("hs__yuejin")
Fk:loadTranslationTable{
  ["ld__lidian"] = "李典",
  ["~ld__lidian"] = "报国杀敌，虽死犹荣……",
}

local madai = General(extension, "ld__madai", "shu", 4)
local madai_mashu = fk.CreateDistanceSkill{
  name = "heg_madai__mashu",
  frequency = Skill.Compulsory,
  correct_func = function(self, from, to)
    if from:hasSkill(self.name) then
      return -1
    end
  end,
}
madai:addSkill(madai_mashu)
madai:addSkill("re__qianxi")
madai:addCompanions("machao")
Fk:loadTranslationTable{
  ["ld__madai"] = "马岱",
  ["heg_madai__mashu"] = "马术",
  [":heg_madai__mashu"] = "锁定技，你与其他角色的距离-1。",
  ["$re__qianxi1"] = "暗影深处，袭敌斩首！",
  ["$re__qianxi2"] = "擒贼先擒王，打蛇打七寸！",
  ["~ld__madai"] = "我怎么会死在这里……",
}

local zangba = General(extension, "ld__zangba", "wei", 4)
local hengjiang = fk.CreateTriggerSkill{
  name = "hengjiang",
  anim_type = "masochism",
  events = { fk.Damaged },
  can_trigger = function(self, _, target, player, _)
    if target ~= player or not player:hasSkill(self.name) then return false end
    local current = player.room.current
    return current ~= nil and not current.dead
  end,
  on_use = function(_, _, _, player, data)
    local room = player.room
    local target = room.current
    if target ~= nil and not target.dead then
      room:doIndicate(player.id, {target.id})
      room:addPlayerMark(target, "@hengjiang-turn", data.damage)
      room:addPlayerMark(target, MarkEnum.MinusMaxCardsInTurn, data.damage)
    end
  end
}
local hengjiangdelay = fk.CreateTriggerSkill{
  name = "#hengjiang_delay",
  anim_type = "drawcard",
  events = { fk.TurnEnd },
  --FIXME:如何体现这个技能是延迟效果？
  can_trigger = function(_, _, target, player, _)
    if player.dead or player:usedSkillTimes(hengjiang.name) == 0 then return false end
    local room = player.room
    local discard_ids = {}
    room.logic:getEventsOfScope(GameEvent.Phase, 1, function (e)
      if e.data[2] == Player.Discard then
        table.insert(discard_ids, {e.id, e.end_id})
      end
      return false
    end, Player.HistoryTurn)
    if #discard_ids > 0 then
      if #room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function (e)
        local in_discard = false
        for _, ids in ipairs(discard_ids) do
          if #ids == 2 and e.id > ids[1] and e.id < ids[2] then
            in_discard = true
            break
          end
        end
        if in_discard then
          for _, move in ipairs(e.data) do
            if move.from == target.id and move.moveReason == fk.ReasonDiscard then
              for _, info in ipairs(move.moveInfo) do
                if info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip then
                  return true
                end
              end
            end
          end
        end
        return false
      end, Player.HistoryTurn) > 0 then
        return false
      end
    end
    return true
  end,
  on_cost = function()
    return true
  end,
  on_use = function(_, _, _, player, _)
    player:drawCards(1, hengjiang.name)
  end,
}
hengjiang:addRelatedSkill(hengjiangdelay)
zangba:addSkill(hengjiang)
Fk:loadTranslationTable{
  ['ld__zangba'] = '臧霸',
  ['hengjiang'] = '横江',
  [':hengjiang'] = '当你受到伤害后，你可以令当前回合角色本回合手牌上限-X（X为伤害值）。' ..
    '然后若其本回合弃牌阶段内没有弃牌，你摸一张牌。',
  ['@hengjiang-turn'] = '横江',
  ['#hengjiang_delay'] = '横江',

  ['$hengjiang1'] = '霸必奋勇杀敌，一雪夷陵之耻！',
  ['$hengjiang2'] = '江横索寒，阻敌绝境之中！',
  ['~ld__zangba'] = '断刃沉江，负主重托……',
}

local mifuren = General(extension, "ld__mifuren", "shu", 3, 3, General.Female)
local guixiu = fk.CreateTriggerSkill{
  name = "guixiu",
  anim_type = "drawcard",
  events = {fk.GeneralRevealed, "fk.GeneralRemoved"},
  can_trigger = function(self, event, target, player, data)
    return target == player and data == "ld__mifuren" and ((event == "fk.GeneralRemoved" and player:isWounded()) or player:hasSkill(self.name))
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, nil, "#guixiu-" .. (event == fk.GeneralRevealed and "draw" or "recover"))
  end,
  on_use = function(self, event, target, player, data)
    if event == fk.GeneralRevealed then
      player:drawCards(2, self.name)
    else
      player.room:recover{
        who = player,
        num = 1,
        skillName = self.name,
      }
    end
  end
}
local cunsi = fk.CreateActiveSkill{
  name = "cunsi",
  anim_type = "big",
  target_num = 1,
  target_filter = function(self, to_select, selected)
    return #selected == 0
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    H.removeGeneral(room, player, player.deputyGeneral == "ld__mifuren")
    local target = room:getPlayerById(effect.tos[1])
    room:handleAddLoseSkills(target, "yongjue", nil)
    if target ~= player and not target.dead then
      target:drawCards(2, self.name)
    end
  end,
}
local yongjue = fk.CreateTriggerSkill{
  name = "yongjue",
  anim_type = "support",
  events = {fk.CardUseFinished},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self.name) and H.compareKingdomWith(target, player) and not target.dead and data.card.trueName == "slash" then
      local events = target.room.logic:getEventsOfScope(GameEvent.UseCard, 1, function(e) 
        local use = e.data[1]
        return use.from == target.id and use.card.trueName == "slash" 
      end, Player.HistoryTurn)
      if #events == 1 and events[1].id == target.room.logic:getCurrentEvent().id then
        local cards = Card:getIdList(data.card)
        return #cards > 0 and table.every(cards, function(id) return target.room:getCardArea(id) == Card.Processing end)
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    return target.room:askForSkillInvoke(target, self.name, nil, "#yongjue-invoke:::" .. data.card:toLogString())
  end,
  on_use = function(self, event, target, player, data)
    local room = target.room
    -- room:doIndicate(player.id, {target.id})
    room:obtainCard(target, data.card, true, fk.ReasonJustMove)
  end,
}
mifuren:addSkill(guixiu)
mifuren:addSkill(cunsi)
mifuren:addRelatedSkill(yongjue)
Fk:loadTranslationTable{
  ['ld__mifuren'] = '糜夫人',
  ["guixiu"] = "闺秀",
  [":guixiu"] = "当你明置此武将牌后，你可摸两张牌。当你移除此武将牌后，你回复1点体力。",
  ["cunsi"] = "存嗣",
  [":cunsi"] = "出牌阶段，你可移除此武将牌并选择一名角色，其获得〖勇决〗。若其不为你，其摸两张牌。", -- canShowInPlay 若此武将牌处于明置状态
  ["yongjue"] = "勇决",
  [":yongjue"] = "当与你势力相同的一名角色于出牌阶段内使用的【杀】结算结束后，若此【杀】为其于此阶段内使用过的第一张牌，（你令）其选择是否获得此【杀】对应的所有实体牌。",

  ["#guixiu-draw"] = "是否发动“闺秀”，摸两张牌",
  ["#guixiu-recover"] = "是否发动“闺秀”，回复1点体力",
  ["#yongjue-invoke"] = "勇决：你可以获得此%arg",

  ["$guixiu1"] = "闺楼独看花月，倚窗顾影自怜。",
  ["$guixiu2"] = "闺中女子，亦可秀气英拔。",
  ["$cunsi1"] = "一切，便托付将军了……",
  ["$cunsi2"] = "存汉室之嗣，留汉室之本。",
  ["$yongjue1"] = "扶幼主，成霸业！",
  ["$yongjue2"] = "能救一个是一个！",
  ["~ld__mifuren"] = "阿斗被救，妾身再无牵挂…",
}

local sunce = General(extension, "ld__sunce", "wu", 4)
sunce.deputyMaxHpAdjustedValue = -1
sunce:addCompanions { "hs__zhouyu", "hs__taishici", "hs__daqiao" }
sunce:addSkill("jiang")
local yingyang = fk.CreateTriggerSkill{
  name = "yingyang",
  events = {fk.PindianCardsDisplayed},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self.name) and (player == data.from or data.results[player.id])
  end,
  on_cost = function(self, event, target, player, data)
    local choice = player.room:askForChoice(player, { 'yingyang_plus3', 'yingyang_sub3', 'Cancel' }, self.name)
    if choice ~= "Cancel" then
      self.cost_data = choice
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local card
    if player == data.from then
      card = data.fromCard
    elseif data.results[player.id] then
      card = data.results[player.id].toCard
    end
    if self.cost_data == "yingyang_plus3" then
      card.number = math.min(card.number + 3, 13)
    elseif self.cost_data == "yingyang_sub3" then
      card.number = math.max(card.number - 3, 1)
    end
  end,
}
sunce:addSkill(yingyang)
local hunshang = fk.CreateTriggerSkill{
  name = 'hunshang',
  relate_to_place = 'd',
  events = {fk.EventPhaseStart},
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and
      player.phase == Player.Start and player.hp == 1
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:handleAddLoseSkills(player, 'heg_sunce__yingzi|heg_sunce__yinghun')
    local logic = room.logic
    logic:getCurrentEvent():findParent(GameEvent.Turn):addExitFunc(function()
      room:handleAddLoseSkills(player, '-heg_sunce__yingzi|-heg_sunce__yinghun')
    end)
  end,
}
sunce:addSkill(hunshang)

local yingzi = fk.CreateTriggerSkill{
  name = "heg_sunce__yingzi",
  anim_type = "drawcard",
  frequency = Skill.Compulsory,
  events = {fk.DrawNCards},
  on_use = function(self, event, target, player, data)
    data.n = data.n + 1
  end,
}
local yingzi_maxcards = fk.CreateMaxCardsSkill{
  name = "#heg_sunce__yingzi_maxcards",
  fixed_func = function(self, player)
    if player:hasSkill(self.name) then
      return player.maxHp
    end
  end
}
yingzi:addRelatedSkill(yingzi_maxcards)
sunce:addRelatedSkill(yingzi)
local yinghun = fk.CreateTriggerSkill{
  name = "heg_sunce__yinghun",
  anim_type = "drawcard",
  mute = true,
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and player.phase == Player.Start and player:isWounded()
  end,
  on_cost = function(self, event, target, player, data)
    local to = player.room:askForChoosePlayers(player, table.map(player.room:getOtherPlayers(player), function (p)
      return p.id end), 1, 1, "#yinghun-choose:::"..player:getLostHp()..":"..player:getLostHp(), self.name, true)
    if #to > 0 then
      self.cost_data = to[1]
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(self.cost_data)
    local n = player:getLostHp()
    local choice = room:askForChoice(player, {"#yinghun-draw:::" .. n,  "#yinghun-discard:::" .. n}, self.name)
    if choice:startsWith("#yinghun-draw") then
      player:broadcastSkillInvoke(self.name, 1)
      room:notifySkillInvoked(player, self.name, "support")
      to:drawCards(n, self.name)
      room:askForDiscard(to, 1, 1, true, self.name, false)
    else
      player:broadcastSkillInvoke(self.name, 2)
      room:notifySkillInvoked(player, self.name, "control")
      to:drawCards(1, self.name)
      room:askForDiscard(to, n, n, true, self.name, false)
    end
  end,
}
sunce:addRelatedSkill(yinghun)
Fk:loadTranslationTable{
  ['ld__sunce'] = '孙策',
  ['yingyang'] = '鹰扬',
  [':yingyang'] = '当你的拼点牌亮出后，你可以令其点数+3或-3。',
  ['hunshang'] = '魂殇',
  [':hunshang'] = '副将技，锁定技，此武将牌减少半个阴阳鱼；准备阶段，若你的体力值为1，本回合内你拥有技能“英姿”和“英魂”。',
  ['heg_sunce__yingzi'] = '英姿',
  [":heg_sunce__yingzi"] = "锁定技，摸牌阶段，你多摸一张牌；你的手牌上限等同于你的体力上限。",
  ["heg_sunce__yinghun"] = "英魂",
  [":heg_sunce__yinghun"] = "准备阶段，若你已受伤，你可以选择一名其他角色并选择一项：1.令其摸X张牌，然后弃置一张牌；2.令其摸一张牌，然后弃置X张牌（X为你已损失的体力值）。",
}

local chengdong = General(extension, "ld__chenwudongxi", "wu", 4)
local duanxie = fk.CreateActiveSkill{
  name = 'ld__duanxie',
  anim_type = 'offensive',
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = function() return false end,
  target_filter = function(self, to_select, selected)
    return #selected == 0 and to_select ~= Self.id and
      not Fk:currentRoom():getPlayerById(to_select).chained
  end,
  target_num = 1,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])

    if not target.chained then
      target:setChainState(true)
    end

    if not player.chained then
      player:setChainState(true)
    end
  end,
}
local fenming = fk.CreateTriggerSkill{
  name = 'ld__fenming',
  anim_type = 'control',
  events = { fk.EventPhaseStart },
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and
      player.phase == Player.Finish and player.chained
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    for _, p in ipairs(room.alive_players) do
      if p.chained and not p:isNude() then
        local c = room:askForCardChosen(player, p, "he", self.name)
        room:throwCard(c, self.name, p, player)
      end
    end
  end,
}
chengdong:addSkill(duanxie)
chengdong:addSkill(fenming)
Fk:loadTranslationTable{
  ['ld__chenwudongxi'] = '陈武董袭',
  ['ld__duanxie'] = '断绁',
  [':ld__duanxie'] = '出牌阶段限一次，你可以令一名其他角色横置，然后你横置。',
  ['ld__fenming'] = '奋命',
  [':ld__fenming'] = '结束阶段开始时，若你处于连环状态，你可弃置处于连环状态的每名角色的一张牌。',

  ["$ld__duanxie1"] = "区区绳索就想挡住吾等去路？！",
  ["$ld__duanxie2"] = "以身索敌，何惧同伤！",
  ["$ld__fenming1"] = "东吴男儿，岂是贪生怕死之辈？",
  ["$ld__fenming2"] = "不惜性命，也要保主公周全！",
  ["~ld__chenwudongxi"] = "杀身卫主，死而无憾！",
}

local dongzhuo = General(extension, "ld__dongzhuo", "qun", 4)
local hengzheng = fk.CreateTriggerSkill{
  name = 'hengzheng',
  anim_type = "control",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and player.phase == Player.Draw and
      (player.hp == 1 or player:isKongcheng()) and
      table.find(player.room:getOtherPlayers(player), function(p) return not p:isAllNude() end)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    for _, p in ipairs(room:getOtherPlayers(player, true)) do
      if not p:isAllNude() then
        local id = room:askForCardChosen(player, p, "hej", self.name)
        room:obtainCard(player, id, false)
      end
    end
    return true
  end,
}
dongzhuo:addSkill(hengzheng)
local baoling = fk.CreateTriggerSkill{
  name = "baoling",
  relate_to_place = 'm',
  anim_type = "big",
  events = {fk.EventPhaseEnd},
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and player.phase == Player.Play and
      player.general ~= "anjiang" and H.hasGeneral(player, true)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    H.removeGeneral(room, player, true)
    room:changeMaxHp(player, 3)
    room:recover {
      who = player,
      num = 3,
      skillName = self.name
    }
    room:handleAddLoseSkills(player, "benghuai")
  end,
}
dongzhuo:addSkill(baoling)
dongzhuo:addRelatedSkill("benghuai")
Fk:loadTranslationTable{
  ['ld__dongzhuo'] = '董卓',
  ['hengzheng'] = '横征',
  [':hengzheng'] = '摸牌阶段，若你体力值为1或者没有手牌，你可以改为获得所有其他角色区域内各一张牌。',
  ['baoling'] = '暴凌',
  [':baoling'] = '主将技，锁定技，出牌阶段结束时，若此武将已明置且你有副将，则你移除副将，加3点体力上限并回复3点体力，然后获得技能〖崩坏〗。',

  ['$hengzheng1'] = '老夫进京平乱，岂能空手而归？',
  ['$hengzheng2'] = '谁的？都是我的！',
  ['$baoling1'] = '大丈夫，岂能妇人之仁？',
  ['$baoling2'] = '待吾大开杀戒，哈哈哈哈！',
  ['~ld__dongzhuo'] = '为何人人……皆与我为敌？',
}

return extension
