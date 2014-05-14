CLIPBOARD=nil
UNDONAME=nil
UNDOVALUE=nil
VALUECOLUMN=33
MASKARRAY={}	-- ordered ipairs of content lines (connectornames or remarks)
MASKLOOKUP={}	-- hash table to get linenumber from connector name
CURRENTLINE=0


oldprintprobe = printprobe 
function printprobe (name, connector)
   if MASK then 
      printmaskline (name, connector)
   else 
      oldprintprobe(name, connector)
   end
end

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

function jump_to_left ()
   jumptoline(CURRENTLINE)
   io.write("\27E\27[A")
end

function jumptoline(line)
   CURRENTLINE=line
   io.write("\27[".. CURRENTLINE ..";1H")
end

function jumptoend()
   CURRENTLINE = #MASKARRAY
   jumptoline(CURRENTLINE)
end

function jump_below()
   CURRENTLINE = #MASKARRAY + 1
   jumptoline(CURRENTLINE)
end


function jumptomaskline(name)
   local line = MASKLOOKUP[name]
   if line then 
      jumptoline(line)
   ---else
      --table.insert(MASKARRAY,name)
      --MASKLOOKUP[name] = #MASKARRAY
      --jumptoend()
   end
end

function reservemaskline(name)
   local line = MASKLOOKUP[name]
   if not line then 
      table.insert(MASKARRAY,name)
      MASKLOOKUP[name] = #MASKARRAY 
      if DEBUG then print2("reserved maskline", name, #MASKARRAY) end
   end
   printmaskline (name, CONNECTORS[name])
end

function clearmaskline(name)
   local line = MASKLOOKUP[name]
   if line then 
      table.remove(MASKARRAY,line)
      if DEBUG then print2("cleared maskline", name, line) end
   elseif numbertest(name) and name<=#MASKARRAY then
      if DEBUG then print2("cleared maskline #"..name, MASKARRAY[name]) end
      table.remove(MASKARRAY,name)
   end
   MASKLOOKUP = {}
   for n,key in ipairs(MASKARRAY) do MASKLOOKUP[key]=n end
   print(write(MASKARRAY))
   printfullmask()
end


function printfullmask()
      io.write ("\27[H\27[J")   -- clear screen
      for line,entry in ipairs(MASKARRAY) do
         jumptoline(line)
         if CONNECTORS[entry] then 
            printmaskline (entry, CONNECTORS[entry])
         else
            print (entry)
         end
      end
      jumptoend()
end


function printmaskremarkline (string)
   table.insert(MASKARRAY,string)
   jumptoend ()
   if DEBUG then print2("reserved maskline", string, #MASKARRAY) end
   io.write("\27[K") -- clear to end of line
   io.write(string)
   jump_to_left ()
return not nil
end

function printmaskline (name, connector)
   if name and MASKLOOKUP[name] then
      jumptomaskline (name)
      io.write("\27[K")  -- clear line
      MUTE=nil
      oldprintprobe(name, connector)
      jump_to_left ()
      if DEBUG and CONNECTORS[name] then
         jumptomaskline (name)
         local c= CONNECTORS[name]
         local s= c.value()
         io.write("\27[".. CURRENTLINE ..";"..(VALUECOLUMN+16).."H")
         io.write("\27[K")
         if s and stringtest(s) then
            io.write("("..s..")")
         end
         jumptomaskline (name)
      end
   end
end

function getchar()
   os.execute("stty raw -echo")
   local char = io.read(1)
   os.execute("stty sane")
return char
end

function process_eventloop()
   local char = ""
   do_itertable()
   while char do 
      char = handlechar(getchar())
      jumptoline(CURRENTLINE)
   end
   jump_below()
end

function handleinput()
      jump_below()
      io.write("\27[K\27[J") -- clear to end of screen
      io.write(PROMPT or "> ")
      local i = io.read()
      if i then 
         process_input (i)
      else
         return nil
      end
      jumptoend()
end

function handleinteraction(line, char,name,connector,x)
   if char=="\126" or char=="\127"  or char=="\b" then  			-- delete
      UNDONAME=name
      UNDOVALUE=get_scaled_val_from_connector(connector)
      process_input(name)
   elseif char=="\t" or char=="\n" then						-- input
      io.write("\27[".. line ..";"..VALUECOLUMN.."H")
      io.write("\27[K")
--      io.write("")
      local i = io.read()
      if i and i~="" then 
         process_input(name)
         process_input(name.."=".. i) 
      end
   elseif char=="-" then    							-- ~80% ~80% ~80% = 50%
      process_line(name)
      if x then 
      	 process_line(name.."="..PRINTX(vamp(x, math.pow (1/2, 1/3))))
      else
         process_line(name.."=1")
      end   
   elseif char=="/" then    							-- ~8% ~8% ~8% = 95%
      process_line(name)
      if x then 
      	 process_line(name.."="..PRINTX(vamp(x, math.pow (0.95, 1/3))))
      else
         process_line(name.."=1")
      end   
   elseif char=="+" then    							-- ~125% ~125% ~125% = 200%
      process_line(name)
      if x then 
	 process_line(name.."="..PRINTX(vamp(x, math.pow (2, 1/3))))
      else
         process_line(name.."=1")
      end   
   elseif char=="*" then    							-- ~102.5% ~102.5% ~102.5% = 105%
      process_line(name)
      if x then 
	 process_line(name.."="..PRINTX(vamp(x, math.pow (1.05, 1/3))))
      else
         process_line(name.."=1")
      end   
   elseif char=="\07" then    							-- go
      do_itertable()
   elseif char=="\03" then    							-- copy
      CLIPBOARD = x
   elseif char=="\24" then    							-- cut
      CLIPBOARD = x
      process_input(name)
   elseif char=="\22" then    							-- paste
      process_line(name)
      process_line(name.."=".. PRINTX(CLIPBOARD))
   elseif char=="\26" then    							-- undo
      if UNDONAME then process_line(UNDONAME.."=".. PRINTX(UNDOVALUE)) end
   elseif char=="\18" then    							-- refresh
      printfullmask()
   else
      io.write ("\a")
   end   
   do_itertable()
end


function handlechar(char)
   if char=="\27" then
      local nextchar=io.read(1)
      if nextchar =="[" then
         local command = io.read(1)
         if command=="A" then 		jumpup() 
         elseif command=="B" then 	jumpdown() 
         end
      elseif nextchar =="O" then
         local command = io.read(1)
         if     command=="H" then 	jumptoline(1)
         elseif command=="F" then 	jumptoend() 
         end
      else
         warn ("Unknown escape sequence:"..nextchar.."="..string.byte(nextchar))
      end
   elseif char=="\04" or char=="\17" then
      return nil
   elseif char=="\13" or char=="\10" then
      handleinput()
   else
      local line = CURRENTLINE
      local name = MASKARRAY[CURRENTLINE]
      local connector = name and CONNECTORS[name]
      if connector then
         local x = get_scaled_val_from_connector(connector)
         handleinteraction(line, char, name, connector,x)
         printmaskline (name, connector)
         jumptoline(line)
      end
   end
   return not nil
end   




