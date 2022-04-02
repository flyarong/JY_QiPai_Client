-- 创建时间:2019-03-19
EliminateAnimManager = {}
local M = EliminateAnimManager
local callback_list = {}
local lucky_audio = {}
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
			local pos = eliminate_algorithm.get_pos_by_index(x,y)
			if v and v.ui and v.ui.transform and IsEquals(v.ui.transform) and v.ui.transform.localPosition ~= pos then
				local seq = DoTweenSequence.Create()
				seq:Append(v.ui.transform:DOLocalMove(pos, EliminateModel.GetTime(EliminateModel.cfg.time.fruit_move_t)):SetEase(DG.Tweening.Ease.Linear))
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
			scroll_lottery_all_fruit_map[x][y].status = EliminateFruitItem.Status.speed_down
		end
	end
end

function M.StopScrollLottery(new_map,callback)
	table.insert( callback_list,callback )
	scroll_lottery_callback = callback
	scroll_lottery_new_map = new_map
	local max_x = EliminateModel.cfg.size.max_x
	--匀速滚动时间
	if M.speed_uni_timer then M.speed_uni_timer:Stop() end
	M.speed_uni_timer = Timer.New(function ()
		--一列一列的减速
		local x = 1
		if M.speed_down_timer then M.speed_down_timer:Stop() end
		M.speed_down_timer = Timer.New(function (  )
			if scroll_lottery_all_fruit_map[x] then
				for y,v in ipairs(scroll_lottery_all_fruit_map[x]) do
					scroll_lottery_all_fruit_map[x][y].status = EliminateFruitItem.Status.speed_down
				end
			end
			x = x + 1
		end,EliminateModel.GetTime(EliminateModel.cfg.time.speed_down_d),max_x)
		M.speed_down_timer:Start()
	end,EliminateModel.GetTime(EliminateModel.cfg.time.speed_uni_d),1)
	M.speed_uni_timer:Start()
end

