local basefunc = require "Game.Common.basefunc"
eliminate_xy_algorithm = basefunc.class()
local M = eliminate_xy_algorithm

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

M.xc_limit=3
M.high_max=4
M.wide_max=5
--消除元素的倍率表，*10倍的结果
M.rate_map = {
	{0,0, 4,8,15,30,50,100,},--//1 袈裟
    {0,0, 5,10,25,50,100,200,},--//2 紫金钵
    {0,0, 8,15,30,60,150,300,},--//3 玉净瓶
    {0,0, 10,25,50,100,200,400,},--//4 人参果
    {0,0, 20,50,100,200,400,800,},--//5 经书
	{0,},--6 唐僧
	{0,},--7 白骨精
	{0,},--8 孙悟空
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
	[7] = 7,
	[8] = 8,
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

function M.get_pos_by_index(x,y,size_x,size_y,spac_x,spac_y)
	size_x = size_x or 200
	size_y = size_y or 140
	spac_x = spac_x or 4
	spac_y = spac_y or 4
	local pos = {x = 0,y = 0}
	pos.x = (x - 1) * (size_x + spac_x)
	pos.y = (y - 1) * (size_y + spac_y)
	return pos, {x = x,y = y}
end

function M.get_bg_pos_by_index(x,y,size_x,size_y,spac_x,spac_y)
	size_x = size_x or 204
	size_y = size_y or 144
	spac_x = spac_x or 0
	spac_y = spac_y or 0
	local pos = {x = 0,y = 0}
	pos.x = (x - 1) * (size_x + spac_x)
	pos.y = (y - 1) * (size_y + spac_y)
	return pos
end

function M.get_index_by_pos(x,y,size_x,size_y,spac_x,spac_y)
	size_x = size_x or 200
	size_y = size_y or 140
	spac_x = spac_x or 4
	spac_y = spac_y or 4
	local index = {x = 1,y = 1}
	index.x = math.floor(x / (size_x + spac_x)) + 1
	index.y = math.floor(y / (size_y + spac_y)) + 1
	return index
end

function M.str_maps_conver_to_pos_maps(s,max_x)
	if not s then return end
	local t = unzip_data_to_proto(s)
	-- dump(s,"<color=white>s:::::</color>")
	-- dump(t,"<color=white>s:::::</color>")
	local c = {}
	local y = 1
	local x = 1
	for i=1,#t do
		c[x] = c[x] or {}
		if tonumber(t[i]) ~= 0 then
			c[x][y] = tonumber(t[i])
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
			c[x][y] = tonumber(id)
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
	nor = "nor", --普通消除
	free = "free",	--免费游戏
}

