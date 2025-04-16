local extension = Package:new("offline_heg")
extension.extensionName = "hegemony"
extension.game_modes_whitelist = { 'nos_heg_mode', 'new_heg_mode' }

extension:loadSkillSkelsByPath("./packages/hegemony/pkg/offline_heg/skills")

Fk:loadTranslationTable{
  ["offline_heg"] = "国战-线下卡专属",
  ["of_heg"] = "线下",
}

General:new(extension,"of_heg__lifeng","shu",3):addSkills{"of_heg__tunchu", "of_heg__shuliang"}
Fk:loadTranslationTable{
  ["of_heg__lifeng"] = "李丰",
  ["#of_heg__lifeng"] = "朱提太守",
  ["cv:of_heg__lifeng"] = "秦且歌",
  ["illustrator:of_heg__lifeng"] = "NOVART",
  ["~of_heg__lifeng"] = "吾，有负丞相重托。",
}

local yangwan = General:new(extension, "ty_heg__yangwan", "shu", 3, 3,General.Female) -- 保留原本的前缀
yangwan:addSkills{"ty_heg__youyan", "ty_heg__zhuihuan"}
yangwan:addCompanions("hs__machao")

Fk:loadTranslationTable{
  ["ty_heg__yangwan"] = "杨婉",
  ["#ty_heg__yangwan"] = "融沫之鲡",
  --["designer:yangwan"] = "",
  ["illustrator:ty_heg__yangwan"] = "木美人",
  ["~ty_heg__yangwan"] = "遇人不淑……",
}

General:new(extension, "of_heg__lingcao", "wu", 4):addSkill("of_heg__dujin")
Fk:loadTranslationTable{
  ["of_heg__lingcao"]= "凌操",
  ["#of_heg__lingcao"] = "激流勇进",
  ["illustrator:of_heg__lingcao"] = "樱花闪乱",
  ["~of_heg__lingcao"] = "呃啊！（扑通）此箭……何来……",
}

General(extension, "os_heg__himiko", "qun", 3, 3, General.Female):addSkills{"guishu", "yuanyuk"}
Fk:loadTranslationTable{
  ['os_heg__himiko'] = '卑弥呼', -- 十年心版
  ["#os_heg__himiko"] = "邪马台的女王",
  ["illustrator:os_heg__himiko"] = "聚一_小道恩",
  ["designer:os_heg__himiko"] = "淬毒",
  ["~os_heg__himiko"] = "我还会从黄泉比良坂回来的……",
}

General:new(extension, "of_heg__xurong", "qun", 4):addSkill("of_heg__xionghuo")

Fk:loadTranslationTable{
  ["of_heg__xurong"] = "徐荣",
  ["#of_heg__xurong"] = "玄菟战魔",
  ["cv:of_heg__xurong"] = "曹真",
  ["designer:of_heg__xurong"] = "Loun老萌",
  ["illustrator:of_heg__xurong"] = "青岛磐蒲",
  ["~of_heg__xurong"] = "死于战场……是个不错的结局……",
}

return extension
