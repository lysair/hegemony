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
  ["#ld__lidian"] = "深明大义",
  ["designer:ld__lidian"] = "KayaK",
  ["illustrator:ld__lidian"] = "张帅",
  ["~ld__lidian"] = "报国杀敌，虽死犹荣……",
}

local zangba = General(extension, "ld__zangba", "wei", 4)
local hengjiang = fk.CreateTriggerSkill{
  name = "hengjiang",
  anim_type = "masochism",
  events = { fk.Damaged },
  can_trigger = function(self, _, target, player, _)
    if target ~= player or not player:hasSkill(self) then return false end
    local current = player.room.current
    return current ~= nil and not current.dead
  end,
  on_use = function(_, _, _, player, data)
    local room = player.room
    local target = room.current
    if target ~= nil and not target.dead then
      room:doIndicate(player.id, {target.id})
      room:addPlayerMark(target, "@hengjiang-turn", math.max(1, #target:getCardIds("e")))
      room:addPlayerMark(target, MarkEnum.MinusMaxCardsInTurn, math.max(1, #target:getCardIds("e")))
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
  on_cost = Util.TrueFunc,
  on_use = function(_, _, _, player, _)
    if player:getHandcardNum() < player.maxHp then
      player:drawCards(player.maxHp - player:getHandcardNum() , hengjiang.name)
    end
  end,
}
hengjiang:addRelatedSkill(hengjiangdelay)
zangba:addSkill(hengjiang)
zangba:addCompanions("hs__zhangliao")
Fk:loadTranslationTable{
  ['ld__zangba'] = '臧霸',
  ["#ld__zangba"] = "节度青徐",
  ["illustrator:ld__zangba"] = "HOOO",
  ["cv:ld__zangba"] = "墨禅",
  ['hengjiang'] = '横江',
  [':hengjiang'] = '当你受到伤害后，你可以令当前回合角色本回合手牌上限-X（X为其装备区内牌数且至少为1）。' ..
    '然后若其本回合弃牌阶段内没有弃牌，你将手牌摸至体力上限。',
  ['@hengjiang-turn'] = '横江',
  ['#hengjiang_delay'] = '横江',

  ['$hengjiang1'] = '霸必奋勇杀敌，一雪夷陵之耻！',
  ['$hengjiang2'] = '江横索寒，阻敌绝境之中！',
  ['~ld__zangba'] = '断刃沉江，负主重托……',
}

local madai = General(extension, "ld__madai", "shu", 4)
local madai_mashu = fk.CreateDistanceSkill{
  name = "heg_madai__mashu",
  frequency = Skill.Compulsory,
  correct_func = function(self, from, to)
    if from:hasSkill(self) then
      return -1
    end
  end,
}
madai:addSkill(madai_mashu)
madai:addSkill("re__qianxi")
madai:addCompanions("hs__machao")
Fk:loadTranslationTable{
  ["ld__madai"] = "马岱",
  ["#ld__madai"] = "临危受命",
  ["designer:ld__madai"] = "凌天翼（韩旭）",
  ["illustrator:ld__madai"] = "Thinking",
  ["heg_madai__mashu"] = "马术",
  [":heg_madai__mashu"] = "锁定技，你与其他角色的距离-1。",
  ["$re__qianxi1"] = "暗影深处，袭敌斩首！",
  ["$re__qianxi2"] = "擒贼先擒王，打蛇打七寸！",
  ["~ld__madai"] = "我怎么会死在这里……",
}

local mifuren = General(extension, "ld__mifuren", "shu", 3, 3, General.Female)
local guixiu = fk.CreateTriggerSkill{
  name = "guixiu",
  anim_type = "drawcard",
  events = {fk.GeneralRevealed, "fk.GeneralRemoved"},
  can_trigger = function(self, event, target, player, data)
    if target ~= player then return false end
    if event == "fk.GeneralRemoved" then
      return player:isWounded() and table.contains(Fk.generals[data]:getSkillNameList(), self.name)
    else
      if player:hasSkill(self) then
        for _, v in pairs(data) do
          if table.contains(Fk.generals[v]:getSkillNameList(), self.name) then return true end
        end
      end
    end
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
    local isDeputy = H.inGeneralSkills(player, self.name)
    if isDeputy then
      H.removeGeneral(room, player, isDeputy == "d")
    end
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
    if player:hasSkill(self) and H.compareKingdomWith(target, player) and not target.dead and data.card.trueName == "slash" and target.phase == Player.Play then
      local events = target.room.logic:getEventsOfScope(GameEvent.UseCard, 1, function(e)
        local use = e.data[1]
        return use.from == target.id
      end, Player.HistoryPhase)
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
  ["#ld__mifuren"] = "乱世沉香",
  ["designer:ld__mifuren"] = "淬毒",
  ["illustrator:ld__mifuren"] = "木美人",

  ["guixiu"] = "闺秀",
  [":guixiu"] = "当你：1.明置此武将牌后，你可摸两张牌：2.移除此武将牌后，你回复1点体力。",
  ["cunsi"] = "存嗣",
  [":cunsi"] = "出牌阶段，你可移除此武将牌并选择一名角色，其获得〖勇决〗。若其不为你，其摸两张牌。", -- canShowInPlay 若此武将牌处于明置状态
  ["yongjue"] = "勇决",
  [":yongjue"] = "当与你势力相同的角色于其出牌阶段内使用【杀】结算后，若此【杀】为其于此阶段内使用的第一张牌，其可获得此【杀】对应的所有实体牌。",

  ["#guixiu-draw"] = "是否发动“闺秀”，摸两张牌",
  ["#guixiu-recover"] = "是否发动“闺秀”，回复1点体力",
  ["#yongjue-invoke"] = "勇决：你可以获得此%arg",

  ["$guixiu1"] = "闺中女子，亦可秀气英拔。",
  ["$guixiu2"] = "闺楼独看花月，倚窗顾影自怜。",
  ["$cunsi1"] = "存汉室之嗣，留汉室之本。",
  ["$cunsi2"] = "一切，便托付将军了……",
  ["$yongjue1"] = "能救一个是一个！",
  ["$yongjue2"] = "扶幼主，成霸业！",
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
    return player:hasSkill(self) and (player == data.from or data.results[player.id])
  end,
  on_cost = function(self, event, target, player, data)
    local choice = player.room:askForChoice(player, { 'yingyang_plus3', 'yingyang_sub3', 'Cancel' }, self.name)
    if choice ~= "Cancel" then
      self.cost_data = choice
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:changePindianNumber(data, player, self.cost_data == "yingyang_plus3" and 3 or -3, self.name)
  end,
}
sunce:addSkill(yingyang)
local hunshang = fk.CreateTriggerSkill{
  name = 'hunshang',
  relate_to_place = 'd',
  events = {fk.EventPhaseStart},
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and
      player.phase == Player.Start and player.hp == 1
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:handleAddLoseSkills(player, 'heg_sunce__yingzi|heg_sunce__yinghun')
    room.logic:getCurrentEvent():findParent(GameEvent.Turn):addCleaner(function()
      room:handleAddLoseSkills(player, '-heg_sunce__yingzi|-heg_sunce__yinghun', nil, true, false)
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
    if player:hasSkill(self) then
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
    return target == player and player:hasSkill(self) and player.phase == Player.Start and player:isWounded()
  end,
  on_cost = function(self, event, target, player, data)
    local to = player.room:askForChoosePlayers(player, table.map(player.room:getOtherPlayers(player, false), Util.IdMapper), 1, 1, "#yinghun-choose:::"..player:getLostHp()..":"..player:getLostHp(), self.name, true)
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
  ["#ld__sunce"] = "江东的小霸王",
  ["designer:ld__sunce"] = "KayaK（韩旭）",
  ["illustrator:ld__sunce"] = "木美人",

  ['yingyang'] = '鹰扬',
  [':yingyang'] = '当你的拼点牌亮出后，你可令其点数+3或-3。',
  ['hunshang'] = '魂殇',
  [':hunshang'] = '副将技，锁定技，此武将牌减少半个阴阳鱼；准备阶段，若你的体力值为1，你拥有技能“英姿”和“英魂”至本回合结束。',
  ['heg_sunce__yingzi'] = '英姿',
  [":heg_sunce__yingzi"] = "锁定技，摸牌阶段，你多摸一张牌；你的手牌上限等于你的体力上限。",
  ["heg_sunce__yinghun"] = "英魂",
  [":heg_sunce__yinghun"] = "准备阶段，你可选择一名其他角色并选择一项：1.令其摸X张牌，然后弃置一张牌；2.令其摸一张牌，然后弃置X张牌（X为你已损失的体力值）。",

  ["yingyang_plus3"] = "令你的拼点牌点数+3",
  ["yingyang_sub3"] = "令你的拼点牌点数-3",

  ["$yingyang1"] = "此战，我必取胜！",
  ["$yingyang2"] = "相斗之趣，吾常胜之。",
  ["$heg_sunce__yingzi1"] = "公瑾，助我决一死战。",
  ["$heg_sunce__yingzi2"] = "尔等看好了！",
  ["$heg_sunce__yinghun1"] = "父亲，助我背水一战。",
  ["$heg_sunce__yinghun2"] = "孙氏英烈，魂佑江东！",
  ["~ld__sunce"] = "内事不决问张昭，外事不决问周瑜……",
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
    return to_select ~= Self.id and
      not Fk:currentRoom():getPlayerById(to_select).chained
  end,
  max_target_num = function (self)
    return math.max(1, Self.maxHp - Self.hp)
  end,
  min_target_num = 1,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    for _, pid in ipairs(effect.tos) do
      local target = room:getPlayerById(pid)
      if not target.chained then
        target:setChainState(true)
      end
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
    return target == player and player:hasSkill(self) and
      player.phase == Player.Finish and player.chained
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    for _, p in ipairs(room:getAlivePlayers()) do
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
  ["#ld__chenwudongxi"] = "壮怀激烈",
  ["designer:ld__chenwudongxi"] = "淬毒",
  ["illustrator:ld__chenwudongxi"] = "地狱许",

  ['ld__duanxie'] = '断绁',
  [':ld__duanxie'] = '出牌阶段限一次，你可以令至多X名其他角色横置，然后你横置（X为你已损失的体力值且至少为1）。',
  ['ld__fenming'] = '奋命',
  [':ld__fenming'] = '结束阶段，若你处于横置状态，你可弃置所有处于横置状态角色的各一张牌。',

  ["$ld__duanxie1"] = "区区绳索就想挡住吾等去路？！",
  ["$ld__duanxie2"] = "以身索敌，何惧同伤！",
  ["$ld__fenming1"] = "东吴男儿，岂是贪生怕死之辈？",
  ["$ld__fenming2"] = "不惜性命，也要保主公周全！",
  ["~ld__chenwudongxi"] = "杀身卫主，死而无憾！",
}

local dongzhuo = General(extension, "ld__dongzhuo", "qun", 4)
local hengzheng = fk.CreateTriggerSkill{
  name = 'hengzheng',
  anim_type = "big", -- 神杀特色
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Draw and
      (player.hp == 1 or player:isKongcheng()) and
      table.find(player.room:getOtherPlayers(player, false), function(p) return not p:isAllNude() end)
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
    return target == player and player:hasSkill(self) and player.phase == Player.Play and
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
  ["#ld__dongzhuo"] = "魔王",
  ["designer:ld__dongzhuo"] = "KayaK（韩旭）",
  ["illustrator:ld__dongzhuo"] = "巴萨小马",

  ['hengzheng'] = '横征',
  [':hengzheng'] = '摸牌阶段，若你体力值为1或者没有手牌，你可改为获得所有其他角色区域内各一张牌。',
  ['baoling'] = '暴凌',
  [':baoling'] = '主将技，锁定技，出牌阶段结束时，若此武将处于明置状态且你有副将，则你移除副将，加3点体力上限并回复3点体力，然后获得〖崩坏〗。',

  ['$hengzheng1'] = '老夫进京平乱，岂能空手而归？',
  ['$hengzheng2'] = '谁的？都是我的！',
  ['$baoling1'] = '大丈夫，岂能妇人之仁？',
  ['$baoling2'] = '待吾大开杀戒，哈哈哈哈！',
  ['~ld__dongzhuo'] = '为何人人……皆与我为敌？',
}

local zhangren = General(extension, "ld__zhangren", "qun", 4)

local chuanxin = fk.CreateTriggerSkill{
  name = "chuanxin",
  anim_type = "offensive",
  events = {fk.DamageCaused},
  can_trigger = function(self, event, target, player, data)
    return target == player and target:hasSkill(self) and player.phase == Player.Play and data.card and table.contains({"slash", "duel"}, data.card.trueName) and not data.chain
      and H.compareExpectedKingdomWith(player, data.to, true) and H.hasGeneral(data.to, true)
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, data, "#chuanxin-ask::" .. data.to.id)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local target = data.to
    local all_choices = {"chuanxin_discard", "removeDeputy"}
    local choices = table.clone(all_choices)
    if #data.to:getCardIds(Player.Equip) == 0 then table.remove(choices, 1) end
    local choice = room:askForChoice(target, choices, self.name, nil, false, all_choices)
    if choice == "removeDeputy" then
      H.removeGeneral(room, target, true)
    else
      target:throwAllCards("e")
      if not target.dead then
        room:loseHp(target, 1, self.name)
      end
    end
    return true
  end,
}

local fengshi = H.CreateArraySummonSkill{
  name = "fengshi",
  array_type = "siege",
}
local fengshiTrigger = fk.CreateTriggerSkill{
  name = "#fengshi_trigger",
  events = {fk.TargetSpecified},
  frequency = Skill.Compulsory,
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return player:hasShownSkill(fengshi) and data.card.trueName == "slash" and H.inSiegeRelation(target, player, player.room:getPlayerById(data.to))
      and #player.room.alive_players > 3 and #player.room:getPlayerById(data.to):getCardIds(Player.Equip) > 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:notifySkillInvoked(player, "fengshi", "control")
    player:broadcastSkillInvoke("fengshi")
    room:askForDiscard(room:getPlayerById(data.to), 1, 1, true, self.name, false, ".|.|.|equip", "#fengshi-discard")
  end
}
fengshi:addRelatedSkill(fengshiTrigger)

zhangren:addSkill(chuanxin)
zhangren:addSkill(fengshi)

Fk:loadTranslationTable{
  ['ld__zhangren'] = '张任',
  ["#ld__zhangren"] = "索命神射",
  ["designer:ld__zhangren"] = "淬毒",
  ["illustrator:ld__zhangren"] = "DH",

  ['chuanxin'] = '穿心',
  [':chuanxin'] = '当你于出牌阶段内使用【杀】或【决斗】对目标角色造成伤害时，若其与你势力不同或你明置此武将牌后与其势力不同，且其有副将，你可防止此伤害，令其选择一项：1. 弃置装备区里的所有牌，失去1点体力；2. 移除副将。',
  ['fengshi'] = '锋矢',
  [':fengshi'] = '阵法技，若你是围攻角色，此围攻关系中的围攻角色使用【杀】指定被围攻角色为目标后，你令被围攻角色角色弃置其装备区里的一张牌。',

  ["chuanxin_discard"] = "弃置装备区里的所有牌，失去1点体力",
  ["removeDeputy"] = "移除副将",
  ["#chuanxin-ask"] = "你可防止此伤害，对 %dest 发动“穿心”",
  ["#fengshi_trigger"] = "锋矢",
  ["#fengshi-discard"] = "锋矢：弃置装备区里的一张牌",

  ['$chuanxin1'] = '一箭穿心，哪里可逃？',
  ['$chuanxin2'] = '穿心之痛，细细品吧，哈哈哈哈！',
  ['$fengshi1'] = '大军压境，还不卸甲受降！',
  ['$fengshi2'] = '放下兵器，饶你不死！',
  ['~ld__zhangren'] = '本将军败于诸葛，无憾……',
}

local lordzhangjiao = General(extension, "ld__lordzhangjiao", "qun", 4)
lordzhangjiao.hidden = true
H.lordGenerals["hs__zhangjiao"] = "ld__lordzhangjiao"

local wuxin = fk.CreateTriggerSkill{
  name = "wuxin",
  anim_type = "control",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Draw
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local num = H.getSameKingdomPlayersNum(room, nil, "qun")
    if player:hasSkill("hongfa") then
      num = num + #player:getPile("heavenly_army")
    end
    room:askForGuanxing(player, room:getNCards(num), nil, {0, 0}, self.name)
  end,
}

local hongfa = fk.CreateTriggerSkill{
  name = "hongfa",
  anim_type = "support",
  events = {fk.GeneralRevealed},
  frequency = Skill.Compulsory,
  derived_piles = "heavenly_army",
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self, true) then
      for _, v in pairs(data) do
        if table.contains(Fk.generals[v]:getSkillNameList(), self.name) then return true end
      end
    end 
  end,
  on_use = function(self, event, target, player, data)
    player:broadcastSkillInvoke(self.name, 1)
    player.room:notifySkillInvoked(player, self.name, "support")
  end,

  refresh_events = {fk.EventAcquireSkill, fk.EventLoseSkill, fk.Deathed, fk.GeneralRevealed, fk.GeneralHidden},
  can_refresh = function(self, event, target, player, data)
    if player ~= target then return false end
    if event == fk.Deathed then return player:hasSkill(self, true, true)
    elseif event == fk.EventAcquireSkill or event == fk.EventLoseSkill then return data == self
    else return true end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local players = room.alive_players
    local godzhangjiaos = table.filter(players, function(p) return p:hasShownSkill(self) end)
    local hongfa_map = {}
    for _, p in ipairs(players) do
      local will_attach = false
      for _, godzhangjiao in ipairs(godzhangjiaos) do
        if H.compareKingdomWith(godzhangjiao, p) then
          will_attach = true
          break
        end
      end
      hongfa_map[p] = will_attach
    end
    for p, v in pairs(hongfa_map) do
      if v ~= p:hasSkill("heavenly_army_skill&") then
        room:handleAddLoseSkills(p, v and "heavenly_army_skill&" or "-heavenly_army_skill&", nil, false, true)
      end
    end
  end,
}

local heavenly_army_skill = fk.CreateViewAsSkill{
  name = "heavenly_army_skill&",
  anim_type = "offensive",
  pattern = "slash",
  prompt = "#heavenly_army_skill-active",
  interaction = function()
    local cards = {}
    local kingdom = Self.kingdom
    for _, p in ipairs(Fk:currentRoom().alive_players) do
      if string.find(p.general, "lord") and p:hasSkill("hongfa") and p.kingdom == kingdom and #p:getPile("heavenly_army") > 0 then
        cards = table.map(p:getPile("heavenly_army"), function(id) return Fk:getCardById(id):toLogString() end)
        break
      end
    end
    if #cards == 0 then return end
    return UI.ComboBox {choices = cards} -- FIXME: expand_pile
  end,
  view_as = function(self, cards)
    if self.interaction.data == nil then return end
    local card = Fk:cloneCard("slash")
    card.skillName = self.name
    return card
  end,
  before_use = function(self, player, use)
    local room = player.room
    local cards = {}
    local kingdom = player.kingdom
    for _, p in ipairs(room.alive_players) do
      if string.find(p.general, "lord") and p:hasSkill("hongfa") and p.kingdom == kingdom and #p:getPile("heavenly_army") > 0 then
        cards = p:getPile("heavenly_army")
        break
      end
    end
    local card
    for _, id in ipairs(cards) do
      if Fk:getCardById(id):toLogString() == self.interaction.data then
        card = id
        break
      end
    end
    use.card:addSubcard(card)
    player:broadcastSkillInvoke("hongfa", math.random(4, 5))
    return
  end,
  enabled_at_play = function(self, player)
    for _, p in ipairs(Fk:currentRoom().alive_players) do
      if string.find(p.general, "lord") and p:hasSkill("hongfa") and p.kingdom == player.kingdom and #p:getPile("heavenly_army") > 0 then
        return true
      end
    end
  end,
  enabled_at_response = function(self, player)
    for _, p in ipairs(Fk:currentRoom().alive_players) do
      if string.find(p.general, "lord") and p:hasSkill("hongfa") and p.kingdom == player.kingdom and #p:getPile("heavenly_army") > 0 then
        return true
      end
    end
  end,
}
local heavenly_army_skill_trig = fk.CreateTriggerSkill{
  name = "#heavenly_army_skill_trig",
  mute = true,
  events = {fk.EventPhaseStart, fk.PreHpLost},
  can_trigger = function(self, event, target, player, data)
    if not (target == player and player:hasSkill(self) and player:hasSkill("hongfa")) then return end
    if event == fk.EventPhaseStart then
      return player.phase == Player.Start and #player:getPile("heavenly_army") == 0
    else
      return #player:getPile("heavenly_army") > 0
    end
  end,
  on_cost = function(self, event, target, player, data)
    if event == fk.EventPhaseStart then
      return true
    else
      local card = player.room:askForCard(player, 1, 1, false, self.name, true, ".|.|.|heavenly_army", "#heavenly_army_skill-ask", "heavenly_army")
      if #card > 0 then
        self.cost_data = card[1]
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.EventPhaseStart then
      player:broadcastSkillInvoke("hongfa", math.random(2, 3))
      room:notifySkillInvoked(player, "heavenly_army_skill&", "control")
      player:addToPile("heavenly_army", room:getNCards(H.getSameKingdomPlayersNum(room, nil, "qun") + #player:getPile("heavenly_army")), true, self.name)
    else
      player:broadcastSkillInvoke("hongfa", 6)
      room:notifySkillInvoked(player, "heavenly_army_skill&", "defensive")
      room:moveCardTo(self.cost_data, Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile, self.name, "heavenly_army", true, player.id)
      return true
    end
  end,
}
heavenly_army_skill:addRelatedSkill(heavenly_army_skill_trig)
Fk:addSkill(heavenly_army_skill)

local wendao = fk.CreateActiveSkill{
  name = "wendao",
  anim_type = "support",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = function(self, to_select, selected)
    if #selected == 0 then
      local card = Fk:getCardById(to_select)
      return card.color == Card.Red and card.name ~= "peace_spell" and not Self:prohibitDiscard(card)
    end
  end,
  target_filter = Util.FalseFunc,
  target_num = 0,
  card_num = 1,
  on_use = function(self, room, effect)
    local from = room:getPlayerById(effect.from)
    room:throwCard(effect.cards, self.name, from, from)
    local card = room:getCardsFromPileByRule("peace_spell", 1, "discardPile")
    if #card > 0 then
      room:obtainCard(from, card[1], false, fk.ReasonPrey)
    else
      for _, p in ipairs(room.alive_players) do
        for _, id in ipairs(p:getCardIds(Player.Equip)) do
          if Fk:getCardById(id).name == "peace_spell" then
            room:obtainCard(from, id, false, fk.ReasonPrey)
            return false
          end
        end
      end
    end
  end,
}

lordzhangjiao:addSkill(wuxin)
lordzhangjiao:addSkill(hongfa)
lordzhangjiao:addSkill(wendao)

Fk:loadTranslationTable{
  ["ld__lordzhangjiao"] = "君张角",
  ["#ld__lordzhangjiao"] = "时代的先驱",
  ["designer:ld__lordzhangjiao"] = "韩旭",
  ["illustrator:ld__lordzhangjiao"] = "青骑士",

  ["wuxin"] = "悟心",
  [":wuxin"] = "摸牌阶段开始时，你可观看牌堆顶的X张牌（X为群势力角色数）并可改变这些牌的顺序。",
  ["hongfa"] = "弘法",
  [":hongfa"] = "<b><font color='goldenrod'>君主技</font></b>，你拥有“黄巾天兵符”。<br>#<b>黄巾天兵符</b>：<br>" ..
          "①准备阶段，若没有“天兵”，你将牌堆顶的X张牌置于武将牌上（称为“天兵”）（X为群势力角色数）。<br>" ..
          "②每有一张“天兵”，你执行的效果中的“群势力角色数”便+1。<br>" ..
          "③当你的失去体力结算开始前，若有“天兵”，你可将一张“天兵”置入弃牌堆，终止此失去体力流程。<br>" ..
          "④与你势力相同的角色可将一张“天兵”当【杀】使用或打出。",
  ["wendao"] = "问道",
  [":wendao"] = "出牌阶段限一次，你可弃置一张不为【太平要术】的红色牌，你获得弃牌堆里或一名角色的装备区里的【太平要术】。",
  ["heavenly_army"] = "天兵",

  ["heavenly_army_skill&"] = "天兵符",
  [":heavenly_army_skill&"] = "你可将一张“天兵”当【杀】使用或打出",
  ["#heavenly_army_skill-active"] = "黄巾天兵符：你可将一张“天兵”当【杀】使用或打出",
  ["#heavenly_army_skill_trig"] = "黄巾天兵符",
  ["#heavenly_army_skill-ask"] = "黄巾天兵符：你可移去一张“天兵”，防止此次失去体力",

  ["$wuxin1"] = "冀悟迷惑之心。",
  ["$wuxin2"] = "吾已明此救世之术矣。",
  ["$hongfa1"] = "苍天已死，黄天当立！", -- 亮将
  ["$hongfa2"] = "汝等安心，吾乃大贤良师矣。", -- 拿天兵
  ["$hongfa3"] = "此法可助汝等脱离苦海。", -- 拿天兵
  ["$hongfa4"] = "此乃天将天兵，尔等妖孽看着！", -- 杀
  ["$hongfa5"] = "且作一法，召唤神力！", -- 杀
  ["$hongfa6"] = "吾有天神护体！", -- 防止失去体力
  ["$wendao1"] = "诚心求天地之道，救世之法。",
  ["$wendao2"] = "求太平之法以安天下。",
  ["~ld__lordzhangjiao"] = "天，真要灭我……",
}

local extension_card = Package("momentum_cards", Package.CardPack)
extension_card.extensionName = "hegemony"
extension_card.game_modes_whitelist = { 'nos_heg_mode', 'new_heg_mode' }

local peaceSpellSkill = fk.CreateTriggerSkill{
  name = "#peace_spell_skill",
  attached_equip = "peace_spell",
  frequency = Skill.Compulsory,
  events = {fk.DamageInflicted},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.damageType ~= fk.NormalDamage
  end,
  on_use = function(self, event, target, player, data)
    player.room:notifySkillInvoked(player, "peace_spell", "defensive")
    return true
  end,
}
local peace_spell_maxcards = fk.CreateMaxCardsSkill{
  name = "#peace_spell_maxcards",
  correct_func = function(self, player)
    if player:hasSkill("#peace_spell_skill") then
      if player.kingdom == "unknown" then
        return 1
      else
        local num = H.getSameKingdomPlayersNum(Fk:currentRoom(), player)
        return (num or 0) + #player:getPile("heavenly_army")
      end
    end
  end,
}
peaceSpellSkill:addRelatedSkill(peace_spell_maxcards)
Fk:addSkill(peaceSpellSkill)
local peace_spell = fk.CreateArmor{
  name = "peace_spell",
  suit = Card.Heart,
  number = 3,
  equip_skill = peaceSpellSkill,
  on_uninstall = function(self, room, player)
    Armor.onUninstall(self, room, player)
    if not player.dead and self.equip_skill:isEffectable(player) then
      room:notifySkillInvoked(player, "peace_spell", "drawcard")
      player:drawCards(2, self.name)
      if player.hp > 1 then
        room:loseHp(player, 1, self.name)
      end
    end
  end,
}
H.addCardToConvertCards(peace_spell, "jingfan")
extension_card:addCard(peace_spell)

Fk:loadTranslationTable{
  ["momentum_cards"] = "君临天下·势卡牌",
}
Fk:loadTranslationTable{
  ["peace_spell"] = "太平要术",
  [":peace_spell"] = "装备牌·防具<br /><b>防具技能</b>：锁定技，①当你受到属性伤害时，你防止此伤害。②你的手牌上限+X（X为与你势力相同的角色数）。③当你失去装备区里的【太平要术】后，你摸两张牌，然后若你的体力值大于1，你失去1点体力。",
}

return {
  extension,
  extension_card,
}
