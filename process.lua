function process_inputline(line)
      if line:find("^#[A-Z]") then
         return process_directive(line:match("^#(.*)$"))
      elseif line:find("#") then
         return process_inputline(line:match("^([^#]*)#.*$"))  	-- ignore comments
      elseif line:find (";%s*$") then
         return process_inputline(line:match("^([^;]*);%s*$"))  	-- ignore closing semicolon
      else
         process_contentline(line:match("^%s*(.*)%s*$")) 	-- remove leading and trailing whitespace
         return not nil
      end
end


    
function process_contentline (input)   
   if not input or input=="" then return end
   if string.find (input, "=") then
      local left=extract_left(input)
      local right=extract_right(input) or ""
      local name=extract_name(left)
      local unit=extract_unit(left)
      assert(left and right,"Can't understand equation: "..input.."$")
      if unit then
         if string.match (right, "^%s*"..NUMBERPATTERN.."%s*$") then    	-- name [unit] = number
            local val = vreader(right)
            local c = ensure_symbol_and_probe (name)
            if DEBUG then print2(PRINT16(name).." UNITNUM"..unit, "=\t", PRINT16(val)) end
            c["unit"] = unit
            c["scale"] = assert(SCALE[unit]," Unit not declared:"..unit)
            CONNECTORS[name]=c
            run(c, val)
         elseif extract_value(right) then   				 	-- name [unit] = value +- uncertainty
            local val = vreader(right)
            local c = ensure_symbol_and_probe (name)
            if DEBUG then print2(PRINT16(name).." UNIT "..unit, "=\t", PRINT16(val)) end
            c["unit"] = unit
            c["scale"] = assert(SCALE[unit]," Unit not declared:"..unit)
            CONNECTORS[name]=c
            run(c, val)
         else
            error("Can't understand right side:"..right)
         end
      elseif left == name then 
         -- if MASK then reservemaskline(name) end
         if string.match (right, "^%s*$") then	    				-- name =
            if DEBUG then print2(PRINT16(name), "=\t .") end
            run(ensure_symbol_and_probe (name))
         elseif string.match (right, "^%s*%.%s*$") then    			-- name = .
            if DEBUG then print2(PRINT16(name), "=\t .") end
            run(ensure_symbol_and_probe (name))
         elseif string.match (right, "^%s*"..NUMBERPATTERN.."%s*$") then    	-- name = number
            local val = vreader(right)
            if DEBUG then print2(PRINT16(name), "=\t", right) end
            run(ensure_symbol_and_probe (name), val)
         elseif extract_value(right) then   				 	-- name = value +- uncertainty
            local val = vreader(right)
            if DEBUG then print2(PRINT16(name), "=\t", right) end
            run(ensure_symbol_and_probe (name), val)
         elseif string.match (right, "^%s*"..NAMEPATTERN.."%s*$") then      	-- name = name
            local a = ensure_symbol_and_probe (name)
            local b = ensure_symbol_and_probe (right)
            pipe (a, b, RET, RET)
            if DEBUG then print2(PRINT16(name), "=\t", right) end
         elseif  string.find (right, EXPRPATTERN) then				-- name = expression
            local expr=extract_expr(right)
            if DEBUG then print2(PRINT16(name), "=\t", expr) end
            if DEBUG then print2(PRINT16(name), "=\t", pretty(unpack(order(parse(expr))))) end
            DEFINITIONS[name]=expr
            EVAL(order(parse(expr)), ensure_symbol_and_probe (name))
         else
            error ("Can't resolve right side: "..right)
         end
      else
         if string.match (left, "^%s*"..NUMBERPATTERN.."%s*$") then    		-- number = expr
            local rexpr = pretty(order(parse(right))):gsub("%s*","")
            local num = tonumber(extract_number(left))
            if DEBUG then print2(PRINT16(num), "=\t", rexpr) end
            local b = ensure_symbol (rexpr)
            pipe (EVAL(num), b, RET, RET)
            EVAL(order(parse(right)), b)
         elseif string.match (right, "^%s*"..NUMBERPATTERN.."%s*$") then    	-- expr = number
            local lexpr = pretty(order(parse(left))):gsub("%s*","")
            local num = tonumber(extract_number(right))
            if DEBUG then print2(lexpr, "=\t", num) end
            local a = ensure_symbol_and_probe (lexpr)
            pipe (a, EVAL(num), RET, RET)
            EVAL(order(parse(left)), a)
         elseif extract_value(left) then    					-- value +- uncertainty = expr
            local val = vreader(left)
            if DEBUG then print2(PRINT16(val), "=\t", expr) end
            error ("Values with uncertaninty are not allowed on left side. Use variable instead!")
         elseif  string.find (left, EXPRPATTERN) then               		-- expression = expression
            local lexpr = pretty(order(parse(left))):gsub("%s*","")
            local rexpr = pretty(order(parse(right))):gsub("%s*","")
            local a = ensure_symbol_and_probe (lexpr)
            local b = ensure_symbol (rexpr)
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
      assert(name or expr,"Can't understand: "..input.."$")
      if string.match (input, "^%s*"..NUMBERPATTERN.."%s*$") then		-- number 
         local num = tonumber(extract_number(input))
         if DEBUG then print2(num) end
         if not MUTE then print(num) end
      elseif extract_value(input) then 				  		-- value +- uncertainty
         local val = vreader(input)
         if DEBUG then print2(PRINT16(val)) end
         if not MUTE then print (PRINTX(val)) end
      elseif unit then
         local c = ensure_symbol_and_probe (name, ensure_symbol(name))		-- name [unit]
         c["scale"] = SCALE[unit]
         c["unit"] = unit
         if DEBUG then print2(name,unit) end
         if MASK then reservemaskline(name) end
         run(CONNECTORS[name])
      elseif string.match (input, "^%s*%-%-%s*".."%d+".."%s*$") then		-- -- line
         local line = tonumber(string.match (input, "^%s*%-%-%s*".."(%d+)".."%s*$"))
         if DEBUG then print2("-- #"..line) end
         if MASK then clearmaskline(line) end
      elseif string.match (input, "^%s*%-%-%s*"..NAMEPATTERN.."%s*$") then	-- -- name
         if DEBUG then print2("-- "..name) end
         ensure_symbol_and_probe (name)       			
         if MASK then clearmaskline(name) end
      elseif name ~= expr then							-- expression
         local lexpr = pretty(order(parse(expr))):gsub("%s*","")
         if DEBUG then print2(lexpr) end
         local a = ensure_symbol_and_probe (lexpr)       	
         EVAL(order(parse(expr)), a)
      else									-- name
         if DEBUG then print2(name) end
         ensure_symbol_and_probe (name)
         if MASK then reservemaskline(name) end
         run(CONNECTORS[name])
      end
   end
end


function process_directive(line)
   local cmd  = line:match("^([A-Z]+)")
   local arg  = line:match("^[A-Z]+%s+([%S]+)")
   local rest = line:match("^[A-Z]+%s+(.*)$")
   process_flags(cmd)
   
   if line:find("^Q") or line:find("^DUM?P?") then
      return nil
   elseif line:find("^P") then
      return (TABLE or RECORD) and print2(rest or "")
             or
             MASK and printmaskremarkline (rest or "")
             or
             (print (rest or "") or not nil)
   elseif line:find("^U") then 
      readunit (rest)
      return not nil
   elseif line:find("^I") then 
      if DEBUG then print2("INCLUDE\t",f,"\n") end
      return process_file(f)
   else
      process_flags(cmd)
   end
end



