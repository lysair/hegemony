local duannian = fk.CreateTriggerSkill{
  name = "ty_heg__duannian",
  anim_type = "drawcard",
  events = {fk.EventPhaseEnd},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Play and not player:isKongcheng()
  end,
  on_use = function(self, event, target, player, data)
    player.room:throwCard(player:getCardIds("h"), self.name, player, player)
    if player.dead then return end
    player:drawCards(player.maxHp - player:getHandcardNum(), self.name)
  end,
}