--[[

dimensions are annoying!!!

possibilities: 

- special connectors for scales => twice as much connectors
- scientific notation => annoying during input

Best solution: scaled probes during declaration!

# permil decimal: 137	octal: 211	hex: 89 


If any symbol is used for the first time, its possible to declare its scale as:

a [%]
b [%o]
c [ppm]

These scales ar not units, but its also possible to use:

a [m]
b [°C]
c [any]

Of course, its also necessary to scale values during input for this probe. Therefore, any connector still contains the original values for propagation within the network, but is attached to a scaled probe. Setting values is more difficult, as values from user have to be scaled to. 
Here, the run-routine checks if the connector has a scale and uses this value before setting.

Any units have to be declared before first use with directive #UNIT. Using this mechanism its possible to use unicode strings for permil without tainting the source files. Otherwise they are used but not scaled.
variables using units have to declared before first use in expressions as well.

--]]

SCALE={}

function readunit(line)
   unit = line:match("%s*("..UNITPATTERN..").*")
   scale= line:match("%s*"..UNITPATTERN.."%s+([%d.]+).*")
   SCALE[unit]=scale
   if DEBUG then warn ("UNIT", unit, scale) end
end


function probe_unit (name, connector, unit, scale)
   local me = {}
   local actors = {connector}
   me = scale and make_actor (function () printprobe (name, PRINT (vamp(connector.get(), 1/scale)), unit) end, 
                              function () printprobe (name, ".", unit) end, name)
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

function getval_from_connector_with_unit(connector)
   local scale = connector["scale"] or 1
return PRINT (vamp(connector.get(), 1/scale))
end
   
function ensure_symbol_and_probe_with_unit (name, unit, connector)
   c= ensure_symbol (name, connector)
   c["scale"] = SCALE[unit]
   if not PROBES[name] then 
         PROBES[name] = probe_unit (name, CONNECTORS[name], unit, SCALE[unit]) 
   end
return CONNECTORS[name]
end

