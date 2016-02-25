baseurl = {}

local BaseUrl = ''

function baseurl.url(Request)
   if #BaseUrl == 0 then
      local F = io.open('IguanaConfiguration.xml', 'r')
      local C = F:read('*all')
      F:close()
      C = xml.parse{data=C}
      BaseUrl = 'http://'..Request.headers.Host:split(':')[1]..':'..C.iguana_config.web_config.port..'/'
   end
   return BaseUrl
end