function clear_tableline (c, columns)
   for n,name in pairs(columns) do 
      if DEBUG then warn("CLEAR "..name) end
      run (c, c[name])
   end
end

function process_tableline (c, columns, rec)
   for name, value in pairs(columns) do 
      if DEBUG then warn("SET "..name.."="..value) end
      run (c, c[name], vreader(value)) 
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
       ensure_symbol(colname)
end

function print_resulting_tableline (colnames) 
   local con,value,check
   local r={}
   for k,v in ipairs(colnames) do 
      con=CONNECTORS[v]
      gen=CONNECTORS[v:match("(.*)%+%-$") or v:match("(.*)±$") or v:match("(.*)%%$")]
      r[k] = con and con.value() and PRINT(con.get())
             or 
             gen and gen.value() and v:find("%%$") and best(math.sqrt(gen.get()["d2"])*100,2) 
             or 
             gen and gen.value() and best(math.sqrt(gen.get()["D2"]),3)
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

   print(unpack(table.map(colnames,function(x) return PRINT16(x) end)))
   for line, record in ipairs(records) do 
      clear_tableline(connectortable, colnames)
      process_tableline (connectortable, record)
      r= print_resulting_tableline(colnames)
      print(unpack(r))
   end
end
