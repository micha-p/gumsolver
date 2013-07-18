function process_record (c, rec)
   run(c)
   for name,connector in pairs(c) do 
      run (c, connector, rec[name], not rec[name.."%"] and (rec[name.."+-"] or rec[name.."±"]), rec[name.."%"] and rec[name.."%"]/100) 
   end
end

function process_column(c, colname)
   local function new()
      c[colname]=make_connector(colname)
      return c[colname]
   end
return colname:match("%+%-$") 
       or 
       colname:match("±$") 
       or 
       colname:match ("%%$")
       or 
       colname:match ("=") and process_formula(c, CONSTRAINTS, colname)
       or
       new(colname)
end

function print_result (colnames) 
   local con,value,check
   local r={}
   for k,v in ipairs(colnames) do 
      con=CONNECTORS[v]
      gen=CONNECTORS[v:match("(.*)%+%-$") or v:match("(.*)±$") or v:match("(.*)%%$")]
      r[k] = con and con.value() and best(con.get()["v"],4)
             or 
             gen and gen.value() and v:find("%%$") and best(math.sqrt(gen.get()["d2"])*100,2) 
             or 
             gen and gen.value() and best(math.sqrt(gen.get()["D2"]),3)
             or
             "."
   end
return r
end

function process_table(c, DELIMITER)
   records,header,colnames=csv_read(DELIMITER)
   for col, colname in ipairs(header) do process_column(c, colname) end 
   if DEBUG then 
      for name,connector in pairs(c) do probe2stderr(name,connector) end
      io.stderr:write (SCRIPT.." version "..VERSION.. "   TABLE MODE  Separator:")
      io.stderr:write ((DELIMITER == "\t") and "TAB" 
                       or
                       (DELIMITER == " ") and "SPACE"
                       or
                       DELIMITER) 
      io.stderr:write ("      DEBUGGING TO STDERR\n")
   end
   print(unpack(header))
   for line, record in ipairs(records) do 
      process_record (c, record)
      r= print_result(colnames)
      print(unpack(r))
   end
end
