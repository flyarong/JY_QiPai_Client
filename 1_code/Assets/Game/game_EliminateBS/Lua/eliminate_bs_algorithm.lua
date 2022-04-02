local basefunc = require "Game.Common.basefunc"
eliminate_bs_algorithm = basefunc.class()
local M = eliminate_bs_algorithm

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
--消除元素的倍率表
M.rate_map = {
	{0,0, 1,2,5,10},--//1 宝石
    {0,0, 2,5,10,20},--//2 宝石
    {0,0, 5,10,20,40},--//3 宝石
    {0,0, 10,20,40,80},--//4 宝石
    {0,0, 20,40,80,150},--//5 宝石
}

--消除特殊元素的倍率表
M.special_rate_map = {
	[200] = -1,
	[201] = 2,
	[202] = 5,
	[203] = 10,
	[204] = 20,
	[205] = 40,
	[210] = -1,
	[211] = 5,
	[212] = 10,
	[213] = 20,
	[214] = 40,
	[215] = 80,
	[220] = -1,
	[221] = 10,
	[222] = 20,
	[223] = 40,
	[224] = 80,
	[225] = 150,
}

--免费游戏的进度增加值
M.free_game_slider_value_add = {
	[1] = 1,
	[2] = 2,
	[3] = 2,
	[4] = 3,
	[5] = 3,
	[200] = -1,
	[201] = 2,
	[202] = 4,
	[203] = 4,
	[204] = 5,
	[205] = 5,
	[210] = -1,
	[211] = 4,
	[212] = 8,
	[213] = 8,
	[214] = 10,
	[215] = 10,
	[220] = -1,
	[221] = 8,
	[222] = 15,
	[223] = 15,
	[224] = 20,
	[225] = 20,
}

--n 消除的元素，c 消除的个数
function M.get_rate_1(n,c)
	if not n or not c then return 0 end
	if n < 0 or n > #M.rate_map then return 0 end
	if c > #M.rate_map[n] then
		c = #M.rate_map[n]
	end
	-- print("<color=green>n,c</color>",n,c,M.rate_map[n][c])
	return M.rate_map[n][c] / 10
end

