function print2stderr (name, sep, value)
    io.stderr:write (name .. "\t " .. sep .. " \t" .. tostring(value) .."\n")
end

function probe2stderr (name, connector)
  local me = {}
  me = make_actor (function () print2stderr (name, PRINT (connector.get())) end, function () print2stderr (name,"=","?") end)
  connector.connect(me)
  return me
end


function process_record (c, rec)
   run(c)
   for name,connector in pairs(c) do 
      run (c, connector, rec[name], not rec[name.."%"] and (rec[name.."+-"] or rec[name.."±"]), rec[name.."%"] and rec[name.."%"]/100) 
   end
end

function process_column(c, colname)
   local function new()
      c[colname]=make_connector()
      return c[colname]
   end
return colname:match("%+%-$") 
       or 
       colname:match("±$") 
       or 
       colname:match ("%%$")
       or 
       colname:match ("=") and process_formula(c, colname)
       or
       new()
end

function print_result (c, colnames) 
   local con,value,check
   local r={}
   for k,v in ipairs(colnames) do 
      con=c[v]
      gen=c[v:match("(.*)%+%-$") or v:match("(.*)±$") or v:match("(.*)%%$")]
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

function process_table(CONNECTORS, DELIMITER)
   records,header,colnames=csv_read(DELIMITER)
   for col, colname in ipairs(header) do process_column(CONNECTORS, colname) end 
   if DEBUG then 
      for name,connector in pairs(CONNECTORS) do probe2stderr(name,connector) end
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
      process_record (CONNECTORS, record)
      r= print_result(CONNECTORS, colnames)
      print(unpack(r))
   end
end