function M.ScrollLottery(item_map)
	EliminateModel.data.ScrollLottery = true
	local speed_status = {
		speed_up = "speed_up",
		speed_uniform = "speed_uniform",
		speed_down = "speed_down",
		speed_end = "speed_end",
	}
	local max_x = EliminateModel.cfg.size.max_x
	local max_y = EliminateModel.cfg.size.max_y
	local spacing = EliminateModel.cfg.size.size_y + EliminateModel.cfg.size.spac_y
	local add_y_count = 8
	local down_count = 0
	local all_count = max_x * (max_y + add_y_count)
	--先生成多余水果用于滚动
	for x=1,max_x do
		for y=max_y + 1,max_y + add_y_count do
			EliminateObjManager.AddEliminateItem({x =x,y = y,id = math.random(EliminateModel.fruit_enum.apple,EliminateModel.fruit_enum.bar)})
		end
	end
	local speed_uniform
	local speed_up
	local speed_down

	local function call(v)
		if not v.obj.ui or not v.obj.ui.transform or not IsEquals(v.obj.ui.transform) then return end
		if v.status == speed_status.speed_up or v.status == speed_status.speed_uniform or v.status == speed_status.speed_down then
			if v.status == speed_status.speed_up then
				v.obj.ui.icon_img.material = EliminateObjManager.item_obj.material_FrontBlur
			elseif v.status == speed_status.speed_down then
				v.obj.ui.icon_img.material = nil
			end
			if v.obj.ui.transform.localPosition.y <= -spacing then
				if v.status == speed_status.speed_up then
					v.obj.ui.transform.localPosition = eliminate_algorithm.get_pos_by_index(v.obj.data.x,v.obj.data.y + add_y_count)
				else
					v.obj.ui.transform.localPosition = eliminate_algorithm.get_pos_by_index(v.obj.data.x,max_y + add_y_count)
				end
				v.obj.ui.icon_img.sprite = EliminateObjManager.item_obj["xxl_icon_" .. math.random(EliminateModel.fruit_enum.apple,EliminateModel.fruit_enum.lucky)]
			end
		elseif v.status == speed_status.speed_end then
			down_count = down_count + 1
			if down_count == all_count then
				if scroll_lottery_callback and type(scroll_lottery_callback)== "function" then
					scroll_lottery_callback()
					if EliminateObjManager.bgm_xxl_kaishi then
						local key = EliminateObjManager.bgm_xxl_kaishi
						soundMgr:CloseLoopSound(key)
						EliminateObjManager.bgm_xxl_kaishi = nil
					end
					scroll_lottery_callback = nil
				end
				scroll_lottery_new_map = nil
				scroll_lottery_all_fruit_map = nil
				if EliminateModel.data then
					EliminateModel.data.ScrollLottery = false
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
		end
	end

	speed_up = function (v)
		v.status = speed_status.speed_up
		local seq = DoTweenSequence.Create()
		local t_y = v.obj.ui.transform.localPosition.y - spacing * add_y_count
		seq:Append(v.obj.ui.transform:DOLocalMoveY(t_y, EliminateModel.GetTime(EliminateModel.cfg.time.speed_up_t)))
		seq:SetEase(DG.Tweening.Ease.InCirc)
		seq:OnForceKill(function ()
			call(v)
		end)
	end

	speed_uniform = function  (v)
		v.status = speed_status.speed_uniform
		local seq = DoTweenSequence.Create()
		local t_y = v.obj.ui.transform.localPosition.y - spacing
		seq:Append(v.obj.ui.transform:DOLocalMoveY(t_y, EliminateModel.GetTime(EliminateModel.cfg.time.speed_uni_t)))
		seq:SetEase(DG.Tweening.Ease.Linear)
		seq:OnForceKill(function ()
			call(v)
		end)
	end

	speed_down = function  (v)
		v.status = speed_status.speed_down
		local index = eliminate_algorithm.get_index_by_pos(v.obj.ui.transform.localPosition.x,v.obj.ui.transform.localPosition.y)
		if index.y > max_y then
			local id = scroll_lottery_new_map[index.x][index.y - add_y_count] or 1
			v.obj.ui.icon_img.sprite = EliminateObjManager.item_obj["xxl_icon_" .. id]
		end
		local seq = DoTweenSequence.Create()
		local t_y = v.obj.ui.transform.localPosition.y - spacing * add_y_count
		seq:Append(v.obj.ui.transform:DOLocalMoveY(t_y, EliminateModel.GetTime(EliminateModel.cfg.time.speed_down_t)))
		seq:SetEase(DG.Tweening.Ease.OutCirc)
		seq:OnForceKill(function ()
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
	end,EliminateModel.GetTime(EliminateModel.cfg.time.speed_up_d),max_x)
	M.speed_up_timer:Start()
	scroll_lottery_all_fruit_map = all_map
	scroll_lottery_start_time = os.time()
end

