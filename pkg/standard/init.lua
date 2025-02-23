local extension = Package:new("hegemony_standard")
extension.extensionName = "hegemony"
extension.game_modes_whitelist = { 'nos_heg_mode', 'new_heg_mode' }

local heg_mode = require "packages.hegemony.new_hegemony_mode"
extension:addGameMode(heg_mode)
local nos_heg = require "packages.hegemony.nos_hegemony_mode"
extension:addGameMode(nos_heg)

extension:loadSkillSkels(require("packages.hegemony.pkg.standard.skills"))

local H = require "packages/hegemony/util"

Fk:loadTranslationTable{
  ["hegemony_standard"] = "国战标准版",
  ["hs"] = "国标",
}

local caocao = General:new(extension, "hs__caocao", "wei", 4)
caocao:addSkill("jianxiong")
caocao:addCompanions{"hs__dianwei", "hs__xuchu"}
Fk:loadTranslationTable{
  ["hs__caocao"] = "曹操",
  ["#hs__caocao"] = "魏武帝",
  -- ["illustrator:hs__caocao"] = "KayaK",
  ["~hs__caocao"] = "霸业未成，未成啊……",
}

General:new(extension, "hs__simayi", "wei", 3):addSkills{"fankui", "ex__guicai"} -- 手杀
Fk:loadTranslationTable{
  ["hs__simayi"] = "司马懿",
  ["#hs__simayi"] = "狼顾之鬼",
  ["illustrator:hs__simayi"] = "木美人",
  ["~hs__simayi"] = "我的气数就到这里了吗？",
}

local xiahoudun = General:new(extension, "hs__xiahoudun", "wei", 4)
xiahoudun:addSkill("hs__ganglie")
xiahoudun:addCompanions("hs__xiahouyuan")
Fk:loadTranslationTable{
  ["hs__xiahoudun"] = "夏侯惇",
  ["#hs__xiahoudun"] = "独眼的罗刹",
  ["illustrator:hs__xiahoudun"] = "DH",
  ["~hs__xiahoudun"] = "诸多败绩，有负丞相重托……",
}

General:new(extension, "hs__zhangliao", "wei", 4):addSkill("ex__tuxi") -- 手杀
Fk:loadTranslationTable{
  ["hs__zhangliao"] = "张辽",
  ["#zhangliao"] = "前将军",
  ["illustrator:zhangliao"] = "张帅",
  ["~hs__zhangliao"] = "被敌人占了先机……呃……",
}

General:new(extension, "hs__xuchu", "wei", 4):addSkill("hs__luoyi")
Fk:loadTranslationTable{
  ["hs__xuchu"] = "许褚",
  ["#xuchu"] = "虎痴",
  ["illustrator:xuchu"] = "KayaK",
  ["~hs__xuchu"] = "冷，好冷啊……",
}

General:new(extension, "hs__guojia", "wei", 3):addSkills{"hs__yiji", "tiandu"}
Fk:loadTranslationTable{
  ["hs__guojia"] = "郭嘉",
  ["#hs__guojia"] = "早终的先知",
  ["illustrator:hs__guojia"] = "绘聚艺堂",
  ["~hs__guojia"] = "咳，咳……",
}

local zhenji = General:new(extension, "hs__zhenji", "wei", 3, 3, General.Female)
zhenji:addSkills{"hs__luoshen", "qingguo"}
zhenji:addCompanions("hs__caopi")

Fk:loadTranslationTable{
  ["hs__zhenji"] = "甄姬",
  ["#hs__zhenji"] = "薄幸的美人",
  ["illustrator:hs__zhenji"] = "DH",
  ["~hs__zhenji"] = "悼良会之永绝兮，哀一逝而异乡。",
}

General:new(extension, "hs__xiahouyuan", "wei", 5):addSkill("hs__shensu")
Fk:loadTranslationTable{
  ["hs__xiahouyuan"] = "夏侯渊",
  ["#hs__xiahouyuan"] = "虎步关右",
  ["illustrator:hs__xiahouyuan"] = "凡果",
  ["~hs__xiahouyuan"] = "竟然比我还…快……",
}

local zhanghe = General:new(extension, "hs__zhanghe", "wei", 4)
zhanghe:addSkill("qiaobian")
Fk:loadTranslationTable{
  ["hs__zhanghe"] = "张郃",
  ["#hs__zhanghe"] = "料敌机先",
  ["illustrator:hs__zhanghe"] = "张帅",
  ["~hs__zhanghe"] = "呃，膝盖中箭了……",
}

General:new(extension, "hs__xuhuang", "wei", 4):addSkill("hs__duanliang")
Fk:loadTranslationTable{
  ["hs__xuhuang"] = "徐晃",
  ["#hs__xuhuang"] = "周亚夫之风",
  ["illustrator:hs__xuhuang"] = "Tuu.",
  ["~hs__xuhuang"] = "一顿不吃饿得慌。",
}

General:new(extension, "hs__caoren", "wei", 4):addSkill("hs__jushou")
Fk:loadTranslationTable{
  ["hs__caoren"] = "曹仁",
  ["#hs__caoren"] = "大将军",
  ["illustrator:hs__caoren"] = "Ccat",
  ["~hs__caoren"] = "实在是守不住了……",
}

General:new(extension, "hs__dianwei", "wei", 4):addSkill("hs__qiangxi")
Fk:loadTranslationTable{
  ['hs__dianwei'] = '典韦',
  ["#hs__dianwei"] = "古之恶来",
  ["illustrator:hs__dianwei"] = "凡果",
  ["~hs__dianwei"] = "主公，快走！",
}

General:new(extension, "hs__xunyu", "wei", 3):addSkills{"quhu", "hs__jieming"}
Fk:loadTranslationTable{
  ['hs__xunyu'] = '荀彧',
  ["#hs__xunyu"] = "王佐之才",
  ["illustrator:hs__xunyu"] = "LiuHeng",
  ["~hs__xunyu"] = "主公要臣死，臣不得不死。",
}

General:new(extension, "hs__caopi", "wei", 3):addSkills{"xingshang", "hs__fangzhu"}
Fk:loadTranslationTable{
  ['hs__caopi'] = '曹丕',
  ["#hs__caopi"] = "霸业的继承者",
  ["illustrator:hs__caopi"] = "DH",
  ["~hs__caopi"] = "子建，子建……",
}

General:new(extension, "hs__yuejin", "wei", 4):addSkill("hs__xiaoguo")

Fk:loadTranslationTable{
  ["hs__yuejin"] = "乐进",
  ["#hs__yuejin"] = "奋强突固",
  ["illustrator:hs__yuejin"] = "巴萨小马",
  ["desinger:hs__yuejin"] = "淬毒",
  ["~hs__yuejin"] = "箭疮发作，吾命休矣。",
}

local liubei = General:new(extension, "hs__liubei", "shu", 4)
liubei:addSkill("ex__rende")
liubei:addCompanions({"hs__guanyu", "hs__zhangfei", "hs__ganfuren"})
Fk:loadTranslationTable{
  ["hs__liubei"] = "刘备",
  ["#hs__liubei"] = "乱世的枭雄",
  ["illustrator:hs__liubei"] = "木美人",
  ["~hs__liubei"] = "汉室未兴，祖宗未耀，朕实不忍此时西去……",
}

local guanyu = General:new(extension, "hs__guanyu", "shu", 5)
guanyu:addSkill("hs__wusheng")
guanyu:addCompanions("hs__zhangfei")
Fk:loadTranslationTable{
  ["hs__guanyu"] = "关羽",
  ["#hs__guanyu"] = "威震华夏",
  ["illustrator:hs__guanyu"] = "凡果",
  ["~hs__guanyu"] = "什么？此地名叫麦城？",
}

General:new(extension, "hs__zhangfei", "shu", 4):addSkill("hs__paoxiao")

Fk:loadTranslationTable{
  ["hs__zhangfei"] = "张飞",
  ["#hs__zhangfei"] = "万夫不当",
  -- ["illustrator:hs__zhangfei"] = "宋其金",
  ["~hs__zhangfei"] = "实在是杀不动了……",
}

local zhugeliang = General:new(extension, "hs__zhugeliang", "shu", 3)
zhugeliang:addSkills{"hs__guanxing", "hs__kongcheng"}
zhugeliang:addCompanions("hs__huangyueying")
Fk:loadTranslationTable{
  ["hs__zhugeliang"] = "诸葛亮",
  ["#hs__zhugeliang"] = "迟暮的丞相",
  ["illustrator:hs__zhugeliang"] = "木美人",
  ["~hs__zhugeliang"] = "将星陨落，天命难违。",
}

local zhaoyun = General:new(extension, "hs__zhaoyun", "shu", 4)
zhaoyun:addSkill("hs__longdan")
zhaoyun:addCompanions("hs__liushan")

Fk:loadTranslationTable{
  ["hs__zhaoyun"] = "赵云",
  ["#hs__zhaoyun"] = "虎威将军",
  ["illustrator:hs__zhaoyun"] = "DH",
  ["~hs__zhaoyun"] = "这，就是失败的滋味吗？",
}

