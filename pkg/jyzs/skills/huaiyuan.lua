local huaiyuan = fk.CreateSkill {
    name = "jy_heg__huaiyuan",
}

Fk:loadTranslationTable {
    ["jy_heg__huaiyuan"] = "怀远",
    [":jy_heg__huaiyuan"] = "与你势力相同角色的准备阶段，你可以令其以下项于本回合数值+1: 1.攻击范围；2.手牌上限；3.使用【杀】的次数上限。",
    ["#jy_heg__huaiyuan_choose"] = "怀远：选择一项，令 %src 对应项于本回合数值+1 ",

    ["jy_heg__huaiyuan_atkrange"] = "攻击范围+1",
    ["jy_heg__huaiyuan_maxcard"] = "手牌上限+1",
    ["jy_heg__huaiyuan_targetmod"] = "使用【杀】的次数上限+1",
    ["@jy_heg__huaiyuan_atkrange-turn"] = "攻击范围",
    ["@jy_heg__huaiyuan_maxcard-turn"] = "手牌上限",
    ["@jy_heg__huaiyuan_targetmod-turn"] = "【杀】上限",

    ["$jy_heg__huaiyuan1"] = "当怀远志，砥砺奋进。",
    ["$jy_heg__huaiyuan2"] = "举有成资，谋有全策。",
}

local H = require "packages/hegemony/util"

huaiyuan:addEffect(fk.EventPhaseStart, {
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(huaiyuan.name) and target.phase == Player.Start and H.compareKingdomWith(target, player)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local choices = { "jy_heg__huaiyuan_atkrange", "jy_heg__huaiyuan_maxcard", "jy_heg__huaiyuan_targetmod" }
    if target.dead or player.dead then return end
    local choice = room:askToChoice(player, {
        choices = choices,
        skill_name = huaiyuan.name,
        prompt = "#jy_heg__huaiyuan_choose:"..target.id,
        cancelable = false,
    })
    room:setPlayerMark(target, "@"..choice.."-turn", 1)
  end,
})

huaiyuan:addEffect("maxcards", {
  correct_func = function(self, player)
    return player:getMark("@jy_heg__huaiyuan_maxcard-turn")
  end,
})

huaiyuan:addEffect("atkrange", {
  correct_func = function(self, from, to)
    return from:getMark("@jy_heg__huaiyuan_atkrange-turn")
  end,
})

huaiyuan:addEffect("targetmod", {
  residue_func = function(self, player, skill, scope)
    if skill.trueName == "slash_skill" and scope == Player.HistoryPhase then
      return player:getMark("@jy_heg__huaiyuan_slash-turn")
    end
  end,
})

return huaiyuan
