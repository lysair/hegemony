local prefix = "packages.hegemony.pkg."
local gamemodes = require(prefix .. "gamemodes")

local hegemony_standard = require(prefix .. "standard")
local formation = require(prefix .. "formation")
local momentum = require(prefix .. "momentum")
local transformation = require(prefix .. "transformation")
local power = require(prefix .. "power")
local ex = require(prefix .. "lord_ex")
local ziqidonglai = require(prefix .. "zqdl")

local mobile = require(prefix .. "mobile_heg")
local tenyear = require(prefix .. "tenyear_heg")
local overseas = require(prefix .. "overseas_heg")
local offline = require(prefix .. "offline_heg")

local hegemony_cards = require(prefix .. "standard_cards")
local strategic_advantage = require(prefix .. "strategic_advantage")
local lord_cards = require(prefix .. "lord_cards")

Fk:loadTranslationTable{ ["hegemony"] = "国战" }
Fk:loadTranslationTable(require 'packages/hegemony/i18n/en_US', 'en_US')

return {
  gamemodes,

  hegemony_standard,
  formation,
  momentum,
  transformation,
  power,
  ex,
  ziqidonglai,

  mobile,
  tenyear,
  overseas,
  offline,

  hegemony_cards,
  strategic_advantage,
  lord_cards,
}
