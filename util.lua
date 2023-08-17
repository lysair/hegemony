local H = {}

---@param from ServerPlayer
---@param to ServerPlayer
---@param diff bool
---@return boolean
H.compareKingdomWith = function(from, to, diff)
  if from.kingdom == "unknown" or to.kingdom == "unknown" then
    return false
  end

  local ret = from.kingdom == to.kingdom
  if diff then ret = not ret end
  return ret
end

-- H.军令 = function xxx

return H
