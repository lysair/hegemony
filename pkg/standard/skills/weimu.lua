local weimu = fk.CreateSkill{
  name = "hs__weimu",
  tags = {Skill.Compulsory},
}
weimu:addEffect(fk.TargetConfirming, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.skeleton.name) and data.card.color == Card.Black and data.card:isCommonTrick()
  end,
  on_use = function(self, event, target, player, data)
    data:cancelTarget(player)
  end
})
weimu:addEffect(fk.BeforeCardsMove, {
  anim_type = "defensive",
  can_trigger = function (self, event, target, player, data)
    if not player:hasSkill(self.skeleton.name) then return false end
    local id = 0
    local source = player
    local c
    for _, move in ipairs(data) do
      if move.to == player.id and move.toArea == Card.PlayerJudge then
        for _, info in ipairs(move.moveInfo) do
          id = info.cardId
          if info.fromArea == Card.PlayerJudge then
            source = move.from or player
          else
            source = player
          end
          c = source:getVirualEquip(id)
          --FIXME：巨大隐患，延时锦囊的virtual_equips在置入判定区的事件被篡改，或者判定阶段自然流程以外的方式离开判定区时不会清理
          if not c then c = Fk:getCardById(id) end
          if c.sub_type == Card.SubtypeDelayedTrick and c.color == Card.Black then
            return true
          end
        end
      end
    end
  end,
  on_use = function (self, event, target, player, data)
    local source = player
    local mirror_moves = {}
    local ids = {}
    for _, move in ipairs(data) do
      if move.to == player.id and move.toArea == Card.PlayerJudge then
        local move_info = {}
        local mirror_info = {}
        for _, info in ipairs(move.moveInfo) do
          local id = info.cardId
          if info.fromArea == Card.PlayerJudge then
            source = move.from or player
          else
            source = player
          end
          local c = source:getVirualEquip(id)
          if not c then c = Fk:getCardById(id) end
          if c.sub_type == Card.SubtypeDelayedTrick and c.color == Card.Black then
            table.insert(mirror_info, info)
            table.insert(ids, id)
          else
            table.insert(move_info, info)
          end
        end
        if #mirror_info > 0 then
          move.moveInfo = move_info
          local mirror_move = table.clone(move)
          mirror_move.to = nil
          mirror_move.toArea = Card.DiscardPile
          mirror_move.moveInfo = mirror_info
          table.insert(mirror_moves, mirror_move)
        end
      end
    end
    table.insertTable(data, mirror_moves)
  end
})

Fk:loadTranslationTable{
  ['hs__weimu'] = '帷幕',
  [':hs__weimu'] = '锁定技，当你成为黑色锦囊牌的目标时，取消之。',

  ["$hs__weimu1"] = "此计伤不到我。",
  ["$hs__weimu2"] = "你奈我何！",
}

return weimu
