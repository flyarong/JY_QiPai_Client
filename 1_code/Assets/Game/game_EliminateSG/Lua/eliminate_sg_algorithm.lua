local basefunc = require "Game.Common.basefunc"
eliminate_sg_algorithm = basefunc.class()
local M = eliminate_sg_algorithm

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
M.high_max = 8
M.wide_max = 8
--消除元素的倍率表，*10倍的结果
M.rate_map = {
	{0,0, 1,2,5,10,20,50,},--//1 粮草
    {0,0, 2,5,10,20,40,80,},--//2 元宝
    {0,0, 5,10,20,40,80,150,},--//3 头盔
    {0,0, 10,20,40,80,150,300,},--//4 铠甲
    {0,0, 20,40,80,150,300,600},--//5 战马
	{0,0, 5,10,20,40,80,150,},--6 虎符
	{0,},--7 战船
	{0,},--8 草船
	{0,},--9 箭a
	{0,},--10 箭b
	{0,},--11 箭c
	{0,},--12 箭d
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
	[0] = 0,
	[1] = 1,
	[2] = 2,
	[3] = 3,
	[4] = 4,
	[5] = 5,
	[6] = 6,
	[7] = 7,
	[8] = 8,
	[9] = 9,
	[10] = 10,
	[11] = 11,
	[12] = 12,
	[100] = 100, -- 点燃的船
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
function M.get_pos_by_indexTX(x,y,size_x,size_y,spac_x,spac_y)
	size_x = size_x or 101
	size_y = size_y or 102
	spac_x = spac_x or 4
	spac_y = spac_y or 4
	local pos = {x = 0,y = 0}
	pos.x = (x - 1) * (size_x + spac_x)
	pos.y = (y - 1) * (size_y + spac_y)
	return pos
end

function M.get_pos_by_index(x,y,size_x,size_y,spac_x,spac_y)
	if (EliminateSGModel.data.state == EliminateSGModel.xc_state.nor) or (EliminateSGModel.data.state == EliminateSGModel.xc_state.null) or (EliminateSGModel.data.state == EliminateSGModel.xc_state.select) then
	elseif (EliminateSGModel.data.state == EliminateSGModel.xc_state.hscb_2) or (EliminateSGModel.data.state == EliminateSGModel.xc_state.hscb_1) then
		size_x = 200
		size_y = 135
		spac_x = 0
		spac_y = 5
	elseif (EliminateSGModel.data.state == EliminateSGModel.xc_state.ccjj_2) or (EliminateSGModel.data.state == EliminateSGModel.xc_state.ccjj_cs) then
		size_x = 200
		size_y = 135
		spac_x = 0
		spac_y = 5
	end
	size_x = size_x or 105
	size_y = size_y or 105
	spac_x = spac_x or 0
	spac_y = spac_y or 1
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
	if (EliminateSGModel.data.state == EliminateSGModel.xc_state.nor) or (EliminateSGModel.data.state == EliminateSGModel.xc_state.null) or (EliminateSGModel.data.state == EliminateSGModel.xc_state.select) then
	elseif (EliminateSGModel.data.state == EliminateSGModel.xc_state.hscb_2) or (EliminateSGModel.data.state == EliminateSGModel.xc_state.hscb_1) then
		size_x = 200
		size_y = 135
		spac_x = 0
		spac_y = 5
	elseif (EliminateSGModel.data.state == EliminateSGModel.xc_state.ccjj_2) or (EliminateSGModel.data.state == EliminateSGModel.xc_state.ccjj_cs) then
		size_x = 200
		size_y = 135
		spac_x = 0
		spac_y = 5
	end
	size_x = size_x or 105
	size_y = size_y or 105
	spac_x = spac_x or 0
	spac_y = spac_y or 1
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

M.xc_state = {
	null = "nil",
	nor = "nor", --普通消除
	select = "select",--二选一
	hscb_2 = "hscb_2",	--火烧赤壁
	hscb_1 = "hscb_1",--火烧赤壁点火阶段
	ccjj_2 = "ccjj_2",	--草船借箭
	ccjj_cs = "ccjj_cs"
}

function M.sever_data_convert_client_data(s_d)
	--s_d.xc_data = "77147545441447574445254557525573243417455575732445544147213402777074720444703750050700707007000"
	dump(s_d, "<color=green>服务器数据</color>")

	if not s_d then return end

	s_d.all_rate = s_d.all_rate or 0	--总倍率
	s_d.all_money = s_d.all_award or 0	--总金币(包括基础消)
	s_d.cur_money = s_d.cur_award or 0	--当前的总金币
	s_d.all_rate = s_d.all_rate / 10

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
	if (data.state == M.xc_state.nor) or (data.state == M.xc_state.null) or (data.state == M.xc_state.select) then
		M.high_max = 8
		M.wide_max = 8
	else
		M.high_max = 4
		M.wide_max = 5
	end

	M.sever_data_convert_client_data(data)
	local c_d = data

	--开奖结果全存在这里
	local eliminate_data = {}
	eliminate_data.all_rate = c_d.all_rate
	eliminate_data.all_money = c_d.all_money
	eliminate_data.cur_money = c_d.cur_money
	--是否免费游戏
	eliminate_data.is_free_game = c_d.is_free_game
	eliminate_data.start_fire_index = c_d.start_fire_index
	
	if c_d.wind_data then
		eliminate_data.free_game_num_max = #c_d.wind_data
		eliminate_data.free_game_num_cur = 1
		c_d.free_game_num_max = #c_d.wind_data
		c_d.free_game_num_cur = 1
	end


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

	local function save_maps(data)
		--消除表
		data.map_del = basefunc.deepcopy(data.del_map)
		M.map_remove(maps,data.map_del)
		M.map_xc_aegis(maps)
		data.map_add = M.get_tj_map(maps,data.map_del)
		data.map_new = M.get_xc_map(maps) --过程表
	end

	local function set_rate_list(data)
		if not table_is_null(data.del_list) then
			data.del_rate_list = data.del_rate_list or {}
			for i,v in ipairs(data.del_list) do
				local c = M.get_xc_count(v)
				local n = M.get_xc_id(v)
				local rate = 0
				if n ~= M.eliminate_id[6] then
					rate = M.get_rate(n,c)
				elseif n == M.eliminate_id[6] then
					if eliminate_data.hf_skill_trigger_index and (i == eliminate_data.hf_skill_trigger_index) then
						rate = M.get_rate()
						eliminate_data.hf_skill_trigger_index = nil
					else
						rate = M.get_rate(n,c)
					end
				end
				table.insert(data.del_rate_list, rate)
			end
		end
	end

	--虎符
	local function trigger_hf_skill(data)
		if not table_is_null(data.del_list) and not eliminate_data.hf_skill_trigger then
			for k,v in pairs(data.del_list) do
				local xc_id = M.get_xc_id(v)
				if xc_id == M.eliminate_id[6] then
					eliminate_data.hf_skill_trigger = true
					data.hf_skill_trigger = true
					data.hf_skill_trigger_index = k
					eliminate_data.hf_skill_trigger_index = k
					break
				end
			end
		end
	end

	-- 火烧赤壁 Fun
	-- 火烧连环船


	local pos_hslh = {{x=-1,y=0},{x=1,y=0},{x=0,y=-1},{x=0,y=1}}
	local function hslh_fun(data, new_map)
		if table_is_null(new_map) then
			return
		end
		local lock_map = {}
		local flag = false
		while true do
			flag = false
			for k,v in pairs(new_map) do
				for kk,vv in ipairs(v) do
					if not lock_map[vv.x] or not lock_map[vv.x][vv.y] then
						lock_map[vv.x] = lock_map[vv.x] or {}
						lock_map[vv.x][vv.y] = vv
						for i = 1, #pos_hslh do
							local xx = vv.x + pos_hslh[i].x
							local yy = vv.y + pos_hslh[i].y
							if xx > 0 and xx <= M.wide_max and yy > 0 and yy <= M.high_max and maps[xx][yy] == M.eliminate_id[7] then
								flag = true
								maps[xx][yy] = 102
								data.map_new[xx][yy] = 102
								data.hslh_map[k+1] = data.hslh_map[k+1] or {}
								data.hslh_map[k+1][#data.hslh_map[k+1] + 1] = {x=xx, y=yy}
								--dump(data.hslh_map,"<color=yellow><size=15>++++++++++data.hslh_map++++++++++</size></color>")
							end
						end
					end
				end
			end
			if not flag then
				break
			else
				new_map = basefunc.deepcopy(data.hslh_map)
			end
		end
	end

	lottery = function (data)
		--普通消除
		data.map_base = M.get_xc_map(maps) --过程表
		local xc_map =  M.get_xc_map(maps)

		-- 空 战船 草船 箭a b c d 点燃的船
		local not_check_id_map = {[0] = 0,[7] = 7, [8] = 8, [9] = 9, [10] = 10, [11] = 11, [12] = 12, [100] = 100, [101] = 101, [102] = 102}
		data.del_list,data.del_map = M.get_eliminate_all_element(xc_map,not_check_id_map)
		
		trigger_hf_skill(data)
		set_rate_list(data)
		save_maps(data)

		if data.state == M.xc_state.hscb_2 then
			if #result > 0 then
				if result[#result].is_fire then
					data.is_scroll = true
					local times = 6
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
				data.free_times = 6
			end
		elseif data.state == M.xc_state.ccjj_2 then
			if #result > 0 then
				if result[#result].is_arrow then
					data.is_scroll = true
				end
			end
		end
		if not table_is_null(data.del_list) then
			save_data(data)
			eliminate_compute(data.state)
		else
			-- 消除完后才播放技能
			if data.state == M.xc_state.hscb_2 then
				
				dump({is_scroll = data.is_scroll}, "<color=red>  is_scrollis_scroll </color>")

				data.is_fire = true
				local ww = c_d.wind_data[c_d.free_game_num_cur]
				c_d.free_game_num_cur = c_d.free_game_num_cur + 1
				if ww then
					-- 火烧连环
					data.hslh_map = {}
					--dump(maps,"<color=yellow><size=15>++++++++++77777777777777777++++++++++</size></color>")
					--hslh_map[1]={}
					data.hslh_map[#data.hslh_map + 1] = data.hslh_map[#data.hslh_map + 1] or {}
					for x=1,M.wide_max do
						for y=1,M.high_max do
							if maps[x][y] >= 100 then
								data.hslh_map[#data.hslh_map][#data.hslh_map[#data.hslh_map]+1] = {x=x, y=y,id = id}
							end
						end
					end
					--dump(data.hslh_map,"<color=yellow><size=15>++++++++++8888888888888888++++++++++</size></color>")
					local hslh_map = basefunc.deepcopy(data.hslh_map)
					hslh_fun(data, hslh_map)
					
					-- 开始点燃船
					if ww == 1 then
						data.lit_list = {}
						for x=1,M.wide_max do
							for y=1,M.high_max do
								if maps[x][y] == M.eliminate_id[7] then
									data.lit_list[#data.lit_list + 1] = {x=x, y=y}
									maps[x][y] = 101
									data.map_new[x][y] = 101
								end
							end
						end
						print(#data.lit_list, "<color=red>data.lit_list </color>")
					end
					save_data(data)
					map_remove(data)
					eliminate_compute(data.state)
				else
					print("<color=red>WWWWWWWWWWWWWWWWWWWW </color>")
				end				
			elseif data.state == M.xc_state.ccjj_2 then
				data.is_arrow = true
				data.arrow_fly_list = {{},{},{},{}} -- 1-4 对应 9-12
				data.boat_fly_list = {}
				for x=1,M.wide_max do
					for y=1,M.high_max do
						if maps[x][y] >= M.eliminate_id[9] and maps[x][y] <= M.eliminate_id[12] then
							local ii = maps[x][y] - M.eliminate_id[9] + 1
							data.arrow_fly_list[ii][#data.arrow_fly_list[ii] + 1] = {x=x, y=y}
						end
						if maps[x][y] == M.eliminate_id[8] then
							data.boat_fly_list[#data.boat_fly_list + 1] = {x=x, y=y}
						end
					end
				end
				save_data(data)
				map_remove(data)
				eliminate_compute(data.state)
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
		if cur_state == M.xc_state.nor then
			maps = c_d.xc_data
		elseif cur_state == M.xc_state.hscb_2 then
			maps = c_d.xc_data
		elseif cur_state == M.xc_state.ccjj_2 then
			maps = c_d.xc_data
		else
			maps = c_d.xc_data
		end
		local data = {}
		data.state = cur_state

		lottery(data)
	end

	-- 初始化 
	if c_d.state == M.xc_state.hscb_2 then
		if c_d.start_fire_index then
			local init_pos = M.get_hscb_pos_by_index(c_d.start_fire_index)
			c_d.xc_data[init_pos[1][1]][init_pos[1][2]] = 100
			c_d.xc_data[init_pos[2][1]][init_pos[2][2]] = 100
		end
	elseif (c_d.state == M.xc_state.ccjj_2) or (c_d.state == M.xc_state.ccjj_cs) then
		c_d.cur_tot_arrow = 0 -- 当前收集的箭
		c_d.arrow_top_list = {1,1,1,1} -- 上方显示的箭
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
		local gd_list = {}
		for y=1, M.high_max do
			if map[x][y] >= 100 then
				gd_list[x] = gd_list[x] or {}
				gd_list[x][y] = {y=y, v=map[x][y]}
			end
		end
		for y=M.high_max,1, -1 do
			if _v[y] or (gd_list[x] and gd_list[x][y]) then
				if map[x] and map[x][y] then
					table.remove(map[x], y)
				end
			end
		end
		for y=1, M.high_max do
			if gd_list[x] and gd_list[x][y] then
				table.insert(map[x], gd_list[x][y].y, gd_list[x][y].v)
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
		--白骨精消除
		if not table_is_null(_v.bgj_map_del) then
			table.insert(all_del_list,basefunc.deepcopy(_v.bgj_map_del))
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

--  火烧赤壁fun
local XC_WIDE = 5
local XC_HIGH = 4
local hscb_index_pos_list = {
	{{1, 1}, {XC_WIDE, 1}},  -- 左下+右下
	{{1, 1}, {1, XC_HIGH}},  -- 左下+左上
	{{1, 1}, {XC_WIDE, XC_HIGH}},  -- 左下+右上
	{{XC_WIDE, 1}, {1, XC_HIGH}},  -- 右下+左上
	{{XC_WIDE, 1}, {XC_WIDE, XC_HIGH}},  -- 右下+右上
	{{1, XC_HIGH}, {XC_WIDE, XC_HIGH}},  -- 左上+右上
}
-- 火烧的选择初始的火船索引 服务器用
function M.get_hscb_index_by_pos(parm)
	if not parm or #parm ~= 2 then
		return
	end

	local x1 = parm[1].x
	local y1 = parm[1].y
	local x2 = parm[2].x
	local y2 = parm[2].y
	for k,v in ipairs(hscb_index_pos_list) do
		if v[1][1] == x1 and v[1][2] == y1
			and v[2][1] == x2 and v[2][2] == y2 then
				return k-1
		end
		if v[2][1] == x1 and v[2][2] == y1
			and v[1][1] == x2 and v[1][2] == y2 then
				return k-1
		end
	end
end
-- 火烧的选择初始的火船坐标
function M.get_hscb_pos_by_index(index)
	local pos = hscb_index_pos_list[index + 1]
	return pos
end

--  草船借箭fun
local arrow_score_tab = {1,3,5,10}
function M.get_arrow_score_by_num(type,num)
	return arrow_score_tab[type] * num
end
