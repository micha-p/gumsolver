dofile ("constraints.lua")
dofile ("values.lua")
dofile ("csv.lua")
dofile ("parser.lua")

init_algebra (vadd,vsub,vmul,vdiv)
init_print   (function (v)   return v.abs () end) 
init_equal   (function (a,b) return a.v == b.v and a.D2 == b.D2 end) 


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

function process_record (c, rec)
   run(c)
   for name,connector in pairs(c) do 
      run (c, connector, rec[name], rec[name.."+-"] or rec[name.."±"], rec[name.."%"] and rec[name.."%"]/100) 
   end
end


function process_formula(c, formula)
   local function apply (op1, infix, op2)
   return infix=="+" and cadd (op1, op2)
          or
          infix=="-" and csub (op1, op2)
          or
          infix=="*" and cmul (op1, op2)
          or
          infix=="/" and cdiv (op1, op2)
   end

   local function eval(node)
   return stringtest(node) and c[node]
          or
          stringtest(node) and process_column(c, node)
          or
          numbertest(node) and cv(vnew(node))
          or
          tabletest(node) and apply (eval(node[1]),node[2],eval(node[3])) 
          or
          error ("Can't resolve expression: "..node)
   end 

   name=formula:match("%s*([%a][%w%-]*)%s*=")
   expr=formula:match(".*=(.*)$")
   c[name]=eval(order(parse(expr)))
return c[name]
end
    
function process_column(c, colname)
   local function new()
      c[colname]=make_connector()
      return c[colname]
   end
return colname:match("%+%-$") 
       or 
       colname:match("±$") 
       or 
       colname:match ("%%$")
       or 
       colname:match ("=") and process_formula(c, colname)
       or
       new()
end

function print_result (c, colnames) 
   local con,value,check
   local r={}
   for k,v in ipairs(colnames) do 
      con=c[v]
      gen=c[v:match("(.*)%+%-$") or v:match("(.*)±$") or v:match("(.*)%%$")]
      r[k] = con and con.value() and con.get()["v"]
             or 
             gen and gen.value() and v:find("%%$") and math.sqrt(gen.get()["d2"])*100 
             or 
             gen and gen.value() and math.sqrt(gen.get()["D2"])
             or
             "."
   end
return r
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

