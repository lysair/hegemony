local H = {}

---@param from ServerPlayer
---@param to ServerPlayer
---@param diff bool
---@return boolean
H.compareKingdomWith = function(from, to, diff)
  if from == to then
    return not diff
  end
  for _, p in ipairs({from, to}) do
    if p.kingdom == "unknown" and p.deputyGeneral ~= "anjiang" then
      p.kingdom = Fk.generals[p.deputyGeneral].kingdom
      if RoomInstance then
        RoomInstance:broadcastProperty(p, "kingdom")
      end
    end
  end
  if from.kingdom == "unknown" or to.kingdom == "unknown" then
    return false
  end

  local ret = from.kingdom == to.kingdom
  if diff then ret = not ret end
  return ret
end

-- H.军令 = function xxx

return H