function M.ScrollLuckyChangeToFiurt(item_map,cur_result,callback)
	table.insert( callback_list,callback )
	local speed_status = {
		speed_up = "speed_up",
		speed_uniform = "speed_uniform",
		speed_down = "speed_down",
		speed_end = "speed_end",
	}
	local spacing = EliminateModel.cfg.size.size_x + EliminateModel.cfg.size.spac_x
	local add_y_count = 3
	local down_count = 0
	local all_count = 0
	local all_fruit_map = {}
	for x,_v in pairs(item_map) do
		for y,v in pairs(_v) do
			all_count = all_count + 1
		end
	end
	all_count = all_count * add_y_count

	local speed_uniform
	local speed_up
	local speed_down

	local is_create_blow = true
	local function call(v)
		if not v.obj.ui or not v.obj.ui.transform or not IsEquals(v.obj.ui.transform) then return end
		if v.status == speed_status.speed_up or v.status == speed_status.speed_uniform or v.status == speed_status.speed_down then
			if v.status == speed_status.speed_up then
				v.obj.ui.icon_img.material = EliminateObjManager.item_obj.material_FrontBlur
			elseif v.status == speed_status.speed_down then
				v.obj.ui.icon_img.material = nil
			end
			if v.obj.ui.transform.localPosition.x >= spacing + spacing then
				if v.status == speed_status.speed_up then
					v.obj.ui.transform.localPosition = eliminate_algorithm.get_pos_by_index(0,v.obj.data.y )
				else
					v.obj.ui.transform.localPosition = eliminate_algorithm.get_pos_by_index(0,v.obj.data.y)
				end
				-- v.obj.ui.transform.localPosition = eliminate_algorithm.get_pos_by_index(v.obj.data.x, add_y_count)
				v.obj.ui.icon_img.sprite = EliminateObjManager.item_obj["xxl_icon_" .. math.random(EliminateModel.fruit_enum.apple,EliminateModel.fruit_enum.lucky)]
			end
		elseif v.status == speed_status.speed_end then
			down_count = down_count + 1
			if down_count == all_count then
				for x1,_v1 in pairs(all_fruit_map) do
					for y1,v1 in pairs(_v1) do
						for x2,_v2 in pairs(v1) do
							for y2,v2 in pairs(_v2) do
								-- if cur_result.win_lucky then
								-- 	--lucky中奖
								-- 	for k,_v in pairs(cur_result.win_lucky.win_list) do
								-- 		for k2,v in pairs(_v) do
								-- 			if v2.real_x == v.x and v2.real_y == v.y then
								-- 				-- EliminatePartManager.CreateFruitBlow(v)
								-- 			end
								-- 		end
								-- 	end
												
								-- end
								v2.obj:Exit()
							end
						end
					end
				end
				all_fruit_map = {}
				EliminateObjManager.ClearEliminateItem()
				EliminateObjManager.CreateEliminateItem(cur_result.map_lucky_change_to_nor)
				if callback and type(callback) == "function" then
					callback()
				end
				soundMgr:CloseLoopSound(M.lucky_audio)
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
			if is_create_blow then
				EliminatePartManager.CreateFruitBlows(item_map)
				is_create_blow = false
			end
		end
	end

	speed_up = function  (v)
		v.status = speed_status.speed_up
		local seq = DoTweenSequence.Create()
		local t_y = v.obj.ui.transform.localPosition.x + spacing
		seq:Append(v.obj.ui.transform:DOLocalMoveX(t_y, EliminateModel.GetTime(EliminateModel.cfg.time.change_up_t)))
		seq:SetEase(DG.Tweening.Ease.InCirc)
		seq:OnForceKill(function ()
			call(v)
		end)
	end

	speed_uniform = function (v)
		v.status = speed_status.speed_uniform
		local seq = DoTweenSequence.Create()
		local t_y = v.obj.ui.transform.localPosition.x + spacing
		seq:Append(v.obj.ui.transform:DOLocalMoveX(t_y, EliminateModel.GetTime(EliminateModel.cfg.time.change_uni_t)))
		seq:SetEase(DG.Tweening.Ease.Linear)
		seq:OnForceKill(function ()
			call(v)
		end)
	end

	speed_down = function (v)
		v.status = speed_status.speed_down
		local index = eliminate_algorithm.get_index_by_pos(v.obj.ui.transform.localPosition.x,v.obj.ui.transform.localPosition.y)
		if index.x == 0 then
			local id = cur_result.del_map_lucky[v.real_x][v.real_y]
			v.obj.ui.icon_img.sprite = EliminateObjManager.item_obj["xxl_icon_" .. id]
		end
		local seq = DoTweenSequence.Create()
		local t_y = v.obj.ui.transform.localPosition.x + spacing
		seq:Append(v.obj.ui.transform:DOLocalMoveX(t_y, EliminateModel.GetTime(EliminateModel.cfg.time.change_down_t)))
		seq:SetEase(DG.Tweening.Ease.OutCirc)
		seq:OnForceKill(function ()
			v.status = speed_status.speed_end
			call(v)
		end)
	end

	local function lucky_chang_to_fruit(v,index_y)
		local fruit_map = {}
		local id
		for y=1,add_y_count do
			if y == 1 then
				id = v.data.id
			else
				id = math.random(EliminateModel.fruit_enum.apple,EliminateModel.fruit_enum.lucky)
			end
			fruit_map[1] = fruit_map[1] or {}
			fruit_map[1][y] ={obj = EliminateFruitItem.Create({x = y,y = 1,id = id ,parent = v.ui.transform}),status = speed_status.speed_up,real_x = v.data.x,real_y = v.data.y}
			--隐藏自己--未完成
			if y == 1 then
				v.ui.icon_img.gameObject:SetActive(false)
			end

			local v = fruit_map[1][y]
			if v.obj.ui.transform.localPosition.x >= spacing + spacing then
				if v.status == speed_status.speed_up then
					v.obj.ui.transform.localPosition = eliminate_algorithm.get_pos_by_index(0,v.obj.data.y )
				else
					v.obj.ui.transform.localPosition = eliminate_algorithm.get_pos_by_index(0,v.obj.data.y)
				end
				-- v.obj.ui.transform.localPosition = eliminate_algorithm.get_pos_by_index(v.obj.data.x, add_y_count)
				v.obj.ui.icon_img.sprite = EliminateObjManager.item_obj["xxl_icon_" .. math.random(EliminateModel.fruit_enum.apple,EliminateModel.fruit_enum.lucky)]
			end
			speed_up(fruit_map[1][y])
		end
		return fruit_map
	end

	--一列一列加速改变
	local x = 1
	if M.change_up_timer then M.change_up_timer:Stop() end
	M.change_up_timer = Timer.New(function()
		if x == 1 then
			M.lucky_audio = ExtendSoundManager.PlaySound(audio_config.xxl.bgm_xxl_lucky1.audio_name,64)
		end
		if item_map[x] then
			for y=1,EliminateModel.cfg.size.max_y do
				local v = item_map[x][y]
				if v then
					all_fruit_map[x] = all_fruit_map[x] or {}
					all_fruit_map[x][y] = lucky_chang_to_fruit(v,y)
				end
			end
		end
		x = x + 1
		if x == EliminateModel.cfg.size.max_x then
			local m_callback = function(  )
				for x,_v in pairs(all_fruit_map) do
					for y,v in pairs(_v) do
						for x1,v1 in pairs(v) do
							for y1,v2 in pairs(v1) do
								v2.status = EliminateFruitItem.Status.speed_down
							end
						end
					end
				end
			end
			M.change_uni_timers = M.change_uni_timers or {}
			local change_uni_timer = Timer.New(function ()
				m_callback()
			end,EliminateModel.GetTime(EliminateModel.cfg.time.change_uni_d),1)
			change_uni_timer:Start()
			-- change_uni_timer:SetStopCallBack(function()
			-- 	m_callback()
			-- end)
			table.insert( M.change_uni_timers,change_uni_timer)
		end
	end,EliminateModel.GetTime(EliminateModel.cfg.time.change_up_d),8)
	M.change_up_timer:Start()
