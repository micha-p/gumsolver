dofile ("constraints.lua")
dofile ("values.lua")
dofile ("csv.lua")
dofile ("parser.lua")

init_algebra (vadd,vsub,vmul,vdiv)
init_print   (function (v)   return v.abs () end) 
init_equal   (function (a,b) return a.v == b.v and a.D2 == b.D2 end) 


c={}  -- global connector table

function run (connectortable, c, val , abs , rel) 
   if c then
      if val then 
         c.set (001, vnew (val, abs, rel))
      else
         c.forget (001)
      end
   else
      for name,connector in pairs(connectortable) do connector.forget (001) end
   end
end

function process_record (c, rec)
   run(c)
   for name,connector in pairs(c) do 
      run (c, connector, rec[name], rec[name.."+-"] or rec[name.."±"], rec[name.."%"] and rec[name.."%"]/100) 
   end
end

function process_and_print (c, rec)
   run(c)
   for name,connector in pairs(c) do 
      run (c, connector, rec[name], rec[name.."+-"] or rec[name.."±"], rec[name.."%"] and rec[name.."%"]/100) 
   end
   
end


function process_formula(formula)
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
          numbertest(node) and cv(vnew(node))
          or
          tabletest(node) and apply (eval(node[1]),node[2],eval(node[3])) 
   end 

   name=formula:match("%s*(.+)%s*=")
   expr=formula:match(".*=(.*)$")
   c[name]=eval(parse(expr))
return not nil
end
    
function process_column(colname)
   local function new()
      c[colname]=make_connector()
      return nil
   end
return colname:match("%+%-$") 
	or 
   	colname:match("±$") 
   	or 
   	colname:match ("%%$")
   	or 
   	colname:match ("=") and process_formula(colname)
   	or
   	new()
end


r,h=csv_read("tableformula.txt","\t")

for col, colname in ipairs(h) do print("Field:",colname); process_column(colname) end 
for name,connector in pairs(c) do probe(name,connector) end
for line, record in ipairs(r) do process_record (c, record) ; print ("===============") end

display (r)



