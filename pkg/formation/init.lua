local extension = Package:new("formation")
extension.extensionName = "hegemony"
extension.game_modes_whitelist = { 'nos_heg_mode', 'new_heg_mode' }

local H = require "packages/hegemony/util"
local U = require "packages/utility/utility"

extension:loadSkillSkelsByPath("./packages/hegemony/pkg/formation/skills")

Fk:loadTranslationTable{
  ["formation"] = "君临天下·阵",
  ["ld"] = "君临",
}

local dengai = General:new(extension, "ld__dengai", "wei", 4)
dengai.mainMaxHpAdjustedValue = -1
dengai:addSkills{"ld__tuntian", "ld__jixi", "ziliang"}
Fk:loadTranslationTable{
  ["ld__dengai"] = "邓艾",
  ["#ld__dengai"] = "矫然的壮士",
  ["designer:ld__dengai"] = "KayaK（淬毒）",
  ["illustrator:ld__dengai"] = "Amo",
  ["~ld__dengai"] = "君不知臣，臣不知君。罢了……罢了！",
}

local caohong = General:new(extension, "ld__caohong", "wei", 4)
caohong:addSkills{"ld__huyuan", "heyi"}
caohong:addRelatedSkill("feiying")
caohong:addCompanions("hs__caoren")
Fk:loadTranslationTable{
  ["ld__caohong"] = "曹洪",
  ["#ld__caohong"] = "魏之福将",
  ["designer:ld__caohong"] = "韩旭（淬毒）",
  ["illustrator:ld__caohong"] = "YellowKiss",
  ["cv:ld__caohong"] = "绯川陵彦",
  ["~ld__caohong"] = "曹公，可安好…",
}
--[[
local jiangwei = General(extension, "ld__jiangwei", "shu", 4)
jiangwei:addCompanions("hs__zhugeliang")
jiangwei.deputyMaxHpAdjustedValue = -1
local tianfu = H.CreateArraySummonSkill{
  name = "tianfu",
  array_type = "formation",
  relate_to_place = "m",
}
local tianfuTrig = fk.CreateTriggerSkill{ -- FIXME
  name = '#tianfu_trigger',
  visible = false,
  frequency = Skill.Compulsory,
  refresh_events = {fk.TurnStart, fk.GeneralRevealed, fk.EventAcquireSkill, "fk.RemoveStateChanged", fk.EventLoseSkill, fk.GeneralHidden},
  can_refresh = function(self, event, target, player, data)
    if event == fk.EventLoseSkill then return data == tianfu
    elseif event == fk.GeneralHidden then return player == target
    else return player:hasShownSkill(self.name, true, true) end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local ret = H.inFormationRelation(room.current, player) and #room.alive_players > 3 and player:hasSkill(self)
    room:handleAddLoseSkills(player, ret and 'ld__kanpo' or "-ld__kanpo", nil, false, true)
  end,
}
tianfu:addRelatedSkill(tianfuTrig)
local kanpo = fk.CreateViewAsSkill{
  name = "ld__kanpo",
  anim_type = "control",
  pattern = "nullification",
  prompt = "#kanpo",
  card_filter = function(self, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).color == Card.Black and Fk:currentRoom():getCardArea(to_select) == Player.Hand
  end,
  view_as = function(self, cards)
    if #cards ~= 1 then return end
    local card = Fk:cloneCard("nullification")
    card.skillName = self.name
    card:addSubcard(cards[1])
    return card
  end,
}

local yizhi = fk.CreateTriggerSkill{
  name = "yizhi",
  refresh_events = {fk.GeneralRevealed, fk.GeneralHidden, fk.EventLoseSkill},
  relate_to_place = "d",
  frequency = Skill.Compulsory,
  can_refresh = function(self, event, target, player, data)
    return target == player
  end,
  on_refresh = function(self, event, target, player, data)
    local has_head_guanxing = false
    for _, sname in ipairs(Fk.generals[player.general]:getSkillNameList()) do
      if Fk.skills[sname].trueName == "guanxing" then
        has_head_guanxing = true
        break
      end
    end
    local ret = player:hasShownSkill(self.name) and not (has_head_guanxing and player.general ~= "anjiang")
    player.room:handleAddLoseSkills(player, ret and "ld__guanxing" or "-ld__guanxing", nil, false, true)
  end
}
local guanxing = fk.CreateTriggerSkill{
  name = "ld__guanxing",
  anim_type = "control",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and
      player.phase == Player.Start
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:askForGuanxing(player, room:getNCards(math.min(5, #room.alive_players)))
  end,
}

jiangwei:addSkill("tiaoxin")
jiangwei:addSkill(tianfu)
jiangwei:addRelatedSkill(kanpo)
jiangwei:addSkill(yizhi)
jiangwei:addRelatedSkill(guanxing)

Fk:loadTranslationTable{
  ["ld__jiangwei"] = "姜维",
  ["#ld__jiangwei"] = "龙的衣钵",
  ["designer:ld__jiangwei"] = "KayaK（淬毒）",
  ["illustrator:ld__jiangwei"] = "木美人",

  ["tianfu"] = "天覆",
  [":tianfu"] = "主将技，阵法技，你于与你处于同一<a href='heg_formation'>队列</a>的角色的回合内拥有〖看破〗。",
  ["yizhi"] = "遗志",
  [":yizhi"] = "副将技，此武将牌上单独的阴阳鱼个数-1；若你的主将的武将牌：有〖观星〗且处于明置状态，此〖观星〗改为固定观看五张牌；没有〖观星〗或处于暗置状态，你拥有〖观星〗。",

  ["ld__kanpo"] = "看破",
  [":ld__kanpo"] = "你可将一张黑色手牌当【无懈可击】使用。",
  ["ld__guanxing"] = "观星",
  [":ld__guanxing"] = "准备阶段，你可将牌堆顶的X张牌（X为角色数且至多为5}）扣置入处理区（对你可见），你将其中任意数量的牌置于牌堆顶，将其余的牌置于牌堆底。",

  ["$tiaoxin_ld__jiangwei1"] = "小小娃娃，乳臭未干。",
  ["$tiaoxin_ld__jiangwei2"] = "快滚回去，叫你主将出来！",
  ["$ld__kanpo1"] = "丞相已教我识得此计。",
  ["$ld__kanpo2"] = "哼！有破绽！",
  ["$ld__guanxing1"] = "天文地理，丞相所教，维铭记于心。",
  ["$ld__guanxing2"] = "哪怕只有一线生机，我也不会放弃！",
  ["~ld__jiangwei"] = "臣等正欲死战，陛下何故先降？",
}
--]]
local jiangfei = General:new(extension, "ld__jiangwanfeiyi", "shu", 3)
jiangfei:addSkills{"shengxi", "shoucheng"}
jiangfei:addCompanions("hs__zhugeliang")

Fk:loadTranslationTable{
  ["ld__jiangwanfeiyi"] = "蒋琬费祎",
  ["#ld__jiangwanfeiyi"] = "社稷股肱",
  ["designer:ld__jiangwanfeiyi"] = "淬毒",
  ["illustrator:ld__jiangwanfeiyi"] = "cometrue",
  ["~ld__jiangwanfeiyi"] = "墨守成规，终为其害啊……",
}

local xusheng = General:new(extension, "ld__xusheng", "wu", 4)
xusheng:addSkill("yicheng")
xusheng:addCompanions("hs__dingfeng")

Fk:loadTranslationTable{
  ["ld__xusheng"] = "徐盛",
  ["#ld__xusheng"] = "江东的铁壁",
  ["designer:ld__xusheng"] = "淬毒",
  ["illustrator:ld__xusheng"] = "天信",
  ["~ld__xusheng"] = "可怜一身胆略，尽随一抔黄土……",
}

local jiangqin = General:new(extension, "ld__jiangqin", "wu", 4)
--[[
local niaoxiang = H.CreateArraySummonSkill{
  name = "niaoxiang",
  array_type = "siege",
}
local niaoxiangTrigger = fk.CreateTriggerSkill{
  name = "#niaoxiang_trigger",
  visible = false,
  events = {fk.TargetSpecified},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and data.card.trueName == "slash" and H.inSiegeRelation(target, player, player.room:getPlayerById(data.to)) 
      and #player.room.alive_players > 3 and H.hasShownSkill(player,niaoxiang)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data.fixedResponseTimes = data.fixedResponseTimes or {}
    data.fixedResponseTimes["jink"] = 2
  end
}
niaoxiang:addRelatedSkill(niaoxiangTrigger)
--]]
jiangqin:addSkills{"shangyi"} -- {"niaoxiang", "shangyi"}
jiangqin:addCompanions("hs__zhoutai")
Fk:loadTranslationTable{
  ["ld__jiangqin"] = "蒋钦",
  ["#ld__jiangqin"] = "祁奚之器",
  ["designer:ld__jiangqin"] = "淬毒",
  ["illustrator:ld__jiangqin"] = "天空之城",
  ["cv:ld__jiangqin"] = "小六",

  ["niaoxiang"] = "鸟翔",
  [":niaoxiang"] = "阵法技，若你是围攻角色，此围攻关系中的围攻角色使用【杀】指定被围攻角色为目标后，你令被围攻角色响应此【杀】的方式改为依次使用两张【闪】。",
  ["#niaoxiang_trigger"] = "鸟翔",

  ["$niaoxiang1"] = "此战，必是有死无生！",
  ["$niaoxiang2"] = "抢占先机，占尽优势！",
  ["~ld__jiangqin"] = "竟破我阵法…",
}

General:new(extension, "ld__yuji", "qun", 3):addSkill("qianhuan")
Fk:loadTranslationTable{
  ["ld__yuji"] = "于吉",
  ["#ld__yuji"] = "魂绕左右",
  ["designer:ld__yuji"] = "淬毒",
  ["illustrator:ld__yuji"] = "G.G.G.",
  ["~ld__yuji"] = "幻化之物，终是算不得真呐。",
}

General:new(extension, "ld__hetaihou", "qun", 3, 3, General.Female):addSkills{"zhendu", "qiluan"}
Fk:loadTranslationTable{
  ["ld__hetaihou"] = "何太后",
  ["#ld__hetaihou"] = "弄权之蛇蝎",
  ["cv:ld__hetaihou"] = "水原",
  ["illustrator:ld__hetaihou"] = "KayaK&木美人",
  ["designer:ld__hetaihou"] = "淬毒",
  ["~ld__hetaihou"] = "你们男人造的孽，非要说什么红颜祸水……",
}
--[[
local lordliubei = General(extension, "ld__lordliubei", "shu", 4)
lordliubei.hidden = true
H.lordGenerals["hs__liubei"] = "ld__lordliubei"

local zhangwu = fk.CreateTriggerSkill{
  name = "zhangwu",
  anim_type = 'drawcard',
  events = {fk.BeforeCardsMove, fk.AfterCardsMove},
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self) then return false end
    if event == fk.BeforeCardsMove then
      for _, move in ipairs(data) do
        if move.from == player.id and (move.to ~= player.id or (move.toArea ~= Card.PlayerEquip and move.toArea ~= Card.PlayerHand)) and
          (move.moveReason ~= fk.ReasonUse or player.room.logic:getCurrentEvent():findParent(GameEvent.UseCard).data[1].card.name ~= "dragon_phoenix") then
          for _, info in ipairs(move.moveInfo) do
            if (info.fromArea == Card.PlayerEquip or info.fromArea == Card.PlayerHand) and Fk:getCardById(info.cardId).name == "dragon_phoenix" then
              return true
            end
          end
        end
      end
    else
      for _, move in ipairs(data) do
        if move.to ~= player.id and (move.toArea == Card.PlayerEquip or move.toArea == Card.DiscardPile) then
          for _, info in ipairs(move.moveInfo) do
            if Fk:getCardById(info.cardId).name == "dragon_phoenix" then
              return true
            end
          end
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local ids = {}
    if event == fk.BeforeCardsMove then
      local mirror_moves = {}
      for _, move in ipairs(data) do
        if move.from == player.id and (move.to ~= player.id or (move.toArea ~= Card.PlayerEquip and move.toArea ~= Card.PlayerHand)) and
          (move.moveReason ~= fk.ReasonUse or player.room.logic:getCurrentEvent():findParent(GameEvent.UseCard).data[1].card.name ~= "dragon_phoenix") then
          local move_info = {}
          local mirror_info = {}
          for _, info in ipairs(move.moveInfo) do
            local id = info.cardId
            if (info.fromArea == Card.PlayerEquip or info.fromArea == Card.PlayerHand) and Fk:getCardById(info.cardId).name == "dragon_phoenix" then
              table.insert(ids, id)
              table.insert(mirror_info, info)
            else
              table.insert(move_info, info)
            end
          end
          if #mirror_info > 0 then
            move.moveInfo = move_info
            local mirror_move = table.clone(move)
            mirror_move.to = nil
            mirror_move.toArea = Card.DrawPile
            mirror_move.drawPilePosition = -1
            mirror_move.moveInfo = mirror_info
            table.insert(mirror_moves, mirror_move)
          end
        end
      end
      player:showCards(ids)
      table.insertTable(data, mirror_moves)
      if not player.dead then
        player:drawCards(2, self.name) -- 大摆特摆
      end
    else
      for _, move in ipairs(data) do
        if move.to ~= player.id and (move.toArea == Card.PlayerEquip or move.toArea == Card.DiscardPile) then
          for _, info in ipairs(move.moveInfo) do
            if Fk:getCardById(info.cardId).name == "dragon_phoenix" then
              table.insert(ids, info.cardId)
            end
          end
        end
      end
      player.room:obtainCard(player, ids, true, fk.ReasonPrey)
    end
  end,
}

local shouyue = fk.CreateTriggerSkill{
  name = "shouyue",
  anim_type = "support",
  events = {fk.GeneralRevealed},
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self, true) then
      for _, v in pairs(data) do
        if table.contains(Fk.generals[v]:getSkillNameList(), self.name) then return true end
      end
    end
  end,
}

local jizhao = fk.CreateTriggerSkill{
  name = "jizhao",
  anim_type = "support",
  frequency = Skill.Limited,
  events = {fk.AskForPeaches},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.dying and player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if player:getHandcardNum() < player.maxHp then
      room:drawCards(player, player.maxHp - player:getHandcardNum(), self.name)
    end
    if player.hp < 2 and not player.dead then
      room:recover({
        who = player,
        num = 2 - player.hp,
        recoverBy = player,
        skillName = self.name,
      })
    end
    room:handleAddLoseSkills(player, "-shouyue|ex__rende", nil) -- 乐
  end,
}

lordliubei:addSkill(zhangwu)
lordliubei:addSkill(shouyue)
lordliubei:addSkill(jizhao)
lordliubei:addRelatedSkill("ex__rende")

Fk:loadTranslationTable{
  ["ld__lordliubei"] = "君刘备",
  ["#ld__lordliubei"] = "龙横蜀汉",
  ["designer:ld__lordliubei"] = "韩旭",
  ["illustrator:ld__lordliubei"] = "LiuHeng",

  ["zhangwu"] = "章武",
  [":zhangwu"] = "锁定技，①当【飞龙夺凤】移至弃牌堆或其他角色的装备区后，你获得此【飞龙夺凤】；②当你非因使用【飞龙夺凤】而失去【飞龙夺凤】前，你展示此【飞龙夺凤】，将此【飞龙夺凤】的此次移动的目标区域改为牌堆底，摸两张牌。",
  ["shouyue"] = "授钺",
  [":shouyue"] = "<b><font color='goldenrod'>君主技</font></b>，你拥有“五虎将大旗”。<br>" ..
  "#<b>五虎将大旗</b>：存活的蜀势力角色拥有的〖武圣〗、〖咆哮〗、〖龙胆〗、〖铁骑〗和〖烈弓〗分别按以下规则修改：<br>" ..
  "〖武圣〗：将“红色牌”改为“任意牌”；<br>"..
  "〖咆哮〗：增加描述“当你使用杀指定目标后，此【杀】无视其他角色的防具”；<br>"..
  "〖龙胆〗：增加描述“当你使用/打出因〖龙胆〗转化的普【杀】或【闪】时，你摸一张牌”；<br>"..
  "〖铁骑〗：将“一张明置的武将牌的非锁定技失效”改为“所有明置的武将牌的非锁定技失效”；<br>"..
  "〖烈弓〗：增加描述“你的攻击范围+1”。",
  ["jizhao"] = "激诏",
  [":jizhao"] = "限定技，当你处于濒死状态时，你可将手牌摸至X张（X为你的体力上限），将体力回复至2点，失去〖授钺〗并获得〖仁德〗。",

  ["$shouyue"] = "布德而昭仁，见旗如见朕!",
  ["$zhangwu1"] = "遁剑归一，有凤来仪。",
  ["$zhangwu2"] = "剑气化龙，听朕雷动！",
  ["$jizhao1"] = "仇未报，汉未兴，朕志犹在！",
  ["$jizhao2"] = "王业不偏安，起师再兴汉！",
  ["$ex__rende_ld__lordliubei1"] = "勿以恶小而为之，勿以善小而不为。",
  ["$ex__rende_ld__lordliubei2"] = "君才十倍于丕，必能安国成事。",
  ["~ld__lordliubei"] = "若嗣子可辅，辅之。如其不才，君可自取……",
}
--]]
return extension
