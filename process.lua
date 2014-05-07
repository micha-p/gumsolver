function process_input(line)
      if line:find("^#[A-Z]") then
         process_directive(line)
      else
         -- first remove comments
         -- then leading and trailing whitespace as well as closing semicolon
         process_line(string.match(line:match("^([^#]*)#?.*$"), "^%s*(.*)%s*;?$"))
      end
end

    
function process_line (input)   
   if not input or input=="" then return end
   if MASK then reservemaskline(name) end
   if string.find (input, "=") then
      local left=extract_left(input)
      local right=extract_right(input)
      local name=extract_name(left)
      local expr=extract_expr(right)
      assert(left and right,"Can't understand equation:"..input.."$")
      if left == name then 
         if string.match (expr, "^%s*$") then	    				-- name =
            if DEBUG then print(warn(PRINT16(name), "=\t .")) end
            run(ensure_symbol_and_probe (name))
         elseif string.match (expr, "^%s*%.%s*$") then    			-- name = .
            if DEBUG then print(warn(PRINT16(name), "=\t .")) end
            run(ensure_symbol_and_probe (name))
         elseif string.match (expr, "^%s*"..NUMBERPATTERN.."%s*$") then    	-- name = number
            local val = vreader(expr)
            if DEBUG then print(warn(PRINT16(name), "=\t", expr)) end
            run(ensure_symbol_and_probe (name), val)
         elseif string.match (expr, "^%s*"..VALUEPATTERN.."%s*$") then    	-- name = value +- uncertainty
            local val = vreader(expr)
            if DEBUG then print(warn(PRINT16(name), "=\t", expr)) end
            run(ensure_symbol_and_probe (name), val)
         elseif string.match (expr, "^%s*"..NAMEPATTERN.."%s*$") then      	-- name = name
            local a = ensure_symbol_and_probe (name)
            local b = ensure_symbol_and_probe (expr)
            pipe (a, b, RET, RET)
            if DEBUG then print(warn(PRINT16(name), "=\t", expr)) end
         elseif  string.find (expr, EXPRPATTERN) then				-- name = expression
            if DEBUG then print(warn(PRINT16(name), "=\t", pretty(unpack(order(parse(expr)))))) end
            DEFINITIONS[name]=expr
            EVAL(order(parse(expr)), ensure_symbol_and_probe (name))
         else
            error ("Can't resolve right side: "..expr)
         end
      else
         if string.match (left, "^%s*"..NUMBERPATTERN.."%s*$") then    		-- number = expr
            local rexpr = pretty(order(parse(right)))
            local num = tonumber(extract_number(left))
            if DEBUG then print(warn(PRINT16(num), "=\t", rexpr)) end
            local b = ensure_symbol_and_probe (rexpr)
            pipe (EVAL(num), b, RET, RET)
            EVAL(order(parse(right)), b)
         elseif string.match (right, "^%s*"..NUMBERPATTERN.."%s*$") then    	-- expr = number
            local lexpr = pretty(order(parse(left)))
            local num = tonumber(extract_number(right))
            if DEBUG then print(warn(lexpr, "=\t", num)) end
            local a = ensure_symbol_and_probe (lexpr)
            pipe (a, EVAL(num), RET, RET)
            EVAL(order(parse(left)), a)
         elseif string.match (left, "^%s*"..VALUEPATTERN.."%s*$") then    	-- value +- uncertainty = expr
            local val = vreader(left)
            if DEBUG then print(warn(PRINT16(val), "=\t", expr)) end
            error ("Values with uncertaninty are not allowed on left side. Use variable instead!")
         elseif  string.find (left, EXPRPATTERN) then               		-- expression = expression
            local lexpr = pretty(order(parse(left)))
            local rexpr = pretty(order(parse(right)))
            local a = ensure_symbol_and_probe (lexpr)
            local b = ensure_symbol_and_probe (rexpr)
            pipe (a, b, RET, RET)
            EVAL(order(parse(left)), a)
            EVAL(order(parse(right)), b)
         else
            error ("Can't resolve left side: "..left)
         end
      end
   else 
      local expr=extract_expr(input)
      local name=extract_name(input)
      local unit=extract_unit(input)
      if DEBUG then print(warn("left",left,"name",name,"expr",expr)) end
      assert(name,"Can't find name"..input.."$")
      if name ~= expr then							-- expression
         local lexpr = pretty(order(parse(expr)))
         if DEBUG then print(warn(lexpr)) end
         local a = ensure_symbol_and_probe (lexpr)       	
         EVAL(order(parse(expr)), a)
      elseif unit then
         local c = ensure_symbol_and_probe (name, ensure_symbol(name))		-- name [unit]
         c["scale"] = SCALE[unit]
         c["unit"] = unit
         if DEBUG then print(warn (name,unit)) end
         run(CONNECTORS[name])
      else
         ensure_symbol_and_probe (name)       			 		-- name
         run(CONNECTORS[name])
      end
   end
end

function process_directive(line)
   local function setrelative (v)
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
   local out  = line:match("^#PR?I?N?T? (.*)$")
   return 
      line:find("^#P") and (TABLE or RECORD) and  warn (out or "")
      or
      line:find("^#P") and MASK and printfullmaskline (out or "")
      or
      line:find("^#P") and (print (out or "") or not nil)
      or
      line:find("^#U") and (readunit (rest) or not nil)
      or
      line:find("^#I") and process_include(arg)
      or
      line:find("^#O") and record_connectors()
      or
      line:find("^#RECO?R?D?") and record_connectors()
      or
      line:find("^#R") and setrelative(not nil)
      or
      line:find("^#A") and setrelative (nil)
      or
      line:find("^#TRA?C?E?") and trace(tonumber(line:match("^#TRA?C?E?%s+([%S]+)")))
      or
      line:find("^#VE?R?B?O?S?I?T?Y?") and verbosity(tonumber(line:match("^#VE?R?B?O?S?I?T?Y?%s+([%S]+)")))
      or
      line:find("^#DEBUG") and verbosity(2)
      or
      line:find("^#T") and ((arg and tabulate_selected(rest)) or tabulate_record())
      or
      line:find("^#D") and (dump_connectors() or not nil)
      or
      error ("Unknown directive in line: " .. line)
end



