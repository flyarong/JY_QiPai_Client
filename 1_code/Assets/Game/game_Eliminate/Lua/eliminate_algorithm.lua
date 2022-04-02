local basefunc = require "Game.Common.basefunc"
eliminate_algorithm = basefunc.class()

local M = eliminate_algorithm

M.fruit_enum={
    apple=1,
    star=2,
    melon=3,
    seven=4,
    bar=5,
	lucky=6,
	null = 0,
}
M.xc_limit=3
M.high_max=8
M.wide_max=8

M.eliminate_enum = {
	nor = 3,--摇中3个，普通开奖
	del_type = 4,--lucky 摇中4个，消除同类
	clear_all = 5,--lucky 摇中5个及以上，消除全屏
}

M.lottery_type ={
    nor = "nor",--普通开奖
	lucky = "lucky",--lucky开奖
	fix = "fix",--固定消除
}

--得到map中所有要消除的元素,not_check_ids为不进行检查的id列表
function M.get_eliminate_all_element(map,not_check_ids)
	if not map or not next(map) then return end
	local m_delete = {}
	local eliminate_cache = {}
	local max_x = #map
	local max_y = #map[1]

	local function check(x,y)
		if not m_delete[x] or not m_delete[x][y] then
			-- local cache_map,_delete = M.check_all_line(map,x,y)
			local cache_map = {}
			local _delete = {}
			if map[x] and  map[x][y] and map[x][y]>0 then
				M.check_can_xc_by_point(map,x,y,cache_map,_delete)
			end
			if cache_map and  next(cache_map) then
				table.insert(eliminate_cache, cache_map)
			end
			if _delete and  next(_delete) then
				M.add_map_to_map(_delete,m_delete)
			end
		end
	end
	
	for y = max_y, 1, -1 do
		for x = 1, max_x, 1 do
			if not not_check_ids and  (not m_delete or not m_delete[x] or not m_delete[x][y] ) then
				check(x,y)
			else 
				--屏蔽id的id不进行检测
				local is_check = true
				for k,v in pairs(not_check_ids) do
					if map[x][y] == v then
						is_check = false
					end
				end
				if is_check and  (not m_delete or not m_delete[x] or not m_delete[x][y] )  then
					check(x,y)
				end
			end
		end
	end
	if not next(eliminate_cache) then
		eliminate_cache = nil
	end
	if not next(m_delete) then
		m_delete = nil
	end
	return eliminate_cache, m_delete
end

--取表中所有类型相同的,排除 exclude_map中的数据
function M.get_type_all_element(map,id,exclude_map)
	local m_map = {}
	local m_map2 = {}
	for x,_v in pairs(map) do
		for y,v in pairs(_v) do
			if exclude_map and next(exclude_map) then
				if not exclude_map[x] or not exclude_map[x][y] then
					if v == id then
						m_map2[x] = m_map2[x] or {}
						m_map2[x][y] = v
						table.insert(m_map, {x = x,y = y, id = v})
					end
				end
			else
				if v == id then
					m_map2[x] = m_map2[x] or {}
					m_map2[x][y] = v
					table.insert(m_map, {x = x,y = y, id = v})
				end
			end
		end
	end
	if not next(m_map) then
		m_map = nil
	end
	if not next(m_map2) then
		m_map2 = nil
	end
	return m_map,m_map2
end

