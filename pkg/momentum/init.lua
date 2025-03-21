local H = require "packages/hegemony/util"
local extension = Package:new("momentum")
extension.extensionName = "hegemony"
extension.game_modes_whitelist = { 'nos_heg_mode', 'new_heg_mode' }

extension:loadSkillSkelsByPath("./packages/hegemony/pkg/momentum/skills")

Fk:loadTranslationTable{
  ["momentum"] = "君临天下·势",
}

local lidian = General:new(extension, "ld__lidian", "wei", 3)
lidian:addSkills{"xunxun", "wangxi"}
lidian:addCompanions("hs__yuejin")
Fk:loadTranslationTable{
  ["ld__lidian"] = "李典",
  ["#ld__lidian"] = "深明大义",
  ["designer:ld__lidian"] = "KayaK",
  ["illustrator:ld__lidian"] = "张帅",
  ["~ld__lidian"] = "报国杀敌，虽死犹荣……",
}

local zangba = General:new(extension, "ld__zangba", "wei", 4)
zangba:addSkill("hengjiang")
zangba:addCompanions("hs__zhangliao")
Fk:loadTranslationTable{
  ['ld__zangba'] = '臧霸',
  ["#ld__zangba"] = "节度青徐",
  ["illustrator:ld__zangba"] = "HOOO",
  ["cv:ld__zangba"] = "墨禅",
  ['~ld__zangba'] = '断刃沉江，负主重托……',
}

local madai = General:new(extension, "ld__madai", "shu", 4)
madai:addSkills{"heg_madai__mashu", "re__qianxi"}
madai:addCompanions("hs__machao")
Fk:loadTranslationTable{
  ["ld__madai"] = "马岱",
  ["#ld__madai"] = "临危受命",
  ["designer:ld__madai"] = "凌天翼（韩旭）",
  ["illustrator:ld__madai"] = "Thinking",
  ["~ld__madai"] = "我怎么会死在这里……",
}

local mifuren = General:new(extension, "ld__mifuren", "shu", 3, 3, General.Female)
mifuren:addSkills{"guixiu", "cunsi", "yongjue"}
Fk:loadTranslationTable{
  ['ld__mifuren'] = '糜夫人',
  ["#ld__mifuren"] = "乱世沉香",
  ["designer:ld__mifuren"] = "淬毒",
  ["illustrator:ld__mifuren"] = "木美人",
  ["~ld__mifuren"] = "阿斗被救，妾身再无牵挂…",
}

local sunce = General:new(extension, "ld__sunce", "wu", 4)
sunce.deputyMaxHpAdjustedValue = -1
sunce:addCompanions { "hs__zhouyu", "hs__taishici", "hs__daqiao" }
sunce:addSkills{"jiang", "yingyang", "hunshang"}
sunce:addRelatedSkills{"heg_sunce__yingzi", "heg_sunce__yinghun"}
Fk:loadTranslationTable{
  ['ld__sunce'] = '孙策',
  ["#ld__sunce"] = "江东的小霸王",
  ["designer:ld__sunce"] = "KayaK（韩旭）",
  ["illustrator:ld__sunce"] = "木美人",

  ['heg_sunce__yingzi'] = '英姿',
  [":heg_sunce__yingzi"] = "锁定技，摸牌阶段，你多摸一张牌；你的手牌上限等于你的体力上限。",


  ["$heg_sunce__yingzi1"] = "公瑾，助我决一死战。",
  ["$heg_sunce__yingzi2"] = "尔等看好了！",
  ["~ld__sunce"] = "内事不决问张昭，外事不决问周瑜……",
}

local chengdong = General:new(extension, "ld__chenwudongxi", "wu", 4)

chengdong:addSkills{"duanxie", "fenming"}
Fk:loadTranslationTable{
  ['ld__chenwudongxi'] = '陈武董袭',
  ["#ld__chenwudongxi"] = "壮怀激烈",
  ["designer:ld__chenwudongxi"] = "淬毒",
  ["illustrator:ld__chenwudongxi"] = "地狱许",
  ["~ld__chenwudongxi"] = "杀身卫主，死而无憾！",
}
--[[
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

Fk:loadTranslationTable{
  ["momentum_cards"] = "君临天下·势卡牌",
}

--]]
return extension
  --extension_card,

