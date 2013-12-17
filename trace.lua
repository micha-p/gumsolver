--[[
provides a small unique number for every object
--]] 

TRACE=nil
MUTE=nil
HIDDEN_TABLE_OF_TABLES={}

function short (t)
   if stringtest(t) then
      return t
   end
   if not t then
      return "nil"
   end
   if t == {} then
      return "{}"
   end
   local key = table.find (HIDDEN_TABLE_OF_TABLES, t)
   assert (tabletest(t), "Error while trying to display table: No table given", t)

   if key then
      return "t"..key
   else
      table.insert (HIDDEN_TABLE_OF_TABLES, t)
      return "t"..#HIDDEN_TABLE_OF_TABLES
   end
end

function printtrace (sender, message, a, b, c)  
   if TRACE then warn (short(me), message, short(a), short(b), short(c), 
                       a and a["info"] or "", 
                       b and b["info"] or "", 
                       c and c["info"] or "" 
--                      a and a.value() and a.get()["v"], 
--                      b and b.value() and b.get()["v"], 
--                      c and c.value() and c.get()["v"]
                       ) 
   end
end

