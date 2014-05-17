

--[[
This library implements minimization, other problems might be solved in terms of this.
There is no suitable math notation for this: trial: a argmin target

A minimizer is a special constraint, which takes two connectors as arguments and acts as a oneway pipe:
Besides this contraint, there must be another network, which propagates a to the target. 

When a is set, this value is not just propagated, but taken as starting value for an iteration.
Finally, when a globally defined epsilon is reached, a and target will hold the final values. 
When a is unset, the target will loose its value too. 

The optimizer is triggered by a start value. See below for details.
--]]



LIMIT   = 1000
ITERTABLE={}
INSIDE_ITERATION=nil

function do_itertable()
   for name,c in ipairs(ITERTABLE) do
      local r = nil
      local agent = c[1]
      if DEBUG then print2("GO:",agent,c[2],c[3],c[4]) end
      local func = c[5]
      local rcon = CONNECTORS[c[4]]

      INSIDE_ITERATION=not nil
      r=func(CONNECTORS[c[2]],CONNECTORS[c[3]],rcon)
      INSIDE_ITERATION=nil

      if r then 
         rcon.set(agent,r) 
         if DEBUG then print2("GO E:",agent,c[2],c[3],c[4],PRINT16(r)) end
      end
   end
end

function argmin_go (target, trigger, a)
  local f
  function do_process(agent, a, target, startx, starty)
           local mutestate = MUTE
           local tracestate=TRACE
           MUTE = not nil
           TRACE=nil
           a.forget(agent)
           assert(not a.value(), "OPTIMIZER: can't release source: "..a["name"])
           assert(not target.value(), "OPTIMIZER: target not released: "..target["name"])
           local final = argmin_iter (agent, target, a, startx, starty)
           TRACE=tracestate
           MUTE = mutestate
   return final
   end
   local agent = "argmin_ITER"
   if a.value() and (a.value() == "argmin") then
      a.forget("argmin")
   end
   if a.value() and (a.value() == "user") then
      a.forget("user")
   end
   if trigger.value() and (not target.value()) then
      if DEBUG then print2(" Try to start argmin just with TRIGGER value",trigger.name,PRINT16(trigger.get())) end
      local startx  = trigger.get()
      if DEBUG then print2("SET:", a["name"], PRINTX(a.get())) end
      a.set (agent, startx)
      if DEBUG then print2("SET:", a["name"], PRINTX(a.get())) end
      local starty  = target.get()
      if not starty then 
         print2("OPTIMIZER: "..a.name.. " won't fill target: "..target.name)
         a.forget(agent)
         return
      end
      f=do_process(agent, a, target, startx, starty)
   elseif trigger.value() and target.value() and target.value=="user" then
      if DEBUG then print2(" Try to start argmin with TRIGGER value and TARGET USER VALUE") end
      local startx  = trigger.get()
      local starty  = target.get()
      target.forget("user")
      f=do_process(agent, a, target, startx, starty)
   end
return f
end


function argmin_iter (agent, y, x, startx, starty)
   
   local n = 0
   local xcache = startx
   local ycache = starty
   local epsilon = AMP (starty,0.0001)
   local step 	 = AMP (startx,0.05)
   local dleft, dright = epsilon, epsilon   
   
   if ITER or DEBUG then
      print2("ARGMIN:", PRINT16(x["name"] or ""),"\t",PRINT16(y["name"] or "")) 
   end
   
   if ITER then print2(n, PRINT16(xcache),PRINT16(step),PRINT16(ycache),"\t\t",PRINT16(dleft),PRINT16(dright)) end 
   
   local function check_above_epsilon (agent, x, y)

      local xleft, xright, yleft, yright

      xcache = x.get()		-- defined outside
      ycache = y.get()		-- defined outside
      assert(xcache,"OPTIMIZER: source has no value!!!")
      assert(ycache,"OPTIMIZER: target has no value!!!")
      x.forget(agent)   

      xleft = SUB (xcache, step)
      x.set(agent, xleft)
      yleft = y.get()
      x.forget(agent)

      xright = ADD (xcache, step)
      x.set(agent, xright)
      yright = y.get()
      x.forget(agent)

      dleft = SUB(ycache,yleft)    -- defined outside
      dright = SUB(yright,ycache)  -- defined outside
      if ITER then
         print2(n, PRINT16(xcache),PRINT16(step),PRINT16(ycache),"\t\t",PRINT16(dleft),PRINT16(dright))
      end

      return POS(SUB(ABS(dleft),epsilon)) or POS(SUB(ABS(dright),epsilon))
   end

   while check_above_epsilon (agent, x, y) do
      assert (n < LIMIT, "OPTIMIZER: RECURSION REACHES LIMIT!!!")
      if POS(dleft) and POS(dright) then 
         xn = SUB(xcache,step)     
         x.set(agent, xn)			-- move left
      elseif NEG(dleft) and NEG(dright) then
         xn = ADD(xcache,step)
         x.set(agent, xn)			-- move right
      else 
         step = DIV(step,NEW(2))	        -- better resolution
         x.set(agent, xcache)
      end
      n = n + 1
   end   

   if DEBUG then
      print2(n, PRINT16(xcache),PRINT16(step),PRINT16(ycache),"\t\t",PRINT16(dleft),PRINT16(dright))
   end

   return xcache
end

function argmin_constraint (target, trigger, a)
  local me = {}
  local actors = {a, trigger, target}
  local function process_forget ()
     if (not trigger.value()) then 
           if DEBUG then print2(" Forget argmin") end
          a.forget("argmin")
     end
  end
  me = make_actor (function () end, process_forget) 
  me["setters"]  = function () return actors end
  me["class"]  = "argmin"
  me["free"]  = 1
  a.connect(me)
  trigger.connect(me)
  target.connect(me)
  table.insert(ITERTABLE,{"argmin",target.name,trigger.name,a.name,argmin_go})
  return me
end


--[[

require 'constraints'
package.path = package.path .. ";include/?.lua"
require 'stderr'

X = make_connector()
Y = cmul(X,X)

probe ("X", X)
probe ("Y", Y)

X.set("user", 2)
X.forget("user")
X.set("user", -2)
X.forget("user")
Y.set("user", 9)
Y.forget("user")

print("_________________")

Z=cadd(cmul(X,cval(0)),csub(cval(10),cexp(X)))
probe ("Z", Z)

M = csqr(csqu(csub(Y,Z)))
probe ("M", M)
 
X.set("user", 0); X.forget("user")
X.set("user", 1); X.forget("user")
X.set("user", 1.5); X.forget("user")
X.set("user", 1.8); X.forget("user")
X.set("user", 1.87); X.forget("user")  	-- argmin close to 1.87
X.set("user", 1.9); X.forget("user")
X.set("user", 2); X.forget("user")
X.set("user", 3); X.forget("user")

print("_________________ calling iteration directly")

X.set("user", 1)
--argmin_iter(X, M)			-- works 1.871875
X.forget("user")
X.set("user", 10)
--argmin_iter(X, M)			-- works 1.871875
X.forget("user")

print("_________________ constraint")

ITER = not nil
TRACE = nil
BEST = not nil

argmin_constraint (X, M)

X.set("user", 10)			-- works 1.871875
--print("_________________ constraint second")
--X.forget("user")
--X.set("user", 1)			-- works 1.871875

--]]
