-- The main function is the first function called from Iguana.
-- The Data argument will contain the message to be processed.
require 'depend'
require 'baseurl'
require 'search'

function main(Data)
   local MList, TChanMap = depend.report()
   local Report
   
   local R = net.http.parseRequest{data=Data}
   
   BaseUrl = baseurl.url(R)
   
   if R.params.search then
      Report = SearchReport(R.params.search, TChanMap, MList, BaseUrl)
   else
      Report = SharedModuleReport(MList, TChanMap, BaseUrl)
   end
   
   Report = SearchBox(R.params.search)..Report
      
   net.http.respond{body=Report}
end
