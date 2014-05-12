

--[[
This library implements minimization, other problems might be solved in terms of this.
There is no suitable math notation for this: trial: a argmin target

A minimizer is a special constraint, which takes two connectors as arguments and acts as a oneway pipe:
Besides this contraint, there must be another network, which propagates a to the target. 

When a is set, this value is not just propagated, but taken as starting value for an iteration.
Finally, when a globally defined epsilon is reached, a and target will hold the final values. 
When a is unset, the target will loose its value too. 

A user-supplied value to the target is not propagated, as a will be calculated by the other constraints. 
--]]



LIMIT   = 500

function argmin_iter (agent, x, y, startx, starty)
   
   local n = 0
   local xcache = startx
   local ycache = starty
   local epsilon = AMP (starty,0.0001)
   local step 	 = AMP (startx,0.1)
   local dleft, dright = epsilon, epsilon   
   
   if ITER or DEBUG then
      print2(warn("ARGMIN:", PRINT16(x["name"]),PRINT16(""),PRINT16(y["name"]))) 
   end
   
   if ITER then print2(warn(n, PRINT16(xcache),PRINT16(step),PRINT16(ycache),"\t\t",PRINT16(dleft),PRINT16(dright))) end 
   
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
         print2(warn(n, PRINT16(xcache),PRINT16(step),PRINT16(ycache),"\t\t",PRINT16(dleft),PRINT16(dright))) 
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

   if ITER or DEBUG then
      print2(warn(n, PRINT16(xcache),PRINT16(step),PRINT16(ycache),"\t\t",PRINT16(dleft),PRINT16(dright))) 
   end

   MUTE = nil
   return xcache
end

ITERLOOP=nil

function argmin_constraint (a, target)  -- two connectors as pipe-constraint
  local me = {}
  local actors = {a, target}
  local agent = "argmin"

  local function process_new_value ()
    if (not ITERLOOP) and target.value() and (a.value()=="user" or not a.value()) then
       -- if DEBUG then print2(warn ("OPTIMIZER: Start", a.value(), target.value(), PRINT16(a.get()), PRINT16(target.get()))) end
       ITERLOOP = not nil
       -- a.disconnect(me)
       local mutestate = MUTE
       local tracestate=TRACE
       local origin = a.value()
       local startx  = a.get()
       local starty  = target.get()
       MUTE = not nil
       TRACE=nil
       a.forget (origin)
       assert(not a.value(), "OPTIMIZER: can't release source")
       assert(not target.value(), "OPTIMIZER: can't release target")
       local final = argmin_iter (agent, a, target, startx, starty)
       TRACE=tracestate
       MUTE = mutestate
       a.set (origin, final)
       assert(final==a.get(), "OPTIMIZER: can't set final")
       -- a.connect(me)   		-- this triggers another iteration
       ITERLOOP = nil
    end
  end
  local function process_forget_value ()
    if not a.value() then target.forget(me) end
    if not target.value() then a.forget(me) end
  end
  me = make_actor (process_new_value, process_forget_value) 
  me["setters"]  = function () return actors end
  me["class"]  = "argmin"
  me["iter"]  = nil
  a.connect(me)
  target.connect(me)
  return me
end


--[[

require 'constraints'
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
MUTE = nil
TRACE = nil
BEST = not nil

argmin_constraint (X, M)

X.set("user", 10)			-- works 1.871875
--print("_________________ constraint second")
--X.forget("user")
--X.set("user", 1)			-- works 1.871875

--]]
