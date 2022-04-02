local basefunc = require "Game.Common.basefunc"
eliminate_cs_algorithm = basefunc.class()
local M = eliminate_cs_algorithm

M.xc_limit=3
M.high_max=8
M.wide_max=8
--消除元素的倍率表，*10倍的结果
M.rate_map = {
	{0,0,1,2,5,10,15,50},--1铜钱
	{0,0,2,4,10,20,30,100},--2宝石
	{0,0,4,8,20,40,60,200},--3玉石
	{0,0,10,20,40,80,120,400},--4金猪
	{0,0,20,40,80,160,240,800},--5财神
	{0,0,4,8,20,40,60,200},--6 金蛋
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

M.eliminate_id ={
	[0] = 0,
	[1] = 1,
	[2] = 2,
	[3] = 3,
	[4] = 4,
	[5] = 5,
	[6] = 6,
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
				-- M.check_can_xc_by_point(map,x,y,xc_map,xc_type,high_or_wide,hash_map,is_clear,cur_xc_map)
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
	  while end_p<=M.high_max do
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
	  while end_p<=M.wide_max do
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

function M.get_pos_by_index(x,y,size_x,size_y,spac_x,spac_y)
	size_x = size_x or 114
	size_y = size_y or 114
	spac_x = spac_x or 4
	spac_y = spac_y or 4
	local pos = {x = 0,y = 0}
	pos.x = (x - 1) * (size_x + spac_x)
	pos.y = (y - 1) * (size_y + spac_y)
	return pos, {x = x,y = y}
end

function M.get_bg_pos_by_index(x,y,size_x,size_y,spac_x,spac_y)
	size_x = size_x or 118
	size_y = size_y or 118
	spac_x = spac_x or 0
	spac_y = spac_y or 0
	local pos = {x = 0,y = 0}
	pos.x = (x - 1) * (size_x + spac_x)
	pos.y = (y - 1) * (size_y + spac_y)
	return pos
end

function M.get_index_by_pos(x,y,size_x,size_y,spac_x,spac_y)
	size_x = size_x or 114
	size_y = size_y or 114
	spac_x = spac_x or 4
	spac_y = spac_y or 4
	local index = {x = 1,y = 1}
	index.x = math.floor(x / (size_x + spac_x)) + 1
	index.y = math.floor(y / (size_y + spac_y)) + 1
	return index
end

function M.str_maps_conver_to_pos_maps(s,max_x)
	-- if not s then return end
	local c = {}
	local max_y = #s / max_x
	local i = 1
	local id = 0
	for y=1,max_y do
		for x=1,max_x do
			c[x] = c[x] or {}
			id = string.sub(s,i,i)
			c[x][y] = tonumber(id)
			i = i + 1
		end
	end
	return c
end

function M.get_str_lmaps_by_str_fmaps(fm,lm)
	local new_lm = ""
	local id = 0
	local lm_index = 1
	for i=1,#fm do
		id = string.sub(fm,i,i)
		if tonumber(id) == M.eliminate_id[6] then
			id = string.sub(lm,lm_index,lm_index)
			lm_index = lm_index + 1
		else
			id = 0
		end
		new_lm = new_lm .. id
	end
	return new_lm
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

M.xc_state = {
	nor = "nor", --普通消除
	zd = "zd",	--砸蛋
	zd_tnsh = "zd_tnsh",	--砸蛋天女散花
	zp = "zp",	--转盘
	zp_tnsh = "zp_tnsh",	--转盘天女散花
}

--正常开奖
function M.compute_eliminate_result_nor(data)
	local _data = {}
	_data.total_xc_data = {}
	local _d = {}
	_d.money = data.all_money
	_d.rate = data.all_rate
	if not table_is_null(data.tnsh_all_data) then
		_d.money = data.all_money - data.tnsh_all_data.all_money
		_d.rate = data.all_rate - data.tnsh_all_data.all_rate
	end
	_d.all_jindan_value = data.all_jindan_value
	_d.xc_maps = data.xc_data
	if not table_is_null(data.jindan_word_vec) then
		_d.jindan_word_vec = data.jindan_word_vec
	end
	_d.jindan_value = 0
	if not table_is_null(data.total_jindan_xiaochu_value_one) then
		_d.jindan_value_list = data.total_jindan_xiaochu_value_one
		for i,v in ipairs(data.total_jindan_xiaochu_value_one) do
			_d.jindan_value = _d.jindan_value + v
		end
	end
	if not table_is_null(data.zadan_item_vec) then
		_d.zd_maps = ""
		for i,v in ipairs(data.zadan_item_vec) do
			_d.zd_maps = _d.zd_maps .. v
		end
	end
	_d.tnsh_type = data.sky_girl_type
	_d.tnsh_rate = data.sky_girl_extra_rate
	_data.total_xc_data[1] = basefunc.deepcopy(_d)

	_d = {}
	if not table_is_null(data.tnsh_all_data) then
		_d.money = data.tnsh_all_data.all_money
		_d.rate = data.tnsh_all_data.all_rate
		_d.xc_maps = data.tnsh_all_data.xc_data
		_d.hb_maps = data.tnsh_all_data.change_data
	end
	_data.total_xc_data[2] = basefunc.deepcopy(_d)

	return M.compute_eliminate_result(_data)
end

--转盘开奖
function M.compute_eliminate_result_zp(data)
	local _data = {}
	_data.total_xc_data = {}
	local _d = {}
	if not table_is_null(data.tnsh_all_data) then
		_d.money = data.tnsh_all_data.all_money
		_d.rate = data.tnsh_all_data.all_rate
		_d.xc_maps = data.tnsh_all_data.xc_data
		_d.hb_maps = data.tnsh_all_data.change_data
		_d.all_jindan_value = data.tnsh_all_data.all_jindan_value
		_d.index = data.tnsh_all_data.index
	end
	_data.total_xc_data[3] = basefunc.deepcopy(_d)
	return M.compute_eliminate_result(_data)
end

--根据开奖信息计算出本局开奖数据
function M.compute_eliminate_result(data)
	dump(data,"<color=red>根据开奖信息计算出本局开奖数据</color>")
	local sever_data = {}
	sever_data.all_rate = 0
	sever_data.all_money = 0
	sever_data.xc_data = data.total_xc_data
	for i=1,3 do
		if not table_is_null(data.total_xc_data[i]) then
			if data.total_xc_data[i].rate then
				sever_data.all_rate = sever_data.all_rate + data.total_xc_data[i].rate
			end
			if data.total_xc_data[i].money then
				sever_data.all_money = sever_data.all_money + data.total_xc_data[i].money
			end
		end
	end	
	dump(sever_data, "<color=green>服务器数据</color>")

	--开奖过程中的数据，包括初始的map和每次开奖的后的数据
	local eliminate_data = {}

	local maps = {}
	--花瓣
	local hb_maps = {}
	if not table_is_null(sever_data.xc_data[1]) then
		if sever_data.xc_data[1].xc_maps then
			maps = M.str_maps_conver_to_pos_maps(sever_data.xc_data[1].xc_maps,M.wide_max)
		end
	end

	eliminate_data.all_rate = sever_data.all_rate
	eliminate_data.all_money = sever_data.all_money
	eliminate_data.all_tnsh_list = {[1] = 0,[2] = 0,[3] = 0,[4] = 0,}
	if not table_is_null(sever_data.xc_data[1]) and sever_data.xc_data[1].all_jindan_value then
		eliminate_data.all_jindan_value = sever_data.xc_data[1].all_jindan_value
		eliminate_data.all_jindan_value_cur = sever_data.xc_data[1].all_jindan_value - sever_data.xc_data[1].jindan_value	
	end

	if not table_is_null(sever_data.xc_data[3]) and sever_data.xc_data[3].all_jindan_value then
		eliminate_data.all_jindan_value = sever_data.xc_data[3].all_jindan_value
		eliminate_data.all_jindan_value_cur = sever_data.xc_data[3].all_jindan_value
	end

	--开奖结果全存在这里
	local result = {}
	local lottery	--开奖函数
	local recursive_count = 0 --递归计数
	local eliminate_compute --消除计算

	local function save_data(data)
		--消除表
		data.map_base = M.get_show_map(maps) --过程表
		--先改变
		if not table_is_null(data.hb_map_change) then
			for x,_v in pairs(data.hb_map_change) do
				for y,v in pairs(_v) do
					maps[x][y] = v
				end
			end
		end
		data.map_del = basefunc.deepcopy(data.del_map)
		M.map_remove(maps,data.map_del)
		M.map_xc_aegis(maps)
		data.map_add = M.get_tj_map(maps,data.map_del)
		data.map_new = M.get_show_map(maps) --过程表
		--花瓣表
		if (data.state == M.xc_state.zd_tnsh or data.state == M.xc_state.zp_tnsh) and not table_is_null(hb_maps) then
			local xc_map = M.get_xc_map(hb_maps)
			M.map_remove(hb_maps,xc_map)
			M.map_xc_aegis(hb_maps)
			M.get_tj_map(hb_maps,xc_map)
		end
		table.insert(result,data)
	end

	local function set_rate_list(data)
		if not table_is_null(data.del_list) then
			data.del_rate_list = data.del_rate_list or {}
			for i,v in ipairs(data.del_list) do
				local c = M.get_xc_count(v)
				local n = M.get_xc_id(v)
				local rate = M.get_rate(n,c)
				table.insert( data.del_rate_list, rate)
			end
		end
	end

	local function set_jd_data(data)
		if data.state == M.xc_state.nor and not table_is_null(data.del_list) then
			for i,v in ipairs(data.del_list) do
				local xc_id = M.get_xc_id(v)
				if xc_id == 6 then
					data.all_tnsh_list = data.all_tnsh_list or {}
					data.all_jindan_value_list = data.all_jindan_value_list or {}
					--金蛋集字
					if not table_is_null(sever_data.xc_data[1].jindan_word_vec) then
						local n = sever_data.xc_data[1].jindan_word_vec[1]
						table.remove(sever_data.xc_data[1].jindan_word_vec,1)
						if n and n ~= 0 then
							table.insert( data.all_tnsh_list, n)
							eliminate_data.all_tnsh_list[n] = eliminate_data.all_tnsh_list[n] + 1
							data.all_tnsh_list_cur = basefunc.deepcopy(eliminate_data.all_tnsh_list)
						end
					end
					--金蛋进度
					if not table_is_null(sever_data.xc_data[1].jindan_value_list) then
						local c = sever_data.xc_data[1].jindan_value_list[1]
						table.remove(sever_data.xc_data[1].jindan_value_list,1)
						if c and c ~= 0 then
							table.insert( data.all_jindan_value_list, c)
							eliminate_data.all_jindan_value_cur = eliminate_data.all_jindan_value_cur + c
							data.all_jindan_value_cur = eliminate_data.all_jindan_value_cur
						end
					end
				end
			end
		end
	end

	lottery = function (data)
		--普通消除
		local xc_map = M.get_xc_map(maps)
		if data.state == M.xc_state.zd_tnsh or data.state == M.xc_state.zp_tnsh then
			local hb_map = M.get_xc_map(hb_maps)
			--先改变
			if not table_is_null(hb_map) then
				data.hb_map_change = {}
				for x=1,M.wide_max do
					for y=1,M.high_max do
						if hb_map[x] and hb_map[x][y] and hb_map[x][y] ~= 0 then
							xc_map[x] = xc_map[x] or {}
							xc_map[x][y] = hb_map[x][y]
							data.hb_map_change[x] = data.hb_map_change[x] or {}
							data.hb_map_change[x][y] = hb_map[x][y]
						end
					end
				end	
			end
		end
		local not_check_id_map = {[0] = 0}
		data.del_list,data.del_map = M.get_eliminate_all_element(xc_map,not_check_id_map)
		set_rate_list(data)
		set_jd_data(data)
		save_data(data)
		if not table_is_null(data.del_list) then
			eliminate_compute(data.state)
		else
			if data.state == M.xc_state.zp_tnsh or data.state == M.xc_state.zd_tnsh then
				if not table_is_null(hb_maps) then
					local is_hb = false
					for x,_v in pairs(hb_maps) do
						for y,v in pairs(_v) do
							if v ~= 0 then
								is_hb = true
								break
							end
						end
					end
					if is_hb then
						--本屏没有可消除，但是还有花瓣
						eliminate_compute(data.state)
					end
				end
			end
		end
	end

	eliminate_compute = function (cur_state)
		if recursive_count > 100 then
			print("<color=red>递归计数</color>",recursive_count)
			return
		end
		recursive_count = recursive_count + 1
		local data = {}
		data.state = cur_state
		lottery(data)
	end

	if not table_is_null(sever_data.xc_data[1]) then
		eliminate_compute(M.xc_state.nor)
	end

	--砸金蛋
	if not table_is_null(sever_data.xc_data[1]) and sever_data.xc_data[1].zd_maps then
		local data = {}
		data.state = M.xc_state.zd
		data.zd_list = M.str_conver_to_list(sever_data.xc_data[1].zd_maps)
		if sever_data.xc_data[1].tnsh_type then
			--天女散花
			data.tnsh_type = sever_data.xc_data[1].tnsh_type
			data.tnsh_rate = sever_data.xc_data[1].tnsh_rate
		end
		data.map_base = M.get_show_map(maps) --过程表
		table.insert(result,data)
		if not table_is_null(sever_data.xc_data[2]) then
			maps = M.str_maps_conver_to_pos_maps(sever_data.xc_data[2].xc_maps,M.wide_max)
			hb_maps = M.str_maps_conver_to_pos_maps(sever_data.xc_data[2].hb_maps,M.wide_max)
			eliminate_compute(M.xc_state.zd_tnsh)			
		end
	end

	--转盘
	if not table_is_null(sever_data.xc_data[3]) then
		local data = {}
		data.state = M.xc_state.zp
		data.index = sever_data.xc_data[3].index
		-- data.map_base = M.get_show_map(maps) --过程表
		table.insert(result,data)
		if sever_data.xc_data[3].xc_maps then
			maps = M.str_maps_conver_to_pos_maps(sever_data.xc_data[3].xc_maps,M.wide_max)
			hb_maps = M.str_maps_conver_to_pos_maps(sever_data.xc_data[3].hb_maps,M.wide_max)
			eliminate_compute(M.xc_state.zp_tnsh)
		end
	end

	eliminate_data.result = basefunc.deepcopy(result)
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

--根据map获取一个供检查消除的表
function M.get_show_map(maps)
	local show_map = {}
	for x=1,M.wide_max do
		for y=1,M.high_max do
			show_map[x] = show_map[x] or {}
			show_map[x][y] = maps[x][y]
		end
	end
	return show_map
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
	if not xc_map or type(xc_map) ~= "table" or not next(xc_map) then return end
	local tj_map = {}
	local start_y = {}
	for x,v in pairs(xc_map) do
		start_y[x] = M.high_max - M.get_xc_y_count(v) + 1
	end
	for x,_v in pairs(xc_map) do
		for y,v in pairs(_v) do
			tj_map[x] = tj_map[x] or {}
			tj_map[x][start_y[x]] = maps[x][start_y[x]]
			start_y[x] = start_y[x] + 1
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
		for y=M.high_max,1, -1 do
			if (_v[y]) then
				if map[x] and map[x][y] then
					table.remove(map[x], y)
				end
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
	local all_del_list = {}
	for i,_v in ipairs(result) do
		if _v.del_rate_list then
			for i,v in ipairs(_v.del_rate_list) do
				table.insert(all_del_list,basefunc.deepcopy(v))
			end
		end
	end
	return all_del_list
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