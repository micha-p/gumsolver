-- estimate, square of absolute uncertainty, square of relative uncertainty

function vfast (v, squared_abs_error, squared_rel_error)
   local r={}
   r.v  = v
   r.D2 = squared_abs_error or (squared_rel_error and ( squared_rel_error^0.5 * v )^2) or 0
   r.d2 = squared_rel_error or (squared_abs_error and ( squared_abs_error^0.5 / v )^2) or 0

   r.rel = function () return r.v .. " ± " .. 100 * math.sqrt(r.d2) .. "%" end
   r.abs = function () return r.v .. " ± " .. math.sqrt(r.D2) end

   return r
end

-- vfast <= squared errors
-- vnew  <= unsquared errors

function vnew (v, D, d) return vfast( v , D and D^2, d and d^2) end
function vinv (a)       return vfast (- a.v, a.D2, a.d2) end 
function vrec (a)       return vfast (1/a.v, nil , a.d2) end 
function vadd (a, b)    return vfast (a.v + b.v , a.D2 + b.D2, nil) end 
function vsub (a, b)    return vfast (a.v - b.v , a.D2 + b.D2, nil) end
function vmul (a, b)    return vfast (a.v * b.v , nil, a.d2 + b.d2) end
function vdiv (a, b)    return vfast (a.v / b.v , nil, a.d2 + b.d2) end
function vamp (a, s)    return vfast (a.v * s ,  nil, a.d2)                                              end    -- relative error identical
function vsqu (a)       return vnew  (a.v ^ 2 ,      a.D2 == 0 and 0, a.D2 ~= 0 and a.d2^0.5 * 2   or 0) end    -- relative error doubled
function vcub (a)       return vnew  (a.v ^ 3 ,      a.D2 == 0 and 0, a.D2 ~= 0 and a.d2^0.5 * 3   or 0) end    -- relative error three times
function vsqr (a)       return vnew  (a.v ^ 0.5,     a.D2 == 0 and 0, a.D2 ~= 0 and a.d2^0.5 / 2   or 0) end    -- relative error halfed
function vexp (a)       return vnew  (math.exp(a.v), a.D2^0.5 * math.exp(a.v) or 0) end                         -- absolute error multiplied
function vlog (a)       return vnew  (math.log(a.v), a.D2^0.5 / a.v or 0) end                                   -- absolute error divided


function vreader (str)
 local space="%s*"
 local num="-?[%d_]*%.?[%d_]*"
 local err="[%+%-%±]*"
 local rel="%%?"
 local v,s,e,r
 
 function make (val,err,rflag)
     return vnew (val, (not rflag) and err, rflag and err and err/100)
 end

 v= string.match(str, space.."("..num..")"..space..err..space..num..space..rel)
 s= string.match(str, space..num..space.."("..err..")"..space..num..space..rel)
 e= string.match(str, space..num..space..err..space.."("..num..")"..space..rel)
 r= string.match(str, space..num..space..err..space..num..space.."("..rel..")")

-- warn (v,"|", s,"|",e,"|",r)
 return make(tonumber(v:gsub("_",""),10) or error("error while parsing as value with uncertainty: "..str),
             tonumber(e:gsub("_",""),10) or nil,
             r=="%")
end
 


--[[
dofile ("display.lua")

a = vreader ("200+-5")
b = vreader ("200±5")
c = vreader ("200+-5%")
d = vreader ("200±5%")
print(a.abs(), b.abs(), c.abs(), d.abs())
print(a.rel(), b.rel(), c.rel(), d.rel())
a = vreader ("200   +-       5")
b = vreader (".1±5")
c = vreader ("   .1+-.5%")
d = vreader ("200±5       %")
print(a.abs(), b.abs(), c.abs(), d.abs())
print(a.rel(), b.rel(), c.rel(), d.rel())
print()

s=vsub(vnew(100,5), vnew (30,5))
print(s.abs(), s.rel())
s=vsub(vnew(100,5), vnew (1,5))
print(s.abs(), s.rel())
s=vsub(vnew(100,5), vnew (0.001,5))
print(s.abs(), s.rel())

s=vsub(vnew(30,5), vnew (100,5))
print(s.abs(), s.rel())
s=vsub(vnew(1,5), vnew (100,5))
print(s.abs(), s.rel())
s=vsub(vnew(0.001,5), vnew (100,5))
print(s.abs(), s.rel())

print("\nsmall differences are dangerous!")
a=vnew(0.99,0.01) ; s=vsub(a, vnew (1))
print(a.abs(), a.rel(), s.abs(), s.rel())
a=vnew(0.99,0.05) ; s=vsub(a, vnew (1))
print(a.abs(), a.rel(), s.abs(), s.rel())
a=vnew(0.99,0.10) ; s=vsub(a, vnew (1))
print(a.abs(), a.rel(), s.abs(), s.rel())

a=vnew(0.99,nil, 0.01) ; s=vsub(a, vnew (1))
print(a.abs(), a.rel(), s.abs(), s.rel())
a=vnew(0.99,nil, 0.05) ; s=vsub(a, vnew (1))
print(a.abs(), a.rel(), s.abs(), s.rel())
a=vnew(0.99,nil, 0.10) ; s=vsub(a, vnew (1))
print(a.abs(), a.rel(), s.abs(), s.rel())
--]]


