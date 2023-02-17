function vector_from(angle,magnitude)
  local m=magnitude or 1
  return Vector:new(math.cos(angle)*m,math.sin(angle)*m)
end