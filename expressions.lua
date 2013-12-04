require 'constraints_with_values'
require 'parser'

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

function EVAL(createfunc, expr)
   local function apply (op1, infix, op2)
   return infix=="+" and cadd (op1, op2)
          or
          infix=="-" and csub (op1, op2)
          or
          infix=="*" and cmul (op1, op2)
          or
          infix=="/" and cdiv (op1, op2)
   end
return stringtest(expr) and createfunc(expr)
       or
       numbertest(expr) and cval (vnew(expr))
       or
       tabletest(expr)  and apply (EVAL(createfunc,expr[1]),expr[2],EVAL(createfunc,expr[3])) 
       or
       error ("Can't resolve expression: "..node)
end 


function REMOVEprocess_expr (createfunc, formula)
   name=extract_name(formula)
   expr=extract_expr(formula)
   c[name] = EVAL(createfunc, order(parse(expr)))
   probe(name,c[name])
end

--[[

c={} 

function create(name) 
   if not c[name] then
      c[name]=make_connector()
      probe(name,c[name])
   end
return c[name]
end

process_expr (create,"F = ( (9 / 5 ) * C ) + 32" )
process_expr (create,"K = C + 273.15")
process_expr (create,"R = 80 * (C / 100)")

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

--]]

