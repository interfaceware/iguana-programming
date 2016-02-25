depend = {}

local function TranList()
   local List = {}
   for K,V in os.fs.glob('run/*') do
      List[#List+1] = K:sub(5)
   end
   return List
end

local function DependList(TranList)
   local MList = {}
   for i=1,#TranList do
      local ProjectFile =  'run/'..TranList[i]..'/'..TranList[i]..'/project.prj'
      trace(ProjectFile)
      local F = io.open(ProjectFile, 'r')
      if F then
         local P = F:read('*all')
         P = json.parse{data=P}
         for j = 1,#P.LuaDependencies do
            local MName = P.LuaDependencies[j]
            if MList[MName] == nil then MList[MName] = {} end
            MList[MName][#MList[MName]+1] = TranList[i]
         end
      end
   end
   return MList
end

local function FindFilterGuid(C)
   if C.message_filter then
      local Guid = C.message_filter.translator_guid
      if Guid then return Guid:nodeValue() end
   end
end

local function FindToTranslatorGuid(C)
   if C.to_mapper then
      return C.to_mapper.guid:nodeValue()
   end
end

local function FindFromTranslatorGuid(C)
   if C.from_mapper then
      return C.from_mapper.guid:nodeValue()
   end
end

local function FindFromHttpGuid(C)
   if C.from_http and C.from_http.guid then
      return C.from_http.guid:nodeValue()
   end
end


local function FindFromLlpListenerGuid(C)
   if C.from_llp_listener and C.from_llp_listener.ack_script then
      return C.from_llp_listener.ack_script:nodeValue()
   end
end


local function RegisterTranslator(C, FindFunc, Extn, CList, TList) 
   local Guid = FindFunc(C)
   if Guid and #Guid > 0 then
      TList[Guid] = {name=C.name:nodeValue(), loc=Extn, cguid=C.guid:nodeValue()}
   end
end

local function ChannelList()
   local CList = {}
   local TList = {}
   local F = io.open('IguanaConfigurationRepo/IguanaConfiguration.xml', 'r')
   local C = F:read('*all')
   F:close()
   C = xml.parse{data=C}
   local G = C.iguana_config.channel_groupings.grouping.channels
   for i=1,G:childCount("channel") do
      local ChannelName = G:child("channel", i).channel_name:nodeValue()
      local ChannelConfig = iguana.channelConfig{name=ChannelName}
      local Channel = xml.parse{data=ChannelConfig}.channel
      RegisterTranslator(Channel, FindFilterGuid, 'F', CList, TList)
      RegisterTranslator(Channel, FindFromHttpGuid, 'H', CList, TList)
      RegisterTranslator(Channel, FindFromLlpListenerGuid, 'LLP', CList, TList)
      RegisterTranslator(Channel, FindToTranslatorGuid, 'D', CList, TList)
      RegisterTranslator(Channel, FindFromTranslatorGuid, 'S', CList, TList)
   end
   return TList
end

depend.componentMap={
   H='From HTTPS',
   D='To Translator',
   S='From Translator',
   LLP='Acknowledgment',
   F='Filter'
}

function depend.report()
   local List = TranList()
   local MList = DependList(List)
   local TList = ChannelList() 
   return MList, TList
end