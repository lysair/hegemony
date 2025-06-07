local xiejian = fk.CreateSkill {
    name = "jy_heg__xiejian",
}

Fk:loadTranslationTable {
    ["jy_heg__xiejian"] = "挟奸",
    [":jy_heg__xiejian"] = "出牌阶段限一次，你可以对一名其他角色发起“军令”，且你以此法抽取的备选“军令”对其他角色不可见，若其不执行，其强制执行你抽取的备选“军令”。",

    ["#jy_heg__xiejian"] = "挟奸：选择一名其他角色发起“军令”",
}

local H = require "packages/hegemony/util"

xiejian:addEffect("active", {
  anim_type = "offensive",
  prompt = "#jy_heg__xiejian",
  can_use = function(self, player)
    return player:usedSkillTimes(xiejian.name, Player.HistoryPhase) == 0
  end,
  target_num = 1,
  card_num = 0,
  target_filter = function(self, player, to_select, selected, selected_cards)
    return #selected == 0 and to_select ~= player
  end,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = effect.from
    local to = effect.tos[1]
    local allCommands = { "command1", "command2", "command3", "command4", "command5", "command6" }
    local commands = table.random(allCommands, 2) ---@type string[]
    local choice = room:askToChoice(player, { choices = commands, skill_name = "start_command", detailed = true })
    room:sendLog {
        type = "#CommandChoice",
        from = player.id,
        arg = ":" + choice,
        toast = true,
    }
    local index = table.indexOf(allCommands, choice)
    table.removeOne(commands, choice)
    local spare_index = commands[1]
    if player.dead or to.dead then return false end
    room:sendLog {
        type = "#AskCommandTo",
        from = player.id,
        to = { to.id },
        arg = xiejian.name,
        toast = true,
    }
    if not H.doCommand(to, xiejian.name, index, player, false) then
        H.doCommand(to, xiejian.name, table.indexOf(allCommands, spare_index), player, true)
      end
    end,
})

return xiejian
