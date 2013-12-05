--[[
provides a small unique number for every object
--]] 

TRACE=nil
MUTE=nil
HIDDEN_TABLE_OF_TABLES={}

function short (t)
   if t == {} then
      return "{}"
   end
   local key = table.find (HIDDEN_TABLE_OF_TABLES, t)
   assert (tabletest(t), "Error while trying to display table: No table given")

   if key then
      return "t"..key
   else
      table.insert (HIDDEN_TABLE_OF_TABLES, t)
      return "t"..#HIDDEN_TABLE_OF_TABLES
   end
end


