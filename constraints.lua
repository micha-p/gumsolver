--started using tables

function cons(a, b)
  r = {}
  r.car = a
  r.cdr = b
  return r
end

function car(x) return x.car end
function cdr(x) return x.cdr end

function member (a, list)
  if list == nil then return nil 
  elseif a == car (list) then return not nil 
  else return member (a ,cdr (list))
  end
end

function for_each_except (exception, procedure, list)
  local function loop (items)
    if nil == items then return "done"
    elseif car (items) == exception then loop (cdr (items))
    else procedure (car (items))
         loop (cdr (items))
    end
  end
  loop (list)
end

  
-------------------------------------------------------------------------
-------------------------------------------------------------------------


function adder (a1, a2, sum)  
  local me={}
  local function process_new_value ()
    if has_value(a1) and has_value(a2) then 
           set_value (sum, get_value(a1) + get_value(a2), me) 
    elseif has_value(a1) and has_value(sum) then 
           set_value (a2, get_value(sum) - get_value(a1), me) 
    elseif has_value(a2) and has_value(sum) then 
           set_value (a1, get_value(sum) - get_value(a2), me) 
    end
  end
  local function process_forget_value ()
    forget_value(a1,me)
    forget_value(a2,me)
    forget_value(sum,me)
    process_new_value()
  end
  me.call = function (request)
             if request == "I have a value" then process_new_value()
             elseif request == "I lost my value" then process_forget_value()
             else print ("Unknown request - ADDER", request)
             end
            end
  connect (a1, me)
  connect (a2, me)
  connect (sum, me)
end

function multiplier (m1, m2, product)  
  local me={}
  local function process_new_value ()
    if has_value(m1) and has_value(m2) then 
           set_value (product, get_value(m1) * get_value(m2), me) 
    elseif has_value(m1) and has_value(product) then 
           set_value (m2, get_value(product) / get_value(m1), me) 
    elseif has_value(m2) and has_value(product) then 
           set_value (m1, get_value(product) / get_value(m2), me) 
    end
  end
  local function process_forget_value ()
    forget_value(m1,me)
    forget_value(m2,me)
    forget_value(product,me)
    process_new_value()
  end
  me.call = function (request)
             if request == "I have a value" then process_new_value()
             elseif request == "I lost my value" then process_forget_value()
             else print ("Unknown request - MULTIPLIER", request)
             end
            end
  connect (m1, me)
  connect (m2, me)
  connect (product, me)
end



function inform_about_value (constraint)  return constraint.call ("I have a value") end
function inform_about_no_value (constraint) return constraint.call ("I lost my value") end

function constant (value, connector) 
  local me = {}
  me.call = function (request)
              print ("Unknown request - CONSTANT" , request)
            end
  connect (connector, me)
  set_value (connector, value, me)
  return me
end

function probe (name, connector)
  local me={}
  local print_probe = function (value)
    print ("Probe: ", name, " = ", value)
  end
  local process_new_value = function ()
    print_probe (get_value (connector))
  end
  local process_forget_value = function ()
    print_probe ("?")
  end
  me.call = function (request)
              if request == "I have a value" then process_new_value()
              elseif request == "I lost my value" then process_forget_value()
              else print ("Unknown request - PROBE", request)
              end
            end
  connect (connector, me)
end


function make_connector()
  local me={}
  me.value = nil
  me.informant = nil
  me.constraints = nil

  local set_my_value = function (newval, setter)
    if (not has_value(me)) then
      me.value = newval
      me.informant = setter
      for_each_except (setter, inform_about_value, me.constraints)
    elseif not (get_value(me) == newval) then print ("Contradiction" , value , newval)
    end
  end

  local forget_my_value = function (retractor)
    if retractor == me.informant then
       me.informant = nil
       for_each_except (retractor, inform_about_no_value, me.constraints)
    end
  end
  
  me.connect = function (new_constraint)
    if not member (new_constraint , me.constraints) then me.constraints = cons (new_constraint , me.constraints) end
    if has_value(me) then inform_about_value (new_constraint) end
  end

  me.call = function (request)
              if request == "has value?" then if me.informant then return not nil else return nil end
              elseif request == "value" then return me.value 
              elseif request == "set value" then return set_my_value
              elseif request == "forget" then return forget_my_value
              elseif request == "connect" then return me.connect
              else print ("Unknown operation - CONNECTOR", request)
              end
            end
  return me
end


function has_value(connector) 
  return connector.call ("has value?")
end 

function get_value(connector)
  return connector.call ("value")
end

function set_value (connector, new_value, informant)
  r= connector.call("set value")
  return r(new_value, informant)
end

function forget_value (connector, retractor)
  r=connector.call ("forget")
  return r(retractor)
end

function connect (connector, new_constraint)
  r=connector.call ("connect")
  return r(new_constraint)
end

---------------------------------------------------------------


function celsius_fahrenheit_converter (c, f)
  u = make_connector()
  v = make_connector()
  w = make_connector()
  x = make_connector()
  y = make_connector()
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

set_value ( C, 25, "user")
set_value ( F, 212, "user")
forget_value  (C, "user")
set_value  (F, 212, "user")


