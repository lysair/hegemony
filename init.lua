

local prefix = "packages.hegemony.pkg."
local gamemodes = require(prefix .. "gamemodes")

local hegemony_standard = require(prefix .. "standard")
local formation = require(prefix .. "formation")
local momentum = require(prefix .. "momentum")
--[[
local transformation = require "packages/hegemony/transformation"
local power = require "packages/hegemony/power"
local tenyear = require "packages/hegemony/tenyear_heg"
local overseas = require "packages/hegemony/overseas_heg"
local offline = require "packages/hegemony/offline_heg"
--]]
local ex = require(prefix .. "lord_ex")
local ziqidonglai = require(prefix .. "zqdl")

local hegemony_cards = require(prefix .. "standard_cards")
local strategic_advantage = require(prefix .. "strategic_advantage")
--[[
local formation_cards = require "packages/hegemony/formation"[2]
local momentum_cards = require "packages/hegemony/momentum"[2]
local transformation_cards = require "packages/hegemony/transformation"[2]
local power_cards = require "packages/hegemony/power"[2]
--]]
local lord_cards = require(prefix .. "lord_cards")

Fk:loadTranslationTable{ ["hegemony"] = "国战" }
Fk:loadTranslationTable(require 'packages/hegemony/i18n/en_US', 'en_US')

return {
  gamemodes,

  hegemony_standard,
  formation,
  momentum,
  --[[
  transformation,
  power,
  tenyear,
  overseas,
  offline,
  --]]
  ex,
  ziqidonglai,

  hegemony_cards,
  strategic_advantage,
  lord_cards,
}