General:new(extension, "hs__machao", "shu", 4):addSkills{"mashu", "hs__tieqi"}
Fk:loadTranslationTable{
  ["hs__machao"] = "马超",
  ["#hs__machao"] = "一骑当千",
  ["illustrator:hs__machao"] = "KayaK&木美人&张帅",
  ["~hs__machao"] = "请将我，葬在西凉……",
}

local huangyueying = General:new(extension, "hs__huangyueying", "shu", 3, 3, General.Female)
huangyueying:addSkills{"jizhi","qicai"}
huangyueying:addCompanions("hs__wolong")
Fk:loadTranslationTable{
  ["hs__huangyueying"] = "黄月英",
  ["#hs__huangyueying"] = "归隐的杰女",
  ["illustrator:hs__huangyueying"] = "木美人",
  ["~hs__huangyueying"] = "亮……",
}

local huangzhong = General:new(extension, "hs__huangzhong", "shu", 4)
huangzhong:addSkill("hs__liegong")
huangzhong:addCompanions("hs__weiyan")
Fk:loadTranslationTable{
  ["hs__huangzhong"] = "黄忠",
  ["#hs__huangzhong"] = "老当益壮",
  -- ["illustrator:hs__huangzhong"] = "凡果",
  ["~hs__huangzhong"] = "不得不服老了……",
}

General:new(extension, "hs__weiyan", "shu", 4):addSkill("hs__kuanggu")

Fk:loadTranslationTable{
  ["hs__weiyan"] = "魏延",
  ["#hs__weiyan"] = "嗜血的独狼",
  ["illustrator:hs__weiyan"] = "瞌瞌一休",
  ["~hs__weiyan"] = "奸贼……害我……",
}

local pangtong = General:new(extension, "hs__pangtong", "shu",3)
pangtong:addSkills{"lianhuan", "niepan"}
pangtong:addCompanions("hs__wolong")
Fk:loadTranslationTable{
  ['hs__pangtong'] = '庞统',
  ["#hs__pangtong"] = "凤雏",
  ["illustrator:hs__pangtong"] = "KayaK",
}

General:new(extension, "hs__wolong", "shu", 3):addSkills{"bazhen", "huoji", "kanpo"}
Fk:loadTranslationTable{
  ['hs__wolong'] = '卧龙诸葛亮',
  ["#hs__wolong"] = "卧龙",
  ["illustrator:hs__wolong"] = "绘聚艺堂",
  ["~hs__wolong"] = "我的计谋竟被……",
}

General:new(extension, "hs__liushan", "shu", 3):addSkills{"xiangle", "fangquan"}
Fk:loadTranslationTable{
  ['hs__liushan'] = '刘禅',
  ["#hs__liushan"] = "无为的真命主",
  ["illustrator:hs__liushan"] = "LiuHeng",
  ["~hs__liushan"] = "别打脸，我投降还不行吗？",
}

local menghuo = General:new(extension, "hs__menghuo", "shu", 4)
menghuo:addCompanions("hs__zhurong")
menghuo:addSkills{"huoshou", "zaiqi"}
Fk:loadTranslationTable{
  ['hs__menghuo'] = '孟获',
  ["#hs__menghuo"] = "南蛮王",
  ["illustrator:hs__menghuo"] = "废柴男",
}

General:new(extension, "hs__zhurong", "shu", 4, 4, General.Female):addSkills{"juxiang", "lieren"}
Fk:loadTranslationTable{
  ['hs__zhurong'] = '祝融',
  ["#hs__zhurong"] = "野性的女王",
  ["illustrator:hs__zhurong"] = "废柴男",
  ["~hs__zhurong"] = "大王，我，先走一步了。",
}

General(extension, "hs__ganfuren", "shu", 3, 3, General.Female):addSkills{"shushen", "shenzhi"}
Fk:loadTranslationTable{
  ['hs__ganfuren'] = '甘夫人',
  ["#hs__ganfuren"] = "昭烈皇后",
  ["illustrator:hs__ganfuren"] = "琛·美弟奇",
  ["designer:hs__ganfuren"] = "淬毒",
  ["~hs__ganfuren"] = "请替我照顾好阿斗……",
}

local sunquan = General:new(extension, "hs__sunquan", "wu", 4)
sunquan:addSkill("hs__zhiheng")
sunquan:addCompanions("hs__zhoutai")

Fk:loadTranslationTable{
  ["hs__sunquan"] = "孙权",
  ["#hs__sunquan"] = "年轻的贤君",
  ["illustrator:hs__sunquan"] = "KayaK",
  ["~hs__sunquan"] = "父亲，大哥，仲谋愧矣……",
}

General:new(extension, "hs__ganning", "wu", 4):addSkill("qixi")

