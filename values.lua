dofile "display.lua"

function createvalue (i)
   local ret={}
   if i.name ~= NIL then ret.name = i.name end
   if i.mean ~= NIL then ret.mean = i.mean end
   if i.unit ~= NIL then ret.unit = string.gsub (i.unit, "µ", "\\u") end
   if i.se   ~= NIL then ret.se = i.se else ret.se = 0 end
   if i.info ~= NIL then ret.info = i.info end
   ret.string = function () 
                   return ret.name .. " [" .. ret.unit .. "] = " .. ret.mean .. " +- " .. ret.se 
                end
   ret.ascii  = function () 
                   return ( string.gsub (ret.string(), "\\u", "u") )
                end
   ret.pretty = function () 
                  return (ret.name .. " [" .. 
                          string.gsub(
                             string.gsub(
                                string.gsub(
                                   string.gsub(
                                      string.gsub (ret.unit, "\\u", "µ"),
                                      "3", "³"), 
                                   "2","²"),
                                "1","¹"),
                             "-", "¯") .. "] = " .. ret.mean .. " ± " .. ret.se)
                end
   return ret
end


leafarea= createvalue {name="area", mean=0.01,unit="m2",se=0.001, info="projected leaf area"}

print(leafarea)
print(leafarea.mean)
print(leafarea.se)
print(leafarea.unit)

display(leafarea)
display(leafarea.ascii())

display(light)

light= createvalue {name="ppfd", mean=1000, unit="µmol m-2 s-1",se="10", info="phpt..."}

print(light.ascii())
print(light.string())
print(light.pretty())
display(leafarea.ascii())
