-- Lua is an elegant and small language

-- therefore there is no real need for booleans
-- therefore it starts counting at 1
-- therefore it does not need ternary operators
-- therefore has no symbols and consequently no need for quoting and application
 
-- it generates efficient code even without using integers
-- it runs on systems without hierarchical file systems
-- it is fully 8-bit clean
-- it should handle typechecking more efficiently than by comparing strings
-- it might adopt these very few convenient scheme functions
----- table-like output (tabulate) inspired by Lua
----- list-like output (write)     inspired by Scheme
----- human-like output (display)  inspired by Lisp Prettyprinting
----- naming not clear


-- six of the seven important types need a predicate
niltest      = function (x) return x == nil end
numbertest   = function (x) return type(x) == "number" end
stringtest   = function (x) return type(x) == "string" end
tabletest    = function (x) return type(x) == "table" end
lambdatest   = function (x) return type(x) == "function" end
threadtest   = function (x) return type(x) == "thread" end
userdatatest = function (x) return type(x) == "userdata" end 


warn=function (...)
   local first = arg[1]
   arg[1]="\27[33m"..tostring(arg[1] or "")
   arg[#arg+1]="\27[m"
return unpack(arg)
end

-- print(1,2,3)
-- print(warn(1,2,3))

best = function (n, precision) 
   if n==0 then
      return "0"
   else 
      precision = precision or 5
      magnitude = math.floor(math.log10(math.abs(n)))+1
      shift     = 10^(precision - magnitude)  
      result    = math.floor( n*shift +0.5) / shift
      return magnitude>precision and string.format("%.f", result) 
             or 
             magnitude<1 and string.format("%."..tonumber(precision-magnitude).."f", result) 
             or
             result
   end
end

-- formatting to human readable string: best numbers, no quotes, only string keys
-- numeric keys are ordered before string keys

function pretty(t, ...)
   local prettyT = function (t)
      local out=""
      for k,v in pairs(t) do 
         if out ~="" then out = out.." " end
         if stringtest(k) then out=out..k.."=" end
         out=out..pretty(v)
      end
      return out
   end
   local pretty1 = function (t) return
      niltest(t)    and "nil"
      or
      stringtest(t) and t
      or
      numbertest(t) and best(t)
      or
      tabletest(t) and "("..prettyT(t)..")"
      or
      lambdatest(t) and tostring(t)
      or
      t and "not nil" -- PRAGMA
      or
      error ("Dont know how to pretty print")
   end
   return #arg > 0 and pretty1(t).."\t"..pretty(unpack(arg))
          or
          t and pretty1(t)
          or 
          "nil"
end

-- formatting to machine readable string: full numbers, quotes, string keys and curled braces
-- numeric keys are ordered before string keys

function write(t, ...)
   local writeT = function (t)
      local out=""
      for k,v in pairs(t) do 
         if out ~="" then out = out..", " end
         if stringtest(k) then out=out..k.."=" end
         out=out..write(v)
      end
      return out
   end
   local write1 = function (t) return
      niltest(t)    and "nil"
      or
      stringtest(t) and '\"'..t..'\"'
      or
      numbertest(t) and tonumber(t)
      or
      tabletest(t) and "{"..writeT(t).."}"
      or
      lambdatest(t) and tostring(t)
      or
      t and "not nil" -- PRAGMA
      or
      error ("Dont know how to pretty print")
   end
   return #arg > 0 and write1(t).."\t"..write(unpack(arg))
          or
          t and write1(t)
          or 
          "nil"
end


-- intended for human understanding, like pretty but with all keys printed
tabulate = function (t, ...)
   display1 = function (t) return
      niltest(t)    and "nil"
      or
      stringtest(t) and t
      or
      numbertest(t) and best(t)
      or
      lambdatest(t) and tostring(t)
      or
      tabletest(t)  and displayT(t) and ""
      or
      t and "not nil" -- PRAGMA
      or
      "nil"
   end
   displayT = function (t)
      io.write ("(")
      local continue=nil
      for k,v in pairs(t) do 
         if continue then io.write(" ") end
         continue=not nil
         io.write(k,"=")
         io.write(display1(v))
         io.stdout:flush()
      end
      io.write (")")
      return not nil
   end
   return #arg > 0 and io.write(display1(t), "\t") and display(unpack(arg))
          or
          t and io.write(display1(t), "\n")
          or 
          io.write("\n")
end


display = function (t, ...)
   display1 = function (t) return
      niltest(t)    and "nil"
      or
      stringtest(t) and t
      or
      numbertest(t) and best(t)
      or
      lambdatest(t) and tostring(t)
      or
      tabletest(t)  and displayH(t) and ""
      or
      t and "not nil" -- PRAGMA
      or
      "nil"
   end
   displayH = function (t)
      io.write ("(")
      local continue=nil
      for k,v in pairs(t) do
         if continue then io.write(" ") end
         continue=not nil
         io.write(display1(v))
         io.stdout:flush()
      end
      io.write (")")
      return not nil
   end
   return #arg > 0 and io.write(display1(t), "\t") and display(unpack(arg))
          or
          t and io.write(display1(t), "\n")
          or 
          io.write("\n")
end

--[[
--pretty=write
print(pretty(nil))
print(pretty(not nil))
print(pretty(2))
print(pretty(2,3,"end"))
print(pretty(2,nil,3))
print(pretty("test"))
print(pretty({1,2,"dummy",3},"next"))
print(pretty({1,{33,22},"dummy",3}))
print(pretty({1,{33,22},"dummy",3,e="4",f=22}))
print(pretty({1,{33,nil,22},"dummy",3,e="4",f=22,77}))
print(pretty({1,{33,nil,22,{"this","as","well"}},"dummy",3,e="4",f=22,77, "that"}))
--]]

