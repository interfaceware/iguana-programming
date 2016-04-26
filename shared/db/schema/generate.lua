local Import = {}

local sqlserver = {}
sqlserver.dataMap = {}
sqlserver.dataMap.tinyint    = 'integer'
sqlserver.dataMap.smallint   = 'integer'
sqlserver.dataMap.int        = 'integer'
sqlserver.dataMap.bigint     = 'integer'
sqlserver.dataMap.numeric    = 'integer'
sqlserver.dataMap.decimal    = 'integer'
sqlserver.dataMap.bit        = 'integer'
sqlserver.dataMap.smallmoney = 'integer'
sqlserver.dataMap.money      = 'integer'

sqlserver.dataMap.varchar    = 'string'
sqlserver.dataMap.char       = 'string'
sqlserver.dataMap.text       = 'string'
sqlserver.dataMap.nchar      = 'string'
sqlserver.dataMap.nvarchar   = 'string'
sqlserver.dataMap.ntext      = 'string'

sqlserver.dataMap.datetime       = 'datetime'
sqlserver.dataMap.date           = 'datetime'
sqlserver.dataMap.datetimeoffset = 'datetime'
sqlserver.dataMap.datetime2      = 'datetime'
sqlserver.dataMap.smalldatetime  = 'datetime'
sqlserver.dataMap.time           = 'datetime'

sqlserver.dataMap.float = 'double'
sqlserver.dataMap.real = 'double'

function sqlserver.mapType(ColumnType)
   local DbsType = sqlserver.dataMap[ColumnType]
   if not DbsType then
      error('Data type '..ColumnType..' is not known')      
   end   
   return DbsType
end

local SQL_SERVER_DESCRIBE=[[SELECT 
    c.name 'Column Name',
    t.Name 'Data type',
    c.max_length 'Max Length',
    c.precision ,
    c.scale ,
    c.is_nullable,
    ISNULL(i.is_primary_key, 0) 'Primary Key'
FROM    
    sys.columns c
INNER JOIN 
    sys.types t ON c.user_type_id = t.user_type_id
LEFT OUTER JOIN 
    sys.index_columns ic ON ic.object_id = c.object_id AND ic.column_id = c.column_id
LEFT OUTER JOIN 
    sys.indexes i ON ic.object_id = i.object_id AND ic.index_id = i.index_id
WHERE
    c.object_id = OBJECT_ID('#TABLENAME#')]]

function sqlserver.tableDefinition(DB, Name)
   local Sql = SQL_SERVER_DESCRIBE:gsub("#TABLENAME#", Name)
   local Cols = DB:query{sql=Sql}  
   local Def = {}
   Def.name = Name
   Def.columns = {}
   for i=1, #Cols do
      local Column = {}
      Def.columns[i] = Column
      Column.name = Cols[i]["Column Name"]
      Column.type = sqlserver.mapType(Cols[i]["Data type"]:S())
      Column.key = Cols[i]["Primary Key"]:S() ~= '0' 
     -- local Key = TInfo[i].Key
     -- Column.key = #Key:S() > 0 
   end
   return Def
end

Import[db.SQL_SERVER] = function(DB, T)
   local TabResults = DB:query{sql="SELECT * FROM sys.Tables"}
   local Tables = {}
   for i=1, #TabResults do
      Tables[#Tables+1] = sqlserver.tableDefinition(DB, TabResults[i].name:S()) 
   end
   return Tables
end

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