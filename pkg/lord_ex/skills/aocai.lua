local aocai = fk.CreateSkill{
  name = "ld__aocai",
}

Fk:loadTranslationTable{
  ["ld__aocai"] = "傲才",
  [":ld__aocai"] = "当你于回合外需要使用或打出一张基本牌时，你可以观看牌堆顶的两张牌，若你观看的牌中有相同牌名的牌，你可以使用或打出之。",

  ["#ld__aocai"] = "发动 傲才，观看牌堆顶的两张牌，并可以使用或打出其中你需要的基本牌",
  ["#ld__aocai-choose"] = "傲才：选择你需要使用或打出的基本牌",

  ["$ld__aocai1"] = "哼，易如反掌。",
  ["$ld__aocai2"] = "吾主圣明，泽披臣属。",
}

aocai:addEffect("viewas",{
  pattern = ".|.|.|.|.|basic",
  anim_type = "defensive",
  prompt = "#ld__aocai",
  card_filter = Util.FalseFunc,
  interaction = function(self, player)
    --FIXME: 不支持平辽（打出一张特定颜色的牌）、使用一张基本牌（因为不能正确地选择目标）的技能
    --FIXME: 建议简化为只能使用【杀】、【闪】、【桃】、【酒】（管宁直呼内行）
    --FIXME: 多牌名时会显示英文
    --FIXME: 不支持鏖战（需要特判）
    local all_names = {"slash", "jink", "peach", "analeptic"}
    local names = player:getViewAsCardNames(aocai.name, all_names)
    return UI.CardNameBox {choices = { table.concat(names, ",") }}
  end,
  view_as = function(self, player, cards)
    if self.interaction.data == nil or self.interaction.data == "" then return end
    local names = string.split(self.interaction.data, ",")
    if #names > 0 then
      local card = Fk:cloneCard(names[1])
      card:setMark("aocai_names", names)
      return card
    end
  end,
  before_use = function(self, player, use)
    local room = player.room
    local names = use.card:getMark("aocai_names")
    local cards = room:getNCards(2)
    --FIXME: 需要判断合法性，但是没法区分是使用还是打出
    local ids = table.filter(cards, function (id)
      return table.contains(names, Fk:getCardById(id).trueName)
    end)
    cards = room:askToCards(player,{
      min_num = 1,
      max_num = 1,
      include_equip = false,
      skill_name = aocai.name,
      pattern = tostring(Exppattern{ id = ids }),
      prompt = "#ld__aocai-choose",
      expand_pile = cards,
      cancelable = true,
    })
    if #cards > 0 then
      use.card = Fk:getCardById(cards[1])
    else
      return aocai.name
    end
  end,
  enabled_at_play = Util.FalseFunc,
  enabled_at_response = function(self, player, response)
    return Fk:currentRoom():getCurrent() ~= player
  end,
})

return aocai