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


foreach = function (t, func)
  for key,value in pairs(t) do func (key, value) end
end

map = function (t, func)
  local new = {}
  for key,value in pairs(t) do new[key] = func(value) end
  return new
end

-- six of the seven important types need a predicate
niltest      = function (x) return x == nil end
numbertest   = function (x) return type(x) == "number" end
stringtest   = function (x) return type(x) == "string" end
tabletest    = function (x) return type(x) == "table" end
lambdatest   = function (x) return type(x) == "function" end
threadtest   = function (x) return type(x) == "thread" end
userdatatest = function (x) return type(x) == "userdata" end 

function best (n, precision) 
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

TABLE_OF_TABLES={}
function short (t)
   if t == {} then
      return "{}"
   end
   local key = table.find (TABLE_OF_TABLES, t)
   assert (tabletest(t), "Error while trying to display table: No table given")

   if key then
      return "t"..key
   else
      table.insert (TABLE_OF_TABLES, t)
      return "t"..#TABLE_OF_TABLES
   end
end

display = function (t, ...) -- recursive consumer
   displayT = function (t)
      for k,v in pairs(t) do 
         io.write(k,"=")
         display1(v)
         dummy = k==#t or io.write(" ")
      end
   end
   display1 = function (t) return
      niltest(t)    and io.write("nil")
      or
      stringtest(t) and io.write(string.format('%q',t))
      or
      numbertest(t) and io.write(best(t))
      or
      lambdatest(t) and io.write(tostring(t))
      or
      tabletest(t)  and {io.write ("{");displayT(t);io.write ("}")}
      or
      not t and io.write("nil")
      or
      t and io.write("not nil") -- PRAGMA
   end
   display1 (t) 
   return arg.n > 0 and {io.write(" "); display(unpack(arg))} 
          or
          io.write("\n")
end
