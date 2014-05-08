

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
   local xcache = start
   local xscale = x["scale"] or 1
   local yscale = y["scale"] or 1
   local epsilon = NEW(0.001) --AMP(starty,0.01)
   local step 	 = NEW(0.01) -- AMP(startx,0.01/xscale)
   local dleft, dright = epsilon, epsilon   
   
   if ITER then
      local xscaled 	= AMP(startx,  1/xscale)
      local sscaled 	= AMP(step,    1/xscale)
      local yscaled 	= AMP(starty,  1/yscale)
      print(warn("", PRINT16(x["name"]),PRINT16(""),PRINT16(y["name"]))) 
      print(warn(n, PRINT16(xscaled),PRINT16(sscaled),PRINT16(yscaled),"\t\t",PRINT16(dleft),PRINT16(dright))) 
   end
   
   
   local function check_above_epsilon (agent, x, y)

      local xleft, xright, yleft, ycenter, yright

      xcache 	= x.get()     -- defined outside
      assert(xcache,"GUMSOLVER: source has no value!!!")
      ycenter 	= y.get()
      assert(ycenter,"GUMSOLVER: target has no value!!!")
      ycenter 	= AMP(ycenter, 1/yscale)

      x.forget(agent)   

      xleft = SUB (xcache, step)
      x.set(agent, xleft)
      yleft = AMP(y.get(), 1/yscale)
      x.forget(agent)

      xright = ADD (xcache, step)
      x.set(agent, xright)
      yright = AMP(y.get(), 1/yscale)
      x.forget(agent)

      dleft = SUB(yleft,ycenter)    -- defined outside
      dright = SUB(yright,ycenter)  -- defined outside
      if ITER then
         local xscaled 	= AMP(xcache,  1/xscale)
         local sscaled 	= AMP(step,    1/xscale)
         local yscaled 	= AMP(ycenter, 1/yscale)
         print(warn(n, PRINT16(xscaled),PRINT16(sscaled),PRINT16(ycenter),"\t\t",PRINT16(dleft),PRINT16(dright))) 
      end

      return POS (SUB (dleft,epsilon)) or POS (SUB (dright,epsilon))
   end

   while check_above_epsilon (agent, x, y) do
      assert (n < LIMIT, "RECURSION REACHES LIMIT!!!")
      if NEG(dleft) and POS(dright) then 
         xn = SUB(xcache,step)     
         x.set(agent, xn)			-- move left
      elseif POS(dleft) and NEG(dright) then
         xn = ADD(xcache,step)
         x.set(agent, xn)			-- move right
      else 
         step = DIV(step,NEW(2))	        -- better resolution
         x.set(agent, xcache)
      end
      n = n + 1
   end
   MUTE = nil
   return xcache
end


function argmin_constraint (a, target)  -- two connectors as pipe-constraint
  local me = {}
  local actors = {a, target}
  local agent = "argmin"

  local function process_new_value ()
    if a.value() and target.value() and not me["iter"] and a.value()~=agent and a.value()=="user" then 
       if TRACE then print(warn ("OPTIMIZER: Received", a.value(), target.value(), PRINT16(a.get()), PRINT16(target.get()))) end
       me["iter"] = not nil
       a.disconnect(me)
       local mutestate = MUTE
       local origin = a.value()
       local startx  = a.get()
       local starty  = target.get()
       MUTE = not nil
       a.forget (origin)
       assert(not a.value(), "OPTIMIZER: can't release source")
       assert(not target.value(), "OPTIMIZER: can't release target")
       local final = argmin_iter (agent, a, target, startx,starty)
       MUTE = mutestate
       a.set (origin, final)
       a.connect(me)
       me["iter"] = nil
    end
  end
  local function process_forget_value ()
    -- a.forget(me)		-- ignore messages from target
    target.forget(me)
  end
  me = make_actor (process_new_value, process_forget_value) 
  me["setters"]  = function () return actors end
  me["class"]  = "argmin"
  me["iter"]  = nil
  a.connect(me)
  target.connect(me)
  return me
end

function cargmin(target) local z=make_connector(); argmin_constraint (z, target); return z end 
function FNARGMIN (a,target) return argmin_constraint (a,target) end


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

FNARGMIN (X, M)

X.set("user", 10)			-- works 1.871875
--print("_________________ constraint second")
--X.forget("user")
--X.set("user", 1)			-- works 1.871875

--]]
