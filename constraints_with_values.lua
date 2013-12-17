require 'display'
require 'constraints'
require 'values'

ADD = vadd
SUB = vsub
MUL = vmul
DIV = vdiv
SQU = vsqu
SQR = vsqr

-- GLOBALS
EQUAL   = function (a,b) return a.v == b.v and a.D2 == b.D2 end 
PRINTV  = function (r) return r and best(r.v,4) or "." end
PRINTE  = function (r) return not r and "." or (RELATIVE and best(100 * math.sqrt(r.d2),2) .. "%") or best(math.sqrt(r.D2),3) end
PRINT   = function (r) return r and (PRINTV(r) ..  " ± " .. PRINTE(r)) or "." end 
PRINT16 = function (r) return string.format("%-15.15s",r) end

--[[

C = make_connector()
F = cadd (cmul (cdiv(cval(vnew(9)),cval(vnew(5))) , C) , cval(vnew(32)))
K = csub (C, cval (vnew(-273.15)))
R = cmul (cval(vnew(80)), cdiv (C, cval(vnew(100))))

probe ("Celsius    ", C)
probe ("Fahrenheit ", F)
probe ("Kelvin     ", K)
probe ("Reaumur    ", R)

C.set("user", vnew(25))
F.set("user", vnew(212))
C.forget("user")
F.set("user", vnew(212))
F.forget("user")
K.set("user",vnew(0))
K.forget("user")
R.set("user", vnew(80,nil,0.04))
R.forget("user")
R.set("user", vnew(0))
R.forget("user")
C.set("user", vnew(100,1))
--]]

