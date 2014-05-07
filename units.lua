--[[

dimensions are annoying!!!

possibilities: 

- special connectors for scales => twice as much connectors
- scientific notation => annoying during input

Best solution: scaled probes during declaration!



If any symbol is used for the first time, its possible to declare its scale as:

a [%]
b [%o]
c [ppm]   # permil decimal: 137	octal: 211	hex: 89 


These scales ar not units, but its also possible to use:

a [m]
b [°C]
c [any]

Of course, its also necessary to scale values during input for this probe. Therefore, any connector still contains the original values for propagation within the network, but is attached to a scaled probe. Setting values is more difficult, as values from user have to be scaled to. 
Here, the run-routine checks if the connector has a scale and uses this value before setting.

Any units have to be declared before first use with directive #UNIT. Using this mechanism its possible to use unicode strings for permil without tainting the source files. Otherwise they are used but not scaled

--]]

PRINT16 = function (...) 
   local f={}
   for i,r in ipairs(arg) do
      f[i] = stringtest(r) and string.format("%-15.15s",r) or string.format("%-15.15s",PRINTX(r))
   end
return unpack (f)
end

SCALE={}

function readunit(line)
   unit = line:match("%s*("..UNITPATTERN..").*")
   scale= line:match("%s*"..UNITPATTERN.."%s+([%d.]+).*")
   SCALE[unit]=scale
   if DEBUG then warn ("UNIT", unit, scale) end
end

function printprobe (name, connector)
   print (PRINT16 (name, connector and connector["unit"] or "", connector and PRINTX (get_scaled_val_from_connector (connector)) or "."))
   io.flush()
end


function get_scaled_val_from_connector (connector)
   local scale = connector["scale"] or 1
return connector.value() and vamp(connector.get(), 1/scale) or nil
end

