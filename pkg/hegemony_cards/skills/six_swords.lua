local sixSwordsSkill = fk.CreateSkill{
  name = "#six_swords_skill",
  attached_equip = "six_swords",
}

local H = require "packages/hegemony/util"

sixSwordsSkill:addEffect("atkrange", {
  frequency = Skill.Compulsory,
  correct_func = function (self, from, to)
    if from.kingdom ~= "unknown" then
      if table.find(Fk:currentRoom().alive_players, function(p)
        return from ~= p and H.compareKingdomWith(from, p) and
          table.find(p:getEquipments(Card.SubtypeWeapon), function(c) return Fk:getCardById(c).name == "six_swords" end) end) then
        return 1
      end
    end
    return 0
  end,
})

Fk:loadTranslationTable{
  ["six_swords"] = "吴六剑",
  [":six_swords"] = "装备牌·武器<br/><b>攻击范围</b>：２ <br/><b>武器技能</b>：锁定技，与你势力相同的其他角色攻击范围+1。",
}

return sixSwordsSkill
