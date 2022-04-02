XRMFJBManager = {}
local M = XRMFJBManager
M.key = "xrmfjb"
GameButtonManager.ExtLoadLua(M.key, "XRMFJB_JYFLEnterPrefab")
local this
local lister
local m_data
function M.CheckIsShow()
    if MainModel.GetNewPlayer() == PLAYER_TYPE.PT_Old then
        return
    end
    return true
end

function M.GotoUI(parm)
	dump(parm, "<color=white>goto parm</color>")
	if parm.goto_scene_parm == "jyfl_enter" then
        return XRMFJB_JYFLEnterPrefab.Create(parm.parent, parm)
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end

-- 活动的提示状态
function M.GetHintState(parm)
	if m_data and m_data.broke_beg_num 
		and m_data.broke_beg_num > 0 
		and MainModel.UserInfo 
		and MainModel.UserInfo.jing_bi 
		and MainModel.UserInfo.jing_bi < 3000 then
		return ACTIVITY_HINT_STATUS_ENUM.AT_Get
	end
    return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
end

function M.on_global_hint_state_set_msg(parm)
	if parm.gotoui == M.key then
		M.SetHintState()
	end
end

function M.SetHintState()
	Event.Brocast("global_hint_state_change_msg", {gotoui=M.key})
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

	lister["broke_beg_response"] = this.broke_beg_response
    lister["query_broke_beg_num_response"] = this.query_broke_beg_num_response
    lister["AssetChange"] = this.AssetChange
    lister["player_new_change_to_old"] = this.player_new_change_to_old
end

function M.Init()
	M.Exit()

	this = XRMFJBManager
	m_data = {}
	MakeLister()
    AddLister()
	M.InitUIConfig()
end

function M.Exit()
	if this then
		RemoveLister()
		this = nil
		m_data = nil
	end
end

function M.InitUIConfig()

end

function M.OnLoginResponse(result)
	if result ~= 0 then return end
	M.query_broke_beg_num()
end

function M.OnExitScene()

end

function M.OnEnterScene()
	
end

function M.broke_beg_response(_, data)
	if data.result ~= 0 then HintPanel.ErrorMsg(data.result) end
	M.query_broke_beg_num()
end

function M.query_broke_beg_num_response(_, data)
	if data.result ~= 0 then HintPanel.ErrorMsg(data.result) end
	m_data.broke_beg_num = data.num
	Event.Brocast("model_query_broke_beg_num")
	Event.Brocast("global_hint_state_change_msg", {gotoui=M.key})
end

function M.get_broke_beg_num()
	if m_data and m_data.broke_beg_num then
		return m_data.broke_beg_num
	end
end

function M.query_broke_beg_num()
	Network.SendRequest("query_broke_beg_num", nil, "发送请求")
end

function M.broke_beg()
	Network.SendRequest("broke_beg", nil, "发送请求")
end

function M.AssetChange()
	Event.Brocast("global_hint_state_change_msg", {gotoui=M.key})
end

function M.player_new_change_to_old()
	Event.Brocast("global_hint_state_change_msg", {gotoui=M.key})
	Event.Brocast("xrmfjb_player_new_change_to_old", {gotoui=M.key})
end