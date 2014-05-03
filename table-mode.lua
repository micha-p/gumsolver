function clear_tableline (c, columns)
   for n,name in pairs(columns) do 
      if DEBUG then warn("CLEAR "..name) end
      run (c, c[name])
   end
end

function process_headerfield(c, colname)
return colname:match("%+%-$") 
       or 
       colname:match("±$") 
       or 
       colname:match ("%%$")
       or 
       colname:match ("=") and process_line(colname)
       or
       process_line(colname)
end

function print_resulting_tableline (colnames) 
   local con,value,check
   local r={}
   for k,v in ipairs(colnames) do 
      con=CONNECTORS[v]
      gen=CONNECTORS[v:match("(.*)%+%-$") or v:match("(.*)±$") or v:match("(.*)%%$")]
      r[k] = ERRORS and con and con.value() and PRINT16(PRINT(get_scaled_val_from_connector(con)))
             or
             con and con.value() and PRINT16(best(get_scaled_val_from_connector(con)["v"],6))
             or 
             gen and gen.value() and v:find("%%$") and PRINT16(best(math.sqrt(gen.get()["d2"])*100,2)) 
             or 
             gen and gen.value() and PRINT16(best(math.sqrt(gen.get()["D2"]),3))
             or
             "."
   end
return r
end

function process_table(connectortable, DELIMITER, filehandle)
   records,header,colnames = csv_read(DELIMITER, filehandle)
   for col, colname in ipairs(header) do process_headerfield(c, colname) end 
   if DEBUG then 
      for name,connector in pairs(connectortable) do ensure_symbol_and_probe (name, connector) end
      io.stderr:write (SCRIPT.." version "..VERSION.. "   TABLE MODE  Separator:")
      io.stderr:write ((DELIMITER == "\t") and "TAB" 
                       or
                       (DELIMITER == " ") and "SPACE"
                       or
                       DELIMITER) 
      io.stderr:write ("      DEBUGGING TO STDERR\n\n")
   end

   for k,v in pairs(colnames) do io.write(PRINT16(v).."\t") end
   print()
   for k,v in pairs(colnames) do io.write(connectortable[v]["unit"] or "".."\t") end
   print()
   for linenumber, one_line in ipairs(records) do 
      clear_tableline(connectortable, colnames)
      if stringtest(one_line) and one_line:find("^#[A-Z]") then
         if one_line:find("^#Q") then
            break
         else
            process_directive(one_line)
         end
      else
         for colnum, field in ipairs(one_line) do 
            process_line(field)
         end
         r= print_resulting_tableline(colnames)
         print(unpack(r))
      end
   end
end
