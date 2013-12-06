CLIPBOARD=""
VALUECOLUMN=33
MASKTABLE={}  -- hash
MASKARRAY={}  -- array
CURRENTLINE=0

function jumpdown()
   if CURRENTLINE < #MASKARRAY then
      jumptoline(CURRENTLINE+1)
   end
end

function jumpup()
   if CURRENTLINE>1 then
      jumptoline(CURRENTLINE-1)
   end
end

function jumplefttostart ()
   jumptoline(CURRENTLINE)
   -- io.write("\27E\27[A")
end

function jumptoline(line)
   CURRENTLINE=line
   io.write("\27[".. CURRENTLINE ..";1H")
end

function jumptoend(further)
   CURRENTLINE = #MASKARRAY + (further or 0)
   jumptoline(CURRENTLINE)
end


function jumptomaskline(name)
   local line = MASKTABLE[name]
   if line then 
      jumptoline(line)
   else
      table.insert(MASKARRAY,name)
      MASKTABLE[name] = #MASKARRAY
      jumptoend()
   end
end

function reservemaskline(name, value, unit)
   local line = MASKTABLE[name]
   if not line then 
      table.insert(MASKARRAY,name)
      MASKTABLE[name] = #MASKARRAY
      printmaskline (name, value, unit)
   end
end

function printrawmaskline (string)
   jumptomaskline (string)
   io.write("\27[K")
   io.write(string)
   io.write("\27E\27[A")
end

function printfullmaskline (string)
   table.insert(MASKARRAY,string)
   jumptoend ()
   io.write("\27[K")
   io.write(string)
   jumplefttostart ()
return not nil
end


function printmaskline (name, value, unit)
   if name then
      jumptomaskline (name)
      io.write("\27[K")
      io.write(PRINT16(name))
      io.write("\t")
      io.write(PRINT16(unit or ""))
      io.write("\t")
      io.write(value or "")
      jumplefttostart ()
   end
end

function getchar()
   os.execute("stty raw -echo")
   local char = io.read(1)
   os.execute("stty sane")
return char
end

function loop()
   local char = ""
   while char and char ~= "\004" and char ~= "q" do 
      char = getchar()
      handlechar(char)
   end
   jumptoend(1)
   io.write("\27[K\27[J")
end

function handlechar(char)
   if char=="\27" then
      local nextchar=io.read(1)
      if nextchar =="[" then
         local command = io.read(1)
         if command=="A" then jumpup()   end 
         if command=="B" then jumpdown() end
      elseif nextchar =="O" then
         local command = io.read(1)
         if     command=="H" then jumptoline(1)
         elseif command=="F" then jumptoend() 
         end
      else
         warn ("Unknown escape sequence:"..nextchar.."="..string.byte(nextchar))
      end
   elseif char=="\13" or char=="\10" then
      jumptoend(1)
      io.write("\27[K\27[J")
      process_input(io.read())
      jumptoend(1)
      io.write("\27[K")
      jumptoend(0)
   elseif char=="\126" or char=="\127"  or char=="\b" then
      local c=CURRENTLINE
      process_input(MASKARRAY[CURRENTLINE])
      jumptoline(c)
   elseif char=="\t" then
      local c=CURRENTLINE
      io.write("\27[".. c ..";"..VALUECOLUMN.."H")
      io.write("\27[K")
      io.write("")
      process_input(MASKARRAY[CURRENTLINE].."=".. io.read())
      jumptoline(c)
   elseif char=="\03" then    -- copy
      local name=MASKARRAY[CURRENTLINE]
      if name and CONNECTORS[name] then
         CLIPBOARD = process_line(MASKARRAY[CURRENTLINE].."=")
      end
   elseif char=="\24" then    -- cut
      local name=MASKARRAY[CURRENTLINE]
      if name and CONNECTORS[name] then
         CLIPBOARD = process_line(MASKARRAY[CURRENTLINE].."=")
         process_input(MASKARRAY[CURRENTLINE])
      end
   elseif char=="\22" then    -- paste
      local name=MASKARRAY[CURRENTLINE]
      if CLIPBOARD and name and CONNECTORS[name] then
         process_line(MASKARRAY[CURRENTLINE])
         process_line(MASKARRAY[CURRENTLINE].."=".. CLIPBOARD)
      end
   else
      io.write ("\a")
   end
end   