function M.sever_data_convert_client_data(s_d)
	dump(s_d, "<color=green>服务器数据</color>")
	-- for k,v in pairs(s_d) do
	-- 	dump(v, "<color=green>服务器数据 v </color>" .. k .. "   ")
	-- end

	if not s_d then return end
	local c_d = {}
	c_d.is_local = s_d.is_local
	c_d.all_rate = s_d.all_rate or 0	--总倍率
	c_d.all_money = s_d.all_money or 0	--总鲸币
	c_d.xc_data = s_d.xc_data	--正常消除数据
	c_d.bgj_rate_list = s_d.bgj_rate_vec	--白骨精倍率列表
	c_d.swk_skill_list = s_d.swk_skill	--孙悟空 技能列表
	c_d.swk_skill_added_rate_list = s_d.swk_skill_2	--孙悟空 额外倍率列表
	c_d.swk_skill_change_xc_list = s_d.swk_skill_3	--孙悟空 改变元素列表
	c_d.swk_skill_change_rate_list = s_d.swk_skill_3_rate_vec	--孙悟空 改变元素倍率列表
	c_d.free_game_num = s_d.free_game_num	--免费游戏次数
	if s_d.free_game_data then
		c_d.free_game_data = {
			all_rate = s_d.free_game_data.all_rate,	--总倍率
			all_add_value = s_d.free_game_data.all_add_value,	--白骨精增加进度
			xc_data = s_d.free_game_data.xc_data,	--消除数据
			xc_change_data = s_d.free_game_data.change_data,	--每次替换的元素
			xc_change_data_rate = s_d.free_game_data.change_data_rate_vec,	--替换的倍率
	
			swk_skill_list = s_d.free_game_data.swk_skill,	--孙悟空 技能列表
			swk_skill_added_rate_list = s_d.free_game_data.swk_skill_2,	--孙悟空 额外倍率列表
			swk_skill_change_xc_list = s_d.free_game_data.swk_skill_3,	--孙悟空 改变元素列表
			swk_skill_change_rate_list = s_d.free_game_data.swk_skill_3_rate_vec, --孙悟空 改变元素倍率列表
	
			bgj_jc_rate = s_d.free_game_data.bgj_rate,	--白骨精奖池倍率
			swk_skill_award = s_d.free_game_data.bgj_award_skill, --唐僧技能 （1就是翻倍）
		}
	end
	dump(c_d, "<color=green>服务器转客户端数据</color>")
	if c_d.all_rate then
		c_d.all_rate = c_d.all_rate / 10
	end
	if c_d.xc_data then
		if c_d.is_local then
			c_d.xc_data = M.str_maps_conver_to_pos_maps_new(c_d.xc_data,M.wide_max)
		else
			c_d.xc_data = M.str_maps_conver_to_pos_maps(c_d.xc_data,M.wide_max)
		end
	end
	if c_d.swk_skill_added_rate_list then
		c_d.swk_skill_added_rate_list = json2lua(c_d.swk_skill_added_rate_list)
		for i=1,#c_d.swk_skill_added_rate_list do
			c_d.swk_skill_added_rate_list[i] = c_d.swk_skill_added_rate_list[i] / 10
		end
	end
	if c_d.swk_skill_change_xc_list then
		local t = {}
		for i,v in ipairs(c_d.swk_skill_change_xc_list) do
			table.insert(t,M.str_maps_conver_to_pos_maps(v,M.wide_max))
		end
		c_d.swk_skill_change_xc_list = t
	end
	if c_d.swk_skill_change_rate_list then
		c_d.swk_skill_change_rate_list = json2lua(c_d.swk_skill_change_rate_list)
		for i=1,#c_d.swk_skill_change_rate_list do
			for j=1,#c_d.swk_skill_change_rate_list[i] do
				c_d.swk_skill_change_rate_list[i][j] = c_d.swk_skill_change_rate_list[i][j] / 10
			end
		end
	end
	if c_d.bgj_rate_list then
		c_d.bgj_rate_list = json2lua(c_d.bgj_rate_list)
		for i=1,#c_d.bgj_rate_list do
			c_d.bgj_rate_list[i] = c_d.bgj_rate_list[i] / 10
		end
	end
	if c_d.free_game_data then
		if c_d.free_game_data.all_rate then
			c_d.free_game_data.all_rate = c_d.free_game_data.all_rate / 10
		end
		if c_d.free_game_data.xc_data then
			c_d.free_game_data.xc_data = M.str_maps_conver_to_pos_maps(c_d.free_game_data.xc_data,M.wide_max)
		end
		if c_d.free_game_data.xc_change_data then
			local t = {}
			for i,v in ipairs(c_d.free_game_data.xc_change_data) do
				table.insert(t,M.str_maps_conver_to_pos_maps(v,M.wide_max))
			end
			c_d.free_game_data.xc_change_data = t
		end
		if c_d.free_game_data.xc_change_data_rate then
			c_d.free_game_data.xc_change_data_rate = json2lua(c_d.free_game_data.xc_change_data_rate)
			for i=1,#c_d.free_game_data.xc_change_data_rate do
				for j=1,#c_d.free_game_data.xc_change_data_rate[i] do
					c_d.free_game_data.xc_change_data_rate[i][j] = c_d.free_game_data.xc_change_data_rate[i][j] / 10
				end
			end
		end
		if c_d.free_game_data.swk_skill_added_rate_list then
			c_d.free_game_data.swk_skill_added_rate_list = json2lua(c_d.free_game_data.swk_skill_added_rate_list)
			for i=1,#c_d.free_game_data.swk_skill_added_rate_list do
				c_d.free_game_data.swk_skill_added_rate_list[i] = c_d.free_game_data.swk_skill_added_rate_list[i] / 10
			end
		end
		if c_d.free_game_data.swk_skill_change_xc_list then
			local t = {}
			for i,v in ipairs(c_d.free_game_data.swk_skill_change_xc_list) do
				table.insert(t,M.str_maps_conver_to_pos_maps(v,M.wide_max))
			end
			c_d.free_game_data.swk_skill_change_xc_list = t
		end
		if c_d.free_game_data.swk_skill_change_rate_list then
			c_d.free_game_data.swk_skill_change_rate_list = json2lua(c_d.free_game_data.swk_skill_change_rate_list)
			for i=1,#c_d.free_game_data.swk_skill_change_rate_list do
				for j=1,#c_d.free_game_data.swk_skill_change_rate_list[i] do
					c_d.free_game_data.swk_skill_change_rate_list[i][j] = c_d.free_game_data.swk_skill_change_rate_list[i][j] / 10
				end
			end
		end
		if c_d.free_game_data.bgj_jc_rate then
			c_d.free_game_data.bgj_jc_rate = c_d.free_game_data.bgj_jc_rate / 10
		end
	end
	dump(c_d, "<color=green>客户端数据</color>")
	-- for k,v in pairs(c_d) do
	-- 	dump(k, "<color=green>客户端数据 k </color>")
	-- 	dump(v, "<color=green>客户端数据 v </color>")
	-- end
	return c_d
