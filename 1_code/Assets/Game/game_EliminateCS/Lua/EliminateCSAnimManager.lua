-- 创建时间:2019-03-19
EliminateCSAnimManager = {}
local M = EliminateCSAnimManager
local lucky_audio
local callback_list = {}
function M.ExitTimer()
	dump("动画退出", "<color=white>动画退出>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>></color>")
	if lucky_audio then
		soundMgr:CloseLoopSound(lucky_audio)
		lucky_audio = nil
	end

	if next(callback_list) then
		for i,v in ipairs(callback_list) do
			if type(v) == "function" then
				v = nil
			end
		end
	end
	callback_list = {}
	if M.speed_up_timer then M.speed_up_timer:Stop() end
	if M.speed_uni_timer then M.speed_uni_timer:Stop() end
	if M.speed_down_timer then M.speed_down_timer:Stop() end
	if M.change_up_timer then M.change_up_timer:Stop() end
	if M.change_uni_timers then
		for i,v in pairs(M.change_uni_timers) do
			v:Stop()
		end
	end
end

function M.Spring(item_map,t,callback)
	table.insert( callback_list,callback )
	local count = 0
	local all_count = 0
	for x,_v in pairs(item_map) do
		for y,v in pairs(_v) do
			all_count = all_count + 1
		end
	end
	if all_count == count then
		--结束
		if callback and type(callback) == "function" then
			callback()
		end
		return
	end

	for x,_v in pairs(item_map) do
		for y,v in pairs(_v) do
			if v.ui then
				v:PlaySpring()
			end
			local seq = DoTweenSequence.Create()
			seq:AppendInterval(t)
			seq:OnForceKill(function ()
				if v.ui then
					v:StopSpring()
				end
				count = count + 1
				if all_count == count then
					if callback and type(callback) == "function" then
						callback()
					end
					return
				end
			end)
		end
	end
end

function M.EliminateItemDown(item_map,callback)
	--dump(item_map,"<color=red>item_mapitem_mapitem_mapitem_mapitem_mapitem_mapitem_mapitem_map</color>")
	table.insert( callback_list,callback )
	local count = 0 --下落计数
	local all_count = 0
	for x,_v in pairs(item_map) do
		for y,v in pairs(_v) do
			all_count = all_count + 1
		end
	end
	if all_count == count then
		--结束
		if callback and type(callback) == "function" then
			callback()
		end
		return
	end

	for x,_v in pairs(item_map) do
		for y,v in pairs(_v) do
			local pos = eliminate_cs_algorithm.get_pos_by_index(x,y)
			if IsEquals(v.ui.transform) and v.ui.transform.localPosition ~= pos then
				local seq = DoTweenSequence.Create()
				seq:Append(v.ui.transform:DOLocalMove(pos, EliminateCSModel.GetTime(EliminateCSModel.time.ys_yd)):SetEase(DG.Tweening.Ease.Linear))
				seq:OnForceKill(function ()
					if not v.ui then return end
					v.ui.transform.localPosition = pos
					count = count + 1
					if all_count == count then
						if callback and type(callback) == "function" then
							callback()
						end
						return
					end
				end)
			end
		end
	end
end

local scroll_lottery_all_fruit_map
local scroll_lottery_callback
local scroll_lottery_new_map
local scroll_lottery_start_time

function M.SkipScrollLottery(new_map,callback)
	table.insert( callback_list,callback )
	scroll_lottery_callback = callback
	scroll_lottery_new_map = new_map
	for x,_v in pairs(scroll_lottery_all_fruit_map) do
		for y,v in pairs(_v) do
			scroll_lottery_all_fruit_map[x][y].status = EliminateCSItem.Status.speed_down
		end
	end
end

function M.StopScrollLottery(new_map,callback,times)
	if EliminateCSModel.DataDamage() then return end
	table.insert( callback_list,callback )
	scroll_lottery_callback = callback
	scroll_lottery_new_map = new_map
	local max_x = EliminateCSModel.size.max_x
	--匀速滚动时间
	if M.speed_uni_timer then M.speed_uni_timer:Stop() end
	M.speed_uni_timer = Timer.New(function ()
		--一列一列的减速
		local x = 1
		if M.speed_down_timer then M.speed_down_timer:Stop() end
		M.speed_down_timer = Timer.New(function (  )
			if scroll_lottery_all_fruit_map and scroll_lottery_all_fruit_map[x] then
				for y,v in ipairs(scroll_lottery_all_fruit_map[x]) do
					scroll_lottery_all_fruit_map[x][y].status = EliminateCSItem.Status.speed_down
				end
			end
			x = x + 1
		end,EliminateCSModel.GetTime(times.ys_j_sgdjg),max_x) --EliminateCSModel.time.ys_j_sgdjg
		M.speed_down_timer:Start()
	end,EliminateCSModel.GetTime(times.ys_ysgdsj),1)--EliminateCSModel.time.ys_ysgdsj
	M.speed_uni_timer:Start()