Fk:loadTranslationTable{
  ["hs__ganning"] = "甘宁",
  ["#hs__ganning"] = "锦帆游侠",
  ["illustrator:hs__ganning"] = "KayaK",
  ["~hs__ganning"] = "二十年后，又是一条好汉！",
}
--[[
local lvmeng = General(extension, "hs__lvmeng", "wu", 4)

local keji = fk.CreateTriggerSkill{
  name = "hs__keji",
  anim_type = "defensive",
  events = {fk.EventPhaseStart},
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    if target ~= player or not player:hasSkill(self) or player.phase ~= Player.Discard then return false end 
    local cards, play_ids = {}, {}
    local logic = player.room.logic
    logic:getEventsOfScope(GameEvent.Phase, 1, function (e)
      if e.data[2] == Player.Play then
        table.insert(play_ids, {e.id, e.end_id})
      end
      return false
    end, Player.HistoryTurn)
    logic:getEventsOfScope(GameEvent.UseCard, 1, function (e)
      local in_play = false
      for _, ids in ipairs(play_ids) do
        if #ids == 2 and e.id > ids[1] and e.id < ids[2] then
          in_play = true
          break
        end
      end
      if in_play then
        local use = e.data[1]
        if use.from == player.id and (use.card.color ~= Card.NoColor) then
          table.insertIfNeed(cards, use.card.color)
        end
      end
    end, Player.HistoryTurn)
    return #cards <= 1
  end,
  on_use = function(self, event, target, player, data)
    player.room:addPlayerMark(player, MarkEnum.AddMaxCardsInTurn, 4)
  end
}

local mouduan = fk.CreateTriggerSkill{
  name = "hs__mouduan",
  events = {fk.EventPhaseStart},
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    if target ~= player or not player:hasSkill(self) or player.phase ~= Player.Finish then return false end 
    local suits, types, play_ids = {}, {}, {}
    local logic = player.room.logic
    logic:getEventsOfScope(GameEvent.Phase, 1, function (e)
      if e.data[2] == Player.Play then
        table.insert(play_ids, {e.id, e.end_id})
      end
      return false
    end, Player.HistoryTurn)
    logic:getEventsOfScope(GameEvent.UseCard, 1, function (e)
      local in_play = false
      for _, ids in ipairs(play_ids) do
        if #ids == 2 and e.id > ids[1] and e.id < ids[2] then
          in_play = true
          break
        end
      end
      if in_play then
        local use = e.data[1]
        if use.from == player.id then
          table.insertIfNeed(suits, use.card.suit)
          table.insertIfNeed(types, use.card.type)
        end
      end
    end, Player.HistoryTurn)
    return #suits >= 4 or #types >= 3
  end,
  on_cost = function(self, event, target, player, data)
    local targets = player.room:askForChooseToMoveCardInBoard(player, "#hs__mouduan-move", self.name, true, nil)
    if #targets ~= 0 then
      self.cost_data = targets
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local targets = self.cost_data
    local room = player.room
    targets = table.map(targets, function(id) return room:getPlayerById(id) end)
    room:askForMoveCardInBoard(player, targets[1], targets[2], self.name)
  end
}

lvmeng:addSkill(keji)
lvmeng:addSkill(mouduan)

Fk:loadTranslationTable{
  ["hs__lvmeng"] = "吕蒙",
  ["#hs__lvmeng"] = "白衣渡江",
  ["illustrator:hs__lvmeng"] = "樱花闪乱",

  ["hs__keji"] = "克己",
  [":hs__keji"] = "锁定技，弃牌阶段开始时，若你于出牌阶段内未使用过有颜色的牌，或于出牌阶段内使用过的所有的牌的颜色均相同，你的手牌上限于此回合内+4。",
  ["hs__mouduan"] = "谋断",
  [":hs__mouduan"] = "结束阶段，若你于出牌阶段内使用过四种花色或三种类别的牌，你可移动场上的一张牌。",

  ["#hs__mouduan-move"] = "谋断：你可选择两名角色，移动他们场上的一张牌",

  ["$hs__keji1"] = "谨慎为妙。",
  ["$hs__keji2"] = "时机未到。",
  ["$hs__mouduan1"] = "今日起兵，渡江攻敌！",
  ["$hs__mouduan2"] = "时机已到，全军出击！。",
  ["~hs__lvmeng"] = "种下恶因，必有恶果。",
}

local huanggai = General(extension, "hs__huanggai", "wu", 4)

local kurou = fk.CreateActiveSkill{
  name = "hs__kurou",
  anim_type = "drawcard",
  card_num = 1,
  target_num = 0,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  on_use = function(self, room, effect)
    local from = room:getPlayerById(effect.from)
    room:throwCard(effect.cards, self.name, from, from)
    if from.dead then return end
    room:loseHp(from, 1, self.name)
    if from.dead then return end
    from:drawCards(3, self.name)
  end
}
local kurouBuff = fk.CreateTargetModSkill{
  name = "#hs__kurou_buff",
  residue_func = function(self, player, skill, scope)
    if skill.trueName == "slash_skill" and scope == Player.HistoryPhase then
      return player:usedSkillTimes("hs__kurou", Player.HistoryPhase)
    end
  end,
}
kurou:addRelatedSkill(kurouBuff)

huanggai:addSkill(kurou)
huanggai:addCompanions("hs__zhouyu")

Fk:loadTranslationTable{
  ["hs__huanggai"] = "黄盖",
  ["#hs__huanggai"] = "轻身为国",
  ["illustrator:hs__huanggai"] = "G.G.G.",

  ["hs__kurou"] = "苦肉",
  [":hs__kurou"] = "出牌阶段限一次，你可弃置一张牌，然后你失去1点体力，摸三张牌，于此阶段内使用【杀】的次数上限+1。",

  ["$hs__kurou1"] = "我这把老骨头，不算什么！",
  ["$hs__kurou2"] = "为成大业，死不足惜！",
  ["~hs__huanggai"] = "盖，有负公瑾重托……",
}

local zhouyu = General(extension, "hs__zhouyu", "wu", 3)
zhouyu:addSkill("ex__yingzi")
zhouyu:addSkill("ex__fanjian")
zhouyu:addCompanions("hs__xiaoqiao")
Fk:loadTranslationTable{
  ["hs__zhouyu"] = "周瑜",
  ["#hs__zhouyu"] = "大都督",
  ["illustrator:hs__zhouyu"] = "绘聚艺堂",
  ["~hs__zhouyu"] = "既生瑜，何生亮。既生瑜，何生亮！",
}

local daqiao = General(extension, "hs__daqiao", "wu", 3, 3, General.Female)

daqiao:addSkill("guose")
daqiao:addSkill("liuli")
daqiao:addCompanions("hs__xiaoqiao")

Fk:loadTranslationTable{
  ["hs__daqiao"] = "大乔",
  ["#hs__daqiao"] = "矜持之花",
  ["illustrator:hs__daqiao"] = "KayaK",
  ["~hs__daqiao"] = "伯符，我去了……",
}

local luxun = General(extension, "hs__luxun", "wu", 3)

local qianxun = fk.CreateTriggerSkill{
  name = "hs__qianxun",
  anim_type = "defensive",
  events = {fk.TargetConfirming, fk.BeforeCardsMove},
  frequency = Skill.Compulsory,
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self) then return false end
    if event == fk.TargetConfirming then
      return target == player and player:hasSkill(self) and data.card.name == "snatch"
    elseif event == fk.BeforeCardsMove then
      local id = 0
      local source = player
      local room = player.room
      local c
      for _, move in ipairs(data) do
        if move.to == player.id and move.toArea == Card.PlayerJudge then
          for _, info in ipairs(move.moveInfo) do
            id = info.cardId
            if info.fromArea == Card.PlayerJudge then
              source = room:getPlayerById(move.from) or player
            else
              source = player
            end
            c = source:getVirualEquip(id)
            --FIXME：巨大隐患，延时锦囊的virtual_equips在置入判定区的事件被篡改，或者判定阶段自然流程以外的方式离开判定区时不会清理
            if not c then c = Fk:getCardById(id) end
            if c.trueName == "indulgence" then
              return true
            end
          end
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:notifySkillInvoked(player, self.name)
    if event == fk.TargetConfirming then
      player:broadcastSkillInvoke(self.name, 2)
      AimGroup:cancelTarget(data, player.id)
      return true
    elseif event == fk.BeforeCardsMove then
      player:broadcastSkillInvoke(self.name, 1)
      local source = player
      local mirror_moves = {}
      local ids = {}
      for _, move in ipairs(data) do
        if move.to == player.id and move.toArea == Card.PlayerJudge then
          local move_info = {}
          local mirror_info = {}
          for _, info in ipairs(move.moveInfo) do
            local id = info.cardId
            if info.fromArea == Card.PlayerJudge then
              source = room:getPlayerById(move.from) or player
            else
              source = player
            end
            local c = source:getVirualEquip(id)
            if not c then c = Fk:getCardById(id) end
            if c.trueName == "indulgence" then
              table.insert(mirror_info, info)
              table.insert(ids, id)
            else
              table.insert(move_info, info)
            end
          end
          if #mirror_info > 0 then
            move.moveInfo = move_info
            local mirror_move = table.clone(move)
            mirror_move.to = nil
            mirror_move.toArea = Card.DiscardPile
            mirror_move.moveInfo = mirror_info
            table.insert(mirror_moves, mirror_move)
          end
        end
      end
      table.insertTable(data, mirror_moves)
    end
  end
}

local duoshi = fk.CreateTriggerSkill{
  name = "duoshi",
  anim_type = "drawcard",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    local card = Fk:cloneCard("await_exhausted")
    return player:hasSkill(self) and player == target and player.phase == Player.Play and not player:prohibitUse(card)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room.alive_players, function(p) return
      H.compareKingdomWith(p, player) end)
    room:useVirtualCard("await_exhausted", {}, player, targets, self.name)
  end,
}

luxun:addSkill(qianxun)
luxun:addSkill(duoshi)

Fk:loadTranslationTable{
  ["hs__luxun"] = "陆逊",
  ["#hs__luxun"] = "擎天之柱",
  ["illustrator:hs__luxun"] = "KayaK",

  ["hs__qianxun"] = "谦逊",
  [":hs__qianxun"] = "锁定技，当你成为【顺手牵羊】或【乐不思蜀】的目标时，你取消此目标。",
  ["duoshi"] = "度势",
  [":duoshi"] = "出牌阶段开始时，你可以视为使用一张【以逸待劳】。",

  ["$hs__qianxun1"] = "儒生脱尘，不为贪逸淫乐之事。",
  ["$hs__qianxun2"] = "谦谦君子，不饮盗泉之水。",
  ["$duoshi1"] = "以今日之大势，当行此计。",
  ["$duoshi2"] = "国之大计，审势为先。",
  ["~hs__luxun"] = "还以为我已经不再年轻……",
}


local sunshangxiang = General(extension, "hs__sunshangxiang", "wu", 3, 3, General.Female)

local xiaoji = fk.CreateTriggerSkill{
  name = "hs__xiaoji",
  anim_type = "drawcard",
  events = {fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self) then return end
    for _, move in ipairs(data) do
      if move.from == player.id then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerEquip then
            return true
          end
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    if player.room.current == player then
      player:drawCards(1, self.name)
    else
      player:drawCards(3, self.name)
    end
  end,
}

sunshangxiang:addSkill(xiaoji)
sunshangxiang:addSkill("jieyin")

Fk:loadTranslationTable{
  ["hs__sunshangxiang"] = "孙尚香",
  ["#hs__sunshangxiang"] = "弓腰姬",
  ["illustrator:hs__sunshangxiang"] = "凡果",

  ["hs__xiaoji"] = "枭姬",
  [":hs__xiaoji"] = "当你失去装备区的装备牌后，若此时是你的回合内，你摸一张牌，否则你摸三张牌。",

  ["$hs__xiaoji1"] = "哼！",
  ["$hs__xiaoji2"] = "看我的厉害！",
  ["~hs__sunshangxiang"] = "不！还不可以死！",
}

