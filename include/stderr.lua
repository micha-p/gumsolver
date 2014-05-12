--[[

Terminal 1 : 
mkfifo gsfifo
tail -f gsfifo

Terminal 2: 

gumsolver -DEBUG -f mypnetwork 2>> gsfifo


--]]

-- colored output
warn=function (...)
   local first = arg[1]
   arg[1]="\27[33m"..tostring(arg[1] or "")
   arg[#arg+1]="\27[m"
return unpack(arg)
end


-- print redirected to stderr

print2 = function (t, ...) -- recursive consumer
return #arg > 0 and
       io.stderr:write(tostring(t)) and
       io.stderr:write("\t") and
       print2(unpack(arg))
       or
       t and io.stderr:write(tostring(t)) and print2()
       or
       io.stderr:write("\n") and io.stderr:flush()
end

