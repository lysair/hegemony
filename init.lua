local prefix = "packages.hegemony.pkg."

local hegemony_standard = require(prefix .. "standard")
local formation = require(prefix .. "formation")[1]
local momentum = require(prefix .. "momentum")[1]
--[[
local transformation = require "packages/hegemony/transformation"[1]
local power = require "packages/hegemony/power"[1]
local tenyear = require "packages/hegemony/tenyear_heg"
local overseas = require "packages/hegemony/overseas_heg"
local offline = require "packages/hegemony/offline_heg"
local ex = require "packages/hegemony/lord_ex"
--]]

local hegemony_cards = require(prefix .. "standard_cards")
local strategic_advantage = require(prefix .. "strategic_advantage")
--[[
local formation_cards = require "packages/hegemony/formation"[2]
local momentum_cards = require "packages/hegemony/momentum"[2]
local transformation_cards = require "packages/hegemony/transformation"[2]
local power_cards = require "packages/hegemony/power"[2]
--]]
Fk:loadTranslationTable{ ["hegemony"] = "国战" }
Fk:loadTranslationTable(require 'packages/hegemony/i18n/en_US', 'en_US')

return {
  hegemony_standard,
  formation,
  -- momentum,
  --[[
  transformation,
  power,
  tenyear,
  overseas,
  offline,
  ex,
  --]]

  hegemony_cards,
  strategic_advantage,
  --[[
  formation_cards,
  momentum_cards,
  transformation_cards,
  power_cards,
  -- ]]
}
