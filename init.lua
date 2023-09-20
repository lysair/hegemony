local hegemony_standard = require "packages/hegemony/hegemony_standard"
local formation = require "packages/hegemony/formation"[1]
local momentum = require "packages/hegemony/momentum"
local transformation = require "packages/hegemony/transformation"
local power = require "packages/hegemony/power"
local tenyear = require "packages/hegemony/tenyear_heg"
local overseas = require "packages/hegemony/overseas_heg"
local lunar = require "packages/hegemony/lunar_heg"
local ex = require "packages/hegemony/lord_ex"

local hegemony_cards = require "packages/hegemony/hegemony_cards"
local strategic_advantage = require "packages/hegemony/strategic_advantage"
local formation_cards = require "packages/hegemony/formation"[2]

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
}
