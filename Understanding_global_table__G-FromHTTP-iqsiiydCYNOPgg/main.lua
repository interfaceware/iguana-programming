-- See http://help.interfaceware.com/v6/eliots-tips-and-tricks#_G
-- The more you understand Lua the more clear it becomes how integral
-- that tables are to Lua's internal design.

-- The _G object gives you access to the global table which has all the
-- the functions and variables defined in the global scope

-- This channel shows some interesting things you can learn from this

local Html

function main(Data)
   -- Step 1 
   -- Open up the _G object and browse it to see
   -- all the functions 
   trace(_G)
   -- Step 2
   -- If you forget the name of command then a great
   -- trick is to type _G. and then use deep auto
   -- completion to find the function you want
   -- Try typing _G.md  and you'll find the _G.util.md5 function
   
   
   -- Step 3
   -- Find all the parse functions in Iguana - type _G.parse
   
   
   -- Step 4
   -- Find functions and symbols that should not be global
   -- The other thing that _G very useful for is checking it you
   -- forgot to make a function local in scope.  Look at _G and you
   -- should see we forgot to make AAABadFunctionThatShouldBeLocal
   -- local in scope.  We can also see from the trace function
   -- here that this function exists in the global scope
   -- Put "local " in front of it to remove it from the global scope
   trace(_G.AAABadFunctionThatShouldBeLocal)

   net.http.respond{body=Html, entity_type='text/html'}
end

function AAABadFunctionThatShouldBeLocal()
   
end

Html=[[<p>
Read the code to understand this channel
</p>
<p>
It talks about the <a href="http://help.interfaceware.com/v6/eliots-tips-and-tricks#_G">global _G table</a>.
</p>
]]