--  high_or_wide 0 表示 横竖都要搜索  1 表示横向搜索  2表示竖向搜索  is_clear--是否清除
function M.check_can_xc_by_point(map,x,y,xc_vec,xc_map,xc_type,high_or_wide,hash_map,is_clear)
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

			xc_vec[#xc_vec+1]={x=i,y=y,id=xc_type}
			xc_map[i]=xc_map[i] or {}
			xc_map[i][y]=xc_type
			M.check_can_xc_by_point(map,i,y,xc_vec,xc_map,xc_type,2,hash_map,is_clear)
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

			xc_vec[#xc_vec+1]={y=i,x=x,id=xc_type}
			xc_map[x]=xc_map[x] or {}
			xc_map[x][i]=xc_type

			M.check_can_xc_by_point(map,x,i,xc_vec,xc_map,xc_type,1,hash_map,is_clear)
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
		M.check_can_xc_by_point(map,x,y,xc_vec,xc_map,xc_type,1,hash_map,is_clear)
	  end
	  if not hash_map[x] or (hash_map[x] and not hash_map[x][y]) then
		M.check_can_xc_by_point(map,x,y,xc_vec,xc_map,xc_type,2,hash_map,is_clear)
	  end
	end
  end

--检查所有相邻的元素单行总和超过指定个数的
function M.check_all_line(map,x,y,eliminate_count)
	if not eliminate_count then eliminate_count = 3 end
	local grid_steps = {
		{1,0},
		{0,1},
		{1,-1},
		{1,1}
	}
	local id = map[x][y]
	local r = #map
	local c = #map[x]
	local cache_map = {}
	local m_delete = {}
	m_delete[x] = m_delete[x] or {}
	m_delete[x][y] = id
	local lines = {}

	local checked_map = {}
	checked_map[x] =checked_map[x] or {}
	checked_map[x][y] = id

	local check_line = function(x, y, step_x, step_y)
		local tmp_x = x
		local tmp_y = y

		while true do
			tmp_x = tmp_x + step_x
			tmp_y = tmp_y + step_y
			if tmp_x < 1 or tmp_x > r or tmp_y < 1 or tmp_y > c then
				return false
			end
			if map[tmp_x][tmp_y] ~= id then
				return false
			end
			print("<color=yellow>坐标</color>",tmp_x,tmp_y)
			dump(m_delete, "<color=yellow>消除</color>")
			if checked_map[tmp_x] and checked_map[tmp_x][tmp_y] then
				return false
			end
			dump(cache_map, "<color=yellow>cache_map</color>")
			table.insert(cache_map, {x = tmp_x,y = tmp_y, id = id})
		end
	end

	local check = function(x,y)
		checked_map[x] =checked_map[x] or {}
		checked_map[x][y] = id
		for i = 1, 2 do
			cache_map = {}
			check_line(x, y, grid_steps[i][1], grid_steps[i][2])
			check_line(x, y, -grid_steps[i][1], -grid_steps[i][2])
			if #cache_map > 1 then
				for i,v in ipairs(cache_map) do
					table.insert(lines, {x = v.x,y = v.y, id = v.id})
					m_delete[v.x] = m_delete[v.x] or {}
					m_delete[v.x][v.y] = v.id
				end
			end
		end
	end
	check(x,y)
	for i,v in ipairs(lines) do
		check(v.x,v.y)
	end
	table.insert(lines, {x = x,y = y, id = id})
	if #lines >= eliminate_count then
		dump(lines, "<color=yellow>lines>>>>>>>>>>>>>>>>>>>>>></color>")
		dump(m_delete, "<color=yellow>m_delete>>>>>>>>>>>>>>>>>>>>>></color>")
		return lines , m_delete
	end
	return nil
end

--添加一个二维表到另一个二维表中,默认替换原值
function M.add_map_to_map(t_map,map,is_rep)
	if not t_map or type(t_map) ~= "table" or not next(t_map) then return map end
	if not map then map = {} end
	for x,_v in pairs(t_map) do
		for y,v in pairs(_v) do
			map[x] = map[x] or {}
			if map[x][y] then
				if is_rep == nil or is_rep == true then
					map[x][y] = v
				end
			else
				map[x][y] = v
			end
		end
	end
	return map
end

--从一个二维表中删除一些元素
function M.del_map_by_map(map,t_map)
	if not map or type(map) ~= "table" or not next(map) then return map end
	if not t_map or type(t_map) ~= "table" or not next(t_map) then return map end
	local max_x = 0
	local max_y = 0
	local set_max = function(_map)
		for x,v in pairs(_map) do
			if max_x < x then max_x = x end
			if max_y < #v then max_y= #v end
		end
	end
	set_max(map)
	--删除需要删除的元素
	for y = max_y, 1, -1 do
		for x = 1, max_x, 1 do
			if map[x] and map[x][y] and t_map[x] and t_map[x][y] then
				--判断是移除还是占用
				table.remove(map[x], y)
			end
		end
	end
	return map
end

--从一个二维表中获取一些元素
function M.get_map_by_map(map,t_map)
	if not map or type(map) ~= "table" or not next(map) then return end
	if not t_map or type(t_map) ~= "table" or not next(t_map) then return end
	local new_map = {}
	local id
	for x,_v in pairs(t_map) do
		for y,v in pairs(_v) do
			id = v
			if map[x] and map[x][y] then
				id = map[x][y]
			else
				--测试代码 没有数字可取的时候随机出数字
				id = M.fruit_enum.lucky -- math.random( M.fruit_enum.apple,M.fruit_enum.lucky )
			end
			new_map[x] = new_map[x] or {}
			new_map[x][y] = id
		end
	end
	if next(new_map) then
		return new_map
	end
end

--在一个二维表中替换一些元素
function M.rep_map_by_map(map,t_map)
	if not map or type(map) ~= "table" or not next(map) then return map end
	if not t_map or type(t_map) ~= "table" or not next(t_map) then return map end
	for x,_v in pairs(t_map) do
		for y,v in pairs(_v) do
			map[x] = map[x] or {}
			map[x][y] = t_map[x][y]
		end
	end
	return map
end

--得到一个y轴向连续的需要删除的表
function M.get_order_y_map(map)
	if not map or type(map) ~= "table" or not next(map) then return end
	local new_map = {}
	for x,_v in pairs(map) do
		local new_y = 1
		for y,v in pairs(_v) do
			new_map[x] = new_map[x] or {}
			new_map[x][new_y] = map[x][y]
			new_y = new_y + 1
		end
	end
	if next(new_map) then
		return new_map
	end
end

--将新生产的表转换为需要添加的表
function M.new_map_convert_add_map(newt,max_y)
	if not newt or type(newt) ~= "table" or not next(newt) then return end
	local cret = {}
	local check_top_nil_count = function (index,t)
		local count = 0
		for i = index + 1,max_y do
			if not t[i] then
				count = count + 1
			end
		end
		return count
	end
	for x,_v in pairs(newt) do
		for y,v in pairs(_v) do
			cret[x] = cret[x] or {}
			local count = check_top_nil_count(y,_v)
			cret[x][y + count] = v
		end
	end
	if next(cret) then
		return cret
	end
end

function M.array_sort(t,max_x,max_y)
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

--二维表变成一维表
function M.change_map_to_list(t_t)
	local o_t = {}
	local max_x = 0
	local max_y = 0
	for x,_v in pairs(t_t) do
		if max_x < x then
			max_x = x
		end
		for y,v in pairs(_v) do
			if max_y < y then
				max_y = y
			end
		end
	end

	for x=1,max_x do
		for y=1,max_y do
			if t_t[x][y] then
				table.insert(o_t,{x = x,y = y,id = t_t[x][y]})
			end
		end
	end
	return M.array_sort(o_t,max_x,max_y)
end

--一维表变成二维表
function M.change_list_to_map(t_t)
	local o_t = {}
	for i,v in ipairs(t_t) do
		o_t[v.x] = o_t[v.x] or {}
		o_t[v.x][v.y] = v.id
	end
	return o_t
end

function M.get_pos_by_index(x,y,size_x,size_y,spac_x,spac_y)
	size_x = size_x or EliminateModel.cfg.size.size_x or 116
	size_y = size_y or EliminateModel.cfg.size.size_y or 109
	spac_x = spac_x or EliminateModel.cfg.size.spac_x or 5
	spac_y = spac_y or EliminateModel.cfg.size.spac_y or 1
	local pos = {x = 0,y = 0}
	pos.x = (x - 1) * (size_x + spac_x)
	pos.y = (y - 1) * (size_y + spac_y)
	return pos
end

function M.get_index_by_pos(x,y,size_x,size_y,spac_x,spac_y)
	size_x = size_x or EliminateModel.cfg.size.size_x or 116
	size_y = size_y or EliminateModel.cfg.size.size_y or 109
	spac_x = spac_x or EliminateModel.cfg.size.spac_x or 5
	spac_y = spac_y or EliminateModel.cfg.size.spac_y or 1
	local index = {x = 1,y = 1}
	index.x = x / (size_x + spac_x) + 1
	index.y = y / (size_y + spac_y) + 1
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

--将服务器给的str_lucky_maps变成和maps等长度的字符串，并替换其中的lucky为对应值,其余为0
function M.get_str_lmaps_by_str_fmaps(fm,lm)
	local new_lm = ""
	local id = 0
	local lm_index = 1
	for i=1,#fm do
		id = string.sub(fm,i,i)
		if tonumber(id) == M.fruit_enum.lucky then
			id = string.sub(lm,lm_index,lm_index)
			lm_index = lm_index + 1
		else
			id = 0
		end
		new_lm = new_lm .. id
	end
	return new_lm
end

--添加一个一维表到另一个一维表后面
function M.add_list_to_list(list,t_list)
	if not t_list or type(t_list) ~= "table" or not next(t_list) then return list end
	if not list then list = {} end
	for i,v in ipairs(t_list) do
		table.insert( list,v)
	end
	return list
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

--根据开奖信息计算出本局开奖数据
function M.compute_eliminate_result(str_fmaps,str_lmaps,cfg)
	dump(str_fmaps, "<color=yellow>str_fmaps</color>")
	dump(str_lmaps, "<color=yellow>str_lmaps</color>")
	dump(cfg, "<color=yellow>cfg</color>")
	--开奖过程中的数据，包括初始的map和每次开奖的后的数据
	local eliminate_data = {}

	--用于取元素的 8 * 8 的数组
	local get_map = {}
    for x=1,cfg.size.max_x do
        for y=1,cfg.size.max_x do
            get_map[x] = get_map[x] or {}
            get_map[x][y] = -1
        end
	end


	local bureau_type = M.lottery_type.nor	--本局开奖类型，lucky摇中奖才算lucky
	local maps = {}
	local map = {}
	maps = M.str_maps_conver_to_pos_maps(str_fmaps,cfg.size.max_x)
	map = M.get_map_and_del(maps,get_map)
	eliminate_data.map = basefunc.deepcopy(map)

	local maps_lucky = {}
	local map_lucky = {}
	if str_lmaps then
		--本次有lucky
		local new_str_lmaps = M.get_str_lmaps_by_str_fmaps(str_fmaps,str_lmaps)
		maps_lucky = M.str_maps_conver_to_pos_maps(new_str_lmaps,cfg.size.max_x)
		map_lucky = M.get_map_and_del(maps_lucky,get_map)
	end

	dump(maps, "<color=yellow>maps</color>")
	dump(map, "<color=yellow>map</color>")
	dump(maps_lucky, "<color=yellow>maps_lucky</color>")
	dump(map_lucky, "<color=yellow>map_lucky</color>")

	--开奖结果全存在这里
	local result = {}
	local change_map	--开奖改变map函数
	local lottery	--开奖函数
	local recursive_count = 0 --递归计数
	local eliminate_compute --消除计算

	change_map = function(data)
		--从没有用过的表中取数字的map格式
		local get_map = M.get_order_y_map(data.del_map)
		--从没有用过的表中取出数据并删除取过的数据
		local new_map_temp = M.get_map_and_del(maps,get_map)
		--将取出的数据转成要放入当前map中的格式
		data.new_map = M.new_map_convert_add_map(new_map_temp,cfg.size.max_y)
		--从当前表中删除需要消除的数据
		map = M.del_map_by_map(map,data.del_map)
		--将新数据加入map中
		map = M.add_map_to_map(data.new_map,map)

		--lucky同步
		new_map_temp = M.get_map_and_del(maps_lucky,get_map)
		data.new_map_lucky = M.new_map_convert_add_map(new_map_temp,cfg.size.max_y)
		map_lucky = M.del_map_by_map(map_lucky,data.del_map)
		map_lucky = M.add_map_to_map(data.new_map_lucky,map_lucky)
	end

	local function save_data(data)
		data.maps = basefunc.deepcopy(maps)
		data.map = basefunc.deepcopy(map)
		data.maps_lucky = basefunc.deepcopy(maps_lucky)
		data.map_lucky = basefunc.deepcopy(map_lucky)
		-- if data.win_lucky and data.win_lucky.max_win_count > M.eliminate_enum.nor then
		-- 	--摇中4和5连需要优先处理
		-- 	table.insert( result,1,data)
		-- 	-- table.insert(result,data)
		-- else
		-- 	table.insert(result,data)
		-- end
		table.insert(result,data)
	end

	lottery = function (data)
		data.del_list,data.del_map = M.get_eliminate_all_element(map,{M.fruit_enum.lucky,M.fruit_enum.null})
		--没有消除元素开奖结束
		if not data.del_list or not data.del_map then
			save_data(data)
			return
		end
		--判定本次开奖是不是lucky开奖,并处理lucky开奖的相关数据
		if data.current_type == M.lottery_type.lucky and data.win_lucky then
			if data.win_lucky.max_win_count == M.eliminate_enum.nor then
				--lucky摇中3个
				--消除同类型的元素
				for i,win_v in ipairs(data.win_lucky.win_list) do
					local del_index
					for i,del_v in ipairs(data.del_list) do
						if win_v[1].x == del_v[1].x and win_v[1].y == del_v[1].y and win_v[1].id == del_v[1].id	then
							del_index = i
						end
					end
					if del_index then
						local del_type_all = basefunc.deepcopy(data.del_list[del_index])
						table.remove( data.del_list,del_index )
						table.insert( data.del_list, 1 , win_v)
					end
				end
			elseif data.win_lucky.max_win_count == M.eliminate_enum.del_type then
				--消除同类型的元素
				for i,v in ipairs(data.win_lucky.win_list) do
					if #v == data.win_lucky.max_win_count then
						local temp_list,temp_map = M.get_type_all_element(map,v[1].id,data.del_map)
						-- table.insert(data.del_list,1,temp_list)
						data.del_type_list = basefunc.deepcopy(temp_list)
						local del_type_all = {}

						for i=#data.del_list,1,-1 do
								local d_v = data.del_list[i]
								if d_v[1].id == v[1].id then
									local del_type_list = basefunc.deepcopy(d_v)
									table.remove( data.del_list, i )
									del_type_all = M.add_list_to_list(del_type_all,del_type_list)
								end
						end
						del_type_all = M.add_list_to_list(del_type_all,temp_list)
						table.insert( data.del_list, 1 , del_type_all)
						M.add_map_to_map(temp_map,data.del_map)
					end
				end
			elseif data.win_lucky.max_win_count >= M.eliminate_enum.clear_all then
				data.del_list = {}
				data.del_list[1] = M.change_map_to_list(map)
				data.del_map = basefunc.deepcopy(map)
				data.del_all_list = basefunc.deepcopy(data.win_lucky.win_list)
			end
		end
		change_map(data)
		save_data(data)
		--开奖结束
		if data.win_lucky and data.win_lucky.over then return end
		eliminate_compute()
	end

	eliminate_compute = function ()
		if recursive_count > 100 then
			print("<color=red>递归计数</color>",recursive_count)
			return
		end
		recursive_count = recursive_count + 1

		local data = {}
		if M.check_map_have_lucky(map) then
			--得到lucky数据
			data.win_lucky = M.get_win_lucky_data(map_lucky)
			data.change_lucky = M.get_change_lucky_data(map,map_lucky)
			if data.change_lucky then
				data.del_map_lucky = data.change_lucky.map --M.get_del_map_lucky(map_lucky)
				map = M.change_lucky_to_nor_in_map(map,data.change_lucky.map)
			end
			data.map_lucky_change_to_nor = basefunc.deepcopy(map)
			if data.win_lucky then
				data.current_type = M.lottery_type.lucky --本次开奖类型，lucky摇中奖才算lucky
				bureau_type = M.lottery_type.lucky
			else
				data.current_type = M.lottery_type.nor
			end
			data.have_lucky = true --本次开奖包含lucky
		else
			data.current_type = M.lottery_type.nor
		end
		lottery(data)
	end

	eliminate_compute()
	eliminate_data.result = basefunc.deepcopy(result)
	eliminate_data.bureau_type = bureau_type
	return eliminate_data
end

--获取所有需要消除的lucky
function M.get_del_map_lucky(map_lucky)
	local l_map = {}
	for x,_v in pairs(map_lucky) do
		for y,v in pairs(_v) do
			if v ~= 0 then
				l_map[x] = l_map[x] or {}
				l_map[x][y] = v
			end
		end
	end
	if not next(l_map) then
		return
	end
	return l_map
end

--获取lucky的中奖数据,3个以上lucky连在一起
function M.get_win_lucky_data(map_lucky)
	local win_list,win_map = M.get_eliminate_all_element(map_lucky,{M.fruit_enum.null})
	if not win_list or not win_map then return end
	local max_win_count = 0
	for k,v in pairs(win_list) do
		if max_win_count < #v then 
			max_win_count = #v
		end
	end
	local win_lucky_data = {}
	win_lucky_data.max_win_count = max_win_count
	win_lucky_data.win_list = win_list
	win_lucky_data.win_map = win_map
	if max_win_count == M.eliminate_enum.del_type or
	  max_win_count >= M.eliminate_enum.clear_all then
		win_lucky_data.over = true
	end
	return win_lucky_data
end

--从二维表中取出一个二维表并将取过的元素删除
function M.get_map_and_del(maps,get_map)
	local map = M.get_map_by_map(maps,get_map)
	M.del_map_by_map(maps,get_map)
	return map
end

--检测表中是否包含lucky
function M.check_map_have_lucky(map)
	for x,_v in pairs(map) do
        for y,v in pairs(_v) do
            if v == M.fruit_enum.lucky then
                return true
            end
        end
    end
end

--将表中的lucky变成一般的元素
function M.change_lucky_to_nor_in_map(map,map_lucky)
	if not map or not next(map) or type(map) ~= "table" then return map end
	if not map_lucky or not next(map_lucky) or type(map_lucky) ~= "table" then return map end
	for x,_v in pairs(map_lucky) do
		for y,v in pairs(_v) do
			map[x][y] = v
		end
	end
	return map
end

--获取map中3个以上lucky连在一起的数据
function M.get_change_lucky_data(map,map_lucky)
	local not_check = {
		M.fruit_enum.null,
		M.fruit_enum.apple,
		M.fruit_enum.bar,
		M.fruit_enum.melon,
		M.fruit_enum.seven,
		M.fruit_enum.star,
	}
	local change_list,change_map = M.get_eliminate_all_element(map,not_check)
	if not change_list or not change_map then return end
	local change_lucky_data = {}
	change_lucky_data.list = {}
	change_lucky_data.map = {}
	for i,_v in ipairs(change_list) do
		local t = {}
		for i,v in ipairs(_v) do
			if map_lucky and map_lucky[v.x] and map_lucky[v.x][v.y] then
				t = {x = v.x, y = v.y,id = map_lucky[v.x][v.y]}
			end
			table.insert( change_lucky_data.list,t)
		end
	end
	local change_lucky_map = {}
	for x,_v in pairs(change_map) do
		for y,v in pairs(_v) do
			if map_lucky and map_lucky[x] and map_lucky[x][y] then
				change_lucky_data.map[x] = change_lucky_data.map[x] or {}
				change_lucky_data.map[x][y] = map_lucky[x][y]
			end
		end
	end
	return change_lucky_data
end

--获取开奖后每一次消除的奖励
function M.get_lottery_award_data(all_rate,all_money,bet,result_list,rate_cfg,hit_cfg)
	local all_award = {}
	local cur_all_money = 0
	local cur_all_rate = 0
	local cur_ys = 0	--当前元素
	local cur_lj = 0	--当前连击
	local cur_money = 0
	local cur_rate = 0
	local del_type_index = 0
	for i,v in ipairs(result_list) do
		if not v.type or (v.type and v.type == EliminateModel.eliminate_enum.nor) then
			cur_ys = v.cur_del_list[1].id
			cur_lj = #v.cur_del_list <= hit_cfg[cur_ys] and #v.cur_del_list or hit_cfg[cur_ys]
			cur_rate = rate_cfg[cur_ys][cur_lj]
			cur_money = bet[cur_ys] * cur_rate
			cur_all_money = cur_all_money + cur_money
			cur_all_rate = cur_all_rate + cur_rate
			table.insert( all_award,{id = cur_ys, jb = cur_money, bs = cur_rate, num = #v.cur_del_list, islucky = 0,double_hit = cur_lj})
		elseif v.type == EliminateModel.eliminate_enum.del_type then
			cur_ys = v.cur_del_list[1].id
			cur_lj = #v.cur_del_list <= hit_cfg[cur_ys] and #v.cur_del_list or hit_cfg[cur_ys]
			table.insert( all_award,{id = cur_ys, jb = 0, bs = 0, num = #v.cur_del_list, islucky = 1,double_hit = cur_lj})
			del_type_index = #all_award
		elseif v.type == EliminateModel.eliminate_enum.clear_all then
			cur_ys = v.cur_del_list[1].id
			cur_lj = hit_cfg[cur_ys]
			cur_rate = all_rate - cur_all_rate
			cur_money = all_money - cur_all_money
			cur_all_money = cur_all_money + cur_money
			cur_all_rate = cur_all_rate + cur_rate
			table.insert( all_award,{id = cur_ys, jb = cur_money, bs = cur_rate, num = #v.cur_del_list, islucky = 1,double_hit = cur_lj})
		end
	end
	--删除同类时的倍数
	if del_type_index ~= 0 and all_award[del_type_index] then
		all_award[del_type_index].jb = all_money - cur_all_money
		all_award[del_type_index].bs = all_rate - cur_all_rate
	end
	dump(all_award, "<color=green>奖励结果统计</color>")
	return all_award
end

function M.compute_fix_xiaochu_result(fix_xiaochu_str,cfg)
	local fix_xiaochu_data = {}
	local map = M.str_maps_conver_to_pos_maps(fix_xiaochu_str,cfg.size.max_x)
	fix_xiaochu_data.current_type = M.lottery_type.fix
	fix_xiaochu_data.del_list = {}
	fix_xiaochu_data.del_list[1] = {}
	local t = M.change_map_to_list(map)
	for i,v in ipairs(t) do
		if v.id ~= 0 then
			table.insert( fix_xiaochu_data.del_list[1], v )
		end
	end
	fix_xiaochu_data.del_map = M.change_list_to_map(fix_xiaochu_data.del_list[1])
	return fix_xiaochu_data
end