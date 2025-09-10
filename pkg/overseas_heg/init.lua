local extension = Package:new("overseas_heg")
extension.extensionName = "hegemony"
extension.game_modes_whitelist = { 'nos_heg_mode', 'new_heg_mode' }

extension:loadSkillSkelsByPath("./packages/hegemony/pkg/overseas_heg/skills")

Fk:loadTranslationTable{
  ["overseas_heg"] = "国战-国际服专属",
  ["os_heg"] = "国际",
}

local yangxiu = General:new(extension, "os_heg__yangxiu", "wei", 3)
yangxiu:addSkills{"danlao", "jilei"}
Fk:loadTranslationTable{
  ['os_heg__yangxiu'] = '杨修',
  ["#os_heg__yangxiu"] = "恃才放旷",
  ["designer:os_heg__yangxiu"] = "KayaK",
  ["illustrator:os_heg__yangxiu"] = "张可",
  ["~os_heg__yangxiu"] = "我固自以死之晚也……",
}

local xiahoushang = General:new(extension, "os_heg__xiahoushang", "wei", 4)
xiahoushang:addCompanions("hs__caopi")
xiahoushang:addSkill("os_heg__tanfeng")
Fk:loadTranslationTable{
  ["os_heg__xiahoushang"] = "夏侯尚",
  ["#os_heg__xiahoushang"] = "魏胤前驱",
  ["designer:os_heg__xiahoushang"] = "豌豆&Loun老萌",
  ["illustrator:os_heg__xiahoushang"] = "M云涯",
  ["~os_heg__xiahoushang"] = "陛下垂怜至此，臣纵死无憾……",
}

local liaohua = General:new(extension, "os_heg__liaohua", "shu", 4)
liaohua:addCompanions("hs__guanyu")
liaohua:addSkill("os_heg__dangxian")

Fk:loadTranslationTable{
  ['os_heg__liaohua'] = '廖化',
  ["#os_heg__liaohua"] = "历尽沧桑",
  ["designer:os_heg__liaohua"] = "梦魇狂朝",
  ["illustrator:os_heg__liaohua"] = "聚一工作室",
  ["~os_heg__liaohua"] = "兴复大业，就靠你们了……",
}

local chendao = General:new(extension, "os_heg__chendao", "shu", 4)
chendao:addCompanions("hs__zhaoyun")
chendao:addSkill("wangliec")
Fk:loadTranslationTable{
  ["os_heg__chendao"] = "陈到",
  ["#os_heg__chendao"] = "白毦督",
  ["designer:os_heg__chendao"] = "荼蘼",
  ["illustrator:os_heg__chendao"] = "王立雄",
  ["~os_heg__chendao"] = "我的白毦兵，再也不能为先帝出力了。",
}

local zhugejin = General:new(extension, "os_heg__zhugejin", "wu", 3)
zhugejin:addCompanions("hs__sunquan")
zhugejin:addSkills{"os_heg__huanshi", "os_heg__hongyuan", "os_heg__mingzhe"}
Fk:loadTranslationTable{
  ["os_heg__zhugejin"] = "诸葛瑾",
  ["#os_heg__zhugejin"] = "联盟的维系者",
  ["designer:os_heg__zhugejin"] = "梦魇狂朝",
  ["illustrator:os_heg__zhugejin"] = "G.G.G.",
  ["~os_heg__zhugejin"] = "君臣不相负，来世复君臣。",
}

local zumao = General:new(extension, "os_heg__zumao", "wu", 4)
zumao:addSkills{"yinbing", "juedi"}
Fk:loadTranslationTable{
  ['os_heg__zumao'] = '祖茂',
  ["#os_heg__zumao"] = "碧血染赤帻",
  ["designer:os_heg__zumao"] = "红莲的焰神",
  ["illustrator:os_heg__zumao"] = "DH",
  ["~os_heg__zumao"] = "孙将军，已经，安全了吧……",
}

local fuwan = General:new(extension, "os_heg__fuwan", "qun", 4)
fuwan:addSkill("moukui")
Fk:loadTranslationTable{
  ['os_heg__fuwan'] = '伏完',
  ["#os_heg__fuwan"] = "沉毅的国丈",
  ["designer:os_heg__fuwan"] = "嘉言懿行",
  ["illustrator:os_heg__fuwan"] = "LiuHeng",
  ["~os_heg__fuwan"] = "后会有期……",
}

local huaxiong = General:new(extension, "os_heg__huaxiong", "qun", 4)
huaxiong:addSkills{"os_heg__yaowu", "os_heg__shiyong"}

Fk:loadTranslationTable{
  ['os_heg__huaxiong'] = '华雄',
  ["#os_heg__huaxiong"] = "魔将",
  ["illustrator:os_heg__huaxiong"] = "地狱许",
  ["designer:os_heg__huaxiong"] = "Loun老萌",
  ["~os_heg__huaxiong"] = "我掉以轻心了……",
}

return extension
