depend = {}

require 'split'

local function Exec(Command) 
   local F = io.popen(Command)
   local R = F:read('*a')
   F:close()
   return R
end

local function ChangeDir(Dir)
   local Cmd = ''
   if Dir:sub(2,2) == ':' then
      Cmd = Dir:sub(1,2)..' & '
   end 
   return Cmd..'cd "'..Dir..'" '
end

local function ExportFossil(TempDir, ExportDir)
   os.execute(ChangeDir(TempDir)..' & mkdir "'..ExportDir..'"')
   local A = Exec('cd')
   A = A:gsub('\n', '')
   local Cmd = ChangeDir(TempDir..ExportDir)
   os.execute(Cmd..'& "'..A
      ..'\\fossil.exe" open "'..A..'\\vcs_repo.sqlite"')
   if not iguana.isTest() then
      os.execute(Cmd..'& "'..A..'\\fossil.exe" close')
   end
end

local function TranList(TempDir, ExportDir)
   local List = Exec(ChangeDir(TempDir..ExportDir)..' & dir /b')
   List = List:split('\n')  
   return List
end

local function DependList(Dir, TranList)
   local MList = {}
   for i=1,#TranList do
      local ProjectFile =  Dir..'\\'..TranList[i]..'\\project.prj'
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
   if Guid then
      TList[Guid] = {name=C.name:nodeValue(), loc=Extn, cguid=C.guid:nodeValue()}
   end
end

local function ChannelList()
   local CList = {}
   local TList = {}
   local F = io.open('IguanaConfiguration.xml', 'r')
   local C = F:read('*all')
   F:close()
   C = xml.parse{data=C}
   for i = 1, C.iguana_config.channel_config:childCount('channel') do
      local Channel = C.iguana_config.channel_config:child("channel", i)
      RegisterTranslator(Channel, FindFilterGuid, 'F', CList, TList)
      RegisterTranslator(Channel, FindFromHttpGuid, 'H', CList, TList)
      RegisterTranslator(Channel, FindFromLlpListenerGuid, 'LLP', CList, TList)
      RegisterTranslator(Channel, FindToTranslatorGuid, 'D', CList, TList)
      RegisterTranslator(Channel, FindFromTranslatorGuid, 'S', CList, TList)
   end
   
   
   return TList
end

depend.tempDir = "C:\\temp\\"
depend.exportDir = 'export'

function depend.root()
   return depend.tempDir..depend.exportDir
end

depend.componentMap={
   H='From HTTPS',
   D='To Translator',
   S='From Translator',
   LLP='Acknowledgment',
   F='Filter'
}

function depend.report()
   local TempDir = "C:\\temp\\"
   local ExportDir = 'export'
   ExportFossil(TempDir, ExportDir)
   local List = TranList(TempDir, ExportDir)
   local MList = DependList(TempDir..ExportDir, List)
   local TList = ChannelList() 
   return MList, TList
end