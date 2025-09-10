local jubao = fk.CreateSkill{
  name = "jubao",
  tags = {Skill.Compulsory},
}

Fk:loadTranslationTable{
  ["jubao"] = "聚宝",
  [":jubao"] = "锁定技，①结束阶段，若弃牌堆或场上存在【定澜夜明珠】，你摸一张牌，然后获得拥有【定澜夜明珠】的角色的一张牌；②其他角色获得你装备区内的宝物牌时，取消之。",

  ["$jubao1"] = "四海之宝，孤之所爱。",
  ["$jubao2"] = "夷洲，扶南，辽东，皆大吴臣邦也！",
}

jubao:addEffect(fk.EventPhaseStart, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if not (target == player and player:hasSkill(jubao.name) and player.phase == Player.Finish) then return false end
    for _, id in ipairs(player.room.discard_pile) do
      if Fk:getCardById(id).name == "luminous_pearl" then
        return true
      end
    end
    return table.find(Fk:currentRoom().alive_players, function(p)
      return not not table.find(p:getEquipments(Card.SubtypeTreasure), function(cid)
        return Fk:getCardById(cid).name == "luminous_pearl"
      end)
    end)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:drawCards(1, jubao.name)
    local targets = table.filter(room.alive_players, function(p)
      return not not table.find(p:getEquipments(Card.SubtypeTreasure), function(cid)
        return Fk:getCardById(cid).name == "luminous_pearl"
      end) end)
    if #targets == 0 then return end
    room:sortByAction(targets)
    for _, t in ipairs(targets) do
      local card = room:askToChooseCard(player, {
        target = t,
        flag = t == player and "e" or "he",
        skill_name = jubao.name,
      })
      room:obtainCard(player.id, card, false, fk.ReasonPrey)
    end
  end,
})

jubao:addEffect(fk.BeforeCardsMove, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(jubao.name) or not (player:getEquipment(Card.SubtypeTreasure)) then return false end
    for _, move in ipairs(data) do
      if move.from == player and move.to ~= move.from and move.toArea == Card.PlayerHand then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerEquip and Fk:getCardById(info.cardId).sub_type == Card.SubtypeTreasure then
            return true
          end
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local ids = {}
    player.room:notifySkillInvoked(player, "jubao", "defensive")
    player:broadcastSkillInvoke("jubao")
    for _, move in ipairs(data) do
      if move.from == player and move.to ~= move.from and move.toArea == Card.PlayerHand then
        local move_info = {}
        for _, info in ipairs(move.moveInfo) do
          local id = info.cardId
          if info.fromArea == Card.PlayerEquip and Fk:getCardById(id).sub_type == Card.SubtypeTreasure then
            table.insert(ids, id)
          else
            table.insert(move_info, info)
          end
        end
        if #ids > 0 then
          move.moveInfo = move_info
        end
      end
    end
    if #ids > 0 then
      player.room:sendLog{
        type = "#cancelDismantle",
        card = ids,
        arg = jubao.name,
      }
    end
  end,
})

return jubao
