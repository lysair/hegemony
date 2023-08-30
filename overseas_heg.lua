local extension = Package:new("overseas_heg")
extension.extensionName = "hegemony"
extension.game_modes_whitelist = { 'nos_heg_mode', 'new_heg_mode' }

local H = require "packages/hegemony/util"

Fk:loadTranslationTable{
  ["overseas_heg"] = "国际服-国战专属",
  ["os_heg"] = "国际",
}

local yangxiu = General(extension, "os_heg__yangxiu", "wei", 3)
yangxiu:addSkill("danlao")
yangxiu:addSkill("jilei")
Fk:loadTranslationTable{
  ['os_heg__yangxiu'] = '杨修',
  ["~os_heg__yangxiu"] = "我固自以死之晚也……",
}

local fuwan = General(extension, "os_heg__fuwan", "qun", 4)
fuwan:addSkill("moukui")
Fk:loadTranslationTable{
  ['os_heg__fuwan'] = '伏完',
  ["~os_heg__fuwan"] = "后会有期……",
}
--[[
local huaxiong = General(extension, "os_heg__huaxiong", "qun", 4)

local yaowu = fk.CreateTriggerSkill{
  name = "os_heg__yaowu",
  frequency = Skill.Limited,
  events = {fk.Damage},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and player:usedSkillTimes(self.name, Player.HistoryGame) == 0 and not table.contains(player.player_skills, self) 
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:changeMaxHp(player, 2)
    room:recover({
      who = player,
      num = 2,
      recoverBy = player,
      skillName = self.name
    })
  end,
}
local yaowuDeath = fk.CreateTriggerSkill{
  name = "#os_heg__yaowu_death",
  events = {fk.Deathed},
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:usedSkillTimes(yaowu.name, Player.HistoryGame) > 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local targets = table.map(table.filter(room.alive_players, function(p) return H.compareKingdomWith(p, player) end), Util.IdMapper)
    if #targets == 0 then return end
    room:doIndicate(player.id, targets)
    room:sortPlayersByAction(targets)
    for _, pid in ipairs(targets) do
      local p = room:getPlayerById(pid)
      if not p.dead then
        room:loseHp(p, 1, self.name)
      end
    end
  end,
}
yaowu:addRelatedSkill(yaowuDeath)

local shiyong = fk.CreateTriggerSkill{
  name = "os_heg__shiyong",
  frequency = Skill.Compulsory,
  events = {fk.Damaged},
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and data.card
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke(self.name)
    if player:usedSkillTimes(yaowu.name, Player.HistoryGame) == 0 then
      if data.card.color ~= Card.Red then
        room:notifySkillInvoked(player, self.name, "drawcard")
        player:drawCards(1, self.name)
      end
    elseif data.card.color ~= Card.Black and data.from and not data.from.dead then
      room:notifySkillInvoked(player, self.name, "negative")
      data.from:drawCards(1, self.name)
    end
  end,
}

huaxiong:addSkill(yaowu)
huaxiong:addSkill(shiyong)

Fk:loadTranslationTable{
  ['os_heg__huaxiong'] = '华雄',
  ["os_heg__yaowu"] = "耀武",
  [":os_heg__yaowu"] = "限定技，当你造成伤害后，你可明置此武将牌，加2点体力上限，回复2点体力，“升级”〖恃勇〗，且当你死亡后，与你势力相同的角色各失去1点体力。",
  ["os_heg__shiyong"] = "恃勇",
  [":os_heg__shiyong"] = "锁定技，当你受到伤害后，1级：若造成伤害的牌不为红色，你摸一张牌；2级：若造成伤害的牌不为黑色，伤害来源摸一张牌。",

  ["#os_heg__yaowu_death"] = "耀武",

  ["$os_heg__yaowu1"] = "潘凤已被我斩了，谁还来领死！",
  ["$os_heg__yaowu2"] = "十八路诸侯？！哼！乌合之众。",
  ["$os_heg__shiyong1"] = "你们不要笑得太早。",
  ["$os_heg__shiyong2"] = "哼，不痛不痒。",
  ["~os_heg__huaxiong"] = "我掉以轻心了……",
}
]]

local himiko = General(extension, "os_heg__himiko", "qun", 3, 3, General.Female)

local guishu = fk.CreateViewAsSkill{
  name = "guishu",
  pattern = "known_both,befriend_attacking",
  anim_type = "drawcard",
  interaction = function()
    local names = {}
    local all_choices = {"befriend_attacking", "known_both"}
    for _, name in ipairs(all_choices) do
      if Self:getMark("_guishu-turn") ~= name and Self:canUse(Fk:cloneCard(name)) then
        table.insertIfNeed(names, name)
      end
    end
    if #names == 0 then return end
    return UI.ComboBox {choices = names, all_choices = all_choices }
  end,
  card_filter = function(self, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).suit == Card.Spade
  end,
  view_as = function(self, cards)
    if #cards ~= 1 or self.interaction.data == nil then return end
    local card = Fk:cloneCard(self.interaction.data)
    card.skillName = self.name
    card:addSubcard(cards[1])
    return card
  end,
  before_use = function(self, player, use)
    player.room:setPlayerMark(player, "_guishu-turn", use.card.name)
  end
}

local yuanyuk = fk.CreateTriggerSkill{
  name = "yuanyuk",
  anim_type = "defensive",
  frequency = Skill.Compulsory,
  events = {fk.DamageInflicted},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and data.from and not data.from:inMyAttackRange(target)
  end,
  on_use = function(self, event, target, player, data)
    data.damage = data.damage - 1
  end
}

himiko:addSkill(guishu)
himiko:addSkill(yuanyuk)

Fk:loadTranslationTable{
  ['os_heg__himiko'] = '卑弥呼', -- 十年心版
  ["guishu"] = "鬼术",
  [":guishu"] = "出牌阶段，你可将一张♠手牌当【远交近攻】或【知己知彼】使用（不可与你此回合上一次以此法使用的牌相同）。",
  ["yuanyuk"] = "远域",
  [":yuanyuk"] = "锁定技，当你受到伤害时，若有伤害来源且你不在伤害来源的攻击范围内，此伤害-1。",

  ["$guishu1"] = "契约已定！",
  ["$guishu2"] = "准备好，听候女王的差遣了吗？",
  ["$yuanyuk1"] = "是你，在召唤我吗？",
  ["$yuanyuk2"] = "这片土地的人，真是太有趣了。",
  ["~os_heg__himiko"] = "我还会从黄泉比良坂回来的……",
}
return extension
