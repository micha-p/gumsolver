function table.find (t, value)
  for k,v in pairs(t) do
    if v==value then return k end
  end
  return nil
end


-------------------------------------------------------------------------
-------------------------------------------------------------------------
--
-- constraints, probes and pipes are all actors, which understand the signals "new" and "lost"
-- while creation they attach themselve to the given connectors

PRINT = function (a) return a end
EQUAL = function (a,b) return a == b end

function make_actor (process_new_value, process_forget_value)  
  local me = {}
  me.new  = function () process_new_value() end
  me.lost = function () process_forget_value() end
  return me
end

function pipe (a, b)  
  local me = {}
  local function process_new_value ()
    if     a.value() then b.set (me, a.get()) 
    elseif b.value() then a.set (me, b.get()) 
    end
  end
  local function process_forget_value ()
    a.forget(me)
    b.forget(me)
    process_new_value()
  end
  me = make_actor (process_new_value, process_forget_value) 
  a.connect(me)
  b.connect(me)
  return me
end


function constraint (a, b, c, forward , back)  
  local me = {}
  local function process_new_value ()
    if     a.value() and b.value()then c.set(me, forward (a.get(), b.get())) 
    elseif a.value() and c.value()then b.set(me, back    (c.get(), a.get())) 
    elseif b.value() and c.value()then a.set(me, back    (c.get(), b.get())) 
    end
  end
  local function process_forget_value ()
    a.forget(me)
    b.forget(me)
    c.forget(me)
    process_new_value()
  end
  me = make_actor (process_new_value, process_forget_value) 
  a.connect(me)
  b.connect(me)
  c.connect(me)
  return me
end


function probe (name, connector)
  local me = {}
  local printprobe = function (value)
    print (name, " -> ", value)
  end
  me = make_actor (function () printprobe (PRINT (connector.get())) end, function () printprobe ("?") end)
  connector.connect(me)
  return me
end


function make_connector(hint)
  local me = {}
  local value = nil
  local informant = nil
  local actors = {}
  local info = hint

  local set_my_value = function (setter, newval)
    if (not informant) then 
      value = newval
      informant = setter
      table.foreach (actors, function (k, v) if v ~= setter then v.new() end end)
    elseif not EQUAL (value, newval) then print ("Contradiction" , PRINT (value) , PRINT (newval))
    end
  end

  local forget_my_value = function (retractor)
    if retractor == informant then
       informant = nil
       table.foreach (actors, function (k, v) if v ~= retractor then v.lost() end end)
    end
  end
  
  local connect_actor = function (new_constraint)
    if not table.find (actors, new_constraint) then table.insert (actors, 1, new_constraint) end
    if informant then new_constraint.new() end
  end

  me.info    	= function () return info end
  me.listeners  = function () return actors end
  me.value 	= function () return informant end
  me.get    	= function () return value end
  me.set    	= function (actor, new) set_my_value    (actor, new) end
  me.forget 	= function (actor)      forget_my_value (actor)      end
  me.connect	= function (actor)      connect_actor   (actor)      end

  return me
end


---------------------------------------------------------------

genadd = nil
gensub = nil
genmul = nil
gendiv = nil
genset = nil

function init_algebra (add, sub, mul, div)
  genadd = function (a1, a2, sum)  constraint(a1,a2,sum , add, sub) end
  gensub = function (a1, a2, diff) constraint(a1,a2,diff, sub, add) end
  genmul = function (m1, m2, prod) constraint(m1,m2,prod, mul, div) end
  gendiv = function (a1, a2, sum)  constraint(a1,a2,sum , div, mul) end
  genset = function (value, connector) 
    local me = {}
    me = make_actor () 
    connector.connect(me)
    connector.set(me, value)
    return me
  end
end

function cadd (x,y) local z = make_connector(); genadd (x,y,z) return z end
function csub (x,y) local z = make_connector(); gensub (x,y,z) return z end
function cmul (x,y) local z = make_connector(); genmul (x,y,z) return z end
function cdiv (x,y) local z = make_connector(); gendiv (x,y,z) return z end
function cv   (x  ) local z = make_connector(); genset (x,  z) return z end



--[[
init_algebra (function(a,b) return a+b end, 
              function(a,b) return a-b end, 
              function(a,b) return a*b end, 
              function(a,b) return a/b end)

a = make_connector()
b = make_connector()
c=cadd(a,b)

probe("A",a)
probe("B",b)
probe("C",c)

a.set(001, 2)
b.set(001, 3)
b.forget(001)
c.set(001, 7)

C = make_connector()
F = cadd (cmul (cdiv(cv(9),cv(5)) , C) , cv(32) )
K = csub (C, cv (-273.15))
R = cmul (cv(80), cdiv (C, cv(100)))

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
]]


