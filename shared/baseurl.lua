baseurl = {}

local BaseUrl = ''

function baseurl.url(Request)
   
   if #BaseUrl == 0 then
      BaseUrl = 'http://'..Request.headers.Host:split(':')[1]..':'..iguana.webInfo().web_config.port..'/'
   end
   return BaseUrl
end