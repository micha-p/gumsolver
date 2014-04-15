-------------------------------------------------------------------------
-------------------------------------------------------------------------
--
-- constraints, probes and pipes are all actors, which only understand the signals "new" and "lost"
-- while creation they attach themselve to the given connectors


package.path = package.path .. ";include/?.lua"
require 'display'
require 'tables'



ADD = function(a,b) return a+b  end 
SUB = function(a,b) return a-b  end 
MUL = function(a,b) return a*b  end 
DIV = function(a,b) return a/b  end
SQU = function(a)   return a^2  end
SQR = function(a)   return a^.5 end
RET = function(a)   return a    end
EXP = function(a)   return math.exp(a) end
LOG = function(a)   return math.log(a) end

PRINT16 = function (a) return a end
PRINT   = function (a) return a end
EQUAL   = function (a,b) return a == b end

function make_actor (process_new_value, process_forget_value)  
  local me = {}
  me["class"]  = "actor"
  me.new   = function () process_new_value() end
  me.lost  = function () process_forget_value() end
  return me
end

function pipe (a, r, op1, op2)  
  local me = {}
  local actors = {a,b}
  local function process_new_value ()
    if     a.value() then r.set (me, op1 (a.get())) 
    elseif r.value() then a.set (me, op2 (r.get())) 
    end
  end
  local function process_forget_value ()
    a.forget(me)
    r.forget(me)
    process_new_value()
  end
  me = make_actor (process_new_value, process_forget_value) 
  me["setters"]  = function () return actors end
  me["class"]  = "pipe"
  a.connect(me)
  r.connect(me)
  return me
end

function constraint (a, b, r, op1, op2)  
   local me = {}
   local actors = {a,b,r}
   local function process_new_value ()
      if TRACE then printtrace (me, "processing new", a, b, r) end 
      if     a.value() and b.value() and not r.value() then r.set(me, op1 (a.get(), b.get())) 
      elseif r.value() and b.value() and not a.value() then a.set(me, op2 (r.get(), b.get())) 
      elseif r.value() and a.value() and not b.value() then b.set(me, op2 (r.get(), a.get())) 
      end
   end
   local function process_forget_value ()
      if TRACE then printtrace (me, "processing forget", a, b, r) end 
      r.forget(me)
      a.forget(me)
      b.forget(me)
      process_new_value()
   end
   me = make_actor (process_new_value, process_forget_value) 
   me["setters"]  = function () return actors end
   me["class"]  = "constraint"
   a.connect(me)
   b.connect(me)
   r.connect(me)
   return me
end

function constant (connector, value)
   local me = {}
   local actors = {connector}
   me = make_actor () 
   me["class"]  = "value"
   me["setters"]  = function () return actors end
   connector.connect(me)
   connector.set(me, value)
return me
end


function printprobe (name, value)
   print (PRINT16 (name), PRINT16 (value))
end


function probe (name, connector)
   local me = {}
   local actors = {connector}
   me = make_actor (function () printprobe (name, PRINT (connector.get())) end, 
                    function () printprobe (name, ".") end,
                    name)
   me["class"]   = "probe"
   me["name"]    = name
   me["setters"] = function () return actors end
   connector.connect(me)
   return me
end


function make_connector()
  local me = {}
  local value = nil
  local informant = nil
  local actors = {}

  local set_my_value = function (setter, newval)
    if TRACE then printtrace (me, "RECEIVED " .. newval.abs() .. " from ".. (tabletest(setter) and short(setter) or setter)) end
    if (not informant) then 
      value = newval
      informant = setter
      for k,v in pairs (actors) do if v ~= setter then 
         if TRACE and DEBUG then printtrace (me, "informs about new value ", v) end
         v.new () end end
    else
      if not EQUAL (value, newval) then print (PRINT16 ("CONTRADICTION!") , PRINT (value) , PRINT (newval), hint) end
    end
  end

  local forget_my_value = function (retractor)
    if TRACE then printtrace (me, "RECEIVED FORGET from ".. (tabletest(retractor) and short(retractor) or retractor)) end
    if retractor == informant then
       informant = nil
       for k,v in pairs (actors) do if v ~= retractor then 
         if TRACE and DEBUG then printtrace (me, "informs about loss ", v) end
       v.lost() end end
    end
  end
  
  local connect_actor = function (new_constraint)
    if not table.find (actors, new_constraint) then table.insert (actors, 1, new_constraint) end
    if informant then new_constraint.new() end
  end

  me["class"]  = "connector"
  me.listeners  = function () return actors end
  me.value 	= function () return informant end
  me.get    	= function () return value end
  me.set    	= function (actor, new) set_my_value    (actor, new) end
  me.forget 	= function (actor)      forget_my_value (actor)      end
  me.connect	= function (actor)      connect_actor   (actor)      end

  return me
end


---------------------------------------------------------------

function cadd(x,y) local z=make_connector(); constraint(x, y, z, ADD, SUB); return z end
function csub(x,y) local z=make_connector(); constraint(z, y, x, ADD, SUB); return z end
function cmul(x,y) local z=make_connector(); constraint(x, y, z, MUL, DIV); return z end
function cdiv(x,y) local z=make_connector(); constraint(z, y, x, MUL, DIV); return z end
function csqu(x  ) local z=make_connector(); pipe      (x,    z, SQU, SQR); return z end 
function csqr(x  ) local z=make_connector(); pipe      (x,    z, SQR, SQU); return z end 
function cexp(x  ) local z=make_connector(); pipe      (x,    z, EXP, LOG); return z end 
function clog(x  ) local z=make_connector(); pipe      (x,    z, LOG, EXP); return z end 
function cret(x  ) local z=make_connector(); pipe      (x,    z, RET, RET); return z end 
function cval(v  ) local z=make_connector(); constant  (z,v);               return z end 

function SUM   (x,y,s) return constraint(x, y, s, ADD, SUB); end
function DIFF  (x,y,d) return SUM (y,d,x) end
function PROD  (x,y,p) return constraint(x, y, p, MUL, DIV); end
function RATIO (x,y,r) return PROD (y,r,x) end
function CONST (x,v)   return constant (x, v) end
function SQUARE(x,y)   return pipe   (x,y, SQU, SQR) end
function SQROOT(x,y)   return SQUARE (y,x)  end
function FNEXP(x,y)    return pipe   (x,y, EXP, LOG) end
function FNLOG(x,y)    return pipe   (x,y, LOG, EXP) end

--[[
C = make_connector()
F = cadd (cmul (cdiv(cval(9),cval(5)) , C) , cval(32) )
K = csub (C, cval (-273.15))
R = cmul (cval(80), cdiv (C, cval(100)))

probe ("Celsius    ", C)
probe ("Fahrenheit ", F)
probe ("Kelvin     ", K)
probe ("Reaumur    ", R)

C.set("user", 25)
F.set("user", 212)
C.forget("user")
F.set("user", 212)
F.forget("user")
K.set("user",0)
K.forget("user")
R.set("user", 80)
R.forget("user")
R.set("user", 0)
R.forget("user")
C.set("user", 100)
--]]

--[[
A = make_connector()
B = cexp (A)
C = clog (B)
probe ("A", A)
probe ("B", B)
probe ("C", C)


A.set ("user", 1)
A.forget ("user")
A.set ("user", 2)   -- e^2 = 7.38905609893
A.forget ("user")
A.set ("user", 10)   -- e^10 = 22026.4657948

--]]

