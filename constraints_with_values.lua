dofile ("constraints.lua")
dofile ("values.lua")
dofile ("csv.lua")


init_algebra (vadd,vsub,vmul,vdiv)
init_print   (function (v)   return v.abs () end) 
init_equal   (function (a,b) return a.v == b.v and a.D2 == b.D2 end) 

nine = cv (vnew (9))
five = cv (vnew (5))
abs =  cv (vnew (-273.15))
v32 =  cv (vnew (32))
v80 =  cv (vnew (80))
v100 = cv (vnew (100))

C = make_connector()
F = cadd (cmul (cdiv (nine,five) , C) , v32 )
K = csub (C, abs)
R = cmul (v80, cdiv (C, v100))

probe ("Celsius    ", C)
probe ("Fahrenheit ", F)
probe ("Kelvin     ", K)
probe ("Reaumur    ", R)

function vreader (str)
 sp="%s*"
 num="-?%d*%.?%d*"
 err="[+-±]*"
 rel="%%?"
 function make (val,err,rel)
    return vnew (val, (not rel) and err or nil, rel and err and err/100 or nil)
 end

 a,b,c= string.find(str,sp.."("..num..")"..sp..err..sp..num..sp..rel)
 d,e,f= string.find(str,sp..num..sp.."("..err..")"..sp..num..sp..rel)
 g,h,i= string.find(str,sp..num..sp..err..sp.."("..num..")"..sp..rel)
 j,k,l= string.find(str,sp..num..sp..err..sp..num..sp.."("..rel..")")

 return make(tonumber(c) or error("error while parsing: "..str),
             tonumber(i) or nil,
             l=="%")
end



function run ( connector, s) 
if s then 
    connector.set (001, numbertest (s) and vnew (tonumber(s)) or vreader (s) )
  else
    connector.forget (001)
  end
end


--[[
r=csv_read("table.csv")

display (r)]]
