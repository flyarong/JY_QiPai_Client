-- 创建时间:2019-01-03
OperatorActivityLogic = {}
local M = OperatorActivityLogic
local this -- 单例
local model
local m_data
local cur_panel
local panelNameMap=
{
	djhb = "djhb",
	ls = "ls",
	cs = "cs"
}
--不展示活动的游戏ID
local NOT_SHOW_LS_IDs = {1,2,3,4,33,34,35,36,21,22,23,24,25}

local lister
local function AddLister()
    for msg,cbk in pairs(lister) do
        Event.AddListener(msg, cbk)
    end
end

local function RemoveLister()
    if lister then
        for msg,cbk in pairs(lister) do
            Event.RemoveListener(msg, cbk)
        end
    end
    lister=nil
end
local function MakeLister()
    lister = {}
    lister["OnLoginResponse"] = this.OnLoginResponse
    lister["ExitScene"] = this.OnExitScene
    lister["open_operator_activity"] = this.open_operator_activity
	lister["close_operator_activity"] = this.close_operator_activity
	--活动数据刷新
	lister["activity_fg_activity_data_msg"] = this.on_activity_fg_activity_data_msg
	--模式
    lister["activity_fg_all_info"] = this.activity_fg_all_info
	lister["activity_fg_gameover_msg"] = this.activity_fg_gameover_msg
	lister["activity_fg_close_clearing"] = this.activity_fg_close_clearing
	lister["activity_fg_enter_room_msg"] = this.activity_fg_enter_room_msg
	lister["activity_fg_join_msg"] = this.activity_fg_join_msg
	lister["activity_fg_leave_msg"] = this.activity_fg_leave_msg
	lister["activity_fg_ready_msg"] = this.activity_fg_ready_msg
	lister["activity_fg_signup_msg"] = this.activity_fg_signup_msg
	--玩法
	lister["activity_nor_begin_msg"] = this.activity_nor_begin_msg
	lister["activity_nor_fa_pai_msg"] = this.activity_nor_fa_pai_msg
	lister["activity_nor_dizhu_msg"] = this.activity_nor_dizhu_msg
	lister["activity_nor_dizhu_pai_msg"] = this.activity_nor_dizhu_pai_msg
	lister["activity_nor_settlement_msg"] = this.activity_nor_settlement_msg
	lister["activity_nor_dingque_result_msg"] = this.activity_nor_dingque_result_msg
	lister["activity_nor_da_piao_msg"] = this.activity_nor_da_piao_msg
end

function M.Init()
    M.Exit()
    this = M
    MakeLister()
	AddLister()
	if model then
		model.Exit()
	end
	model = OperatorActivityModel.Init()
    return this
end
function M.Exit()
	if this then
		model.Exit()
		model = nil
		RemoveLister()
		this = nil
	end
end

--正常登录成功
function M.OnLoginResponse(result)
    if result==0 then
    	if model then
    		model.Exit()
    	end
    	model = OperatorActivityModel.Init()
    end
end
function M.OnExitScene()
	if cur_panel then
		cur_panel.instance:MyClose()
		cur_panel=nil
	end
end
function M.open_operator_activity(panelName)
	if panelName then
		M.change_panel(panelName)
	end
end

function M.close_operator_activity(panelName)
	if panelName then
		if cur_panel then
			if cur_panel.name == panelName then
				cur_panel.instance:MyClose()
				cur_panel=nil
			end
		end
	end
end

function M.change_panel(panelName)
	if cur_panel then
		if cur_panel.name == panelName then
			cur_panel.instance:MyRefresh()
		else
			cur_panel.instance:MyClose()
			cur_panel=nil
		end
	end
	if not cur_panel then
		if panelName == panelNameMap.djhb then
			cur_panel = {name=panelName, instance=OperatorActivityDJPanel.Create()}
		elseif panelName == panelNameMap.ls then
			cur_panel = {name=panelName, instance=OperatorActivityLSPanel.Create()}
		elseif panelName == panelNameMap.cs then
			cur_panel = {name=panelName, instance=OperatorActivityCSPanel.Create()}
		end
	end
	
end

function M.CloseCurPanel()
	if cur_panel then
		cur_panel.instance:MyClose()
		cur_panel=nil
	end
end

function M.IsShowPanel(name)
	if cur_panel and cur_panel.name == name then
		return true
	else
		return false
	end
end

