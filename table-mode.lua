function clear_tableline (columns)
   for n,name in pairs(columns) do 
      if DEBUG then print2(warn("CLEAR "..name)) end
      run (CONNECTORS[name])
   end
end


function process_table(DELIMITER, filehandle)
   local records,header,colnames, quit
   records,header,colnames = csv_read(DELIMITER, filehandle)
   if DEBUG then 
      io.stderr:write (SCRIPT.." version "..VERSION.. "   TABLE MODE  Separator:")
      io.stderr:write ((DELIMITER == "\t") and "TAB" 
                       or
                       (DELIMITER == " ") and "SPACE"
                       or
                       DELIMITER) 
      io.stderr:write ("      DEBUGGING TO STDERR\n\n")
   end
   for col, colname in ipairs(header) do process_line(colname) end 
   if not NOHEADER then 
      for k,v in ipairs(colnames) do io.write(PRINT16(v),"\t") end
      print()
      for k,v in ipairs(colnames) do io.write(PRINT16(CONNECTORS[v] and CONNECTORS[v]["unit"] or ""),"\t") end
      print()
   end
   for linenumber, one_line in ipairs(records) do 
         if quit then break end
         clear_tableline(colnames)
         for colnum, field in ipairs(one_line) do 
            if field:find("^#Q") then
               quit=not nil
               break
            elseif field:find("^#[A-Z]") then
               process_directive(field)
            elseif field~="" then 
               process_line(header[colnum].."="..field) 
            end
         end
         do_itertable()
         for k,v in ipairs(colnames) do io.write(PRINT16(PRINTX(CONNECTORS[v] and get_scaled_val_from_connector(CONNECTORS[v]))).."\t") end
         print()
   end
end
