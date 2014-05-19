function clear_tableline (columns)
   for n,name in pairs(columns) do 
      if DEBUG then print2(warn("CLEAR "..name)) end
      run (CONNECTORS[name])
   end
end


function process_table(DELIMITER, filehandle)
   local records={}
   local header={}
   local colnames={}
   local quit

   records = csv_read(DELIMITER, filehandle)
   if records and records[1] then header = records[1] end
   for i, columnhead in ipairs(header) do 
      process_contentline(columnhead)
      colnames[i]=columnhead:find("=") and columnhead:match("%s*(.+)%s*=") or columnhead
   end 
   for k,v in ipairs(colnames) do io.write(PRINT16(v),"\t") end
   print()
   for k,v in ipairs(colnames) do io.write(PRINT16(CONNECTORS[v] and CONNECTORS[v]["unit"] or ""),"\t") end
   print()
   for linenumber, one_line in ipairs(records) do 
         if quit then break end
         clear_tableline(colnames)
         for colnum, field in ipairs(one_line) do 
            if not process_inputline(header[colnum].."="..field) then break end
         end
         do_itertable()
         for k,v in ipairs(colnames) do io.write(PRINT16(PRINTX(CONNECTORS[v] and get_scaled_val_from_connector(CONNECTORS[v]))).."\t") end
         print()
   end
end
