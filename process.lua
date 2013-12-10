function process_input(line)
      if line:find("^#[A-Z]") then
         process_directive(line)
      else
         -- first remove comments and then leading and trailing whitespace
         process_line(string.match(line:match("^([^#]*)#?.*$"), "^%s*(.*)%s*$"))
      end
end

    
function process_line (input)   
   local name=extract_name(input)
   local unit=extract_unit(input)
   local expr=extract_expr(input)
   local val

   if not input then return end
   if input=="" then return end
   if not name  then error ("Name not recognized:"..input.."$") return end
   if MASK then reservemaskline(name, nil, unit) end

   if expr then
      if string.match (expr, NAMEPATTERN.."@[%d]+") then          	-- name@...
         local entry  = string.match (expr, NAMEPATTERN) 
         local recnum = tonumber(string.match (expr, "@([%d]+)")) 
         local rec = assert (RECORDS[recnum], "Invalid record number: "..recnum)
         run(CONNECTORS, ensure_symbol_and_probe(name), rec[entry])
      elseif string.match (input, NAMEPATTERN.."%s*=%s*$") then		-- name =
         local c = CONNECTORS[name]
         if c then 
            local val = getval_from_connector_with_unit(c)
            if not MASK then print (val) end
            return val
         end
      elseif  string.find (expr, "[%a*/%(%)]") then               	-- name = expression
         if DEBUG then warn(PRINT16(name), expr) end
         DEFINITIONS[name]=expr
         EVAL(order(parse(expr)), ensure_symbol_and_probe(name))
      elseif string.match (expr, "^[%s%d%.%_%±%+%-%%]*$") then    	-- name = value
         local val
         val = vreader(expr)
         if DEBUG then warn(PRINT16(name), expr.." (user)") end
         run (c, ensure_symbol_and_probe(name), val)
      else
         error ("Can't resolve right side: "..expr)
      end
   else 
      if unit then
         ensure_symbol_and_probe_with_unit (name, unit)            	-- name [unit]
         run(CONNECTORS, CONNECTORS[name])
      else
         ensure_symbol_and_probe(name)                             	-- name
         run(CONNECTORS, CONNECTORS[name])
      end
   end
end

function process_directive(line)
   local function set (v)
      RELATIVE=v
      return not nil
   end
   local function trace(num)
      TRACE=num and (num==1) or not TRACE
      return not nil
   end
   local function verbosity(num)
      DEBUG = num and (num==2) or nil
      MUTE = num and (num==0) or nil
      return not nil
   end
   local arg  = line:match("^#[A-Z]+%s+([%S]+)")
   local rest = line:match("^#[A-Z]+%s+(.*)$")
   return 
      line:find("^#P") and (TABLE or RECORD) and  warn (line:match("^!PR?I?N?T? (.*)$") or "")
      or
      line:find("^#P") and MASK and printfullmaskline (rest)
      or
      line:find("^#P") and (print (rest) or not nil)
      or
      line:find("^#U") and (readunit (rest) or not nil)
      or
      line:find("^#A") and set (nil)
      or
      line:find("^#I") and process_include(arg)
      or
      line:find("^#O") and record_connectors()
      or
      line:find("^#RECO?R?D?") and record_connectors()
      or
      line:find("^#R") and set(not nil)
      or
      line:find("^#TRA?C?E?") and trace(tonumber(line:match("^#TRA?C?E?%s+([%S]+)")))
      or
      line:find("^#VE?R?B?O?S?I?T?Y?") and verbosity(tonumber(line:match("^#VE?R?B?O?S?I?T?Y?%s+([%S]+)")))
      or
      line:find("^#T") and ((arg and tabulate_selected(rest)) or tabulate_record())
      or
      line:find("^#D") and (dump_connectors() or not nil)
      or
      error ("Unknown directive in line: " .. line)
end



