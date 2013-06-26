function cons(a, b) return {car=a, cdr = b} end
function car (x)    return x.car end
function cdr (x)    return x.cdr end

function member (a, list)
  if list == nil then return nil 
  elseif a == car (list) then return not nil 
  else return member (a ,cdr (list))
  end
end

function for_each_except (exception, procedure, list)
  local function loop (items)
    if nil == items then return
    elseif car (items) == exception then loop (cdr (items))
    else procedure (car (items))
         loop (cdr (items))
    end
  end
  loop (list)
end

-------------------------------------------------------------------------
-------------------------------------------------------------------------

value = 1
get = 2
set = 3
forget = 4
connect = 5
new = 10
lost = 11

function actor (process_new_value, process_forget_value)  
  local me
  me = function (request)
             if request == new then process_new_value()
             elseif request == lost then process_forget_value()
             end
           end
  return me
end

function constraint (a, b, c, forward , back)  
  local me
  local function process_new_value ()
    if     a(value) and b(value) then c(set, me, forward (a(get), b(get))) 
    elseif a(value) and c(value) then b(set, me, back    (c(get), a(get))) 
    elseif b(value) and c(value) then a(set, me, back    (c(get), b(get))) 
    end
  end
  local function process_forget_value ()
    a(forget, me)
    b(forget, me)
    c(forget, me)
    process_new_value()
  end
  me = actor (process_new_value, process_forget_value) 
  a(connect, me)
  b(connect, me)
  c(connect, me)
end

function adder     (a1, a2, sum)  constraint(a1,a2,sum , function(a,b) return a+b end, function(a,b) return a-b end) end
function subtractor(a1, a2, diff) constraint(a1,a2,diff, function(a,b) return a-b end, function(a,b) return a+b end) end
function multiplier(m1, m2, prod) constraint(m1,m2,prod, function(a,b) return a*b end, function(a,b) return a/b end) end
function divider   (a1, a2, sum)  constraint(a1,a2,sum , function(a,b) return a/b end, function(a,b) return a*b end) end

--[[ syntactic sugar  

arrow is also used in OCaml, maple, f#, erlang, haskell, oft aber auch für typenübergabe
-> ist ein binärer operator in der Reihenfolge direkt über =

adder      = (a1, a2, sum)  -> constraint(a1,a2,sum , (a,b) -> return a+b, (a,b) -> return a-b)
subtractor = (a1, a2, diff) -> constraint(a1,a2,diff, (a,b) -> return a-b, (a,b) -> return a+b)
multiplier = (m1, m2, prod) -> constraint(m1,m2,prod, (a,b) -> return a*b, (a,b) -> return a/b)
divider    = (a1, a2, sum)  -> constraint(a1,a2,sum , (a,b) -> return a/b, (a,b) -> return a*b)

]]



function constant (value, connector) 
  local me
  me = actor () 
  connector (connect, me)
  connector (set, me, value)
end

function probe (name, connector)
  local me
  local print_probe = function (value)
    print ("Probe: ", name, " = ", value)
  end
  me = actor (function () print_probe (connector (get)) end, function () print_probe ("?") end)
  connector (connect, me)
end


function make_connector()
  local me 
  local myval = nil
  local informant = nil
  local constraints = nil

  local set_my_value = function (setter, newval)
    if (not informant) then   -- informant = me(value)
      myval = newval
      informant = setter
      for_each_except (setter, function (constraint) constraint (new) end, constraints)
    elseif myval ~= newval then print ("Contradiction" , myval , newval) -- myval = me(get)
    end
  end

  local forget_my_value = function (retractor)
    if retractor == informant then
       informant = nil
       for_each_except (retractor, function (constraint) constraint (lost) end, constraints)
    end
  end
  
  local connect_actor = function (new_constraint)
    if not member (new_constraint , constraints) then constraints = cons (new_constraint , constraints) end
    if informant then inform_about_value (new_constraint) end
  end

  me = function (request, actor, newval)
              if request == value then return informant
              elseif request == get then return myval 
              elseif request == set then set_my_value (actor, newval)
              elseif request == forget then forget_my_value (actor)
              elseif request == connect then connect_actor (actor)
              end
            end
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

C (set, "user", 25)
F (set, "user", 212)
C (forget, "user")
F (set, "user", 212)
F (forget, "user")
R (set, "user", 80)
R (forget, "user", 80)
K (set, "user", 0)


