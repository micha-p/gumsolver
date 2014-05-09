-- estimate, square of absolute uncertainty, square of relative uncertainty

function vfast (v, squared_abs_error, squared_rel_error)
   local r={}
   r.v  = v
   r.D2 = squared_abs_error or (squared_rel_error and ( squared_rel_error^0.5 * v )^2)
   r.d2 = squared_rel_error or (squared_abs_error and ( squared_abs_error^0.5 / v )^2)

   r.rel = function () return r.v .. " ± " .. 100 * math.sqrt(r.d2 or 0) .. "%" end
   r.abs = function () return r.v .. " ± " .. math.sqrt(r.D2 or 0) end

   return r
end

-- vfast <= squared errors (stored format)
-- vnew  <= unsquared errors

function vnew (v, D, d) return vfast( v , D and D^2, d and d^2) end
function vinv (a)       return vfast (- a.v, a.D2, a.d2) end 
function vabs (a)       return vfast (math.abs(a.v), a.D2, a.d2) end 
function vrec (a)       return vfast (1/a.v, nil , a.d2) end 
function vadd (a, b)    return vfast (a.v + b.v , a.D2 and b.D2 and a.D2 + b.D2 or a.D2 or b.D2, nil) end 
function vsub (a, b)    return vfast (a.v - b.v , a.D2 and b.D2 and a.D2 + b.D2 or a.D2 or b.D2, nil) end
function vmul (a, b)    return vfast (a.v * b.v , nil, a.d2 and b.d2 and a.d2 + b.d2 or a.d2 or b.d2) end
function vdiv (a, b)    return vfast (a.v / b.v , nil, a.d2 and b.d2 and a.d2 + b.d2 or a.d2 or b.d2) end
function vamp (a, s)    return vfast (a.v * s ,   nil, a.d2) end    				-- relative error identical
function vsqu (a)       return vnew  (a.v ^ 2 ,   nil, a.d2 and a.d2^0.5 * 2) end    		-- relative error doubled
function vcub (a)       return vnew  (a.v ^ 3 ,   nil, a.d2 and a.d2^0.5 * 3) end    		-- relative error three times
function vrt2 (a)       return vnew  (a.v ^ 0.5,  nil, a.d2 and a.d2^0.5 / 2) end    		-- relative error halfed
function vrt3 (a)       return vnew  (a.v ^ 1/3,  nil, a.d2 and a.d2^0.5 / 3) end    		-- relative error one third
function vexp (a)       return vnew  (math.exp(a.v), a.D2 and a.D2^0.5 * math.exp(a.v)) end	-- absolute error multiplied
function vlog (a)       return vnew  (math.log(a.v), a.D2 and a.D2^0.5 / a.v) end           	-- absolute error divided
function vmin (a, b)    return (a.v < b.v) and a or b end
function vlim (r, x)    if (r.v>x.v) then print ("EXCEEDING MINIMUM!", r.abs() , x.abs()) else return r end end


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
dofile ("include/display.lua")

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

--[[
A = vnew(3,1)
B = vnew(2,0.5)
M = vmin(A,B)
print(M.abs())
L = vlim(M,B)
print(L.abs())
M = vnew(100)
L = vlim(M,A)
print(L.abs())
--]]
