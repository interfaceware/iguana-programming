-- This example takes Step 1 to the next level by leveraging a
-- what Lua calls meta-tables.   Lua tables can have a meta-table
-- assigned to them.

-- Meta tables can be used to customize the behavior of a Lua
-- table for things like comparison and arithmetic.  There are
-- are special keys which have pre-defined meaning in Lua meta tables
-- See: http://www.lua.org/pil/13.html

-- The particular key feature of meta tables which we are going to
-- use is the "__index" key.  This key can be assigned to a table
-- which gives a list of default "properties" or members of the table.

-- The way this works is say you have a table "Foo" and it has a meta-table
-- "Bar" which has a entry "__index" which is assigned to table with a value "ABC".

-- Then when we look at the value Foo.ABC - even though the Foo table itself
-- does not have the value "ABC" it will in fact return the value of ABC in Bar.__index["ABC"]

-- Read http://www.lua.org/pil/13.4.1.html for more information about __index

-- Why is that useful?

-- Well effectively it allows as to define a CLASS of objects which all have
-- the same properties.  We define a table of closures which we assign to 
-- the "__index" property of the meta table.  Now every table which uses this
-- meta table ends up with the same properties or methods.

-- If you know Javascript well, meta tables have some analogies to 'prototypes'
-- See http://www.w3schools.com/js/js_object_prototypes.asp

-- Let's see it in action!

local function MakeMetaTable(MethodList)
   local R = {}
   -- We create a list of closures like we did before
   for i=1,#MethodList do
      local Tool = MethodList[i];
      
      trace(Tool) 
      R[Tool.."Select"] = function(S) return S.owner.." selected a "..Tool end 
   end
	-- But this time we assign them to a meta table
   local MetaTable = {}
   MetaTable.__index = R
   return MetaTable
end

local function Step2MetaTable()
   -- Our array of 'tools'
   local MethodList={"toothBrush", "pick", "hammer"}
   -- We build our meta table
   local MetaTable = MakeMetaTable(MethodList)
   -- Here are our two 'objects'
   local Mary = {owner="Mary"}
   local Jake = {owner="Jake"}
   -- We assign them both to use the same metatable
   setmetatable(Mary, MetaTable)
   setmetatable(Jake, MetaTable)
   -- We invoke the methods on the each object and
   -- get slightly different results based on their
   -- values
   Mary:hammerSelect()
   Jake:hammerSelect()
   Jake:toothBrushSelect()
end

-- Meta tables effectively give us an optimization on Step 1
-- by allowing us to generate the set of closure 'methods' only
-- once, but use them multple times.

return Step2MetaTable