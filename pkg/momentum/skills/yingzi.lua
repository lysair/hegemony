
local yingzi = fk.CreateSkill{
  name = "heg_sunce__yingzi",
  tags = {Skill.Compulsory},
}
yingzi:addEffect(fk.DrawNCards, {
  anim_type = "drawcard",
  on_use = function(self, event, target, player, data)
    data.n = data.n + 1
  end,
})
yingzi:addEffect("maxcards", {
  name = "#heg_sunce__yingzi_maxcards",
  fixed_func = function(self, player)
    if player:hasSkill(yingzi.name) then
      return player.maxHp
    end
  end
})

return yingzi
