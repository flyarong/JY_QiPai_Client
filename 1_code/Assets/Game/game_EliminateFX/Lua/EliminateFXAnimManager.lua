-- 创建时间:2019-03-19
EliminateFXAnimManager = {}
local M = EliminateFXAnimManager
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
	if M.fxjjAddTimer then M.fxjjAddTimer:Stop() end

	-- if M.change_uni_timers then
	-- 	for i,v in pairs(M.change_uni_timers) do
	-- 		v:Stop()
	-- 	end
	-- end

	-- for i,v in ipairs(M.big_game_timers or {}) do
	-- 	if v then
	-- 		v:Stop()
	-- 		v = nil
	-- 	end
	-- end
	-- M.big_game_timers = {}
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
			local pos = eliminate_fx_algorithm.get_pos_by_index(x,y)
			if IsEquals(v.ui.transform) and v.ui.transform.localPosition ~= pos then
				local seq = DoTweenSequence.Create()
				seq:Append(v.ui.transform:DOLocalMove(pos, EliminateFXModel.GetTime(EliminateFXModel.time.ys_yd)):SetEase(DG.Tweening.Ease.Linear))
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
			scroll_lottery_all_fruit_map[x][y].status = EliminateFXItem.Status.speed_down
		end
	end
end

function M.StopScrollLottery(new_map,callback,times,xc_change_map)
	dump(new_map,"<color=yellow><size=15>++++++++++new_map++++++++++</size></color>")
	if EliminateFXModel.DataDamage() then return end
	table.insert( callback_list,callback )
	scroll_lottery_callback = callback
	scroll_lottery_new_map = new_map
	local max_x = EliminateFXModel.size.max_x
	if M.speed_uni_timer then M.speed_uni_timer:Stop() end
	--均匀减速
	down = function (  )
		--EliminateFXObjManager.PrintItemMap(scroll_lottery_all_fruit_map,"PPPPPPPPPPPP22222222222")
		--一列一列的减速
		local x = 1
		if M.speed_down_timer then M.speed_down_timer:Stop() end
		M.speed_down_timer = Timer.New(function (  )
			if scroll_lottery_all_fruit_map and scroll_lottery_all_fruit_map[x] then
				for y,v in ipairs(scroll_lottery_all_fruit_map[x]) do
					scroll_lottery_all_fruit_map[x][y].status = EliminateFXItem.Status.speed_down
				end
				--Event.Brocast("open_sys_act_base")
				ExtendSoundManager.PlaySound(audio_config.fxgz.bgm_fxgz_down.audio_name)
			end
			x = x + 1
		end,EliminateFXModel.GetTime(times.ys_j_sgdjg),max_x)
		M.speed_down_timer:Start()
	end
	M.speed_uni_timer = Timer.New(down,EliminateFXModel.GetTime(times.ys_ysgdsj),1)
	M.speed_uni_timer:Start()
end