end

--根据开奖信息计算出本局开奖数据
function M.compute_eliminate_result(data)
	local c_d = M.sever_data_convert_client_data(data)

	--开奖结果全存在这里
	local eliminate_data = {}
	eliminate_data.all_rate = c_d.all_rate
	eliminate_data.all_money = c_d.all_money
	--免费游戏次数
	eliminate_data.free_game_num = c_d.free_game_num
	eliminate_data.bgj_rate_list = c_d.bgj_rate_list

	local result = {}
	local lottery	--开奖函数
	local recursive_count = 0 --递归计数c_d
	local eliminate_compute --消除计算

	local maps = {}--消除表

	local function save_data(data)
		table.insert(result,data)
	end

	local function save_maps(data)
		--消除表
		data.map_del = basefunc.deepcopy(data.del_map)
		M.map_remove(maps,data.map_del)
		M.map_xc_aegis(maps)
		data.map_add = M.get_tj_map(maps,data.map_del)
		data.map_new = M.get_xc_map(maps) --过程表

		--修正bgj倍率map
		data.bgj_rate_map_new = {}
		if data.state == M.xc_state.nor then
			local bgj_rate_list_index = c_d.bgj_rate_list_index
			for x=1,M.wide_max do
				local bgj_y = 1
				for y=1,M.high_max do
					if data.map_new[x] and data.map_new[x][y] and data.map_new[x][y] == M.eliminate_id[7] then
						for b_y=bgj_y,M.high_max do
							if data.bgj_rate_map and data.bgj_rate_map[x] and data.bgj_rate_map[x][b_y] then
								data.bgj_rate_map_new[x] = data.bgj_rate_map_new[x] or {}
								data.bgj_rate_map_new[x][y] = data.bgj_rate_map[x][b_y]
								bgj_y = b_y + 1
								break
							end
						end
						if not data.bgj_rate_map_new[x] or not data.bgj_rate_map_new[x][y] then
							data.bgj_rate_map_new[x] = data.bgj_rate_map_new[x] or {}
							bgj_rate_list_index = bgj_rate_list_index and bgj_rate_list_index or 0
							bgj_rate_list_index = bgj_rate_list_index + 1
							if c_d.bgj_rate_list then
								data.bgj_rate_map_new[x][y] = c_d.bgj_rate_list[bgj_rate_list_index]
							end
						end
					end
				end
			end
			c_d.bgj_rate_map = data.bgj_rate_map_new
		elseif data.state == M.xc_state.free then
			for x=1,M.wide_max do
				local bgj_y = 1
				for y=1,M.high_max do
					if data.map_new[x] and data.map_new[x][y] and data.map_new[x][y] == M.eliminate_id[7] then
						for b_y=bgj_y,M.high_max do
							if c_d.free_game_data.bgj_rate_map and c_d.free_game_data.bgj_rate_map[x] and c_d.free_game_data.bgj_rate_map[x][b_y] then
								data.bgj_rate_map_new[x] = data.bgj_rate_map_new[x] or {}
								data.bgj_rate_map_new[x][y] = c_d.free_game_data.bgj_rate_map[x][b_y]
								bgj_y = b_y + 1
								break
							end
						end
					end
				end
			end
			c_d.free_game_data.bgj_rate_map = data.bgj_rate_map_new
		end
	end

	local function set_swk_rate(data)
		if data.state ~= M.xc_state.nor then return end
		eliminate_data.swk_rate_cur = eliminate_data.swk_rate_cur or 0
		data.swk_rate_cur = eliminate_data.swk_rate_cur
		if table_is_null(data.del_list) then return end
		for i,v in ipairs(data.del_list) do
			local c = M.get_xc_count(v)
			local n = M.get_xc_id(v)
			local rate = M.get_rate(n,c)
			eliminate_data.swk_rate_cur = eliminate_data.swk_rate_cur + rate
		end
		data.swk_rate_cur = eliminate_data.swk_rate_cur
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

	local function trigger_swk_skill(data)
		if eliminate_data.swk_skill or table_is_null(data.del_list) then return end
		for j,v in ipairs(data.del_list) do
			local xc_id = M.get_xc_id(v)
			if xc_id == M.eliminate_id[8] then
				eliminate_data.swk_skill = true
				data.swk_skill_trigger_index = j
				local cur_data
				if data.state == M.xc_state.nor then
					cur_data = c_d
				else
					cur_data = c_d.free_game_data
				end
				cur_data.swk_skill_index = cur_data.swk_skill_index and cur_data.swk_skill_index or 0
				cur_data.swk_skill_index = cur_data.swk_skill_index + 1
			end
		end
	end

	local function trigger_ts_skill(data)
		if table_is_null(data.del_list) then return end
		for i,v in ipairs(data.del_list) do
			local xc_id = M.get_xc_id(v)
			if xc_id == M.eliminate_id[6] then
				eliminate_data.ts_skill_trigger = true
				data.ts_skill_trigger = true
				data.ts_skill_trigger_index = i
				data.free_game_num = c_d.free_game_num

				eliminate_data.free_game_num_cur = eliminate_data.free_game_num_cur or 0
				eliminate_data.free_game_num_cur = eliminate_data.free_game_num_cur + 6
				data.free_game_num_cur = eliminate_data.free_game_num_cur
			end
		end
	end

	local function use_swk_skill(data)
		if not eliminate_data.swk_skill then
			--没有孙悟空技能，开奖结束或者进入免费游戏
			return
		end
		--使用孙悟空技能，消除白骨精
		local cur_data
		if data.state == M.xc_state.nor then
			cur_data = c_d
		else
			cur_data = c_d.free_game_data
		end

		data.bgj_map_base = M.get_xc_map(maps) --过程表
		local xc_map = M.get_xc_map(maps)
		--白骨精消除
		local bgj_xc_map = {}
		local bgj_rate_map = data.bgj_rate_map or {}
		for x=1,M.wide_max do
			for y=1,M.high_max do
				if xc_map[x] and xc_map[x][y] and xc_map[x][y] == M.eliminate_id[7] then
					bgj_xc_map[x] = bgj_xc_map[x] or {}
					bgj_xc_map[x][y] = xc_map[x][y]
				end
			end
		end

		local i = cur_data.swk_skill_index
		if table_is_null(cur_data.swk_skill_list) or not cur_data.swk_skill_list[i] then 
			--没有孙悟空技能
			dump(data,"<color=white>没有孙悟空技能了</color>")
			return
		end
		data.swk_skill = cur_data.swk_skill_list[i]
		if data.swk_skill == 0 then
			--空技能
			if table_is_null(bgj_xc_map) then
				dump(data,"<color=white>孙悟空技能0当前屏中没有白骨精</color>")
				return
			end
		elseif data.swk_skill == 1 then
			--1翻倍当前屏幕中的白骨精的明面价值
			if table_is_null(bgj_xc_map) then
				dump(data,"<color=white>孙悟空技能1当前屏中没有白骨精</color>")
				return
			end
			data.swk_skill_added_rate_map = bgj_rate_map
		elseif data.swk_skill == 2 then
			--2屏幕中的白骨精额外奖励技能
			if table_is_null(bgj_xc_map) then
				dump(data,"<color=white>孙悟空技能2当前屏中没有白骨精</color>")
				return
			end
			data.swk_skill_added_rate_map = {}
			for x=1,M.wide_max do
				for y=1,M.high_max do
					if bgj_xc_map[x] and bgj_xc_map[x][y] then
						data.swk_skill_added_rate_map[x] = data.swk_skill_added_rate_map[x] or {}
						cur_data.swk_skill_added_rate_index = cur_data.swk_skill_added_rate_index and cur_data.swk_skill_added_rate_index or 0
						cur_data.swk_skill_added_rate_index = cur_data.swk_skill_added_rate_index + 1
						local _i = cur_data.swk_skill_added_rate_index
						data.swk_skill_added_rate_map[x][y] = cur_data.swk_skill_added_rate_list[_i]
					end
				end
			end
			
			if table_is_null(data.swk_skill_added_rate_map) then
				dump(data,"<color=white>孙悟空技能2数据错误</color>")
				return
			end

		elseif data.swk_skill == 3 then
			--3再摇一次，随机变化一些白骨精出现
			cur_data.swk_skill_change_index = cur_data.swk_skill_change_index and cur_data.swk_skill_change_index or 0
			cur_data.swk_skill_change_index = cur_data.swk_skill_change_index + 1
			local _i = cur_data.swk_skill_change_index
			data.swk_skill_change_xc = cur_data.swk_skill_change_xc_list[_i]
			data.swk_skill_change_rate = cur_data.swk_skill_change_rate_list[_i]
			if table_is_null(data.swk_skill_change_xc) or table_is_null(data.swk_skill_change_rate) then
				dump(data,"<color=white>孙悟空技能3数据错误</color>")
				return
			end

			for x=1,M.wide_max do
				for y=1,M.high_max do
					if data.swk_skill_change_xc[x] and data.swk_skill_change_xc[x][y] then
						if data.swk_skill_change_xc[x][y] ~= 0 then
							xc_map[x] = xc_map[x] or {}
							xc_map[x][y] = data.swk_skill_change_xc[x][y]
							maps[x] = maps[x] or {}
							maps[x][y] = data.swk_skill_change_xc[x][y]
							if data.swk_skill_change_xc[x][y] == M.eliminate_id[7] then
								--白骨精倍率
								data.swk_skill_change_rate_index = data.swk_skill_change_rate_index and data.swk_skill_change_rate_index or 0
								data.swk_skill_change_rate_index = data.swk_skill_change_rate_index + 1
								bgj_rate_map[x] = bgj_rate_map[x] or {}
								bgj_rate_map[x][y] = data.swk_skill_change_rate[data.swk_skill_change_rate_index]
								bgj_xc_map[x] = bgj_xc_map[x] or {}
								bgj_xc_map[x][y] = M.eliminate_id[7]
							end
						else
							data.swk_skill_change_xc[x][y] = nil
						end
					end
				end
			end
		end
		data.use_swk_skill = true
		data.bgj_xc_map = bgj_xc_map
		data.bgj_rate_map = bgj_rate_map
		data.bgj_rate = 0
		for x=1,M.wide_max do
			for y=1,M.high_max do
				if bgj_rate_map[x] and bgj_rate_map[x][y] then
					data.bgj_rate = data.bgj_rate + bgj_rate_map[x][y]
				end
			end
		end

		data.bgj_rate_add = 0
		if not table_is_null(data.swk_skill_added_rate_map) then
			for x=1,M.wide_max do
				for y=1,M.high_max do
					if data.swk_skill_added_rate_map[x] and data.swk_skill_added_rate_map[x][y] then
						data.bgj_rate_add = data.bgj_rate_add + data.swk_skill_added_rate_map[x][y]
					end
				end
			end
		end
		data.bgj_rate = data.bgj_rate + data.bgj_rate_add


		if data.state == M.xc_state.free then
			--只有免费游戏才加入奖池
			eliminate_data.bgj_rate_jc_cur = eliminate_data.bgj_rate_jc_cur or 0
			eliminate_data.bgj_rate_jc_cur = eliminate_data.bgj_rate_jc_cur - data.bgj_rate_free_nor
			data.bgj_rate_jc_cur = data.bgj_rate + eliminate_data.bgj_rate_jc_cur
			eliminate_data.bgj_rate_jc_cur = data.bgj_rate_jc_cur
		end
		--消除所有白骨精
		data.bgj_map_del = basefunc.deepcopy(data.bgj_xc_map)
		M.map_remove(maps,data.bgj_map_del)
		M.map_xc_aegis(maps)
		data.bgj_map_add = M.get_tj_map(maps,data.bgj_map_del)
		data.bgj_map_new = M.get_xc_map(maps) --过程表
		return true
	end

	local function ts_skill_use(data)
		if not eliminate_data.ts_skill_trigger then return end
		--使用唐僧的技能，进行免费游戏
		if not c_d.free_game_num_rem then c_d.free_game_num_rem = c_d.free_game_num end
		if c_d.free_game_num_rem == 0 then
			--免费游戏用完
			return
		end
		if not c_d.free_game_num_rem then return end
		c_d.free_game_num_rem = c_d.free_game_num_rem - 1
		data.free_game_num = c_d.free_game_num_rem
		data.free_game_num_del = c_d.free_game_num - data.free_game_num
		data.ts_skill_use = true

		eliminate_data.free_game_num_cur = eliminate_data.free_game_num_cur - 1

		local xc_map = {}
		for x=1,M.wide_max do
			for y=1,M.high_max do
				xc_map[x] = xc_map[x] or {}
				xc_map[x][y] = 0
			end
		end
		M.map_remove(maps,xc_map)
		return true
	end

	local function use_swk_skill_award(data)
		if data.state ~= M.xc_state.free then return end --不在免费游戏中
		if not eliminate_data.ts_skill_trigger then return end --没有触发唐僧奖励技能
		if not c_d.free_game_data.swk_skill_award then return end  --触发的唐僧奖励技能为空
		data.swk_skill_award = c_d.free_game_data.swk_skill_award
		if data.swk_skill_award == 1 then
			--摇中孙悟空取全部奖池
			data.bgj_jc_rate = c_d.free_game_data.bgj_jc_rate
		elseif data.swk_skill_award == 2 then
			--摇中唐僧取1/10
			data.bgj_jc_rate = math.ceil(c_d.free_game_data.bgj_jc_rate) * 0.1
			c_d.free_game_data.bgj_jc_rate = data.bgj_jc_rate
		end
		data.swk_map_base = {}
		data.swk_map_new = {}
		for x=1,M.wide_max do
			for y=1,M.high_max do
				data.swk_map_base[x] = data.swk_map_base[x] or {}
				data.swk_map_new[x] = data.swk_map_new[x] or {}
				if x ~= M.wide_max then
					data.swk_map_base[x][y] = M.eliminate_id[0]
					data.swk_map_new[x][y] = M.eliminate_id[0]
				else
					data.swk_map_base[x][y] = M.eliminate_id[0]
					data.swk_map_new[x][y] = M.eliminate_id[0]
				end
			end
		end
		return true
	end

	local function set_bgj_rate(data)
		if data.state == M.xc_state.nor then
			data.bgj_rate = 0
			if not table_is_null(data.del_map) then
				for x=1,M.wide_max do
					for y=1,M.high_max do
						if data.del_map[x] and data.del_map[x][y] and data.bgj_rate_map[x] and data.bgj_rate_map[x][y] then
							data.bgj_rate = data.bgj_rate + data.bgj_rate_map[x][y]
						end
					end
				end
			end
			eliminate_data.bgj_rate_nor_cur = eliminate_data.bgj_rate_nor_cur or 0
			data.bgj_rate_nor_cur = data.bgj_rate + eliminate_data.bgj_rate_nor_cur
			eliminate_data.bgj_rate_nor_cur = data.bgj_rate_nor_cur
		elseif data.state == M.xc_state.free then
			data.bgj_rate = 0
			--没有普通消除消除的时候记录当前不能消除的白骨精
			if table_is_null(data.del_map) and not table_is_null(data.bgj_rate_map) then
				for x=1,M.wide_max do
					for y=1,M.high_max do
						if data.bgj_rate_map[x] and data.bgj_rate_map[x][y] then
							data.bgj_rate = data.bgj_rate + data.bgj_rate_map[x][y]
						end
					end
				end
			end
			data.bgj_rate_free_nor = data.bgj_rate
			eliminate_data.bgj_rate_jc_cur = eliminate_data.bgj_rate_jc_cur or 0
			data.bgj_rate_jc_cur = data.bgj_rate + eliminate_data.bgj_rate_jc_cur
			eliminate_data.bgj_rate_jc_cur = data.bgj_rate_jc_cur
		end
	end

	lottery = function (data)
		data.free_game_num_cur = eliminate_data.free_game_num_cur
		--普通消除
		data.map_base = M.get_xc_map(maps) --过程表
		local xc_map =  M.get_xc_map(maps)
		if data.state == M.xc_state.nor then
			local cur_data = c_d
			local bgj_rate_map = {}
			if not c_d.bgj_rate_map then
				for x=1,M.wide_max do
					for y=1,M.high_max do
						if xc_map[x] and xc_map[x][y] and xc_map[x][y] == M.eliminate_id[7] then
							if not table_is_null(cur_data.bgj_rate_list) then
								bgj_rate_map[x] = bgj_rate_map[x] or {}
								cur_data.bgj_rate_list_index = cur_data.bgj_rate_list_index and cur_data.bgj_rate_list_index or 0
								cur_data.bgj_rate_list_index = cur_data.bgj_rate_list_index + 1
								bgj_rate_map[x][y] = cur_data.bgj_rate_list[cur_data.bgj_rate_list_index]
							end
						end
					end
				end
			else
				for x=1,M.wide_max do
					for y=1,M.high_max do
						if xc_map[x] and xc_map[x][y] and xc_map[x][y] == M.eliminate_id[7] then
							if c_d.bgj_rate_map[x] and c_d.bgj_rate_map[x][y] then
								bgj_rate_map[x] = bgj_rate_map[x] or {}
								bgj_rate_map[x][y] = c_d.bgj_rate_map[x][y]
							else
								if not table_is_null(cur_data.bgj_rate_list) then
									bgj_rate_map[x] = bgj_rate_map[x] or {}
									cur_data.bgj_rate_list_index = cur_data.bgj_rate_list_index and cur_data.bgj_rate_list_index or 0
									cur_data.bgj_rate_list_index = cur_data.bgj_rate_list_index + 1
									bgj_rate_map[x][y] = cur_data.bgj_rate_list[cur_data.bgj_rate_list_index]
								end
							end
						end
					end
				end
			end
			data.bgj_rate_map = bgj_rate_map
			c_d.bgj_rate_map = bgj_rate_map
		elseif data.state == M.xc_state.free then
			local bgj_rate_map = {}
			if data.free_game_start then
				--唐僧技能触发免费游戏需要重新触发孙悟空
				c_d.free_game_data.xc_change_data_index = c_d.free_game_data.xc_change_data_index and c_d.free_game_data.xc_change_data_index or 0
				c_d.free_game_data.xc_change_data_index = c_d.free_game_data.xc_change_data_index + 1
				local i = c_d.free_game_data.xc_change_data_index
				data.xc_change_data = c_d.free_game_data.xc_change_data[i]
				data.xc_change_data_rate = c_d.free_game_data.xc_change_data_rate[i]
				if not table_is_null(data.xc_change_data) then
					for x=1,M.wide_max do
						for y=1,M.high_max do
							if data.xc_change_data[x] and data.xc_change_data[x][y] then
								if data.xc_change_data[x][y] ~= 0 then
									xc_map[x] = xc_map[x] or {}
									xc_map[x][y] = data.xc_change_data[x][y]
									maps[x] = maps[x] or {}
									maps[x][y] = data.xc_change_data[x][y]
								else
									data.xc_change_data[x][y] = nil
								end
							end
						end
					end
				end
				--白骨精倍率
				local index = 1
				for x,_v in pairs(data.xc_change_data) do
					for y,v in pairs(_v) do
						bgj_rate_map[x] = bgj_rate_map[x] or {}
						bgj_rate_map[x][y] = data.xc_change_data_rate[index]
						index = index + 1
					end
				end
			else
				for x=1,M.wide_max do
					for y=1,M.high_max do
						if xc_map[x] and xc_map[x][y] and xc_map[x][y] == M.eliminate_id[7] then
							if c_d.free_game_data.bgj_rate_map and c_d.free_game_data.bgj_rate_map[x] and c_d.free_game_data.bgj_rate_map[x][y] then
								bgj_rate_map[x] = bgj_rate_map[x] or {}
								bgj_rate_map[x][y] = c_d.free_game_data.bgj_rate_map[x][y]
							end
						end
					end
				end
				-- bgj_rate_map = c_d.free_game_data.bgj_rate_map
			end

			data.bgj_rate_map = bgj_rate_map
			c_d.free_game_data.bgj_rate_map = bgj_rate_map
		end
		local not_check_id_map = {[0] = 0,[7] = 7}
		data.del_list,data.del_map = M.get_eliminate_all_element(xc_map,not_check_id_map)
		set_rate_list(data)
		set_swk_rate(data)
		--孙悟空技能触发
		trigger_swk_skill(data)
		--唐僧技能触发
		trigger_ts_skill(data)
		--免费游戏白骨精倍率
		set_bgj_rate(data)
		save_maps(data)
		if not table_is_null(data.del_list) then
			save_data(data)
			eliminate_compute(data.state)
		else
			
			if use_swk_skill(data) then
				--孙悟空技能使用
				save_data(data)
				eliminate_data.swk_skill = false
				eliminate_compute(data.state)
				return
			end
			if ts_skill_use(data) then
				--唐僧技能使用，进行免费游戏
				save_data(data)
				eliminate_data.swk_skill = false
				--继续开奖
				eliminate_compute(M.xc_state.free,true)
				return
			end
			use_swk_skill_award(data)
			save_data(data)
		end
	end

	eliminate_compute = function (cur_state,free_game_start)
		if recursive_count > 100 then
			print("<color=red>递归计数</color>",recursive_count)
			return
		end
		recursive_count = recursive_count + 1
		if (cur_state == M.xc_state.nor) then
			maps = c_d.xc_data
		elseif (cur_state == M.xc_state.free) then
			maps = c_d.free_game_data.xc_data
		end
		local data = {}
		data.state = cur_state
		data.free_game_start = free_game_start
		lottery(data)
	end

	if not table_is_null(c_d.xc_data) then
		eliminate_compute(M.xc_state.nor)
	elseif not table_is_null(c_d.free_game_data) and not table_is_null(c_d.free_game_data.xc_data) then
		eliminate_compute(M.xc_state.free)
	end

	eliminate_data.result = basefunc.deepcopy(result)

	--验证数据
	local all_del_list ,nor_nor_rate,free_nor_rate,nor_bgj_rate,free_bgj_rate,free_bgj_rate_nor,free_bgj_rate_xc = M.get_all_del_rate_list(eliminate_data.result)
	local n = 0
	for i,v in ipairs(all_del_list) do
		n = n + v
	end
	local n1 = 0
	for i,v in ipairs(nor_nor_rate) do
		n1 = n1 + v
	end
	local n2 = 0
	for i,v in ipairs(free_nor_rate) do
		n2 = n2 + v
	end
	local n3 = 0
	for i,v in ipairs(nor_bgj_rate) do
		n3 = n3 + v
	end
	local n4 = 0
	for i,v in ipairs(free_bgj_rate) do
		n4 = n4 + v
	end
	local bgj_jc_rate = 0
	if c_d.free_game_data and c_d.free_game_data.bgj_jc_rate then
		bgj_jc_rate = c_d.free_game_data.bgj_jc_rate
		if c_d.free_game_data.swk_skill_award == 1 then
			n = n + bgj_jc_rate
		end
	end
	local n5 = 0
	for i,v in ipairs(free_bgj_rate_nor) do
		n5 = n5 + v
	end
	local n6 = 0
	for i,v in ipairs(free_bgj_rate_xc) do
		n6 = n6 + v
	end
	dump({all_rate = n,nor_nor_rate = n1,free_nor_rate = n2,nor_bgj_rate = n3,free_bgj_rate = n4,bgj_jc_rate = bgj_jc_rate
		,free_bgj_rate_nor = n5,free_bgj_rate_xc = n6},"<color=red>客户端计算总倍率</color>")

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
		--白骨精消除
		if not table_is_null(_v.bgj_map_del) then
			table.insert(all_del_list,basefunc.deepcopy(_v.bgj_map_del))
		end
	end
	return all_del_list
