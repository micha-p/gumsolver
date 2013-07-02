--header contains formula, records do not


function csv_read(filename,separator)
   local sep = separator or ","
   local file=assert(io.open(filename,"r"))
   local line=assert(file:read())
   local rheader=csv_read_line(line, sep)
   local rtable={}
   local header={}

   for k,v in ipairs(rheader) do header[k]= string.find(v,"=") and string.match(v,"%s*(.+)%s*=") or v end

   for line in function() return file:read() end do
      local fields={}
      for i,field in ipairs(csv_read_line(line, sep)) do
      	 if i > #header then
      	    error ("To many input fields, check line endings!")
      	 else
            fields[header[i]]=try_tonumber(field)
         end
      end
      table.insert(rtable,fields)
    end
   
   file:close()
   return rtable,rheader,header
end

function try_tonumber (s)
   if string.find(s,"^%s*%.%s*$") then
      return nil
   else
      local n = tonumber(s) 
      return n or s
   end
end


function csv_read_line (str, sep)
      str = str .. sep
      local t = {}
      local pos = 1
      local last = str:len()
      repeat
        if str:find('^"', pos) then
          local closing = str:find('[^"]"[^"]', pos+1)
          if not closing then error('closing " not found') end
          local entry = string.gsub(string.sub (str, pos+1, closing), '""', '"')
          print (entry)
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

--[[records, header,short =csv_read("tableformula.txt","\t")
for k,v in ipairs(header) do print(k,v) end
for k,v in ipairs(short) do print(k,v) end]]

