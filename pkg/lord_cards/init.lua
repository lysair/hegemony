local extension = Package:new("lord_cards", Package.CardPack)
extension.extensionName = "hegemony"
extension:loadSkillSkelsByPath("./packages/hegemony/pkg/lord_cards/skills")

Fk:loadTranslationTable{
  ["lord_cards"] = "君临天下卡牌",
}

extension.game_modes_whitelist = { 'new_heg_mode', 'nos_heg_mode' }

local H = require "packages/hegemony/util"

local dragonPhoenix = fk.CreateCard{
  name = "dragon_phoenix",
  type = Card.TypeEquip,
  sub_type = Card.SubtypeWeapon,
  attack_range = 2,
  equip_skill = "#dragon_phoenix_skill",
}
H.addCardToConvertCards("dragon_phoenix", "double_swords")

extension:addCardSpec("dragon_phoenix", Card.Spade, 2)

local peaceSpell = fk.CreateCard{
  name = "peace_spell",
  type = Card.TypeEquip,
  sub_type = Card.SubtypeWeapon,
  equip_skill = "#peace_spell_skill",
}
H.addCardToConvertCards("peace_spell", "jingfan")

extension:addCardSpec("peace_spell", Card.Heart, 3)

local luminousPearl = fk.CreateCard{
  name = "luminous_pearl",
  type = Card.TypeEquip,
  sub_type = Card.SubtypeTreasure,
  equip_skill = "luminous_pearl_skill",
  on_install = function(self, room, player)
    Treasure.onInstall(self, room, player)
    if (player:hasSkill("hs__zhiheng") or player:hasSkill("ld__lordsunquan_zhiheng") or player:hasSkill("wk_heg__zhiheng")) then
      room:handleAddLoseSkills(player, "-luminous_pearl_skill", nil, false, true)
    end
  end,
}
H.addCardToConvertCards("luminous_pearl", "six_swords")

extension:addCardSpec("luminous_pearl", Card.Diamond, 6)

local liulongcanjia = fk.CreateCard{
  name = "liulongcanjia",
  type = Card.TypeEquip,
  sub_type = Card.SubtypeDefensiveRide,
  equip_skill = "#liulongcanjia_skill",

  on_install = function(self, room, player)
    local cards = player:getEquipments(Card.SubtypeOffensiveRide)
    if #cards > 0 then room:moveCardTo(cards, Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile, self.name, nil, true, player.id) end
    DefensiveRide.onInstall(self, room, player)
    room:setPlayerMark(player, "@@liulongcanjia", 1) -- 绷
  end,
  on_uninstall = function(self, room, player)
    DefensiveRide.onUninstall(self, room, player)
    room:setPlayerMark(player, "@@liulongcanjia", 0)
  end,
}
H.addCardToConvertCards("liulongcanjia", "zhuahuangfeidian")

extension:addCardSpec("liulongcanjia", Card.Heart, 13)

extension:loadCardSkels{
  dragonPhoenix, peaceSpell, luminousPearl, liulongcanjia
}

Fk:loadTranslationTable{
  ["dragon_phoenix"] = "飞龙夺凤",
  [":dragon_phoenix"] = "装备牌·武器<br/><b>攻击范围</b>：２ <br/><b>武器技能</b>：①当你使用【杀】指定目标后，你可令目标弃置一张牌。②当一名角色因执行你使用的【杀】的效果而受到你造成的伤害而进入濒死状态后，你可获得其一张手牌。",

  ["peace_spell"] = "太平要术",
  [":peace_spell"] = "装备牌·防具<br /><b>防具技能</b>：锁定技，①当你受到属性伤害时，你防止此伤害。②你的手牌上限+X（X为与你势力相同的角色数）。③当你失去装备区里的【太平要术】后，你摸两张牌，然后若你的体力值大于1，你失去1点体力。",

  ["luminous_pearl"] = "定澜夜明珠",
  [":luminous_pearl"] = "装备牌·宝物<br/><b>宝物技能</b>：锁定技，若你没有〖制衡〗，你视为拥有〖制衡〗；若你有〖制衡〗，取消〖制衡〗的数量限制。",

  ["liulongcanjia"] = "六龙骖驾",
  [":liulongcanjia"] = "装备牌·坐骑<br /><b>坐骑技能</b>：锁定技，其他角色与你的距离+1，你与其他角色的距离-1；当【六龙骖驾】移至你的装备区后，你将你的装备区里所有其他坐骑牌置入弃牌堆；你不能使用坐骑牌。",
}

return extension
