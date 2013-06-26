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


function adder (a1, a2, sum)  
  local me
  local function process_new_value ()
    if     a1(value) and a2 (value) then sum(set, me, a1 (get) + a2(get)) 
    elseif a1(value) and sum(value) then a2 (set, me, sum(get) - a1(get)) 
    elseif a2(value) and sum(value) then a1 (set, me, sum(get) - a2(get)) 
    end
  end
  local function process_forget_value ()
    a1 (forget, me)
    a2 (forget, me)
    sum (forget, me)
    process_new_value()
  end
  me = function (request)
             if request == new then process_new_value()
             elseif request == lost then process_forget_value()
             end
           end
  a1  (connect, me)
  a2  (connect, me)
  sum (connect, me)
end

function multiplier (m1, m2, product)  
  local me
  local function process_new_value ()
    if     m1(value) and m2     (value) then product(set, me, m1     (get) * m2(get)) 
    elseif m1(value) and product(value) then m2     (set, me, product(get) / m1(get)) 
    elseif m2(value) and product(value) then m1     (set, me, product(get) / m2(get)) 
    end
  end
  local function process_forget_value ()
    m1      (forget, me)
    m2      (forget, me)
    product (forget, me)
    process_new_value()
  end
  me = function (request)
             if request == new then process_new_value()
             elseif request == lost then process_forget_value()
             end
            end
  m1      (connect, me)
  m2      (connect, me)
  product (connect, me)
end


function constant (value, connector) 
  local me
  me = function (request) end
  connector (connect, me)
  connector (set, me, value)
end

function probe (name, connector)
  local me
  local print_probe = function (value)
    print ("Probe: ", name, " = ", value)
  end
  me = function (request)
              if request == new then print_probe (connector (get))
              elseif request == lost then print_probe ("?")
              end
            end
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

C = make_connector()
F = make_connector()

celsius_fahrenheit_converter(C, F)

probe ("Celsius temp", C)
probe ("Fahrenheit temp", F)

C (set, "user", 25)
F (set, "user", 212)
C (forget, "user")
F (set, "user", 212)