local yinghun = fk.CreateTriggerSkill{
  name = "hs__yinghun",
  anim_type = "drawcard",
  mute = true,
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Start
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
local sunjian = General:new(extension, "hs__sunjian", "wu", 5)
sunjian:addSkill(yinghun)
Fk:loadTranslationTable{
  ['hs__sunjian'] = '孙坚',
  ["#hs__sunjian"] = "魂佑江东",
  ["illustrator:hs__sunjian"] = "凡果",

  ["hs__yinghun"] = "英魂",
  [":hs__yinghun"] = "准备阶段，你可选择一名其他角色并选择一项：1.令其摸X张牌，然后弃置一张牌；2.令其摸一张牌，然后弃置X张牌（X为你已损失的体力值）。",
  ["#yinghun-choose"] = "英魂：你可以令一名其他角色：摸%arg张牌然后弃置一张牌，或摸一张牌然后弃置%arg2张牌",
  ["#yinghun-draw"] = "摸%arg张牌，弃置1张牌",
  ["#yinghun-discard"] = "摸1张牌，弃置%arg张牌",

  ["$hs__yinghun1"] = "以吾魂魄，保佑吾儿之基业。",
  ["$hs__yinghun2"] = "不诛此贼三族，则吾死不瞑目！",
  ["~hs__sunjian"] = "有埋伏！呃……啊！！",
}

local xiaoqiao = General(extension, "hs__xiaoqiao", "wu", 3, 3, General.Female)
local tianxiang = fk.CreateTriggerSkill{
  name = "hs__tianxiang",
  anim_type = "defensive",
  events = {fk.DamageInflicted},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and target == player and (player:getMark("hs__tianxiang_damage-turn") == 0 or player:getMark("hs__tianxiang_loseHp-turn") == 0)
  end,
  on_cost = function(self, event, target, player, data)
    local tar, card = player.room:askForChooseCardAndPlayers(player, table.map(player.room:getOtherPlayers(player, false), Util.IdMapper), 1, 1, ".|.|heart|hand", "#hs__tianxiang-choose", self.name, true)
    if #tar > 0 and card then
      self.cost_data = {tar[1], card}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(self.cost_data[1])
    local cid = self.cost_data[2]
    room:throwCard(cid, self.name, player, player)

    if to.dead then return true end
    local choices = {}
    if player:getMark("hs__tianxiang_loseHp-turn") == 0 then
      table.insert(choices, "hs__tianxiang_loseHp")
    end
    if data.from and not data.from.dead and player:getMark("hs__tianxiang_damage-turn") == 0 then
      table.insert(choices, "hs__tianxiang_damage")
    end
    local choice = room:askForChoice(player, choices, self.name, "#hs__tianxiang-choice::"..to.id)
    if choice == "hs__tianxiang_loseHp" then
      room:setPlayerMark(player, "hs__tianxiang_loseHp-turn", 1)
      room:loseHp(to, 1, self.name)
      if not to.dead and (room:getCardArea(cid) == Card.DrawPile or room:getCardArea(cid) == Card.DiscardPile) then
        room:obtainCard(to, cid, true, fk.ReasonJustMove)
      end
    else
      room:setPlayerMark(player, "hs__tianxiang_damage-turn", 1)
      room:damage{
        from = data.from,
        to = to,
        damage = 1,
        skillName = self.name,
      }
      if not to.dead then
        to:drawCards(math.min(to:getLostHp(), 5), self.name)
      end
    end
    return true
  end,
}

local hongyan = fk.CreateFilterSkill{
  name = "hs__hongyan",
  card_filter = function(self, to_select, player)
    return to_select.suit == Card.Spade and player:hasSkill(self)
  end,
  view_as = function(self, to_select)
    return Fk:cloneCard(to_select.name, Card.Heart, to_select.number)
  end,
}

local hongyan_maxcards = fk.CreateMaxCardsSkill{
  name = "#hs__hongyan_maxcards",
  correct_func = function (self, player)
    if player:hasSkill("hs__hongyan") and #table.filter(player:getCardIds(Player.Equip), function (id) return Fk:getCardById(id).suit == Card.Heart or Fk:getCardById(id).suit == Card.Spade end) > 0  then
      return 1
    end
  end,
}

xiaoqiao:addSkill(tianxiang)
hongyan:addRelatedSkill(hongyan_maxcards)
xiaoqiao:addSkill(hongyan)

Fk:loadTranslationTable{
  ['hs__xiaoqiao'] = '小乔',
  ["#hs__xiaoqiao"] = "矫情之花",
  ["illustrator:hs__xiaoqiao"] = "绘聚艺堂",

  ["hs__tianxiang"] = "天香",
  [":hs__tianxiang"] = "当你受到伤害时，你可弃置一张<font color='red'>♥</font>手牌并选择一名其他角色。你防止此伤害，选择本回合未选择过的一项：1.令来源对其造成1点伤害，其摸X张牌（X为其已损失的体力值且至多为5）；2.令其失去1点体力，其获得牌堆或弃牌堆中你以此法弃置的牌。",
  ["hs__hongyan"] = "红颜",
  [":hs__hongyan"] = "锁定技，你的黑桃牌视为红桃牌；若你的装备区内有红桃牌，你的手牌上限+1",

  ["#hs__tianxiang-choose"] = "天香：弃置一张<font color='red'>♥</font>手牌并选择一名其他角色",
  ["#hs__tianxiang-choice"] = "天香：选择一项令 %dest 执行",
  ["hs__tianxiang_damage"] = "令其受到1点伤害并摸已损失体力值的牌",
  ["hs__tianxiang_loseHp"] = "令其失去1点体力并获得你弃置的牌",

  ["$hs__tianxiang1"] = "接着哦~",
  ["$hs__tianxiang2"] = "替我挡着~",
  ["~hs__xiaoqiao"] = "公瑾…我先走一步……",
}
--]]
General:new(extension, "hs__taishici", "wu", 4):addSkill("tianyi")
Fk:loadTranslationTable{
  ['hs__taishici'] = '太史慈',
  ["#hs__taishici"] = "笃烈之士",
  ["illustrator:hs__taishici"] = "Tuu.",
  ["~hs__taishici"] = "大丈夫，当带三尺之剑，立不世之功！",
}
--[[
local zhoutai = General(extension, "hs__zhoutai", "wu", 4)
local buqu = fk.CreateTriggerSkill{
  name = "hs__buqu",
  anim_type = "defensive",
  events = {fk.AskForPeaches},
  frequency = Skill.Compulsory,
  derived_piles = "hs__buqu_scar",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.dying
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local scar_id =room:getNCards(1)[1]
    local scar = Fk:getCardById(scar_id)
    player:addToPile("hs__buqu_scar", scar_id, true, self.name)
    if player.dead or not table.contains(player:getPile("hs__buqu_scar"), scar_id) then return false end
    local success = true
    for _, id in pairs(player:getPile("hs__buqu_scar")) do
      if id ~= scar_id then
        local card = Fk:getCardById(id)
        if (card.number == scar.number) then
          success = false
          break
        end
      end
    end
    if success then
      room:recover({
        who = player,
        num = 1 - player.hp,
        recoverBy = player,
        skillName = self.name
      })
    else
      room:throwCard(scar:getEffectiveId(), self.name, player) 
    end
  end,
}

local fenji = fk.CreateTriggerSkill{
  name = "hs__fenji",
  anim_type = "support",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and target.phase == Player.Finish and target:isKongcheng()
  end,
  on_use = function(self, event, target, player, data)
    target:drawCards(2, self.name)
    if not player.dead then player.room:loseHp(player, 1, self.name) end
  end,
}

zhoutai:addSkill(buqu)
zhoutai:addSkill(fenji)

Fk:loadTranslationTable{
  ['hs__zhoutai'] = '周泰',
  ["#hs__zhoutai"] = "历战之躯",
  ["illustrator:hs__zhoutai"] = "Thinking",

  ["hs__buqu"] = "不屈",
  [":hs__buqu"] = "锁定技，当你处于濒死状态时，你将牌堆顶的一张牌置于你的武将牌上，称为“创”，若此牌的点数与已有的“创”点数：均不同，则你将体力回复至1点；存在相同，将此牌置入弃牌堆。",
  ["hs__fenji"] = "奋激",
  [":hs__fenji"] = "一名角色的结束阶段，若其没有手牌，你可令其摸两张牌，然后你失去1点体力。",

  ["hs__buqu_scar"] = "创",

  ["$hs__buqu1"] = "战如熊虎，不惜躯命！",
  ["$hs__buqu2"] = "哼，这点小伤算什么！",
  ["$hs__fenji1"] = "百战之身，奋勇驱前！",
  ["$hs__fenji2"] = "两肋插刀，愿赴此躯！",
  ["~hs__zhoutai"] = "敌众我寡，无力回天……",
}
--]]
General:new(extension, "hs__lusu", "wu", 3):addSkills{"haoshi", "dimeng"}
Fk:loadTranslationTable{
  ['hs__lusu'] = '鲁肃',
  ["#hs__lusu"] = "独断的外交家",
  ["illustrator:hs__lusu"] = "LiuHeng",
  ["~hs__lusu"] = "此联盟已破，吴蜀休矣。",
}

General:new(extension, "hs__zhangzhaozhanghong", "wu", 3):addSkills{"zhijian", "guzheng"}
Fk:loadTranslationTable{
  ['hs__zhangzhaozhanghong'] = '张昭张纮',
  ["#hs__zhangzhaozhanghong"] = "经天纬地",
  ["illustrator:hs__zhangzhaozhanghong"] = "废柴男",
  ["~hs__zhangzhaozhanghong"] = "竭力尽智，死而无憾。",
}

