local huyuan = fk.CreateSkill{
  name = "ld__huyuan",
}

huyuan:addEffect(fk.EventPhaseStart, {
  anim_type = "defensive",
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(huyuan.name) and player.phase == Player.Finish and not player:isNude()
  end,
  on_cost = function (self, event, target, player, data)
    local success, dat = player.room:askToUseActiveSkill(player, {skill_name = "#ld__huyuan_active",
      prompt = "#ld__huyuan-choose", cancelable = true})
    if success and dat then
      event:setCostData(self, {interaction = dat.interaction, tos = dat.targets, cards = dat.cards})
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local dat = event:getCostData(self)
    local choice = dat.interaction
    if choice == "ld__huyuan_give" then
      room:obtainCard(dat.tos[1], dat.cards, false, fk.ReasonGive, player.id)
    elseif choice == "ld__huyuan_equip" then
      room:moveCardIntoEquip(dat.tos[1], dat.cards, huyuan.name, true, player)
      if not player.dead then
        local targets = table.map(table.filter(room.alive_players, function(p)
          return #p:getCardIds("ej") > 0 end), Util.IdMapper)
        local to2 = room:askForChoosePlayers(player, targets, 1, 1, "#ld__huyuan_discard-choose", huyuan.name, true, true)
        if #to2 > 0 then
          local cid = room:askForCardChosen(player, room:getPlayerById(to2[1]), "ej", huyuan.name)
          room:throwCard({cid}, huyuan.name, room:getPlayerById(to2[1]), player)
        end
      end
    end
  end,
})

Fk:loadTranslationTable{
  ["ld__huyuan"] = "护援",
  [":ld__huyuan"] = "结束阶段，你可选择：1.将一张手牌交给一名角色；2.将一张装备牌置入一名角色的装备区，然后你可以弃置场上的一张牌。",

  ["#ld__huyuan-choose"] = "发动 护援，选择一张牌和一名角色",
  ["#ld__huyuan_discard-choose"] = "护援：选择一名角色，弃置其场上的一张牌",

  ["$ld__huyuan1"] = "舍命献马，护我曹公！",
  ["$ld__huyuan2"] = "拼将性命，定保曹公周全。",
}
return huyuan
