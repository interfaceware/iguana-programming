-- The next step is to add is support for the translator’s help system.
-- http://help.interfaceware.com/v6/customize-help

-- The help system in Iguana is what generates the on the fly information
-- and auto-completion of arguments for functions.  You can build up help
-- information by hand but you can also generate help programatically.

-- Generating help programatically is create for generating similar methods
-- like if they are methods on a web service API.

-- This is what gives the nice informative information and auto-completion of arguments for help functions. The beauty of the system is that one can generate help programmatically also rather than coding it up by hand.

-- Just like we did in Step 2 we generate a meta table with closures
local function MakeMetaTable(MethodList)
   local R = {}
   for i=1,#MethodList do
      local Tool = MethodList[i];
      trace(Tool)
 
      R[Tool.."Select"] = function(S) return S.owner.." selected a "..Tool end 
   end
   local MetaTable = {}
   MetaTable.__index = R
   return MetaTable
end
 
-- But in this step we now also generate help programmatically
local function MakeHelp(MethodList, MetaTable)
   local Methods = MetaTable.__index;
   for i=1, #MethodList do
      local HelpInfo ={}
      local Tool = MethodList[i]
      local MethodName = Tool.."Select"
      trace(Tool, MethodName)
      HelpInfo.Desc = "Select a "..MethodList[i]
      HelpInfo.Title = MethodName
      HelpInfo.ParameterTable = true
      HelpInfo.Parameters = {}
      HelpInfo.Parameters[1]={live={Desc="Active live tool"}}
      -- Please have a look at HelpInfo to see the form
      -- of the help
      trace(HelpInfo)
      help.set{input_function=Methods[MethodName], 
               help_data=HelpInfo}
   end
end
 
local function Step3GenerateHelp()
   local MethodList={"rake", "shovel", "pick", "hammer"}
   -- Generate the metatable of closures
   local MetaTable = MakeMetaTable(MethodList)
   -- Generate the help information
   MakeHelp(MethodList, MetaTable)
   -- Define our objects 
   local Mary = {owner="Mary"}
   local Jake = {owner="Jake"}
   setmetatable(Mary, MetaTable)
   setmetatable(Jake, MetaTable)
   -- Here are our objects with help
   Mary:hammerSelect{live=false}
   Jake:hammerSelect{live=true}
   -- Try typing Mary: at and see the auto-completion help
   
end

return Step3GenerateHelp