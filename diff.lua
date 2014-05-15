-- this is just a quick approach
-- it won't work as expected when values are changed during iteration

require 'constraints'

function diff_constraint (input, output)
  local me = {}
  local old, recent
  local actors = {input, output}
  local function process_new_value ()
     if not INSIDE_ITERATION then 
        if DEBUG then print2("Diff",PRINT16(old), PRINT16(recent)) end
        if input.value() then
           recent = input.get()
           if old and recent then output.forget(me); output.set (me,SUB(recent,old)) end
        elseif output.value() then 
           if old then recent = ADD(old, output.get()); input.forget(me); input.set (me,recent) end
           old=recent 
        end
     end
  end
  local function process_forget_value ()
    if not INSIDE_ITERATION then 
       if DEBUG then print2("Dforget",PRINT16(old), PRINT16(recent)) end
       old=recent
       recent=nil
       input.forget(me) 
       output.forget(me)
       process_new_value()
    end
  end
  me = make_actor (process_new_value, process_forget_value) 
  me["setters"]  = function () return actors end
  me["class"]  = "diff"
  input.connect(me)
  output.connect(me)
  return me
end

--[[
i=make_connector()
o=make_connector()
probe ("In", i)
probe ("Out", o)

diff_constraint (i, o)

i.set("user", 3)
i.forget("user")
i.set("user", 5)
i.forget("user")
i.set("user", 8)
i.forget("user")
o.set("user", 1)
o.forget("user")
o.set("user", 10)
--]]
