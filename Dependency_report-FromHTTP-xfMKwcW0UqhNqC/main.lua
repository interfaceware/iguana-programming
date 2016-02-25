-- The main function is the first function called from Iguana.
-- The Data argument will contain the message to be processed.
require 'depend'
require 'baseurl'

function TraceChan(TranList, ChannelMap, i)
   trace(i)
   trace(TranList[i])
   trace(ChannelMap[TranList[i]])
end

function SharedTranList(Mod, MList, ChannelMap)
   local Line = ''
   local TranList = MList[Mod]
   for i = 1, #TranList do
      if ChannelMap[TranList[i]] then
         TraceChan(TranList, ChannelMap, i)
         Line = Line..ChannelMap[TranList[i]].name..
            '('..ChannelMap[TranList[i]].loc..') '
      else
         trace(TranList[i])   
      end
   end
   return Line
end


function OutputModule(Entry, TranGuid, BaseUrl)
   local Link = BaseUrl
   local E = filter.uri.enc
   Link = Link..'mapper/#ComponentName='..E(depend.componentMap[Entry.loc])
              ..'&ChannelName='..E(Entry.name)
              ..'&ChannelGuid='..TranGuid
              ..'&Page=OpenEditor&Module=main'
   
   return '"<a href="'..Link..'">'..Entry.name..'('..Entry.loc..')</a>"'
end

function SearchBox(Phrase)
   if not Phrase then Phrase = '' end
   return [[
   <table>
   <tr>
   <th>Search:</th>
   <td><form method="post" action=""><input name="search" value="]]..Phrase..[[">
       <input type="submit"></form></td>
   </tr>
   </table>
   ]]
end

function SharedModuleReport(MList, TChanMap, BaseUrl)
   local R = '<table>'
   for K,V in pairs(MList) do
      R = R..'<tr><th>'..K..'</th><td>'
      SharedTranList(K, MList, TChanMap)
      local TranList = MList[K]
      for i = 1, #TranList do
         if TChanMap[TranList[i]] then
            R = R..OutputModule(TChanMap[TranList[i]], TranList[i], BaseUrl)
         end
      end
      R = R..'</td></tr>\n'
   end
   R = R..'</table>'      
   return R
end

function ModuleContainPhrase(Phrase,Guid)
   local MainFile = depend.root()..'\\'..Guid..'\\main.lua'
   local Result = false
   trace(ProjectFile)
   local F = io.open(MainFile, 'r')
   if F then
      local M = F:read('*a')
      if M:find(Phrase) then
         Result = true
      end
      F:close()
   end 
   return Result
end

function SearchMainModules(Phrase, TChanMap)
   local TList = {}
   for K in pairs(TChanMap) do
      if ModuleContainPhrase(Phrase, K) then
         TList[K] = TChanMap[K]
      end
   end
   trace(TList)
   return TList
end

function SharedModuleContainPhrase(Phrase, ModName)
   local FName = depend.root()..'\\shared\\'..ModName
   FName = FName:gsub('%.', '\\')..'.lua'
   local F = io.open(FName, 'r')
   local Content = F:read('*all')
   F:close()
   if Content:find(Phrase) then
      return true
   else
      return false
   end
end

function SearchSharedModules(Phrase, ModuleList)
   local MList = {}
   for ModName in pairs(ModuleList) do
      if SharedModuleContainPhrase(Phrase,ModName) then
         MList[ModName] = ModuleList[ModName]
      end
   end
   return MList
end

function SearchReport(Phrase, TChanMap, ModuleList, BaseUrl)
   local TList = SearchMainModules(Phrase, TChanMap)
   local MList = SearchSharedModules(Phrase, ModuleList)
   
   local R = '<p>Search results on <b>'..Phrase..'</b></p>\n'
             ..'<p>Main modules containing the phrase.<p>'
             ..'<table>\n'        
   for C in pairs(TList) do
      R = R..'<tr><th>'..OutputModule(TList[C], C, BaseUrl)..'</th></tr>\n'   
   end
   R = R..'</table>\n'..
          '<p>Shared modules containing the phrase.</p>\n'
   R = R..SharedModuleReport(MList, TChanMap, BaseUrl)   
   
   return R
end

function main(Data)
   queue.push{data=Data}
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

function trace(M) return end