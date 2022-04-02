--
-- Author: lyx
-- Date: 2018/3/10
-- Time: 17:10
-- 说明：常用功能函数
--

local basefunc = {}

local basefunc = {
	path={},
	math={},
	physics={},
	string = {},
	debug = {},
	table = {}
}

local lm = math
local lstr_format = string.format
local oneday_sec = 24 * 60 * 60 --一天的秒数
local meta_weak_key = {__mode="k" }
local meta_weak_value = {__mode="v" }
local meta_weak_kv = {__mode="kv" }
local unpack = table.unpack

----------------------------
-- 通用函数库

local typeinfo_map = {}

-- 创建一个类
function basefunc.class(base,name)
	local cls = {}
	local obj_meta = {__index=cls}
	if base then
		cls.super=base
		setmetatable(cls,{__index=base})
	end

	function cls.New(...)
		local ret = setmetatable({class=cls},obj_meta)

		if cls.ctor then
			ret:ctor(...)
		end

		return ret
	end

	cls.typeinfo = {class=cls,name=name }

	if name then

		if typeinfo_map[name] then
			print(string.format("!!!! warning:class name '%s' is conflict!",name))
		end

		typeinfo_map[name] = cls.typeinfo
	end

	return cls
end

-- 得到父类
-- 参数 obj ： 可以是类 或 对象
function basefunc.parent(obj)

	if not obj then return nil end

	local ti = rawget(obj,"typeinfo")

	-- obj 是类
	if ti then
		return rawget(ti.cls,"super")
	end

	-- obj 是对象
	local cls = rawget(obj,"class")
	return cls and rawget(cls,"super")
end

-- 判断类 或 对象 是否 派生自 指定的类
-- 参数 obj ： 可以是类 或 对象
-- 参数 class ： 可以是类 、 对象 、或类名
function basefunc.iskindof(obj,class)

	local classname = nil
	if type(class) == "string" then
		classname = class
		class = basefunc.classbyname(class)
	else
		classname = basefunc.classname(class)
	end

	-- obj 是不是类
	local ti = rawget(obj,"typeinfo")
	local objcls = ti and obj

	-- obj 是类
	if not objcls then
		objcls = rawget(obj,"class")
		if not objcls then
			return false
		end

		ti = rawget(objcls,"typeinfo")
	end

	-- 逐级查找
	while objcls and ti do

		if objcls == class or ti.name == classname then
			return true
		end

		-- 继续找 父类
		objcls = rawget(objcls,"super")
		ti = rawget(objcls,"typeinfo")
	end

	return false
end

-- 根据名字得到类
function basefunc.classbyname(name)
	local t = typeinfo_map[name]
	return t and t.class
end

-- 设置类的别名，返回一个派生的类
function basefunc.classalias(name,alias)
	local cls = basefunc.classbyname(name)
	if not cls then return nill end

	return basefunc.class(cls,alias)
end

-- 得到类名
-- 参数 name ： 可以是类 、 对象 、或类名
function basefunc.classname(obj)
	if not obj then return nil end

	if type(obj) == "string" then return obj end

	if type(obj) ~= "table" then return nil end

	local ti = rawget(obj,"typeinfo")

	-- obj 是类
	if ti then
		return ti.name
	end

	-- obj 是对象
	local cls = rawget(obj,"class")
	ti = cls and rawget(cls,"typeinfo")
	return ti and ti.name
end

-- 根据参数创建对象 or 空表
function basefunc.create(creator,...)

	if not creator then
		return {}
	end

	if "function" == type(creator) then
		return creator(...)
	end

	if "string" == type(creator) then
		return basefunc.classbyname(creator).new(...)
	end

	if "table" == type(creator) and creator.new then
		return creator.new(...)
	end

	return nil
end


function basefunc.weakValue(t)
	return setmetatable(t or {}, meta_weak_value)
end

function basefunc.weakKey(t)
	return setmetatable(t or {}, meta_weak_key)
end

function basefunc.weakKV(t)
	return setmetatable(t or {}, meta_weak_kv)
end

--[[
    -- 序列化值为 lua 字符串
	其结果格式
	1.value是字符串：
	".........."

	2.value是数字：
	1

	3.value是table没有环
	do
		local ret = {....}
		return ret
	end

	4.value是table带有环
	do
		local ret = {....}
		ret.a[1].c = ret.a
		ret.a[2].b[2] = ret.a[3]
		return ret
	end
--]]
function basefunc.serialize(value)

	if type(value)~="table" then
		return type(value)=="string" and "\""..value.."\"" or tostring(value)
	end

	local mark={}
	local assign={}
	local loopRef = false

	local function ser_table(tbl,parent)
		mark[tbl]=parent
		local tmp={}
		for k,v in pairs(tbl) do
			local key= type(k)=="number" and "["..k.."]" or k
			if type(v)=="table" then
				local dotkey= parent..(type(k)=="number" and key or "."..tostring(key))
				if mark[v] then
					loopRef = true
					table.insert(assign,dotkey.."="..mark[v])
				else
					table.insert(tmp, tostring(key).."="..ser_table(v,dotkey))
				end
			else
				table.insert(tmp, tostring(key).."="..(type(v)=="string" and "\""..v.."\"" or tostring(v)))
			end
		end
		return "{"..table.concat(tmp,",").."}"
	end

	local str = ser_table(value,"ret")
	if loopRef then		-- 有循环引用，则需要赋值
		return "do local ret="..str..table.concat(assign," ").." return ret end"
	else
		return str		-- 无循环引用，直接返回
	end
end


--[[
	安全的序列化 处理需要再加载的数据代码使用
	不支持循环引用
--]]
function basefunc.safe_serialize(value)

    if type(value)~="table" then
        return type(value)=="string" and "\""..value.."\"" or tostring(value)
    end

    local mark={}
   
    local function v2s(str)

        --检测两个]
        local ret = str
        local num = 0
        ret , num = string.gsub(str,"]]","] ]")
        while num>0 do
            ret , num = string.gsub(ret,"]]","] ]")
        end

        --最后一个
        if string.sub(ret,-1,-1) == "]" then
            ret = ret .. " "
        end
        
        ret = "[[" .. ret .. "]]"

        return ret
    end

    local function t(n)
        return string.rep("\t",n)
    end
    local function ser_table(tbl,parent,lv)
        mark[tbl]=parent
        local tmp={}
        for k,v in pairs(tbl) do
            local key= type(k)=="number" and "["..k.."]" or k
            if type(v)=="table" then
                local dotkey= parent..(type(k)=="number" and key or "."..key)
                if mark[v] then
                    error("error!!! safe_serialize args has loopRef")
                    return "error!!!"
                else
                    table.insert(tmp, t(lv+1)..key.."="..ser_table(v,dotkey,lv+1))
                end
            else
                table.insert(tmp, t(lv+1)..key.."="..(type(v)=="string" and v2s(v) or tostring(v)))
            end
        end
        return "\n"..t(lv).."{\n"..table.concat(tmp,",\n").."\n"..t(lv).."}"
    end
    
    local str = ser_table(value,"ret",0)
    return str
end


-- 成员函数 转换为普通函数
function basefunc.handler(obj, method)
	if not obj or not method then
		error("handle:obj or method is nil",2)
	end

    return function(...)
        return method(obj, ...)
    end
end

-- 浅拷贝
function basefunc.copy(value)

    if type(value) ~= "table" then
        return value
    end

	local ret = {}
	for k, v in pairs(value) do
		ret[k] = v
	end
	return ret
end

-- 合并表内容
-- 参数 dest 可为 nil
-- 返回合并后的表
function basefunc.merge(src,dest)

	dest = dest or {}
	for k,v in pairs(src) do
		dest[k] = v
	end

	return dest
end

-- 计算表中的 key 数量
function basefunc.key_count(_t)
	local _count = 0
	for _,_ in pairs(_t) do
		_count = _count + 1
	end

	return _count
end

function basefunc.is_array_table(t)
    if type(t) ~= "table" then
        return false
    end

    local n = #t
    for i,v in pairs(t) do
        if type(i) ~= "number" then
            return false
        end

        if i > n then
            return false
        end
    end

    return true
end

-- 将 value 转换成一个可读的调试字符串
function basefunc.tostring( value, recMax )

	-- by lyx
	if type(value) ~= "table" then
		return tostring(value)
	end

	recMax = recMax or 3
	local stringBuffer = {}

	local function __tab_string( count )
		local tabl = {}
		for i = 1, count do
			table.insert( tabl, "  " )
		end
		return table.concat( tabl, "" )
	end

	local function __table_to_string( tableNow, recNow )

		-- by lyx
		if value == nil then return "nil" end

		if( recNow > recMax ) then
			table.insert( stringBuffer, tostring( tableNow ) .. ",\n" )
			return
		end

		table.insert( stringBuffer, "{\n" )
		for k, v in pairs( tableNow ) do
			table.insert( stringBuffer, __tab_string(recNow) .. tostring( k ) .. "=" )
			if( "table" ~= type(v) ) then
				table.insert( stringBuffer, tostring( v ) .. ",\n" )
			else
				__table_to_string( v, recNow + 1 )
			end
		end
		table.insert( stringBuffer, __tab_string(recNow-1) .. "},\n" )
	end

	__table_to_string( value, 1 )
	return table.concat( stringBuffer, "" )
end

