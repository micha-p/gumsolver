
function dump16(k)  io.stderr:write(PRINT16(k),"\t") end

function dump_short_list(list)
   local out={}
   for n,obj in ipairs(list) do 
      if obj.class ~= "probe" then
         if table.find(CONSTRAINTS,obj) then table.insert(out,(obj.info or "").."("..table.find(CONSTRAINTS,obj)..")") end
         if table.find(CONNECTORS, obj) then table.insert(out,table.find(CONNECTORS,obj)) end
      end
   end
   io.stderr:write (string.format("%-40.39s", table.concat(out," ")))
end


function dump_connectors()

   local function printright(connector)
      if connector.value() then  
         dump16(PRINTX(connector.get()))
         print2(stringtest(connector.value()) and " ("..connector.value()..")")
      else
         print2(".")
      end
   end   
         
   print2()   
   print2("CONNECTORS:\tLISTENERS:\t\t\t\tINTERNAL VALUE:")
   for k,v in pairs (CONNECTORS) do
      dump16(k)
      dump_short_list(v.listeners())
      printright(v)
   end
end

function dump_probes_and_constraints()

   print2()   
   print2("PROBES:\t\tSETTERS:\t\tUNIT:\t\tSCALED VALUE:")
   for k,v in pairs (PROBES) do
      local slist = v.setters() 
      dump16(k)
      for n,setter in ipairs(slist) do
         dump16(table.find(CONNECTORS,setter))
         dump16(PRINT16(setter.unit or "\t"))
         dump16(PRINTX(get_scaled_val_from_connector(setter)))
      end
      print2()
   end
      
   print2()   
   print2("CONSTRAINTS:\tSETTERS:\t\t\t\tNUMBER:")
   for n,constraint in ipairs (CONSTRAINTS) do
      dump16(constraint.info or "")
      dump_short_list(constraint.setters())
      print2(n)
   end
end