end

function M.ScrollLottery(item_map,times)
	EliminateCSModel.data.ScrollLottery = true
	local speed_status = {
		speed_up = "speed_up",
		speed_uniform = "speed_uniform",
		speed_down = "speed_down",
		speed_end = "speed_end",
	}
	local max_x = EliminateCSModel.size.max_x
	local max_y = EliminateCSModel.size.max_y
	local spacing = EliminateCSModel.size.size_y + EliminateCSModel.size.spac_y
	local add_y_count = 8
	local down_count = 0
	local all_count = max_x * (max_y + add_y_count)
	--先生成多余水果用于滚动
	local _map = {}
	for x=1,max_x do
		for y=max_y + 1,max_y + add_y_count do
			_map[x] = _map[x] or {}
			_map[x][y] = math.random(EliminateCSModel.eliminate_enum.one,EliminateCSModel.eliminate_enum.lucky)
		end
	end
	EliminateCSObjManager.AddEliminateItem(_map)
	local speed_uniform
	local speed_up
	local speed_down

	local function call(v)
		if not v.obj.ui or not v.obj.ui.transform or not IsEquals(v.obj.ui.transform) then return end
		if v.status == speed_status.speed_up or v.status == speed_status.speed_uniform or v.status == speed_status.speed_down then
			if v.status == speed_status.speed_up then
				v.obj.ui.icon_img.material = EliminateCSObjManager.item_obj.material_FrontBlur
			elseif v.status == speed_status.speed_down then
				v.obj.ui.icon_img.material = nil
			end
			if v.obj.ui.transform.localPosition.y <= -spacing then
				if v.status == speed_status.speed_up then
					v.obj.ui.transform.localPosition = eliminate_cs_algorithm.get_pos_by_index(v.obj.data.x,v.obj.data.y + add_y_count)
				else
					v.obj.ui.transform.localPosition = eliminate_cs_algorithm.get_pos_by_index(v.obj.data.x,max_y + add_y_count)
				end
				v.obj.ui.icon_img.sprite = EliminateCSObjManager.item_obj["xxl_icon_" .. math.random(EliminateCSModel.eliminate_enum.one,EliminateCSModel.eliminate_enum.lucky)]
			end
		elseif v.status == speed_status.speed_end then
			down_count = down_count + 1
			if down_count == all_count then
				if scroll_lottery_callback and type(scroll_lottery_callback)== "function" then
					scroll_lottery_callback()
					if EliminateCSObjManager.bgm_csxxl_kaishi then
						local key = EliminateCSObjManager.bgm_csxxl_kaishi
						soundMgr:CloseLoopSound(key)
						EliminateCSObjManager.bgm_csxxl_kaishi = nil
					end
					scroll_lottery_callback = nil
				end
				scroll_lottery_new_map = nil
				scroll_lottery_all_fruit_map = nil
				EliminateCSModel.data.ScrollLottery = false
			end
		end
		if v.status == speed_status.speed_up then
			v.status = speed_status.speed_uniform --加速完成进入匀速状态
		end
		if v.status == speed_status.speed_uniform then
			speed_uniform(v)
		elseif v.status == speed_status.speed_up then
			speed_up(v)
		elseif v.status == speed_status.speed_down then
			speed_down(v)
		end
	end

	speed_up = function (v)
		v.status = speed_status.speed_up
		local seq = DoTweenSequence.Create()
		local t_y = v.obj.ui.transform.localPosition.y - spacing * add_y_count
		seq:Append(v.obj.ui.transform:DOLocalMoveY(t_y, EliminateCSModel.GetTime(times.ys_jsgdsj))) --EliminateCSModel.time.ys_jsgdsj
		seq:SetEase(DG.Tweening.Ease.InCirc)
		seq:OnKill(function ()
			call(v)
		end)
	end

	speed_uniform = function  (v)
		v.status = speed_status.speed_uniform
		local seq = DoTweenSequence.Create()
		local t_y = v.obj.ui.transform.localPosition.y - spacing
		seq:Append(v.obj.ui.transform:DOLocalMoveY(t_y, EliminateCSModel.GetTime(times.ys_ysgdjg)))--EliminateCSModel.time.ys_ysgdjg
		seq:SetEase(DG.Tweening.Ease.Linear)
		seq:OnKill(function ()
			call(v)
		end)
	end

	speed_down = function  (v)
		v.status = speed_status.speed_down
		local index = eliminate_cs_algorithm.get_index_by_pos(v.obj.ui.transform.localPosition.x,v.obj.ui.transform.localPosition.y)
		if index.y > max_y then
			local id = scroll_lottery_new_map[index.x][index.y - add_y_count]
			v.obj.ui.icon_img.sprite = EliminateCSObjManager.item_obj["xxl_icon_" .. id]
		end
		local seq = DoTweenSequence.Create()
		local t_y = v.obj.ui.transform.localPosition.y - spacing * add_y_count
		seq:Append(v.obj.ui.transform:DOLocalMoveY(t_y, EliminateCSModel.GetTime(times.ys_j_sgdsj))) --EliminateCSModel.time.ys_j_sgdsj
		seq:SetEase(DG.Tweening.Ease.OutCirc)
		seq:OnKill(function ()
			v.status = speed_status.speed_end
			call(v)
		end)
	end

	local all_map = {}
	--一列一列的加速
	local x = 1
	if M.speed_up_timer then M.speed_up_timer:Stop() end
	M.speed_up_timer = Timer.New(function (  )
		for y,v in ipairs(item_map[x]) do
			if v.data then
				all_map[v.data.x] = all_map[v.data.x] or {}
				all_map[v.data.x][v.data.y] = {obj = v,status = speed_status.speed_up}
				speed_up(all_map[v.data.x][v.data.y]) 
			end
		end
		x = x + 1
	end,EliminateCSModel.GetTime(times.ys_jsgdjg),max_x) --EliminateCSModel.time.ys_jsgdjg
	M.speed_up_timer:Start()
	scroll_lottery_all_fruit_map = all_map
	scroll_lottery_start_time = os.time()
