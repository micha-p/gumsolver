-- adaptive central difference algorithm:
-- decrease h until changes in result are smaller than epsilon

LIMIT   = 500

function partial_iter (agent, y, x, starty, startx)
   
   local n = 0
   local epsilon = AMP (starty,0.001)
   local step 	 = AMP (startx,0.1)
   local oldy, newy
   
   if ITER or DEBUG then
      print2("PARTIAL", PRINT16("d "..y["name"]),PRINT16("d "..x["name"]))
   end
   
   function calculate (agent, y, x)
      local xleft, xright, yleft, yright, dx, dy
      x.forget(agent)   
      xleft = SUB (startx, step)
      x.set(agent, xleft)
      yleft = y.get()
      x.forget(agent)
      xright = ADD (startx, step)
      x.set(agent, xright)
      yright = y.get()
      x.forget(agent)
      dx = SUB(xright,xleft)
      dy = SUB(yright,yleft)
      dydx=DIV(dy,dx)
      if ITER then
         print2(n,PRINT16(dy),PRINT16(dx),PRINT16(dydx),"\t",PRINT16(yleft),PRINT16(yright),PRINT16(xleft),PRINT16(xright))
      end
      return dydx
   end
   
   oldy=starty
   newy=ADD(starty,ADD(epsilon,epsilon))
   while POS(SUB(ABS(SUB(oldy,newy)),epsilon)) do
      assert (n < LIMIT, "DIFFERENTIATOR: RECURSION REACHES LIMIT!!!")
      oldy=newy
      newy = calculate (agent,y,x)
      step = DIV(step,NEW(2))	        -- better resolution
      n = n + 1
   end
   MUTE = nil
   return newy
end

ITERLOOPP=nil

function chain(a,b)
   local asetter = a.value()
   local bsetter = b.value()
   if DEBUG then print2("Chain?",a["name"],b["name"]) end
   if asetter and bsetter then
      local aval=a.get()
      a.forget(asetter)
      if a.value() then 
         return nil
      else
         a.set(asetter,aval)
         return not nil
      end
   else
      return nil
   end
end

function partial_constraint (y,x,derivative)
  local me = {}
  local actors = {x, y, derivative}
  local agent = "partial"

  local function process_new_value ()
    if (not ITERLOOPP) and x.value() and y.value() and (x.value=="user" or x.value=="final") and chain(x,y) then 
       if DEBUG then print2("START DIFF",PRINTX(y.get()), PRINTX(x.get())) end
       ITERLOOPP = not nil
       local mutestate = MUTE
       local tracestate=TRACE
       local origin = x.value()
       local startx  = x.get()
       local starty  = y.get()
       MUTE = not nil
       TRACE=nil
       x.forget (origin)
       derivative.forget (agent)
       assert(not x.value(), "DIFFERENTIATOR: can't release source")
       assert(not y.value(), "DIFFERENTIATOR: clearing source doesn't release target")
       local final = partial_iter (agent, y, x, starty, startx)
       TRACE=tracestate
       MUTE = mutestate
       x.set (origin, startx)
       derivative.set (agent, final)
       ITERLOOPP = nil
    end
  end
  local function process_forget_value ()
    if (not x.value()) or (not y.value()) then derivative.forget(me) end
  end
  me = make_actor (process_new_value, process_forget_value) 
  me["setters"]  = function () return actors end
  me["class"]  = "partial"
  me["iter"]  = nil
  x.connect(me)
  y.connect(me)
  print2("partial created")
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

FNARGMIN (X, M)

X.set("user", 10)			-- works 1.871875
--print("_________________ constraint second")
--X.forget("user")
--X.set("user", 1)			-- works 1.871875

--]]
