--header contains formula, records do not


function csv_read(separator,filehandle)
   local sep = separator or ","
   io.input(filehandle)
   local rheader=csv_process_line(assert(io.read(), sep))
   local rtable={}
   local header={}

   for k,v in ipairs(rheader) do header[k]= string.find(v,"=") and string.match(v,"%s*(.+)%s*=") or v end
   for line in io.lines() do
      local fields={}
      for i,field in ipairs(csv_process_line(line, sep)) do
      	 if i > #header then
      	    error ("To many input fields, check line endings!")
      	 else
            fields[header[i]]=try_tonumber(field)
         end
      end
      table.insert(rtable,fields)
    end
   
    return rtable,rheader,header
end

function try_tonumber (s)
   if string.find(s,"^%s*$")      then return nil end  	-- empty cell
   if string.find(s,"^%s*%.%s*$") then return nil end  	-- missing value
   return tonumber(s) or s			    	-- number or symbol
end


function csv_process_line (str, sep)
      str = str .. sep
      local t = {}
      local pos = 1
      local last = str:len()
      repeat
        if str:find('^"', pos) then
          local closing = str:find('[^"]"[^"]', pos+1)
          if not closing then error('closing " not found') end
          local entry = string.gsub(string.sub (str, pos+1, closing), '""', '"')
          table.insert(t, entry)
          pos = str:find(sep, closing) + 2
        else 
          local ending = str:find(sep, pos)
          table.insert(t, str:sub(pos, ending-1))
          pos = ending + 1
        end
      until pos > last
return t
end


