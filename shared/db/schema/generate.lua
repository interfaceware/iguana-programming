
local MS_SQL = {}
MS_SQL.dataMap = {}
MS_SQL.dataMap.tinyint    = 'integer'
MS_SQL.dataMap.smallint   = 'integer'
MS_SQL.dataMap.int        = 'integer'
MS_SQL.dataMap.bigint     = 'integer'
MS_SQL.dataMap.numeric    = 'integer'
MS_SQL.dataMap.decimal    = 'integer'
MS_SQL.dataMap.bit        = 'integer'
MS_SQL.dataMap.smallmoney = 'integer'
MS_SQL.dataMap.money      = 'integer'

MS_SQL.dataMap.varchar    = 'string'
MS_SQL.dataMap.char       = 'string'
MS_SQL.dataMap.text       = 'string'
MS_SQL.dataMap.nchar      = 'string'
MS_SQL.dataMap.nvarchar   = 'string'
MS_SQL.dataMap.ntext      = 'string'

MS_SQL.dataMap.datetime       = 'datetime'
MS_SQL.dataMap.date           = 'datetime'
MS_SQL.dataMap.datetimeoffset = 'datetime'
MS_SQL.dataMap.datetime2      = 'datetime'
MS_SQL.dataMap.smalldatetime  = 'datetime'
MS_SQL.dataMap.time           = 'datetime'

MS_SQL.dataMap.float = 'double'
MS_SQL.dataMap.real = 'double'

local function buildDBSString(r,p)
   local IsString = MakeLookup(string_dict)
   local IsInteger = MakeLookup(integer_dict)
   local IsDouble = MakeLookup(double_dict)
   local IsDateTime = MakeLookup(datetime_dict)
   local function datatype(s)      
      if IsString(s) then return 'string' end
      if IsInteger(s) then return 'integer' end
      if IsDouble(s) then return 'double' end
      if IsDateTime(s) then return 'datetime' end
      error('Unsupported datatype',0)
   end
   
   local t = 'create table'..wrap(r[1].TABLE_NAME)..'\r('
   for j=1,#r do
      t = t..wrap(r[j].COLUMN_NAME)   
      ..datatype(r[j].DATA_TYPE:nodeValue())
      ..',\r'
   end
   for j=1, #p do
      t = t..'key('..p[j].column_name..'),\r'
   end
   t = t..');\r'
   return t
end


local function composeSQL(table2import)
   local sql = {}
   sql[1] = [[SELECT column_name 
   FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE 
   WHERE OBJECTPROPERTY(OBJECT_ID(constraint_name),'IsPrimaryKey') = 1 
   AND table_name = ']]..table2import.."'"
   
   sql[2] = [[SELECT * FROM information_schema.columns 
   where table_name = ']]..table2import.."' ORDER  BY ordinal_position"
   return sql
end

local Import = {}

--[[Import[db.SQL_SERVER] = function(DB, T) 
   local table2import = T
   local Sql = composeSQL(table2import)
   local PKR = DB:query{sql=Sql[1]}      
   local R = DB:query{sql=Sql[2]}   
   defineDatatypes()
   local dbsString = buildDBSString(R,PKR)
   local gname ='mySampleGroup'
   dbsString = dbsString..'\rgroup ['..gname..'] ('..wrap(table2import)..');\r'
   return dbsString   
end]]

local mysql = {}
-- Mappings of native MySQL types to the few built in types
mysql.dataMap = {}
mysql.dataMap.int     = 'integer'
mysql.dataMap.tinyint = 'integer'

mysql.dataMap.varchar    = 'string'
mysql.dataMap.enum       = 'string'
mysql.dataMap.text       = 'string'
mysql.dataMap.longtext   = 'string'
mysql.dataMap.mediumblob = 'string'

mysql.dataMap.datetime  = 'datetime'
mysql.dataMap.date      = 'datetime'
mysql.dataMap.timestamp = 'datetime'

mysql.dataMap.float = 'double'

function mysql.mapType(DataType)
   if (DataType:find("%(")) then
      DataType = DataType:split("(")[1]   
   end
   local DbsType = mysql.dataMap[DataType]
   if not DbsType then
      error('Data type '..DataType..' is not known')      
   end   
   return DbsType
end

function mysql.tableDefinition(DB, Name)
   local TInfo = DB:query{sql="DESCRIBE "..Name}
   local Def = {}
   Def.name = Name
   Def.columns = {}
   for i=1, #TInfo do
      local Column = {}
      Def.columns[i] = Column
      Column.name = TInfo[i].Field
      Column.type = mysql.mapType(TInfo[i].Type:S())
      local Key = TInfo[i].Key
      Column.key = #Key:S() > 0 
   end
   return Def
end

Import[db.MY_SQL] = function(DB, T)
   local TabResults = DB:query{sql="SHOW TABLES"}
   local Tables = {}
   for i=1, #TabResults do
      Tables[#Tables+1] = 
         mysql.tableDefinition(DB, TabResults[i].Tables_in_CRM:S())      
   end
   return Tables
end

local function GenerateDbsTable(Def)
   local R = "create table ["..Def.name .. "](\n"
   local K = ''
   for i=1, #Def.columns do
      local Column = Def.columns[i]
      R = R.."   ["..Column.name..'] '..Column.type..',\n'
      if Column.key then
         K = K.."["..Column.name.."],"
      end
   end
   trace(K)
   if #K > 0 then
      R = R.."   key("..K:sub(1, #K-1)..")\n);\n\n"
   else
      R = R:sub(1, #R-2).."\n);\n\n"
   end
   return R
end

local function Generate(DB)
   if not Import[DB:info().api] then
      error("Data base with API "..DB:info().api.." type is not supported.",2)   
   end
   local Dbs = {}
   local TableDefs = Import[DB:info().api](DB)
   for i=1, #TableDefs do
      Dbs[i] = GenerateDbsTable(TableDefs[i])
   end
   local Result = table.concat(Dbs)
   return Result
end


return Generate