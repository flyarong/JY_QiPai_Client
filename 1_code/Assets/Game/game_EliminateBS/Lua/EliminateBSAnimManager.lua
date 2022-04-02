-- 创建时间:2019-03-19
EliminateBSAnimManager = {}
local M = EliminateBSAnimManager
local callback_list = {}
function M.ExitTimer()
	dump("动画退出", "<color=white>动画退出>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>></color>")
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

	for i,v in ipairs(M.big_game_timers or {}) do
		if v then
			v:Stop()
			v = nil
		end
	end
	M.big_game_timers = {}
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

function M.EliminateItemDown(item_map,new_special_part_map,callback)
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

	for x=1,eliminate_bs_algorithm.wide_max do
		for y=1,eliminate_bs_algorithm.high_max do
			if item_map[x] and item_map[x][y] then
				local pos = eliminate_bs_algorithm.get_pos_by_index(x,y)
				if IsEquals(item_map[x][y].ui.transform) and item_map[x][y].ui.transform.localPosition ~= pos then
					local seq = DoTweenSequence.Create()
					seq:Append(item_map[x][y].ui.transform:DOLocalMove(pos, EliminateBSModel.GetTime(EliminateBSModel.time.ys_yd)):SetEase(DG.Tweening.Ease.Linear))
					if new_special_part_map and new_special_part_map[x] and new_special_part_map[x][y] then
						if IsEquals(new_special_part_map[x][y].transform) and new_special_part_map[x][y].transform.localPosition ~= pos then
							seq:Append(new_special_part_map[x][y].transform:DOLocalMove(pos, EliminateBSModel.GetTime(EliminateBSModel.time.ys_yd)):SetEase(DG.Tweening.Ease.Linear))
						end
					end
					seq:OnForceKill(function ()
						if not item_map or not item_map[x] or not item_map[x][y] or not IsEquals(item_map[x][y].ui) then return end
						item_map[x][y].ui.transform.localPosition = pos
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

	for x,_v in pairs(item_map) do
		for y,v in pairs(_v) do
			local pos = eliminate_bs_algorithm.get_pos_by_index(x,y)
			if IsEquals(v.ui.transform) and v.ui.transform.localPosition ~= pos then
				local seq = DoTweenSequence.Create()
				seq:Append(v.ui.transform:DOLocalMove(pos, EliminateBSModel.GetTime(EliminateBSModel.time.ys_yd)):SetEase(DG.Tweening.Ease.Linear))
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
			scroll_lottery_all_fruit_map[x][y].status = EliminateBSItem.Status.speed_down
		end
	end
end

function M.StopScrollLottery(new_map,callback,times,xc_change_map)
	if EliminateBSModel.DataDamage() then return end
	table.insert( callback_list,callback )
	scroll_lottery_callback = callback
	scroll_lottery_new_map = new_map
	local max_x = EliminateBSModel.size.max_x
	if M.speed_uni_timer then M.speed_uni_timer:Stop() end
	--均匀减速
	down = function (  )
		--EliminateBSObjManager.PrintItemMap(scroll_lottery_all_fruit_map,"PPPPPPPPPPPP22222222222")
		--一列一列的减速
		local x = 1
		if M.speed_down_timer then M.speed_down_timer:Stop() end
		M.speed_down_timer = Timer.New(function (  )
			if scroll_lottery_all_fruit_map and scroll_lottery_all_fruit_map[x] then
				for y,v in ipairs(scroll_lottery_all_fruit_map[x]) do
					scroll_lottery_all_fruit_map[x][y].status = EliminateBSItem.Status.speed_down
				end
				ExtendSoundManager.PlaySound(audio_config.bsmz.bgm_bsmz_down.audio_name)
			end
			x = x + 1
		end,EliminateBSModel.GetTime(times.ys_j_sgdjg),max_x)
		M.speed_down_timer:Start()
	end
	M.speed_uni_timer = Timer.New(down,EliminateBSModel.GetTime(times.ys_ysgdsj),1)
	M.speed_uni_timer:Start()
end

function M.ScrollLottery(item_map,times,is_lock)
	EliminateBSModel.data.ScrollLottery = true
	local speed_status = {
		speed_up = "speed_up",
		speed_uniform = "speed_uniform",
		speed_down = "speed_down",
		speed_end = "speed_end",
	}
	local max_x = EliminateBSModel.size.max_x
	local max_y = EliminateBSModel.size.max_y
	local spacing = EliminateBSModel.size.size_y + EliminateBSModel.size.spac_y
	local add_y_count = EliminateBSModel.size.max_y
	local down_count = 0
	local all_count = max_x * (max_y + add_y_count)
	dump(all_count, "<color=yellow>all_countall_countall_countall_countall_count</color>")
	--先生成多余元素用于滚动
	local _map = {}
	for x=1,max_x do
		for y=max_y + 1,max_y + add_y_count do
			_map[x] = _map[x] or {}
			if (EliminateBSModel.data.state == EliminateBSModel.xc_state.nor) or (EliminateBSModel.data.state == EliminateBSModel.xc_state.null) or (EliminateBSModel.data.state == EliminateBSModel.xc_state.select) then
				_map[x][y] = math.random(EliminateBSModel.eliminate_enum.one,EliminateBSModel.eliminate_enum.five)
			end
		end
	end
	EliminateBSObjManager.AddEliminateItem(_map)
	local speed_uniform
	local speed_up
	local speed_down

	local function call(v,cb)
		if not v.obj.ui or not v.obj.ui.transform or not IsEquals(v.obj.ui.transform) then return end
		if v.status == speed_status.speed_up or v.status == speed_status.speed_uniform or v.status == speed_status.speed_down then
			if v.status == speed_status.speed_up then
				v.obj.ui.icon_img.material = EliminateBSObjManager.item_obj.material_FrontBlur
			elseif v.status == speed_status.speed_down then
				v.obj.ui.icon_img.material = nil
			end
			if v.obj.ui.transform.localPosition.y <= -spacing then
				if v.status == speed_status.speed_up then
					v.obj.ui.transform.localPosition = eliminate_bs_algorithm.get_pos_by_index(v.obj.data.x,v.obj.data.y + add_y_count)
				else
					v.obj.ui.transform.localPosition = eliminate_bs_algorithm.get_pos_by_index(v.obj.data.x,max_y + add_y_count)
				end
				local _id
				if (EliminateBSModel.data.state == EliminateBSModel.xc_state.nor) or (EliminateBSModel.data.state == EliminateBSModel.xc_state.null) or (EliminateBSModel.data.state == EliminateBSModel.xc_state.select) then
					_id = math.random(EliminateBSModel.eliminate_enum.one,EliminateBSModel.eliminate_enum.five)
				end
				if (EliminateBSModel.data.state == EliminateBSModel.xc_state.nor) or (EliminateBSModel.data.state == EliminateBSModel.xc_state.null) or (EliminateBSModel.data.state == EliminateBSModel.xc_state.select) then
					v.obj.ui.icon_img.sprite = EliminateBSObjManager.item_obj["xxl_icon_" .. _id]
					v.obj.ui.bg_img.gameObject:SetActive(false)
				end
			end
		elseif v.status == speed_status.speed_end then
			if cb and type(cb) == "function" then cb() end
			down_count = down_count + 1
			--dump(down_count, "<color=red>down_countdown_countdown_countdown_countdown_count</color>")
			if down_count == all_count then
				--EliminateBSObjManager.RemoveBoatEliminateItem()
				if scroll_lottery_callback and type(scroll_lottery_callback)== "function" then
					scroll_lottery_callback()
					if EliminateBSObjManager.bgm_sdbgj_kaishi then
						local key = EliminateBSObjManager.bgm_sdbgj_kaishi
						soundMgr:CloseLoopSound(key)
						EliminateBSObjManager.bgm_sdbgj_kaishi = nil
					end
					scroll_lottery_callback = nil
				end
				scroll_lottery_new_map = nil
				scroll_lottery_all_fruit_map = nil
				EliminateBSModel.data.ScrollLottery = false
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
		seq:Append(v.obj.ui.transform:DOLocalMoveY(t_y, EliminateBSModel.GetTime(times.ys_jsgdsj))) --EliminateBSModel.time.ys_jsgdsj
		seq:SetEase(DG.Tweening.Ease.InCirc)
		seq:OnForceKill(function ()
			call(v)
		end)
	end

	speed_uniform = function  (v)
		v.status = speed_status.speed_uniform
		local seq = DoTweenSequence.Create()
		local t_y = v.obj.ui.transform.localPosition.y - spacing
		seq:Append(v.obj.ui.transform:DOLocalMoveY(t_y, EliminateBSModel.GetTime(times.ys_ysgdjg)))--EliminateBSModel.time.ys_ysgdjg
		seq:SetEase(DG.Tweening.Ease.Linear)
		seq:OnForceKill(function ()
			--dump(v,"<color=yellow><size=15>++++++++++vvvvvvvvvvvvvvvvvv++++++++++</size></color>")
			call(v)
		end)
	end

	speed_down = function  (v)
		v.status = speed_status.speed_down
		local index = eliminate_bs_algorithm.get_index_by_pos(v.obj.ui.transform.localPosition.x,v.obj.ui.transform.localPosition.y)
		if index.y > max_y then
			local id = scroll_lottery_new_map[index.x][index.y - add_y_count]
			if (EliminateBSModel.data.state == EliminateBSModel.xc_state.nor) or (EliminateBSModel.data.state == EliminateBSModel.xc_state.null) or (EliminateBSModel.data.state == EliminateBSModel.xc_state.select) then
				v.obj.ui.icon_img.sprite = EliminateBSObjManager.item_obj["xxl_icon_" .. id]
				v.obj.ui.bg_img.gameObject:SetActive(false)
			end
			v.obj.data.id = id
		end
		local seq = DoTweenSequence.Create()
		local t_y = v.obj.ui.transform.localPosition.y - spacing * add_y_count
		seq:Append(v.obj.ui.transform:DOLocalMoveY(t_y - 15, EliminateBSModel.GetTime(times.ys_j_sgdsj)):SetEase(DG.Tweening.Ease.OutCirc))
		-- seq:SetEase(DG.Tweening.Ease.OutCirc)
		seq:Append(v.obj.ui.transform:DOLocalMoveY(t_y, EliminateBSModel.GetTime(times.ys_j_sgdsj / 4)):SetEase(DG.Tweening.Ease.InCirc))
		-- seq:SetEase(DG.Tweening.Ease.OutCirc)
		seq:OnForceKill(function ()
			v.status = speed_status.speed_end
			call(v)
		end)
	end

	local all_map = {}
	--一列一列的加速
	local x = 1
	if M.speed_up_timer then M.speed_up_timer:Stop() end
	--EliminateBSObjManager.PrintItemMap(item_map,"PPPPPPPPPPPP")
	M.speed_up_timer = Timer.New(function (  )
		for y,v in ipairs(item_map[x]) do
			if v.data then
				all_map[v.data.x] = all_map[v.data.x] or {}
				all_map[v.data.x][v.data.y] = {obj = v,status = speed_status.speed_up,r_x = x,r_y = y}
				speed_up(all_map[v.data.x][v.data.y]) 
			end
		end
		x = x + 1
	end,EliminateBSModel.GetTime(times.ys_jsgdjg),max_x) --EliminateBSModel.time.ys_jsgdjg
	M.speed_up_timer:Start()
	scroll_lottery_all_fruit_map = all_map
	scroll_lottery_start_time = os.time()
end

function M.DOShakePosition(obj,t)
	local seq = DoTweenSequence.Create()
	seq:Append(obj.ui.transform:DOShakePosition(t, Vector3.New(10,10,0),40))
	seq:OnForceKill(function ()
		if obj.ui and IsEquals(obj.ui.transform) then
			obj.ui.transform.localPosition = eliminate_bs_algorithm.get_pos_by_index(obj.data.x,obj.data.y)
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

function M.DOShakePositionCamer(camer,t,end_pos,finish_call)
	if not camer then
		camer = GameObject.Find("Camera")
		end_pos = Vector3.New(0,0,-406)
	end

	local o_pos = camer.transform.localPosition
	local seq = DoTweenSequence.Create()
	seq:Append(camer.transform:DOShakePosition(t, Vector3.New(30,30,0),20))
	seq:OnKill(function(  )
		if finish_call and type(finish_call) == "function" then
            finish_call()
        end
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