function M.GetCurPanel()
	if cur_panel then
		return cur_panel.instance
	else
		return nil
	end
end

function M.GetData()
	return m_data
end

--活动数据改变
function M.on_activity_fg_activity_data_msg(data)
	dump(data, "<color=yellow>activity_refresh_data_msg</color>")
	if data then
		if m_data and data.activity_data then
			m_data = data
			M.activity_fg_all_info(m_data)
		end
        Event.Brocast("activity_refresh_data_msg", data)
    end
end

--模式
function M.activity_fg_all_info( data)
	dump(data, "<color=yellow>activity_fg_all_info:</color>")
	if M.IsNotShowID(data.game_id) then
		return
	end
	m_data = data
	if data.activity_data and #data.activity_data > 0 then
		local activity_id = 0
		for _, item in ipairs(data.activity_data) do
			if item.key == "activity_id" then
				activity_id = item.value
				break
			end
		end

		print("<color=green>活动id:</color>",activity_id,M.curActivityId)
		if OperatorActivityModel.IsActivated(m_data.game_id, activity_id) then
			if M.curActivityId and activity_id ~= M.curActivityId then
				M.CloseCurPanel()
			end

			M.curActivityId = activity_id
			if activity_id == ActivityType.DuiJuHongBao then
				this.open_operator_activity(panelNameMap.djhb)
			elseif activity_id == ActivityType.Consecutive_Win then
				this.open_operator_activity(panelNameMap.ls)
			elseif activity_id == ActivityType.TianJiangCaiShen then
				this.open_operator_activity(panelNameMap.cs)
			end
		end
	else
		M.CloseCurPanel()
	end
	Event.Brocast("logic_activity_all_info")
end

function M.activity_fg_gameover_msg()
	print("<color=yellow>activity_fg_gameover_msg</color>")
    Event.Brocast("logic_activity_fg_gameover_msg")
end

function M.activity_fg_close_clearing()
	print("<color=yellow>activity_fg_close_clearing</color>")
	if cur_panel and m_data and M.curActivityId and not OperatorActivityModel.IsActivated(m_data.game_id, M.curActivityId) then
		M.CloseCurPanel()
	else
		Event.Brocast("activity_close_clearing_msg")
	end
end

function M.activity_fg_enter_room_msg()
	print("<color=yellow>activity_fg_enter_room_msg</color>")
    Event.Brocast("logic_activity_fg_enter_room_msg")
end

function M.activity_fg_join_msg()
	print("<color=yellow>activity_fg_join_msg</color>")
    Event.Brocast("logic_activity_fg_join_msg")
end

function M.activity_fg_leave_msg(seat_num)
	print("<color=yellow>activity_fg_leave_msg</color>")
    Event.Brocast("logic_activity_fg_leave_msg",seat_num)
end

--玩法
function M.activity_nor_begin_msg()
	print("<color=yellow>activity_nor_begin_msg</color>")
	if cur_panel and m_data and M.curActivityId and not OperatorActivityModel.IsActivated(m_data.game_id, M.curActivityId) then
		M.CloseCurPanel()
	else
		Event.Brocast("logic_activity_nor_begin_msg")
	end
end

function M.activity_nor_fa_pai_msg()
	print("<color=yellow>activity_nor_fa_pai_msg</color>")
    Event.Brocast("activity_fp_msg")
end

function M.activity_nor_dizhu_msg()
	print("<color=yellow>activity_nor_dizhu_msg</color>")
    Event.Brocast("logic_activity_nor_dizhu_msg")
end

function M.activity_nor_dizhu_pai_msg()
	print("<color=yellow>activity_nor_dizhu_pai_msg</color>")
    Event.Brocast("logic_activity_nor_dizhu_pai_msg")
end

function M.activity_nor_settlement_msg()
	print("<color=yellow>activity_nor_settlement_msg</color>")
    Event.Brocast("logic_activity_nor_settlement_msg")
end

function M.activity_nor_dingque_result_msg()
	print("<color=yellow>activity_nor_dingque_result_msg</color>")
    Event.Brocast("logic_activity_nor_dingque_result_msg")
end

function M.activity_nor_da_piao_msg()
	print("<color=yellow>activity_nor_da_piao_msg</color>")
    Event.Brocast("logic_activity_nor_da_piao_msg")
end

function M.activity_fg_ready_msg()
	print("<color=yellow>activity_fg_ready_msg</color>")
    Event.Brocast("logic_activity_fg_ready_msg")
