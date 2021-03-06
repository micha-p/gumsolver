-- providing some commonly used table functions

table.foreach = function (t, func)
  for key,value in pairs(t) do func (key, value) end
end

table.map = function (t, func)
  local new = {}
  for key,value in pairs(t) do new[key] = func(value) end
  return new
end

table.find = function (t, value)
  for k,v in pairs(t) do
    if v==value then return k end
  end
  return nil
end

table.count = function (t)
  local n=0
  for k,v in pairs(t) do n = n + 1 end
  return n
end

