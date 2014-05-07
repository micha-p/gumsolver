RECORDS = {}

function print_record()
   local r={}
   local sorted={}
   
   for k,v in pairs(CONNECTORS) do table.insert(sorted,k) end
   table.sort(sorted)
   
   for i,n in ipairs(sorted) do
      v=CONNECTORS[n] 
      if TABLE or RECORD then 
         if DEBUG then warn (PRINT16(n), v.value() and PRINT(v.get()) or "") end
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
   run() --> clear
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
