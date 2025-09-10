local baoling = fk.CreateSkill{
  name = "baoling",
  tags = {Skill.MainPlace, Skill.Compulsory},
}
local H = require "packages/hegemony/util"
baoling:addEffect(fk.EventPhaseEnd, {
  anim_type = "big",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(baoling.name) and player.phase == Player.Play and
      player.general ~= "anjiang" and H.hasGeneral(player, true)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    H.removeGeneral(player, true)
    if not player:isAlive() then return end
    room:changeMaxHp(player, 3)
    if not player:isAlive() then return end
    room:recover {
      who = player,
      num = 3,
      skillName = baoling.name
    }
    if not player:isAlive() then return end
    room:handleAddLoseSkills(player, "benghuai")
  end,
})

baoling:addTest(function (room, me)
  FkTest.runInRoom(function ()
    room:changeHero(me, "ld__dongzhuo")
    room:changeHero(me, "caocao", false, true)
    me:gainAnExtraTurn()
  end)
end)


Fk:loadTranslationTable{
  ['baoling'] = '暴凌',
  [':baoling'] = '主将技，锁定技，出牌阶段结束时，若此武将处于明置状态且你有副将，则你移除副将，加3点体力上限并回复3点体力，然后获得〖崩坏〗。',
  ['$baoling1'] = '大丈夫，岂能妇人之仁？',
  ['$baoling2'] = '待吾大开杀戒，哈哈哈哈！',
}

return baoling