end

function M.get_all_del_rate_list(result)
	local all_del_list = {}
	local nor_nor_rate = {}
	local free_nor_rate = {}
	local nor_bgj_rate = {}
	local free_bgj_rate = {}
	local free_bgj_rate_nor = {}
	local free_bgj_rate_xc = {}
	for i,_v in ipairs(result) do
		if _v.del_rate_list then
			for i,v in ipairs(_v.del_rate_list) do
				table.insert(all_del_list,basefunc.deepcopy(v))
				if _v.state == M.xc_state.nor then
					table.insert(nor_nor_rate,basefunc.deepcopy(v))
				elseif _v.state == M.xc_state.free then
					table.insert(free_nor_rate,basefunc.deepcopy(v))
				end
			end
		end
		if _v.bgj_rate then
			if _v.use_swk_skill then
				--使用了孙悟空技能消除白骨精
				table.insert(all_del_list, _v.bgj_rate)
				table.insert(free_bgj_rate_xc,basefunc.deepcopy(_v.bgj_rate))
			else
				--没有消除白骨精
				if _v.bgj_rate_free_nor then
					table.insert(free_bgj_rate_nor,basefunc.deepcopy(_v.bgj_rate_free_nor))
				end
			end

			if _v.state == M.xc_state.nor then
				table.insert(nor_bgj_rate,basefunc.deepcopy(_v.bgj_rate))
			elseif _v.state == M.xc_state.free then
				table.insert(free_bgj_rate,basefunc.deepcopy(_v.bgj_rate))
			end
		end
	end
	return all_del_list,nor_nor_rate,free_nor_rate,nor_bgj_rate,free_bgj_rate,free_bgj_rate_nor,free_bgj_rate_xc
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