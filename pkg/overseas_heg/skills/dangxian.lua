local dangxian = fk.CreateSkill{
  name = "os_heg__dangxian",
  tags = {Skill.Compulsory},
}
local H = require "packages/hegemony/util"
dangxian:addEffect(fk.EventPhaseEnd, {
  can_trigger = function(self, event, target, player, data)
    if target ~= player or not player:hasSkill(dangxian.name) then return false end
    return player.phase == Player.RoundStart
  end,
  on_use = function(self, event, target, player, data)
    player:gainAnExtraPhase(Player.Play)
  end
})
dangxian:addEffect(fk.GeneralRevealed, {
  can_trigger = function(self, event, target, player, data)
    if target ~= player or not player:hasSkill(dangxian.name) then return false end
    if player:usedSkillTimes(dangxian.name, Player.HistoryGame) == 0 then
      for _, v in pairs(data) do
        if table.contains(Fk.generals[v]:getSkillNameList(), dangxian.name) then return true end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    H.addHegMark(player.room, player, "vanguard")
  end
})

Fk:loadTranslationTable{
  ["os_heg__dangxian"] = "当先",
  [":os_heg__dangxian"] = "锁定技，当你首次明置此武将牌后，你获得一枚“先驱”标记；回合开始时，你执行一个额外的出牌阶段。",

  ["$os_heg__dangxian1"] = "谁言蜀汉已无大将？",
  ["$os_heg__dangxian2"] = "老将虽白发，宝刀刃犹锋！",
}

return dangxian
