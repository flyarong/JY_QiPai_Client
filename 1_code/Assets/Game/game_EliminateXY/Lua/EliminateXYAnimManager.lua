-- 创建时间:2019-03-19
EliminateXYAnimManager = {}
local M = EliminateXYAnimManager
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
			local pos = eliminate_xy_algorithm.get_pos_by_index(x,y)
			if IsEquals(v.ui.transform) and v.ui.transform.localPosition ~= pos then
				local seq = DoTweenSequence.Create()
				seq:Append(v.ui.transform:DOLocalMove(pos, EliminateXYModel.GetTime(EliminateXYModel.time.ys_yd)):SetEase(DG.Tweening.Ease.Linear))
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
			scroll_lottery_all_fruit_map[x][y].status = EliminateXYItem.Status.speed_down
		end
	end
end

function M.StopScrollLottery(new_map,callback,times,xc_change_map)
	if EliminateXYModel.DataDamage() then return end
	table.insert( callback_list,callback )
	scroll_lottery_callback = callback
	scroll_lottery_new_map = new_map
	local max_x = EliminateXYModel.size.max_x
	if M.speed_uni_timer then M.speed_uni_timer:Stop() end

	local ys_x = EliminateXYModel.GetScrollAdd(new_map,xc_change_map)

	local down
	if not table_is_null(ys_x) then
		--不均匀减速
		down = function(  )
			--一列一列的减速
			local x = 1
			local cd = 0
			local interval = 0.02--更新频率
			local stop_t = times.ys_j_sgdjg
			if M.speed_down_timer then M.speed_down_timer:Stop() end
			M.speed_down_timer = Timer.New(function ()
				if x > max_x then
					M.speed_down_timer:Stop()
					return
				end
				cd = cd + interval
				if cd < stop_t then return end

				if scroll_lottery_all_fruit_map and scroll_lottery_all_fruit_map[x] then
					for y,v in ipairs(scroll_lottery_all_fruit_map[x]) do
						scroll_lottery_all_fruit_map[x][y].status = EliminateXYItem.Status.speed_down
					end
					ExtendSoundManager.PlaySound(audio_config.sdbgj.bgm_sdbgj_down.audio_name)
					if ys_x[x] and ys_x[x].type_id == EliminateXYModel.eliminate_enum.ts and ys_x[x].id == EliminateXYModel.eliminate_enum.ts then
						ExtendSoundManager.PlaySound(audio_config.sdbgj.bgm_sdbgj_ts_free.audio_name)
					end
				end
				x = x + 1
				stop_t = stop_t + times.ys_j_sgdjg
				if ys_x[x] then
					stop_t = stop_t + times.ys_ysgdsj_add
					EliminateXYPartManager.CreateScrollAddKuang(x,ys_x[x].y,ys_x[x].type_id)
					ExtendSoundManager.PlaySound(audio_config.sdbgj.bgm_sdbgj_disanpai_yj.audio_name)
				end
			end,interval,-1)
			M.speed_down_timer:Start()
		end
	else
		--均匀减速
		down = function (  )
			--一列一列的减速
			local x = 1
			if M.speed_down_timer then M.speed_down_timer:Stop() end
			M.speed_down_timer = Timer.New(function (  )
				if scroll_lottery_all_fruit_map and scroll_lottery_all_fruit_map[x] then
					for y,v in ipairs(scroll_lottery_all_fruit_map[x]) do
						scroll_lottery_all_fruit_map[x][y].status = EliminateXYItem.Status.speed_down
					end
					ExtendSoundManager.PlaySound(audio_config.sdbgj.bgm_sdbgj_down.audio_name)
				end
				x = x + 1
			end,EliminateXYModel.GetTime(times.ys_j_sgdjg),max_x)
			M.speed_down_timer:Start()
		end
	end
	M.speed_uni_timer = Timer.New(down,EliminateXYModel.GetTime(times.ys_ysgdsj),1)
	M.speed_uni_timer:Start()
end

