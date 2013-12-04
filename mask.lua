
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


function jumptoline(line)
   CURRENTLINE=line
   io.write("\27[".. CURRENTLINE ..";1H")
end

function jumptoend(further)
   jumptoline (#MASKARRAY + (further or 0))
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
   
function printmaskline (name,value)
   jumptomaskline (name)
   io.write("\27[K")
   io.write(PRINT16(name))
   io.write("\t")
   io.write(value)
   --- io.write("\27[0m\n")
   jumptoend ()
   -- io.write("\27[J")
end


function loop()
   local char = io.read(1)
   if char and char ~= "\004" then 
      handlechar(char)
      loop() 
      jumptoend()
   end
end

function navigate ()
   -- os.execute("stty min 1 time 0 -icanon -echo -echoctl")
   os.execute("stty raw -echo")
   loop()
   os.execute("stty sane")
   print()
end   

function handlechar(char)
   if char=="\27" then
      local nextchar= io.read(1)
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
      os.execute("stty sane")
      io.write("\27[K\27[J> ")
      process_input(io.read())
      os.execute("stty raw -echo")
      jumptoend(1)
      io.write("\27[K")
      jumptoend(0)
   elseif char=="\126" or char=="\127"  or char=="\b" then
      process_cycle(MASKARRAY[CURRENTLINE])
   elseif char=="\t" then
      io.write("\27[".. CURRENTLINE ..";17H")
      io.write("\27[K")
      os.execute("stty sane")
      io.write("")
      process_input(MASKARRAY[CURRENTLINE].."=".. io.read())
      os.execute("stty raw -echo")
   else
      io.write ("\a")
   end
end   




