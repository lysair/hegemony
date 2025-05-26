local extension = Package:new("zqdl")
extension.extensionName = "hegemony"
extension.game_modes_whitelist = { "nos_heg_mode", "new_heg_mode" }

extension:loadSkillSkelsByPath("./packages/hegemony/pkg/zqdl/skills")

Fk:loadTranslationTable{
  ["zqdl"] = "紫气东来",
  ["zq_heg"] = "紫气",
}

General:new(extension, "zq_heg__simayi", "jin", 4):addSkills { "zq_heg__yingshis", "zq_heg__shunfu" }
Fk:loadTranslationTable{
  ["zq_heg__simayi"] = "司马懿",
  ["#zq_heg__simayi"] = "应期佐命",
  ["illustrator:zq_heg__simayi"] = "小罗没想好",
}

local zhangchunhua = General:new(extension, "zq_heg__zhangchunhua", "jin", 3, 3, General.Female)
zhangchunhua:addSkills { "zq_heg__ejue", "zq_heg__shangshi" }
zhangchunhua:addCompanions("zq_heg__simayi")
Fk:loadTranslationTable{
  ["zq_heg__zhangchunhua"] = "张春华",
  ["#zq_heg__zhangchunhua"] = "锋刃染霜",
  ["illustrator:zq_heg__zhangchunhua"] = "小罗没想好",

  ["~zq_heg__zhangchunhua"] = "冷眸残情，孤苦为一人。",
}

--General:new(extension, "zq_heg__simashi", "jin", 4):addSkills { "zq_heg__yimie", "zq_heg__ruilue" }
Fk:loadTranslationTable{
  ["zq_heg__simashi"] = "司马师",
  ["#zq_heg__simashi"] = "睚眥侧目",
  ["illustrator:zq_heg__simashi"] = "拉布拉卡",
}

General:new(extension, "zq_heg__simazhao", "jin", 3):addSkills { "zq_heg__zhaoran", "zq_heg__beiluan" }
Fk:loadTranslationTable{
  ["zq_heg__simazhao"] = "司马昭",
  ["#zq_heg__simazhao"] = "天下畏威",
  ["illustrator:zq_heg__simazhao"] = "君桓文化",
}

General:new(extension, "zq_heg__simazhou", "jin", 4):addSkills { "zq_heg__pojing" }
Fk:loadTranslationTable{
  ["zq_heg__simazhou"] = "司马伷",
  ["#zq_heg__simazhou"] = "温恭的狻猊",
  ["illustrator:zq_heg__simazhou"] = "凝聚永恒",
}

General:new(extension, "zq_heg__simaliang", "jin", 4):addSkills { "zq_heg__gongzhi", "zq_heg__shejus" }
Fk:loadTranslationTable{
  ["zq_heg__simaliang"] = "司马亮",
  ["#zq_heg__simaliang"] = "蒲牢惊啼",
  ["illustrator:zq_heg__simaliang"] = "小罗没想好",
}

General:new(extension, "zq_heg__simalun", "jin", 4):addSkills { "zq_heg__zhulan", "zq_heg__luanchang" }
Fk:loadTranslationTable{
  ["zq_heg__simalun"] = "司马伦",
  ["#zq_heg__simalun"] = "螭吻裂冠",
  ["illustrator:zq_heg__simalun"] = "荆芥",
}

General:new(extension, "zq_heg__shibao", "jin", 4):addSkill("zq_heg__zhuosheng")
Fk:loadTranslationTable{
  ["zq_heg__shibao"] = "石苞",
  ["#zq_heg__shibao"] = "经国之才",
  ["illustrator:zq_heg__shibao"] = "凝聚永恒",
}

local yanghuiyu = General:new(extension, "zq_heg__yanghuiyu", "jin", 3, 3, General.Female)
yanghuiyu:addSkills { "zq_heg__ciwei", "zq_heg__caiyuan" }
yanghuiyu:addCompanions("zq_heg__simashi")
Fk:loadTranslationTable{
  ["zq_heg__yanghuiyu"] = "羊徽瑜",
  ["#zq_heg__yanghuiyu"] = "克明礼教",
  ["illustrator:zq_heg__yanghuiyu"] = "Jzeo",
}

local wangyuanji = General:new(extension, "zq_heg__wangyuanji", "jin", 3, 3, General.Female)
wangyuanji:addSkills { "zq_heg__yanxi", "zq_heg__shiren" }
wangyuanji:addCompanions("zq_heg__simazhao")
Fk:loadTranslationTable{
  ["zq_heg__wangyuanji"] = "王元姬",
  ["#zq_heg__wangyuanji"] = "垂心万物",
  ["illustrator:zq_heg__wangyuanji"] = "六道目",
}

General:new(extension, "zq_heg__weiguan", "jin", 3):addSkills { "zq_heg__chengxi", "zq_heg__jiantong" }
Fk:loadTranslationTable{
  ["zq_heg__weiguan"] = "卫瓘",
  ["#zq_heg__weiguan"] = "忠允清识",
  ["illustrator:zq_heg__weiguan"] = "Karneval",
}

General:new(extension, "zq_heg__jiachong", "jin", 3):addSkills { "zq_heg__chujue", "zq_heg__jianzhi" }
Fk:loadTranslationTable{
  ["zq_heg__jiachong"] = "贾充",
  ["#zq_heg__jiachong"] = "悖逆篡弑",
  ["illustrator:zq_heg__jiachong"] = "游漫美绘",
}

local guohuaij = General:new(extension, "zq_heg__guohuaij", "jin", 3, 3, General.Female)
guohuaij:addSkills { "zq_heg__zhefu", "zq_heg__yidu" }
guohuaij:addCompanions("zq_heg__jiachong")
Fk:loadTranslationTable{
  ["zq_heg__guohuaij"] = "郭槐",
  ["#zq_heg__guohuaij"] = "嫉贤妒能",
  ["illustrator:zq_heg__guohuaij"] = "凝聚永恒",
}

General:new(extension, "zq_heg__wangjun", "jin", 4):addSkill("zq_heg__chengliu")
Fk:loadTranslationTable{
  ["zq_heg__wangjun"] = "王濬",
  ["#zq_heg__wangjun"] = "顺流长驱",
  ["illustrator:zq_heg__wangjun"] = "荆芥",
}

General:new(extension, "zq_heg__malong", "jin", 4):addSkills{ "zq_heg__zhuanzhan", "zq_heg__xunjim" }
Fk:loadTranslationTable{
  ["zq_heg__malong"] = "马隆",
  ["#zq_heg__malong"] = "困局诡阵",
  ["illustrator:zq_heg__malong"] = "荆芥",
}

return extension
