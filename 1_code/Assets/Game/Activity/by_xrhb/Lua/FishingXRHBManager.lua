-- 创建时间:2019-11-11
-- 捕鱼新人福卡管理器

FishingXRHBManager = {}
local M = FishingXRHBManager
M.key = "by_xrhb"
GameButtonManager.ExtLoadLua(M.key, "FishingNewPlayerPanel")
GameButtonManager.ExtLoadLua(M.key, "BYXRHB_JYFLEnterPrefab")

local this
local lister
local m_data

-- 捕鱼大厅
local byhall_rect
local byhall_index

-- 是否有活动
function M.IsActive()
    local _permission_key = "drt_block_buyu_hongbao_task" -- 屏蔽捕鱼福卡任务
    if _permission_key then
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=_permission_key, is_on_hint = true}, "CheckCondition")
        if a and b then
            return false
        end
        return true
    else
        return true
    end
end
function M.CheckIsShow()
    return M.IsActive()
end
function M.GotoUI(parm)
	if not M.IsActive() then
		return
	end
    if parm.goto_scene_parm == "panel" then
        return FishingNewPlayerPanel.Create()
    elseif parm.goto_scene_parm == "jyfl_enter" then
        return BYXRHB_JYFLEnterPrefab.Create(parm.parent, parm)
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end
-- 活动的提示状态
function M.GetHintState(parm)
    return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
end
function M.on_global_hint_state_set_msg(parm)
	if parm.gotoui == M.key then
	end
end
function M.SetHintState()
end


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
    lister["EnterScene"] = this.OnEnterScene
    lister["ExitScene"] = this.OnExitScene
    lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed
    lister["global_hint_state_set_msg"] = this.on_global_hint_state_set_msg

    lister["query_send_list_fishing_msg"] = this.on_query_send_list_fishing_msg
    lister["query_one_task_data_response"] = this.on_query_one_task_data
    lister["model_query_task_data_response"] = this.on_model_query_task_data_response
    lister["fishing_guide_finish"] = this.on_fishing_guide_finish
    lister["fishing_ready_finish"] = this.on_fishing_ready_finish
    lister["model_task_change_msg"] = this.on_task_change_msg

    lister["ui_byhall_select_msg"] = this.on_ui_byhall_select_msg
end

function M.Init()
	M.Exit()

	this = FishingXRHBManager
	m_data = {}
    this.activityRedMap = {}
	MakeLister()
    AddLister()
	M.InitUIConfig()
end
function M.Exit()
	if this then
		RemoveLister()
		this = nil
	end
