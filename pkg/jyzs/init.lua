local extension = Package:new("jyzs")
extension.extensionName = "hegemony"
extension.game_modes_whitelist = { "nos_heg_mode", "new_heg_mode" }

extension:loadSkillSkelsByPath("./packages/hegemony/pkg/jyzs/skills")

Fk:loadTranslationTable{
  ["jyzs"] = "国战-金印紫授",
  ["jy_heg"] = "金印",
}

local H = require "packages/hegemony/util"

General:new(extension, "jy_heg__zhanghuyuechen", "jin", 4):addSkills { "jy_heg__xijue", "jy_heg__lvxian", "jy_heg__yingwei" }
Fk:loadTranslationTable{
  ["jy_heg__zhanghuyuechen"] = "张虎乐綝",
  ["#jy_heg__zhanghuyuechen"] = "文成武德",
  ["illustrator:jy_heg__zhanghuyuechen"] = "凝聚永恒",

  ["~jy_heg__zhanghuyuechen"] = "儿有辱……父亲威名……",
}

General:new(extension, "jy_heg__wenyang", "jin", 5):addSkills { "jy_heg__duanqiu" }
Fk:loadTranslationTable{
  ["jy_heg__wenyang"] = "文鸯",
  ["#jy_heg__wenyang"] = "勇冠三军",
  ["illustrator:jy_heg__wenyang"] = "小罗没想好",
}

 General:new(extension, "jy_heg__yanghu", "jin", 4):addSkills { "jy_heg__huaiyuan", "jy_heg__fushou" }
 Fk:loadTranslationTable{
  ["jy_heg__yanghu"] = "羊祜",
  ["#jy_heg__yanghu"] = "静水沧笙",
  ["illustrator:jy_heg__yanghu"] = "白",

  ["~jy_heg__yanghu"] = "当断不断，反受其乱……",
}

General:new(extension, "jy_heg__yangjun", "jin", 4):addSkills { "jy_heg__neiji" }
Fk:loadTranslationTable{
  ["jy_heg__yangjun"] = "杨骏",
  ["#jy_heg__yangjun"] = "阶缘佞宠",
  ["illustrator:jy_heg__yangjun"] = "荆芥",
}

local bailingyun = General:new(extension, "jy_heg__bailingyun", "jin", 3, 3, General.Female)
bailingyun:addSkills{ "jy_heg__xiace", "jy_heg__limeng" }
bailingyun:addCompanions("zq_heg__simayi")
Fk:loadTranslationTable{
  ["jy_heg__bailingyun"] = "柏夫人",
  ["#jy_heg__bailingyun"] = "玲珑心窍",
  ["illustrator:jy_heg__bailingyun"] = "小罗没想好",
}

General:new(extension, "jy_heg__wangxiang", "jin", 3):addSkills { "jy_heg__bingxin" }
Fk:loadTranslationTable{
  ["jy_heg__wangxiang"] = "王祥",
  ["#jy_heg__wangxiang"] = "沂川跃鲤",
  ["illustrator:jy_heg__wangxiang"] = "KY",

  ["~jy_heg__wangxiang"] = "夫生之有死，自然之理也。",
}

local sunxiu = General:new(extension, "jy_heg__sunxiu", "jin", 3)
sunxiu:addSkills{ "jy_heg__xiejian", "jy_heg__yinsha" }
sunxiu:addCompanions("zq_heg__simalun")
Fk:loadTranslationTable{
  ["jy_heg__sunxiu"] = "孙秀",
  ["#jy_heg__sunxiu"] = "黄钟毁弃",
  ["illustrator:jy_heg__sunxiu"] = "荆芥",
}

local duyu = General:new(extension, "jy_heg__duyu", "jin", 4)
duyu.mainMaxHpAdjustedValue = -1
duyu:addCompanions("jy_heg__yanghu")
duyu:addSkills{ "jy_heg__sanchen", "jy_heg__pozhu" }
Fk:loadTranslationTable{
  ["jy_heg__duyu"] = "杜预",
  ["#jy_heg__duyu"] = "文成武德",
  ["illustrator:jy_heg__duyu"] = "君桓文化",

  ["~jy_heg__duyu"] = "金瓯尚缺，死难瞑目……",
}

local lordsimayi = General:new(extension, "jy_heg__lordsimayi", "jin", 4)
lordsimayi.hidden = true
H.lordGenerals["zq_heg__simayiz"] = "jy_heg__lordsimayi"
lordsimayi:addSkills{ "jy_heg__jiaping", "jy_heg__guikuang", "jy_heg__shujuan" }
Fk:loadTranslationTable{
  ["jy_heg__lordsimayi"] = "君司马懿",
  ["#jy_heg__lordsimayi"] = "狼顾九州",
  ["illustrator:jy_heg__lordsimayi"] = "凡果",
}

return extension
