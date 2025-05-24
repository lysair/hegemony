local xiongsuan = fk.CreateSkill{
  name = "xiongsuan",
  tags = {Skill.Limited},
}
local H = require "packages/hegemony/util"
xiongsuan:addEffect("active", {
  anim_type = "offensive",
  can_use = function(self, player)
    return player:usedSkillTimes(xiongsuan.name, Player.HistoryGame) == 0
  end,
  card_num = 1,
  target_num = 1,
  card_filter = function(self, player, to_select, selected)
    return #selected < 1 and Fk:currentRoom():getCardArea(to_select) == Player.Hand
  end,
  target_filter = function(self, player, to_select, selected)
    return #selected == 0 and H.compareKingdomWith(to_select, player)
  end,
  on_use = function (self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    room:throwCard(effect.cards, xiongsuan.name, player, player)
    if player.dead or target.dead then return false end
    room:damage{
      from = player,
      to = target,
      damage = 1,
      skillName = xiongsuan.name,
    }
    if player.dead then return false end
    player:drawCards(3, xiongsuan.name)
    if target.dead then return false end
    local skills = table.filter(target.player_skills, function(s)
      return s:hasTag(Skill.Limited) and target:usedSkillTimes(s.name, Player.HistoryGame) > 0
    end)
    if #skills == 0 then return false end
    local skillNames = table.map(skills, Util.NameMapper)
    local skill = room:askToChoice(player, {
        choices = skillNames,
        skill_name = xiongsuan.name,
        prompt = "#xiongsuan-reset::" .. target.id,
      })
    room:setPlayerMark(player, "_xiongsuan-turn", {skill, target.id})
  end,
})
xiongsuan:addEffect(fk.TurnEnd, {
  mute = true,
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and type(player:getMark("_xiongsuan-turn")) == "table"
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local skill = player:getMark("_xiongsuan-turn")[1]
    target = room:getPlayerById(player:getMark("_xiongsuan-turn")[2])
    target:addSkillUseHistory(skill, -1)
    room:sendLog{
      type = "#XiongsuanReset",
      from = target.id,
      arg = skill,
    }
  end,
})

xiongsuan:addTest(function (room, me)
  FkTest.runInRoom(function ()
    room:handleAddLoseSkills(me, xiongsuan.name)
  end)
  FkTest.setNextReplies(me, { json.encode{
    card = { skill = xiongsuan.name, subcards = {1} }, targets = { me.id }
  } })
  FkTest.runInRoom(function ()
    room:obtainCard(me, 1)
    GameEvent.Turn:create(TurnData:new(me, "game_rule", { Player.Play })):exec()
  end)
  lu.assertEquals(me:getHandcardNum(), 3)
  lu.assertEquals(me.hp, 3)
  lu.assertEvalToTrue(xiongsuan.effects[1]:canUse(me))
end)

Fk:loadTranslationTable{
  ["xiongsuan"] = "凶算",
  [":xiongsuan"] = "限定技，出牌阶段，你可弃置一张手牌并选择与你势力相同的一名角色，"..
    "你对其造成1点伤害，摸三张牌，选择其一个已发动过的限定技，然后此回合结束后，你令此技能于此局游戏内的发动次数上限+1。",
  ["#xiongsuan-reset"] = "凶算：请重置%dest的一项技能",
  ["#XiongsuanReset"] = "%from 重置了限定技〖%arg〗",

  ["$xiongsuan1"] = "此战虽凶，得益颇高。",
  ["$xiongsuan2"] = "谋算计策，吾二人尚有险招。",
}

return xiongsuan
