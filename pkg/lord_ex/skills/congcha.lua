local congcha = fk.CreateSkill {
  name = "ld__congcha",
}

Fk:loadTranslationTable {
  ["ld__congcha"] = "聪察",
  [":ld__congcha"] = "①准备阶段，你可选择一名未确定势力的角色，然后直到你的下回合开始，当其明置武将牌后，若其确定势力且势力与你：相同，你与其各摸两张牌；不同，其失去1点体力。②摸牌阶段，若场上不存在未确定势力的角色，你可多摸两张牌。",

  ["@@ld__congcha_delay"] = "聪察",
  ["#ld__congcha_delay"] = "聪察",
  ["#ld__congcha_choose"] = "聪察：选择一名未确定势力的角色",

  ["$ld__congcha1"] = "窥一斑而知全豹。",
  ["$ld__congcha2"] = "问一事则明其心。",
}

local H = require "packages/hegemony/util"

congcha:addEffect(fk.EventPhaseStart, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if not (target == player and player:hasSkill(congcha.name)) then return end
    return player.phase == Player.Start and
      table.find(player.room:getOtherPlayers(player, false), function(p) return H.getGeneralsRevealedNum(p) == 0 end)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room:getOtherPlayers(player, false), function(p)
      return H.getGeneralsRevealedNum(p) == 0
    end)
    if #targets == 0 then return false end
    local to = room:askToChoosePlayers(player, {
      targets = targets,
      min_num = 1,
      max_num = 1,
      prompt = "#ld__congcha_choose",
      skill_name = congcha.name,
      cancelable = true,
    })
    if #to > 0 then
      room:addTableMark(to[1], "@@ld__congcha_delay", player.id)
      room:setPlayerMark(player, "_ld__congcha", to[1].id)
    end
  end,
})

congcha:addEffect(fk.DrawNCards, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if not (target == player and player:hasSkill(congcha.name)) then return end
    return player.phase == Player.Draw and
    table.every(player.room.alive_players, function(p) return H.getGeneralsRevealedNum(p) > 0 end)
  end,
  on_use = function(self, event, target, player, data)
    data.n = data.n + 2
  end,
})

congcha:addEffect(fk.GeneralRevealed, {
  is_delay_effect = true,
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if target.dead or player.dead then return false end
    local mark = target:getMark("@@ld__congcha_delay")
    return type(mark) == "table" and table.contains(mark, player.id)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:doIndicate(player.id, { target.id })
    local record = target:getMark("@@ld__congcha_delay")
    table.removeOne(record, player.id)
    if #record == 0 then record = 0 end
    room:setPlayerMark(target, "@@ld__congcha_delay", record)
    room:setPlayerMark(player, "_ld__congcha", 0)
    if H.compareKingdomWith(player, target) then
      local targets = { target, player }
      room:sortByAction(targets)
      for _, p in ipairs(targets) do
        if not p.dead then p:drawCards(2, congcha.name) end
      end
    else
      room:loseHp(target, 1, congcha.name)
    end
  end,
})

congcha:addEffect(fk.TurnStart, {
  can_refresh = function(self, event, target, player, data)
    return target == player and player:getMark("_ld__congcha") ~= 0
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    target = room:getPlayerById(player:getMark("_ld__congcha"))
    local record = target:getTableMark("@@ld__congcha_delay")
    table.removeOne(record, player.id)
    if #record == 0 then record = {} end
    room:setPlayerMark(target, "@@ld__congcha_delay", record)
    room:setPlayerMark(player, "_ld__congcha", 0)
  end,
})

congcha:addEffect(fk.BuryVictim, {
  can_refresh = function(self, event, target, player, data)
    return target == player and player:getMark("_ld__congcha") ~= 0
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    target = room:getPlayerById(player:getMark("_ld__congcha"))
    local record = target:getTableMark("@@ld__congcha_delay")
    table.removeOne(record, player.id)
    if #record == 0 then record = {} end
    room:setPlayerMark(target, "@@ld__congcha_delay", record)
    room:setPlayerMark(player, "_ld__congcha", 0)
  end,
})

return congcha
