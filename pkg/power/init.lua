local extension = Package:new("power")
extension.extensionName = "hegemony"
extension.game_modes_whitelist = { 'nos_heg_mode', 'new_heg_mode' }

extension:loadSkillSkelsByPath("./packages/hegemony/pkg/power/skills")

Fk:loadTranslationTable{
  ["power"] = "君临天下·权",
}

local cuiyanmaojie = General:new(extension, "ld__cuiyanmaojie", "wei", 3)
cuiyanmaojie:addSkills{"ld__zhengbi", "ld__fengying"}

cuiyanmaojie:addCompanions("hs__caopi")
Fk:loadTranslationTable{
  ["ld__cuiyanmaojie"] = "崔琰毛玠",
  ["#ld__cuiyanmaojie"] = "日出月盛",
  ["designer:ld__cuiyanmaojie"] = "Virgopaladin（韩旭）",
  ["illustrator:ld__cuiyanmaojie"] = "兴游",
  ["~ld__cuiyanmaojie"] = "为世所痛惜，冤哉……",
}

local yujin = General:new(extension, "ld__yujin", "wei", 4)
yujin:addSkill("ld__jieyue")
yujin:addCompanions("hs__xiahoudun")

Fk:loadTranslationTable{
  ['ld__yujin'] = '于禁',
  ["#ld__yujin"] = "讨暴坚垒",
  ["designer:ld__yujin"] = "Virgopaladin（韩旭）",
  ["illustrator:ld__yujin"] = "biou09",
  ["~ld__yujin"] = "此役一败，晚节不保啊……",
}

local wangping = General:new(extension, "ld__wangping", "shu", 4)
wangping:addCompanions("ld__jiangwanfeiyi")
wangping:addSkill("jianglue")

Fk:loadTranslationTable{
  ["ld__wangping"] = "王平",
  ["#ld__wangping"] = "键闭剑门",
  ["illustrator:ld__wangping"] = "zoo",
  ["~ld__wangping"] = "无当飞军，也有困于深林之时……",
}

local fazheng = General:new(extension, "ld__fazheng", "shu", 3)
fazheng:addCompanions("hs__liubei")
fazheng:addSkills{ "ld__xuanhuo","ld__enyuan"}
Fk:loadTranslationTable{
  ["ld__fazheng"] = "法正",
  ["#ld__fazheng"] = "蜀汉的辅翼",
  ["illustrator:ld__fazheng"] = "黑白画谱",

  ["~ld__fazheng"] = "汉室复兴，我，是看不到了……",
}

local lukang = General:new(extension, "ld__lukang", "wu", 3, 3, General.Male)
lukang:addSkills{"ld__keshou", "ld__zhuwei"}
lukang:addCompanions("hs__luxun")
Fk:loadTranslationTable{
  ["ld__lukang"] = "陆抗",
  ["#ld__lukang"] = "孤柱扶厦",
  ["illustrator:ld__lukang"] = "王立雄",
  ["~ld__lukang"] = "吾既亡矣，又能存几时…",
}

local wuguotai = General:new(extension, "ld__wuguotai", "wu", 3, 3, General.Female)
wuguotai:addSkills{"ld__buyi", "ganlu"}
wuguotai:addCompanions("hs__sunjian")

Fk:loadTranslationTable{
  ['ld__wuguotai'] = '吴国太',
  ["#ld__wuguotai"] = "武烈皇后",
  ["illustrator:ld__wuguotai"] = "李秀森",
  ["$ganlu_ld__wuguotai1"] = "玄德，实乃佳婿呀！", -- 特化
  ["$ganlu_ld__wuguotai2"] = "好一个郎才女貌，真是天作之合啊。",
  ["~ld__wuguotai"] = "诸位卿家，还请尽力辅佐仲谋啊……",
}

local yuanshu = General:new(extension, "ld__yuanshu", "qun", 4)
yuanshu:addCompanions("hs__jiling")
yuanshu:addSkills{"ld__yongsi", "ld__weidi"}

Fk:loadTranslationTable{
  ['ld__yuanshu'] = '袁术',
  ["#ld__yuanshu"] = "仲家帝",
  ["illustrator:ld__yuanshu"] = "YanBai",
  ["~ld__yuanshu"] = "可恶！就差……一步了……",
}

local zhangxiu = General:new(extension, "ld__zhangxiu", "qun", 4)

