RECORDS = {}

function print_record()
   local r={}
   local sorted={}
   
   for k,v in pairs(CONNECTORS) do table.insert(sorted,k) end
   table.sort(sorted)
   
   for i,n in ipairs(sorted) do
      v=CONNECTORS[n] 
      if TABLE or RECORD then 
         if DEBUG then orange (PRINT16(n), v.value() and PRINT(v.get()) or "") end
      else
         if not MUTE then print (PRINT16(n), v.value() and PRINT(v.get()) or "") end
      end
   end
end


function save_record()
   local r={}
   for k,v in pairs(CONNECTORS) do 
      r[k]=v.value() and v.get()
   end
   table.insert(RECORDS,r)
end

function clear_record()
   local old = MUTE
   MUTE=not nil
   run(CONNECTORS) --> clear
   MUTE= old
end

function record_connectors()
   print_record()
   save_record()
   clear_record()
return not nil   
end

function tabulate_records()
   local colnames={}
   local headers={}
  
   for k,v in pairs (CONNECTORS) do 
      table.insert(colnames,k) 
      table.insert(headers,DEFINITIONS[k] and k.."="..DEFINITIONS[k] or k) 
      table.insert(headers,RELATIVE and k.."%" or k.."±") 
   end
   
   print(unpack(headers))
   for line, record in ipairs(RECORDS) do 
      local r={}
      for k,v in pairs (colnames) do 
         table.insert(r, PRINTV(record[v])) 
         table.insert(r, PRINTE(record[v])) 
      end
      print(unpack(r))
   end
return not nil
end

function tabulate_selected(head)
   print(head)
   for line, record in ipairs(RECORDS) do 
      for k,v in pairs (record) do 
         if head:find(k) then
            io.write(PRINTV(v),"\t±",PRINTE(v),"\t")
         end 
      end
      print()
   end
return not nil
end

function dump_connectors()
   function name(k)  io.write(PRINT16(k),"\t") end
   function left(v)  io.write (short(v), "\t") end
   function printconnections(ltable)
      local out={}   
      for k,l in pairs(ltable) do 
         info=l["info"] and l.info() 
         if DEBUG then 
            table.insert(out, informant == l and "!" or "")
            table.insert(out, short(l))
            table.insert(out, "=")
            table.insert(out, info or "")
         else
            table.insert(out, info or ".")
         end   
         table.insert(out, " ")
      end
   io.write (string.format(DEBUG and "%-48.47s" or "%-24s",table.concat(out)))
   end

   function right(v)
      if v["value"] then  
         informant=(v.value())
         io.write (informant and PRINT(v.get()) or "", stringtest(informant) and " ("..informant..")" or "","\n")
      else
         print()
      end
   end   
      
   local keys={}
   for k,v in pairs(CONNECTORS) do table.insert(keys, k) end
   table.sort(keys) 
   
   print("SYMBOLS (CONNECTORS):")
   for k,v in pairs (DEBUG and CONNECTORS or keys) do
      if DEBUG then left (v); name(k) else name(v); v=CONNECTORS[v] end
      ltable=  v["listeners"] and (v.listeners()) or {}
      printconnections(ltable)
      right(v)
   end
   print("SUBEXPRESSIONS (CONNECTORS):")
   for k,v in pairs (SUBEXPRESSIONS) do
      if DEBUG then left (v) end
      name(k)
      informant=(v.value())
      ltable=(v.listeners())
      printconnections(ltable)
      right(v)
   end
   print("CONSTRAINTS:")
   for k,v in pairs (CONSTRAINTS) do
      if DEBUG then left (v) end
      name(k)
      setters=(v.setters())
      printconnections(setters)
      print ()
   end

   if DEBUG then
      print("PROBES:")
      for k,v in pairs (PROBES) do
      if DEBUG then left (v) end
         name(k)
         setters=(v.setters())
         printconnections(setters)
         print ()
      end
   end
end
