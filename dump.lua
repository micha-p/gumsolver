function dump_connectors()

   function name(k)  io.write(PRINT16(k),"\t") end
   
   function printlisteners(ltable)
      local out=""
      for k,l in pairs(ltable) do 
         if l["class"] ~= "probe" then
            out=out..table.find(CONSTRAINTS,l)..l["info"]
         else
            if DEBUG then 
               out=out.."?"..table.find(PROBES,l) 
            end
         end
         out=out.." "
      end
   io.write (string.format(DEBUG and "%-36.35s" or "%-24s", out))
   end

   function printsetters(ltable)
      local out=""
      for k,l in pairs(ltable) do 
         if table.find(CONNECTORS,l) then
            out=out .. table.find(CONNECTORS,l)
         end
         out=out.." "
      end
   io.write (string.format(DEBUG and "%-36.35s" or "%-24s", out))
   end

   function right(connector)
      if connector["value"] then  
         informant=(connector.value())
         io.write (informant and PRINT(connector.get()) or "", stringtest(informant) and " ("..informant..")" or "","\n")
      else
         print()
      end
   end   
         
   print()   
   print("CONNECTORS:\tLISTENERS:")
   for k,v in pairs (CONNECTORS) do
      name(k)
      printlisteners(v.listeners())
      right(v)
   end
      
   print()   
   print("CONSTRAINTS:\tSETTERS:")
   for k,v in pairs (CONSTRAINTS) do
      name(k..v["info"])
      printsetters(v.setters())
      print()
   end
      
   if DEBUG then 
      print()   
      print("PROBES:\t\tUnit:\t\tSETTERS:")
      for k,v in pairs (PROBES) do
         name(k)
         name(v["unit"] or "")
         printsetters(v.setters())
         print()
      end
   end
end
