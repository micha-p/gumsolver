--[[

As lua functions can hande different numbers of arguments easily, 
the returned connector-functions do not need to return another function to handle any request.
Instead they process the request directly.
]]

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
  local me
  local function process_new_value ()
    if a1("value") and a2("value") then 
           sum("set", me, a1("get") + a2("get")) 
    elseif a1("value") and sum("value") then 
           a2("set", me, sum("get") - a1("get")) 
    elseif a2("value") and sum("value") then 
           a1("set", me, sum("get") - a2("get")) 
    end
  end
  local function process_forget_value ()
    a1 ("forget", me)
    a2 ("forget", me)
    sum ("forget", me)
    process_new_value()
  end
  me = function (request)
             if request == "I have a value" then process_new_value()
             elseif request == "I lost my value" then process_forget_value()
             else print ("Unknown request - ADDER", request)
             end
            end
  a1 ("connect", me)
  a2 ("connect", me)
  sum ("connect", me)
end

function multiplier (m1, m2, product)  
  local me
  local function process_new_value ()
    if m1("value") and m2("value") then 
           product("set", me, m1("get") * m2("get")) 
    elseif m1("value") and product("value") then 
           m2("set", me, product("get") / m1("get")) 
    elseif m2("value") and product("value") then 
           m1("set", me, product("get") / m2("get")) 
    end
  end
  local function process_forget_value ()
    m1 ("forget", me)
    m2 ("forget", me)
    product ("forget", me)
    process_new_value()
  end
  me = function (request)
             if request == "I have a value" then process_new_value()
             elseif request == "I lost my value" then process_forget_value()
             else print ("Unknown request - MULTIPLIER", request)
             end
            end
  m1 ("connect", me)
  m2 ("connect", me)
  product ("connect", me)
end

function inform_about_value (constraint)  return constraint ("I have a value") end
function inform_about_no_value (constraint) return constraint ("I lost my value") end

function constant (value, connector) 
  local me
  me = function (request)
              print ("Unknown request - CONSTANT" , request)
            end
  connector ("connect", me)
  connector ("set", me, value)
end

function probe (name, connector)
  local me
  local print_probe = function (value)
    print ("Probe: ", name, " = ", value)
  end
  me = function (request)
              if request == "I have a value" then print_probe (connector ("get"))
              elseif request == "I lost my value" then print_probe ("?")
              else print ("Unknown request - PROBE", request)
              end
            end
  connector ("connect", me)
end


function make_connector()
  local me 
  local value = nil
  local informant = nil
  local constraints = nil

  local set_my_value = function (setter, newval)
    if (not informant) then   -- informant = me("value")
      value = newval
      informant = setter
      for_each_except (setter, inform_about_value, constraints)
    elseif value ~= newval then print ("Contradiction" , value , newval) -- value = me("get")
    end
  end

  local forget_my_value = function (retractor)
    if retractor == informant then
       informant = nil
       for_each_except (retractor, inform_about_no_value, constraints)
    end
  end
  
  local connect = function (new_constraint)
    if not member (new_constraint , constraints) then constraints = cons (new_constraint , constraints) end
    if me("value") then inform_about_value (new_constraint) end
  end

  me = function (request, actor, newval)
              if request == "value" then if informant then return not nil else return nil end
              elseif request == "get" then return value 
              elseif request == "set" then set_my_value (actor, newval)
              elseif request == "forget" then forget_my_value (actor)
              elseif request == "connect" then connect (actor)
              else print ("Unknown operation - CONNECTOR", request)
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

C ("set", "user", 25)
F ("set", "user", 212)
C ("forget", "user")
F ("set", "user", 212)


