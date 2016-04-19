


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
 
-- And we generate help programmatically like in Step 3
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

local MetaTable

local foo = {}

-- But now we package everything up into one convenient
-- call making it easy to create multiple objects
function foo.make(Owner)
   if not MetaTable then
      local MethodList={"rake", "shovel", "pick", "hammer"}
      MetaTable = MakeMetaTable(MethodList)
      MakeHelp(MethodList, MetaTable)
   end
   local Result = {owner=Owner}
   setmetatable(Result, MetaTable)
   return Result
end

-- And finally we just use the new API which makes it
-- super easy to create objects on the fly with a simple
-- interface.  Just starting here to begin with would make
-- it hard to understand all the ingredients that went into
-- this recipe but hopefully at this stage you have see
-- the concepts built up step by step
local function Step4AllTogether()
   -- Define our objects 
   local Jack = foo.make("Jack")
   local Mary = foo.make("Mary")
   local Jake = foo.make("Jake")
   Mary:hammerSelect{live=false}
   Jake:hammerSelect{live=true}
   Jack:rakeSelect{live=false}
   -- Try typing Mary: at and see the auto-completion help
end

return Step4AllTogether