function M.ScrollLottery(item_map,times,res_index)
	EliminateXYModel.data.ScrollLottery = true
	local speed_status = {
		speed_up = "speed_up",
		speed_uniform = "speed_uniform",
		speed_down = "speed_down",
		speed_end = "speed_end",
	}
	local max_x = EliminateXYModel.size.max_x
	local max_y = EliminateXYModel.size.max_y
	local spacing = EliminateXYModel.size.size_y + EliminateXYModel.size.spac_y
	local add_y_count = EliminateXYModel.size.max_y
	local down_count = 0
	local all_count = max_x * (max_y + add_y_count)
	--先生成多余元素用于滚动
	local _map = {}
	for x=1,max_x do
		for y=max_y + 1,max_y + add_y_count do
			_map[x] = _map[x] or {}
			_map[x][y] = math.random(EliminateXYModel.eliminate_enum.one,EliminateXYModel.eliminate_enum.swk)
		end
	end
	EliminateXYObjManager.AddEliminateItem(_map)
	local speed_uniform
	local speed_up
	local speed_down

	local function call(v,cb)
		if not v.obj.ui or not v.obj.ui.transform or not IsEquals(v.obj.ui.transform) then return end
		if v.status == speed_status.speed_up or v.status == speed_status.speed_uniform or v.status == speed_status.speed_down then
			if v.status == speed_status.speed_up then
				v.obj.ui.icon_img.material = EliminateXYObjManager.item_obj.material_FrontBlur
			elseif v.status == speed_status.speed_down then
				v.obj.ui.icon_img.material = nil
			end
			if v.obj.ui.transform.localPosition.y <= -spacing then
				if v.status == speed_status.speed_up then
					v.obj.ui.transform.localPosition = eliminate_xy_algorithm.get_pos_by_index(v.obj.data.x,v.obj.data.y + add_y_count)
				else
					v.obj.ui.transform.localPosition = eliminate_xy_algorithm.get_pos_by_index(v.obj.data.x,max_y + add_y_count)
				end
				local _id = math.random(EliminateXYModel.eliminate_enum.one,EliminateXYModel.eliminate_enum.swk)
				v.obj.ui.icon_img.sprite = EliminateXYObjManager.item_obj["xxl_icon_" .. _id]
				v.obj.ui.bg.gameObject:SetActive(_id == EliminateXYModel.eliminate_enum.bgj)
			end
		elseif v.status == speed_status.speed_end then
			if cb and type(cb) == "function" then cb() end
			down_count = down_count + 1
			if down_count == all_count then
				if scroll_lottery_callback and type(scroll_lottery_callback)== "function" then
					scroll_lottery_callback()
					if EliminateXYObjManager.bgm_sdbgj_kaishi then
						local key = EliminateXYObjManager.bgm_sdbgj_kaishi
						soundMgr:CloseLoopSound(key)
						EliminateXYObjManager.bgm_sdbgj_kaishi = nil
					end
					scroll_lottery_callback = nil
				end
				scroll_lottery_new_map = nil
				scroll_lottery_all_fruit_map = nil
				EliminateXYModel.data.ScrollLottery = false
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
		seq:Append(v.obj.ui.transform:DOLocalMoveY(t_y, EliminateXYModel.GetTime(times.ys_jsgdsj))) --EliminateXYModel.time.ys_jsgdsj
		seq:SetEase(DG.Tweening.Ease.InCirc)
		seq:OnForceKill(function ()
			call(v)
		end)
	end

	speed_uniform = function  (v)
		v.status = speed_status.speed_uniform
		local seq = DoTweenSequence.Create()
		v.obj.ui.money_txt.text = ""
		local t_y = v.obj.ui.transform.localPosition.y - spacing
		seq:Append(v.obj.ui.transform:DOLocalMoveY(t_y, EliminateXYModel.GetTime(times.ys_ysgdjg)))--EliminateXYModel.time.ys_ysgdjg
		seq:SetEase(DG.Tweening.Ease.Linear)
		seq:OnForceKill(function ()
			call(v)
		end)
	end

	speed_down = function  (v)
		v.status = speed_status.speed_down
		local index = eliminate_xy_algorithm.get_index_by_pos(v.obj.ui.transform.localPosition.x,v.obj.ui.transform.localPosition.y)
		local cb
		if index.y > max_y then
			local id = scroll_lottery_new_map[index.x][index.y - add_y_count]
			v.obj.ui.icon_img.sprite = EliminateXYObjManager.item_obj["xxl_icon_" .. id]
			v.obj.ui.bg.gameObject:SetActive(id == EliminateXYModel.eliminate_enum.bgj)
			v.obj.data.id = id

			local bgj_rate_change = function (  )
				res_index = res_index or 1
				if v.obj.data.id ~= EliminateXYModel.eliminate_enum.bgj
					or table_is_null(EliminateXYModel.data.eliminate_data) 
					or table_is_null(EliminateXYModel.data.eliminate_data.result) 
					or table_is_null(EliminateXYModel.data.eliminate_data.result[res_index])
					or table_is_null(EliminateXYModel.data.eliminate_data.result[res_index].bgj_rate_map)
					or EliminateXYModel.data.eliminate_data.result[res_index].state == "free"
					then 
					return
				end
				local pos = eliminate_xy_algorithm.get_index_by_pos(v.obj.ui.transform.localPosition.x,v.obj.ui.transform.localPosition.y)
				local bgj_rate_map = EliminateXYModel.data.eliminate_data.result[res_index].bgj_rate_map
				if table_is_null(bgj_rate_map[pos.x]) or not bgj_rate_map[pos.x][pos.y] then
					return
				end
				local money = 0
				local bgj_rate = bgj_rate_map[pos.x][pos.y]
				money = StringHelper.ToCash(EliminateXYModel.GetAwardGold(bgj_rate))
				v.obj.ui.bg.gameObject:SetActive(true)
				EliminateXYItem.MoneyPlayAni(v.obj.ui.money_txt,money)
			end
			cb = function(  )
				bgj_rate_change()
			end
		end
		local seq = DoTweenSequence.Create()
		local t_y = v.obj.ui.transform.localPosition.y - spacing * add_y_count
		seq:Append(v.obj.ui.transform:DOLocalMoveY(t_y - 15, EliminateXYModel.GetTime(times.ys_j_sgdsj)):SetEase(DG.Tweening.Ease.OutCirc))
		-- seq:SetEase(DG.Tweening.Ease.OutCirc)
		seq:Append(v.obj.ui.transform:DOLocalMoveY(t_y, EliminateXYModel.GetTime(times.ys_j_sgdsj / 4)):SetEase(DG.Tweening.Ease.InCirc))
		-- seq:SetEase(DG.Tweening.Ease.OutCirc)
		seq:OnForceKill(function ()
			v.status = speed_status.speed_end
			call(v,cb)
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
				all_map[v.data.x][v.data.y] = {obj = v,status = speed_status.speed_up,r_x = x,r_y = y}
				speed_up(all_map[v.data.x][v.data.y]) 
			end
		end
		x = x + 1
	end,EliminateXYModel.GetTime(times.ys_jsgdjg),max_x) --EliminateXYModel.time.ys_jsgdjg
	M.speed_up_timer:Start()
	scroll_lottery_all_fruit_map = all_map
	scroll_lottery_start_time = os.time()