end

function M.DOShakePosition(obj,t)
	local seq = DoTweenSequence.Create()
	seq:Append(obj.ui.transform:DOShakePosition(t, Vector3.New(10,10,0),40))
	seq:OnForceKill(function ()
		if obj.ui and IsEquals(obj.ui.transform) then
			obj.ui.transform.localPosition = eliminate_cs_algorithm.get_pos_by_index(obj.data.x,obj.data.y)
		end
	end)
end

function M.DOShakePositionObjs(item_map,t)
	for x,_v in pairs(item_map) do
		for y,v in pairs(_v) do
			M.DOShakePosition(v,t)
		end
	end
end

function M.DOShakePositionCamer(camer,t,end_pos)
	if not camer then
		camer = GameObject.Find("Camera")
	end
	local o_pos = camer.transform.localPosition
	local seq = DoTweenSequence.Create()
	seq:Append(camer.transform:DOShakePosition(t, Vector3.New(30,30,0),20))
	seq:OnKill(function(  )
		if IsEquals(camer) then
			camer.transform.localPosition = o_pos
			if end_pos then
				camer.transform.localPosition = end_pos
			end
		end
	end)
	seq:OnForceKill(function ()
		if IsEquals(camer) then
			camer.transform.localPosition = o_pos
			if end_pos then
				camer.transform.localPosition = end_pos
			end
		end
	end)
end

