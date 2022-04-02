-- 创建时间:2018-11-20
-- 本地数据库
local basefunc = require "Game.Common.basefunc"


LocalDatabase = {}
local IndexFile = "index.txt"
local function getBasePath()
    local path = AppDefine.LOCAL_DATA_PATH .. "/" .. MainModel.UserInfo.user_id .. "/"
    return path
end
local function getTablePath(tablename)
    local path = getBasePath() .. tablename
    return path
end
local function getFilePath(tablename, key)
    local path = getTablePath(tablename) .. "/" .. key
    return path
end

--解析数据
local function parseData(bdata, isreturn)
    local code
    if isreturn then
        code = bdata
    else
        code = "return " .. bdata
    end
    local ok, ret = xpcall(function ()
        local data = loadstring(code)()
        if type(data) ~= 'table' then
            data = {}
            print("parseEmailData error : {}")
        end
        return data
    end
    ,function (err)
        local errStr = "parseEmailData error : "..bdata
        print(errStr)
        print(err)
    end)

    if not ok then
        ret = {}
    end

    return ret or {}
end

local function SaveLocalData(tablename, key, data)
    local path = getTablePath(tablename)
    if not Directory.Exists(path) then
        Directory.CreateDirectory(path)
    end
    local filePath = getFilePath(tablename, key)
    local descStr = basefunc.safe_serialize(data)
    if descStr then
        File.WriteAllText(filePath, descStr)
    else
    	dump(data, "<color=red>存储数据为空</color>")
    	print("*****filePath=" .. filePath)
    end
end
-- 保存数据
function LocalDatabase.SaveData(tablename, key, data)
	-- tablename的文件夹下有唯一一个索引txt，每个索引对应一个数据txt
	local dd = LocalDatabase.LoadData(tablename, IndexFile)
	if dd and next(dd) then
		local b = false
	    for k,v in ipairs(dd) do
	    	if v == key then
	    		b = true
	    		break
	    	end
	    end
	    if not b then
			dd[#dd + 1] = key
			SaveLocalData(tablename, IndexFile, dd)
	    end
	else
		dd = {}
		dd[1] = key
		SaveLocalData(tablename, IndexFile, dd)
	end
	SaveLocalData(tablename, key, data)
end
-- 保存数据
function LocalDatabase.SaveDataDict(tablename, data)
	local dd1 = {}
	for k,v in pairs(data) do
		dd1[k] = 1
		SaveLocalData(tablename, k, v)
	end
	local dd = LocalDatabase.LoadData(tablename, IndexFile)
	if dd and next(dd) then
		for k,v in ipairs(dd) do
			if not dd1[v] then
				dd1[v] = 1
			end
		end
	end
	dd = {}
	for k,v in pairs(dd1) do
		dd[#dd + 1] = k
	end
	SaveLocalData(tablename, IndexFile, dd)
end

-- 读取某一文件的数据
function LocalDatabase.LoadData(tablename, key)
    local path = getTablePath(tablename)
    if not Directory.Exists(path) then
        Directory.CreateDirectory(path)
    end
    local filePath = getFilePath(tablename, key)
    if not File.Exists(filePath) then
        return
    end
    local allID = File.ReadAllText(filePath)
    if not allID or allID == "" then
        return
    end
    local dd = parseData(allID)
    return dd
end
-- 读取所有数据，除了index.txt
function LocalDatabase.LoadAllData(tablename)
	local dd = LocalDatabase.LoadData(tablename, IndexFile)
	local dict = {}
	if dd and next(dd) then
	    for _,v in ipairs(dd) do
	    	dict[v] = LocalDatabase.LoadData(tablename, v)
	    end
	end
    return dict
end

-- 读取配置文件，返回lua表
function LocalDatabase.LoadFileDataToTable(filepath)
    if not File.Exists(filepath) then
        print("<color=blue>no find file:" .. filepath .. "</color>")
        return
    end
    local allID = File.ReadAllText(filepath)
    if not allID or allID == "" then
        return
    end
    local dd = parseData(allID, true)
    return dd
end

-- 清空数据,不删除文件
function LocalDatabase.ClearData(tablename, key)
	local path = getTablePath(tablename)
    if not Directory.Exists(path) then
        Directory.CreateDirectory(path)
    end
    local filePath = getFilePath(tablename, key)
    local descStr = ""
    if descStr then
        File.WriteAllText(filePath, descStr)
    else
    	print("*****filePath=" .. filePath)
    end
end

-- 删除文件
function LocalDatabase.DeleteData(tablename, key)
	local path = getTablePath(tablename)
    if not Directory.Exists(path) then
        Directory.CreateDirectory(path)
    end
    local filePath = getFilePath(tablename, key)
    if filePath then
        File.Delete(filePath)
    else
    	print("*****filePath=" .. filePath)
    end
end