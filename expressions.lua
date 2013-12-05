package.path = package.path .. ";include/?.lua"
require 'constraints_with_values'
require 'display'
require 'parser'

CONNECTORS={}    		-- name: connector (explicitly defined) 
CONSTRAINTS={}   		-- hint or number : constraint 
PROBES={}

eadd=function(x,y,z) c=SUM   (x,y,z);c["info"]="+";table.insert(CONSTRAINTS,c);return z end
esub=function(x,y,z) c=DIFF  (x,y,z);c["info"]="-";table.insert(CONSTRAINTS,c);return z end
emul=function(x,y,z) c=PROD  (x,y,z);c["info"]="*";table.insert(CONSTRAINTS,c);return z end
ediv=function(x,y,z) c=RATIO (x,y,z);c["info"]="/";table.insert(CONSTRAINTS,c);return z end
eval=function(  v,z) c=CONST (z,v  );c["info"]="=";table.insert(CONSTRAINTS,c);return z end

function run (connectortable, connector, val , abs , rel) 
   if connector then
      if val then 
         connector.set ("user", tabletest (val) and val or vnew (val, abs, rel))
      else
         connector.forget ("user")
      end
   else
      for name,c in pairs(connectortable) do c.forget ("user") end
   end
end

function ensure_symbol (name, connector)
   if not CONNECTORS[name] then 
      CONNECTORS[name]= connector or make_connector()
   end
return CONNECTORS[name]
end

function ensure_symbol_and_probe(name, connector)
   ensure_symbol (name, connector)
   if not PROBES[name] then 
         PROBES[name] = probe (name, CONNECTORS[name]) 
   end
return CONNECTORS[name]
end

function EVAL(expr, rootconnector)
   local function apply (op1, infix, op2)
      local root = rootconnector or ensure_symbol(infix..table.count(CONNECTORS) + 1)
   return infix=="+" and eadd (op1, op2, root)
          or
          infix=="-" and esub (op1, op2, root)
          or
          infix=="*" and emul (op1, op2, root)
          or
          infix=="/" and ediv (op1, op2, root)
   end
return stringtest(expr) and ensure_symbol_and_probe(expr)
       or
       numbertest(expr) and eval (vnew(expr), ensure_symbol("="..table.count(CONNECTORS) + 1))
       or
       tabletest(expr)  and apply (EVAL(expr[1]),expr[2],EVAL(expr[3])) 
       or
       error ("Can't resolve expression: >"..expr.."<")
end 

--[[

function process(name, expr)
   local root = ensure_symbol_and_probe (name)
   EVAL (order(parse(expr)), root)
end

process ("F","( (9 / 5 ) * C ) + 32" )
process ("K","C + 273.15")
process ("R","80 * (C / 100)")

c=CONNECTORS
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
run(c,c["C"], 100) 

for k,v in pairs(CONNECTORS) do display("con", k, v["name"]) end
for k,v in pairs(CONSTRAINTS) do display(k, v["info"]) end
for k,v in pairs(PROBES) do display(k) end


--]]

