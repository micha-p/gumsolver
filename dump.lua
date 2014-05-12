function dump_connectors()

   function name(k)  io.stderr:write(PRINT16(k),"\t") end
   
   function printlisteners(ltable)
      local out=""
      for k,l in pairs(ltable) do 
         if l["class"] ~= "probe" then
            out=out..(l["info"] or "")
            if DEBUG then out=out.."("..table.find(CONSTRAINTS,l)..")" end
            out=out.." "
         end
      end
   io.stderr:write (string.format(DEBUG and "%-36.35s" or "%-24s", out))
   end

   function printright(connector)
      if connector["value"] then  
         informant=(connector.value())
         io.stderr:write (informant and PRINTX(connector.get()) or "", stringtest(informant) and " ("..informant..")" or "","\n")
      else
         print2()
      end
   end   
         
   print2()   
   print2("CONNECTORS:\tLISTENERS:")
   for k,v in pairs (CONNECTORS) do
      name(k)
      printlisteners(v.listeners())
      printright(v)
   end
end

function dump_probes_and_constraints()

   function printsetters(ltable)
      local out=""
      for n,connector in ipairs(ltable) do 
         if table.find(CONNECTORS,connector) then
            out=out .. table.find(CONNECTORS,connector)
         end
         out=out.." "
      end
   io.stderr:write (string.format(DEBUG and "%-36.35s" or "%-24s", out))
   end

   print2()   
   print2("PROBES:\t\tSETTERS:\tUNIT:\t\tVALUE:")
   for k,v in pairs (PROBES) do
      local slist = v.setters() 
      name(k)
      for n,setter in ipairs(slist) do
         name(table.find(CONNECTORS,setter))
         name(setter["unit"] or "")
         name(PRINTX(get_scaled_val_from_connector(setter)))
      end
      print2()
   end
      
   print2()   
   print2("#\tCONSTRAINTS:\tSETTERS:")
   for n,constraint in ipairs (CONSTRAINTS) do
      io.stderr:write(tostring(n),"\t") 
      name(constraint["info"] or "")
      printsetters(constraint.setters())
      print2()
   end
end
