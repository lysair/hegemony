local extension = Package:new("manoeuve")
extension.extensionName = "hegemony"
extension.game_modes_whitelist = { 'nos_heg_mode', 'new_heg_mode' }

local H = require "packages/hegemony/util"

Fk:loadTranslationTable{
  ["manoeuve"] = "十周年-纵横捭阖",
}

-- local huaxin = General(extension, "ty__huaxin", "wei", 3)
Fk:loadTranslationTable{
  ['ty__huaxin'] = '华歆',
  ["ty__wanggui"] = "望归",
  [":ty__wanggui"] = "每回合限一次，当你造成或受到伤害后，若你：仅明置了此武将牌，你可对与你势力不同的一名角色造成1点伤害；武将牌均明置，你可令所有与你势力相同的角色各摸一张牌。",
  ["ty__wanggui"] = "息兵",
  [":ty__wanggui"] = "当一名其他角色于其出牌阶段内使用第一张黑色【杀】或黑色普通锦囊牌指定一名角色为唯一目标后，你可令其将手牌摸至体力值（至多摸至5张），然后若你与其均明置了所有武将牌，则你可暗置你与其各一张武将牌且本回合不能明置以此法暗置的武将牌。若其因此摸牌，其本回合不能再使用手牌。",

  ["$ty__wanggui1"] = "存志太虚，安心玄妙。",
  ["$ty__wanggui2"] = "礼法有度，良德才略。",
  ["$ty__xibing1"] = "千里运粮，非用兵之利。",
  ["$ty__xibing2"] = "宜弘一代之治，绍三王之迹。",
  ["~ty__huaxin"] = "大举发兵，劳民伤国。",
}

Fk:loadTranslationTable{
  ["ty__fengxiw"] = "冯熙",
  ["ty__yusui"] = "玉碎",
  [":ty__yusui"] = "每回合限一次，当你成为其他角色使用黑色牌的目标后，若你与其势力不同，你可失去1点体力，然后选择一项：1.令其弃置X张手牌（X为其体力上限）；2.令其失去体力值至与你相同。",
  ["ty__boyan"] = "驳言",
  [":ty__boyan"] = "出牌阶段限一次，你可以选择一名其他角色，其将手牌摸至其体力上限，其本回合不能使用或打出手牌。" .. 
    "<br><font color=\"pink\">◆纵横：删去〖驳言〗描述中的“将手牌摸至体力上限”。<font><br><font color=\"grey\"><b>纵横</b>某些角色的技能可以发动“纵横”。当拥有“纵横”效果技能发动结算完成后，可以令技能目标角色获得对应修订描述后的技能，直到其下回合结束。",
}

return extension
