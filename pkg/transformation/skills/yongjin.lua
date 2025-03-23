
local yongjin = fk.CreateSkill{
  name = "yongjin",
  tags = {Skill.Limited},
}
yongjin:addEffect("active", {
  anim_type = "offensive",
  card_num = 0,
  target_num = 0,
  card_filter = Util.FalseFunc,
  can_use = function(self, player)
    return player:usedSkillTimes(yongjin.name, Player.HistoryGame) == 0
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    for _ = 1, 3, 1 do
      if #room:canMoveCardInBoard("e") == 0 or player.dead then break end
      local to = room:askToChooseToMoveCardInBoard(player, {
        prompt = "#yongjin-choose", skill_name = yongjin.name,
        cancelable = true, flags = "e"
      })
      if #to == 2 then
        if not room:askToMoveCardInBoard(player, {target_one = to[1],
          target_two = to[2], skill_name = yongjin.name, flags = "e"}) then
          break
        end
      else
        break
      end
    end
  end,
})

Fk:loadTranslationTable{
  ["yongjin"] = "勇进",
  [":yongjin"] = "限定技，出牌阶段，你可依次移动场上至多三张装备牌。" ..
  "<font color='grey'><br />注：可以多次移动同一张牌。",
  ["#yongjin-choose"] = "勇进：你可以移动场上的一张装备牌",

  ["$yongjin1"] = "急流勇进，覆戈倒甲！",
  ["$yongjin2"] = "长缨缚敌，先登夺旗！",
}

return yongjin
