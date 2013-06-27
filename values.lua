dofile "display.lua"


function vfast (v, D2, d2)
   local r={}
   r.v  = v
   r.D2 = D2 or d2 and ( d2^0.5 * v )^2 or 0
   r.d2 = d2 or D2 and ( D2^0.5 / v )^2 or 0

   r.rel = function () return r.v .. " ± " .. 100 * math.sqrt(r.d2) .. "%" end
   r.abs = function () return r.v .. " ± " .. math.sqrt(r.D2) end

   return r
end

function vnew (v, D, d) return vfast( v , D and D^2, d and d^2) end
function vinv (a)       return vfast (- a.v, a.D2, a.d2) end 
function vadd (a, b)    return vfast (a.v + b.v , a.D2 + b.D2, nil) end 
function vsub (a, b)    return vfast (a.v - b.v , a.D2 + b.D2, nil) end
function vmul (a, b)    return vfast (a.v * b.v , nil, a.d2 + b.d2) end
function vdiv (a, b)    return vfast (a.v / b.v , nil, a.d2 + b.d2) end


--[[

a = vnew ( 100000, 1)
b = vnew ( 12, 1)
c = vadd ( a , b)

print()
print(a.abs(), b.abs(), c.abs())
print(a.rel(), b.rel(), c.rel())

a = vnew ( 10, 1)
b = vnew ( 10, 1)
c = vmul ( a , b)

print()
print(a.abs(), b.abs(), c.abs())
print(a.rel(), b.rel(), c.rel())

a = vnew ( 30, 3)
b = vnew ( 10, 1)
c = vdiv ( a , b)

print()
print(a.abs(), b.abs(), c.abs())
print(a.rel(), b.rel(), c.rel())

a = vnew ( 10, 2)
b = vnew ( 10, nil, 0.2)
c = vnew ( 10, 2)
d = vnew ( 10, 2)
r = vadd (vadd ( a , b) , vadd ( c , d)) -- relative error gets smaller!!

print()
print(a.abs())
print(a.rel())
print(r.abs())
print(r.rel())
display(a.D2)
display(r.D2)

a = vnew ( 10, 2)
b = vnew ( 10, nil, 0.2)
c = vnew ( 10, 2)
d = vnew ( 10, 2)
r = vmul (vmul ( a , b) , vmul ( c , d))

print()
print(a.abs())
print(a.rel())
print(r.abs())
print(r.rel())
display(a.D2)
display(r.d2) 

print ("\n \n exact value")
n = vnew ( 10)
print (n.abs())

]]

