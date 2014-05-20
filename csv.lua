-- header contains formula, records do not
-- to ensure correct sequence, each record is given as an itable of fieldstrings with preceeding colname

function csv_read(separator,filehandle)
   local sep = separator or ","
   io.input(filehandle)
   local rtable={}
   local header={}

   for line in io.lines() do
      local fields={}
      if not line:find("^# ") then			-- skip comments
         for i,field in ipairs(csv_process_line(line, sep)) do
       	    if #rtable > 1 and i > table.getn(rtable[1]) then
      	       error ("Too many input fields: "..i.." Check line endings!: "..line)
      	    else
               table.insert(fields, field)
            end
         end
         table.insert(rtable,fields)
       end
    end
    return rtable
end


function csv_process_line (str, sep)
   if str then 
      str = str.. sep
      local t = {}
      local pos = 1
      local last = str:len()
      repeat
        if str:find('^"', pos) then
          local closing = str:find('[^"]"[^"]', pos+1)
          if not closing then error('closing quote not found') end
          local entry = string.gsub(string.sub (str, pos+1, closing), '""', '"')
          table.insert(t, entry)
          pos = str:find(sep, closing) + 1
        else 
          local ending = str:find(sep, pos)
          table.insert(t, str:sub(pos, ending-1))
          pos = ending + 1
        end
      until pos > last
      return t
   else
      return {}
   end
end