function M.ScrollLottery(item_map,times,is_lock)
	EliminateFXModel.data.ScrollLottery = true
	local speed_status = {
		speed_up = "speed_up",
		speed_uniform = "speed_uniform",
		speed_down = "speed_down",
		speed_end = "speed_end",
	}
	local max_x = EliminateFXModel.size.max_x
	local max_y = EliminateFXModel.size.max_y
	local spacing = EliminateFXModel.size.size_y + EliminateFXModel.size.spac_y
	local add_y_count = EliminateFXModel.size.max_y
	local down_count = 0
	local all_count = max_x * (max_y + add_y_count)
	dump(all_count, "<color=yellow>all_countall_countall_countall_countall_count</color>")
	--先生成多余元素用于滚动
	local _map = {}
	for x=1,max_x do
		for y=max_y + 1,max_y + add_y_count do
			_map[x] = _map[x] or {}
			_map[x][y] = math.random(EliminateFXModel.eliminate_enum.one,EliminateFXModel.eliminate_enum.five)
		end
	end
	EliminateFXObjManager.AddEliminateItem(_map)
	local speed_uniform
	local speed_up
	local speed_down

	local function call(v,cb)
		if not v.obj.ui or not v.obj.ui.transform or not IsEquals(v.obj.ui.transform) then return end
		if v.status == speed_status.speed_up or v.status == speed_status.speed_uniform or v.status == speed_status.speed_down then
			if v.status == speed_status.speed_up then
				v.obj.ui.icon_img.material = EliminateFXObjManager.item_obj.material_FrontBlur
			elseif v.status == speed_status.speed_down then
				v.obj.ui.icon_img.material = nil
			end
			if v.obj.ui.transform.localPosition.y <= -spacing then
				if v.status == speed_status.speed_up then
					v.obj.ui.transform.localPosition = eliminate_fx_algorithm.get_pos_by_index(v.obj.data.x,v.obj.data.y + add_y_count)
				else
					v.obj.ui.transform.localPosition = eliminate_fx_algorithm.get_pos_by_index(v.obj.data.x,max_y + add_y_count)
				end
				local _id = math.random(EliminateFXModel.eliminate_enum.one,EliminateFXModel.eliminate_enum.five)
				v.obj.ui.icon_img.sprite = EliminateFXObjManager.item_obj["xxl_icon_" .. _id]
				v.obj.ui.bg_img.gameObject:SetActive(false)
			end
		elseif v.status == speed_status.speed_end then
			if cb and type(cb) == "function" then cb() end
			down_count = down_count + 1
			if down_count == all_count then
				EliminateFXObjManager.RemoveBoatEliminateItem()
				if scroll_lottery_callback and type(scroll_lottery_callback)== "function" then
					scroll_lottery_callback()
					if EliminateFXObjManager.bgm_sdbgj_kaishi then
						local key = EliminateFXObjManager.bgm_sdbgj_kaishi
						soundMgr:CloseLoopSound(key)
						EliminateFXObjManager.bgm_sdbgj_kaishi = nil
					end
					scroll_lottery_callback = nil
				end
				scroll_lottery_new_map = nil
				scroll_lottery_all_fruit_map = nil
				EliminateFXModel.data.ScrollLottery = false
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
		seq:Append(v.obj.ui.transform:DOLocalMoveY(t_y, EliminateFXModel.GetTime(times.ys_jsgdsj))) --EliminateFXModel.time.ys_jsgdsj
		seq:SetEase(DG.Tweening.Ease.InCirc)
		seq:OnForceKill(function ()
			call(v)
		end)
	end

	speed_uniform = function  (v)
		v.status = speed_status.speed_uniform
		local seq = DoTweenSequence.Create()
		local t_y = v.obj.ui.transform.localPosition.y - spacing
		seq:Append(v.obj.ui.transform:DOLocalMoveY(t_y, EliminateFXModel.GetTime(times.ys_ysgdjg)))--EliminateFXModel.time.ys_ysgdjg
		seq:SetEase(DG.Tweening.Ease.Linear)
		seq:OnForceKill(function ()
			--dump(v,"<color=yellow><size=15>++++++++++vvvvvvvvvvvvvvvvvv++++++++++</size></color>")
			call(v)
		end)
	end

	speed_down = function  (v)
		v.status = speed_status.speed_down
		local index = eliminate_fx_algorithm.get_index_by_pos(v.obj.ui.transform.localPosition.x,v.obj.ui.transform.localPosition.y)
		if index.y > max_y then
			local id = scroll_lottery_new_map[index.x][index.y - add_y_count]
			v.obj.ui.icon_img.sprite = EliminateFXObjManager.item_obj["xxl_icon_" .. id]
			v.obj.ui.bg_img.gameObject:SetActive(false)
			v.obj.data.id = id
		end
		local seq = DoTweenSequence.Create()
		local t_y = v.obj.ui.transform.localPosition.y - spacing * add_y_count
		seq:Append(v.obj.ui.transform:DOLocalMoveY(t_y - 15, EliminateFXModel.GetTime(times.ys_j_sgdsj)):SetEase(DG.Tweening.Ease.OutCirc))
		-- seq:SetEase(DG.Tweening.Ease.OutCirc)
		seq:Append(v.obj.ui.transform:DOLocalMoveY(t_y, EliminateFXModel.GetTime(times.ys_j_sgdsj / 4)):SetEase(DG.Tweening.Ease.InCirc))
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
	-- EliminateFXObjManager.PrintItemMap(item_map,"PPPPPPPPPPPP")
	-- dump(#item_map,"<color=white>PPPPPPPPPPPP</color>")
	M.speed_up_timer = Timer.New(function (  )
		for y,v in ipairs(item_map[x]) do
			if v.data then
				all_map[v.data.x] = all_map[v.data.x] or {}
				all_map[v.data.x][v.data.y] = {obj = v,status = speed_status.speed_up,r_x = x,r_y = y}
				speed_up(all_map[v.data.x][v.data.y]) 
			end
		end
		x = x + 1
	end,EliminateFXModel.GetTime(times.ys_jsgdjg),max_x) --EliminateFXModel.time.ys_jsgdjg
	M.speed_up_timer:Start()
	scroll_lottery_all_fruit_map = all_map
	scroll_lottery_start_time = os.time()
	if is_lock and (EliminateFXModel.data.state == EliminateFXModel.xc_state.big_game) then
		_map = {}
		for x=1,max_x do
			for y=1,max_y do
				if item_map[x][y].data.id >= 100 then
					_map[x] = _map[x] or {}
					_map[x][y] = item_map[x][y].data.id
				end
			end
		end
		EliminateFXObjManager.AddBoatEliminateItem(_map)
	end
end

function M.DOShakePosition(obj,t)
	local seq = DoTweenSequence.Create()
	seq:Append(obj.ui.transform:DOShakePosition(t, Vector3.New(10,10,0),40))
	seq:OnForceKill(function ()
		if obj.ui and IsEquals(obj.ui.transform) then
			obj.ui.transform.localPosition = eliminate_fx_algorithm.get_pos_by_index(obj.data.x,obj.data.y)
		end
	end)
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

--小游戏加倍动画
function M.DoAddRateAnimation(playAnimList, seq)
	if table_is_null(playAnimList) then
		return
	end
	for i = 1, #playAnimList do
		local startPos = eliminate_fx_algorithm.get_pos_by_index(playAnimList[i].send.x, playAnimList[i].send.y)
		local endPos = eliminate_fx_algorithm.get_pos_by_index(playAnimList[i].accept.x, playAnimList[i].accept.y)
		local startPosVec = Vector3.New(startPos.x, startPos.y, 0)
		local endPosVec = Vector3.New(endPos.x, endPos.y, 0)
		M.DoAddRateFlyAnim(startPosVec, endPosVec, seq, playAnimList[i].send.id)
		M.DoAddRateBoomAnim(endPosVec, seq, playAnimList[i].send.id)
		seq:AppendCallback(function ()
			if playAnimList[i].isHandle == false then
				playAnimList[i].hander()
			end
			local rateMap = EliminateFXModel.GetBigGameRateMap()
			local score = rateMap[playAnimList[i].accept.x][playAnimList[i].accept.y]
			EliminateFXObjManager.RefreshScore(playAnimList[i].accept.x, playAnimList[i].accept.y, playAnimList[i].accept.id, score, true, true)
		end)
		seq:AppendInterval(0.38)
	end
end

function M.DoAddRateFlyAnim(startPos, endPos, seq, sendId)
	seq:AppendCallback(function ()
		EliminateFXPartManager.CreateAddRateFly(startPos, endPos, sendId, 0.7)
	end)
	seq:AppendInterval(0.5)
end

function M.DoAddRateBoomAnim(endPos, seq, sendId)
	seq:AppendCallback(function ()
		EliminateFXPartManager.CreateAddRateBoom(endPos, sendId, 0.5)
	end)
	seq:AppendInterval(0.17)
end

--小游戏结束时向奖池加钱
function M.DoAddMoneyToJc(seq, data, parent)
	-- dump(data, "<color=white>福星高照:结束时向奖池加钱动画data</color>")
	local playAnimList = {}
	for k, v in pairs(data) do
		for _k, _v in pairs(v) do
			if _v ~= 0 then
				local playAnim = {}
				playAnim.x = k
				playAnim.y = _k
				playAnim.num = _v
				playAnimList[#playAnimList + 1] = playAnim
			end
		end
	end

	table.sort(playAnimList,function(a, b)
		if a.x ~= b.x then
			return a.x > b.x
		elseif a.y ~= b.y then
			return a.y < b.y
		end
	end)

	local partEndPos = Vector3.New(340, 582, 0)
	local fxjjPanel = newObject("EliminateFXJJ", parent)
	local fxjjNumTxt = fxjjPanel.transform:Find("NumTxt"):GetComponent("Text")
	local fxJJNum = 0
	fxjjPanel.transform.localPosition = Vector3.New(0, 350, 0)
	fxjjNumTxt.text = 0

	for i = 1, #playAnimList do
		local startPos = eliminate_fx_algorithm.get_pos_by_index(playAnimList[i].x, playAnimList[i].y)
		local startPosVec = Vector3.New(startPos.x, startPos.y, 0)
		seq:AppendInterval(0.5)
		seq:AppendCallback(function ()
			fxJJNum = fxJJNum + playAnimList[i].num
			local partEndCall = function()
				M.FxjjNumRefresh(fxjjPanel, fxjjNumTxt, fxJJNum)
			end
			EliminateFXObjManager.HideScore(playAnimList[i].x, playAnimList[i].y)
			EliminateFXPartManager.CreateAddMoneyToJc(startPos, partEndPos, 1, partEndCall)
		end)
	end

	local jcClear = newObject("EliminateFXXyxClearPanel", parent)
	local jcClearUI = {}
	LuaHelper.GeneratingVar(jcClear.transform, jcClearUI)
	jcClear.gameObject:SetActive(false)

	seq:AppendInterval(1)
	seq:AppendCallback(function ()
		--奖池的结算
		jcClear.gameObject:SetActive(true)
		local num1 = EliminateFXModel.GetLittleSpecRate()
		local num2 = EliminateFXModel.GetBet()[1]
		local num3 = EliminateFXModel.GetXiaoChuAward()
		jcClearUI.fxjj_txt.text = num1
		jcClearUI.dxtr_txt.text = num2
		jcClearUI.xc_txt.text = num3
		jcClearUI.root.transform.localScale = Vector3.New(0.5, 0.5, 0.5)
		local seq2 = DoTweenSequence.Create()
		seq2:Append(jcClearUI.root.transform:DOScale(Vector3.New(1, 1, 1), 0.15):SetEase(DG.Tweening.Ease.OutQuint))
		seq2:AppendCallback(function()
		
		end)
		seq2:AppendInterval(0.1)
		seq2:AppendCallback(function()
			jcClearUI.fxjj.gameObject:SetActive(true)
		end)

		seq2:AppendInterval(0.4)
		seq2:AppendCallback(function()
			jcClearUI.cheng.gameObject:SetActive(true)
		end)

		seq2:AppendInterval(0.2)
		seq2:AppendCallback(function()
			jcClearUI.dxtr.gameObject:SetActive(true)
		end)

		seq2:AppendInterval(0.5)
		seq2:AppendCallback(function()
			jcClearUI.jia.gameObject:SetActive(true)
		end)

		seq2:AppendInterval(0.2)
		seq2:AppendCallback(function()
			jcClearUI.xc.gameObject:SetActive(true)
		end)
	end)
	seq:AppendInterval(3.5)
	seq:AppendCallback(function ()
		
	end)
	seq:Append(jcClearUI.root.transform:DOScale(Vector3.New(0.5, 0.5, 0.5), 0.15):SetEase(DG.Tweening.Ease.InQuint))
	seq:AppendCallback(function ()
		jcClear.gameObject:SetActive(false)
		destroy(jcClear.gameObject)
	end)
end

function M.ShowFxjj(parent, num)
	local isHaveFxjj = false
	for i = 1, parent.childCount do
		if parent:GetChild(i - 1).name == "EliminateFXJJ" then
			isHaveFxjj = true
		end
	end
	if isHaveFxjj then
		return
	end
	local fxjjPanel = newObject("EliminateFXJJ", parent)
	local fxjjNumTxt = fxjjPanel.transform:Find("NumTxt"):GetComponent("Text")
	fxjjPanel.transform.localPosition = Vector3.New(0, 350, 0)
	fxjjNumTxt.text = num
end

function M.FxjjNumRefresh(fxjjPanel, fxjjNumTxt, num)
	local newNum = num
	local oldNum = tonumber(fxjjNumTxt.text)
	local curNum = oldNum
	local time = 0.5
	local dt = 0.02
	local dNum = (newNum - oldNum) / (time / dt)
	local dFunction = function()
		fxjjNumTxt.text =  math.floor(curNum)
	end

	if M.fxjjAddTimer then
		M.fxjjAddTimer:Stop()
		M.fxjjAddTimer = nil
	end

	M.fxjjAddTimer = Timer.New(function()
		curNum = curNum + dNum
		if curNum >= newNum * 0.95 then
			curNum = newNum
			dFunction()
			M.fxjjAddTimer:Stop()
			M.fxjjAddTimer = nil
		else
			dFunction()
		end
	end, dt, -1)
	M.fxjjAddTimer:Start()
end

function M.RefreshScore(numTxt, isNeedScaleAnim)
	local txt = numTxt.text
	local len = #txt
	local baseScale = 1
	if len > 3 then
		baseScale = 1 - (len - 3) * 0.1
	end
	if isNeedScaleAnim then
		local seq = DoTweenSequence.Create()
		seq:Append(numTxt.transform:DOScale(Vector3.New(baseScale * 1.2, baseScale * 1.2, baseScale * 1.2), 0.12))
		seq:Append(numTxt.transform:DOScale(Vector3.New(baseScale, baseScale, baseScale), 0.12))
		seq:AppendCallback(function()
			if seq then
				seq:Kill()
			end
		end)
	else
		numTxt.transform.localScale = Vector3.New(baseScale, baseScale, baseScale)
	end
end