local extension = Package:new("transformation")
extension.extensionName = "hegemony"
extension.game_modes_whitelist = { 'nos_heg_mode', 'new_heg_mode' }

Fk:loadTranslationTable{
  ["transformation"] = "君临天下·变",
}

local shamoke = General(extension, "ld__shamoke", "shu", 4)
local jilis = fk.CreateTriggerSkill{
  name = "ld__jilis",
  anim_type = "drawcard",
  events = {fk.CardUsing, fk.CardResponding},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and player:getMark("_jilis-turn") == player:getAttackRange()
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(player:getAttackRange())
  end,

  refresh_events = {fk.AfterCardUseDeclared, fk.CardResponding},
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name)
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:addPlayerMark(player, "_jilis-turn", 1)
  end,
}
shamoke:addSkill(jilis)
Fk:loadTranslationTable{
  ['ld__shamoke'] = '沙摩柯',
  ["ld__jilis"] = "蒺藜",
  [":ld__jilis"] = "当你于一回合内使用或打出第X张牌时，你可摸X张牌（X为你的攻击范围）。",

  ["$ld__jilis1"] = "蒺藜骨朵，威震慑敌！",
  ["$ld__jilis2"] = "看我一招，铁蒺藜骨朵！",
  ["~shamoke"] = "五溪蛮夷，不可能输！",
}

local lingtong = General(extension, "ld__lingtong", "wu", 4)
local xuanlve = fk.CreateTriggerSkill{
  name = "xuanlve",
  anim_type = "control",
  events = {fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self.name) then return end
    local room = player.room
    for _, move in ipairs(data) do
      if move.from == player.id then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerEquip then
            return table.find(room:getOtherPlayers(player), function(p)
              return not p:isNude()
            end) ~= nil
          end
        end
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room:getOtherPlayers(player), function(p)
      return not p:isNude()
    end)

    targets = table.map(targets, Util.IdMapper)
    local pid = room:askForChoosePlayers(player, targets, 1, 1, '#xuanlve-discard',
      self.name, true)[1]

    if pid then
      self.cost_data = pid
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(self.cost_data)
    local id = room:askForCardChosen(player, to, "he", self.name)
    room:throwCard(id, self.name, to, player)
  end,
}
lingtong:addSkill(xuanlve)
lingtong:addSkill("ex__yongjin")
Fk:loadTranslationTable{
  ['ld__lingtong'] = '凌统',
  ['xuanlve'] = '旋略',
  [':xuanlve'] = '当你失去装备区的牌后，你可以弃置一名其他角色的一张牌。',
  ['#xuanlve-discard'] = '旋略：你可以弃置一名其他角色的一张牌',
}

return extension
