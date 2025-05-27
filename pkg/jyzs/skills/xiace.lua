local xiace = fk.CreateSkill{
  name = "jy_heg__xiace",
}

Fk:loadTranslationTable{
  ["jy_heg__xiace"] = "黠策",
  [":jy_heg__xiace"] = "若当前回合角色有【杀】的剩余使用次数，你可以将一张牌当【无懈可击】使用，" ..
    "并令当前回合角色【杀】的剩余使用次数-1，然后你可以变更副将。",

  ["@jy_heg__xiace_slash-phase"] = "黠策",
}

local H = require "packages/hegemony/util"

xiace:addEffect("viewas", {
  pattern = "nullification",
  card_num = 1,
  handly_pile = true,
  enabled_at_nullification = function (self, player, response)
    local curPlayer = Fk:currentRoom():getCurrent()
    if curPlayer then
      local card = Fk:cloneCard("slash")
      return card.skill:withinTimesLimit(curPlayer, Player.HistoryPhase, card)
    end
  end,
  card_filter = function (self, player, to_select, selected)
    return #selected == 0
  end,
  view_as = function (self, player, cards)
    if #cards ~= 1 then return end
    local c = Fk:cloneCard("nullification")
    c.skillName = xiace.name
    c:addSubcard(cards[1])
    return c
  end,
  before_use = function (self, player, use)
    use.extra_data = use.extra_data or {}
    use.extra_data.jy_heg__xiaceUser = player.id
  end,
})
xiace:addEffect(fk.CardUseFinished, {
  is_delay_effect = true,
  can_trigger = function (self, event, target, player, data)
    return target == player and (data.extra_data or {}).jy_heg__xiaceUser == player.id
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local curPlayer = room:getCurrent() --[[@as ServerPlayer]]
    if curPlayer and curPlayer:isAlive() then
      room:addPlayerMark(curPlayer, "@jy_heg__xiace_slash-phase")
    end
    H.transformGeneral(room, player)
  end
})
xiace:addEffect("targetmod", {
  residue_func = function (self, player, skill, scope, card, to)
    if player:getMark("@jy_heg__xiace_slash-phase") ~= 0 and skill.trueName == "slash_skill" and scope == Player.HistoryPhase then
      return -player:getMark("@jy_heg__xiace_slash-phase")
    end
  end
})

xiace:addTest(function (room, me)
  FkTest.runInRoom(function ()
    room:handleAddLoseSkills(me, xiace.name)
  end)
  FkTest.runInRoom(function ()
    me:drawCards(1)
  end)
end)

return xiace
