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

   name=formula:match("%s*(.+)%s*=")
   expr=formula:match(".*=(.*)$")
   c[name]=eval(parse(expr))
return not nil
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



