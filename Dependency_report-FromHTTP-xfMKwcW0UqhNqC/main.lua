-- See http://help.interfaceware.com/forums/topic/generating-a-report-of-which-channels-use-each-shared-module
-- for information on what this channel does and it's history.

local auth = require 'web.basicauth'

local depend = require 'depend'
require 'search'

function main(Data)
   local MList, TChanMap = depend.report()
   local Report
   
   local R = net.http.parseRequest{data=Data}
   
   if not auth.isAuthorized(R) then
      auth.requireAuthorization("Enter your Iguana username and password")
      return
   end
   
   BaseUrl = 'http://'..R.headers.Host:split(':')[1]..':'..iguana.webInfo().web_config.port..'/'
   trace(BaseUrl)
   
   if R.params.search then
      Report = SearchReport(R.params.search, TChanMap, MList, BaseUrl, auth.getCredentials(R).username)
   else
      Report = SharedModuleReport(MList, TChanMap, BaseUrl)
   end
   
   Report = SearchBox(R.params.search)..Report
      
   net.http.respond{body=Report}
end
