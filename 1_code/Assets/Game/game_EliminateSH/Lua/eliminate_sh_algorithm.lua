local basefunc = require "Game.Common.basefunc"
eliminate_sh_algorithm = basefunc.class()
local M = eliminate_sh_algorithm

M.xc_limit=3
M.high_max=8
M.wide_max=8
--消除元素的倍率表，*10倍的结果
M.rate_map = {
	{ 0,0, 1,2,5,10,15,50 },--1
	{ 0,0, 2,4,8,15,30,60 },--2
	{ 0,0, 5,10,20,40,80,150 },--//3
	{ 0,0, 10,20,40,80,150,300 },--//4
	{ 0,0, 20,40,80,150,300,500 },--//5
	{ 0,0, 10,20,40,80,150,300 },--//6 令牌
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
--英雄id
M.hero_id = {1,2,3,4}
--英雄2摇出英雄的倍率 k : 英雄 id
M.hero2_rate = {50,100,100,150}
function M.get_hero2_rate(i)
	if not M.hero2_rate[i] then return 0 end
	return M.hero2_rate[i] / 10
end
--英雄3摇出元素的倍率 k : 元素 id
M.hero3_rate = {50,100,150,200,250}
function M.get_hero3_rate(i)
	if not M.hero3_rate[i] then return 0 end
	return M.hero3_rate[i] / 10
end
--lucky和英雄的数量对应表
M.lucky_hero_count_map = {
	[4] = 1,
	[5] = 2,
	[6] = 3,
	[7] = 4,
}
--n lucky个数
function M.get_hero_count(n)
	if not n then return end
	if n > 7 then n = 7 end
	return M.lucky_hero_count_map[n]
end

--lucky出英雄的表
M.lucky_hero_get_map = {
	[6] = 6,
}

function M.check_add_hero(id)
	return M.lucky_hero_get_map[id]
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
	return pos
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

function M.hero_list_id_arrange(hero_list)
	if table_is_null(hero_list) then return end
	local new_hero_list = {}
	local hero_id = 1
	for i,v in ipairs(hero_list) do
		if v == 1 then
			hero_id = 1
		elseif v == 2 then
			hero_id = 3
		elseif v == 3 then
			hero_id = 2
		elseif v == 4 then
			hero_id = 4
		end
		new_hero_list[i] = hero_id
	end
	if not table_is_null(new_hero_list) then
		return new_hero_list
	end
end

--根据开奖信息计算出本局开奖数据
function M.compute_eliminate_result(data)
	dump(data,"<color=red>根据开奖信息计算出本局开奖数据</color>")
	local sever_data = {}
	sever_data.all_rate = data.all_rate
	sever_data.award_money = data.award_money
	sever_data.str_maps = data.total_xc_data
	sever_data.hero_list = M.hero_list_id_arrange(data.hero_list)
	dump(sever_data.hero_list, "<color=white>英雄历史</color>")
	sever_data.hero_data = {}
	--hero id : 1 武松 ，2 鲁智深，3 李逵，4 宋江
	if not table_is_null(sever_data.hero_list) then
		for i,v in ipairs(sever_data.hero_list) do
			if v == 1 then
				sever_data.hero_data[1] = {rate = 2}
			elseif v == 2 then
				sever_data.hero_data[2] = {
					base = data.event_lzs_data_guding,
					random = data.event_lzs_data_random,
				}
			elseif v == 3 then
				sever_data.hero_data[3] = {
					id_list = data.event_lk_bomb_list,
				}
			elseif v == 4  then
				sever_data.hero_data[4] = {
					loop_count = data.event_sj_zlnc
				}
			end
		end
	end
	dump(sever_data, "<color=green>服务器数据</color>")

	--开奖过程中的数据，包括初始的map和每次开奖的后的数据
	local eliminate_data = {}

	local maps = {}
	local hero = {}
	maps = M.str_maps_conver_to_pos_maps(sever_data.str_maps[1],M.wide_max)
	table.remove(sever_data.str_maps, 1)
	eliminate_data.all_rate = sever_data.all_rate
	eliminate_data.award_money = sever_data.award_money

	--开奖结果全存在这里
	local result = {}
	local lottery	--开奖函数
	local recursive_count = 0 --递归计数
	local eliminate_compute --消除计算


	local function save_data(data)
		data.map_base = M.get_show_map(maps) --过程表
		data.map_del = data.map_del or {}
		data.map_del = basefunc.deepcopy(data.del_map)
		if not table_is_null(data.hero_del_map) then
			M.map_merge(data.map_del,data.hero_del_map)
		end
		M.map_remove(maps,data.map_del)
		M.map_xc_aegis(maps)
		data.map_add = M.get_tj_map(maps,data.map_del)
		data.map_new = M.get_show_map(maps) --过程表
		if not table_is_null(data.hero_skill) and not table_is_null(data.hero_skill[3]) then
			--固定的图像替换
			for x=1,M.wide_max do
				for y=1,M.high_max do
					if data.map_new[x] and data.map_new[x][y] then
						data.map_new[x][y] = 6
					end
				end
			end
		end
		-- data.maps = basefunc.deepcopy(maps)
		data.hero = basefunc.deepcopy(hero) --英雄过程数据
		table.insert(result,data)
	end

	local function init_hero(k)
		if table_is_null(hero) then return end
		hero[k] = {}
		if sever_data.hero_data[k] then
			if k == 1 then
				hero[k].rate = sever_data.hero_data[k].rate
				--使用技能使之前的加倍
				if not table_is_null(eliminate_data.result) then
					for i=1,#eliminate_data.result - 1 do
						local cur_result = eliminate_data.result[i]
						if not table_is_null(cur_result) and 
							not table_is_null(cur_result.del_rate_list) then
							for i=1,#cur_result.del_rate_list do
								cur_result.del_rate_list[i] = cur_result.del_rate_list[i] * hero[1].rate
							end
						end
					end
				end
			elseif k == 2 then
				hero[k].base = {}
				hero[k].lucky = {}
				hero[k].random = {}
				for i=1,4 do
					hero[k].base[i] = sever_data.hero_data[k].base[1]
					table.remove( sever_data.hero_data[k].base, 1)
					if not hero[k].base[i] then
						hero[k].base[i] = i
					end
					hero[k].random[i] = 5 - i
				end
			elseif k == 3 then
				hero[k].id = sever_data.hero_data[k].id_list[1]
				table.remove( sever_data.hero_data[k].id_list, 1)
				hero[k].rate = M.get_hero3_rate(hero[k].id)
			elseif k == 4 then
				hero[k].loop_count = sever_data.hero_data[k].loop_count
				sever_data.hero_data[k].loop_count = sever_data.hero_data[k].loop_count - 1
			end
		end
	end

	local function add_hero(data)
		if table_is_null(sever_data.hero_list) then return end
		for i,v in ipairs(data.del_list) do
			if table_is_null(sever_data.hero_list) then return end
			local xc_id = M.get_xc_id(v)
			if M.check_add_hero(xc_id) then
				local xc_count = M.get_xc_count(v)
				local hc = M.get_hero_count(xc_count)
				if hc then
					for i=1,hc do
						if sever_data.hero_list[1] then
							local k = sever_data.hero_list[1]
							table.remove(sever_data.hero_list,1)
							data.hero_add_list = data.hero_add_list or {}
							table.insert( data.hero_add_list, k)
							hero[k] = {}
							init_hero(k)
						end
					end
				end
			end
		end
	end

	local function set_rate_list(data)
		if not table_is_null(data.del_list) then
			data.del_rate_list = data.del_rate_list or {}
			for i,v in ipairs(data.del_list) do
				local c = M.get_xc_count(v)
				local n = M.get_xc_id(v)
				local rate = M.get_rate(n,c)
				if not table_is_null(sever_data.hero_list) and
					M.check_add_hero(n) and
					M.get_hero_count(c) then
					rate = 0
				end
				table.insert( data.del_rate_list, rate)
			end
		end
	end

	local function hero1_skill(data)
		local k = 1
		if table_is_null(hero) or table_is_null(hero[k]) then return end
		data.hero_skill = data.hero_skill or {}
		data.hero_skill[k] = {}
		data.hero_skill[k].rate = hero[k].rate

		for i=1,#data.del_rate_list do
			data.del_rate_list[i] = data.del_rate_list[i] * hero[k].rate
		end
	end

	local function hero2_skill(data)
		local k = 2
		if table_is_null(hero) or table_is_null(hero[k]) then return end
		hero[k].random = {}
		hero[k].rate_list = {}
		hero[k].cur_lucky = {}
		for i=1,4 do
			hero[k].random[i] = sever_data.hero_data[k].random[1]
			table.remove(sever_data.hero_data[k].random, 1)
			if not hero[k].random[i] then
				hero[k].random[i] = i
			end
			if hero[k].base[i] == hero[k].random[i] and (not hero[k].lucky or not hero[k].lucky[i]) then
				--摇中英雄
				local rate = M.get_hero2_rate(hero[k].base[i])
				table.insert(hero[k].rate_list, rate)
				hero[k].lucky = hero[k].lucky or {}
				hero[k].lucky[i] = hero[k].base[i]--标记摇中英雄
				hero[k].cur_lucky[i] = hero[k].base[i]--当前中奖英雄
			end
		end

		data.hero_skill = data.hero_skill or {}
		data.hero_skill[k] = {}
		data.hero_skill[k].rate_list = basefunc.deepcopy(hero[k].rate_list)
		data.hero_skill[k].base = basefunc.deepcopy(hero[k].base)
		data.hero_skill[k].random = basefunc.deepcopy(hero[k].random)
		data.hero_skill[k].cur_lucky = basefunc.deepcopy(hero[k].cur_lucky)

		if not table_is_null(data.hero_skill[k].cur_lucky) then
			for k,v in pairs(data.hero_skill[k].cur_lucky) do
				local del_map = {}
				local y = k + 2
				for x=1,M.wide_max do
					if not data.del_map[x] or not data.del_map[x][y] then
						del_map[x] = del_map[x] or {}
						del_map[x][y] = maps[x][y]
					end
				end
				if not table_is_null(del_map) then
					data.hero_del_list = data.hero_del_list or {}
					data.hero_del_map = data.hero_del_map or {}
					table.insert( data.hero_del_list,del_map )
					M.map_merge(data.hero_del_map, del_map)
				end
			end
		end
		if not table_is_null(data.hero_skill[k].rate_list) then
			for i,v in ipairs(data.hero_skill[k].rate_list) do
				data.hero_del_rate_list = data.hero_del_rate_list or {}
				table.insert( data.hero_del_rate_list,v)
			end
		end
	end

	local function hero3_skill(data)
		local k = 3
		if table_is_null(hero) or table_is_null(hero[k]) then return end

		data.hero_skill = data.hero_skill or {}
		data.hero_skill[k] = {}
		data.hero_skill[k].id = hero[k].id
		data.hero_skill[k].rate = hero[k].rate

		hero[k].id = sever_data.hero_data[k].id_list[1]
		table.remove( sever_data.hero_data[k].id_list, 1)
		hero[k].rate = M.get_hero3_rate(hero[k].id)

		local del_map = {}
		for x=1,M.wide_max do
			for y=1,M.high_max do
				if not table_is_null(data.del_map) then
					if not data.del_map[x] or not data.del_map[x][y] then
						del_map[x] = del_map[x] or {}
						del_map[x][y] = maps[x][y]
					end
				else
					del_map[x] = del_map[x] or {}
					del_map[x][y] = maps[x][y]
				end
			end
		end
		if not table_is_null(del_map) then
			data.hero_del_list = data.hero_del_list or {}
			data.hero_del_map = data.hero_del_map or {}
			table.insert(data.hero_del_list,del_map)
			M.map_merge(data.hero_del_map, del_map)
		end
		if data.hero_skill[k].rate then
			data.hero_del_rate_list = data.hero_del_rate_list or {}
			table.insert( data.hero_del_rate_list,data.hero_skill[k].rate)
		end
	end

	local function hero4_skill(data)
		local k = 4
		if table_is_null(hero) or table_is_null(hero[k]) or hero[k].loop_count < 1 then
			save_data(data) 
			return
		end

		data.hero_skill = data.hero_skill or {}
		data.hero_skill[k] = {}
		data.hero_skill[k].loop_count = hero[k].loop_count

		hero[k].loop_count = sever_data.hero_data[k].loop_count
		sever_data.hero_data[k].loop_count = sever_data.hero_data[k].loop_count - 1
		
		save_data(data)

		maps = M.str_maps_conver_to_pos_maps(sever_data.str_maps[1],M.wide_max)
		table.remove(sever_data.str_maps, 1)
		--当宋江重置的时候，没有消除的元素，这个时候服务器没有发鲁智深重置的数据，不重置鲁智深
		local xc_map = M.get_xc_map(maps)
		local not_check_id_map = {[0] = 0}
		local cur_del_list,cur_del_map = M.get_eliminate_all_element(xc_map,not_check_id_map)
		if not table_is_null(cur_del_list) then
			--英雄重置
			if not table_is_null(hero[2]) then
				init_hero(2)
			end
		end
		eliminate_compute()
	end

	lottery = function (data)
		local xc_map = M.get_xc_map(maps)
		local not_check_id_map = {[0] = 0}
		data.del_list,data.del_map = M.get_eliminate_all_element(xc_map,not_check_id_map)
		set_rate_list(data)
		if not table_is_null(data.del_list) then
			add_hero(data)
			hero1_skill(data)
			hero2_skill(data)
			save_data(data)
			eliminate_compute()
		else
			hero3_skill(data)
			hero4_skill(data)
		end
	end

	eliminate_compute = function ()
		if recursive_count > 100 then
			print("<color=red>递归计数</color>",recursive_count)
			return
		end
		recursive_count = recursive_count + 1
		local data = {}
		lottery(data)
	end

	eliminate_compute()
	eliminate_data.result = basefunc.deepcopy(result)
	return eliminate_data
end

--根据map获取一个供检查消除的表
function M.get_xc_map(maps)
	local xc_map = {}
	for x=1,M.wide_max do
		for y=1,M.high_max do
			xc_map[x] = xc_map[x] or {}
			if (x < 3 or x > 6) and (y < 3 or y > 6) then
				xc_map[x][y] = 0
			else
				xc_map[x][y] = maps[x][y]
			end
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
	if table_is_null(xc_map) then return 6 end
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

function M.get_all_del_list(result,not_hero)
	local all_del_list = {}
	for i,_v in ipairs(result) do
		if _v.del_list then
			for i,v in ipairs(_v.del_list) do
				local xc_c = eliminate_sh_algorithm.get_xc_count(v)
				local xc_id = eliminate_sh_algorithm.get_xc_id(v)
				local is_lucky = false
				if xc_id == 6 and xc_c > 3 and not table_is_null(_v.hero_add_list) then
					is_lucky = true
				end
				if not is_lucky then
					table.insert(all_del_list,basefunc.deepcopy(v))
				end
			end
		end
		if not not_hero then
			if _v.hero_del_list then
				local strart_lucky_hero = 1
				local hero_skill = basefunc.deepcopy(_v.hero_skill)
				for i,v in ipairs(_v.hero_del_list) do
					if M.get_xc_count(v) == 64 and _v.hero_skill[3] then
						--英雄3全屏消除
						local hero3_id = _v.hero_skill[3].id
						local del_map = {}
						for x=1,8 do
							for y=1,8 do
								del_map[x] = del_map[x] or {}
								del_map[x][y] = hero3_id
							end
						end
						del_map.hero_del = 3
						table.insert(all_del_list,basefunc.deepcopy(del_map))
					else
						--英雄2全行消除
						for index=strart_lucky_hero,4 do
							strart_lucky_hero = strart_lucky_hero + 1
							if hero_skill[2].cur_lucky[index] then
								local cur_del_hero_list = {}
								cur_del_hero_list.hero_del = 2
								cur_del_hero_list[1] = {}
								table.insert( cur_del_hero_list[1],"hero_" .. hero_skill[2].cur_lucky[index])
								table.insert(all_del_list,basefunc.deepcopy(cur_del_hero_list))
								hero_skill[2].cur_lucky[index] = nil
								break
							end
						end
					end
				end
			end
		end
	end
	return all_del_list
end

function M.get_all_del_rate_list(result,not_hero)
	local all_del_list = {}
	for i,_v in ipairs(result) do
		if _v.del_rate_list then
			for i,v in ipairs(_v.del_rate_list) do
				table.insert(all_del_list,basefunc.deepcopy(v))
			end
		end
		if not not_hero then
			if _v.hero_del_rate_list then
				for i,v in ipairs(_v.hero_del_rate_list) do
					table.insert(all_del_list,basefunc.deepcopy(v))
				end
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

function M.check_cur_result_is_hero1(cur_result)
	local is_hero1 = false
	if table_is_null(cur_result.hero_add_list) then
        if table_is_null(cur_result.hero_skill) then
            is_hero1 = false
        else
            if cur_result.hero_skill[1] then
                is_hero1 = true
            else
                is_hero1 = false
            end
        end
    else
        local have_hero1 = false
        for k,v in pairs(cur_result.hero_add_list) do
            if v == 1 then
                have_hero1 = true
            end
        end

        if have_hero1 then
            is_hero1 = false
        else
            if table_is_null(cur_result.hero_skill) then
                is_hero1 = false
            else
                if cur_result.hero_skill[1] then
                    is_hero1 = true
                else
                    is_hero1 = false
                end
            end
        end
	end
	return is_hero1
end