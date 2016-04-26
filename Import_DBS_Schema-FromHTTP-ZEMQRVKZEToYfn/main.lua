-- This channel shows the use of a module which can query a database and generate
-- a DBS schema file.  DBS schema perform the same role as a vmd based table grammar
-- in allowing one to populate a set of records and use the db:merge{} function.
-- See http://help.interfaceware.com/api/#dbs_init
-- As of today only MySQL is supported

db.generateSchema = require 'db.schema.generate'
local config = require 'encrypt.password'
local Key = 'sdlfjhslkfdjhslkdfjhskj'

-- To avoid saving database credentials into the Lua script ahnd having
-- See http://help.interfaceware.com/v6/encrypt-password-in-file
--To change the password and host you'll need to 
-- 1) Enter them into these lines
-- 2) Uncomment the lines.
-- 3) Recomment the lines
-- 4) Remove the password and host from the file before you same a milestone

--config.save{config='apphost', key=Key, password=''}
--config.save{config='apppassword', key=Key, password=''}
local function GetSchema()
   local Password = config.load{config='apppassword', key=Key}..'dd'
   local Host     = config.load{config='apphost', key=Key}
   
   local DB = db.connect{
      api=db.MY_SQL, 
      user='crm', 
      password=Password,
      name=Host
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
   local Success, Schema = pcall(GetSchema)
   if Success then
      net.http.respond{body=Schema, entity_type='text/plain'}
   else
      if type(Schema)=='table' then
         Schema = Schema.message
      end
      net.http.respond{body=ErrorMessage..Schema, entity_type='text/plain'}
   end
end


