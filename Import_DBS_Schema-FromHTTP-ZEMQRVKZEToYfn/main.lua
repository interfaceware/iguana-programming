-- This channel shows the use of a module which can query a database and generate
-- a DBS schema file.  DBS schema perform the same role as a vmd based table grammar
-- in allowing one to populate a set of records and use the db:merge{} function.
-- See http://help.interfaceware.com/api/#dbs_init
-- As of today only MySQL and Microsoft SQL Server are supported

db.generateSchema = require 'db.schema.generate'
local config = require 'encrypt.password'
local Key = 'sdlfjhslkfdjhslkdfjhskj'

-- To avoid saving database credentials into the Lua script ahnd having
-- See http://help.interfaceware.com/v6/encrypt-password-in-file
--To change the database name, user, password and database API type you'll need to 
-- 1) Enter them into these lines
-- 2) Uncomment the lines.
-- 3) Recomment the lines
-- 4) Remove the password and host from the file before you same a milestone

--config.save{config='appname',     key=Key, password='YOUR DATABASE NAME'}
--config.save{config='apppassword', key=Key, password='YOUR PASSWORD'}
--config.save{config='appuser',     key=Key, password='YOUR USER'}
--config.save{config='appapi',      key=Key, password=tostring(db.SQL_SERVER)} -- Replace with your API TYPE

local function GetSchema()
   local Password = config.load{config='apppassword', key=Key}
   local DbName   = config.load{config='appname', key=Key}
   local DbUser   = config.load{config='appuser', key=Key}
   local DBApi    = tonumber(config.load{config='appapi', key=Key})
   local DB = db.connect{
      api=DBApi, 
      user=DbUser, 
      password=Password,
      name=DbName
   }
   local Def = db.generateSchema(DB)
   local D = dbs.init{definition=Def}
   local A = D:tables()
   -- 5) Try examining A
   return Def
end

local ErrorMessage = [[
Failed to connect and generate schema.  You probably have not edited
the channel yet to put in the right database credentials.

Please:

1) Stop the channel
2) Edit the source code to put in the right credentials for your database
3) Rerun the channel.

Error message is:


]]

function main()
   local Success, Schema
   if iguana.isTest() then
      Success = true
      Schema = GetSchema()
   else
      Success, Schema = pcall(GetSchema)    
   end
   if Success then
      net.http.respond{body=Schema, entity_type='text/plain'}
   else
      if type(Schema)=='table' then
         Schema = Schema.message
      end
      net.http.respond{body=ErrorMessage..Schema, entity_type='text/plain'}
   end
end


