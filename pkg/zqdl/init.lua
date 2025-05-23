local extension = Package:new("zqdl")
extension.extensionName = "hegemony"
extension.game_modes_whitelist = { "nos_heg_mode", "new_heg_mode" }

extension:loadSkillSkelsByPath("./packages/hegemony/pkg/zqdl/skills")

Fk:loadTranslationTable{
  ["zqdl"] = "紫气东来",
  ["zq"] = "紫气",
}

General:new(extension, "zq__simayi", "jin", 4):addSkills { "zq__yingshis", "zq__shunfu" }
Fk:loadTranslationTable{
  ["zq__simayi"] = "司马懿",
  ["#zq__simayi"] = "应期佐命",
  ["illustrator:zq__simayi"] = "小罗没想好",
}

local zhangchunhua = General:new(extension, "zq__zhangchunhua", "jin", 3, 3, General.Female)
zhangchunhua:addSkills { "zq__ejue", "zq__shangshi" }
zhangchunhua:addCompanions("zq__simayi")
Fk:loadTranslationTable{
  ["zq__zhangchunhua"] = "张春华",
  ["#zq__zhangchunhua"] = "锋刃染霜",
  ["illustrator:zq__zhangchunhua"] = "小罗没想好",

  ["~zq__zhangchunhua"] = "冷眸残情，孤苦为一人。",
}

--General:new(extension, "zq__simashi", "jin", 4):addSkills { "zq__yimie", "zq__ruilue" }
Fk:loadTranslationTable{
  ["zq__simashi"] = "司马师",
  ["#zq__simashi"] = "睚眥侧目",
  ["illustrator:zq__simashi"] = "拉布拉卡",
}

General:new(extension, "zq__simazhao", "jin", 3):addSkills { "zq__zhaoran", "zq__beiluan" }
Fk:loadTranslationTable{
  ["zq__simazhao"] = "司马昭",
  ["#zq__simazhao"] = "天下畏威",
  ["illustrator:zq__simazhao"] = "君桓文化",
}

General:new(extension, "zq__simazhou", "jin", 4):addSkills { "zq__pojing" }
Fk:loadTranslationTable{
  ["zq__simazhou"] = "司马伷",
  ["#zq__simazhou"] = "温恭的狻猊",
  ["illustrator:zq__simazhou"] = "凝聚永恒",
}

General:new(extension, "zq__simaliang", "jin", 4):addSkills { "zq__gongzhi", "zq__shejus" }
Fk:loadTranslationTable{
  ["zq__simaliang"] = "司马亮",
  ["#zq__simaliang"] = "蒲牢惊啼",
  ["illustrator:zq__simaliang"] = "小罗没想好",
}

General:new(extension, "zq__simalun", "jin", 4):addSkills { "zq__zhulan", "zq__luanchang" }
Fk:loadTranslationTable{
  ["zq__simalun"] = "司马伦",
  ["#zq__simalun"] = "螭吻裂冠",
  ["illustrator:zq__simalun"] = "荆芥",
}

General:new(extension, "zq__shibao", "jin", 4):addSkill("zq__zhuosheng")
Fk:loadTranslationTable{
  ["zq__shibao"] = "石苞",
  ["#zq__shibao"] = "经国之才",
  ["illustrator:zq__shibao"] = "凝聚永恒",
}

local yanghuiyu = General:new(extension, "zq__yanghuiyu", "jin", 3, 3, General.Female)
yanghuiyu:addSkills { "zq__ciwei", "zq__caiyuan" }
yanghuiyu:addCompanions("zq__simashi")
Fk:loadTranslationTable{
  ["zq__yanghuiyu"] = "羊徽瑜",
  ["#zq__yanghuiyu"] = "克明礼教",
  ["illustrator:zq__yanghuiyu"] = "Jzeo",
}

local wangyuanji = General:new(extension, "zq__wangyuanji", "jin", 3, 3, General.Female)
wangyuanji:addSkills { "zq__yanxi", "zq__shiren" }
wangyuanji:addCompanions("zq__simazhao")
Fk:loadTranslationTable{
  ["zq__wangyuanji"] = "王元姬",
  ["#zq__wangyuanji"] = "垂心万物",
  ["illustrator:zq__wangyuanji"] = "六道目",
}

General:new(extension, "zq__weiguan", "jin", 3):addSkills { "zq__chengxi", "zq__jiantong" }
Fk:loadTranslationTable{
  ["zq__weiguan"] = "卫瓘",
  ["#zq__weiguan"] = "忠允清识",
  ["illustrator:zq__weiguan"] = "Karneval",
}

General:new(extension, "zq__jiachong", "jin", 3):addSkills { "zq__chujue", "zq__jianzhi" }
Fk:loadTranslationTable{
  ["zq__jiachong"] = "贾充",
  ["#zq__jiachong"] = "悖逆篡弑",
  ["illustrator:zq__jiachong"] = "游漫美绘",
}

local guohuaij = General:new(extension, "zq__guohuaij", "jin", 3, 3, General.Female)
guohuaij:addSkills { "zq__zhefu", "zq__yidu" }
guohuaij:addCompanions("zq__jiachong")
Fk:loadTranslationTable{
  ["zq__guohuaij"] = "郭槐",
  ["#zq__guohuaij"] = "嫉贤妒能",
  ["illustrator:zq__guohuaij"] = "凝聚永恒",
}

General:new(extension, "zq__wangjun", "jin", 4):addSkill("zq__chengliu")
Fk:loadTranslationTable{
  ["zq__wangjun"] = "王濬",
  ["#zq__wangjun"] = "顺流长驱",
  ["illustrator:zq__wangjun"] = "荆芥",
}

General:new(extension, "zq__malong", "jin", 4):addSkills{ "zq__zhuanzhan", "zq__xunjim" }
Fk:loadTranslationTable{
  ["zq__malong"] = "马隆",
  ["#zq__malong"] = "困局诡阵",
  ["illustrator:zq__malong"] = "荆芥",
}

return extension
