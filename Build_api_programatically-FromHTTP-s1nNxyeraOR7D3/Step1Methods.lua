-- So this code is all about showing how we can use what are called "CLOSURES"
-- A CLOSURE is a function which Lua let's us define on the fly which has access
-- to variables in the scope in which it is defined.

-- It's helpful to us to be able to create a table of functions with different names
-- and different behaviors based on the variables that each 'closure' captures.

-- Languages like Javascript also support Closures:
-- See this for reference: https://en.wikipedia.org/wiki/Closure_(computer_programming)

-- In this first step we take a list of 'tools' and create one closure per 'tool'
-- These become like methods

-- This function takes the string variable Owner and the array "MethodList"
-- and generates an table of closure functions for each of the entries in Method list
local function MakeMethods(Owner,MethodList)
   local R = {}
   R.owner = Owner
   trace(R)
   for i=1,#MethodList do
      local Tool = MethodList[i];
      trace(Tool)
      R[Tool.."Select"] = function(self) return self.owner.." selected a "..Tool end 
   end
   -- Please click and expand the returned table to see the generated
   -- 'closures' - they appear just like functions.
   return R
end

local function Step1Methods()
   local MethodList={"rake", "shovel", "pick", "hammer"}
   -- MethodList is a Lua table in the array format
   -- Please click and expand it in the annotation dialog
   trace(MethodList)
   -- MakeMethods returns a table of closures generated
   -- off the data we passed in.
   local O = MakeMethods("Jake", MethodList)
   -- Here we invoke the closures - which look a lot
   -- like "methods' on the "O" object. See:
   -- http://help.interfaceware.com/v6/eliots-tips-and-tricks#colon
   -- to learn more about the "colon" operator.
   O:hammerSelect()
   O:rakeSelect()
   O:shovelSelect()
   O:pickSelect()
   -- Try and type O: into the next line - you should
   -- see some nice intellisense happen with the methods
   -- defined on the O object.
end

return Step1Methods