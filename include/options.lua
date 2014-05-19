function collect_short_options(arg)
   local stack={}
   for i = 1, (arg and #arg or 0) do
      local a = arg[i] 
      if string.match (a,"^-[a-z]") then table.insert(stack, string.sub(a,2,string.len(a))) end
   end
   return table.concat(stack)
end   

function get_next_option(arg)
   if arg[1] then 
      return string.match(arg[1],"^%-%-?(.*)$")
   else
      return nil
   end
end
   
--print(collect_short_options({"1","2","-e","-d,","-qr","-d\t","f","-q"}))

--print(get_next_long_option({"--VERSION", "END"}))
--print(get_next_long_option({"-VERSION", "END"}))
--print(get_next_long_option({"END"}))