function M.ScrollDefaultChangeToRandom(item_map,t_id,callback)
	local speed_status = {
		speed_up = "speed_up",
		speed_uniform = "speed_uniform",
		speed_down = "speed_down",
		speed_end = "speed_end",
	}
	local spacing = EliminateCSModel.size.size_x + EliminateCSModel.size.spac_x
	local add_y_count = 3
	local down_count = 0
	local all_count = 0
	local all_hero_map = {}
	for x,_v in pairs(item_map) do
		for y,v in pairs(_v) do
			all_count = all_count + 1
		end
	end
	all_count = all_count * add_y_count

	local speed_uniform
	local speed_up
	local speed_down

	local function call(v)
		if v.status == speed_status.speed_up or v.status == speed_status.speed_uniform or v.status == speed_status.speed_down then
			if not v.obj.ui or not v.obj.ui.transform or not IsEquals(v.obj.ui.transform) then return end
			if v.status == speed_status.speed_up then
				v.obj.ui.icon_img.material = EliminateCSObjManager.item_obj.material_FrontBlur
			elseif v.status == speed_status.speed_down then
				v.obj.ui.icon_img.material = nil
			end
			if v.obj.ui.transform.localPosition.y <= 0 then
				if v.status == speed_status.speed_up then
					v.obj.ui.transform.localPosition = eliminate_cs_algorithm.get_pos_by_index(1,v.obj.data.y )
				else
					v.obj.ui.transform.localPosition = eliminate_cs_algorithm.get_pos_by_index(1,v.obj.data.y)
				end
				v.obj.ui.icon_img.sprite = EliminateCSObjManager.item_obj["xxl_icon_" .. math.random(1,4)]
			end
		elseif v.status == speed_status.speed_end then
			down_count = down_count + 1
			if down_count == all_count then
				for x1,_v1 in pairs(all_hero_map) do
					for y1,v1 in pairs(_v1) do
						for x2,_v2 in pairs(v1) do
							for y2,v2 in pairs(_v2) do
								if v2.obj then
									v2.obj:Exit()
								end
							end
						end
					end
				end
				all_hero_map = {}
				if callback then
					callback()
				end
			end
		end
		if v.status == speed_status.speed_up then
			v.status = speed_status.speed_uniform --加速完成进入匀速状态
		end
		if v.status == speed_status.speed_uniform then
			speed_uniform(v)
		elseif v.status == speed_status.speed_up then
			speed_up(v)
		elseif v.status == speed_status.speed_down then
			speed_down(v)
			EliminateCSPartManager.CreateHBBlow({x =v.real_x,y = v.real_y})
		end
	end

	speed_up = function  (v)
		v.status = speed_status.speed_up
		local seq = DoTweenSequence.Create()
		local t_y = v.obj.ui.transform.localPosition.y - spacing
		seq:Append(v.obj.ui.transform:DOLocalMoveY(t_y, EliminateCSModel.time.hb_jsgdsj))
		seq:SetEase(DG.Tweening.Ease.InCirc)
		seq:OnKill(function ()
			call(v)
		end)
	end

	speed_uniform = function (v)
		v.status = speed_status.speed_uniform
		local seq = DoTweenSequence.Create()
		local t_y = v.obj.ui.transform.localPosition.y - spacing
		seq:Append(v.obj.ui.transform:DOLocalMoveY(t_y, EliminateCSModel.time.hb_ysgdsj))
		seq:SetEase(DG.Tweening.Ease.Linear)
		seq:OnKill(function ()
			call(v)
		end)
	end

	speed_down = function (v)
		v.status = speed_status.speed_down
		local index = eliminate_cs_algorithm.get_index_by_pos(v.obj.ui.transform.localPosition.x,v.obj.ui.transform.localPosition.y)
		local id = t_id
		v.obj.ui.icon_img.sprite = EliminateCSObjManager.item_obj["xxl_icon_" .. id]
		local seq = DoTweenSequence.Create()
		local t_y = v.obj.ui.transform.localPosition.y - spacing
		seq:Append(v.obj.ui.transform:DOLocalMoveY(t_y, EliminateCSModel.time.hb_j_sgdsj))
		seq:SetEase(DG.Tweening.Ease.OutCirc)
		seq:OnKill(function ()
			v.status = speed_status.speed_end
			call(v)
		end)
	end

	local function default_chang_to_random(v)
		if not v.data then return end
		local hero_map = {}
		local id
		for y=1,add_y_count do
			if y == 1 then
				id = v.data.id
			else
				id = math.random(1,6)
			end
			hero_map[1] = hero_map[1] or {}
			hero_map[1][y] ={obj = EliminateCSItem.Create({x = 1,y = y,id = id ,parent = v.ui.transform}),status = speed_status.speed_up,real_x = v.data.x,real_y = v.data.y}
			--隐藏自己
			if y == 1 then
				v.ui.icon_img.gameObject:SetActive(false)
			end

			local new_obj = hero_map[1][y]
			if IsEquals(new_obj.obj.ui.transform) then
				if new_obj.obj.ui.transform.localPosition.y <= -spacing then
					new_obj.obj.ui.transform.localPosition = eliminate_cs_algorithm.get_pos_by_index(new_obj.obj.data.x,0)
					new_obj.obj.ui.icon_img.sprite = EliminateCSObjManager.item_obj["xxl_icon_" .. math.random(1,6)]
				end
			end
			speed_up(hero_map[1][y])
		end
		return hero_map
	end

	--一行一行加速改变
	local seq = DoTweenSequence.Create()
	for x=1,8 do
		for y=1,8 do
			--加速
			if item_map[x] and item_map[x][y] then
				seq:AppendCallback(function ()
					if item_map[x][y] then
						all_hero_map[x] = all_hero_map[x] or {}
						all_hero_map[x][y] = default_chang_to_random(item_map[x][y]) --参数是创建出的英雄
					end
				end)
				seq:AppendInterval(EliminateCSModel.time.hb_gdycsj)
				seq:AppendCallback(function(  )
					for x1,v1 in pairs(all_hero_map[x][y]) do
						for y1,v2 in pairs(v1) do
							v2.status = EliminateCSItem.Status.speed_down
						end
					end
				end)
			end
		end
	end

	seq:OnForceKill(function ()
		for x=1,8 do
			for y=1,8 do
				if all_hero_map[x] and all_hero_map[x][y] then
					for x1,v1 in pairs(all_hero_map[x][y]) do
						for y1,v2 in pairs(v1) do
							v2.status = EliminateCSItem.Status.speed_down
						end
					end
				end
			end
		end
	end)
end