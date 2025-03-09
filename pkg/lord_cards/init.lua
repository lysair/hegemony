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

extension:loadCardSkels{
  dragonPhoenix
}

return extension