function M.get_rate_2(v)
	local tab = {}
	for x=1,M.wide_max do
		if v[x] then
			for y=1,M.high_max do
				if v[x][y] and v[x][y] >= 200 then
					local temp_num_1 = tostring(v[x][y])
					local temp_num_2 = string.sub(temp_num_1,1,3)
					local _id = tonumber(temp_num_2)
					if M.special_rate_map[_id] then
						tab[#tab + 1] = M.special_rate_map[_id] / 10
					end
				end
			end
		end
	end
	return tab
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

--得到map中所有要消除的元素,check_ids为进行检查的id列表
function M.get_eliminate_all_element_1(map,check_ids)
	if not map or not next(map) then return end
	local xc_list_map = {}
	local xc_map = {}
	local special_map = {}
	local hash_map = {}
	for y = M.high_max, 1, -1 do
		for x = 1, M.wide_max, 1 do
			if check_ids[map[x][y]] then
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
	else
		for k,v in pairs(xc_list_map) do
			local count = 0
			local id = 0
			for kk,vv in pairs(v) do
				for kkk,vvv in pairs(vv) do
					id = vvv
					count = count + 1
				end
			end
			if count < 4 then
			else
				local special_id = 0
				if count == 4 then
					special_id = 200 + id
				elseif count == 5 then
					special_id = 210 + id
				elseif count >= 6 then
					local temp_num_1 = 220 + id
					local temp_num_2 = count
					local str = temp_num_1 .. temp_num_2
					special_id = tonumber(str)
				end
				local min_x = 999999
				local min_y = 999999
				--[[for kk,vv in pairs(v) do
					min_x = math.min(min_x,kk)
				end
				for kk,vv in pairs(v) do
					if kk == min_x then
						for kkk,vvv in pairs(vv) do
							min_y = math.min(min_y,kkk)
						end
					end
				end--]]
				for kk,vv in pairs(v) do
					for kkk,vvv in pairs(vv) do
						min_y = math.min(min_y,kkk)
					end
				end
				for kk,vv in pairs(v) do
					for kkk,vvv in pairs(vv) do
						if kkk == min_y then
							min_x = math.min(min_x,kk)
						end
					end
				end
				special_map[k] = {x = min_x , y = min_y , id = special_id}
			end
		end
	end
	if table_is_null(special_map) then
		special_map = nil
	end
	return xc_list_map, xc_map, special_map
end

--处理特殊元素
function M.To_Deal_With_Special(map, xc_list_map, type, v, temp_xc_map, mark_special_map, tab, is_insert)
	if type == 1 then
		--处理"第一类"特殊元素
		for ii=1,M.wide_max do
			if v[ii] then
				for iii=1,M.high_max do
					if map[ii] and map[ii][iii] then	
						if (not temp_xc_map[ii] or not temp_xc_map[ii][iii]) then
							tab[ii] = tab[ii] or {}
							tab[ii][iii] = map[ii][iii]
							temp_xc_map[ii] = temp_xc_map[ii] or {}
							temp_xc_map[ii][iii] = true
						end
						if map[ii][iii] >= 200 then
							if (not mark_special_map[ii] or not mark_special_map[ii][iii]) then
								mark_special_map[ii] = mark_special_map[ii] or {}
								mark_special_map[ii][iii] = true
								local type_i = 0
								local new_v = {}
								if (map[ii][iii] >= 200) and (map[ii][iii] < 210) then
									type_i = 1
									new_v[ii] = {}
									new_v[ii][#new_v[ii] + 1] = {x = ii, y = iii, id = map[ii][iii]}
								elseif (map[ii][iii] >= 210) and (map[ii][iii] < 220) then
									type_i = 2
									new_v[#new_v + 1] = {x = ii, y = iii, id = map[ii][iii]}
								elseif map[ii][iii] >= 220 then
									type_i = 3
									new_v[ii] = {}
									new_v[ii][#new_v[ii] + 1] = {x = ii, y = iii, id = map[ii][iii]}
								end
								M.To_Deal_With_Special(map, xc_list_map, type_i, new_v, temp_xc_map, mark_special_map, tab, false)	
							end
						end
					end
				end
				if is_insert then
					xc_list_map[#xc_list_map + 1] = tab
					tab = {}
				end
			end
		end
	elseif type == 2 then
		--处理"第二类"特殊元素
		local parameter_tab = {-1, 0, 1}
		for ii=1,#v do
			for n=1,#parameter_tab do
				local x = parameter_tab[n]
				for m=1,#parameter_tab do
					local y = parameter_tab[m]
					local new_x = v[ii].x + x
					local new_y = v[ii].y + y
					if map[new_x] and map[new_x][new_y] then
						if (not temp_xc_map[new_x] or not temp_xc_map[new_x][new_y]) then
							tab[new_x] = tab[new_x] or {}
							tab[new_x][new_y] = map[new_x][new_y]
							temp_xc_map[new_x] = temp_xc_map[new_x] or {}
							temp_xc_map[new_x][new_y] = true
						end
						if map[new_x][new_y] >= 200 then
							if (not mark_special_map[new_x] or not mark_special_map[new_x][new_y]) then
								mark_special_map[new_x] = mark_special_map[new_x] or {}
								mark_special_map[new_x][new_y] = true
								local type_i = 0
								local new_v = {}
								if (map[new_x][new_y] >= 200) and (map[new_x][new_y] < 210) then
									type_i = 1
									new_v[new_x] = {}
									new_v[new_x][#new_v[new_x] + 1] = {x = new_x, y = new_y, id = map[new_x][new_y]}
								elseif (map[new_x][new_y] >= 210) and (map[new_x][new_y] < 220) then
									type_i = 2
									new_v[#new_v + 1] = {x = new_x, y = new_y, id = map[new_x][new_y]}
								elseif map[new_x][new_y] >= 220 then
									type_i = 3
									new_v[new_x] = {}
									new_v[new_x][#new_v[new_x] + 1] = {x = new_x, y = new_y, id = map[new_x][new_y]}
								end
								M.To_Deal_With_Special(map, xc_list_map, type_i, new_v, temp_xc_map, mark_special_map, tab, false)	
							end
						end
					end
				end
			end
			if is_insert then
				xc_list_map[#xc_list_map + 1] = tab
				tab = {}
			end
		end
	elseif type == 3 then
		--处理"第三类"特殊元素
		local temp_list = {}
		for ii=1,M.wide_max do
			if v[ii] then
				for n,m in ipairs(v[ii]) do
					temp_list[#temp_list + 1] = m
				end
			end
		end
		for n,m in ipairs(temp_list) do
			local temp_num_1 = tostring(m.id)
			local temp_num_2 = string.sub(temp_num_1,1,3)
			local self_id = tonumber(temp_num_2) - 220
			for ii=1,M.wide_max do
				for iii=1,M.high_max do
					if map[ii] and map[ii][iii] then
						local _id = 0
						if map[ii][iii] >= 220 then
							_id = tonumber(string.sub(tostring(map[ii][iii]),1,3)) - 220
						end
						if (self_id == map[ii][iii]) or (self_id == _id) then
							if (not temp_xc_map[ii] or not temp_xc_map[ii][iii]) then
								tab[ii] = tab[ii] or {}
								tab[ii][iii] = map[ii][iii]
								temp_xc_map[ii] = temp_xc_map[ii] or {}
								temp_xc_map[ii][iii] = true
							end
						end
					end
				end
			end
			if is_insert then
				xc_list_map[#xc_list_map + 1] = tab
				tab = {}
			end
		end
	end
end

--得到map中所有要消除的元素,special_list特殊元素列表
function M.get_eliminate_all_element_2(map,special_list)
	dump(special_list,"<color=green><size=15>++++++++++special_list++++++++++</size></color>")
	if not map or not next(map) then return end
	if not special_list or not next(special_list) then return end
	local xc_list_map = {}
	local xc_map = {}
	local temp_xc_map = {}
	local mark_special_map = {}
	for i,v in ipairs(special_list) do
		if not table_is_null(v) then
			local tab = {}
			M.To_Deal_With_Special(map, xc_list_map, i, v, temp_xc_map, mark_special_map, tab, true)
		end
	end
	if table_is_null(xc_list_map) then
		xc_list_map = nil		
	else
		for kk,vv in pairs(xc_list_map) do
			for x,vvv in pairs(vv) do
				for y,_v in pairs(vvv) do
					xc_map[x] = xc_map[x] or {}
					xc_map[x][y] = _v
				end
			end
		end
	end
	if table_is_null(xc_map) then
		xc_map = nil
	end
	dump(xc_list_map,"<color=red><size=15>++++++++++xc_list_map++++++++++</size></color>")
	dump(xc_map,"<color=red><size=15>++++++++++xc_map++++++++++</size></color>")
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
	size_x = size_x or 126
	size_y = size_y or 108
	spac_x = spac_x or 0
	spac_y = spac_y or 1
	local pos = {x = 0,y = 0}
	pos.x = (x - 1) * (size_x + spac_x)
	pos.y = (y - 1) * (size_y + spac_y)
	return pos, {x = x,y = y}
end

function M.get_bg_pos_by_index(x,y,size_x,size_y,spac_x,spac_y)
	size_x = size_x or 126
	size_y = size_y or 108
	spac_x = spac_x or 0
	spac_y = spac_y or 1
	local pos = {x = 0,y = 0}
	pos.x = (x - 1) * (size_x + spac_x)
	pos.y = (y - 1) * (size_y + spac_y)
	return pos
end

function M.get_index_by_pos(x,y,size_x,size_y,spac_x,spac_y)
	size_x = size_x or 126
	size_y = size_y or 108
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
	bshj = "bshj",  -- 宝石幻境
}

function M.sever_data_convert_client_data(s_d)
	--s_d.xc_data = "353514414414414311211441215444412321234442132442421414432332151523115534243114442121532424231325351352141311443423111215111132331211333434221441333142425354242511441345533425242114551324511112253331213214324234131533311303332042032030420230405500301010002010500010102000302000004020000000100000003000000030000000",
	--s_d.xc_data = "4525555314521555152441115554545355532521354521325515543555533544451355515255325232543252525253505323521005532250013455100302025003030430020403000203050005000000",
	--s_d.xc_data = "2252555224554251512554132244454313112453431543143154333453511434544445255141455254424344431132551254225515554355003252320053522400155443005244520052203300522015004530200045101000224010004130200053505000512010000540300003103000030000",
	--s_d.xc_data = "3113412255251254132113553114233242151531155555555313413312355534545151455134253311111111111111111111111111111111103322235004431300015253000510550005100100010001000300010000000500000005000000030000000400000005000000030"
	--s_d.xc_data = "2345151234512345122345123411111123451234512345123451234512345123451234512345"--单六元素(中)
	--s_d.xc_data = "234515123451111112234512345123451234512345123451234512345123451234512345"--单六元素(右下)
	--s_d.xc_data = "23451512345111112234512345123451234512345123451234512345123451234512345"--单五元素
	--s_d.xc_data = "1111512345123451234512345123451234512345123451234512345123451234512345"--单四元素
	--s_d.xc_data = "11111121314411542552344352435445134235444225355321332251555532430000001000000230"
	--s_d--s_d.xc_data = "77147545441447574445254557525573243417455575732445544147213402777074720444703750050700707007000"
	--s_d.xc_data = "15247545133447571445254557525573243417455575732445544147213402777074720444703750050700707007000"
	--s_d.xc_data = "11247545113447571145254557525573243417455575732445544147213402777074720444703750050700707007000"
	--s_d.xc_data = "31111114525451752557324341745557573244554414721311412777074720444703750050700707007000"
	--_d.xc_data = "111111545113447571144444557525573243433333337455575732445544147213402777074720444703750050700707007000"
	--s_d.xc_data = "531175453211175731112545411125573243417455515732145544141213402777074720444703750050700707007000"--田
	--s_d.xc_data = "11147545133447571255254557525573243417455575732445544147213402777074720444703750050700707007000"--L
	--s_d.xc_data = "321475452314475711152545575255732111174551111532445544147213402777074720444703750050700707007000"--倒L
	--s_d.xc_data = "321422222314475721112545575255732111174551131532445544147213402777074720444703750050700707007000"--连环1
	--s_d.xc_data = "322422222324475721111145663333732111174551131532445544137213202777074720544703750050700707007000"--连环2
	--s_d.xc_data = "54535475451111143447571445251557525513243417155575732445544147213402777074720444703750050700707007000"--一
	dump(s_d, "<color=green>服务器数据</color>")

	if not s_d then return end

	s_d.all_rate = s_d.all_rate or 0	--总倍率
	s_d.all_money = s_d.all_award or 0	--总金币(包括基础消)
	s_d.cur_money = s_d.cur_award or 0	--当前的总金币
	s_d.all_rate = s_d.all_rate / 10 or 0
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
	-- if (data.state == M.xc_state.nor) or (data.state == M.xc_state.null) then
	-- 	M.high_max = 8
	-- 	M.wide_max = 8
	-- end

	M.sever_data_convert_client_data(data)
	local c_d = data

	--开奖结果全存在这里
	local eliminate_data = {}
	eliminate_data.all_rate = c_d.all_rate
	eliminate_data.all_money = c_d.all_money
	eliminate_data.cur_money = c_d.cur_money
	eliminate_data.is_free_game = c_d.is_free_game
	eliminate_data.little_prog = c_d.little_prog
	EliminateBSModel.is_ew_bet = c_d.is_ew_bet
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
		data.map_del = M.get_map_del_to_rule_out_special(data.special_map,basefunc.deepcopy(data.del_map))
		M.map_insert(maps,data.special_map,data.map_del)
		data.map_add = M.get_tj_map(maps,data.map_del)
		data.map_new = M.get_xc_map(maps) --过程表
		dump(data.map_add,"<color=blue><size=15>++++++++++data.map_add++++++++++</size></color>")
		dump(data.map_new,"<color=blue><size=15>++++++++++data.map_new++++++++++</size></color>")
	end

	local function set_rate_list_2(data)
		if not table_is_null(data.del_list) then
			data.del_special_rate_list = data.del_special_rate_list or {}
			dump(data.del_list,"<color=red><size=15>++99999++++++++data.del_list++++++++++</size></color>")
			for i,v in ipairs(data.del_list) do
				local rate = M.get_rate_2(v)
				table.insert(data.del_special_rate_list, rate)
			end
		end
	end

	local function set_rate_list_1(data)
		if not table_is_null(data.del_list) then
			data.del_rate_list = data.del_rate_list or {}
			for i,v in ipairs(data.del_list) do
				local c = M.get_xc_count(v)
				local n = M.get_xc_id(v)
				local rate = 0
				if n ~= M.eliminate_id[6] then
					rate = M.get_rate_1(n,c)
				elseif n == M.eliminate_id[6] then
					if eliminate_data.hf_skill_trigger_index and (i == eliminate_data.hf_skill_trigger_index) then
						rate = M.get_rate_1()
						eliminate_data.hf_skill_trigger_index = nil
					else
						rate = M.get_rate_1(n,c)
					end
				end
				table.insert(data.del_rate_list, rate)
			end
		end
	end

	lottery = function (data)
		--普通消除
		data.map_base = M.get_xc_map(maps) --过程表
		local xc_map =  M.get_xc_map(maps)

		local is_xc_special = false
		if not table_is_null(result) and (#result > 0) then
			if result[#result].special_list then
				is_xc_special = true
			end
		end
		if is_xc_special then
			data.del_list,data.del_map = M.get_eliminate_all_element_2(xc_map,result[#result].special_list)
			--dump(data,"<color=yellow><size=15>++22222++++++++data++++++++++</size></color>")
			set_rate_list_2(data)
		else
			local check_id_map = {[1] = 1, [2] = 2, [3] = 3, [4] = 4, [5] = 5, [6] = 6}
			data.del_list,data.del_map,data.special_map = M.get_eliminate_all_element_1(xc_map,check_id_map)
			dump(data.del_list,"<color=pink><size=15>++++++++++data.del_list++++++++++</size></color>")
			dump(data.del_map,"<color=yellow><size=15>++++++++++data.del_map++++++++++</size></color>")
			set_rate_list_1(data)
		end

		save_maps(data)

		if not table_is_null(data.del_list) then
			save_data(data)
			eliminate_compute(data.state)
		else
			--将此屏幕内的所有特殊元素数据做处理,以便播动画的时候使用
			local can_go_on = false
			for k,v in pairs(maps) do
				for kk,vv in pairs(v) do
					if vv >= 200 then
						can_go_on = true
						break
					end
				end
			end
			
			if can_go_on then
				data.special_list = {}
				for i=1,3 do
					data.special_list[i] = {}
				end
				for x,v in pairs(maps) do
					for y,_v in pairs(v) do
						if (_v >= 200) and (_v < 210) then
							data.special_list[1][x] = data.special_list[1][x] or {}
							data.special_list[1][x][#data.special_list[1][x] + 1] = {x = x, y = y, id = _v}
						elseif (_v >= 210) and (_v < 220) then
							data.special_list[2][#data.special_list[2] + 1] = {x = x, y = y, id = _v}
						elseif _v >= 220 then 
							data.special_list[3][x] = data.special_list[3][x] or {}
							data.special_list[3][x][#data.special_list[3][x] + 1] = {x = x, y = y, id = _v}
						end
					end
				end



				dump(data.special_list,"<color=yellow><size=15>++++++++++data.special_list++++++++++</size></color>")
				save_data(data)
				--map_remove(data)
				eliminate_compute(data.state)
			else
				dump("<color=yellow><size=15>++++结束++++++结束+++++结束+++++</size></color>")
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
		-- elseif cur_state == M.xc_state.hscb_2 then
		-- 	maps = c_d.xc_data
		-- elseif cur_state == M.xc_state.ccjj_2 then
		-- 	maps = c_d.xc_data
		else
			maps = c_d.xc_data
		end
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

function M.get_map_del_to_rule_out_special(special_map,xc_map)
	if special_map then
		for k,v in pairs(special_map) do
			xc_map[v.x][v.y] = nil
		end
		for i=1,#xc_map do
			if table_is_null(xc_map[i]) then
				xc_map[i] = nil
			end
		end
	end
	return xc_map
end

function M.get_tj_map(maps,xc_map)
	--dump(maps,"<color=yellow><size=15>++++++++++maps++++++++++</size></color>")
	dump(xc_map,"<color=yellow><size=15>++++++++++xc_map++++++++++</size></color>")
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
				if maps[x] and maps[x][y] then
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
		if xc_n[x] and start_y[x] then
			local n = xc_n[x]
			for y=start_y[x], M.high_max do
				if maps[x] and maps[x][y] then
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
		for y=M.high_max,1, -1 do
			if _v[y] then
				if map[x] and map[x][y] then
					table.remove(map[x], y)
				end
			end
		end
	end
end

function M.map_insert(map,special_map,map_del)
	local temp_tab = {}
	if special_map then
		for i=1,#map do
			for j=1,#map[i] do
				for k,v in pairs(special_map) do
					if i == v.x and j == v.y then
						local count = 0
						if map_del[i] then
							for kk,vv in pairs(map_del[i]) do
								if kk < j then
									count = count + 1
								end
							end
						end
						table.insert(map[i],j - count,v.id)
					end
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
			if not table_is_null(_v.del_special_rate_list) then
				local temp_tab = basefunc.deepcopy(_v.del_list)
				for k,v in pairs(temp_tab) do
					for kk,vv in pairs(v) do
						for i=M.high_max,1,-1 do
							if vv[i] and vv[i] < 200 then
								vv[i] = nil
							end
						end
					end
				end
				for i,v in ipairs(temp_tab) do
					table.insert(all_del_list,basefunc.deepcopy(v))
				end
			else
				for i,v in ipairs(_v.del_list) do
					table.insert(all_del_list,basefunc.deepcopy(v))
				end
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

--****************宝石幻境******************
local zero = {x = -248.5, y = -253}
function M.get_bshj_pos(x, y, spacX, spacY)
	return {x = (x - 1) * spacX + zero.x, y = (y - 1) * spacY + zero.y}
end

function M.transform_bshj_pos_to_index(i, j)
	return (j - 1) * 5 + i
end

function M.transform_bshj_index_to_pos(index)
	local i, j = 1, 1
	if index <= 5 then
		i, j = index, 1
	elseif index % 5 == 0 then
		i, j = 5, math.ceil(index / 5)
	else
		i, j = index % 5, math.ceil(index / 5)
	end
	return { i = i, j = j}
end

function M.encode_bshj_byte_data(id)
	if tonumber(id) then
		if tonumber(id) ~= 0 then
			return tonumber(id) + 26
		end
		return 0
	else
		return string.byte(id) - string.byte('a') + 1
	end
end

function M.get_bshj_map_data(data)
	data = string.sub(string.lower(data), 1, 25)
	local _data = eliminate_bs_algorithm.str_maps_conver_to_pos_maps_new(data , 5)
	local mapData = {}
	for k,v in pairs(_data) do
		mapData[k] = mapData[k] or {}
		for _k,_v in pairs(v) do
			mapData[k][_k] = _v - 9
		end
	end
	_data = nil
	return mapData
end

function M.get_bshj_lottery_data(data)
	data = string.sub(string.lower(data), 26, 55)
	local lotteryData = {}
	local num = 1
	for i = 1, 6 do
		local d = string.sub(data, num, num + 4)
		local d2 = {}
		for j = 1, #d do
			local byte = string.sub(d, j, j)
			d2[j] = eliminate_bs_algorithm.encode_bshj_byte_data(byte)
			byte = nil
		end
		lotteryData[i] = d2
		num = num + 5
		d, d2 = nil
	end
	num = nil
	return lotteryData
end


--选出与之对应的数据 二维
function M.get_bshj_match_data_map(d, s)
	local data = {}
	for i = 1, #d do 
		data[i] = data[i] or {}
		for j = 1, #d[i] do
			if s[i] >= 27 and s[i] <= 31 and j == s[i] - 26 then
				data[i][j] = 1
			else
				data[i][j] = 0
			end
			if d[i][j] == s[i] then
				data[i][j] = 1
			end	
		end
	end
	return data
end

--选出与之对应的数据 一维
function M.get_bshj_match_data_map_2(d, s)
	local data = {}
	for i = 1, #d do 
		data[i] = 0
		for j = 1, #d[i] do
			if d[i][j] == s[i] then
				data[i] = j
			end
			if s[i] >= 27 and s[i] <= 31 and j == s[i] - 26 then
				data[i] = j
			end
		end
	end
	return data
end


function M.get_bshj_macth_new_data_map(d, a)
	local data = {}
	for i = 1, #d do
		data[i] = data[i] or {}
		for j = 1, #d[i] do
			if d[i][j] ~= a[i][j] and a[i][j] == 1 then
				data[i][j] = 1
			else
				data[i][j] = 0
			end
		end
	end
	return data
end

--单次的数据更新到总数据中
function M.get_bshj_match_all_data_map(d, a)
	for i = 1, #d do
		for j = 1, #d[i] do
			if d[i][j] ~= a[i][j] and a[i][j] == 1 then
				d[i][j] = a[i][j]
			end
		end
	end
	return d
end

--修正总数据 断线重连情况下将重连前大宝箱选择添加到总数据中
--d 总数据 arr 修正用到的选择数组 num 次数
function M.get_bshj_match_all_data_corect_map(d, arr, num)
	for i =1, #arr do
		local pos = eliminate_bs_algorithm.transform_bshj_index_to_pos(tonumber(arr[i]))
		d = eliminate_bs_algorithm.add_bshj_match_all_data_map(d, pos.i, pos.j)
	end
	return d
end

function M.add_bshj_match_all_data_map(d, i, j)
	d[i][j] = 1
	return d
end

function M.get_bshj_all_rate(map, isExt)
	return eliminate_bs_algorithm.get_bshj_single_rate(map, isExt) + eliminate_bs_algorithm.get_all_bshj_line_rate(map)
end

--四角
function M.check_corner_single_match(i, j)
	if (i == 1 or i == 5) and (j == 1 or j == 5) then
		return true
	end
end
--中间
function M.check_middle_single_match(i, j)
	if i == 3 and j == 3 then
		return true
	end
end
--额外押注
function M.check_ext_single_match(i, j)
	if i == 2 and j == 3 then
		return true
	elseif i == 3 and j == 2 then
		return true
	elseif i == 3 and j == 4 then
		return true
	elseif i == 4 and j == 3 then
		return true
	end
end

--格子的四角和中间有特殊奖励
function M.get_bshj_single_rate(map, isExt)
	local rate = 0
	for i = 1, #map do 
		for j = 1, #map[i] do
			if map[i][j] == 1  then
				if eliminate_bs_algorithm.check_corner_single_match(i, j) then
					rate = rate + 0.7
				end
				if eliminate_bs_algorithm.check_middle_single_match(i, j) then
					rate = rate + 1.4
				end
				if eliminate_bs_algorithm.check_ext_single_match(i, j) and isExt then
					rate = rate + 0.7
				end
			end
		end
	end
	return rate
end

function M.get_bshj_line_map(map, lineOldMap)
	local data = {}
	local check_row_match = function(j)
		for i = 1, 5 do
			if map[i][j] ~= 1 then
				return false
			end
		end
		return true
	end
	local check_column_match = function(i)
		for j = 1, 5 do
			if map[i][j] ~= 1 then
				return false
			end
		end
		return true
	end
	local check_diagonal_up_match = function()
		for i = 1, 5 do 
			if map[i][i] ~= 1 then
				return false
			end
		end
		return true
	end

	local check_diagonal_down_match = function()
		for i = 1, 5 do 
			if map[i][6 - i] ~= 1 then
				return false
			end
		end
		return true
	end
	for i = 1, 3 do
		data[i] = {}
	end

	--对角线左下右上
	if check_diagonal_up_match() then
		data[3][1] = 1
	else
		data[3][1] = 0
	end

	--对角线左上右下
	if check_diagonal_down_match() then
		data[3][2] = 1
	else
		data[3][2] = 0
	end

	--列
	for i = 1, 5 do 
		if check_column_match(i) then
			data[2][i] = 1
		else
			data[2][i] = 0
		end
	end

	--行
	for j = 1, 5 do 
		if check_row_match(j) then
			data[1][j] = 1
		else
			data[1][j] = 0
		end
	end

	if lineOldMap then
		for i = 1, #lineOldMap do
			for j = 1, #lineOldMap[i] do
				if lineOldMap[i][j] == 2 then
					data[i][j] = 2
				end
			end
		end
	end
	return data
end

function M.get_bshj_line_fx_end_map(map)
	for i = 1, #map do
		for j = 1, #map[i] do
			if map[i][j] == 1 then
				map[i][j] = 2
			end
		end
	end
	return map
end

--所有连线的倍率
function M.get_all_bshj_line_rate(map)
	local lineNum = eliminate_bs_algorithm.get_bshj_line_num(map)
	local rate = 0
	if lineNum > 0 then
		for i = 1, lineNum do
			rate = rate + 0.5 * (i - 1) + 1.5
		end
		return rate
	else
		return 0 
	end
end

--当前连线的倍率 显示
function M.get_bshj_line_rate(map)
	local lineNum = eliminate_bs_algorithm.get_bshj_line_num(map)
	if lineNum > 0 then
		return  0.5 * (lineNum - 1) + 2
	else
		return 0
	end
end

--连线的条数
function M.get_bshj_line_num(map)
	local map = eliminate_bs_algorithm.get_bshj_line_map(map)
	local lineNum = 0
	for i = 1, #map do
		for j =1, #map[i] do
			if map[i][j] == 1 then
				lineNum = lineNum + 1
			end
		end
	end
	return lineNum
end

function M.get_bshj_all_need_select_num(map, len)
	local num = 0
	for i = 1, len do
		for j = 1, #map[i] do
			if map[i][j] == 26 then
				num = num + 1
			end
		end
	end
	return num
end

function M.get_bshj_cur_select_num(d)
	local num = 0
	for i = 1, #d do
		if d[i] == 26 then
			num = num + 1
		end
	end
	return num
end

--当触发大宝箱并进行选择，后续小宝箱有可能会再次随到进行选择的大宝箱，此时抽奖数据不显示小宝箱，而直接显示随到的宝石
function M.get_bshj_cur_data(oldData, allMatchData, allMapData)
	if not allMatchData then
		return oldData
	end
	local data = {}
	for i = 1, #oldData do
		if oldData[i] > 26 and oldData[i] < 32 and allMatchData[i][oldData[i] - 26] == 1 then
			data[i] = allMapData[i][oldData[i] - 26]
		else
			data[i] = oldData[i]
		end
	end
	return data
end
