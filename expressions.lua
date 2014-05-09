package.path = package.path .. ";include/?.lua"
require 'constraints_with_values'
require 'display'
require 'parser'

CONNECTORS={}    		-- name: connector (explicitly defined) 
CONSTRAINTS={}   		-- hint or number : constraint 
PROBES={}


eadd=function(x,y,root) c=SUM   (x,y,root);table.insert(CONSTRAINTS,c);return root end
esub=function(x,y,root) c=DIFF  (x,y,root);table.insert(CONSTRAINTS,c);return root end
emul=function(x,y,root) c=PROD  (x,y,root);table.insert(CONSTRAINTS,c);return root end
ediv=function(x,y,root) c=RATIO (x,y,root);table.insert(CONSTRAINTS,c);return root end
emin=function(x,y,root) c=FNMIN (x,y,root);table.insert(CONSTRAINTS,c);return root end
esqu=function(x,  root) c=SQUARE(x,root);  table.insert(CONSTRAINTS,c);return root end
ecub=function(x,  root) c=CUBE  (x,root);  table.insert(CONSTRAINTS,c);return root end
esqr=function(x,  root) c=SQROOT(x,root);  table.insert(CONSTRAINTS,c);return root end
eexp=function(x,  root) c=FNEXP(x,root);   table.insert(CONSTRAINTS,c);return root end
elog=function(x,  root) c=FNLOG(x,root);   table.insert(CONSTRAINTS,c);return root end
eval=function(  v,root) c=CONST (root,v);  table.insert(CONSTRAINTS,c);return root end
eargmin=function(target,root) c=argmin_constraint(root,target); table.insert(CONSTRAINTS,c);return root end
epartial=function(x,y,root) c=partial_constraint(x,y,root); table.insert(CONSTRAINTS,c);return root end

function run (connector, val , abs , rel) 
   if connector then
      if val then 
         local new = tabletest (val) and val or vnew (val, abs, rel)
         local scale = connector["scale"]
         if scale then
            connector.set ("user", vamp(new, scale))
         else
            connector.set ("user", new)
         end
      else
         connector.forget ("user")
      end
   else
      for name,c in pairs(CONNECTORS) do c.forget ("user") end
   end
end

function ensure_symbol (name, connector)
   if TRACE then print(warn("Ensure",name,CONNECTORS[name])) end
   if not CONNECTORS[name] then 
      CONNECTORS[name]= connector or make_connector()
   end
   local c = CONNECTORS[name]
   c["name"] = name
return c
end

function ensure_symbol_and_probe(name, connector)
   if TRACE then print(warn("Ensure",name,CONNECTORS[name],PROBES[name],CONNECTORS[name] and CONNECTORS[name]["unit"])) end
   if not CONNECTORS[name] then ensure_symbol (name, connector) end
   if not PROBES[name] then 
         PROBES[name] = probe (name, CONNECTORS[name]) 
   end
return CONNECTORS[name]
end

function EVAL(expr, rootconnector)
   local function apply (op1, infix, op2)
      local root = rootconnector or ensure_symbol(infix..table.count(CONNECTORS) + 1)
      local r = infix=="+" and eadd (op1, op2, root)
          	or
          	infix=="-" and esub (op1, op2, root)
          	or
          	infix=="*" and emul (op1, op2, root)
          	or
          	infix=="/" and ediv (op1, op2, root)
          	or
          	infix=="min" and emin (op1, op2, root)
          	or
          	infix=="exp" and eexp (op2, root)
          	or
          	infix=="log" and elog (op2, root)
          	or
          	infix=="argmin" and eargmin (op2, root)
          	or
          	infix=="partial" and epartial (op1, op2, root)
          	or
          	infix=="^" and op2==2 and esqu (op1, root)
          	or
          	infix=="^" and op2==3 and ecub (op1, root)
          	or
          	infix=="^" and op2==0.5 and esqr (op1, root)
          	or
          	infix=="^" and error("Only squares, cubes and square roots allowed",PRINTV(op1),PRINTV(op2))
      r["info"]=infix
   return r
   end
return stringtest(expr) and extract_value(expr) and eval(vreader(expr), ensure_symbol("="..table.count(CONNECTORS) + 1))
       or
       stringtest(expr) and ensure_symbol_and_probe(expr)
       or
       numbertest(expr) and eval (vnew(expr), ensure_symbol("="..table.count(CONNECTORS) + 1))
       or
       tabletest(expr)  and expr[2]=="^" and apply (EVAL(expr[1]),expr[2],expr[3]) 
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

c=CONNECTORS
process ("F","( (9 / 5 ) * C ) + 32" )
process ("K","C + 273.15")
process ("R","80 * (C / 100)")

run(c["C"], 25)
run(c["F"], 212)
run(c["C"])
run(c["F"], 212)
run(c["F"])
run(c["K"],0)
run(c["K"])
run(c["R"], 80)
run(c["R"])
run(c["R"], 0)
run(c["R"])
run(c["C"], 100) 

for k,v in pairs(CONNECTORS) do display("con", k, v["name"]) end
for k,v in pairs(CONSTRAINTS) do display(k, v["info"]) end
for k,v in pairs(PROBES) do display(k) end


--]]