end

function M.DOShakePosition(obj,t)
	local seq = DoTweenSequence.Create()
	seq:Append(obj.ui.transform:DOShakePosition(t, Vector3.New(10,10,0),40))
	seq:OnForceKill(function ()
		if obj.ui and IsEquals(obj.ui.transform) then
			obj.ui.transform.localPosition = eliminate_xy_algorithm.get_pos_by_index(obj.data.x,obj.data.y)
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
		end_pos = Vector3.New(0,0,-406)
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

function M.ScrollSWKSkill3(_item_map,data_map,rate_map,callback)
	local item_map = {}--数据转换
	for x,_v in pairs(_item_map) do
		for y,v in pairs(_v) do
			item_map[x] = item_map[x] or {}
			item_map[x][y] = {}
			item_map[x][y].data = {id=data_map[x][y], x=x, y=y}
			item_map[x][y].ui = {}
			item_map[x][y].ui.gameObject = _item_map[x][y].gameObject
			item_map[x][y].ui.transform = item_map[x][y].ui.gameObject.transform
			LuaHelper.GeneratingVar(item_map[x][y].ui.transform, item_map[x][y].ui)
			-- item_map[x][y].ui.icon_img.sprite = EliminateXYObjManager.item_obj["xxl_icon_" .. item_map[x][y].data.id]
		end
	end
	local change_up_t = EliminateXYModel.time.swk_skill3_change_up_t --加速时间
	local change_uni_t = EliminateXYModel.time.swk_skill3_change_uni_t --每一次滚动时间
	local change_down_t = EliminateXYModel.time.swk_skill3_change_down_t --减速时间
	local change_uni_d = EliminateXYModel.time.swk_skill3_change_uni_d --匀速滚动时长
	local change_up_d = EliminateXYModel.time.swk_skill3_change_up_d --滚动加速间隔

	local speed_status = {
		speed_up = "speed_up",
		speed_uniform = "speed_uniform",
		speed_down = "speed_down",
		speed_end = "speed_end",
	}
	local material_FrontBlur = GetMaterial("FrontBlur")
	local spacing = 144
	local add_y_count = 3
	local down_count = 0
	local all_count = 0
	local all_item_map = {}
	for x,_v in pairs(item_map) do
		for y,v in pairs(_v) do
			all_count = all_count + 1
		end
	end
	all_count = all_count * add_y_count

	local speed_uniform
	local speed_up
	local speed_down

	local function get_pos_by_index(x,y,size_x,size_y,spac_x,spac_y)
		size_x = size_x or 200
		size_y = size_y or 140
		spac_x = spac_x or 4
		spac_y = spac_y or 4
		local pos = {x = 0,y = 0}
		pos.x = (x - 1) * (size_x + spac_x)
		pos.y = (y - 1) * (size_y + spac_y)
		return pos
	end

	local function get_index_by_pos(x,y,size_x,size_y,spac_x,spac_y)
		size_x = size_x or 200
		size_y = size_y or 140
		spac_x = spac_x or 4
		spac_y = spac_y or 4
		local index = {x = 1,y = 1}
		index.x = math.floor(x / (size_x + spac_x)) + 1
		index.y = math.floor(y / (size_y + spac_y)) + 1
		return index
	end

	local function create_obj(data)
		local _obj = {}
		_obj.ui = {}
		_obj.data = data
		local parent = _obj.data.parent
		if not parent then return end
		_obj.ui.gameObject = GameObject.Instantiate(data.obj, parent)
		_obj.ui.gameObject = _obj.ui.gameObject.gameObject
		_obj.ui.transform = _obj.ui.gameObject.transform
		_obj.ui.transform.localPosition = get_pos_by_index(_obj.data.x,_obj.data.y)
		_obj.ui.gameObject.name = _obj.data.x .. "_" .. _obj.data.y
		LuaHelper.GeneratingVar(_obj.ui.transform, _obj.ui)
		_obj.ui.icon_img.sprite = EliminateXYObjManager.item_obj["xxl_icon_" .. data.id]
		_obj.ui.bg.gameObject:SetActive(data.id == EliminateXYModel.eliminate_enum.bgj)
		return _obj
	end

	local function call(v,cb)
		if not v.obj.ui or not v.obj.ui.transform or not IsEquals(v.obj.ui.transform) then return end
		if v.status == speed_status.speed_up or v.status == speed_status.speed_uniform or v.status == speed_status.speed_down then
			if v.status == speed_status.speed_up then
				v.obj.ui.icon_img.material = material_FrontBlur
			elseif v.status == speed_status.speed_down then
				v.obj.ui.icon_img.material = nil
			end
			if v.obj.ui.transform.localPosition.y < -spacing then
				v.obj.ui.transform.localPosition = get_pos_by_index(1,2)
				local _id =  math.random( 1,8)
				v.obj.ui.icon_img.sprite = EliminateXYObjManager.item_obj["xxl_icon_" .. _id]
				v.obj.ui.bg.gameObject:SetActive(_id == EliminateXYModel.eliminate_enum.bgj)
			end
		elseif v.status == speed_status.speed_end then
			if cb and type(cb) == "function" then
				cb()
			end
			down_count = down_count + 1
			if down_count == all_count then
				for x,_v in pairs(item_map) do
					for y,v in pairs(_v) do
						if IsEquals(v.ui.icon_img) then
							v.ui.icon_img.gameObject:SetActive(true)
						end
					end
				end
				for x1,_v1 in pairs(all_item_map) do
					for y1,v1 in pairs(_v1) do
						for x2,_v2 in pairs(v1) do
							for y2,v2 in pairs(_v2) do
								Destroy(v2.obj.ui.gameObject)
							end
						end
					end
				end
				dump(all_item_map,"<color=green>all_item_map</color>")
				all_item_map = {}
				if callback and type(callback) == "function" then
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
		end
	end

	speed_up = function  (v)
		v.status = speed_status.speed_up
		local seq = DoTweenSequence.Create()
		local t_y = v.obj.ui.transform.localPosition.y - spacing
		seq:Append(v.obj.ui.transform:DOLocalMoveY(t_y, EliminateXYModel.GetTime(change_up_t)))
		seq:SetEase(DG.Tweening.Ease.InCirc)
		seq:OnForceKill(function ()
			call(v)
		end)
	end

	speed_uniform = function (v)
		v.status = speed_status.speed_uniform
		local seq = DoTweenSequence.Create()
		local t_y = v.obj.ui.transform.localPosition.y - spacing
		seq:Append(v.obj.ui.transform:DOLocalMoveY(t_y, EliminateXYModel.GetTime(change_uni_t)))
		seq:SetEase(DG.Tweening.Ease.Linear)
		seq:OnForceKill(function ()
			call(v)
		end)
	end

	speed_down = function (v)
		v.status = speed_status.speed_down
		local index = get_index_by_pos(v.obj.ui.transform.localPosition.x,v.obj.ui.transform.localPosition.y)
		local cb
		if index.y == 2 then
			local id = item_map[v.real_x][v.real_y].data.id
			v.obj.ui.icon_img.sprite = EliminateXYObjManager.item_obj["xxl_icon_" .. id]
			v.obj.ui.bg.gameObject:SetActive(id == EliminateXYModel.eliminate_enum.bgj)
			if id == EliminateXYModel.eliminate_enum.bgj then
				local money = StringHelper.ToCash(EliminateXYModel.GetAwardGold(rate_map[v.real_x][v.real_y]))
				v.obj.ui.money_txt.text = money
				v.obj.ui.bg.gameObject:SetActive(true)
				EliminateXYPartManager.BGJBSMini(v.real_x,v.real_y)
				EliminateXYItem.ChangeMoneyTxtLayer(v.obj.ui.money_txt,6)
				EliminateXYItem.MoneyPlayAni(v.obj.ui.money_txt,money)
			end
		end
		local seq = DoTweenSequence.Create()
		local t_y = v.obj.ui.transform.localPosition.y - spacing
		seq:Append(v.obj.ui.transform:DOLocalMoveY(t_y, EliminateXYModel.GetTime(change_down_t)))
		seq:SetEase(DG.Tweening.Ease.OutCirc)
		seq:OnForceKill(function ()
			v.status = speed_status.speed_end
			call(v,cb)
		end)
	end

	local function create_temp_item(v_obj,index_x,index_y)
		if not IsEquals(item_map[index_x][index_y].ui.gameObject) then
			return
		end
		local temp_item = {}
		local id
		local ins_obj = GameObject.Instantiate(item_map[index_x][index_y].ui.gameObject)
		for y=1,add_y_count do
			if y == 1 then
				id = v_obj.data.id
			else
				id = math.random(9,12)
			end
			temp_item[1] = temp_item[1] or {}
			temp_item[1][y] ={obj = create_obj({obj = ins_obj,x = 1,y = y,id = id ,parent = v_obj.ui.transform}),status = speed_status.speed_up,real_x = v_obj.data.x,real_y = v_obj.data.y}
			local v = temp_item[1][y]
			if v.obj.ui.transform.localPosition.y < -spacing then
				v.obj.ui.transform.localPosition = get_pos_by_index(1,2)
				v.obj.ui.icon_img.sprite = EliminateXYObjManager.item_obj["xxl_icon_" .. id]
				v.obj.ui.bg.gameObject:SetActive(id == EliminateXYModel.eliminate_enum.bgj)
			end
			speed_up(temp_item[1][y])
		end
		--隐藏自己
		v_obj.ui.icon_img.gameObject:SetActive(false)
		Destroy(ins_obj)
		return temp_item
	end

	--一行一行加速改变
	local seq = DoTweenSequence.Create()
	for x=1,EliminateXYModel.size.max_x do
		for y=1,EliminateXYModel.size.max_y do
			--加速
			if item_map[x] and item_map[x][y] then
				seq:AppendCallback(function ()
					if item_map[x][y] then
						all_item_map[x] = all_item_map[x] or {}
						all_item_map[x][y] = create_temp_item(item_map[x][y],x,y)
					end
				end)
				seq:AppendInterval(EliminateXYModel.GetTime(change_up_d))
			end
		end
	end
	seq:AppendInterval(EliminateXYModel.GetTime(change_uni_d))
	for x=1,EliminateXYModel.size.max_x do
		for y=1,EliminateXYModel.size.max_y do
			if item_map[x] and item_map[x][y] then
				seq:AppendInterval(EliminateXYModel.GetTime(change_up_d))
				seq:AppendCallback(function ()
					if all_item_map[x] and all_item_map[x][y] then
						for x1,v1 in pairs(all_item_map[x][y]) do
							for y1,v2 in pairs(v1) do
								v2.status = speed_status.speed_down
							end
						end
					end
				end)
			end
		end
	end
	seq:OnForceKill(function ()
		for x=1,EliminateXYModel.size.max_x do
			for y=1,EliminateXYModel.size.max_y do
				if all_item_map[x] and all_item_map[x][y] then
					for x1,v1 in pairs(all_item_map[x][y]) do
						for y1,v2 in pairs(v1) do
							v2.status = speed_status.speed_down
						end
					end
				end
			end
		end
	end)
end

function M.ScrollBGJSkill(item_list,data_list,callback)
	local item_map = {}--数据转换
	for x=1,#item_list do
		item_map[x] = item_map[x] or {}
		item_map[x][1] = {}
		item_map[x][1].data = {id=data_list[x], x=x, y=1}
		item_map[x][1].ui = {}
		item_map[x][1].ui.gameObject = item_list[x].gameObject
		item_map[x][1].ui.transform = item_map[x][1].ui.gameObject.transform
		LuaHelper.GeneratingVar(item_map[x][1].ui.transform, item_map[x][1].ui)
		item_map[x][1].ui.num_txt.text = item_map[x][1].data.id
	end
	local change_up_t = 0.1 --加速时间
	local change_uni_t = 0.01 --每一次滚动时间
	local change_down_t = 0.1 --减速时间
	local change_uni_d = 1 --匀速滚动时长
	local change_up_d = 0.04 --滚动加速间隔

	local speed_status = {
		speed_up = "speed_up",
		speed_uniform = "speed_uniform",
		speed_down = "speed_down",
		speed_end = "speed_end",
	}
	local material_FrontBlur = GetMaterial("FrontBlur")
	local spacing = 48.5
	local add_y_count = 3
	local down_count = 0
	local all_count = 0
	local all_item_map = {}
	for x,_v in pairs(item_map) do
		for y,v in pairs(_v) do
			all_count = all_count + 1
		end
	end
	all_count = all_count * add_y_count

	local speed_uniform
	local speed_up
	local speed_down

	local function get_pos_by_index(x,y,size_x,size_y,spac_x,spac_y)
		size_x = size_x or 102.5
		size_y = size_y or 48.5
		spac_x = spac_x or 0
		spac_y = spac_y or 0
		local pos = {x = 0,y = 0}
		pos.x = (x - 1) * (size_x + spac_x)
		pos.y = (y - 1) * (size_y + spac_y)
		return pos
	end

	local function get_index_by_pos(x,y,size_x,size_y,spac_x,spac_y)
		size_x = size_x or 102.5
		size_y = size_y or 48.5
		spac_x = spac_x or 0
		spac_y = spac_y or 0
		local index = {x = 1,y = 1}
		index.x = math.floor(x / (size_x + spac_x)) + 1
		index.y = math.floor(y / (size_y + spac_y)) + 1
		return index
	end

	local function create_obj(data)
		local _obj = {}
		_obj.ui = {}
		_obj.data = data
		local parent = _obj.data.parent
		if not parent then return end
		_obj.ui.gameObject = GameObject.Instantiate(data.obj, parent)
		_obj.ui.gameObject = _obj.ui.gameObject.gameObject
		_obj.ui.transform = _obj.ui.gameObject.transform
		_obj.ui.transform.localPosition = get_pos_by_index(_obj.data.x,_obj.data.y)
		_obj.ui.gameObject.name = _obj.data.x .. "_" .. _obj.data.y
		LuaHelper.GeneratingVar(_obj.ui.transform, _obj.ui)
		_obj.ui.num_txt.text = data.id
		return _obj
	end

	local function call(v)
		if not v.obj.ui or not v.obj.ui.transform or not IsEquals(v.obj.ui.transform) then return end
		if v.status == speed_status.speed_up or v.status == speed_status.speed_uniform or v.status == speed_status.speed_down then
			if v.status == speed_status.speed_up then
				v.obj.ui.num_txt.material = material_FrontBlur
			elseif v.status == speed_status.speed_down then
				v.obj.ui.num_txt.material = nil
			end
			if v.obj.ui.transform.localPosition.y < -spacing then
				v.obj.ui.transform.localPosition = get_pos_by_index(1,2)
				v.obj.ui.num_txt.text = math.random( 0,9)
			end
		elseif v.status == speed_status.speed_end then
			down_count = down_count + 1
			if down_count == all_count then
				for x,_v in pairs(item_map) do
					for y,v in pairs(_v) do
						v.ui.num_txt.gameObject:SetActive(true)
					end
				end
				for x1,_v1 in pairs(all_item_map) do
					for y1,v1 in pairs(_v1) do
						for x2,_v2 in pairs(v1) do
							for y2,v2 in pairs(_v2) do
								Destroy(v2.obj.ui.gameObject)
							end
						end
					end
				end
				all_item_map = {}
				if callback and type(callback) == "function" then
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
		end
	end

	speed_up = function  (v)
		v.status = speed_status.speed_up
		local seq = DoTweenSequence.Create()
		local t_y = v.obj.ui.transform.localPosition.y - spacing
		seq:Append(v.obj.ui.transform:DOLocalMoveY(t_y, change_up_t))
		seq:SetEase(DG.Tweening.Ease.InCirc)
		seq:OnForceKill(function ()
			call(v)
		end)
	end

	speed_uniform = function (v)
		v.status = speed_status.speed_uniform
		local seq = DoTweenSequence.Create()
		local t_y = v.obj.ui.transform.localPosition.y - spacing
		seq:Append(v.obj.ui.transform:DOLocalMoveY(t_y, change_uni_t))
		seq:SetEase(DG.Tweening.Ease.Linear)
		seq:OnForceKill(function ()
			call(v)
		end)
	end

	speed_down = function (v)
		v.status = speed_status.speed_down
		local index = get_index_by_pos(v.obj.ui.transform.localPosition.x,v.obj.ui.transform.localPosition.y)
		if index.y == 2 then
			local id = item_map[v.real_x][v.real_y].data.id
			v.obj.ui.num_txt.text = id
		end
		local seq = DoTweenSequence.Create()
		local t_y = v.obj.ui.transform.localPosition.y - spacing
		seq:Append(v.obj.ui.transform:DOLocalMoveY(t_y, change_down_t))
		seq:SetEase(DG.Tweening.Ease.OutCirc)
		seq:OnForceKill(function ()
			v.status = speed_status.speed_end
			call(v)
		end)
	end

	local function create_temp_item(v_obj,index_x)
		if not IsEquals(item_map[index_x][1].ui.gameObject) then
			return
		end
		local temp_item = {}
		local id
		local ins_obj = GameObject.Instantiate(item_map[index_x][1].ui.gameObject)
		for y=1,add_y_count do
			if y == 1 then
				id = v_obj.data.id
			else
				id = math.random(9,12)
			end
			temp_item[1] = temp_item[1] or {}
			temp_item[1][y] ={obj = create_obj({obj = ins_obj,x = 1,y = y,id = id ,parent = v_obj.ui.transform}),status = speed_status.speed_up,real_x = v_obj.data.x,real_y = v_obj.data.y}
			local v = temp_item[1][y]
			if v.obj.ui.transform.localPosition.y < -spacing then
				v.obj.ui.transform.localPosition = get_pos_by_index(1,2)
				v.obj.ui.num_txt.text = id
			end
			speed_up(temp_item[1][y])
		end
		--隐藏自己
		v_obj.ui.num_txt.gameObject:SetActive(false)
		Destroy(ins_obj)
		return temp_item
	end
	--一行一行加速改变
	local seq = DoTweenSequence.Create()
	local max_x = 2
	local y = 1
	for x=max_x,1,-1 do
		--加速
		if item_map[x] and item_map[x][y] then
			seq:AppendCallback(function ()
				if item_map[x][y] then
					all_item_map[x] = all_item_map[x] or {}
					all_item_map[x][y] = create_temp_item(item_map[x][y],x)
				end
			end)
			seq:AppendInterval(EliminateXYModel.GetTime(change_up_d))
		end
	end
	for x=max_x,1,-1 do
		if item_map[x] and item_map[x][y] then
			seq:AppendInterval(EliminateXYModel.GetTime(change_uni_d))
			seq:AppendCallback(function ()
				if all_item_map[x] and all_item_map[x][y] then
					for x1,v1 in pairs(all_item_map[x][y]) do
						for y1,v2 in pairs(v1) do
							v2.status = speed_status.speed_down
						end
					end
				end
			end)
		end
	end

	seq:OnForceKill(function ()
		for x=max_x,1,-1 do
			if all_item_map[x] and all_item_map[x][y] then
				for x1,v1 in pairs(all_item_map[x][y]) do
					for y1,v2 in pairs(v1) do
						v2.status = speed_status.speed_down
					end
				end
			end
		end
	end)
end

function M.ScrollBigGame(item_list,data_list,callback,sp_callback,parent)
	if not IsEquals(parent) then return end
	destroyChildren(parent)
	parent.transform.localPosition = Vector3.New(100,-288,0)
	local material_FrontBlur = GetMaterial("FrontBlur")
	local time = EliminateXYModel.GetTime(24)
	local spacing = 144
	local obj_list = {}
	math.randomseed(tostring(os.time()):reverse():sub(1, 7))
	for i=1,5 do
		obj_list[#obj_list + 1] = GameObject.Instantiate(item_list[i],parent).gameObject
		obj_list[#obj_list].transform:SetAsFirstSibling()
	end
	for i=1,95 do
		local id = math.random(6,8)
		obj_list[#obj_list + 1] = GameObject.Instantiate(item_list[1],parent)
		obj_list[#obj_list].transform:SetAsFirstSibling()
		obj_list[#obj_list].transform:Find("@icon_img"):GetComponent("Image").sprite = EliminateXYObjManager.item_obj["xxl_icon_" .. id]
		
		local bg_img = obj_list[#obj_list].transform:Find("@bg"):GetComponent("Image")
		local money_img = obj_list[#obj_list].transform:Find("@money_img"):GetComponent("Image")
		if id == 8 then
			money_img.sprite = GetTexture("sdbgj_imgf_qejc")
			money_img.gameObject:SetActive(true)
			bg_img.gameObject:SetActive(true)
		elseif id== 6 then
			money_img.sprite = GetTexture("sdbgj_imgf_bljc1")
			money_img.gameObject:SetActive(true)
			bg_img.gameObject:SetActive(true)
		end
	end
	for i=1,5 do
		obj_list[#obj_list + 1] = GameObject.Instantiate(item_list[1],parent)
		obj_list[#obj_list].transform:SetAsFirstSibling()
		obj_list[#obj_list].transform:Find("@icon_img"):GetComponent("Image").sprite = EliminateXYObjManager.item_obj["xxl_icon_" .. data_list[i]]
		local id = data_list[i]
		local bg_img = obj_list[#obj_list].transform:Find("@bg"):GetComponent("Image")
		local money_img = obj_list[#obj_list].transform:Find("@money_img"):GetComponent("Image")
		if id== 6 then
			money_img.sprite = GetTexture("sdbgj_imgf_bljc1")
			money_img.gameObject:SetActive(true)
			bg_img.gameObject:SetActive(true)
		elseif id == 7 then
			money_img.gameObject:SetActive(false)
			bg_img.gameObject:SetActive(false)
		elseif id == 8 then
			money_img.sprite = GetTexture("sdbgj_imgf_qejc")
			money_img.gameObject:SetActive(true)
			bg_img.gameObject:SetActive(true)
		end
	end
	parent.gameObject:SetActive(true)
	if sp_callback and type(sp_callback) == "function" then
		sp_callback()
	end
	local b = true
	local seq = DoTweenSequence.Create()
	local t_y = parent.localPosition.y - spacing * 100 - 80
	seq:Append(parent.transform:DOLocalMoveY(t_y, time))
	seq:SetEase(DG.Tweening.Ease.OutCirc)
	seq:OnKill(function(  )
		if b and callback and type(callback) == "function" then
			callback()
			b = false
		end
		if not obj_list then return end
		for i,v in ipairs(obj_list) do
			Destroy(v.gameObject)
		end
		obj_list = {}
		parent.gameObject:SetActive(false)
	end)
	seq:OnForceKill(function ()
		if b and callback and type(callback) == "function" then
			callback()
			b = false
		end
		if not obj_list then return end
		for i,v in ipairs(obj_list) do
			Destroy(v.gameObject)
		end
		obj_list = nil
		parent.gameObject:SetActive(false)
	end)
end

function M.ScrollSWKItem(item_list,data_list,callback,parent)
	if not IsEquals(parent) then return end
	parent.transform.localPosition = Vector3.New(168,-42,0)
	local material_FrontBlur = GetMaterial("FrontBlur")
	local time = EliminateXYModel.GetTime(8)
	local spacing = 84
	local obj_list = {}
	for i=1,1 do
		obj_list[#obj_list + 1] = GameObject.Instantiate(item_list[i],parent)
		obj_list[#obj_list].transform:SetAsFirstSibling()
	end
	for i=1,99 do
		obj_list[#obj_list + 1] = GameObject.Instantiate(item_list[1],parent)
		obj_list[#obj_list].transform:SetAsFirstSibling()
		obj_list[#obj_list].transform:Find("@icon_img"):GetComponent("Image").sprite = EliminateXYObjManager.item_obj["xxl_swk_icon_" .. math.random(9,12)]
	end
	for i=1,1 do
		obj_list[#obj_list + 1] = GameObject.Instantiate(item_list[1],parent)
		obj_list[#obj_list].transform:SetAsFirstSibling()
		obj_list[#obj_list].transform:Find("@icon_img"):GetComponent("Image").sprite = EliminateXYObjManager.item_obj["xxl_swk_icon_" .. data_list[i]]
		item_list[1].transform:Find("@icon_img"):GetComponent("Image").sprite = EliminateXYObjManager.item_obj["xxl_swk_icon_" .. data_list[i]]
	end
	parent.transform.localPosition = Vector3.New(168,-42,0)
	parent.gameObject:SetActive(true)
	local b = true
	local seq = DoTweenSequence.Create()
	local t_y = parent.localPosition.y - spacing * 100
	seq:Append(parent.transform:DOLocalMoveY(t_y, time))
	seq:SetEase(DG.Tweening.Ease.OutCirc)
	seq:OnKill(function(  )
		if b and callback and type(callback) == "function" then
			callback()
			b = false
		end
		if not obj_list then return end
		for i=1,#obj_list do
			Destroy(obj_list[i].gameObject)
		end
		obj_list = nil
		parent.gameObject:SetActive(false)
	end)
	seq:OnForceKill(function ()
		if b and callback and type(callback) == "function" then
			callback()
			b = false
		end
		if not obj_list then return end
		for i=1,#obj_list do
			Destroy(obj_list[i].gameObject)
		end
		obj_list = nil
		parent.gameObject:SetActive(false)
	end)
end