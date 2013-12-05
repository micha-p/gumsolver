--[[

dimensions are annoying!!!

possibilities: 

- special connectors for scales => twice as much connectors
- scientif notation => annoying during input

Best solution: scaled probes during declaration!

# permil decimal: 137	octal: 211	hex: 89 


If any symbol is used for the first time, its possible to declare its scale as:

a [%]
b [%o]
c [ppm]
d [‰]

These scales ar not units, but its also possible to use:

a [m]
b [°C]
c [any]

Of course, its also necessary to scale values during input for this probe. Therefore, any connector still contains the original values for propagation within the network, but is attached to a scaled probe. Setting values is more difficult, as values from outside have to be scaled to. 
Here, the run-routine checks if the connector has a scale and uses this value before setting.

Therefore, all communication to connectors from outside is now handled by the probe. Not just getting but also setting.

Any unknown scales between the brackets are taken as arbitary unit with a scale of 1.

--]]

SCALE={}
SCALE["[%]"]=0.01
SCALE["[‰]"]=0.001
SCALE["[°/oo]"]=0.001
SCALE["[%o]"]=0.001
SCALE["[ppm]"]=0.000001


PRINTU = function (r, u) 
   local len = 15 - #u
   return string.format("%-"..len.."."..len.."s",r)..u
   end


function probe_unit (name, connector, unit, scale)
   local me = {}
   local actors = {connector}
   local printname = PRINTU (name, unit)
   me = scale and make_actor (function () printprobe (printname, PRINT (vamp(connector.get(), 1/scale))) end, 
                              function () printprobe (printname, ".") end, name)
        or make_actor (function () printprobe (printname, PRINT (connector.get())) end, 
                       function () printprobe (printname, ".") end,
                       name)
   me["class"]   = "probe"
   me["name"]    = name
   me["unit"]    = unit
   me["setters"] = function () return actors end
   connector.connect(me)
   return me
end

function ensure_symbol_and_probe_with_unit (name, unit, connector)
   c= ensure_symbol (name, connector)
   c["scale"] = SCALE[unit]
   if not PROBES[name] then 
         PROBES[name] = probe_unit (name, CONNECTORS[name], unit, SCALE[unit]) 
   end
return CONNECTORS[name]
end

