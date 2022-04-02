-- 创建时间:2019-11-11
XXLXRHBManager = {}
local M = XXLXRHBManager
M.key = "xxl_xrhb"
GameButtonManager.ExtLoadLua(M.key, "XXLXRHBPanel")
GameButtonManager.ExtLoadLua(M.key, "XXLXRHB_JYFLEnterPrefab")
GameButtonManager.ExtLoadLua(M.key, "XXLXRHBEnterPrefab")

local this
local lister
local m_data
M.task_id = 81
M.task_id2 = 82
-- 是否有活动
function M.IsActive()
    local _permission_key = "drt_block_xxl_hongbao_task" -- 屏蔽消消乐福卡任务
    if _permission_key then
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=_permission_key, is_on_hint = true}, "CheckCondition")
        if a and b then
            return false
        end
	end

	local _permission_key = "drt_block_new_player_xiaoxiaole_task" --水果消消乐新人红包任务
    if _permission_key then
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=_permission_key, is_on_hint = true}, "CheckCondition")
        if a and b then
            return
        end
    end

	return true
end
function M.CheckIsShow()
	if not M.IsActive() then return end
	if not M.GetJYFLShowId() then return end
	if M.CheckTaskIsOver() then return end
    return true
end
function M.GotoUI(parm)
	if not M.IsActive() then
		return
	end
    if parm.goto_scene_parm == "panel" then
		return XXLXRHBPanel.Create()
	elseif parm.goto_scene_parm == "enter" then
		if M.CheckTaskIsRunning() or not M.CheckTaskIsHas() then
			return XXLXRHBEnterPrefab.Create(parm.parent)
		end
	elseif parm.goto_scene_parm == "jyfl_enter" then
		return XXLXRHB_JYFLEnterPrefab.Create(parm.parent, parm)
	elseif parm.goto_scene_parm == "check_is_run" then
		return M.CheckIsRun()
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
	lister["model_task_change_msg"] = this.on_task_change_msg

    lister["eliminate_refresh_end"] = this.on_eliminate_refresh_end
end

function M.Init()
	M.Exit()

	this = XXLXRHBManager
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
    cfg[#cfg + 1] = {task_id = M.task_id, red_val=10}
    cfg[#cfg + 1] = {task_id = M.task_id2, red_val=10}
    this.UIConfig.cfg_task_id_map = {}
    this.UIConfig.cfg_list = cfg
    for k,v in ipairs(cfg) do
    	this.UIConfig.cfg_task_id_map[v.task_id] = v
    end
end

function M.OnLoginResponse(result)
	if result == 0 then
		local msg_list = {}
		msg_list[#msg_list + 1] = {msg="query_one_task_data", data = {task_id = M.task_id}}
		msg_list[#msg_list + 1] = {msg="query_one_task_data", data = {task_id = M.task_id2}}
		GameManager.SendMsgList("xxl_xrhb", msg_list)
	end
end

function M.OnExitScene()
	
end

function M.OnEnterScene()
	
end

function M.on_task_change_msg(data)
	if this.UIConfig.cfg_task_id_map[data.id] then
		dump(data,"<color=white>消消乐福卡任务改变</color>")
		if m_data.task_map then
			m_data.task_map[data.id] = data
		end
	end
end

function M.on_query_one_task_data(_, data)
	if data.task_data and data.task_data.id and this.UIConfig.cfg_task_id_map[data.task_data.id] then
		dump(data, "<color=green>xxl_xrhb on_query_one_task_data</color>")
		if not m_data then
			m_data = {}
		end
		if not m_data.task_map then
			m_data.task_map = {}
		end
	    GameTaskModel.task_process_int_convent_string(data.task_data)
		if data.result == 0 and data.task_data and next(data.task_data) then
			m_data.task_map[data.task_data.id] = data.task_data
		end
	end
end

function M.on_query_send_list_fishing_msg(tag)
	if not (tag == "xxl_xrhb" or tag == "game_xxl_xrhb") then return end
	print(tag)
	dump(m_data, "<color=green>on_query_send_list_fishing_msg</color>")
	if tag == "xxl_xrhb" then
	    Event.Brocast("model_xxl_xrhb_jyfl_msg")
	elseif tag == "game_xxl_xrhb" then
		for i,v in ipairs(this.UIConfig.cfg_list) do
			local task_id = v.task_id
			if M.is_show(M.GetTaskData(task_id)) then
				XXLXRHBPanel.Create(nil, task_id)
				return
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
	local msg_list = {}
	for i,v in ipairs(this.UIConfig.cfg_list) do
		msg_list[#msg_list + 1] = { msg="query_one_task_data", data = {task_id = v.task_id} }
	end
	GameManager.SendMsgList("game_xxl_xrhb", msg_list)
end

--断线重连完成
function M.on_eliminate_refresh_end()
	local cs = MainLogic.GetCurSceneName()
	if cs ~= "game_Eliminate" then return end
	print("<color=white>消消乐新人福卡刷新</color>")
	M.check_new_player_red()
end

function M.GetTaskData(id)
	if m_data and m_data.task_map then
		return m_data.task_map[id]
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

function M.CheckIsRun()
	for i,v in ipairs(M.UIConfig.cfg_list) do
		local tash_data = M.GetTaskData(v.task_id)
		if tash_data and M.is_show(tash_data) then
			local desc = ""
			if tash_data.now_process >= tash_data.need_process then
				desc = "当前处于消消乐新人福卡中，完成即可领取福卡\n确定要退出吗？"
			else
				local bet = EliminateModel.GetBet()[1] * 5
				local g_num = math.ceil( (tash_data.need_process - tash_data.now_process) / bet )
				desc = "当前押注再消除<color=#F18611FF>" .. StringHelper.ToCash(g_num) .. "次</color>即可领取\n<color=#F18611FF>" ..v.red_val .. "福卡</color>\n确定要退出吗？"
			end
			local pre = HintPanel.Create(5, desc, function ()
				Network.SendRequest("xxl_quit_game")
			end)
			pre:SetButtonText("继续退出", "继续领福卡")
			return true
		end
	end
end

function M.CheckTaskIsRunning()
	for k,v in ipairs(this.UIConfig.cfg_list) do
		if M.is_show(M.GetTaskData(v.task_id)) then
			return true
		end
	end
end

function M.CheckTaskIsHas()
	for k,v in ipairs(this.UIConfig.cfg_list) do
		if not table_is_null(M.GetTaskData(v.task_id)) then
			return true
		end
	end
end

function M.CheckTaskIsOver()
	for k,v in ipairs(this.UIConfig.cfg_list) do
    	local task_data = M.GetTaskData(v.task_id)
    	if task_data and (os.time() >= task_data.over_time or task_data.award_status == 2) then
    		return true
    	end
    end
end