dofile "display.lua"

-- v=value e=error u=unit

function createvalue (i)
   local ret={}
   if i.v ~= NIL then ret.v = i.v else error ( "No value given!") end
   if i.e ~= NIL then ret.e = i.e else ret.e = 0 end
   if i.u ~= NIL then ret.u = string.gsub (i.u, "µ", "\\u") else ret.u="" end
   if i.name ~= NIL then ret.name = i.name else ret.name = "" end
   if i.info ~= NIL then ret.info = i.info end
   ret.e2 = ret.e^2 -- redundant information for better efficiency

   ret.string = function () 
                   return ret.name .. " [" .. ret.u .. "] = " .. ret.v .. " +- " .. ret.e 
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
                                      string.gsub (ret.u, "\\u", "µ"),
                                      "3", "³"), 
                                   "2","²"),
                                "1","¹"),
                             "-", "¯") .. "] = " .. ret.v .. " ± " .. ret.e)
                end
   return ret
end

function vnew (value, err, unit) return createvalue{v=value; e=err; u=unit} end

function vcheck (a , b) return a.name == b.name and a.u == b.u or error "name or unit mismatch" end
 
function vinv (a)
   return vnew (- a.v, a.e, a.u)
end 

function vadd (a, b)
   vcheck (a,b)
   return vnew (a.v + b.v , math.sqrt(a.e2 + b.e2), a.u)
end 

function vsub (a, b)
   vcheck (a,b)
   return vnew (a.v - b.v , math.sqrt(a.e2 + b.e2), a.u)
end 

function vmul (a, b)
   local ar2 = a.e2/a.v^2
   local br2 = b.e2/b.v^2
   local c = a.v * b.v     
   return vnew (c , math.abs(c) * math.sqrt(ar2 + br2), a.u .. " " .. b.u)
end 

function vdiv (a, b)
   local ar2 = a.e2/(a.v^2)
   local br2 = b.e2/(b.v^2)
   local c = a.v / b.v     
   return vnew (c , math.abs(c) * math.sqrt(ar2 + br2), a.u .. " / " .. b.u)
end 


a = vnew ( 10, 1, "m2")
b = vnew ( 12, 1, "m2")
c = vadd ( a , b)

print()
print(a.string())
print(b.string())
print(c.string())

a = vnew ( 10, 1, "m")
b = vnew ( 10, 1, "m")
c = vmul ( a , b)

print()
print(a.string())
print(b.string())
print(c.string())


a = vnew ( 30, 3, "km")
b = vnew ( 10, 1, "h")
c = vdiv ( a , b)

print()
print(a.string())
print(b.string())
print(c.string())





