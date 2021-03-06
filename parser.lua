NAMEPATTERN   	= "[%aδ][%w%.%_δ]*[%w]*[%']*"
NUMBERPATTERN 	= "-?[%d._]+"
VALUEPATTERN 	= NUMBERPATTERN.."%s*%+%-%s*"..NUMBERPATTERN.."%%?"
VALUEPATTERNISO	= NUMBERPATTERN.."%s*%±%s*"..NUMBERPATTERN.."%%?"
ARGPATTERN    	= "[^)]+"
UNITPATTERN   	= "%[.+%]"
EXPRPATTERN	= "[%a%*%/%+%-%(%)%^]"

function extract_value (s)
return s:match("^%s*("..VALUEPATTERN..")%s*")
       or
       s:match("^%s*("..VALUEPATTERNISO..")%s*")
end 

function extract_left (s)
return s:match("^%s*(.*[^%s])%s*=")
end 

function extract_right (s)
return s:match("=%s*(.*[^%s])%s*$")
end 

function extract_name (s)
return s:match("%s*("..NAMEPATTERN..")%s*=?")
end 

function extract_unit (s)
return s:match("%s*"..NAMEPATTERN.."%s*("..UNITPATTERN..")%s*=?")
end 

function extract_expr (s)
return s:match("%s*(.*[^%s])%s*$")
end 

function extract_number (s)
return s and assert(tonumber(s:gsub("_",""),10), "Error while converting to number: " .. s)
end 


function parse (str) 
   
   local s, newpos, pos

   local function expression (str, pos, len, level)
      local e={}
      local i=1
      
      local function check_pattern (pattern)
         if pos > len then 
            return nil
         else
            m = string.match (str, "^"..pattern, pos)
            if m then pos = pos + #m end
            return m
         end
      end

      local func
      local function opening()   return check_pattern ("%(") end  
      local function closing()   return check_pattern ("%)") end  
      local function subexpression()
         if opening() then 
            s, newpos = expression (str, pos, len, level+1)
            pos = newpos
         end
         return s
      end
      local functio
      local function skipspace() return check_pattern ("%s*") end
      local function value()     return check_pattern (VALUEPATTERN) or check_pattern (VALUEPATTERNISO) end  
      local function operator()  return check_pattern ("[%+%-%*%/%^]") end  
      local function diff()      return check_pattern ("diff ?%(") end  
      local function exp()       return check_pattern ("exp ?%(") end  
      local function log()       return check_pattern ("log ?%(") or check_pattern ("ln ?%(") end 
      local function min()       return check_pattern ("min ?%(") end 
      local function max()       return check_pattern ("max ?%(") end 
      local function partial()   return check_pattern ("partial ?%(") end 
      local function argmin()    return check_pattern ("argmin ?%(") end 
      local function variable()  return check_pattern (NAMEPATTERN) end  
      local function number()    return extract_number( check_pattern (NUMBERPATTERN)) end 
      local function operand()   return func() or variable() or value() or number() or subexpression() or nil end
      
   
      local function dualfunc (string)
         skipspace()
         local a = operand()
         skipspace()
         check_pattern(",")
         skipspace()
         local b = operand()
         skipspace()
         if not closing() then error("closing bracket for argument list: "..symbol.." "..str) end
         return {a, string, b}
      end

      func = function ()
         if exp() then
            s, newpos = expression (str, pos, len, level+1)
            pos = newpos
            return {1 ,"exp", s}
         elseif log() then
            s, newpos = expression (str, pos, len, level+1)
            pos = newpos
            return {1, "log", s}
         elseif diff() then
            s, newpos = expression (str, pos, len, level+1)
            pos = newpos
            return {1, "diff", s}
         elseif argmin() then
            return dualfunc("argmin")
         elseif min() then
            return dualfunc("min")
         elseif max() then
            return dualfunc("max")
         elseif partial() then
            return dualfunc("partial")
         end
      end
   
      skipspace()
      e[i]=operand()
      skipspace()
      for a in plusminus or operator do
         i=i+1
         e[i]=a
         skipspace()
         i=i+1
         e[i]=operand()
         skipspace()
      end
      if level>1 and not closing() then error("closing bracket missing: "..str) end
      if level==1 and closing() then error("too many closing brackets: "..str) end
      return #e==1 and e[1] or e , pos
   end
   
   local s = string.gsub(string.gsub(str,"³","^3"),"²","^2")
   return expression (s ,1, #s, 1)
end

function uncurry (expr)
   if tabletest(expr) and #expr > 3 then
      local r={}
      r[1]=expr[1]
      r[2]=expr[2]
      r[3]=expr[3]
      table.remove(expr,3)
      table.remove(expr,2)
      expr[1]=r
      return uncurry(expr)
   else
      return expr
   end
end



function find_first_highest_rank (expr)
   rank={["+"]=1, ["-"]=1, ["*"]=2 ,["/"]=2 ,["^"]=3}
   local pos=2
   local highest=0
   for i,v in ipairs (expr) do
      if math.mod(i, 2) == 0 and rank[v] > highest then highest=rank[v]; pos=i end
   end
return pos
end


function order (expr)
   if tabletest(expr) and #expr > 3 then
      local r={}
      local h=find_first_highest_rank (expr)
      r[1]=expr[h-1]
      r[2]=expr[h]        	--< highest
      r[3]=expr[h+1]
      expr[h]=order(r)		--< ordered subexpression
      table.remove(expr,h+1)
      table.remove(expr,h-1)
      return order(expr)
   elseif tabletest(expr) and #expr==3 then  
      local r={} 
      r[1]=order(expr[1])
      r[2]=expr[2]        	
      r[3]=order(expr[3])
      return r
   else
      return expr
   end
end

--[[
dofile("include/display.lua")

--display (uncurry (parse ("a+b+c+d")))
--display (uncurry (parse ("a+b+c*d+100")))
--display (find_first_highest_rank (parse ("a+b+c+d+d")))
display (order (parse ("a+b+c*d")))
display (order (parse ("a+b+c*d")))
display (order (parse ("a+b*c/d")))
display (order (parse ("a+b+c^d")))
display (order (parse ("a+b²+c^d")))
display (order (parse ("a+b²*c-d")))
display (order (parse ("a+b²*(1 + 4*3) -d")))
display (order (parse ("(a+2*3)+(A^2)")))
--display (order (parse "10"))
--display (parse "area")
--display (parse "1_000_000")
--]]
--[[
display (parse "Ca * 9 / 5 + 32")
display (order (parse "Cb * 9 / 5  + 32"))
display (parse "Cc * (9 / 5 ) + 32")
display (order (parse "Cc * (9 / 5 ) + 32"))
display (parse "( (9 / 5 ) * Cd ) + 32")
display (order (parse "( (9 / 5 ) * Cd ) + 32"))

print()
display (parse "exp(1)")
display (parse "a + exp(1) + 3")
display (parse "exp(a + b)")
display (parse "exp( exp(a) + exp(b) )")
display (parse "exp( exp(a) + exp(b))")
display (parse "exp(exp(a)+exp(b))")
display (parse "1 + exp(a+b) + ln(c)")

print()
display (parse "min(a,b)")
display (parse "min(a,min(b,c))")

--]]