end

function M.activity_fg_signup_msg()
	print("<color=yellow>activity_fg_signup_msg</color>")
	Event.Brocast("logic_activity_fg_signup_msg")
end

function M.IsHaveAcitvity()
	if m_data and m_data.activity_data and #m_data.activity_data > 0 then
		return true
	end
	return false
end

function M.IsBigUI()
	if cur_panel then
		return cur_panel.instance:IsBigUI()
	end
	return false
end

function M.CanLeaveGameBeforeEnd(showHint, cb)
	if GuideLogic and GuideLogic.IsHaveGuide("free_hall") then
		--新手引导中屏蔽
		if cb then cb() end
		return true
	end
	local ret = true
	if cur_panel and cur_panel.name == panelNameMap.ls and OperatorActivityLSPanel.CanBeAwarded() and OperatorActivityModel.IsActivated(m_data.game_id, ActivityType.Consecutive_Win) then
		-- 需求：匹配场退出时不再弹出挑战提示界面
		-- if showHint then
		-- 	local panel = HintPanel.Create(4, "连胜挑战进行中,退出将清空当前进度！", cb)
		-- 	panel:SetBtnTitle("退  出", "继续挑战")
		-- end
		-- ret = false
	elseif cur_panel and cur_panel.name == panelNameMap.djhb and OperatorActivityModel.IsActivated(m_data.game_id, ActivityType.DuiJuHongBao) then
		local nn = 0
		local canBeAwarded = false
		local haveTimes = false
		if m_data and m_data.activity_data and #m_data.activity_data > 0 then
			local data_map = {}
			for k,v in ipairs(m_data.activity_data) do
				data_map[v.key] = v.value
			end
			nn = data_map["max_process"] - data_map["cur_process"]
			canBeAwarded = (data_map["max_process"] > 0 and data_map["max_process"] == data_map["cur_process"])
			haveTimes = data_map["round"] < data_map["max_round"]
		end

		if showHint and haveTimes then
			if nn > 0 then
				GameExitHintPanel.Create("确认离开吗？", "再胜" .. nn .. "场即可抽奖，高概率获得福卡奖励！", cb)
			elseif canBeAwarded then
				GameExitHintPanel.Create("您有一次抽奖机会", "确认要返回大厅吗？", cb)
			else
				GameExitHintPanel.Create("确认离开吗？", "再胜几场即可抽奖，高概率获得福卡奖励！", cb)
			end
		end
		ret = false or not haveTimes
	elseif cur_panel and cur_panel.name == panelNameMap.cs and OperatorActivityModel.IsActivated(m_data.game_id, ActivityType.TianJiangCaiShen) and M.CheckCS() then
		if showHint then
			local panel = HintPanel.Create(4, "财神已幸运的降临到该局游戏中！\n如果在该局离开将无法获得财神奖励，是否确定离开？", cb)
			panel:SetBtnTitle("确  定", "取  消")
		end
		ret = false
	end

	if ret and cb and type(cb) == "function" then
		cb()
	end
	return ret
end

function M.CheckCS()
	if m_data and m_data.activity_data and #m_data.activity_data > 0 then
		local have_cs = false
		local have_seat = false
		for i,v in ipairs(m_data.activity_data) do
			if v.key == "activity_id" and ActivityType.TianJiangCaiShen == v.value then
				have_cs = true
			end
			if v.key == "cs_seat" and v.value > 0 then
				have_seat = true
			end
		end
		return have_cs and have_seat
	end
	return false
end

function M.CheckCSActivity()
	dump(m_data, "<color=white>CheckCSActivity》》》》》》》》》》</color>")
	if m_data and m_data.activity_data and #m_data.activity_data > 0 then
		for i,v in ipairs(m_data.activity_data) do
			if v.key == "activity_id" and ActivityType.TianJiangCaiShen == v.value then
				return true
			end
		end
	end
	return false
end

function M.GetNotShowID()
	return NOT_SHOW_LS_IDs
end

function M.IsNotShowID(id)
	local is_new = false
	local a,b = GameButtonManager.RunFun({gotoui="act_018_mfcdj",}, "IsNewPlayer")
    if a and not b then
        
	else
		is_new = true
	end
	for i = 1,#NOT_SHOW_LS_IDs do
		if id == NOT_SHOW_LS_IDs[i] and is_new then
			return true
		end
	end
end