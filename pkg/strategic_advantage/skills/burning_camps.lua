local burningCampsSkill = fk.CreateSkill{
  name = "burning_camps_skill",
}

local H = require "packages/hegemony/util"

burningCampsSkill:addEffect("cardskill", {
  prompt = "#burning_camps_skill",
  mod_target_filter = function(self, player, to_select, selected, card, distance_limited)
    local prev = player:getNextAlive()
    return prev ~= player and (to_select == prev or H.inFormationRelation(prev, to_select))
  end,
  can_use = function(self, player, card)
    return not player:prohibitUse(card) and not player:isProhibited(player:getNextAlive(), card) and player:getNextAlive() ~= player
  end,
  on_use = function(self, room, use)
    if not use.tos or #use.tos == 0 then
      local player = use.from
      local prev = player:getNextAlive()
      use.tos = { prev }
      for _, p in ipairs(H.getFormationRelation(prev)) do
        if not player:isProhibited(p, use.card) then
          use:addTarget(p)
        end
      end
    end
  end,
  on_effect = function(self, room, effect)
    local player = effect.from
    local target = effect.to
    room:damage({
      from = player,
      to = target,
      card = effect.card,
      damage = 1,
      damageType = fk.FireDamage,
      skillName = self.name
    })
  end,
})

burningCampsSkill:addTest(function(room, me)
  FkTest.runInRoom(function()
    room:useCard {
      from = me,
      card = Fk:cloneCard("burning_camps"),
      tos = {},
    }
  end)
  local nextP = room.players[2]
  local function check(player)
    local num = 4
    if H.inFormationRelation(player, nextP) then -- 都是明将
      num = 3
    end
    lu.assertEquals(player.hp, num)
  end
  check(me)
  lu.assertEquals(room.players[2].hp, 3)
  check(room.players[3])

  nextP = room.players[4]
  FkTest.runInRoom(function()
    room:useCard {
      from = room.players[3],
      card = Fk:cloneCard("burning_camps"),
      tos = {},
    }
  end)
  check(room.players[3])
  lu.assertEquals(room.players[4].hp, 3)
end)

Fk:loadTranslationTable{
  ["burning_camps"] = "火烧连营",
  [":burning_camps"] = "锦囊牌<br/><b>时机</b>：出牌阶段<br/><b>目标</b>：你的下家和除其外与其处于同一<a href='heg_formation'>队列</a>的所有角色<br/><b>效果</b>：目标角色受到你造成的1点火焰伤害。",
  ["#burning_camps_skill"] = "对你的下家和除其外与其处于同一队列的所有角色各造成1点火焰伤害",
  ["heg_formation"] = "队列：连续相邻的若干名（至少2名）势力相同的角色处于同一队列",
}

return burningCampsSkill