General:new(extension, "hs__dingfeng", "wu", 4):addSkills{"duanbing", "fenxun"}
Fk:loadTranslationTable{
  ["hs__dingfeng"] = "丁奉",
  ["#hs__dingfeng"] = "清侧重臣",
  ["illustrator:hs__dingfeng"] = "魔鬼鱼",

  ["$duanbing1"] = "众将官，短刀出鞘。",
  ["$duanbing2"] = "短兵轻甲也可取汝性命！",
  ["$fenxun1"] = "取封侯爵赏，正在今日！",
  ["$fenxun2"] = "给我拉过来！",
  ["~hs__dingfeng"] = "这风，太冷了……",
}
--[[
local huatuo = General(extension, "hs__huatuo", "qun", 3)

local chuli = fk.CreateActiveSkill{
  name = "hs__chuli",
  anim_type = "control",
  card_num = 0,
  min_target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0 and not player:isNude()
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, to_select, selected, selected_cards)
    local room = Fk:currentRoom()
    local target = room:getPlayerById(to_select)
    return to_select ~= Self.id and not target:isNude() and #selected < 3 and
      table.every(selected, function(id) return not H.compareKingdomWith(target, room:getPlayerById(id)) end)
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local targets = table.clone(effect.tos)
    table.insert(targets, 1, effect.from)
    room:sortPlayersByAction(targets)
    for _, id in ipairs(targets) do
      local target = room:getPlayerById(id)
      if not target:isNude() then
        local c = room:askForCardChosen(player, target, "he", self.name)
        room:throwCard({c}, self.name, target, player)
        if Fk:getCardById(c).suit == Card.Spade then
          room:addPlayerMark(target, "_hs__chuli-phase", 1)
        end
      end
    end
    for _, id in ipairs(targets) do
      local target = room:getPlayerById(id)
      if target:getMark("_hs__chuli-phase") > 0 and not target.dead then
        room:setPlayerMark(target, "_hs__chuli-phase", 0)
        target:drawCards(1, self.name)
      end
    end
  end,
}

huatuo:addSkill("jijiu")
huatuo:addSkill(chuli)

Fk:loadTranslationTable{
  ["hs__huatuo"] = "华佗",
  ["#hs__huatuo"] = "神医",
  ["illustrator:hs__huatuo"] = "琛·美弟奇",

  ["hs__chuli"] = "除疠",
  [":hs__chuli"] = "出牌阶段限一次，你可选择至多三名势力各不相同或未确定势力的其他角色，然后你弃置你和这些角色的各一张牌。被弃置♠牌的角色各摸一张牌。",

  ["$jijiu_hs__huatuo1"] = "救死扶伤，悬壶济世。",
  ["$jijiu_hs__huatuo2"] = "妙手仁心，药到病除。",
  ["$hs__chuli1"] = "病去，如抽丝。",
  ["$hs__chuli2"] = "病入膏肓，需下猛药。",
  ["~hs__huatuo"] = "生老病死，命不可违。",
}
--]]
local lvbu = General:new(extension, "hs__lvbu", "qun", 5)
lvbu:addSkill("wushuang")
lvbu:addCompanions("hs__diaochan")

Fk:loadTranslationTable{
  ["hs__lvbu"] = "吕布",
  ["#hs__lvbu"] = "戟指中原",
  ["illustrator:hs__lvbu"] = "凡果",
  ["~hs__lvbu"] = "不可能！",
}
--[[
local diaochan = General(extension, "hs__diaochan", "qun", 3, 3, General.Female)

local lijian = fk.CreateActiveSkill{
  name = "hs__lijian",
  anim_type = "offensive",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = function(self, to_select, selected)
    return #selected == 0
  end,
  target_filter = function(self, to_select, selected)
    return #selected < 2 and to_select ~= Self.id and
      Fk:currentRoom():getPlayerById(to_select).gender == General.Male
  end,
  target_num = 2,
  min_card_num = 1,
  on_use = function(self, room, use)
    local player = room:getPlayerById(use.from)
    room:throwCard(use.cards, self.name, player, player)
    local duel = Fk:cloneCard("duel")
    duel.skillName = self.name
    local new_use = { ---@type CardUseStruct
      from = use.tos[2],
      tos = { { use.tos[1] } },
      card = duel,
    }
    room:useCard(new_use)
  end,
}

diaochan:addSkill(lijian)
diaochan:addSkill("biyue")

Fk:loadTranslationTable{
  ["hs__diaochan"] = "貂蝉",
  ["#hs__diaochan"] = "绝世的舞姬",
  ["illustrator:hs__diaochan"] = "LiuHeng",

  ["hs__lijian"] = "离间",
  [":hs__lijian"] = "出牌阶段限一次，你可弃置一张牌并选择两名其他男性角色，后选择的角色视为对先选择的角色使用一张【决斗】。",

  ["$hs__lijian1"] = "嗯呵呵~~呵呵~~",
  ["$hs__lijian2"] = "夫君，你要替妾身做主啊……",
  ["~hs__diaochan"] = "父亲大人，对不起……",
}

local yuanshao = General(extension, "hs__yuanshao", "qun", 4)

local luanji = fk.CreateViewAsSkill{
  name = "hs__luanji",
  anim_type = "offensive",
  pattern = "archery_attack",
  card_filter = function(self, to_select, selected)
    if #selected == 2 or Fk:currentRoom():getCardArea(to_select) ~= Player.Hand then return false end
    local record = Self:getTableMark("@hs__luanji-turn")
    return not table.contains(record, Fk:getCardById(to_select):getSuitString(true))
  end,
  view_as = function(self, cards)
    if #cards ~= 2 then
      return nil
    end
    local c = Fk:cloneCard("archery_attack")
    c.skillName = "hs__luanji"
    c:addSubcards(cards)
    return c
  end,
  before_use = function(self, player, use)
    local room = player.room
    local record = player:getTableMark("@hs__luanji-turn")
    local cards = use.card.subcards
    for _, cid in ipairs(cards) do
      local suit = Fk:getCardById(cid):getSuitString(true)
      if suit ~= "log_nosuit" then table.insertIfNeed(record, suit) end
    end
    room:setPlayerMark(player, "@hs__luanji-turn", record)
  end
}
local luanji_draw = fk.CreateTriggerSkill{
  name = "#hs__luanji_draw",
  anim_type = "drawcard",
  visible = false,
  events = {fk.CardRespondFinished},
  can_trigger = function(self, event, target, player, data)
    if target ~= player or data.card.name ~= "jink" or player.dead then return false end
    if data.responseToEvent and table.contains(data.responseToEvent.card.skillNames, "hs__luanji") then
      local yuanshao = data.responseToEvent.from
      if yuanshao and H.compareKingdomWith(player, player.room:getPlayerById(yuanshao)) then
        return true
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, nil, "#hs__luanji-draw")
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, self.name)
  end,
}
luanji:addRelatedSkill(luanji_draw)

yuanshao:addSkill(luanji)
yuanshao:addCompanions("hs__yanliangwenchou")