end

function M.DOShakePosition(obj,t)
	local seq = DoTweenSequence.Create()
	seq:Append(obj.ui.transform:DOShakePosition(t, Vector3.New(10,10,0),40))
	seq:OnForceKill(function ()
		if obj.ui and IsEquals(obj.ui.transform) then
			obj.ui.transform.localPosition = eliminate_algorithm.get_pos_by_index(obj.data.x,obj.data.y)
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

function M.DOShakePositionCamer(camer,t)
	if not camer then
		camer = GameObject.Find("Camera")
	end
	local o_pos = camer.transform.localPosition
	local seq = DoTweenSequence.Create()
	seq:Append(camer.transform:DOShakePosition(t, Vector3.New(30,30,0),20))
	seq:OnForceKill(function ()
		camer.transform.localPosition = o_pos
	end)
end

-- 新人福卡任务出现
function M.PlayNewPlayerRedTaskAppear(parent, beginPos, endPos, call)
	local prefab = newObject("xxl_hongbaorenwu_cx",parent)
	local tran = prefab.gameObject.transform
	tran.position = beginPos

    local seq = DoTweenSequence.Create()
    seq:AppendInterval(2)
    seq:Append(tran:DOMove(endPos, 0.3):SetEase(DG.Tweening.Ease.InQuint))
    seq:AppendCallback(function ()
		M.DOShakePositionCamer(nil,1)
    end)
    seq:AppendInterval(0.5)
    seq:AppendCallback(function ()
	    if call then
	    	call()
	    end
	    call = nil
    end)
    seq:AppendInterval(1)
    seq:OnKill(function ()
	    if call then
	    	call()
	    end
	    call = nil
    end)
    seq:OnForceKill(function ()
		if prefab then
			destroy(prefab.gameObject)
		end
	end)
end