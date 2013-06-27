dofile ("constraints.lua")
dofile ("values.lua")
dofile ("csv.lua")


init_algebra (vadd,vsub,vmul,vdiv)
init_print   (function (v)   return v.abs () end) 
init_equal   (function (a,b) return a.v == b.v and a.D2 == b.D2 end) 

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
      -- print ("Process ", name, "with value:" , rec[name])
      run (c, connector, rec[name], rec[name.."+-"] or rec[name.."±"], rec[name.."%"] and rec[name.."%"]/100) 
   end
end

c={}  -- global connector table
c["w"] = make_connector()
c["h"] = make_connector()
c["area"] = cmul (c["w"],c["h"])



for name,connector in pairs(c) do print("Field:",name); probe(name,connector) end
r=csv_read("table.csv",",")


for line, record in ipairs(r) do process_record (c, record) ; print ("===============") end