Fk:loadTranslationTable{
  ["hs__yuanshao"] = "袁绍",
  ["#hs__yuanshao"] = "高贵的名门",
  ["illustrator:hs__yuanshao"] = "北辰菌",

  ["hs__luanji"] = "乱击",
  [":hs__luanji"] = "你可将两张手牌当【万箭齐发】使用（不能使用此回合以此法使用过的花色），当与你势力相同的角色打出【闪】响应此牌结算结束后，其可摸一张牌。",

  ["@hs__luanji-turn"] = "乱击",
  ["#hs__luanji-draw"] = "乱击：你可摸一张牌",
  ["#hs__luanji_draw"] = "乱击",

  ["$hs__luanji1"] = "弓箭手，准备放箭！",
  ["$hs__luanji2"] = "全都去死吧！",
  ["~hs__yuanshao"] = "老天不助我袁家啊！",
}
--]]
General:new(extension, 'hs__yanliangwenchou', 'qun', 4):addSkill('shuangxiong')
Fk:loadTranslationTable{
  ['hs__yanliangwenchou'] = '颜良文丑',
  ["#hs__yanliangwenchou"] = "虎狼兄弟",
  ["illustrator:hs__yanliangwenchou"] = "KayaK",

  ["~hs__yanliangwenchou"] = "这红脸长须大将是……",
}
--[[
local jiaxu = General(extension, 'hs__jiaxu', 'qun', 3)
jiaxu:addSkill('wansha')
jiaxu:addSkill('luanwu')
local weimu = fk.CreateTriggerSkill{
  name = "hs__weimu",
  anim_type = "defensive",
  events = { fk.TargetConfirming, fk.BeforeCardsMove },
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self) then return false end
    if event == fk.TargetConfirming then
      return target == player and data.card.color == Card.Black and data.card:isCommonTrick()
    elseif event == fk.BeforeCardsMove then
      local id = 0
      local source = player
      local room = player.room
      local c
      for _, move in ipairs(data) do
        if move.to == player.id and move.toArea == Card.PlayerJudge then
          for _, info in ipairs(move.moveInfo) do
            id = info.cardId
            if info.fromArea == Card.PlayerJudge then
              source = room:getPlayerById(move.from) or player
            else
              source = player
            end
            c = source:getVirualEquip(id)
            --FIXME：巨大隐患，延时锦囊的virtual_equips在置入判定区的事件被篡改，或者判定阶段自然流程以外的方式离开判定区时不会清理
            if not c then c = Fk:getCardById(id) end
            if c.sub_type == Card.SubtypeDelayedTrick and c.color == Card.Black then
              return true
            end
          end
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.TargetConfirming then
      AimGroup:cancelTarget(data, player.id)
      return true
    elseif event == fk.BeforeCardsMove then
      local source = player
      local mirror_moves = {}
      local ids = {}
      for _, move in ipairs(data) do
        if move.to == player.id and move.toArea == Card.PlayerJudge then
          local move_info = {}
          local mirror_info = {}
          for _, info in ipairs(move.moveInfo) do
            local id = info.cardId
            if info.fromArea == Card.PlayerJudge then
              source = room:getPlayerById(move.from) or player
            else
              source = player
            end
            local c = source:getVirualEquip(id)
            if not c then c = Fk:getCardById(id) end
            if c.sub_type == Card.SubtypeDelayedTrick and c.color == Card.Black then
              table.insert(mirror_info, info)
              table.insert(ids, id)
            else
              table.insert(move_info, info)
            end
          end
          if #mirror_info > 0 then
            move.moveInfo = move_info
            local mirror_move = table.clone(move)
            mirror_move.to = nil
            mirror_move.toArea = Card.DiscardPile
            mirror_move.moveInfo = mirror_info
            table.insert(mirror_moves, mirror_move)
          end
        end
      end
      table.insertTable(data, mirror_moves)
    end
  end
}

jiaxu:addSkill(weimu)
Fk:loadTranslationTable{
  ['hs__jiaxu'] = '贾诩',
  ["#hs__jiaxu"] = "冷酷的毒士",
  ["illustrator:hs__jiaxu"] = "绘聚艺堂",

  ['hs__weimu'] = '帷幕',
  [':hs__weimu'] = '锁定技，当你成为黑色锦囊牌的目标时，取消之。',

  ["$hs__weimu1"] = "此计伤不到我。",
  ["$hs__weimu2"] = "你奈我何！",
  ["~hs__jiaxu"] = "我的时辰也到了……",
}

local pangde = General(extension, "hs__pangde", "qun", 4)

local jianchu = fk.CreateTriggerSkill{
  name = "jianchu",
  anim_type = "offensive",
  events = {fk.TargetSpecified},
  can_trigger = function(self, event, target, player, data)
    if not (target == player and player:hasSkill(self)) then return end
    local to = player.room:getPlayerById(data.to)
    return data.card.trueName == "slash" and not to:isNude()
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(data.to)
    local id = room:askForCardChosen(player, to, "he", self.name)
    room:throwCard({id}, self.name, to, player)
    local card = Fk:getCardById(id)
    if card.type == Card.TypeEquip then
      data.disresponsive = true
    else
      if not to.dead then
        local cardlist = Card:getIdList(data.card)
        if #cardlist > 0 and table.every(cardlist, function(id) return room:getCardArea(id) == Card.Processing end) then
          room:obtainCard(to.id, data.card, false)
        end
      end
    end
  end,
}

pangde:addSkill("mashu")
pangde:addSkill(jianchu)

Fk:loadTranslationTable{
  ["hs__pangde"] = "庞德",
  ["#hs__pangde"] = "人马一体",
  ["illustrator:hs__pangde"] = "凝聚永恒",

  ["jianchu"] = "鞬出",
  [":jianchu"] = "当你使用【杀】指定目标后，你可以弃置该角色的一张牌，若此牌：为装备牌，其不能使用【闪】抵消此【杀】；不为装备牌，其获得此【杀】。",

  ["$jianchu1"] = "你，可敢挡我！",
  ["$jianchu2"] = "我要杀你们个片甲不留！",
  ["~hs__pangde"] = "四面都是水……我命休矣。",
}
--]]
General:new(extension, "hs__zhangjiao", 'qun', 3):addSkills{"leiji", "guidao"}
Fk:loadTranslationTable{
  ['hs__zhangjiao'] = '张角',
  ["#hs__zhangjiao"] = "天公将军",
  ["illustrator:hs__zhangjiao"] = "LiuHeng",
  ["~hs__zhangjiao"] = "黄天…也死了……",
}
--[[
local caiwenji = General(extension, "hs__caiwenji", "qun", 3, 3, General.Female)
local duanchang = fk.CreateTriggerSkill{
  name = "hs__duanchang",
  anim_type = "control",
  frequency = Skill.Compulsory,
  events = {fk.Death},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self, false, true) and data.damage and data.damage.from and not data.damage.from.dead
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = data.damage.from ---@type ServerPlayer
    local choices = {}
    if not to.general:startsWith("blank_") then
      table.insert(choices, to.general ~= "anjiang" and to.general or "mainGeneral")
    end
    if not to.deputyGeneral:startsWith("blank_") then
      table.insert(choices, to.deputyGeneral ~= "anjiang" and to.deputyGeneral or "deputyGeneral")
    end
    if #choices == 0 then return false end
    local choice = room:askForChoice(player, choices, self.name, "#hs__duanchang-ask::" .. to.id)
    room:addTableMark(to, "@hs__duanchang", choice)
    local _g = (choice == "mainGeneral" or choice == to.general) and to.general or to.deputyGeneral
    if _g ~= "anjiang" then
      local skills = {}
      for _, skill_name in ipairs(Fk.generals[_g]:getSkillNameList(true)) do
        table.insertIfNeed(skills, skill_name)
      end
      if #skills > 0 then
        room:handleAddLoseSkills(to, "-"..table.concat(skills, "|-"), nil, true, false)
      end
    else
      _g = choice == "mainGeneral" and to:getMark("__heg_general") or to:getMark("__heg_deputy")
      local general = Fk.generals[_g]
      for _, s in ipairs(general:getSkillNameList()) do
        local skill = Fk.skills[s]
        to:loseFakeSkill(skill)
      end
      room:addTableMark(to, "_hs__duanchang_anjiang", _g)
    end
  end,

  refresh_events = {fk.GeneralShown},
  can_refresh = function(self, event, target, player, data)
    if target == player and type(player:getMark("_hs__duanchang_anjiang")) == "table" then
      for _, v in pairs(data) do
        if table.contains(player:getMark("_hs__duanchang_anjiang"), v) then return true end
      end
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local skills = {}
    for _, v in pairs(data) do
      if table.contains(player:getMark("_hs__duanchang_anjiang"), v) then
        for _, skill_name in ipairs(Fk.generals[v]:getSkillNameList(true)) do
          table.insertIfNeed(skills, skill_name)
        end
        if #skills > 0 then
          player.room:handleAddLoseSkills(player, "-"..table.concat(skills, "|-"), nil, true, false)
        end
      end
    end
  end,
}
caiwenji:addSkill("beige")
caiwenji:addSkill(duanchang)
Fk:loadTranslationTable{
  ["hs__caiwenji"] = "蔡文姬",
  ["#hs__caiwenji"] = "异乡的孤女",
  ["illustrator:hs__caiwenji"] = "SoniaTang",

  ["hs__duanchang"] = "断肠",
  [":hs__duanchang"] = "锁定技，当你死亡时，你令杀死你的角色失去一张武将牌上的所有技能。",

  ["#hs__duanchang-ask"] = "断肠：令 %dest 失去一张武将牌上的所有技能",
  ["@hs__duanchang"] = "断肠",

  ["$hs__duanchang1"] = "流落异乡愁断肠。",
  ["$hs__duanchang2"] = "日东月西兮徒相望，不得相随兮空断肠。",
  ["~hs__caiwenji"] = "人生几何时，怀忧终年岁。",
}

local mateng = General(extension, "hs__mateng", "qun", 4)

local xiongyi = fk.CreateActiveSkill{
  name = "xiongyi",
  anim_type = "drawcard",
  frequency = Skill.Limited,
  card_num = 0,
  target_num = 0,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local targets = table.map(table.filter(room.alive_players, function(p) return H.compareKingdomWith(p, player) end), Util.IdMapper)
    room:sortPlayersByAction(targets)
    for _, p in ipairs(targets) do
      p = room:getPlayerById(p)
      if not p.dead then
        p:drawCards(3, self.name)
      end
    end
    if player.dead or player.kingdom == "unknown" then return false end
    local kingdomMapper = H.getKingdomPlayersNum(room)
    local num = kingdomMapper[H.getKingdom(player)]
    for _, n in pairs(kingdomMapper) do
      if n < num then return false end
    end
    if player:isWounded() then
      room:recover({
        who = player,
        num = 1,
        recoverBy = player,
        skillName = self.name
      })
    end
  end,
}

local mateng_mashu = fk.CreateDistanceSkill{
  name = "heg_mateng__mashu",
  frequency = Skill.Compulsory,
  correct_func = function(self, from, to)
    if from:hasSkill(self) then
      return -1
    end
  end,
}
mateng:addSkill(mateng_mashu)
mateng:addSkill(xiongyi)

Fk:loadTranslationTable{
  ["hs__mateng"] = "马腾",
  ["#hs__mateng"] = "驰骋西陲",
  ["desinger:hs__mateng"] = "淬毒",
  ["illustrator:hs__mateng"] = "DH",

  ["xiongyi"] = "雄异",
  [":xiongyi"] = "限定技，出牌阶段，你可令与你势力相同的所有角色各摸三张牌，然后若你的势力角色数为全场最少，你回复1点体力。",
  ["heg_mateng__mashu"] = "马术",
  [":heg_mateng__mashu"] = "锁定技，你与其他角色的距离-1。",

  ["$xiongyi1"] = "弟兄们，我们的机会来啦！",
  ["$xiongyi2"] = "此时不战，更待何时！",
  ["~hs__mateng"] = "儿子，为爹报仇啊！",
}

local kongrong = General(extension, "hs__kongrong", "qun", 3)

local mingshi = fk.CreateTriggerSkill{
  name = "mingshi",
  anim_type = "defensive",
  events = {fk.DamageInflicted},
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.from and 
      (data.from.general == "anjiang" or data.from.deputyGeneral == "anjiang")
  end,
  on_use = function(self, event, target, player, data)
    data.damage = data.damage - 1
  end,
}
local lirang = fk.CreateTriggerSkill{
  name = "lirang",
  anim_type = "support",
  events = {fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self) then return false end
    for _, move in ipairs(data) do
      if move.from == player.id and move.moveReason == fk.ReasonDiscard and move.toArea == Card.DiscardPile then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip then
            return true
          end
        end
      end
    end
  end,
  on_trigger = function(self, event, target, player, data)
    for _, move in ipairs(data) do
      if not player:hasSkill(self) then break end
      if move.from == player.id and move.moveReason == fk.ReasonDiscard and move.toArea == Card.DiscardPile then
        local cids = {}
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip then
            table.insertIfNeed(cids, info.cardId)
          end
        end
        self:doCost(event, nil, player, cids)
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local ids = data
    local room = player.room
    local fakemove = {
      toArea = Card.PlayerHand,
      to = player.id,
      moveInfo = table.map(ids, function(id) return {cardId = id, fromArea = Card.DiscardPile} end),
      moveReason = fk.ReasonJustMove,
    }
    room:notifyMoveCards({player}, {fakemove})
    for _, id in ipairs(ids) do
      room:setCardMark(Fk:getCardById(id), "lirang", 1)
    end
    while table.find(ids, function(id) return Fk:getCardById(id):getMark("lirang") > 0 end) do
      if not room:askForUseActiveSkill(player, "#lirang_active", "#lirang-give", true) then
        for _, id in ipairs(ids) do
          room:setCardMark(Fk:getCardById(id), "lirang", 0)
        end
        ids = table.filter(ids, function(id) return room:getCardArea(id) ~= Card.PlayerHand end)
        fakemove = {
          from = player.id,
          toArea = Card.DiscardPile,
          moveInfo = table.map(ids, function(id) return {cardId = id, fromArea = Card.PlayerHand} end),
          moveReason = fk.ReasonGive,
        }
        room:notifyMoveCards({player}, {fakemove})
      end
    end
  end,
}
local lirang_active = fk.CreateActiveSkill{
  name = "#lirang_active",
  mute = true,
  min_card_num = 1,
  target_num = 1,
  card_filter = function(self, to_select, selected, targets)
    return Fk:getCardById(to_select):getMark("lirang") > 0
  end,
  target_filter = function(self, to_select, selected, selected_cards)
    return #selected == 0 and to_select ~= Self.id
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    room:doIndicate(player.id, {target.id})
    for _, id in ipairs(effect.cards) do
      room:setCardMark(Fk:getCardById(id), "lirang", 0)
    end
    local fakemove = {
      from = player.id,
      toArea = Card.DiscardPile,
      moveInfo = table.map(effect.cards, function(id) return {cardId = id, fromArea = Card.PlayerHand} end),
      moveReason = fk.ReasonGive,
    }
    room:notifyMoveCards({player}, {fakemove})
    room:moveCards({
      fromArea = Card.DiscardPile,
      ids = effect.cards,
      to = target.id,
      toArea = Card.PlayerHand,
      moveReason = fk.ReasonGive,
      skillName = self.name,
    })
  end,
}
lirang:addRelatedSkill(lirang_active)

kongrong:addSkill(mingshi)
kongrong:addSkill(lirang)

Fk:loadTranslationTable{
  ["hs__kongrong"] = "孔融",
  ["#hs__kongrong"] = "凛然重义",
  ["desinger:hs__kongrong"] = "淬毒",
  ["illustrator:hs__kongrong"] = "苍月白龙",

  ["mingshi"] = "名士",
  [":mingshi"] = "锁定技，当你受到伤害时，若来源有暗置的武将牌，你令伤害值-1。",
  ["lirang"] = "礼让",
  [":lirang"] = "当你的牌因弃置而移至弃牌堆后，你可将其中的至少一张牌交给其他角色。",

  ["#lirang-give"] = "礼让：你可以将这些牌分配给任意角色，点“取消”仍弃置",
  ["#lirang_active"] = "礼让",

  ["$mingshi1"] = "孔门之后，忠孝为先。",
  ["$mingshi2"] = "名士之风，仁义高洁。",
  ["$lirang1"] = "夫礼先王以承天之道，以治人之情。",
  ["$lirang2"] = "谦者，德之柄也，让者，礼之逐也。",
  ["~hs__kongrong"] = "覆巢之下，岂有完卵……",
}

local jiling = General(extension, "hs__jiling", "qun", 4)

local shuangren = fk.CreateTriggerSkill{
  name = "shuangren",
  anim_type = "offensive",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and player.phase == Player.Play and not player:isKongcheng() and table.find(player.room:getOtherPlayers(player, false), function(p)
      return not p:isKongcheng()
    end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local availableTargets = table.map(
      table.filter(room:getOtherPlayers(player, false), function(p)
        return not p:isKongcheng()
      end),
      Util.IdMapper
    )
    if #availableTargets == 0 then return false end
    local target = room:askForChoosePlayers(player, availableTargets, 1, 1, "#shuangren-ask", self.name, true)
    if #target > 0 then
      self.cost_data = target[1]
      return true
    end
    return false
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local target = room:getPlayerById(self.cost_data)
    local pindian = player:pindian({target}, self.name)
    if pindian.results[target.id].winner == player then
      if player.dead then return end
      local slash = Fk:cloneCard("slash")
      if player:prohibitUse(slash) then return false end
      local availableTargets = table.map(
        table.filter(room:getOtherPlayers(player, false), function(p)
          return H.compareKingdomWith(p, target) and not player:isProhibited(p, slash)
        end),
        Util.IdMapper
      )
      if #availableTargets == 0 then return false end
      local victims = room:askForChoosePlayers(player, availableTargets, 1, 1, "#shuangren_slash-ask:" .. target.id, self.name, false)
      if #victims > 0 then
        local to = room:getPlayerById(victims[1])
        if to.dead then return false end
        room:useVirtualCard("slash", nil, player, {to}, self.name, true)
      end
    else
      room:setPlayerMark(player, "shuangren-turn", 1)
    end
  end,
}

local shuangren_prohibit = fk.CreateProhibitSkill{
  name = "#shuangren_prohibit",
  is_prohibited = function(self, from, to, card)
    if from:hasSkill(self) then
      return from:getMark("shuangren-turn") > 0 and from ~= to
    end
  end,
}

shuangren:addRelatedSkill(shuangren_prohibit)
jiling:addSkill(shuangren)

Fk:loadTranslationTable{
  ["hs__jiling"] = "纪灵",
  ["#hs__jiling"] = "仲家的主将",
  ["illustrator:hs__jiling"] = "樱花闪乱",
  ["desinger:hs__jiling"] = "淬毒",

  ["shuangren"] = "双刃",
  [":shuangren"] = "出牌阶段开始时，你可与一名角色拼点。若你：赢，你视为对与其势力相同的一名角色使用【杀】；没赢，其他角色于此回合内不是你使用牌的合法目标。",

  ["#shuangren-ask"] = "双刃：你可与一名角色拼点",
  ["#shuangren_slash-ask"] = "双刃：你视为对与 %src 势力相同的一名角色使用【杀】",

  ["$shuangren1"] = "仲国大将纪灵在此！",
  ["$shuangren2"] = "吃我一记三尖两刃刀！",
  ["~hs__jiling"] = "额，将军为何咆哮不断……",
}

local tianfeng = General(extension, "hs__tianfeng", "qun", 3)

local sijian = fk.CreateTriggerSkill{
  name = "sijian",
  events = {fk.AfterCardsMove},
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self) or not player:isKongcheng() then return end
    local ret = false
    for _, move in ipairs(data) do
      if move.from == player.id then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerHand then
            ret = true
            break
          end
        end
      end
    end
    if ret then
      return table.find(player.room.alive_players, function(p) return not p:isNude() end)
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.map(table.filter(room.alive_players, function(p) return not p:isNude() end), Util.IdMapper)
    local target = room:askForChoosePlayers(player, targets, 1, 1, "#sijian-ask", self.name, true)
    if #target > 0 then
      self.cost_data = target[1]
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(self.cost_data)
    local id = room:askForCardChosen(player, to, "he", self.name)
    room:throwCard({id}, self.name, to, player)
  end,
}

local suishi = fk.CreateTriggerSkill{
  name = "suishi",
  frequency = Skill.Compulsory,
  events = {fk.EnterDying, fk.Death},
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self) or target == player then return false end
    if event == fk.EnterDying then
      return data.damage and data.damage.from and H.compareKingdomWith(data.damage.from, player)
    else
      return H.compareKingdomWith(target, player)
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.EnterDying then
      room:notifySkillInvoked(player, self.name, "drawcard")
      player:broadcastSkillInvoke(self.name, 1)
      player:drawCards(1, self.name)
    else
      room:notifySkillInvoked(player, self.name, "negative")
      player:broadcastSkillInvoke(self.name, 2)
      room:loseHp(player, 1, self.name)
    end
  end,
}

