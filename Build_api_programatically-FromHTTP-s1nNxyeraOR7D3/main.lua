local Info=[[
<p>
Read <a href="http://help.interfaceware.com/kb/salesforce-com">this article</a> to
understand what this example channel can teach you.
</p>
<p>
The code shows how to generate a user friendly API programatically.
</p>
<p>
Please take the time to read through each example the
comments to see how it is done.
</p>
]]

local Step1Methods        = require 'Step1Methods'
local Step2MetaTable      = require 'Step2MetaTable'
local Step3GenerateHelp   = require 'Step3GenerateHelp'
local Step4AllTogetherNow = require 'Step4AllTogetherNow'

-- This channel came about from a talk I gave at the 2015 user
-- conference about building up a salesforce.com adapter.

-- Web service APIs typically involve some tricky bit of code to do
-- the authentication bit and then a whole lot of very similar methods
-- to access various data objects in the application.

-- It can be very tedious and error prone to build up this code by
-- hand.  This channel walks through building up core concepts to
-- show how you can build out web service APIs programmatically
-- to greatly reduce the amount of code you need to write.

-- To build up these types of objects in Lua it's necessary to use a couple of
-- more advanced features in the Lua language called “closures”
-- and “meta-tables”,  together with the translator’s own built in help system.

-- DON'T PANIC!! 

-- This example channel gradually introduces these concepts 
-- one by one with some simple examples so if you take your time
-- it should be easy to understand. Closures and meta-tables are a
-- pair of features in Lua that allow one to do ‘object orientated’ 
-- programming in the language.

-- To use the channel please go through the three steps.  Navigate
-- around and look the steps sequentially as each one builds on the
-- previous steps.

-- Enjoy! Eliot Muir 2016

function main(Data)
   Step1Methods()
   Step2MetaTable()
   Step3GenerateHelp()
   Step4AllTogetherNow()
   net.http.respond{body=Info, entity_type='text/html'}
end
