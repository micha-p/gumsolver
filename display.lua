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


foreach = function (func, t)
  for key,value in pairs(t) do func (key, value) end
end

map = function (func, t)
  local new = {}
  for key,value in pairs(t) do new[key] = func(value) end
  return new
end

-- six of the seven important types need a predicate
numbertest   = function (x) return type(x) == "number" end
stringtest   = function (x) return type(x) == "string" end
tabletest    = function (x) return type(x) == "table" end
lambdatest   = function (x) return type(x) == "function" end
threadtest   = function (x) return type(x) == "thread" end
userdatatest = function (x) return type(x) == "userdata" end 

display = function (t, ...) -- recursive consumer
   local display1
   display1 = function (t) 
      if t == nil then io.write("nil")
      elseif stringtest(t)  then io.write(string.format('%q',t))
      elseif lambdatest(t)  then io.write(tostring(t))
      elseif tabletest(t)   then
         io.write ("{")
         foreach (function (k, v) io.write (k, "=") display1(v) io.write(", ") end, t)
         io.write ("\b\b}")  -- beautiful hack
      elseif t == true  then io.write("not nil") -- PRAGMA
      elseif t == false then io.write("nil")
      else io.write(t)       
      end
   end
   display1 (t) 
   if arg.n > 0 then 
      io.write(" ") display(unpack(arg)) 
   else
      io.write("\n")
   end
end


