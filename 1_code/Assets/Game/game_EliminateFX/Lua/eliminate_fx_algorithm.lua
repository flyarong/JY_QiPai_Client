local basefunc = require "Game.Common.basefunc"
eliminate_fx_algorithm = basefunc.class()
local M = eliminate_fx_algorithm

--按位左移
local function leftmove(t,v)
	return math.floor(t * MathExtend.Pow(2,v))
	-- body
end

--按位右移
local function rightmove(t,v)
	return math.floor(t / MathExtend.Pow(2,v))
	-- body
end
local function unzip_data_to_proto(final_data)
	local data = {}
	for i = 1, string.len(final_data) do
		local num = string.sub(final_data, i, i):byte()
		local temp = num
		data[#data + 1] = rightmove(num,4)
		data[#data + 1] = temp - leftmove(data[#data], 4)
	end
	local len = #data % 5
		if len > 0 then
			for i=1,len do
				table.remove(data,#data)
			end
		end
	return data
end

M.xc_limit = 3
M.high_max = 4
M.wide_max = 5

--消除元素的倍率表，*10倍的结果
M.rate_map = {
	{0,0, 1,2,5,10,},--//1 粮草
    {0,0, 2,5,10,20,},--//2 元宝
    {0,0, 5,10,20,40,},--//3 头盔
    {0,0, 10,20,40,80,},--//4 铠甲
    {0,0, 20,40,80,150,},--//5 战马
}

--对应品质从低到高(除了鞭炮)
M.special_rate_map = {
	[100] = 5,		--元宝
	[101] = 10,		--财神1
	[102] = 12,		--财神2
	[103] = 13,		--财神3
}

M.xc_state = {
	big_game = "big_game",
	nor = "nor",
}

--n 消除的元素，c 消除的个数
function M.get_rate(n,c)
	if not n or not c then return 0 end
	if n < 0 or n > #M.rate_map then return 0 end
	if c > #M.rate_map[n] then
		c = #M.rate_map[n]
	end
	-- print("<color=green>n,c</color>",n,c,M.rate_map[n][c])
	return M.rate_map[n][c] / 10
end

-- >=100 的是固定不动的
M.eliminate_id ={
	[1] = 1,
	[2] = 2,
	[3] = 3,
	[4] = 4,
	[5] = 5,
	[100] = 100, -- 鞭炮
	[101] = 101, 
	[102] = 102, 
	[103] = 103, 
}

--得到map中所有要消除的元素,not_check_ids为不进行检查的id列表
function M.get_eliminate_all_element(map,not_check_ids)
	if not map or not next(map) then return end
	local xc_list_map = {}
	local xc_map = {}
	local hash_map = {}
	for y = M.high_max, 1, -1 do
		for x = 1, M.wide_max, 1 do
			if not not_check_ids[map[x][y]] then
				local cur_xc_map = {}
				M.check_can_xc_by_point(map,x,y,xc_map,nil,nil,hash_map,true,cur_xc_map)
				if not table_is_null(cur_xc_map) then
					table.insert(xc_list_map, cur_xc_map)
				end
			end
		end
	end

	if table_is_null(xc_list_map) then
		xc_list_map = nil		
	end
	if table_is_null(xc_map) then
		xc_map = nil
	end
	return xc_list_map, xc_map
end

--  high_or_wide 0 表示 横竖都要搜索  1 表示横向搜索  2表示竖向搜索  is_clear--是否清除
function M.check_can_xc_by_point(map,x,y,xc_map,xc_type,high_or_wide,hash_map,is_clear,cur_xc_map)
	if high_or_wide==1 then
	  local start_p=x
	  local end_p=x
	  while start_p>0 do
		if map[start_p] and map[start_p][y] and map[start_p][y]==xc_type then
		  start_p=start_p-1
		else
		  break
		end
	  end
	  start_p=start_p+1
	  while end_p<=M.wide_max do
		if map[end_p] and map[end_p][y] and  map[end_p][y]==xc_type then
		  end_p=end_p+1
		else
		  break
		end
	  end
	  end_p=end_p-1
	  if end_p-start_p+1>=M.xc_limit then
		for i=start_p,end_p do
		  if not hash_map[i] or (hash_map[i] and not hash_map[i][y]) then
			hash_map[i] = hash_map[i] or {}
			hash_map[i][y]=true

			xc_map[i]=xc_map[i] or {}
			xc_map[i][y]=xc_type
			cur_xc_map[i]=cur_xc_map[i] or {}
			cur_xc_map[i][y]=xc_type
			M.check_can_xc_by_point(map,i,y,xc_map,xc_type,2,hash_map,is_clear,cur_xc_map)
			if is_clear then
				map[i][y]=0
			end
		  end
		end
	  end
	elseif high_or_wide==2 then
	  local start_p=y
	  local end_p=y
	  while start_p>0 do
		if map[x] and map[x][start_p] and map[x][start_p]==xc_type then
		  start_p=start_p-1
		else
		  break
		end
	  end
	  start_p=start_p+1
	  while end_p<=M.high_max do
		if map[x] and map[x][end_p] and map[x][end_p]==xc_type then
		  end_p=end_p+1
		else
		  break
		end
	  end
	  end_p=end_p-1
	  if end_p-start_p+1>=M.xc_limit then
		for i=start_p,end_p do
		  if not hash_map[x] or (hash_map[x] and not hash_map[x][i]) then
			hash_map[x] = hash_map[x] or {}
			hash_map[x][i]=true

			xc_map[x]=xc_map[x] or {}
			xc_map[x][i]=xc_type
			cur_xc_map[x]=cur_xc_map[x] or {}
			cur_xc_map[x][i]=xc_type
			M.check_can_xc_by_point(map,x,i,xc_map,xc_type,1,hash_map,is_clear,cur_xc_map)
			if is_clear then
			  map[x][i]=0
			end
		  end
		end
	  end
	elseif not high_or_wide or high_or_wide==0 then
	  hash_map=hash_map or {}
	  xc_type=xc_type or map[x][y]
	  if not hash_map[x] or (hash_map[x] and not hash_map[x][y]) then
		M.check_can_xc_by_point(map,x,y,xc_map,xc_type,1,hash_map,is_clear,cur_xc_map)
	  end
	  if not hash_map[x] or (hash_map[x] and not hash_map[x][y]) then
		M.check_can_xc_by_point(map,x,y,xc_map,xc_type,2,hash_map,is_clear,cur_xc_map)
	  end
	end
end

--得到map中所有要消除的元素,not_check_ids为不进行检查的id列表
function M.get_fixed_all_element(map,check_ids)
	if not map or not next(map) then return end
	local fix_list_map = {}
	local fix_map = {}
	local hash_map = {}
	for y = M.high_max, 1, -1 do
		for x = 1, M.wide_max, 1 do
			if check_ids[map[x][y]] then
				local cur_fix_map = {}
				local temp_fix_map = {}
				M.check_can_fix_by_point(map,x,y,temp_fix_map,nil,nil,hash_map,false,cur_fix_map)
				if not table_is_null(cur_fix_map) then
					local len = 0
					for i=1,M.wide_max do
						for j=1,M.high_max do
							if cur_fix_map[i] and cur_fix_map[i][j] then
								len = len + 1
							end
						end
					end
					if len >= 4 then
						fix_map = temp_fix_map
						table.insert(fix_list_map, cur_fix_map)
					else
						temp_fix_map = {}
					end
				end
			end
		end
	end

	if table_is_null(fix_list_map) then
		fix_list_map = nil		
	end
	if table_is_null(fix_map) then
		fix_map = nil
	end
	return fix_list_map, fix_map
end

--得到map中所有要消除的元素,not_check_ids为不进行检查的id列表
function M.get_fixed_all_element_2(map,check_ids)
	if not map or not next(map) then return end
	dump(map,"<color=yellow><size=15>++++++++++map++++++++++</size></color>")
	local fix_list_map = {}
	local fix_map = {}
	local hash_map = {}
	for y = M.high_max, 1, -1 do
		for x = 1, M.wide_max, 1 do
			if check_ids[map[x][y]] then
				local cur_fix_map = {}
				M.check_can_fix_by_point_2(map,x,y,fix_map,nil,nil,hash_map,true,cur_fix_map)
				if not table_is_null(cur_fix_map) then
					table.insert(fix_list_map, cur_fix_map)
				end
			end
		end
	end
	if table_is_null(fix_list_map) then
		fix_list_map = nil		
	end
	if table_is_null(fix_map) then
		fix_map = nil
	end
	return fix_list_map, fix_map
end

local conversion_tab = {
	[9] = 100,
	[6] = 101,
	[7] = 102,
	[8] = 103,
}

--  high_or_wide 0 表示 横竖都要搜索  1 表示横向搜索  2表示竖向搜索  is_clear--是否清除
function M.check_can_fix_by_point(map,x,y,xc_map,xc_type,high_or_wide,hash_map,is_clear,cur_xc_map)
	if high_or_wide==1 then
	  local start_p=x
	  local end_p=x
	  while start_p>0 do
		if map[start_p] and map[start_p][y] and (map[start_p][y]==xc_type or map[start_p][y] == conversion_tab[xc_type]) then
		  start_p=start_p-1
		else
		  break
		end
	  end
	  start_p=start_p+1
	  while end_p<=M.wide_max do
		if map[end_p] and map[end_p][y] and  (map[end_p][y]==xc_type or map[end_p][y] == conversion_tab[xc_type]) then
		  end_p=end_p+1
		else
		  break
		end
	  end
	  end_p=end_p-1
	  
	  if end_p-start_p+1>=3 then
		for i=start_p,end_p do
		  if not hash_map[i] or (hash_map[i] and not hash_map[i][y]) then
			hash_map[i] = hash_map[i] or {}
			hash_map[i][y]=true

			xc_map[i]=xc_map[i] or {}
			xc_map[i][y]=xc_type
			cur_xc_map[i]=cur_xc_map[i] or {}
			cur_xc_map[i][y]=xc_type
			M.check_can_fix_by_point(map,i,y,xc_map,xc_type,2,hash_map,is_clear,cur_xc_map)
			if is_clear then
				map[i][y]=0
			end
		  end
		end
	  end
	elseif high_or_wide==2 then
	  local start_p=y
	  local end_p=y
	  while start_p>0 do
		if map[x] and map[x][start_p] and (map[x][start_p]==xc_type or map[x][start_p] == conversion_tab[xc_type]) then
		  start_p=start_p-1
		else
		  break
		end
	  end
	  start_p=start_p+1
	  while end_p<=M.high_max do
		if map[x] and map[x][end_p] and (map[x][end_p]==xc_type or map[x][end_p] == conversion_tab[xc_type]) then
		  end_p=end_p+1
		else
		  break
		end
	  end
	  end_p=end_p-1
	  if end_p-start_p+1>=3 then
		for i=start_p,end_p do
		  if not hash_map[x] or (hash_map[x] and not hash_map[x][i]) then
			hash_map[x] = hash_map[x] or {}
			hash_map[x][i]=true

			xc_map[x]=xc_map[x] or {}
			xc_map[x][i]=xc_type
			cur_xc_map[x]=cur_xc_map[x] or {}
			cur_xc_map[x][i]=xc_type
			M.check_can_fix_by_point(map,x,i,xc_map,xc_type,1,hash_map,is_clear,cur_xc_map)
			if is_clear then
			  map[x][i]=0
			end
		  end
		end
	  end
	elseif not high_or_wide or high_or_wide==0 then
	  hash_map={}
	  xc_type=xc_type or map[x][y]
	  if not hash_map[x] or (hash_map[x] and not hash_map[x][y]) then
		M.check_can_fix_by_point(map,x,y,xc_map,xc_type,1,hash_map,is_clear,cur_xc_map)
	  end
	  if not hash_map[x] or (hash_map[x] and not hash_map[x][y]) then
		M.check_can_fix_by_point(map,x,y,xc_map,xc_type,2,hash_map,is_clear,cur_xc_map)
	  end
	end
end

--  high_or_wide 0 表示 横竖都要搜索  1 表示横向搜索  2表示竖向搜索  is_clear--是否清除
function M.check_can_fix_by_point_2(map,x,y,xc_map,xc_type,high_or_wide,hash_map,is_clear,cur_xc_map)
	if high_or_wide==1 then
	  local start_p=x
	  local end_p=x
	  while start_p>0 do
		if map[start_p] and map[start_p][y] and map[start_p][y]==xc_type then
		  start_p=start_p-1
		else
		  break
		end
	  end
	  start_p=start_p+1
	  while end_p<=M.wide_max do
		if map[end_p] and map[end_p][y] and  map[end_p][y]==xc_type then
		  end_p=end_p+1
		else
		  break
		end
	  end
	  end_p=end_p-1
	  if end_p-start_p+1>=1 then
		for i=start_p,end_p do
		  if not hash_map[i] or (hash_map[i] and not hash_map[i][y]) then
			hash_map[i] = hash_map[i] or {}
			hash_map[i][y]=true

			xc_map[i]=xc_map[i] or {}
			xc_map[i][y]=xc_type
			cur_xc_map[i]=cur_xc_map[i] or {}
			cur_xc_map[i][y]=xc_type
			M.check_can_fix_by_point_2(map,i,y,xc_map,xc_type,2,hash_map,is_clear,cur_xc_map)
			if is_clear then
				map[i][y]=0
			end
		  end
		end
	  end
	elseif high_or_wide==2 then
	  local start_p=y
	  local end_p=y
	  while start_p>0 do
		if map[x] and map[x][start_p] and map[x][start_p]==xc_type then
		  start_p=start_p-1
		else
		  break
		end
	  end
	  start_p=start_p+1
	  while end_p<=M.high_max do
		if map[x] and map[x][end_p] and map[x][end_p]==xc_type then
		  end_p=end_p+1
		else
		  break
		end
	  end
	  end_p=end_p-1
	  if end_p-start_p+1>=1 then
		for i=start_p,end_p do
		  if not hash_map[x] or (hash_map[x] and not hash_map[x][i]) then
			hash_map[x] = hash_map[x] or {}
			hash_map[x][i]=true

			xc_map[x]=xc_map[x] or {}
			xc_map[x][i]=xc_type
			cur_xc_map[x]=cur_xc_map[x] or {}
			cur_xc_map[x][i]=xc_type
			M.check_can_fix_by_point_2(map,x,i,xc_map,xc_type,1,hash_map,is_clear,cur_xc_map)
			if is_clear then
			  map[x][i]=0
			end
		  end
		end
	  end
	elseif not high_or_wide or high_or_wide==0 then
	  hash_map=hash_map or {}
	  xc_type=xc_type or map[x][y]
	  if not hash_map[x] or (hash_map[x] and not hash_map[x][y]) then
		M.check_can_fix_by_point_2(map,x,y,xc_map,xc_type,1,hash_map,is_clear,cur_xc_map)
	  end
	  if not hash_map[x] or (hash_map[x] and not hash_map[x][y]) then
		M.check_can_fix_by_point_2(map,x,y,xc_map,xc_type,2,hash_map,is_clear,cur_xc_map)
	  end
	end
end

function M.get_pos_by_index(x,y,size_x,size_y,spac_x,spac_y)
	size_x = 140
	size_y = 140
	spac_x = 30
	spac_y = 11
	local pos = {x = 0,y = 0}
	pos.x = (x - 1) * (size_x + spac_x)
	pos.y = (y - 1) * (size_y + spac_y)
	return pos, {x = x,y = y}
end

function M.get_bg_pos_by_index(x,y,size_x,size_y,spac_x,spac_y)
	size_x = size_x or 105
	size_y = size_y or 105
	spac_x = spac_x or 0
	spac_y = spac_y or 1
	local pos = {x = 0,y = 0}
	pos.x = (x - 1) * (size_x + spac_x)
	pos.y = (y - 1) * (size_y + spac_y)
	return pos
end

function M.get_index_by_pos(x,y,size_x,size_y,spac_x,spac_y)
	size_x = 140
	size_y = 140
	spac_x = 30
	spac_y = 11
	local index = {x = 1,y = 1}
	index.x = math.floor(x / (size_x + spac_x)) + 1
	index.y = math.floor(y / (size_y + spac_y)) + 1
	return index
end

function M.str_maps_conver_to_pos_maps(s,max_x)
	if not s then return end
	local t = unzip_data_to_proto(s)

	local c = {}
	local y = 1
	local x = 1
	local id = 0
	for i=1,#t do
		c[x] = c[x] or {}
		id = t[i]
		if tonumber(id) then
			if tonumber(t[i]) ~= 0 then
				c[x][y] = tonumber(id)
			end
		else
			c[x][y] = string.byte(id) - string.byte('a') + 9
		end
		x = x + 1
		if x > max_x then
			y = y + 1
			x = 1
		end
	end
	return c
end

function M.str_maps_conver_to_pos_maps_new(s,max_x)
	-- if not s then return end
	local c = {}
	local max_y = #s / max_x
	local i = 1
	local id = 0
	for y=1,max_y do
		for x=1,max_x do
			c[x] = c[x] or {}
			id = string.sub(s,i,i)
			if tonumber(id) then
				c[x][y] = tonumber(id)
			else
				c[x][y] = string.byte(id) - string.byte('a') + 10
			end
			i = i + 1
		end
	end
	return c
end

function M.str_conver_to_list(s)
	if not s then return end
	local c = {}
	local i = 1
	for i=1,#s do
		c[i] = tonumber(string.sub(s,i,i))
	end
	return c
end

--根据数组算出中心位置
function M.get_center_pos(map)
	local min_x = 10000
	local max_x = 0
	local min_y = 10000
	local max_y = 0
	for k,v in pairs(map) do
		if min_x > v.x then min_x = v.x end
		if max_x < v.x then max_x = v.x end
		if min_y > v.y then min_y = v.y end
		if max_y < v.y then max_y = v.y end
	end

	local count_x = max_x - min_x
	local count_y = max_y - min_y
	local center_x = count_x % 2 == 0 and count_x / 2 + min_x or (count_x + 1) / 2 + min_x
	local center_y = count_y % 2 == 0 and count_y / 2 + min_y or (count_y + 1) / 2 + min_y

	local min_dis = {dis = 10000,x = 0,y = 0}
	local dis = 0
	for k,v in pairs(map) do
		dis = Vector2.Distance(Vector2.New(v.x,v.y),Vector2.New(center_x,center_y))
		if dis < min_dis.dis then
			min_dis.dis = dis
			min_dis.x = v.x
			min_dis.y = v.y
		end
	end
	return M.get_pos_by_index(min_dis.x,min_dis.y)
end

function M.ConversionLittleRateToMap(str)
	local tab = {}
	local i = 1
	for y=1,M.high_max do
		for x=1,M.wide_max do
			local rate = tonumber(string.sub(str,i,i))
			tab[x] = tab[x] or {}
			tab[x][y] = rate
			i = i + 1
		end
	end
	return tab
end

function M.sever_data_convert_client_data(s_d)
	--s_d.xc_data = "77147545441447574445254557525573243417455575732445544147213402777074720444703750050700707007000"
	dump(s_d, "<color=green>服务器数据</color>")
	if not s_d then return end
	s_d.all_rate = s_d.all_rate or 0	--总倍率
	s_d.all_money = s_d.all_money or 0	--总金币(包括基础消)
	s_d.cur_money = s_d.cur_award or 0	--当前的总金币
	s_d.all_rate = s_d.all_rate / 100

	if s_d.xc_data then
		if true--[[s_d.is_local--]] then
			s_d.xc_data = M.str_maps_conver_to_pos_maps_new(s_d.xc_data,M.wide_max)
		else
			s_d.xc_data = M.str_maps_conver_to_pos_maps(s_d.xc_data,M.wide_max)
		end
	end
	
	dump(s_d, "<color=green>客户端数据</color>")
end

--根据开奖信息计算出本局开奖数据
function M.compute_eliminate_result(data)
	dump(data,"<color=yellow><size=15>++++++++++data++++++++++</size></color>")
	-- 正常模式和小游戏模式

	--[[data.has_little = 1
	data.rate_data_little = "65102602553015412426"
	if data.state == "nor" then
		data.xc_data = "66636636666366666666"
	else
		data.xc_data = "6663668666616666666605050070100001000030000100003000030"
	end--]]


	M.sever_data_convert_client_data(data)
	local c_d = data

	--开奖结果全存在这里
	local eliminate_data = {}
	eliminate_data.all_rate = c_d.all_rate
	eliminate_data.all_money = c_d.all_money
	eliminate_data.all_money_only_xc = 0
	eliminate_data.state = c_d.state
	eliminate_data.has_little = c_d.has_little == 1
	if c_d.rate_data_little then
		eliminate_data.little_rate_map = M.ConversionLittleRateToMap(c_d.rate_data_little)
	end
	if c_d.fake_rate_data_little then
		eliminate_data.fake_little_rate_map = M.ConversionLittleRateToMap(c_d.fake_rate_data_little)
	end

	eliminate_data.award_pools = c_d.award_pools
	eliminate_data.little_spec_rate = c_d.little_spec_rate / 100
	eliminate_data.xiaochu_award = c_d.xiaochu_award

	eliminate_data.take_pool_id = c_d.take_pool_id
	eliminate_data.take_pool_award = c_d.take_pool_award

	local temp_tab = {}
	c_d.cur_free_times = 1

	local result = {}
	local lottery	--开奖函数
	local recursive_count = 0 --递归计数c_d
	local eliminate_compute --消除计算

	local maps = {}--消除表

	local function save_data(data)
		table.insert(result,data)
	end

	local function map_remove(data)
		local _del = {}
		for x,_v in pairs(data.map_new) do
			for y,v in pairs(_v) do
				if v < 100 then
					_del[x] = _del[x] or {}
					_del[x][y] = v
				end
			end
		end
		M.map_remove(maps, _del)
		M.map_xc_aegis(maps)
	end

	--标记特殊元素id
	local function mark_fixed_id(data)
		for i=1,M.wide_max do
			for j=1,M.high_max do
				if data.fix_map and data.fix_map[i] and data.fix_map[i][j] then
					if data.fix_map[i][j] == 6 then
						data.map_base[i][j] = 101
						maps[i][j] = 101
					elseif data.fix_map[i][j] == 7 then
						data.map_base[i][j] = 102
						maps[i][j] = 102
					elseif data.fix_map[i][j] == 8 then
						data.map_base[i][j] = 103
						maps[i][j] = 103
					elseif data.fix_map[i][j] == 9 then
						data.map_base[i][j] = 100
						maps[i][j] = 100
					end
				elseif data.trigger_list and data.trigger_list[i] and data.trigger_list[i][j] then
					if data.trigger_list[i][j] == 6 then
						data.map_base[i][j] = 101
						maps[i][j] = 101
					elseif data.trigger_list[i][j] == 7 then
						data.map_base[i][j] = 102
						maps[i][j] = 102
					elseif data.trigger_list[i][j] == 8 then
						data.map_base[i][j] = 103
						maps[i][j] = 103
					elseif data.trigger_list[i][j] == 9 then
						data.map_base[i][j] = 100
						maps[i][j] = 100
					end
				end
			end
		end
	end

	--设置倍率
	local function set_rate_list(data)
		if not table_is_null(data.del_list) then
			data.del_rate_list = data.del_rate_list or {}
			for i,v in ipairs(data.del_list) do
				local c = M.get_xc_count(v)
				local n = M.get_xc_id(v)
				local rate = 0
				rate = M.get_rate(n,c)
				table.insert(data.del_rate_list, rate)
			end
		end
	end

	--更新奖励额(只统计消除所得)
	local function update_all_money_only_xc(data)
		if not table_is_null(data.del_rate_list) then
			for i=1,#data.del_rate_list do
				eliminate_data.all_money_only_xc = eliminate_data.all_money_only_xc + (EliminateFXModel.data.bet[1] * data.del_rate_list[i])
			end
		end
	end

	local function save_maps(data)
		--消除表
		data.map_del = basefunc.deepcopy(data.del_map)
		M.map_remove(maps,data.map_del)
		M.map_xc_aegis(maps)
		data.map_add = M.get_tj_map(maps,data.map_del)
		data.map_new = M.get_xc_map(maps) --过程表
	end

	lottery = function (data)
		--普通消除
		data.map_base = M.get_xc_map(maps) --过程表
		local xc_map =  M.get_xc_map(maps)

		--忽略的元素Id
		local not_check_id_map = {[0] = 0,[6] = 6, [7] = 7, [8] = 8, [9] = 9, [100] = 100, [101] = 101, [102] = 102, [103] = 103}
		data.del_list,data.del_map = M.get_eliminate_all_element(xc_map,not_check_id_map)

		--可能
		local maybe_fixed_id_map = {[6] = 6, [7] = 7, [8] = 8, [9] = 9,[100] = 100,[101] = 101, [102] = 102, [103] = 103} --特殊元素
		local xc_map =  M.get_xc_map(maps)
		if data.state == M.xc_state.big_game then
			data.fix_list,data.fix_map = M.get_fixed_all_element_2(xc_map,maybe_fixed_id_map)
		else
			data.fix_list,data.fix_map = M.get_fixed_all_element(xc_map,maybe_fixed_id_map)
			if not table_is_null(data.fix_list) and not table_is_null(data.fix_map) then
				eliminate_data.trigger = true
				if not table_is_null(result) then
					for i=1,#result do
						if not table_is_null(result[i].trigger_list) then
							result[i].trigger_list = nil
						end
					end
				end
				local temp_tab = {}
				for i=1,#data.fix_list do
					for x=1,M.wide_max do
						for y=1,M.high_max do
							if data.fix_list[i][x] and data.fix_list[i][x][y] then
								temp_tab[x] = temp_tab[x] or {}
								temp_tab[x][y] = data.fix_list[i][x][y]
							end
						end
					end
				end
				data.trigger_list = temp_tab
			end
		end

		mark_fixed_id(data)
		set_rate_list(data)
		update_all_money_only_xc(data)
		save_maps(data)
		if data.state == M.xc_state.big_game then
			if #result > 0 then
				if result[#result].is_fire then
					data.is_scroll = true
					local times = 8
					for k,v in pairs(result) do
						if v.is_scroll then
							times = times - 1
						end
					end
					if data.is_scroll then
						times = times - 1
					end
					data.free_times = times
				else
					data.free_times = result[#result].free_times
				end
				if data.is_scroll then
					result[#result].need_refresh = true
				end
			else
				data.free_times = 8
			end
		end
		if not table_is_null(data.del_list) then
			save_data(data)
			eliminate_compute(data.state)
		else
			if data.state == M.xc_state.big_game then
				data.is_fire = true
				if c_d.cur_free_times and c_d.cur_free_times <= 8 then
					c_d.cur_free_times = c_d.cur_free_times + 1
					local special_list = {}
					for i=1,M.wide_max do
						for j=M.high_max,1,-1 do
							if (data.map_base[i] and data.map_base[i][j] and data.map_base[i][j] >= 100) and (not temp_tab[i] or not temp_tab[i][j]) then
								temp_tab[i] = temp_tab[i] or {}
								temp_tab[i][j] = data.map_base[i][j]
								special_list[#special_list + 1] = {x = i,y = j,v = data.map_base[i][j]}
							end
						end
					end
					data.special_list = basefunc.deepcopy(special_list)
					save_data(data)
					map_remove(data)
					eliminate_compute(data.state)
				end
			else
				save_data(data)
			end
		end
	end

	eliminate_compute = function (cur_state,free_game_start)
		if recursive_count > 100 then
			--print("<color=red>递归计数</color>",recursive_count)
			return
		end
		--print("<color=red>递归计数</color>",recursive_count)

		recursive_count = recursive_count + 1
		maps = c_d.xc_data
		local data = {}
		data.state = cur_state

		lottery(data)
	end

	if not table_is_null(c_d.xc_data) then
		eliminate_compute(c_d.state)
	end

	eliminate_data.result = basefunc.deepcopy(result)
	--验证数据
	return eliminate_data
end

--根据map获取一个供检查消除的表
function M.get_xc_map(maps)
	local xc_map = {}
	for x=1,M.wide_max do
		for y=1,M.high_max do
			xc_map[x] = xc_map[x] or {}
			xc_map[x][y] = maps[x][y]
		end
	end
	return xc_map
end

function M.get_xc_id(xc_map)
	if table_is_null(xc_map) then return 0 end
	for x,v1 in pairs(xc_map) do
		for y,v in pairs(v1) do
			return v
		end
	end
end

function M.get_xc_count(xc_map)
	local count = 0
	if table_is_null(xc_map) then return count end
	for x,_v in pairs(xc_map) do
		for x,v in pairs(_v) do
			count = count + 1
		end
	end
	return count
end

function M.get_xc_y_count(xc_map_y)
	local count = 0
	if table_is_null(xc_map_y) then return count end
	for y,_v in pairs(xc_map_y) do
		count = count + 1
	end
	return count
end

function M.get_tj_map(maps,xc_map)
	--dump(maps,"<color=yellow><size=15>++++++++++maps++++++++++</size></color>")
	--dump(xc_map,"<color=yellow><size=15>++++++++++xc_map++++++++++</size></color>")
	if not xc_map or type(xc_map) ~= "table" or not next(xc_map) then return end
	local tj_map = {}
	local start_y = {}
	local xc_n = {}
	for x,v in pairs(xc_map) do
		xc_n[x] = M.get_xc_y_count(v)
	end
	for x=1,M.wide_max do
		if xc_n[x] then
			local n = xc_n[x]
			for y=M.high_max,1,-1 do
				if maps[x] and maps[x][y] and maps[x][y] < 100 then
					n = n - 1
					if n == 0 then
						start_y[x] = y
						break
					end
				end
			end
		end
	end
	for x=1,M.wide_max do
		if xc_n[x] then
			local n = xc_n[x]
			for y=start_y[x], M.high_max do
				if maps[x] and maps[x][y] and maps[x][y] < 100 then
					tj_map[x] = tj_map[x] or {}
					tj_map[x][y] = maps[x][y]
				end
			end
		end
	end
	if next(tj_map) then
		return tj_map
	end
end

function M.map_merge(map,t_map)
	if not t_map or type(t_map) ~= "table" or not next(t_map) then return end
	if not map then map = {} end
	for x,_v in pairs(t_map) do
		for y,v in pairs(_v) do
			map[x] = map[x] or {}
			map[x][y] = v
		end
	end
end

function M.map_remove(map,t_map)
	if not map or type(map) ~= "table" or not next(map) then return end
	if not t_map or type(t_map) ~= "table" or not next(t_map) then return end
	for x,_v in pairs(t_map) do
		local fix_list = {}
		for y=1, M.high_max do
			if map[x][y] >= 100 then
				fix_list[x] = fix_list[x] or {}
				fix_list[x][y] = {y=y, v=map[x][y]}
			end
		end
		for y=M.high_max,1, -1 do
			if _v[y] or (fix_list[x] and fix_list[x][y]) then
				if map[x] and map[x][y] then
					table.remove(map[x], y)
				end
			end
		end
		for y=1, M.high_max do
			if fix_list[x] and fix_list[x][y] then
				table.insert(map[x], fix_list[x][y].y, fix_list[x][y].v)
			end
		end
	end
end

function M.map_get(map,t_map)
	if not map or type(map) ~= "table" or not next(map) then return end
	if not t_map or type(t_map) ~= "table" or not next(t_map) then return end
	local get_map = {}
	for x,_v in pairs(t_map) do
		for y=M.high_max,1, -1 do
			if (_v[y]) then
				get_map[x] = get_map[x] or {}
				get_map[x][y] = map[x][y]
			end
		end
	end
	return get_map
end

function M.map_xc_aegis(maps)
	for x=1,M.wide_max do
		for y=1,M.high_max do
			if not maps[x] or not maps[x][y] then
				maps[x] = maps[x] or {}
				maps[x][y] = 0
			end
		end
	end
end

function M.get_all_del_list(result)
	local all_del_list = {}
	for i,_v in ipairs(result) do
		if not table_is_null(_v.del_list) then
			for i,v in ipairs(_v.del_list) do
				table.insert(all_del_list,basefunc.deepcopy(v))
			end
		end
	end
	return all_del_list
end

function M.get_all_del_rate_list(result)
	for i,_v in ipairs(result) do
	end
	return 1
end

function M.get_map_max_index(map)
	local pos = {}
	pos.x = 0
	pos.y = 0
	for x,_v in pairs(map) do
		if pos.x < x then
			pos.x = x
		end
		for y,v in pairs(_v) do
			if pos.y < y then
				pos.y = y
			end
		end
	end
	return pos
end

--二维表变成一维表
function M.change_map_to_list(map)
	if table_is_null(map) then return end
	local max_x = 0
	local max_y = 0
	for x,_v in pairs(map) do
		if max_x < x then
			max_x = x
		end
		for y,v in pairs(_v) do
			if max_y < y then
				max_y = y
			end
		end
	end

	local list = {}
	for x,_v in pairs(map) do
		for y,v in pairs(_v) do
			table.insert( list,{x = x,y = y,v = v})
		end
	end
	return M.array_sort(list,max_x,max_y)
end

--一维表变成二维表
function M.change_list_to_map(list)
	if table_is_null(list) then return end
	local map = {}
	for i,v in ipairs(list) do
		map[v.x] = map[v.x] or {}
		map[v.x][v.y] = v.id
	end
	return map
end

function M.array_sort(t,max_x,max_y)
	if table_is_null(t) then return end
	local _t = {}
    --从左到右，从上到下，先行后列
    for y = max_y,1,-1 do
        for x = 1,max_x do
            for k,v in pairs(t) do
                if v.x == x and v.y == y then
					table.insert(_t,v)
                end
            end
        end
	end
	if next(_t) then
		t = _t
	end
	return t
end

-- function M.GetCalculateRate(data)
-- 	local tab = {}--最终结果表
-- 	local little_rate_map = basefunc.deepcopy(EliminateFXModel.data.eliminate_data.little_rate_map)
-- 	for i,v in ipairs(data.result) do
-- 		if not table_is_null(v.special_list) then
-- 			for ii,vv in ipairs(v.special_list) do
-- 				for x=1,M.wide_max do
-- 					for y=1,M.high_max do
-- 						if vv.x ~= x and vv.y ~= y then
-- 							if little_rate_map[x] and little_rate_map[x][y] and little_rate_map[x][y] ~= 0 then
-- 								local need_add = false
-- 								if vv.v == 101 then
-- 									if vv.v > v.map_base[x][y] then
-- 										need_add = true
-- 									end
-- 								elseif vv.v == 102 then
-- 									if vv.v > v.map_base[x][y] then
-- 										need_add = true
-- 									end
-- 								elseif vv.v == 103 then
-- 									if vv.v == v.map_base[x][y] then
-- 										need_add = true
-- 									end
-- 								end
-- 								if need_add then
-- 									tab[vv.x] = tab[vv.x] or {}
-- 									tab[vv.x][vv.y] = tab[vv.x][vv.y] or 0
-- 									tab[vv.x][vv.y] = tab[vv.x][vv.y] + little_rate_map[x][y]
-- 									little_rate_map[x][y] = 0
-- 								end
-- 							elseif tab[x] and tab[x][y] and tab[x][y] ~= 0 then
-- 								local need_add = false
-- 								if vv.v == 101 then
-- 									if vv.v > v.map_base[x][y] then
-- 										need_add = true
-- 									end
-- 								elseif vv.v == 102 then
-- 									if vv.v > v.map_base[x][y] then
-- 										need_add = true
-- 									end
-- 								elseif vv.v == 103 then
-- 									if vv.v == v.map_base[x][y] then
-- 										need_add = true
-- 									end
-- 								end
-- 								if need_add then
-- 									tab[vv.x] = tab[vv.x] or {}
-- 									tab[vv.x][vv.y] = tab[vv.x][vv.y] or 0
-- 									tab[vv.x][vv.y] = tab[vv.x][vv.y] + tab[x][y]
-- 								end
-- 							end
-- 						end
-- 					end
-- 				end
-- 			end
-- 		end
-- 	end
-- 	return tab
-- end

function M.get_big_game_primary_rate_map()
	local primaryMap = {}
	for i = 1, 5 do
		primaryMap[i] = primaryMap[i] or {}
		for j = 1, 4 do
			primaryMap[i][j] = 0
		end
	end
	return primaryMap
end