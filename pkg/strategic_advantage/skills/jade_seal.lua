local H = require "packages/hegemony/util"
local jadeSealSkill = fk.CreateSkill{
  name = "#jade_seal_skill",
  attached_equip = "jade_seal",
  tags = {Skill.Compulsory},
}
jadeSealSkill:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(jadeSealSkill.name) and player.phase == Player.Play and H.isBigKingdomPlayer(player)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local card = Fk:cloneCard("known_both")
    local max_num = card.skill:getMaxTargetNum(player, card)
    local targets = {}
    for _, p in ipairs(room:getOtherPlayers(player, false)) do
      if player:canUseTo(card, p) then
        table.insert(targets, p)
      end
    end
    if #targets == 0 or max_num == 0 then return end
    local to = room:askToChoosePlayers(player, {targets = targets, min_num = 1, max_num = max_num,
      prompt = "#jade_seal-ask", skill_name = jadeSealSkill.name, cancelable = false})
    if #to > 0 then
      event:setCostData(self, {tos = to} )
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:useVirtualCard("known_both", nil, player, event:getCostData(self).tos, "jade_seal")
  end,
})
jadeSealSkill:addEffect(fk.DrawNCards, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(jadeSealSkill.name) and H.isBigKingdomPlayer(player)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data.n = data.n + 1
  end,
})
jadeSealSkill:addEffect("bigkingdom", {
  fixed_func = function(self, player)
    return player:hasSkill(jadeSealSkill.name) and player.kingdom ~= "unknown"
  end
})

jadeSealSkill:addTest(function (room, me)
  local card = room:printCard("jade_seal")
  local comp5 = room.players[5]
  local isBigKingdom1, isBigKingdom2, isBigKingdom3 = false, false, false
  FkTest.runInRoom(function()
    room:changeHero(room.players[2], "xuchu")
    room:changeHero(room.players[3], "zhangliao")
    room:changeHero(room.players[4], "guojia")
    room:changeHero(comp5, "liubei")
    room:changeHero(room.players[6], "guanyu")
    room:changeHero(room.players[7], "zhangfei")
    room:changeHero(room.players[8], "zhugeliang")
    isBigKingdom1 = H.isBigKingdomPlayer(me)
    isBigKingdom2 = H.isBigKingdomPlayer(comp5)
  end)
  lu.assertIsTrue(isBigKingdom1)
  lu.assertIsTrue(isBigKingdom2)

  FkTest.runInRoom(function()
    room:useCard {
      from = me,
      tos = { me },
      card = card,
    }
    isBigKingdom1 = H.isBigKingdomPlayer(me)
    isBigKingdom2 = H.isBigKingdomPlayer(comp5)
  end)
  lu.assertIsTrue(isBigKingdom1)
  lu.assertIsFalse(isBigKingdom2) -- 唯一

  FkTest.runInRoom(function()
    room:changeHero(room.players[2], "zhaoyun")
    isBigKingdom1 = H.isBigKingdomPlayer(me)
    isBigKingdom2 = H.isBigKingdomPlayer(comp5)
    isBigKingdom3 = H.isBigKingdomPlayer(room.players[3])
  end)
  lu.assertIsTrue(isBigKingdom1)
  lu.assertIsTrue(isBigKingdom3) -- 同势力其他角色
  lu.assertIsFalse(isBigKingdom2) -- 即使数量更多
end)

Fk:loadTranslationTable{
  ["jade_seal"] = "玉玺",
  [":jade_seal"] = "装备牌·宝物<br/><b>宝物技能</b>：锁定技，若你有势力，你的势力为大势力，除你的势力外的所有势力均为小势力；摸牌阶段，若你有势力，你令额定摸牌数+1；出牌阶段开始时，若你有势力，你视为使用【知己知彼】。",
  ["#jade_seal_skill"] = "玉玺",
  ["#jade_seal-ask"] = "受到【玉玺】的效果，视为你使用一张【知己知彼】",
}

return jadeSealSkill
