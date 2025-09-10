
local tuntian = fk.CreateSkill{
  name = "ld__tuntian",
  derived_piles = "ld__dengai_field",
}
tuntian:addEffect(fk.AfterCardsMove, {
  anim_type = "special",
  can_trigger = function(self, event, target, player, data)
    if not (player:hasSkill(tuntian.name) and player.phase == Player.NotActive) then return end
    for _, move in ipairs(data) do
      if move.from == player then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip then
            return true
          end
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local judge = {
      who = player,
      reason = tuntian.name,
      pattern = ".|.|spade,club,diamond",
    }
    room:judge(judge)
    if judge:matchPattern() and room:getCardArea(judge.card.id) == Card.DiscardPile and not player.dead and
      room:askToSkillInvoke(player, {
        skill_name = tuntian.name,
        prompt = "ld__tuntian_field:::" .. judge.card:toLogString(),
      }) then
      player:addToPile("ld__dengai_field", judge.card, true, tuntian.name)
    end
  end,
})
tuntian:addEffect('distance', {
  correct_func = function(self, from, to)
    if from:hasSkill(tuntian.name) then
      return -#from:getPile("ld__dengai_field")
    end
  end,
})

tuntian:addAI({
  think_skill_invoke = Util.TrueFunc,
})

Fk:loadTranslationTable{
  ["ld__tuntian"] = "屯田",
  [":ld__tuntian"] = "当你于回合外失去牌后，你可判定：若结果不为<font color='red'>♥</font>，你可将弃牌堆里的此判定牌置于武将牌上（称为“田”）。你至其他角色的距离-X（X为“田”数）。",
  ["ld__dengai_field"] = "田",
  ["ld__tuntian_field"] = "屯田：将%arg置于武将牌上（称为“田”）",
  ["$ld__tuntian1"] = "留得良田在，何愁不破敌？",
  ["$ld__tuntian2"] = "击鼓于此，以致四方。",
}

return tuntian