tianfeng:addSkill(sijian)
tianfeng:addSkill(suishi)

Fk:loadTranslationTable{
  ["hs__tianfeng"] = "田丰",
  ["#hs__tianfeng"] = "河北瑰杰",
  ["illustrator:hs__tianfeng"] = "地狱许",
  ["desinger:hs__tianfeng"] = "淬毒",

  ["sijian"] = "死谏",
  [":sijian"] = "当你失去手牌后，若你没有手牌，你可弃置一名其他角色的一张牌。",
  ["suishi"] = "随势",
  [":suishi"] = "锁定技，①当其他角色因受到伤害而进入濒死状态时，若来源与你势力相同，你摸一张牌；②当其他角色死亡时，若其与你势力相同，你失去1点体力。",

  ["#sijian-ask"] = "死谏：你可弃置一名其他角色的一张牌",

  ["$sijian2"] = "忠言逆耳啊！！",
  ["$sijian1"] = "且听我最后一言！",
  ["$suishi1"] = "一荣俱荣！",
  ["$suishi2"] = "一损俱损……",
  ["~hs__tianfeng"] = "不纳吾言而反诛吾心，奈何奈何！！",
}

local panfeng = General(extension, "hs__panfeng", "qun", 4)
local kuangfu = fk.CreateTriggerSkill{
  name = "hs__kuangfu",
  events = {fk.TargetSpecified},
  can_trigger = function (self, event, target, player, data)
    if player:hasSkill(self) and data.card and data.card.trueName == "slash" and player.phase == Player.Play and player:usedSkillTimes(self.name, Player.HistoryPhase) == 0 and target == player then
      for _, p in ipairs(AimGroup:getAllTargets(data.tos)) do
        if #player.room:getPlayerById(p):getCardIds(Player.Equip) > 0 then
          return true
        end
      end
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local choice = {}
    for _ , choicePlayers in ipairs(AimGroup:getAllTargets(data.tos)) do
      if #room:getPlayerById(choicePlayers):getCardIds("e") > 0 then
        table.insert(choice, choicePlayers)
      end
    end
    local p = room:askForChoosePlayers(player, choice, 1, 1, "#hs__kuangfu-choice", self.name, true)
    if #p == 0 then return end
    local card = room:askForCardChosen(player, room:getPlayerById(p[1]), "e", self.name)
    room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonPrey, self.name, nil, false, player.id)
    data.extra_data = data.extra_data or {}
    data.extra_data.hs__kuangfuUser = player.id
  end,
}

