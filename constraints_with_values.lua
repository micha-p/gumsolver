dofile ("constraints.lua")
dofile ("values.lua")
dofile ("csv.lua")
dofile ("parser.lua")

-- OVERLOAD!!
genadd = function (a1, a2, sum)  z=constraint(a1,a2,sum , vadd, vsub,"+") table.insert (CONSTRAINTS,z); return z end
gensub = function (a1, a2, diff) z=constraint(a1,a2,diff, vsub, vadd,"-") table.insert (CONSTRAINTS,z); return z end
genmul = function (m1, m2, prod) z=constraint(m1,m2,prod, vmul, vdiv,"*") table.insert (CONSTRAINTS,z); return z end
gendiv = function (a1, a2, sum)  z=constraint(a1,a2,sum , vdiv, vmul,"/") table.insert (CONSTRAINTS,z); return z end
genset = function (v, con)       z=constant (con,v)                       table.insert (CONSTRAINTS,z); return z end 
cadd   = function (c,x,y,h) local z = make_connector(h); table.insert (c,z); genadd (x,y,z) return z end
csub   = function (c,x,y,h) local z = make_connector(h); table.insert (c,z); gensub (x,y,z) return z end
cmul   = function (c,x,y,h) local z = make_connector(h); table.insert (c,z); genmul (x,y,z) return z end
cdiv   = function (c,x,y,h) local z = make_connector(h); table.insert (c,z); gendiv (x,y,z) return z end
cv     = function (c,x  ,h) local z = make_connector(h); table.insert (c,z); genset (x,  z) return z end
-- END OVERLOAD

PRINT = function (v)   return v.abs() end
EQUAL = function (a,b) return a.v == b.v and a.D2 == b.D2 end 


function run (connectortable, connector, val , abs , rel) 
   if connector then
      if val then 
         connector.set (001, tabletest (val) and val or vnew (val, abs, rel))
      else
         connector.forget (001)
      end
   else
      for name,c in pairs(connectortable) do c.forget (001) end
   end
end



function process_formula(c,cs,formula)

   local function apply (op1, infix, op2)
   return infix=="+" and cadd (cs, op1, op2, infix)
          or
          infix=="-" and csub (cs, op1, op2, infix)
          or
          infix=="*" and cmul (cs, op1, op2, infix)
          or
          infix=="/" and cdiv (cs, op1, op2, infix)
   end

   local function eval(node,hint)
   return stringtest(node) and c[node]
          or
          stringtest(node) and process_column(c, node)
          or
          numbertest(node) and cv(cs, vnew(node), node) -- constant value without uncertainty
          or
          tabletest(node) and apply (eval(node[1]),node[2],eval(node[3])) 
          or
          error ("Can't resolve expression: "..node)
   end 

   name=extract_name(formula) -- name is already known and inserted in all cases?
   expr=extract_expr(formula)
   c[name]=eval(order(parse(expr)))
return c[name]
end
    


--[[
c={}
dofile ("display.lua")

process_column (c, "C")
process_column (c, "F = ( (9 / 5 ) * C ) + 32" )
process_column (c, "K = C + 273.15")
process_column (c, "R = 80 * (C / 100)")

probe ("Celsius    ", c["C"])
probe ("Fahrenheit ", c["F"])
probe ("Kelvin     ", c["K"])
probe ("Reaumur    ", c["R"])

run(c,c["C"], 25)
run(c,c["F"], 212)
run(c,c["C"])
run(c,c["F"], 212)
run(c,c["F"])
run(c,c["K"],0)
run(c,c["K"])
run(c,c["R"], 80)
run(c,c["R"])
run(c,c["R"], 0)
run(c,c["R"])
run(c,c["C"], 100) ]]

