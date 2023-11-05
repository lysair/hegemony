local hegemony_standard = require "packages/hegemony/hegemony_standard"
local formation = require "packages/hegemony/formation"[1]
local momentum = require "packages/hegemony/momentum"[1]
local transformation = require "packages/hegemony/transformation"[1]
local power = require "packages/hegemony/power"[1]
local tenyear = require "packages/hegemony/tenyear_heg"
local overseas = require "packages/hegemony/overseas_heg"
local lunar = require "packages/hegemony/lunar_heg"
local ex = require "packages/hegemony/lord_ex"

local hegemony_cards = require "packages/hegemony/hegemony_cards"
local strategic_advantage = require "packages/hegemony/strategic_advantage"
local formation_cards = require "packages/hegemony/formation"[2]
local momentum_cards = require "packages/hegemony/momentum"[2]
local transformation_cards = require "packages/hegemony/transformation"[2]
local power_cards = require "packages/hegemony/power"[2]

Fk:loadTranslationTable(require 'packages/hegemony/i18n/en_US', 'en_US')

return {
  hegemony_standard,
  formation,
  momentum,
  transformation,
  power,
  tenyear,
  overseas,
  lunar,
  ex,

  hegemony_cards,
  strategic_advantage,
  formation_cards,
  momentum_cards,
  transformation_cards,
  power_cards,
}
