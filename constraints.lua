function table.find (t, value)
  for k,v in pairs(t) do
    if v==value then return k end
  end
  return nil
end


-------------------------------------------------------------------------
-------------------------------------------------------------------------

function make_actor (process_new_value, process_forget_value)  
  local me = {}
  me.new  = function () process_new_value() end
  me.lost = function () process_forget_value() end
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

function adder     (a1, a2, sum)  constraint(a1,a2,sum , function(a,b) return a+b end, function(a,b) return a-b end) end
function subtractor(a1, a2, diff) constraint(a1,a2,diff, function(a,b) return a-b end, function(a,b) return a+b end) end
function multiplier(m1, m2, prod) constraint(m1,m2,prod, function(a,b) return a*b end, function(a,b) return a/b end) end
function divider   (a1, a2, sum)  constraint(a1,a2,sum , function(a,b) return a/b end, function(a,b) return a*b end) end


function constant (value, connector) 
  local me = {}
  me = make_actor () 
  connector.connect(me)
  connector.set(me, value)
  return me
end

function probe (name, connector)
  local me = {}
  local printprobe = function (value)
    print (name, " = ", value)
  end
  me = make_actor (function () printprobe (connector.get()) end, function () printprobe ("?") end)
  connector.connect(me)
  return me
end


function make_connector()
  local me = {}
  local value = nil
  local informant = nil
  local constraints = {}

  local set_my_value = function (setter, newval)
    if (not informant) then 
      value = newval
      informant = setter
      table.foreach (constraints, function (k, v) if v ~= setter then v.new() end end)
    elseif value ~= newval then print ("Contradiction" , value , newval)
    end
  end

  local forget_my_value = function (retractor)
    if retractor == informant then
       informant = nil
       table.foreach (constraints, function (k, v) if v ~= retractor then v.lost() end end)
    end
  end
  
  local connect_actor = function (new_constraint)
    if not table.find (constraints, new_constraint) then table.insert (constraints, new_constraint) end
    if informant then new_constraint.new() end
  end

  me.value  = function () return informant end
  me.get    = function () return value end
  me.set    = function (actor, new) set_my_value    (actor, new) end
  me.forget = function (actor)      forget_my_value (actor)      end
  me.connect= function (actor)      connect_actor   (actor)      end

  return me
end


---------------------------------------------------------------

function celsius_fahrenheit_converter (c, f)
  local u = make_connector()
  local v = make_connector()
  local w = make_connector()
  local x = make_connector()
  local y = make_connector()
  multiplier (c, w, u)
  multiplier (v, x, u)
  adder (v, y, f)
  constant (9, w)
  constant (5, x)
  constant (32, y)
end

function celsius_reaumur_converter (c, r)
  local u = make_connector()
  local f80 = make_connector()
  local f100 = make_connector()
  divider (c, f100, u)
  divider (r, f80,  u)
  constant (80, f80)
  constant (100, f100)
end

function celsius_kelvin_converter (c, k)
  local abs = make_connector()
  subtractor (k, abs, c)
  constant (273.15, abs)
end

R = make_connector()
C = make_connector()
F = make_connector()
K = make_connector()

celsius_fahrenheit_converter(C, F)
celsius_reaumur_converter(C, R)
celsius_kelvin_converter(C, K)

probe ("Celsius    ", C)
probe ("Fahrenheit ", F)
probe ("Reaumur    ", R)
probe ("Kelvin     ", K)

C.set("user", 25)
F.set("user", 212)
C.forget("user")
F.set("user", 212)
F.forget("user")
R.set("user", 80)
R.forget("user")
K.set("user",0)