zhangxiu:addSkills{"ld__fudi", "ld__congjian"}
zhangxiu:addCompanions("hs__jiaxu")
Fk:loadTranslationTable{
  ['ld__zhangxiu'] = '张绣',
  ["#ld__zhangxiu"] = "北地枪王",
  ["designer:ld__zhangxiu"] = "千幻",
  ["illustrator:ld__zhangxiu"] = "青岛磐蒲",
  ['~ld__zhangxiu'] = '若失文和，吾将何归？',
}
--[[
local lordcaocao = General:new(extension, "ld__lordcaocao", "wei", 4)
lordcaocao.hidden = true
H.lordGenerals["hs__caocao"] = "ld__lordcaocao"

local jieyueJA = fk.CreateTriggerSkill{
  name = "jianan__ld__jieyue",
  anim_type = "control",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Start and not player:isKongcheng() and table.find(player.room.alive_players, function(p) return
      p.kingdom ~= "wei"
    end)
  end,
  on_cost = function(self, event, target, player, data)
    local plist, cid = player.room:askForChooseCardAndPlayers(player, table.map(table.filter(player.room.alive_players, function(p) return
      p.kingdom ~= "wei" and p ~= player
    end), Util.IdMapper), 1, 1, ".|.|.|hand", "#jianan__ld__jieyue-target", self.name, true)
    if #plist > 0 then
      self.cost_data = {plist[1], cid}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = self.cost_data[1]
    local target = room:getPlayerById(to)
    room:moveCardTo(self.cost_data[2], Player.Hand, target, fk.ReasonGive, self.name, nil, false, player.id)
    if H.askCommandTo(player, target, self.name) then
      player:drawCards(1, self.name)
    else
      room:addPlayerMark(player, "_jianan__ld__jieyue-turn")
    end
  end
}
local jieyue_drawJA = fk.CreateTriggerSkill{
  name = "#jianan__ld__jieyue_draw",
  mute = true,
  frequency = Skill.Compulsory,
  events = {fk.DrawNCards},
  can_use = function(self, event, target, player, data)
    return target == player and target:getMark("_jianan__ld__jieyue-turn") > 0
  end,
  on_use = function(self, event, target, player, data)
    data.n = data.n + 3 * target:getMark("_jianan__ld__jieyue-turn")
  end,
}

local tuxiJA = fk.CreateTriggerSkill{
  name = "jianan__ex__tuxi",
  anim_type = "control",
  events = {fk.DrawNCards},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.n > 0 and
      not table.every(player.room:getOtherPlayers(player, false), function(p) return p:isKongcheng() end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.map(table.filter(room:getOtherPlayers(player, false), function(p)
      return not p:isKongcheng() end), Util.IdMapper)
    local tos = room:askForChoosePlayers(player, targets, 1, data.n, "#jianan__ex__tuxi-choose:::"..data.n, self.name, true)
    if #tos > 0 then
      self.cost_data = tos
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    for _, id in ipairs(self.cost_data) do
      local c = room:askToChooseCard(player, {
    target = room:getPlayerById(id),
    flag = "h",
    skill_name = self.name,
  })
      room:obtainCard(player, c, false, fk.ReasonPrey)
    end
    data.n = data.n - #self.cost_data
  end,
}

local qiaobianJA = fk.CreateTriggerSkill{
  name = "jianan__qiaobian",
  anim_type = "offensive",
  events = {fk.EventPhaseChanging},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and not player:isKongcheng() and
    data.to > Player.Start and data.to < Player.Finish
  end,
  on_cost = function(self, event, target, player, data)
    local phase_name_table = {
      [3] = "phase_judge",
      [4] = "phase_draw",
      [5] = "phase_play",
      [6] = "phase_discard",
    }
    local card = player.room:askForDiscard(player, 1, 1, false, self.name, true, ".", "#jianan__qiaobian-invoke:::" .. phase_name_table[data.to], true)
    if #card > 0 then
      self.cost_data = card
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:throwCard(self.cost_data, self.name, player, player)
    player:skip(data.to)
    if data.to == Player.Draw then
      local targets = table.map(table.filter(room:getOtherPlayers(player, false), function(p)
        return not p:isKongcheng() end), Util.IdMapper)
      if #targets > 0 then
        local n = math.min(2, #targets)
        local tos = room:askForChoosePlayers(player, targets, 1, n, "#jianan__qiaobian-choose:::"..n, self.name, true)
        if #tos > 0 then
          room:sortPlayersByAction(tos)
          for _, id in ipairs(tos) do
            local p = room:getPlayerById(id)
            if not p:isKongcheng() then
              local card_id = room:askToChooseCard(player, {
    target = p,
    flag = "h",
    skill_name = self.name,
  })
              room:obtainCard(player, card_id, false, fk.ReasonPrey)
            end
          end
        end
      end
    elseif data.to == Player.Play then
      local targets = room:askForChooseToMoveCardInBoard(player, "#jianan__qiaobian-move", self.name, true, nil)
      if #targets ~= 0 then
        targets = table.map(targets, function(id) return room:getPlayerById(id) end)
        room:askForMoveCardInBoard(player, targets[1], targets[2], self.name)
      end
    end
    return true
  end,
}

local xiaoguoJA = fk.CreateTriggerSkill{
  name = "jianan__hs__xiaoguo",
  anim_type = "offensive",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target ~= player and player:hasSkill(self) and target.phase == Player.Finish and not player:isKongcheng()
  end,
  on_cost = function(self, event, target, player, data)
    local card = player.room:askForDiscard(player, 1, 1, true, self.name, true, ".|.|.|.|.|basic", "#jianan__hs__xiaoguo-invoke::"..target.id, true)
    if #card > 0 then
      self.cost_data = card
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:throwCard(self.cost_data, self.name, player, player)
    if #room:askForDiscard(target, 1, 1, true, self.name, true, ".|.|.|.|.|equip", "#jianan__hs__xiaoguo-discard:"..player.id) == 0 then
      room:damage{
        from = player,
        to = target,
        damage = 1,
        skillName = self.name,
      }
    else
      player:drawCards(1, self.name)
    end
  end,
}

local duanliangJA = fk.CreateViewAsSkill{
  name = "jianan__hs__duanliang",
  anim_type = "control",
  pattern = "supply_shortage",
  card_filter = function(self, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).color == Card.Black and Fk:getCardById(to_select).type ~= Card.TypeTrick
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 then
      return nil
    end
    local c = Fk:cloneCard("supply_shortage")
    c.skillName = self.name
    c:addSubcard(cards[1])
    return c
  end,
  before_use = function(self, player, use)
    local targets = TargetGroup:getRealTargets(use.tos)
    if #targets == 0 then return end
    local room = player.room
    for _, p in ipairs(targets) do
      if player:distanceTo(room:getPlayerById(p)) > 2 then
        room:setPlayerMark(player, "@@jianan__hs__duanliang-phase", 1)
      end
    end
  end
}
local duanliang_targetmodJA = fk.CreateTargetModSkill{
  name = "#jianan__hs__duanliang_targetmod",
  distance_limit_func =  function(self, player, skill)
    if player:hasSkill(duanliangJA) and skill.name == "supply_shortage_skill" then
      return 99
    end
  end,
}
local duanliang_invalidityJA = fk.CreateInvaliditySkill {
  name = "#jianan__hs__duanlianginvalidity",
  invalidity_func = function(self, from, skill)
    return from:getMark("@@jianan__hs__duanliang-phase") > 0 and
      skill.name == "jianan__hs__duanliang"
  end
}

local jianan = fk.CreateTriggerSkill{
  name = "jianan",
  anim_type = "support",
  frequency = Skill.Compulsory,
  events = {fk.EventPhaseStart},
  can_trigger = function (self, event, target, player, data)
    if not (target == player and not target:isNude() and target.phase == Player.Start) then return end
    local lord = H.getHegLord(player.room, player)
    if lord and lord:hasSkill(self) then return true end
  end,
  on_cost = function (self, event, target, player, data)
    if #player.room:askForDiscard(target, 1, 1, true, self.name, true, nil, "#jianan-ask") > 0 then
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local isDeputy = false
    if H.getGeneralsRevealedNum(target) == 1 then
      if target.general ~= "anjiang" then
        isDeputy = true
      elseif target.deputyGeneral ~= "anjiang" then
        isDeputy = false
      end
    elseif H.getGeneralsRevealedNum(target) == 2 then 
      isDeputy = H.doHideGeneral(room, target, target, self.name)
    end
    local record = target:getTableMark(MarkEnum.RevealProhibited)
    table.insert(record, isDeputy and "d" or "m")
    room:setPlayerMark(target, MarkEnum.RevealProhibited, record)

    local all_choices = {"jianan__ld__jieyue", "jianan__ex__tuxi", "jianan__qiaobian", "jianan__hs__duanliang", "jianan__hs__xiaoguo"}
    local choices = {}
    local skills = {}
    for _, p in ipairs(room.alive_players) do
      for _, s in ipairs(p.player_skills) do
        table.insert(skills, s.name)
      end
    end
    for _, skill in ipairs(all_choices) do
      local skillNames = {skill, skill:sub(9)}
      local can_choose = true
      for _, sname in ipairs(skills) do
        if table.contains(skillNames, sname) then
          can_choose = false
          break
        end
      end
      if can_choose then table.insert(choices, skill) end
    end
    if #choices == 0 then return false end
    local result = room:askForCustomDialog(target, self.name,
    "packages/utility/qml/ChooseSkillBox.qml", {
      choices, 1, 1, "#jianan-choice"
    })
    if result == "" then return false end
    local choice = json.decode(result)[1]
    room:handleAddLoseSkills(target, choice, nil)
    record = target:getTableMark("@jianan_skills")
    table.insert(record, choice)
    room:setPlayerMark(target, "@jianan_skills", record)
  end,
}

local jiananOtherLose = fk.CreateTriggerSkill{
  name = "#jianan_other_lose&",
  visible = false,
  refresh_events = {fk.TurnStart, fk.Death},
  can_refresh = function(self, event, target, player, data)
    if event == fk.TurnStart then
      return target == player and player:hasSkill(jianan)
    end
    if event == fk.Death then
      return player:hasSkill(jianan, false, true) and player == target
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    for _, p in ipairs(room.alive_players) do
      local _skills = p:getMark("@jianan_skills")
      if _skills ~= 0 then
        local skills = "-" .. table.concat(_skills, "|-")
        room:handleAddLoseSkills(p, skills, nil)
        room:setPlayerMark(p, "@jianan_skills", 0)
      end
      room:setPlayerMark(p, MarkEnum.RevealProhibited, 0)
    end
  end,
}

local huibian = fk.CreateActiveSkill{
  name = "huibian",
  anim_type = "control",
  target_num = 2,
  card_num = 0,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, to_select, selected)
    if #selected == 0 then
      local target2 = Fk:currentRoom():getPlayerById(to_select)
      return target2.kingdom == "wei"
    elseif #selected == 1 then
      local target1 = Fk:currentRoom():getPlayerById(to_select)
      return target1.kingdom == "wei" and target1:isWounded()
    else
      return false
    end
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target1 = room:getPlayerById(effect.tos[1])
    local target2 = room:getPlayerById(effect.tos[2])
    room:damage{
      from = player,
      to = target1,
      damage = 1,
      skillName = self.name,
    }
    if not target1.dead then
      target1:drawCards(2, self.name)
    end
    if not target2.dead and target2:isWounded() then
      room:recover{
        who = target2,
        num = 1,
        recoverBy = player,
        skillName = self.name
      }
    end
  end,
}

local zongyu = fk.CreateTriggerSkill{
  name = "zongyu",
  anim_type = 'defensive',
  events = {fk.CardUsing, fk.AfterCardsMove},
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self) then return false end
    if event == fk.AfterCardsMove then
      for _, move in ipairs(data) do
        if move.to ~= player.id and move.toArea == Card.PlayerEquip then
          for _, info in ipairs(move.moveInfo) do
            if Fk:getCardById(info.cardId).name == "liulongcanjia" then
              return true
            end
          end
        end
      end
    else
      if (data.card.sub_type == Card.SubtypeOffensiveRide or data.card.sub_type == Card.SubtypeDefensiveRide) and data.card.name ~= "liulongcanjia" and target == player then
        if #player.room:getCardsFromPileByRule("liulongcanjia", 1, "discardPile") > 0 then return true end
        return table.find(Fk:currentRoom().alive_players, function(p)
          return p ~= player and table.find(p:getEquipments(Card.SubtypeDefensiveRide), function(cid) return Fk:getCardById(cid).name == "liulongcanjia" end)
        end)
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    if event == fk.CardUsing then
      return true
    else
      return player.room:askToSkillInvoke(player, {
      skill_name = self.name,
      prompt = "#zongyu-ask",
    })
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    if event == fk.AfterCardsMove then
      for _, move in ipairs(data) do
        if move.to ~= player.id and move.toArea == Card.PlayerEquip then
          for _, info in ipairs(move.moveInfo) do
            if Fk:getCardById(info.cardId).name == "liulongcanjia" then
              local cards1 = {player:getEquipment(Fk:getCardById(info.cardId).sub_type)}
              local cards2 = {info.cardId}
              local move1 = {
                from = player.id,
                ids = cards1,
                toArea = Card.Processing,
                moveReason = fk.ReasonJustMove,
                proposer = player.id,
                skillName = self.name,
              }
              local move2 = {
                from = move.to,
                ids = cards2,
                toArea = Card.Processing,
                moveReason = fk.ReasonJustMove,
                proposer = player.id,
                skillName = self.name,
              }
              room:moveCards(move1, move2)
              local move3 = {
                ids = table.filter(cards1, function(id) return room:getCardArea(id) == Card.Processing end),
                fromArea = Card.Processing,
                to = move.to,
                toArea = Card.PlayerEquip,
                moveReason = fk.ReasonJustMove,
                proposer = player.id,
                skillName = self.name,
              }
              local move4 = {
                ids = table.filter(cards2, function(id) return room:getCardArea(id) == Card.Processing end),
                fromArea = Card.Processing,
                to = player.id,
                toArea = Card.PlayerEquip,
                moveReason = fk.ReasonJustMove,
                proposer = player.id,
                skillName = self.name,
              }
              room:moveCards(move3, move4)
              break
            end
          end
        end
      end
    else
      local to_throw = {data.card.id}
      if player:getEquipment(Card.SubtypeDefensiveRide) then
        table.insert(to_throw, player:getEquipment(Card.SubtypeDefensiveRide))
      end
      if player:getEquipment(Card.SubtypeOffensiveRide) then
        table.insert(to_throw, player:getEquipment(Card.SubtypeOffensiveRide))
      end
      room:moveCardTo(to_throw, Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile, self.name, nil, true, player.id)
      local card = room:getCardsFromPileByRule("liulongcanjia", 1, "discardPile")
      if #card == 0 then
        for _, p in ipairs(room:getOtherPlayers(player, false)) do
          for _, cid in ipairs(p:getEquipments(Card.SubtypeDefensiveRide)) do
            if Fk:getCardById(cid).name == "liulongcanjia" then
              card = {cid}
              break
            end
          end
          if #card > 0 then break end
        end
      end
      if #card > 0 then
        room:moveCardTo(card, Card.PlayerEquip, player, fk.ReasonJustMove, self.name)
      end
    end
  end,
}

jieyueJA:addRelatedSkill(jieyue_drawJA)
duanliangJA:addRelatedSkill(duanliang_targetmodJA)
duanliangJA:addRelatedSkill(duanliang_invalidityJA)
jianan:addRelatedSkill(jiananOtherLose)

lordcaocao:addRelatedSkill(jieyueJA)
lordcaocao:addRelatedSkill(tuxiJA)
lordcaocao:addRelatedSkill(qiaobianJA)
lordcaocao:addRelatedSkill(xiaoguoJA)
lordcaocao:addRelatedSkill(duanliangJA)
lordcaocao:addSkill(jianan)
lordcaocao:addSkill(huibian)
lordcaocao:addSkill(zongyu)

Fk:loadTranslationTable{
  ["ld__lordcaocao"] = "君曹操",
  ["#ld__lordcaocao"] = "凤舞九霄",
  ["illustrator:ld__lordcaocao"] = "波子",
  ["zongyu"] = "总御",
  [":zongyu"] = "锁定技，①当你使用坐骑牌时，若其他角色的装备区内或弃牌堆内有【六龙骖驾】，你将原坐骑牌置入弃牌堆，将【六龙骖驾】置入你的装备区内；"..
  "②当【六龙骖驾】移动至其他角色的装备区内后，你可交换你与其装备区内的防御坐骑牌。",
  ["jianan"] = "建安",
  [":jianan"] = "<b><font color='goldenrod'>君主技</font></b>，你拥有“五子良将纛”。<br>" ..
  "#<b>五子良将纛</b>：魏势力角色的准备阶段，其可弃置一张牌并选择一张暗置的武将牌或暗置两张已明置武将牌中的其中一张，" ..
  "若如此做，其获得〖节钺〗、〖突袭〗、〖巧变〗、〖骁果〗、〖断粮〗中一个场上没有的技能，"..
  "且不能明置以此法选择或暗置的武将牌，直至你回合开始。",
  ["huibian"] = "挥鞭",
  [":huibian"] = "出牌阶段限一次，你可选择一名魏势力角色和另一名已受伤的魏势力角色，若如此做，你对前者造成1点伤害，令其摸两张牌，然后后者回复1点体力。",

  ["#jianan-ask"] = "五子良将纛：你可弃置一张牌，暗置一张武将牌，选择获得〖节钺〗〖突袭〗〖巧变〗〖骁果〗〖断粮〗",
  ["#jianan-choice"] = "五子良将纛：获得以下一个技能",

  ["@jianan_skills"] = "良将纛",

  ["#zongyu-ask"] = "总御：是否交换你与其装备区内的所有防御坐骑牌",

  ["jianan__ld__jieyue"] = "节钺",
  [":jianan__ld__jieyue"] = "准备阶段，你可将一张手牌交给不是魏势力或没有势力的一名角色，对其发起军令。若其：执行，你摸一张牌；不执行，摸牌阶段，你令额定摸牌数+3。",
  ["#jianan__ld__jieyue-target"] = "节钺：你可将一张手牌交给不是魏势力或没有势力的一名角色，对其发起军令",
  ["#jianan__ld__jieyue_draw"] = "节钺",

  ["jianan__ex__tuxi"] = "突袭",
  [":jianan__ex__tuxi"] = "摸牌阶段，你可以少摸任意张牌并获得等量其他角色各一张手牌。",
  ["#jianan__ex__tuxi-choose"] = "突袭：你可以少摸至多%arg张牌，获得等量其他角色各一张手牌",

  ["jianan__qiaobian"] = "巧变",
  [":jianan__qiaobian"] = "你的阶段开始前（准备阶段和结束阶段除外），你可以弃置一张手牌跳过该阶段。若以此法跳过摸牌阶段，"..
  "你可以获得至多两名其他角色的各一张手牌；若以此法跳过出牌阶段，你可以将场上的一张牌移动至另一名角色相应的区域内。",
  ["#jianan__qiaobian-invoke"] = "巧变：你可以弃一张手牌，跳过 %arg",
  ["#jianan__qiaobian-choose"] = "巧变：你可以依次获得%arg名角色的各一张手牌",
  ["#jianan__qiaobian-move"] = "巧变：请选择两名角色，移动场上的一张牌",

  ["jianan__hs__duanliang"] = "断粮",
  [":jianan__hs__duanliang"] = "你可将一张不为锦囊牌的黑色牌当【兵粮寸断】使用（无距离关系的限制），若你至目标对应的角色的距离大于2，此技能于此阶段内无效。",
  ["@@jianan__hs__duanliang-phase"] = "断粮 无效",

  ["jianan__hs__xiaoguo"] = "骁果",
  [":jianan__hs__xiaoguo"] = "其他角色的结束阶段，你可以弃置一张基本牌，然后其选择一项：1.弃置一张装备牌，然后你摸一张牌；2.你对其造成1点伤害。",
  ["#jianan__hs__xiaoguo-invoke"] = "骁果：你可以弃置一张基本牌，%dest 需弃置一张装备牌，否则你对其造成1点伤害",
  ["#jianan__hs__xiaoguo-discard"] = "骁果：你需弃置一张装备牌，否则 %src 对你造成1点伤害",

  ["$jianan1"] = "设使天下无孤，不知几人称帝，几人称王。",
  ["$jianan2"] = "行为军锋，还为后拒！",
  ["$jianan3"] = "国之良将，五子为先！",
  ["$huibian1"] = "吾任天下之智力，以道御之，无所不可。",
  ["$huibian2"] = "青青子衿，悠悠我心，但为君故，沉吟至今。",
  ["$zongyu1"] = "驾六龙，乘风而行。行四海，路下之八邦。",
  ["$zongyu2"] = "齐桓之功，为霸之首，九合诸侯，一匡天下。",
  ["$jianan__ld__jieyue1"] = "孤之股肱，谁敢不从？嗯？",
  ["$jianan__ld__jieyue2"] = "泰山之高，群山不可及，文则之重，泰山不可及！",
  ["$jianan__ex__tuxi1"] = "以百破万，让孤再看一次！",
  ["$jianan__ex__tuxi2"] = "望将军身影，可治孤之头风病。",
  ["$jianan__qiaobian1"] = "孤之兵道，此一时，彼一时。",
  ["$jianan__qiaobian2"] = "时变，势变，孤唯才是举！",
  ["$jianan__hs__duanliang1"] = "孤以为断粮如断肠，卿意下如何？",
  ["$jianan__hs__duanliang2"] = "卿名为“亚夫”，实为冠军也！",
  ["$jianan__hs__xiaoguo1"] = "使孤梦回辽东者，卿之雄风也！",
  ["$jianan__hs__xiaoguo2"] = "得贤人共治天下，得将军共定天下！",
  ["~ld__lordcaocao"] = "神龟虽寿，犹有竟时。腾蛇乘雾，终为土灰。",
}
--]]
return extension
