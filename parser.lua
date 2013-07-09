

--[[

V 0.2 operator precedence
V 0.1 init

]]



function parse (str) 
   local function expression (str, pos, len, level)
      local e={}
      local i=1
   
      local function check_pattern (pattern)
         if pos > len then 
            return nil
         else
            m = string.match (str,pattern, pos)
            if m then pos = pos + #m end
            return m
         end
      end

      local function number() 
         local m = check_pattern ("^-?[%d._]+") 
         return m and assert(tonumber(m:gsub("_",""),10), "Error while converting to number: " .. m or "nil")
      end
      local function subexpression()
         local m = check_pattern ("^%(") 
         if m then 
            s, newpos = expression (str, pos, len, level+1)
            pos=newpos
         end
         return s
      end
   
      local function skip_space() check_pattern ("%s*") end
      local function variable() return check_pattern ("^[%a][%w%-]*") end  
      local function closing() return check_pattern ("^%)") end  
      local function operator() return check_pattern ("^[%+%-%*%/]") end  
      local function operand() return variable() or number() or subexpression() or nil end
   
   
      skip_space()
      e[i]=operand()
      skip_space()
      for a in operator do
         i=i+1
         e[i]=a
         skip_space()
         i=i+1
         e[i]=operand()
         skip_space()
      end
      if level>1 and not closing() then error("closing bracket missing before end") end
      if level==1 and closing() then error("too many closing brackets") end
      return #e==1 and e[1] or e , pos
   end
   return expression (str,1, #str,1)
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
   rank={["+"]= 1,["-"]= 1,["*"]= 2,["/"]= 2}
   local pos=2
   for i,v in ipairs (expr) do
      -- print (i,v,rank[v],rank[expr[pos]])
      if math.mod(i, 2) == 0 and rank[v] > rank[expr[pos]] then pos=i end
   end
return pos
end


function order (expr)
   if tabletest(expr) and #expr > 3 then
      local r={}
      local h=find_first_highest_rank (expr)
      r[1]=expr[h-1]
      r[2]=expr[h]
      r[3]=expr[h+1]
      table.remove(expr,h+1)
      table.remove(expr,h)
      expr[h-1]=r
      return order(expr)
   else
      return expr
   end
end

--[[
dofile("display.lua")
display (uncurry (parse ("a+b+c+d")))
display (uncurry (parse ("a+b+c*d+100")))
display (find_first_highest_rank (parse ("a+b+c+d+d")))
display (order (parse ("a+b+c*d")))
display (order (parse ("a+b+c*d")))
display (order (parse ("a+b*c/d")))
display (order (parse "10"))
display (parse "area")
display (parse "1_000_000")

display (parse "C * 9 / 5 + 32")
display (order (parse "C * 9 / 5  + 32"))
display (order (parse "C * (9 / 5 ) + 32"))
display (order (parse "( (9 / 5 ) * C ) + 32"))
]]