function basefunc.table_to_prettyjsonstring( aTable, recMax )
	recMax = recMax or 20
	local stringBuffer = {}
	local function __tab_string( count )
		if( not count ) then
			return ""
		else
			return string.rep( "  ", count )
		end
	end
	local function __validateStr( str )
		local s = str
		s = string.gsub(s,'\\','\\\\')
		s = string.gsub(s,'"','\\"')
		s = string.gsub(s,"'","\\'")
		s = string.gsub(s,'\n','\\n')
		s = string.gsub(s,'\t','\\t')
		return s
	end
	local function __innert( tableNow, recNow )
		if( recNow > recMax ) then
			table.insert( stringBuffer, '"'..__validateStr( tostring(tableNow)..'"' ) )
			return
		end
		local isArray = basefunc.is_array_table( tableNow )
		local lastStr = stringBuffer[#stringBuffer]
		if( lastStr and lastStr[#lastStr] ~= "\n") then
			stringBuffer[#stringBuffer+1] = "\n"
		end

		if( isArray ) then
			stringBuffer[#stringBuffer+1] = __tab_string(recNow).."[\n"
			for i, v in ipairs( tableNow ) do
				if( "table" == type(v) ) then
					__innert( v, recNow+1 )
				else
					local valueStr = tostring(v)
					if( type(v) == "string" ) then
						valueStr = '"'..__validateStr( valueStr )..'"'
					end
					stringBuffer[#stringBuffer+1] = __tab_string(recNow+1)..valueStr..",\n"
				end
			end
		else
			table.insert( stringBuffer, __tab_string(recNow).."{\n" )
			for k, v in pairs( tableNow ) do
				local keyStr = tostring(k)--key 不做__validateStr
				stringBuffer[#stringBuffer+1] = __tab_string(recNow+1) .. string.format( [["%s" : ]], keyStr )
				if( "table" == type(v) ) then
					__innert( v, recNow+1 )
				else
					local valueStr = tostring( v )
					if( type(v) == "string" ) then
						valueStr = '"'..__validateStr( valueStr )..'"'
					end
					stringBuffer[#stringBuffer+1] = valueStr..",\n"
				end
			end
		end

		local lastStr = stringBuffer[#stringBuffer]
		stringBuffer[#stringBuffer] = string.sub( lastStr, 1, #lastStr-2 ).."\n"
		if( isArray ) then
			stringBuffer[#stringBuffer+1] = __tab_string(recNow).. "],\n"
		else
			table.insert( stringBuffer, __tab_string(recNow) .. "},\n" )
		end
	end

	__innert( aTable, 0 )
	local lastStr = stringBuffer[#stringBuffer]
	stringBuffer[#stringBuffer] = string.sub( lastStr, 1, #lastStr-2 ).."\n"
	return table.concat( stringBuffer )
end



-- 深拷贝
function basefunc.deepcopy(value)

    if type(value) ~= "table" then
        return value
    end

	-- 已拷贝对象
	local copedSet = {}

	local function _copy(src_)

		local ret = {}
		copedSet[src_] = ret

		for k, v in pairs(src_) do
			if type(v) ~= "table" then
				ret[k] = v
			else
				if copedSet[v] then
					-- 重复表 仅仅引用
					ret[k] = copedSet[v]
				else
					ret[k] = _copy(v)
				end
			end
		end
		return ret
	end

	return _copy(value)
end

-- update 时间同步
-- 参数：
--	time 本地时间
--	refer 参考时间，如果 为 nil ，则不需要同步
--	speed 同步速度，每秒 贴近 时间
-- 返回： 新的本地时间,参考时间
local math_min = math.min
function basefunc.sync_update(dt,time,refer,speed)

	if not refer then
		return time+dt,nil
	end

	-- 修正量：不能超过 1 秒，否则会出现时间倒退
	local corr = math_min((speed or 0.5),1) * dt

	-- 差异
	local diff = refer - time

	if diff > 0 then
		if corr >= diff then
			return refer + dt,nil				-- 下次无需再修正
		else
			return time + dt + corr,refer + dt	-- 追 refer 时间
		end
	elseif diff < 0 then
		if corr >= -diff then
			return refer + dt,nil				-- 下次无需再修正
		else
			return time + dt - corr,refer + dt	-- 等 refer 时间
		end
	end
end

-- 删除多个表元素：从 pos 开始 n 个
function basefunc.tremove(t,pos,n)
	if n == 0 then return end

	for i=pos,999999,1 do
		t[i]=t[i+n]
		if not t[i] and not t[i+1] then
			break
		end
	end
end

-- 安全的得到字典 t 中的值
function basefunc.getitem(t,k,creator,...)
	local v = t[k]
	if v then
		return v
	else
		v = basefunc.create(creator,...)
		t[k] = v
		return v
	end
end

function basefunc.dump(value,name,...)
	if not AppDefine.IsDebug then
		return
	end
	if name then
		print ("---- dump:" .. name,...)
	end

	--print(basefunc.serialize(value))
	print(basefunc.tostring(value,math.huge))
end

function basefunc.array_partial( array, predicate, iBegin, iEnd )
	local function  __swap( idx1, idx2 )
		local temp = array[idx1]
		array[idx1] = array[idx2]
		array[idx2] = temp
	end
	if iBegin >= iEnd then return  end
	local i = iBegin
	local j = iEnd
	repeat
		if i >= j then
			break
		end
		repeat
			if i == j then break end
			if not predicate(array[i]) then break end
			i = i + 1
		until false
		repeat
			if i == j then break end
			if predicate(array[j]) then break end
			j = j-1
		until false
		__swap( i, j )
	until false
	assert( i == j )
	if predicate(array[i]) then
		return i+1
	else
		return i
	end
end

local function __test_array_partial()
	local array = {}
	for i = 1, 10000 do
		array[#array+1] = math.random( 1, 10 )
	end

	local function __predicate( item )
		return item < 5
	end

	local mid = basefunc.array_partial( array, __predicate, 1, #array )
	for i = 1, mid-1 do
		print( "premid:", array[i] )
		assert( __predicate(array[i]) )
	end
	for i = mid, #array do
		print( "aftmid:", array[i] )
		assert( not __predicate(array[i]) )
	end
end

--转换成还有多少天
function basefunc.get_today_id(now_time , _start_time)
	local start_time = _start_time or 1514736000
  	return math.floor( (now_time - start_time) / 86400)
end


--[[
	将一个数组给定的区间随机打乱,[iBegin, iEnd]
	@iBegin 起始下标，默认为1
	@iEnd 结束下标，默认 = iBegin
]]
function basefunc.array_shuffle( array, iBegin, iEnd )
	assert( array )
	iBegin = iBegin or 1
	iEnd = iEnd or iBegin
	for i = iBegin, iEnd do
		local randomIdx = math.random( iBegin, iEnd )
		local temp = array[iBegin]
		array[iBegin] = array[randomIdx]
		array[randomIdx] = temp
	end
end

function basefunc.array_filter_i( array, iBegin, iEnd, predicate )
	local newArray = {}
	for i = iBegin, iEnd do
		if not predicate( array[i] ) then
			newArray[#newArray+1] = array[i]
		end
	end
	return newArray
end

function basefunc.array_filter( array, predicate )
	return basefunc.array_filter_i(array,1,#array,predicate)
end

function basefunc.array_map_i(array,iBegin,iEnd,func)
	local newArray = {}
	for i = iBegin, iEnd do
		newArray[#newArray+1] = func( array[i] )
	end
	return newArray
end

function basefunc.array_map( array, func  )
	return basefunc.array_map_i(array,1,#array,func)
end

----------------------------
-- datable 数据表格


basefunc.datable = basefunc.class()

function basefunc.datable:ctor()

	-- 列名数组
	self.columns = {}

	-- 列名 => 列序号
	self.colindex = {}

	-- 数据行
	self.rows = {}

	-- 行拷贝函数
	self._rowCopyRow = function(selfRow)
		return self:copyrow(selfRow)
	end

	-- 行的元表：自动判断 下标 or 名称 方式的访问
	self._rowmeta = {
		__index = function(row,name)
			if "number" == type(name) then
				return rawget(row,name)
			else
				if "copyrow" == name then
					return self._rowCopyRow
				else
					return rawget(row,self.colindex[name])
				end
			end
	end}
end

function basefunc.datable:addcolumn(name)
	table.insert(self.columns,name)

	self.colindex[name] = #self.columns
end

-- 加入行：自动识别 字典和数组，字典优先
function basefunc.datable:addrow(row)
	local rowdata = {}
	for icol,ncol in ipairs(self.columns) do
		table.insert(rowdata,row[ncol] or row[icol])
	end

	table.insert(self.rows,setmetatable(rowdata,self._rowmeta))
end

-- 拷贝一行
function basefunc.datable:copyrow(row)
	local rowdata = {}
	for i,name in ipairs(self.columns) do
		rowdata[name] = row[i]
	end

	return rowdata
end

-- 拷贝为普通lua表
function basefunc.datable:copydata()
	local rows = {}

	for i,row in ipairs(self.rows) do
		rows[#rows + 1] = self:copyrow(row)
	end

	return rows
end


----------------------------
-- datagrid 按行列查询的数据网格


basefunc.datagrid = basefunc.class()

function basefunc.datagrid:ctor(head,data)

	self.head = head

	self._colIndex = {}
	self._rowIndex = {}

	self._rows = data

	for i,colname in ipairs(head) do
		self._colIndex[colname] = i
	end

	for i,row in ipairs(data) do
		self._rowIndex[row[1]] = i
	end

end

function basefunc.datagrid:getcell(rowName,colName)
	local irow = self._rowIndex[rowName]
	local icol = self._colIndex[colName]

	return irow and icol and self._rows[irow][icol]
end

function basefunc.datagrid:dump()
	for _,row in ipairs(self._rows) do
		for _,colname in ipairs(self.head) do
			print(row[1],colname,self:getcell(row[1],colname))
		end
	end

end

----------------------------
-- queue 队列（仅允许从首尾增删）


basefunc.queue = basefunc.class()


function basefunc.queue:ctor()

	self._front = 0
	self._back = -1

end

function basefunc.queue:size()
	return self._back-self._front +1
end

-- 是否为空
function basefunc.queue:empty()
	return self._front > self._back
end

function basefunc.queue:clear()
	if self:empty() then return end

	for i=self._front,self._back do
		self[i] = nil
	end

	self._front = 0
	self._back = -1
end

function basefunc.queue:push_front(obj)
	self._front = self._front - 1
	self[self._front] = obj
end

function basefunc.queue:push_back(obj)
	self._back = self._back + 1
	self[self._back] = obj
end

function basefunc.queue:front()

	return self[self._front]
end

function basefunc.queue:back()
	return self[self._back]
end

function basefunc.queue:clear()
	if self:empty() then return end

	for i=self._front,self._back do
		self[i] = nil
	end

	self._front = 0
	self._back = -1
end

function basefunc.queue:pop_front()
	if self._front > self._back then return nil end

	local ret = self[self._front]
	self[self._front] = nil
	self._front = self._front + 1
	return ret
end

function basefunc.queue:pop_back()
	if self._front > self._back then return nil end

	local ret = self[self._back]
	self[self._back] = nil
	self._back = self._back - 1
	return ret
end


-- 迭代器
function basefunc.queue:values()
	local i = self._front - 1
	return function() i = i + 1 return self[i] end
end

-- 反向迭代器
function basefunc.queue:rvalues()
	local i = self._back + 1
	return function() i = i - 1 return self[i] end
end

-- 清空
function basefunc.queue:clear()
	while self:pop_back() do end
    self._front = 0
	self._back = -1
end

-------------------------------
-- list 链表（允许从任意位置增删）

basefunc.list = basefunc.class()


function basefunc.list:ctor()

	self._front = nil
	self._back = nil

end

-- 是否为空
function basefunc.list:empty()
	return nil == self._front
end

-- 清空
function basefunc.list:reset()
	self._front = nil
	self._back = nil
end

-- 计算长度，注意：采用遍历的方法统计
function basefunc.list:calc_size()

	local cur = self._front
	local count = 0
	while cur do
		count = count + 1
		cur=cur.next
	end

	return count
end

-- 计算尺寸是否大于 给定的数值
function basefunc.list:greater(size)
	local cur = self._front
	local count = 0
	while cur do
		count = count + 1

		if count > size then
			return true
		end

		cur=cur.next
	end

	return false
end

function basefunc.list:push_front(obj)
	local cur = self._front
	self._front = {obj,prev=nil,next=cur}
	if cur then
		cur.prev = self._front
	else
		self._back = self._front
	end
end

function basefunc.list:push_back(obj)
	local cur = self._back
	self._back = {obj,prev=cur,next=nil}
	if cur then
		cur.next = self._back
	else
		self._front = self._back
	end
end

-- 将另一个 list 合并到前面，other 将被清空
function basefunc.list:merge_front(other)

	if other and not other:empty() then
		local cur = self._front
		self._front = other._front
		if cur then
			cur.prev = other._back
			other._back.next = cur
		else
			self._back = other._back
		end

		other._front = nil
		other._back = nil
	end
end

-- 将另一个 list 合并到后面，other 将被清空
function basefunc.list:merge_back(other)

	if other and not other:empty() then

		local cur = self._back
		self._back = other._back
		if cur then
			cur.next = other._front
			other._front.prev = cur
		else
			self._front = other._front
		end

		other._front = nil
		other._back = nil
	end
end

function basefunc.list:front()

	return self._front and self._front[1]
end

function basefunc.list:back()
	return self._back and self._back[1]
end

-- 得到内部迭代器
function basefunc.list:front_item()
	return self._front
end
function basefunc.list:back_item()
	return self._back
end

function basefunc.list:pop_front()
	if not self._front then return nil end

	local ret = self._front[1]

	self:erase(self._front)

	return ret
end

function basefunc.list:pop_back()
	if not self._back then return nil end

	local ret = self._back[1]

	self:erase(self._back)

	return ret
end

function basefunc.list:erase(item)

	-- 更新前一个
	if item.prev then
		item.prev.next = item.next
	else
		self._front = item.next
	end

	-- 更新下一个
	if item.next then
		item.next.prev = item.prev
	else
		self._back = item.prev
	end

	-- 返回下一个
	return item.next

	-- 移除引用
	-- 这个可能也正在 闭包中使用(2014-4-26) item[1] = nil

	-- （★★★ 注意，绝对不能移除 next,prev，这个 item 如果在迭代器闭包中使用 将导致遍历终止；）
--	item.next = nil
--	item.prev = nil
end

-- 插入元素
function basefunc.list:insert(obj,where)
	if where then
		local objItem = {obj,prev=where.prev,next=where}
		where.prev = objItem
		if objItem.prev then
			objItem.prev.next = objItem
		end
	else
		self:push_back(obj)
	end
end

-- 迭代器
function basefunc.list:values()
	local i = {next=self._front}
	return function() i = i.next return i and i[1] end
end

-- 反向迭代器
function basefunc.list:rvalues()
	local i = {prev=self._back}
	return function() i = i.prev return i and i[1] end
end

-- 迭代器（返回 item,value）
function basefunc.list:pairs()
	local i = {next=self._front}

	return function()
		i = i.next
		if i then
			return i,i[1]
		else
			return nil,nil
		end
	end
end

-- 反向迭代器（返回 item,value）
function basefunc.list:rpairs()
	local i = {prev=self._back}
	return function()
		i = i.prev
		if i then
			return i,i[1]
		else
			return nil,nil
		end
	end
end


----------------------------
-- 链表 和 映射的组合，支持 任意位置插入 及 快速查找、删除
-- 内部 链表 通过 basefunc.list 实现
-- 使用注意： 所有修改的方法都必须调用 listmap 的成员；读取、查询、遍历的 方法可以直接 调用 list 或 map 成员中的方法

basefunc.listmap = basefunc.class()

function basefunc.listmap:ctor()

	-- 数据链表： value
	self.list = basefunc.list.new()

	-- 键映射： key => listitem
	self.map = {}

end

-- 是否为空
function basefunc.listmap:empty()
	return nil == self.list._front
end

function basefunc.listmap:push_front(key,value)

	assert(key,"listmap key is nil!")
	assert(not self.map[key],"listmap key is conflicted !")

	self.list:push_front(value)
	local item = self.list:front_item()
	item[2] = key	-- 记录键的标记
	self.map[key] = item
end

function basefunc.listmap:push_back(key,value)
	assert(key,"listmap key is nil!")
	assert(not self.map[key],"listmap key is conflicted !")

	self.list:push_back(value)
	local item = self.list:back_item()
	item[2] = key	-- 记录键的标记
	self.map[key] = item
end

function basefunc.listmap:insert(key,value,where)
	assert(key,"listmap key is nil!")
	assert(not self.map[key],"listmap key is conflicted !")

	self.list:insert(value,where)
	where.prev[2] = key	-- 记录键的标记
	self.map[key] = where.prev
end

function basefunc.listmap:erase(key)
	local item = self.map[key]

	if item then
		self.list:erase(item)
		self.map[key] = nil
	end
end

function basefunc.listmap:at(key)
	local item = self.map[key]
	return item and item[1]
end

function basefunc.listmap:set(key,value)
	local item = self.map[key]
	if item then
		item[1] = value
	end
end

function basefunc.listmap:pop_front()

	local item = self.list:front_item()
	self.map[item[2]] = nil
	self.list:pop_front()

	-- 返回 key , value
	return item[2],item[1]
end

function basefunc.listmap:pop_back()

	local item = self.list:back_item()
	self.map[item[2]] = nil
	self.list:pop_back()

	-- 返回 key , value
	return item[2],item[1]
end

----------------------------
-- 数组 和 映射的组合，支持 快速从数组尾部增加 和 删除
-- 内部 数组 采用 lua 表
-- 使用注意：如果 是 从数组中间 插入 或删除 复杂度为 O(n)

basefunc.vectormap = basefunc.class()

function basefunc.vectormap:ctor()

	-- 数组
	self.vector = {}

	-- 键映射： key => 下标
	self.map = {}

end

-- 是否为空
function basefunc.vectormap:empty()
	return self.vector[1] ~= nil
end

function basefunc.vectormap:push_back(key,value)

	assert(key,"listmap key is nil!")
	assert(not self.map[key],"listmap key is conflicted !")

	self.vector[#self.vector + 1] = value
	self.map[key] = #self.vector
end

function basefunc.vectormap:insert(key,value,index)
	assert(key,"listmap key is nil!")
	assert(not self.map[key],"listmap key is conflicted !")

	if index > #self.vector then
		self:push_back(key,value)
	elseif index > 0 then
		table.insert(self.vector,index,value)
		for _k,_i in pairs(self.map) do
			if _i >= index then
				self.map[_k] = _i + 1
			end
		end

		self.map[key] = index
	end
end

function basefunc.vectormap:erase_at(index)

	if index and index > 0 and index <= #self.vector then

		table.remove(self.vector,index)
		for _k,_i in pairs(self.map) do
			if _i == index then
				self.map[_k] = nil
			elseif _i > index then
				self.map[_k] = _i - 1
			end
		end
	end
end

function basefunc.vectormap:erase(key)
	self:erase_at(self.map[key])
end


----------------------------
-- 共享布尔对象：1个以上的对象设置为 true ，则为 true ；各对象采用名称标识
-- 可以链接 信号，当值变化为 false 时，能收到信号

basefunc.sharebool = basefunc.class()
function basefunc.sharebool:ctor()
	self._objects = {}
	self._count = 0

	self._signal = nil
end

-- 如果 name 不为 nil ，则判断该名字设否已设置
function basefunc.sharebool:value(name)
	return name and self._objects[name] or (self._count > 0)
end

-- 按名字设置
function basefunc.sharebool:set(name)
	if not self._objects[name] then
		self._count = self._count + 1
		self._objects[name] = true
	end
end

-- 按名字清除
function basefunc.sharebool:clear(name)
	if self._objects[name] then
		self._count = self._count - 1
		self._objects[name] = nil

		-- 第一次变为 false ，触发事件
		if self._signal and 0 == self._count then
			self._signal:trigger(false)
		end
	end
end

-- 重置为 false
function basefunc.sharebool:reset()
	self._objects = {}
	self._count = 0
end

-- 连接事件
function basefunc.sharebool:bind(obj,func)
	if not self._signal then
		self._signal = basefunc.signal.new()
	end

	self._signal:bind(obj,func)
end

-- 断开事件
function basefunc.sharebool:unbind(obj)
	if self._signal then
		self._signal:unbind(obj)
	end
end


----------------------------
-- 信号对象，允许对象 bind 上来，以便收取消息

basefunc.signal = basefunc.class()

function basefunc.signal:ctor()

	self._recviers = basefunc.listmap.new()

end

--[[
-- 将函数连接到 信号
-- 参数 ：
	obj		- 对象、字符串等可作为键的变量；此参数可选，如果不需要 unbind， 则可以不提供
	func	- 函数
--]]
local _next_obj_key = 0
function basefunc.signal:bind(obj,func)

	if not func then
		_next_obj_key = _next_obj_key + 1
		self:bind("_obj_key_" .. tostring(_next_obj_key),obj)
	else

		if not obj then
			error("signal: obj is nil!",2)
		end

		if not func then
			error("signal: func is nil!",2)
		end

		assert(func,"bind func is nil!")

		if self._recviers.map[obj] then
			self._recviers:set(obj,func)
		else
			self._recviers:push_back(obj,func)
		end
	end

end

-- 断开事件连接
function basefunc.signal:unbind(obj)

	self._recviers:erase(obj)

end

-- 是否空的（没有连接者）
function basefunc.signal:empty()
	return self._recviers.list:empty()
end

-- 修改已链接的函数（作为对调用次数敏感的某些特殊应用）
function basefunc.signal:alterconnect(obj,funcNew)
	self._recviers:set(obj,funcNew)
end

-- 触发事件
function basefunc.signal:trigger(...)

	local cur = self._recviers.list:front_item()
	while cur do
		cur[1](...)
		cur = cur.next
	end
end

-- 连接器对象
local signalConnector = basefunc.class()

-- 通过 ‘连接器’ 连接，断开时使用该‘连接器’对象
-- 此方法适用于 不方便提供对象 key 的情景
function basefunc.signal:withconnector(func)
	return signalConnector.new(self,func)
end

function signalConnector:ctor(signal,func)

	self._signal = signal
	signal:bind(self,func)
end

function signalConnector:alterconnect(funcNew)
	self._signal:alterconnect(self,funcNew)

	return self
end

function signalConnector:unbind()
	self._signal:unbind(self)
end

----------------------------
-- 消息分发器
-- 说明：
--	1、将消息按 名字分发给不同的对象
--	2、如果消息被多个对象处理，则第一个不返回 nil 的处理者的值会被返回。

basefunc.dispatcher = basefunc.class()

function basefunc.dispatcher:ctor()

	self._recviers={} 			-- 已连接的接收者，key=object ,value=msgtable
	self._namemap={}			-- 映射：消息名字 -> 接收者的列表, key=name,value=listmap(key=object,value=func)

end

function basefunc.dispatcher:dump(info)
	print(info or ("======== basefunc.dispatcher(" .. tostring(self) .. ") ========="))
	print("_recviers:")
	for k,v in pairs(self._recviers) do
		print("","obj=" .. tostring(k) .. ",msgtable="..tostring(v))
		for name,func in pairs(v) do
			print("","",name,func)
		end
	end
	print("_namemap:")
	for name,listmap in pairs(self._namemap) do
		print("",name)
		local cur = listmap.list:front_item()

		while cur do
			print("","","fun=" .. tostring(cur[1]),"obj=" .. tostring(cur[2]))
			cur = cur.next
		end

	end

end

--[[
-- 将函数连接到 信号
-- 参数 ：
	obj			- 对象
	msgtable	- 消息表，其中包含消息处理函数
--]]
function basefunc.dispatcher:register(obj,msgtable)

	if self._recviers[obj] then
		self:unregister(obj)
	end

	self._recviers[obj] = msgtable

	print("add dispatcher ",obj)

	for k,v in pairs(msgtable) do
		--print("",k,type(v))
		if "function" == type(v) then

			local funcmap = basefunc.getitem(self._namemap,k,basefunc.listmap)
			if funcmap.map[obj] then
				print("warning:register msg repeat",obj,k)
			else
--				print("",k,v)
            	funcmap:push_back(obj,v)
            end


		end
	end

	--self:dump()
end

-- 断开事件连接
function basefunc.dispatcher:unregister(obj)

	print("remove dispatcher",obj)

	local msgtable = self._recviers[obj]

	-- 清除名字映射
	if msgtable then

		for k,v in pairs(msgtable) do
			local funcmap = self._namemap[k]
			if funcmap then
--				print("",k,obj)
				funcmap:erase(obj)
			end
		end

		-- 清除对象
		self._recviers[obj] = nil
--	else
--		print("","no msgname")
	end

	--self:dump()
end

-- 判断指定的消息名字是否注册
function basefunc.dispatcher:registered(name)
	local limp = self._namemap[name]
	return limp and not limp:empty()
end

-- 调用消息
-- 参数 name ： 消息名字
function basefunc.dispatcher:call(name,...)

	local funcmap = self._namemap[name]
	if funcmap then
		local r1 -- 仅支持一个返回值，否则 返回 多值 如果直接作为参数可能会出问题。,r2,r3,r4 -- 最多支持 4 个返回值
		--local tmp1--,tmp2,tmp3,tmp4

		local cur = funcmap.list:front_item()
		while cur do

			--tmp1 = cur[1](cur[2],...)

			-- 对于分发到多个接收这的返回值处理： 只处理第一个返回值不是 nil 接收者！
			if nil == r1 then
				r1 = cur[1](cur[2],...)
			else
				cur[1](cur[2],...)
			end
--			if tmp1 ~= nil and r1 == nil then
--				r1 = tmp1
--			end

			cur = cur.next
		end

		return r1
	end

	return nil
end

----------------------------
-- 文件路径相关函数库

-- 得到文件名
function basefunc.path.name(path)
	return path:match("([^/\\]+)$")
end

-- 扩展名
function basefunc.path.extname(path)
	return path:match(".+(%.%w+)$")
end

-- 根名
function basefunc.path.purename(path)
	local file = basefunc.path.name(path)
	if not file then return nil end

	local dotIdx = file:find("%.")
	if dotIdx then
		return file:sub(1,dotIdx-1)
	else
		return file
	end
end

-- 文件是否存在
-- 返回值：是否存在(true/false)
function basefunc.path.exists(path)
	local f = io.open(path)
	if f then
		f:close()
		return true
	else
		return false
	end
end

local function isdirsep(c)
	return "/" == c or "\\" == c
end

-- 连接路径：空格会被忽略；只改变中间的分隔符，不会破坏头尾的
function basefunc.path.join(...)
	local args = {... }

	local count = #args

	if count == 1 then return args[1] end
	if count == 0 then return nil end
	if count == 2 then
		if args[1]:len() < 1 then return args[2] end
		if args[2]:len() < 1 then return args[1] end

		if isdirsep(args[1]:sub(-1)) then
			if isdirsep(args[2]:sub(1,1)) then
				return args[1]:sub(1) .. args[2]:sub(2)
			else
				return args[1] .. args[2]
			end
		else
			if isdirsep(args[2]:sub(1,1)) then
				return args[1] .. args[2]
			else
				return args[1] .. "/" .. args[2]
			end
		end
	end

	local ret = args[1]
	for i=2,#args,1 do
		ret = basefunc.path.join(ret,args[i])
	end

	return ret
end

function basefunc.path.read(file)
	local f = io.open(file)
	if f then
		local ret
		if _VERSION == "Lua 5.3" then
			ret = f:read("a")
		else
			ret = f:read("*a")
		end

		f:close()
		return ret
	else
		return nil
	end
end

function basefunc.path.write(filename,data,mode)
	local file ,err = io.open(filename,mode or "w")
	if not file then
		print("file data error:"..err)
		return false
	end
	file:write(data)
	file:close()

	return true
end



-- 规范化路径： 分隔符统一为 "/" ，转换 .. 和 .
function basefunc.path.normalize(path)
	local s = string.gsub(path,"\\","/")
	local dirs = basefunc.string.split(s, "/")

	local i = #dirs
	while i > 0 do
		if dirs[i] == "" or dirs[i] == "." then
			table.remove(dirs,i)
			i = i - 1
		elseif dirs[i] == ".." then
			if i > 1 then
				table.remove(dirs,i-1)
				table.remove(dirs,i-1)

				i = i - 2

			elseif i == 1 then
				table.remove(dirs,i)
				i = i - 1
			end
		else
			i = i - 1
		end
	end
end

-- 得到文件夹：去掉文件名部分
function basefunc.path.dir(file)
	local s = string.gsub(file,"\\","/")
	s = string.gsub(s,"///","/")
	s = string.gsub(s,"//","/")
	local pos = basefunc.string.rfind(s,"/")
	if pos then
		return string.sub(s,1,pos)
	else
		return ""
	end
end

-- 递归创建文件夹（需要 lfs 支持）
local lfs
function basefunc.path.mkdirs(dir)

	if basefunc.path.exists(dir) then return true end

	if isdirsep(string.sub(dir,-1)) then
		if not basefunc.path.mkdirs(basefunc.path.dir(string.sub(dir,1,-2))) then return false end
	else
		if not basefunc.path.mkdirs(basefunc.path.dir(dir)) then return false end
	end

	if not lfs then
		lfs = require "lfs"
	end

	if not lfs then return false end

	return lfs.mkdir(dir)
end

----------------------------
-- 字符串相关

-- 字符串分割
-- 来自 http://blog.163.com/chatter@126/blog/static/127665661201451983036767/
function basefunc.string.split(str, sepa)
	sepa = sepa or ","
	if str==nil or str=='' then
		return nil
	end

    local result = {}
    for match in (str..sepa):gmatch("(.-)"..sepa) do
        table.insert(result, match)
    end
    return result
end
--字符串处理
function basefunc.string.string_to_vec(str)
	local vec = {}
  
	local length = 0
	local i = 1
	while true do
	  local curByte = string.byte( str , i )
	  local byteCount = 1
		  if curByte > 239 then
			  byteCount = 4  -- 4字节字符
		  elseif curByte > 223 then
			  byteCount = 3  -- 汉字
		  elseif curByte > 128 then
			  byteCount = 2  -- 双字节字符
		  else
			  byteCount = 1  -- 单字节字符
		  end
		  local char = string.sub(str, i, i + byteCount - 1)
		  i = i + byteCount
  
		  vec[#vec + 1] = char
		  length = length + 1
		  if i > #str then
			  break
		  end
	end
  
	return vec
  end


-- 反向查找（简单查找，不支持模式匹配）
-- 找到则起始及终点位置的索引； 否则，返回 nil。
function basefunc.string.rfind(str,find)

	-- 倒序查找
	local rstr = string.reverse(str)
	local rfind = string.reverse(find)

	local r1,r2 = string.find(rstr,rfind,1,true)
	if not r1 then return nil end

	-- 换算成正序
	local len = string.len(str)
	return len - r2 + 1,len - r1 + 1
end
function basefunc.string.rtrim(input)
    return string.gsub(input, "[ \t\n\r]+$", "")
end
function basefunc.string.trim(input)
    input = string.gsub(input, "^[ \t\n\r]+", "")
    return string.gsub(input, "[ \t\n\r]+$", "")
end
----------------------------
-- 物理运动相关

-- 求匀加速 运动 的距离
-- 方程：d = v * t + 0.5 * a * t * t
-- 参数 pos0：可以为 nil
function basefunc.physics.accmove(v0,t,a,pos0)
	return {
		x=(pos0 and pos0.x or 0) + v0.x * t + 0.5 * a.x * t * t,
		y=(pos0 and pos0.y or 0) + v0.y * t + 0.5 * a.y * t * t
	}
end

-- 已知 距离 ，求匀加速 直线 运动的时间
-- 返回：
-- 	nil 	- 无解，或没有合法解
--	t1,t2	- 如果有两个有效解（负数解视为无效），则保证 t1 是两个解中最小的
function basefunc.physics.acctime(v0,a,d)

	-- d 太小
	if lm.abs(d) <= 0.00001 then return 0 end

	-- 匀速运动的情况
	if lm.abs(a) <= 0.00001 then
		if lm.abs(v0) <= 0.00001 then
			return nil -- 初速度 加速度 均为 0 ，无解
		else
			local ret = d/v0
			return ret >= 0 and ret or nil
		end
	end

	local delta = v0 * v0 + 2 * a * d
	if delta < 0 then return nil end
	local sqrt_delta = lm.sqrt(delta)
	local tmp1 = - v0 / a
	local tmp2 = sqrt_delta / a

	-- 丢弃负数解
	local r1 = (tmp1 + tmp2) >=0 and (tmp1 + tmp2) or nil
	local r2 = (tmp1 - tmp2) >=0 and (tmp1 - tmp2) or nil

	if not r1 then return r2 end
	if not r2 then return r1 end

	return lm.min(r1,r2)	-- 都合法，返回最小的
end

-- 特定参考方向上的运算 函数集
basefunc.physics.plus = {direct=1}		-- 正方向 函数集
basefunc.physics.minus = {direct=-1}		-- 负方向 函数集

-- 根据符号得到函数集
function basefunc.physics.funcsFromSign(sign)
	return sign < 0 and basefunc.physics.minus or basefunc.physics.plus
end

-- 前进 : l1 + l2
-- 含义： 在 l1 基础上前进（后退为负）距离 l2 后的新位置
function basefunc.physics.plus.forward(l1,l2)
	return l1+l2
end
function basefunc.physics.minus.forward(l1,l2)
	return l1-l2
end

-- 比较 运算: l1 - l2
-- 含义： 在当前方向上，l1 比 l2 领先的距离（落后为负）
function basefunc.physics.plus.compare(l1,l2)
	return l1 - l2
end
function basefunc.physics.minus.compare(l1,l2)
	return l2 - l1
end

-- 取前面的点
function basefunc.physics.plus.front(l1,l2)
	return l1 > l2 and l1 or l2
end
function basefunc.physics.minus.front(l1,l2)
	return l1 < l2 and l1 or l2
end

-- 取后面的点
function basefunc.physics.plus.back(l1,l2)
	return l1 >= l2 and l2 or l1
end
function basefunc.physics.minus.back(l1,l2)
	return l1 <= l2 and l2 or l1
end

-- 根据位置和宽度，计算 开始点和结束点（可用于计算 rect 的前边缘、后边缘）
function basefunc.physics.plus.startpoint(l,w)
	return l
end
function basefunc.physics.minus.startpoint(l,w)
	return l+w
end
function basefunc.physics.plus.endpoint(l,w)
	return l+w
end
function basefunc.physics.minus.endpoint(l,w)
	return l
end


----------------------------
-- 数学函数库

-- 根据概率 进行选择
-- 返回: 选中的项 , 数组下标
-- 参数：
--		array ：待选择的数组
--		chance ：数组元素中存放的 概率 字段名；如果为 nil ，则机会平均
--		chance_total : 概率总数，默认为 100
function basefunc.math.choose(array,chance,chance_total)

	if not array[1] then return nil,nil end

	-- 没有 chance ，则机会平均
	if not chance then
		return array[math.random(#array)]
	end

	local sum = 0
	local total = chance_total or 100
	for i,v in ipairs(array) do
		if v[chance] and tonumber(v[chance]) then
			sum = sum + v[chance]
			if math.random(total) <= sum then
				return v,i
			end
		end
	end

	return array[#array],#array
end

-- 零 坐标
basefunc.zeroPoint = {x=0,y=0 }

-- 零 尺寸
basefunc.zeroSize = {width=0,height=0}

-- 零 矩形
basefunc.zeroRect = {x=0,y=0,width=0,height=0}

-- 拷贝点
function basefunc.math.p(x,y)
    return y and {x=x,y=y} or {x=x.x,y=x.y}
end

-- 点 取负数
function basefunc.math.pminus(x,y)
	return y and {x=-x,y=-y} or {x=-x.x,y=-x.y}
end
function basefunc.math.pminus_(p)
	p.x = -p.x
	p.y = -p.y
	return p
end

function basefunc.math.padd(p1,p2)
	return {x = p1.x + p2.x , y = p1.y + p2.y }
end
function basefunc.math.psub(p1,p2)
	return {x = p1.x - p2.x , y = p1.y - p2.y }
end
function basefunc.math.pzoom(p,m)
	return {x=p.x * m,y=p.y * m}
end

-- 点 自增
function basefunc.math.pinc(p,x,y)

	if y then
		p.x = p.x + x
		p.y = p.y + y
	else
		p.x = p.x + x.x
		p.y = p.y + x.y
	end

	return p
end

-- 点 自减
function basefunc.math.pdec(p,x,y)

	if y then
		p.x = p.x - x
		p.y = p.y - y
	else
		p.x = p.x - x.x
		p.y = p.y - x.y
	end

	return p
end


-- 点 自乘以一个系数
function basefunc.math.pfactor(p,m)
	p.x = p.x * m
	p.y = p.y * m
	return p
end

-- 点到原点距离
function basefunc.math.plength(p)
	return lm.sqrt( p.x * p.x + p.y * p.y )
end

-- 两点距离
function basefunc.math.pdist(p1,p2)
	return basefunc.math.plength(basefunc.math.psub(p1,p2))
end

-- 角度
function basefunc.math.pangle(p)
	if _VERSION == "Lua 5.3" then
		return lm.atan(p.y, p.x)
	else
		return lm.atan2(p.x,p.y)
	end
end

-- 拷贝尺寸
function basefunc.math.size(width,height)
    return height and {width=width,height=height} or {width=width.width,height=width.height}
end

-- 拷贝 rect
function basefunc.math.r(x,y,w,h)
	return y and {x=x,y=y,width=w,height=h} or {x=x.x,y=x.y,width=x.width,height=x.height}
end

-- 移动 rect
function basefunc.math.rmove(r,p)
	return {x=r.x+p.x,y=r.y+p.y,width=r.width,height=r.height}
end

-- rect 自乘以一个系数
function basefunc.math.rfactor(r,m)
	r.x = r.x * m
	r.y = r.y * m
	r.width = r.width * m
	r.height = r.height * m
	return r
end

-- 自膨胀 rect，如果 inf 为 nil，则不变化 rect
function basefunc.math.rinflate(r,inf)

	if inf then
		r.x = r.x-inf
		r.y = r.y-inf
		r.width = r.width + inf + inf
		r.height = r.height + inf + inf
	end

	return r
end


-- 得到矩形的 右上角坐标
function basefunc.math.rtopright(r)
	return {x=r.x + r.width,y=r.y + r.height}
end

-- rect 的中心点
function basefunc.math.rcenter(r)
	return {x=r.x + r.width * 0.5,y=r.y+r.height * 0.5}
end

-- 计算 射线 p1 -> p2 上给定的 百分比位置
function basefunc.math.prayPosByPer(p1,p2,per)
	return {x=p1.x + per * (p2.x-p1.x),y = p1.y + per * (p2.y-p1.y)}
end

-- 根据长度，计算 射线 p1 -> p2 上的点位置
function basefunc.math.prayPos(p1,p2,dist)
	local dist0 = basefunc.math.pdist(p1,p2)
	if dist0 == 0 then
		return {x=p1.x,y=p1.y }
	end
	return basefunc.math.prayPosByPer(p1,p2,dist/dist0)
end

-- 检查点是否在矩形内
function basefunc.math.pinRect(p,rect)
	return p.x >= rect.x and p.x < (rect.x + rect.width) and p.y >= rect.y and p.y < (rect.y + rect.height)
end

-- aabb 碰撞检测
function basefunc.math.pcollide(rect1,rect2)
	-- x 交错
	if rect1.x > rect2.x + rect2.width then return false end
	if rect2.x > rect1.x + rect1.width then return false end

	-- y 交错
	if rect1.y > rect2.y + rect2.height then return false end
	if rect2.y > rect1.y + rect1.height then return false end

	return true
end

-- 四舍五入到整数
local floor = math.floor
function basefunc.math.round(n)
	local v = floor(n)
	return n-v >=  0.5 and v + 1 or v
end

-- 在数组中查找 第一个 小于等于 给定值的下标
-- 参数：
--	vec 数组，已按升序排列
--	var 要查找的变量
--	comp 比较函数，可选，小于则返回 true
-- 返回值：
--	如果 var 小于 第一个值，则返回 0
--	如果数组为空，则返回 nil
function basefunc.math.findrange(vec,var,comp)

	if not vec or not vec[1] then
		return nil
	end

	local compfunc = comp and comp or function(v1,v2) return v1 < v2 end

	local i1=1
	local i2=#vec
	while true do
		local i = lm.modf((i1 + i2) * 0.5)
		if compfunc(var,vec[i]) then
			if i == i1 then -- i2 从右向左移动到重合, var 必然小于 i1，且 i1 为第一个
				return 0
			end

			i2 = i
		else
			if i == i1 then	-- i1 无法移动, i1 , i2 紧贴或相同
				if i1 == i2 then 	-- i , i1 ,i2 相等
					return i1
				else				-- i1,i2 紧贴
					if compfunc(vec[i2],var) then
						return i2	-- vec[i2] < var
					else
						return i1	-- var <= vec[i2]
					end
				end
			end

			i1 = i
		end
	end

	assert(false)
	return nil
end

-- 监视 update 的状态
local debug_upm_data = {}
function basefunc.debug.updateMonitor(name,dt,interval,...)
	local data = basefunc.getitem(debug_upm_data,name)

	data.printCd = data.printCd or 0
	data.printCd = data.printCd - dt
	if data.printCd-dt <= 0 then
		data.printCd = interval
		print("updateMonitor:",name,...)
	end

end

--[[
	服务器用
	通用xpcall错误捕获函数,
	打印出發生異常時的堆棧
]]
function basefunc.debug.common_xpcall_handler_type1( errorMessage )
    print("----------------------------------------")
    print("LUA ERROR: " .. tostring(errorMessage) .. "\n")
    print(debug.traceback("", 2))
    print("----------------------------------------")
    return errorMessage
end

--[[
	服務器用
	通用xpcall錯誤捕獲函數
	打印堆棧，並且將記錄堆棧詳細信息
]]
function basefunc.debug.common_xpcall_handler_type2( errorMessage ,simpleFilePath, detailFilePath)
	print("----------------------------------------")
    print("LUA ERROR: " .. tostring(errorMessage))
    print(debug.traceback("", 2))
    print( string.format( "time is: %s\n", os.date() ) )
    print( "see log file for more detail" )
    print("----------------------------------------")

    if( basefunc.debug.stackdetail ) then
    	basefunc.debug.stackdetail(simpleFilePath, detailFilePath)
    end
    return errorMessage
end

--[[
	服务器用
	将当前堆栈中的所有信息添加写入到指定文件中
	@simpleFilePath 堆栈信息保存文件 默认dreamgame/stack_simple.txt
	@detailFilePath 详细信息保存文件，主要是保存简单文件中的table变量, stack_detail.txt
	@detailDepth table数据类型的记录深度，有一个默认值
]]
function basefunc.debug.stackdetail( simpleFilePath, detailFilePath, detailDepth)
	simpleFilePath = simpleFilePath or "stack_simple.txt"
	detailFilePath = detailFilePath or "stack_detail.txt"
	detailDepth = detailDepth or 7
	assert( type( simpleFilePath ) == "string" )
	assert( type( detailFilePath ) == "string" )
	assert( type( detailDepth ) == "number" )

	--begin for table id
	math.randomseed( os.time() )
	local chars = {}
	for i = 0, 9 do
	    chars[#chars+1] = tostring( i )
	end
	for i = 97, 97+5 do
	    chars[#chars+1] = string.char( i )
	end
	function __genTableId()
	    local tb = {}
	    for i = 1, 32 do
	        tb[#tb+1] = chars[math.random( 1, 16 )]
	    end
	    return table.concat( tb )
	end
	--end for table id

	local function __is_need_log_var( v ) --根据变量的类型决定是否需要记录此变量的信息

	    return true -- 鉴于对lua使用的多样性，所有类型的数据都记录。

	    -- return type(v) ~= "function" and type( v ) ~= "userdata"
	    --     and type( v ) ~= "thread" and type(v) ~= "lightuserdata"
	end
	local function table_to_string( aTable, recMax )

		-- by lyx
		if aTable == nil then return "nil" end

	    recMax = recMax or 3
	    local stringBuffer = {}
	    local function __tab_string( count )
	        local tabl = {}
	        for i = 1, count do
	            table.insert( tabl, "  " )
	        end
	        return table.concat( tabl, "" )
	    end
	    local function __table_to_string( tableNow, recNow )
	        if( recNow > recMax ) then
	            table.insert( stringBuffer, tostring( tableNow ) .. ",\n" )
	            return
	        end
	        table.insert( stringBuffer, "{\n" )
	        for k, v in pairs( tableNow ) do
	            if( __is_need_log_var(v) ) then
	                table.insert( stringBuffer, __tab_string(recNow) .. tostring( k ) .. "=" )
	                if( "table" ~= type(v) ) then
	                    table.insert( stringBuffer, tostring( v ) .. ",\n" )
	                else
	                    __table_to_string( v, recNow + 1 )
	                end
	            end
	        end
	        table.insert( stringBuffer, __tab_string(recNow-1) .. "},\n" )
	    end
	    __table_to_string( aTable, 1 )
	    return table.concat( stringBuffer, "" )
	end


	--实现
	local function __imp()
		local complexVarMap = {} --复杂变量存放处
	    local simpleLogBuffer = {
	        string.format( "time is: %s\n", os.date() )
	    }
	    for level = 3, math.huge do
	        local stackInfo = debug.getinfo( level )
	        if( not stackInfo ) then
	            break
	        end
	        simpleLogBuffer[#simpleLogBuffer+1] = string.format( "stack level:[%d], funcname:[%s], file:[%s], begin at:[%d], at:[%d]\n",
	            level or -100, stackInfo.name or "unknow", stackInfo.source or "unknow",
	                stackInfo.linedefined or -100, stackInfo.currentline or -100)
	        simpleLogBuffer[#simpleLogBuffer+1] = string.format( "there are some local variables:\n" )
	        --local variable 信息
	        for i = 1, math.huge do
	            local vName, vValue = debug.getlocal( level, i )
	            if( nil == vName ) then
	                break
	            end
	            if( __is_need_log_var( vValue ) ) then
	                if( type(vValue) == "table" ) then
	                    local tableId = __genTableId()
	                    complexVarMap[tableId] = vValue
	                    simpleLogBuffer[#simpleLogBuffer+1] = string.format( "name:[%s]\ttableid:[%s]\n", vName, tableId )
	                else
	                    simpleLogBuffer[#simpleLogBuffer+1] = string.format( "name:[%s]\tvalue:[%s]\ttype:[%s]\n",
	                        vName, tostring(vValue), type(vValue))
	                end
	            end
	        end
	        simpleLogBuffer[#simpleLogBuffer+1] = string.format( "there are some upvalue:\n" )
	        --upvalue 信息
	        for i = 1, math.huge do
	            local vName, vValue = debug.getupvalue( stackInfo.func, i )
	            if( nil == vName ) then
	                break
	            end
	            if( __is_need_log_var( vValue ) ) then
	                if( type(vValue) == "table" ) then
	                    local tableId = __genTableId()
	                    complexVarMap[tableId] = vValue
	                    simpleLogBuffer[#simpleLogBuffer+1] = string.format( "name:[%s]\ttableid:[%s]\n", vName, tableId )
	                else
	                    simpleLogBuffer[#simpleLogBuffer+1] = string.format( "name:[%s]\tvalue:[%s]\ttype:[%s]\n",
	                        vName, tostring(vValue), type(vValue))
	                end
	            end
	        end
	        simpleLogBuffer[#simpleLogBuffer+1] = string.format("---end stack level:[%d]\n\n", level)
	    end
	    simpleLogBuffer[#simpleLogBuffer+1] = string.rep( "\n", 5 )
	    --write simple log
	    local sFile, sFileOpenErr = io.open( simpleFilePath, "a" )
	    if( sFile ) then
	        sFile:write( table.concat( simpleLogBuffer ) )
	        sFile:close()
	    else
	        local forPrint = string.format( "__stack_detail__:open log file [%s] faild, beccause [%s]",simpleFilePath, sFileOpenErr )
	        return -- do not need write complex log
	    end

	    --write complex log
	    local dFile, dFileOpenErr = io.open( detailFilePath, "a")
	    if( dFile ) then
	        for k, v in pairs(complexVarMap) do
	            dFile:write( tostring( k ) )
	            dFile:write( " = " )
	            if( type(v) == "table" ) then
	                dFile:write( table_to_string( v, detailDepth ) )
	            end
	            dFile:write( "\n" )
	        end
	        dFile:close()
	    else
	        local forPrint = string.format( "__stack_detail__:open log file [%s] faild, beccause [%s]",detailFilePath, dFileOpenErr )
	        print( forPrint )
	    end
	end -- end imp

	local noError, errorMsg = pcall( __imp )
	if( not noError ) then
		print( string.format( "stackdetail: 发生异常，已经安全退出，检查函数的实现，错误信息：\n%s", errorMsg ) )
	end

end

-- add by wss

function basefunc.getDateTime(tiemStr)
	local date = basefunc.string.split(tiemStr, " ")
	if #date == 2 then
		local nyr = basefunc.string.split(date[1], "-")
		local sfm = basefunc.string.split(date[2], ":")

		return {year = tonumber(nyr[1]) , month = tonumber(nyr[2]) , day = tonumber(nyr[3]) , hour = tonumber(sfm[1]) , min = tonumber(sfm[2]) , sec = tonumber(sfm[3]) }
	end
	return {}
end

function basefunc.setDateTime(tiemTable)
	return ""..tiemTable.year .. "-" .. tiemTable.month .. "-" .. tiemTable.day .. " " .. tiemTable.hour .. ":" .. tiemTable.min .. ":" .. tiemTable.sec
end


function basefunc.table.map( t, func )
	local newt = {}
	for k, v in pairs( t ) do
		newt[k] = func( v )
	end
	return newt
end

function basefunc.table.array_find_i( t, ifirst, ilast, predicate )
	for i = ifirst, ilast, 1 do
		if( predicate( t[i] ) ) then
			return i, t[i]
		end
	end
	return nil
end

function basefunc.table.array_find( t, predicate )
	return basefunc.table.array_find_i( t, 1, #t, predicate )
end

function basefunc.table.array_find_all_i( t, ifirst, ilast, predicate )
	local ret = {}
	for i = ifirst, ilast, 1 do
		if( predicate( t[i] ) ) then
			ret[#ret+1] = t[i]
		end
	end
	return ret
end

function basefunc.table.array_find_all( t, predicate )
	return basefunc.table.array_find_all_i( t, 1, #t, predicate )
end
function basefunc.table.insert_repeat( t, value,times )
	while times>0 do
		t[#t+1]=value
		times=times-1
	end
end


function basefunc.nextDay( dateTable )
	local ts = os.time( dateTable )

	local ts_next = ts + oneday_sec
	local day_next = os.date( "*t", ts_next )
	return day_next
end

function basefunc.sepTheDate( dateTable, seperator )
	seperator = seperator or "-"
	local buf = {
		string.format( "%04d", dateTable.year ),
		string.format( "%02d", dateTable.month ),
		string.format( "%02d", dateTable.day ),
	}
	return table.concat( buf, seperator )
end

function basefunc.tohex(data)
	local ret = {}
	for i=1,string.len(data) do
		ret[#ret + 1] = string.format("%02X",data:byte(i))
	end

	return table.concat(ret)
end

function basefunc.datetimeStrToTimeStamp( datetimeStr )
	local datestr, timestr = unpack(basefunc.string.split( datetimeStr, " " ))
	local yearstr, monthstr, daystr = unpack( basefunc.string.split( datestr, "-" ) )
	local hourstr, minstr, secstr = unpack( basefunc.string.split( timestr, ":" ) )
	local datetime = {
		year = tonumber( yearstr ),
		month = tonumber( monthstr ),
		day = tonumber( daystr ),
		hour = tonumber( hourstr ),
		min = tonumber( minstr ),
		sec = tonumber( secstr ),
	}
	return os.time( datetime )
end

function basefunc.dateStrToTimeStamp( dateStr )
	return basefunc.datetimeStrToTimeStamp( dateStr .. " 00:00:00" )
end


--[[
	传入一个以下格式(常见于http get请求)的字符串，返回相应的键值对表，其中，键值均为字符串
	a=b&c=d&serverId=nmb
	格式的保证由调用者保证，任何非法格式行为不确定
]]
function basefunc.parse_url_params_str( params_str )
	local kvstrs = basefunc.string.split( params_str, "&" )
	local ret = {}
	for _, kvstr in ipairs( kvstrs ) do
		local pair = basefunc.string.split( kvstr, "=" )
		ret[pair[1]] = assert( pair[2] )
	end
	return ret
end


local unescape_uri_map = {
	["%2B"] = "+",
	["%20"] = " ",
	["%2F"] = "/",
	["%3F"] = "?",
	["%25"] = "%",
	["%23"] = "#",
	["%26"] = "&",
	["%3D"] = "=",
}



function basefunc.unescape_uri( uri  )

	-- local charSeqnence = {}
	-- local function __strAt( str, i )
	-- 	return string.sub( str, i, i )
	-- end
	-- local function __isSeqnenceEndWith( str )
	-- 	local seqnenceLen = #charSeqnence
	-- 	local strLen = #str
	-- 	if seqnenceLen < strLen then
	-- 		return false
	-- 	end
	-- 	for i = 0, strLen-1 do
	-- 		if charSeqnence[seqnenceLen-i] ~= __strAt(str, strLen-i) then
	-- 			return false
	-- 		end
	-- 	end
	-- 	return true
	-- end
	-- local function __popbackSequence( num )
	-- 	assert( #charSeqnence >= num)
	-- 	local sequenceLen = #charSeqnence
	-- 	for i = 0, num-1 do
	-- 		charSeqnence[sequenceLen-i] = nil
	-- 	end
	-- end
	-- local function __pushtoSequence( str )
	-- 	for i = 1, #str do
	-- 		charSeqnence[#charSeqnence+1] = __strAt( str, i)
	-- 	end
	-- end
	-- for i = 1, #uri do
	-- 	charSeqnence[#charSeqnence+1] = __strAt(uri, i)
	-- 	for wcoded, worigin in pairs( unescape_uri_map ) do
	-- 		if __isSeqnenceEndWith( wcoded ) then
	-- 			-- print( wcoded )
	-- 			__popbackSequence( #wcoded )
	-- 			__pushtoSequence( worigin )
	-- 			-- print( table.concat( charSeqnence ) )
	-- 		end
	-- 	end
	-- end

	-- return table.concat( charSeqnence )

	-- 参考 https://github.com/gonapps/gonapps-lua-url-decoder
	return string.gsub(uri, "%%(%x%x)", function(hex)
        return string.char(tonumber(hex, 16))
    end)
end


local escape_uri_map = {
	["+"] = "%2B",
	[" "] = "%20",
	["/"] = "%2F",
	["?"] = "%3F",
	["%"] = "%25",
	["#"] = "%23",
	["&"] = "%26",
	["="] = "%3D",
}


function basefunc.escape_uri( uri )

	-- 参考 https://github.com/gonapps/gonapps-lua-url-encoder/blob/master/src/gonapps/url/encoder.lua
	return string.gsub(uri, "[^A-z0-9\\-_.~]", function(char) return string.format("%%%X", string.byte(char)) end)
end


-- print( basefunc.escape_uri( "as+ /?%#fwergrfg&=" ) )


-- print( basefunc.unescape_uri( basefunc.escape_uri( "as+ /?%#fwergrfg&=" ) ) )

---- 解码开关
function basefunc.decode_kaiguan(game_type , kaiguan)
	if not kaiguan or type(kaiguan) ~= "number" then
		print("basefunc.decode_kaiguan kaiguan must number")
		return nil
	end

	local split_name = basefunc.string.split(game_type, "_")

	local mj_kaiguan_map = {
		[1] = "qing_yi_se",
		[2] = "da_dui_zi",
		[3] = "qi_dui",
		[4] = "long_qi_dui",
		[5] = "jiang_dui",
		[6] = "men_qing",
		[7] = "zhong_zhang",
		[8] = "jin_gou_diao",
		[9] = "yao_jiu",
		[10] = "hai_di_ly",
		[11] = "hai_di_pao",
		[12] = "tian_hu",
		[13] = "di_hu",
		[14] = "gang_shang_hua",
		[15] = "gang_shang_pao",
		[16] = "zimo",
		[17] = "qiangganghu",
		[18] = "zimo_jiafan",
		[19] = "zimo_jiadian",
		[20] = "da_piao",
		[21] = "huan_san_zhang",
		[22] = "zhuan_yu",
	}

	local ddz_kaiguan_map = {
		
	}

	
	local kaiguan_table = {}
	if split_name[2] == "mj" then
		local chu = kaiguan
		local index = 0
		while true do
			index = index + 1
			local yu = chu % 2 
			chu = math.floor(chu / 2)

			if mj_kaiguan_map[index] then
				kaiguan_table[ mj_kaiguan_map[index] ] = yu == 1
			end
			
			if chu <= 0 then
				break
			end
		end

		--- 处理高位为0的
		for i = index + 1 , #mj_kaiguan_map do
			kaiguan_table[ mj_kaiguan_map[i] ] = false
		end

	elseif split_name[2] == "ddz" then

	end

	return kaiguan_table
end


---- 解码倍数
function basefunc.decode_multi(game_type , multi)
	if not multi or type(multi) ~= "string" then
		print("basefunc.decode_multi multi must string")
		return nil
	end

	local split_name = basefunc.string.split(game_type, "_")

	local mj_multi_map = {
		[1] = "qing_yi_se",
		[2] = "da_dui_zi",
		[3] = "qi_dui",
		[4] = "long_qi_dui",
		[5] = "dai_geng",
		[6] = "jiang_dui",
		[7] = "men_qing",
		[8] = "zhong_zhang",
		[9] = "jin_gou_diao",
		[10] = "yao_jiu",
		[11] = "hai_di_ly",
		[12] = "hai_di_pao",
		[13] = "tian_hu",
		[14] = "di_hu",
		[15] = "gang_shang_hua",
		[16] = "gang_shang_pao",
		[17] = "zimo",
		[18] = "qiangganghu",
	}

	local multi_code = {}
	if split_name[2] == "mj" then
		for i = 1 , #mj_multi_map do
			local code = string.byte( string.sub( multi , i , i ) )
			multi_code[ mj_multi_map[i] ] = code
		end

	elseif split_name[2] == "ddz" then

	end



	return multi_code
end

--- 解码任务的奖励领取状态
function basefunc.decode_task_award_status(status_num)
	local vec = {}

	if type(status_num) == "number" then

	   local chu = status_num
	  local index = 0
	  while true do
		  index = index + 1
		  local yu = chu % 2
		  chu = math.floor(chu / 2)

		  vec[#vec + 1] = yu == 1

		  if chu <= 0 then
				break
		  end
		end

  elseif type(status_num) == "string" then
	  ----- 判断第一个字符是否是压缩的标志，如果是，用压缩的算法
	  local is_find = string.find( status_num , "+" )
	  if is_find then
		  local tar_status_num = string.sub(status_num , 2,-1)

		  return basefunc.decode_task_award_status_compress(tar_status_num)
	  end

	  vec = basefunc.string.string_to_vec(status_num)

	  ---
	  for key,value in pairs(vec) do
		  vec[key] = value == "1"
	  end

  end

	return vec
end
  
--[[
  参数：
  status_vec : 状态的vec ; 
  _tar_type : 打成的类型（number,string）; 
  _is_compress : 是否压缩
--]] 
function basefunc.encode_task_award_status(status_vec , _tar_type , _is_compress)
  local tar_type = _tar_type or "number"

	local num = 0

	if tar_type ~= "number" and tar_type ~= "string" then
		error("encode_task_award_status tar_type not string and not number")
	end

	if tar_type == "number" then
		for key,status in pairs(status_vec) do
			if status then
			  num = num + 2 ^ (key-1)
		  end
		end
  elseif tar_type == "string" then
	  ---- 如果要压缩，走新的
	  if _is_compress then
		  local tar_str = basefunc.encode_task_award_status_compress(status_vec , _tar_type)
		  --- 编码成字符串之后，在前面加一个 + 
		  tar_str = "+" .. tar_str
		  return tar_str
	  end


	  local max_num = 0
	  ---- 找到最大的key
	  for key,value in pairs(status_vec) do
		  if key > max_num then
			  max_num = key
		  end
	  end
	  ---- 中间没得值的key，用 0 填充
	  for i = 1,max_num do
		  status_vec[i] = status_vec[i] and 1 or 0
	  end

	  num = table.concat( status_vec , "" )
  end

	return num
end


--# 0-不能领取 | 1-可领取 | 2-已完成 | 3- 未启用
function basefunc.decode_all_task_award_status(status_table,data,max_level)
	local vec = {}
	local s
	if data.now_lv == max_level and data.need_process == data.now_process then
		for i=1,max_level do
			if i <= data.now_lv then
				s = status_table[i]
				if not s then
					table.insert(vec,i,1)
				else
					table.insert(vec,i,2)
				end
			else
				table.insert(vec,i,0)
			end
		end
	else
		for i=1,max_level do
			if i < data.now_lv or (i == data.now_lv and data.now_process == data.need_process) then
				s = status_table[i]
				if not s then
					table.insert(vec,i,1)
				else
					table.insert(vec,i,2)
				end
			else
				table.insert(vec,i,0)
			end
		end
	end
	return vec
end

--# 0-不能领取 | 1-可领取 | 2-已完成 | 3- 未启用
function basefunc.decode_all_task_award_status2(status_table,data,max_level)
	local vec = {}
	local s

	for i=1,max_level do
		s = status_table[i]
		if s then
			table.insert(vec,i,2)
		else
			if data.now_lv == max_level and data.need_process == data.now_process then
				table.insert(vec,i,1)
			elseif i < data.now_lv or (i == data.now_lv and data.now_process == data.need_process) then
				table.insert(vec,i,1)
			else
				table.insert(vec,i,0)
			end
		end
	end
	return vec
end

function basefunc.bit_or(a,b)
    local p,c=1,0
    while a+b>0 do
        local ra,rb=a%2,b%2
        if ra+rb>0 then c=c+p end
        a,b,p=(a-ra)/2,(b-rb)/2,p*2
    end
    return c
end

function basefunc.bit_xor(a,b)
    local p,c=1,0
    while a+b>0 do
        local ra,rb=a%2,b%2
        if ra+rb==1 then c=c+p end
        a,b,p=(a-ra)/2,(b-rb)/2,p*2
    end
    return c
end

function basefunc.bit_not(n)
    local p,c=1,0
    while n>0 do
        local r=n%2
        if r<1 then c=c+p end
        n,p=(n-r)/2,p*2
    end
    return c
end

function basefunc.bit_and(a,b)
    local p,c=1,0
    while a>0 and b>0 do
        local ra,rb=a%2,b%2
        if ra+rb>1 then c=c+p end
        a,b,p=(a-ra)/2,(b-rb)/2,p*2
    end
    return c
end

---- 处理名字
function basefunc.deal_hide_player_name(_player_name)
  if not _player_name then
    return ""
  end
  local player_name = _player_name
  local player_name_vec = basefunc.string.string_to_vec(player_name)
  if player_name_vec and type(player_name_vec) == "table" and next(player_name_vec) then
    if #player_name_vec > 3 then
      player_name = player_name_vec[1] .. "**" .. player_name_vec[#player_name_vec]
    elseif #player_name_vec == 3 then
      player_name = player_name_vec[1] .. "*" .. player_name_vec[#player_name_vec]
    elseif #player_name_vec == 2 then
      player_name = player_name_vec[1] .. "*"
    elseif #player_name_vec == 1 then
      player_name = tostring( player_name_vec[1] )
    end
  end
  return player_name
end

-- 判断是否 是物品有特有属性(独立不可折叠)
function basefunc.is_object_asset(_asset_type)
  
  if type(_asset_type)=="string" then
    if string.len(_asset_type)>4 and string.sub(_asset_type,1,4) == "obj_" then
      return true
    end
  end

  return false
end
--- 比较值
function basefunc.compare_value( value1 , value2 , judge_type )
  if type(value2) ~= "table" then
    if judge_type == NOR_CONDITION_TYPE.EQUAL then
      return value1 == value2
    elseif judge_type == NOR_CONDITION_TYPE.GREATER then
      return value1 >= value2
    elseif judge_type == NOR_CONDITION_TYPE.LESS then
      return value1 <= value2
    elseif judge_type == NOR_CONDITION_TYPE.NOT_EQUAL then
      return value1 ~= value2
    end

  else
     local e_judge_type = {
       [NOR_CONDITION_TYPE.EQUAL] = "or",
       [NOR_CONDITION_TYPE.GREATER] = "or",
       [NOR_CONDITION_TYPE.LESS] = "or",
       [NOR_CONDITION_TYPE.NOT_EQUAL] = "and",
     }  

    local cond_num = 0
    for key,value in ipairs(value2) do
      if basefunc.compare_value( value1 , value , judge_type ) then
        cond_num = cond_num + 1
      end
    end

    local is_cond = false
    if not e_judge_type[judge_type] or e_judge_type[judge_type] == "and" then
      if cond_num == #value2 then
        is_cond = true
      end
    elseif e_judge_type[judge_type] == "or" then
      if cond_num > 0 then
        is_cond = true
      end
    end

    if is_cond then
      return true
    else
      return false
    end
  end


  return false
end




---------------------------------- add by wss
--- 解码任务的奖励领取状态(压缩版)
function basefunc.decode_task_award_status_compress(status_num)
	local vec = {}

	if type(status_num) == "number" then

	   local chu = status_num
	  local index = 0
	  while true do
		  index = index + 1
		  local yu = chu % 2
		  chu = math.floor(chu / 2)

		  vec[#vec + 1] = yu == 1

		  if chu <= 0 then
				break
		  end
		end

  elseif type(status_num) == "string" then

	  local new_tt = string.gsub( status_num , "%[%d+%]%d" , function( s ) 	
		  --print( "xxx------s:" , s )
		  
		  local num = string.sub( s , 2 , -3 )
		  --print( "xxx------num:" ,num )
		  
		  local value = string.sub( s , -1 , -1 )
		  --print( "xxx------value:" ,value )
		  
		  local rep = ""
		  
		  for i = 1, tonumber(num) do
			  rep = rep .. value
		  end
		  
		  return rep
	  end)

	  vec = basefunc.string.string_to_vec(new_tt)

	  ---
	  for key,value in pairs(vec) do
		  vec[key] = value == "1"
	  end

  end

	return vec
end

-----编码任务的领奖状态(压缩版)
function basefunc.encode_task_award_status_compress(status_vec , _tar_type)
  local tar_type = _tar_type or "number"

	local num = 0

	if tar_type ~= "number" and tar_type ~= "string" then
		error("encode_task_award_status tar_type not string and not number")
	end

	if tar_type == "number" then
		for key,status in pairs(status_vec) do
			if status then
			  num = num + 2 ^ (key-1)
		  end
		end
  elseif tar_type == "string" then
	  local max_num = 0
	  ---- 找到最大的key
	  for key,value in pairs(status_vec) do
		  if key > max_num then
			  max_num = key
		  end
	  end

	  ---- 有几个连续的相同的项，就开始压缩
	  local same_limit = 5

	  ---- 中间没得值的key，用 0 填充
	  for i = 1,max_num do
		  status_vec[i] = status_vec[i] and 1 or 0
	  end

	  num = ""

	  local last_same_index = 1
	  local last_same_value = nil
	  for i = 1 , max_num do 
		  if not last_same_value then
			  last_same_value = status_vec[i]
			  last_same_index = i
		  end

		  if status_vec[i] ~= last_same_value then
			  local same_num = i - last_same_index

			  if same_num >= same_limit then
				  num = num .. "[" .. same_num .. "]" .. last_same_value
			  else
				  num = num .. table.concat( status_vec , "" , last_same_index , i-1 )
			  end

			  last_same_index = i
			  last_same_value = status_vec[i]
		  end

		  ---- 到最后，最后一个位置需要处理
		  if i == max_num then
			  local same_num = i - last_same_index + 1

			  if same_num >= same_limit then
				  num = num .. "[" .. same_num .. "]" .. last_same_value
			  else
				  num = num .. table.concat( status_vec , "" , last_same_index , i )
			  end
		  end

	  end


	  --num = table.concat( status_vec , "" )
  end

	return num
end

function basefunc.parse_activity_data(_data)
	if not _data then
	  return nil
	end

	local code = "return " .. _data
	local ok, ret = xpcall(function ()
	  local data = loadstring(code)()
	  if type(data) ~= 'table' then
		data = {}
		print("parse_activity_data error : {}")
	  end
	  return data
	end
	,function (err)
	  print("parse_activity_data error : ".._data)
	  print(err)
	end)
  
	if not ok then
	  ret = {}
	end

	return ret or {},ok
end
return basefunc