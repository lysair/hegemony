--- 武将
-- 国标
------------------------------

-- 阵包
------------------------------

-- 势包
------------------------------

-- 变包
------------------------------

-- 权包
------------------------------

-- 十周年
------------------------------

-- 国际服
------------------------------

-- 线下
------------------------------

-- 不臣
------------------------------

--- 卡牌
-- 国标
------------------------------

-- 势备篇
------------------------------
SmartAI:setTriggerSkillAI("#iron_armor_skill", { -- 没有用？
  correct_func = function(self, logic, event, target, player, data)
    return self.skill:triggerable(event, target, player, data)
  end,
})

-- 君主装备
------------------------------
SmartAI:setTriggerSkillAI("#peace_spell_skill", {
  correct_func = function(self, logic, event, target, player, data)
    return self.skill:triggerable(event, target, player, data)
  end,
})
