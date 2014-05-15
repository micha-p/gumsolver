require 'constraints'
require 'values'

-- OVERWRITING GLOBAL ARITHMETICS

NEW = vnew
POS = function(a)   return a.v>0  end 
ZRO = function(a)   return a.v==0 end 
NEG = function(a)   return a.v<0  end 

ADD = vadd
SUB = vsub
MUL = vmul
DIV = vdiv
AMP = vamp
SQU = vsqu
RT2 = vrt2
CUB = vcub
RT3 = vrt3
EXP = vexp
LOG = vlog
MIN = vmin
MAX = vmax
LIM = vlim
ABS = vabs

-- GLOBALS
EQUAL   = function (a,b) return a.v == b.v and a.D2 == b.D2 end 
PRINTV  = function (r) return (not r and ".")
                              or
                              (not r.v and ".")
                              or
                              BEST and best(r.v,5) 
                              or 
                              string.format("%-15G",r.v) 
          end
PRINTE  = function (r) return (RELATIVE and r.d2 and best(100 * math.sqrt(r.d2),2) .. "%") 
                              or 
                              r.D2 and best(math.sqrt(r.D2),3) 
          end
PRINTX  = function (r) return (not r and ".")
                              or
                              numbertest(r) and string.format("%-15G",r) 
                              or
                              ERRORS and r.d2 and (PRINTV(r) ..  " ± " .. PRINTE(r))
                              or
                              PRINTV(r)
                              end 

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

--[[
A = make_connector()
B = cexp (A)
C = clog (B)
probe ("A", A)
probe ("B", B)
probe ("C", C)

A.set ("user", vnew(1))
A.forget ("user")
A.set ("user", vnew(2))   -- e^2 = 7.38905609893
A.forget ("user")
A.set ("user", vnew(10))   -- e^10 = 22026.4657948
--]]

--[[
A = make_connector()
B = make_connector()
M = cmin(A,B)
probe ("A", A)
probe ("B", B)
probe ("MIN", M)

A.set ("user", vnew(1))
B.set ("user", vnew(2))
B.forget ("user")
A.forget ("user")
B.set ("user", vnew(3))
M.set ("user", vnew(2)) --> A = 2
M.forget ("user")
M.set ("user", vnew(4)) --> Error
M.forget ("user")
B.forget ("user")
A.set ("user", vnew(5))
M.set ("user", vnew(0)) --> B = 0
--]]