local kuangfu_delay = fk.CreateTriggerSkill{
  name = "#hs__kuangfu_delay",
  frequency = Skill.Compulsory,
  events = {fk.CardUseFinished},
  can_trigger = function (self, event, target, player, data)
    return (data.extra_data or {}).hs__kuangfuUser == player.id and not data.damageDealt
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    local room = player.room
    room:askForDiscard(player, 2, 2, true, self.name, false)
  end,
}

kuangfu:addRelatedSkill(kuangfu_delay)
panfeng:addSkill(kuangfu)
Fk:loadTranslationTable{
  ["hs__panfeng"] = "潘凤",
  ["#hs__panfeng"] = "联军上将",
  ["illustrator:hs__panfeng"] = "凡果",

  ["hs__kuangfu"] = "狂斧",
  [":hs__kuangfu"] = "当你于出牌阶段内使用【杀】指定目标后，若你于此阶段内未发动过此技能，你可获得此牌其中一个目标角色装备区内的一张牌，然后此牌结算后，若此牌未造成过伤害，你弃置两张牌。",


  ["#hs__kuangfu_delay"] = "狂斧",
  ["#hs__kuangfu-choice"] = "狂斧：选择一名装备区内有牌且是此牌目标的角色，获得其装备区内一张牌",
  ["$hs__kuangfu1"] = "吾乃上将潘凤，可斩华雄！",
  ["$hs__kuangfu2"] = "这家伙，还是给我用吧！",
  ["~hs__panfeng"] = "潘凤又被华雄斩啦。",
}
local zoushi = General(extension, "hs__zoushi", "qun", 3, 3, General.Female)
local huoshui = fk.CreateTriggerSkill{ -- FIXME
  name = "huoshui",
  anim_type = "control",
  frequency = Skill.Compulsory,
  events = {fk.TurnStart, fk.GeneralRevealed, fk.EventAcquireSkill, fk.EventLoseSkill, fk.Deathed, fk.CardUsing},
  can_trigger = function(self, event, target, player, data)
    if target ~= player or player.room.current ~= player then return false end
    if event == fk.TurnStart then
      return player:hasShownSkill(self)
    end
    if event == fk.EventAcquireSkill or event == fk.EventLoseSkill then
      return data == self
    elseif event == fk.GeneralRevealed then
      if player:hasSkill(self) then
        for _, v in pairs(data) do
          if table.contains(Fk.generals[v]:getSkillNameList(), self.name) then return true end
        end
      end
    elseif event == fk.CardUsing then
      return player:hasSkill(self)  and (data.card.trueName == "slash" or data.card.trueName == "archery_attack")
    else
      return player:hasSkill(self, true, true)
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if table.contains({fk.TurnStart, fk.GeneralRevealed, fk.EventAcquireSkill}, event) then
      local targets = {}
      local record
      for _, p in ipairs(room:getOtherPlayers(player, false)) do
        room:setPlayerMark(p, "@@huoshui-turn", 1)
        record = p:getTableMark(MarkEnum.RevealProhibited .. "-turn")
        table.insertTable(record, {"m", "d"})
        room:setPlayerMark(p, MarkEnum.RevealProhibited .. "-turn", record)
        table.insert(targets, p.id)
      end
      room:doIndicate(player.id, targets)
    elseif event == fk.CardUsing then
      local targets = table.filter(room.alive_players, function(p) return (not H.compareKingdomWith(p, player)) and H.getGeneralsRevealedNum(p) == 1 end)
      if #targets > 0 then
        data.disresponsiveList = data.disresponsiveList or {}
        for _, p in ipairs(targets) do
          table.insertIfNeed(data.disresponsiveList, p.id)
        end
      end
    else
      for _, p in ipairs(room:getOtherPlayers(player, false)) do
        room:setPlayerMark(p, "@@huoshui-turn", 0)
        local record = p:getTableMark(MarkEnum.RevealProhibited .. "-turn")
        table.removeOne(record, "m")
        table.removeOne(record, "d")
        if #record == 0 then record = 0 end
        room:setPlayerMark(p, MarkEnum.RevealProhibited .. "-turn", record)
      end
    end
  end,
}
local qingcheng = fk.CreateActiveSkill{
  name = "qingcheng",
  anim_type = "control",
  card_num = 1,
  target_num = 1,
  card_filter = function(self, to_select, selected, targets)
    return #selected == 0 and Fk:getCardById(to_select).color == Card.Black
  end,
  target_filter = function(self, to_select, selected, selected_cards)
    if #selected > 0 or #selected_cards == 0 then return false end --TODO
    local target = Fk:currentRoom():getPlayerById(to_select)
    return to_select ~= Self.id and target.general ~= "anjiang" and target.deputyGeneral ~= "anjiang"
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    local ret = false
    if Fk:getCardById(effect.cards[1]).type == Card.TypeEquip then
      ret = true
    end
    room:throwCard(effect.cards, self.name, player, player)
    H.doHideGeneral(room, player, target, self.name)
    if ret and not player.dead then
      local targets = table.filter(room.alive_players, function(p) return p.general ~= "anjiang" and p.deputyGeneral ~= "anjiang" and p ~= player and p ~= target end)
      if #targets == 0 then return false end
      local to = room:askForChoosePlayers(player, table.map(targets, Util.IdMapper), 1, 1, "#qingcheng-again", self.name, true)
      if #to > 0 then
        target = room:getPlayerById(to[1])
        H.doHideGeneral(room, player, target, self.name)
      end
    end
  end,
}
zoushi:addSkill(huoshui)
zoushi:addSkill(qingcheng)
Fk:loadTranslationTable{
  ["hs__zoushi"] = "邹氏",
  ["huoshui"] = "祸水",
  [":huoshui"] = "锁定技，你的回合内：1.其他角色不能明置其武将牌；2.当你使用【杀】或【万箭齐发】时，你令此牌不能被与你势力不同且有暗置武将牌的角色响应。",
  ["qingcheng"] = "倾城",
  [":qingcheng"] = "出牌阶段，你可弃置一张黑色牌并选择一名武将牌均明置的其他角色，然后你暗置其一张武将牌。然后若你以此法弃置的牌是黑色装备牌，则你可再选择另一名武将牌均明置的其他角色，暗置其一张武将牌。",

  ["@@huoshui-turn"] = "祸水",
  ["#qingcheng-again"] = "倾城：你可再选择另一名武将牌均明置的其他角色，暗置其一张武将牌",

  ["$huoshui1"] = "走不动了嘛？" ,
  ["$huoshui2"] = "别走了在玩一会嘛？" ,
  ["$qingcheng1"] = "我和你们真是投缘啊。",
  ["$qingcheng2"] = "哼，眼睛都直了呀。",
  ["~hs__zoushi"] = "年老色衰了吗？",
}
--]]
return extension