end
function M.InitUIConfig()
    this.UIConfig = {}
    local cfg = {}
    cfg[#cfg + 1] = {game_id = 1, task_id = 68, red_val=10}
    cfg[#cfg + 1] = {game_id = 2, task_id = 76, red_val=50}
    cfg[#cfg + 1] = {game_id = 3, task_id = 77, red_val=200}
    this.UIConfig.cfg_game_id_map = {}
    this.UIConfig.cfg_task_id_map = {}
    this.UIConfig.cfg_list = cfg
    for k,v in ipairs(cfg) do
    	this.UIConfig.cfg_game_id_map[v.game_id] = v
    	this.UIConfig.cfg_task_id_map[v.task_id] = v
    end
end

function M.OnLoginResponse(result)
	if result == 0 then
		--9.14	之后再做处理吧 关闭之后有Bug
		local msg_list = {}
		msg_list[#msg_list + 1] = {msg="query_one_task_data", data = {task_id = 68}}
		msg_list[#msg_list + 1] = {msg="query_one_task_data", data = {task_id = 76}}
		msg_list[#msg_list + 1] = {msg="query_one_task_data", data = {task_id = 77}}
		GameManager.SendMsgList("by_xrhb", msg_list)
	end
end
function M.OnExitScene()
	byhall_rect = {}
	byhall_index = nil
end
function M.OnEnterScene()
	if not M.IsActive() then
		return
	end
	if MainModel.myLocation == "game_FishingHall" then
		local old_obj = GameObject.Find("Canvas/LayerLv1/byxrhb_byhall_hintobj")
		if IsEquals(old_obj) then
			destroy(old_obj)
		end
		byhall_rect = {}
		local parent = GameObject.Find("Canvas/LayerLv1").transform
		local obj = newObject("byxrhb_byhall_hintobj", parent)
		LuaHelper.GeneratingVar(obj.transform, byhall_rect)

		for k,v in ipairs(this.UIConfig.cfg_list) do
			local task_data = M.GetTaskData(v.task_id)
	    	if (not task_data and MainModel.GetNewPlayer() == PLAYER_TYPE.PT_New) or (task_data and os.time() < task_data.over_time and task_data.award_status ~= 2) then
	    		byhall_rect["rect" .. k].gameObject:SetActive(true)
    		else
	    		byhall_rect["rect" .. k].gameObject:SetActive(false)
	    	end
	    end
	    M.on_ui_byhall_select_msg(byhall_index)
	end
end

local function set_ui(obj, b)
	local img1 = obj.transform:Find("byxrhb_hongbao/qipao/qipao"):GetComponent("Image")
	local img2 = obj.transform:Find("byxrhb_hongbao/qipao/Image1"):GetComponent("Image")
	local img3 = obj.transform:Find("byxrhb_hongbao/qipao/hongbao"):GetComponent("Image")
	local txt1 = obj.transform:Find("byxrhb_hongbao/qipao/hongbao/Text"):GetComponent("Text")
	local c = 1
	if b then
		c = 1
	else
		c = 0.7
	end
	img1.color = Color.New(c, c, c, 1)
	img2.color = Color.New(c, c, c, 1)
	img3.color = Color.New(c, c, c, 1)
end
function M.on_ui_byhall_select_msg(i)
	if not i then
		return
	end
	byhall_index = i
	print("<color=red>EEE on_ui_byhall_select_msg</color>")
	if byhall_rect then
		for k = 1, 3 do
			local key = "rect" .. k
			if byhall_rect[key] and IsEquals(byhall_rect[key]) then
				if i == k then
					byhall_rect[key].transform.localScale = Vector3.one
					set_ui(byhall_rect[key], true)
				else
					byhall_rect[key].transform.localScale = Vector3.New(0.8, 0.8, 0.8)
					set_ui(byhall_rect[key], false)
				end
			end
		end
	end
end

function M.on_task_change_msg(data)
	M.HandleTaskData(data)
end

function M.on_query_one_task_data(_, data)
	M.HandleTaskData(data)
end

function M.HandleTaskData(data)
	if data and data.id and this.UIConfig.cfg_task_id_map[data.id] then
		if not m_data then
			m_data = {}
		end
		if not m_data.task_map then
			m_data.task_map = {}
		end
	    GameTaskModel.task_process_int_convent_string(data)
		m_data.task_map[data.id] = data
		M.check_new_player_red()
	end
end

function M.on_model_query_task_data_response()
    local data = GameTaskModel.GetTaskDataByID()
    if data then
        for k,v in pairs(data) do
            M.HandleTaskData(v)
        end
    end
end

function M.on_query_send_list_fishing_msg(tag)
	if not(tag == "by_xrhb" or tag == "game_by_xrhb") then return end
	dump(tag, "<color=red>tag</color>")
	if tag == "by_xrhb" then
	    Event.Brocast("model_by_xrhb_jyfl_msg")
	elseif tag == "game_by_xrhb" then
		if FishingModel and FishingModel.data and FishingModel.data.game_id ~= 4 then
			local game_id = FishingModel.data.game_id
			local task_id = this.UIConfig.cfg_game_id_map[game_id].task_id
			if M.is_show(M.GetTaskData(task_id)) then
				FishingNewPlayerPanel.Create(nil, task_id)
			end
		end
	end
end

function M.is_show(data)
	if not M.IsActive() then
		return
	end
	if data and ((data.now_process >= data.need_process and data.task_round == 1) or
	   (data.task_round == 1 and os.time() < data.over_time)) then
		return true
	end
end
function M.check_new_player_red()
	if not M.IsActive() then
		return
	end
	-- 除开体验场没有福卡任务，其他三个场次都有
	if FishingModel and FishingModel.data and FishingModel.data.game_id ~= 4 then
		local game_id = FishingModel.data.game_id
		local task_id = this.UIConfig.cfg_game_id_map[game_id].task_id
		if not M.GetTaskData(task_id) then 
			local msg_list = {}
			msg_list[#msg_list + 1] = { msg="query_one_task_data", data = {task_id = this.UIConfig.cfg_game_id_map[game_id].task_id} }
			GameManager.SendMsgList("game_by_xrhb", msg_list)
		else
			if M.is_show(M.GetTaskData(task_id)) then
				FishingNewPlayerPanel.Create(nil, task_id)
			end
		end
	end

end
function M.on_fishing_guide_finish()
	if instance then
		instance:MyExit()
	end
	print("<color=red>on_fishing_guide_finish</color>")
	M.check_new_player_red()
end
-- 捕鱼断线重连完成
function M.on_fishing_ready_finish()
	if instance then
		instance:MyExit()
	end
	print("<color=red>on_fishing_ready_finish</color>")
	if not FishingGuideLogic or FishingGuideLogic.IsHaveGuide() then
		print("<color=red>处于新手引导中</color>")
	else
		M.check_new_player_red()
	end
end

function M.GetTaskData(id)
	-- if m_data and m_data.task_map then
	-- 	if id == 68 then -- 去掉捕鱼中浅水湾的10福卡奖励任务
	-- 		if m_data.task_map[id] then
	-- 			return m_data.task_map[id]
	-- 		else
	-- 			local buf = {}
	-- 			buf.now_process = 1
	-- 			buf.need_process = 100
	-- 			buf.task_round = 2
	-- 			buf.award_status = 2
	-- 			buf.over_time = 0
	-- 			return buf
	-- 		end
	-- 	else
	-- 		return m_data.task_map[id]
	-- 	end
	-- end
	-- if id == 68 then -- 去掉捕鱼中浅水湾的10福卡奖励任务
	-- 	local buf = {}
	-- 	buf.now_process = 1
	-- 	buf.need_process = 100
	-- 	buf.task_round = 2
	-- 	buf.award_status = 2
	-- 	buf.over_time = 0
	-- 	return buf
	-- end

	-- 原始逻辑
	if m_data and m_data.task_map then
		return m_data.task_map[id]
	else
		if GameTaskModel.GetTaskDataByID(id) then
			return GameTaskModel.GetTaskDataByID(id)
		end
	end
end
function M.GetTaskDataByGameID(game_id)
	if this.UIConfig.cfg_game_id_map and this.UIConfig.cfg_game_id_map[game_id] then
		return M.GetTaskData(this.UIConfig.cfg_game_id_map[game_id].task_id)
	end
end
function M.GetCfgByGameID(game_id)
	if this.UIConfig.cfg_game_id_map then
		return this.UIConfig.cfg_game_id_map[game_id]
	end
end

function M.GetJYFLShowId()
	if not M.IsActive() then
		return
	end
    for k,v in ipairs(this.UIConfig.cfg_list) do
    	local task_data = M.GetTaskData(v.task_id)
    	if (not task_data and MainModel.GetNewPlayer() == PLAYER_TYPE.PT_New) or (task_data and os.time() < task_data.over_time and task_data.award_status ~= 2) then
    		return v.task_id
    	end
    end
end

