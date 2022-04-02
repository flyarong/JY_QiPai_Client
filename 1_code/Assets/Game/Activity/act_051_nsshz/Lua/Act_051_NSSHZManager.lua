local basefunc = require "Game/Common/basefunc"
Act_051_NSSHZManager = {}
local M = Act_051_NSSHZManager
M.key = "act_051_nsshz"
GameButtonManager.ExtLoadLua(M.key, "Act_051_NSSHZPanel")
local this
local lister
local btn_gameObject
local notice_prefab
local notice_timer
local best_rank = 1
M.base_types = {
    "nsj_053_nsshz_rank" 
}
-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    local e_time
    local s_time
    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
        return false
    end

    -- 对应权限的key
    local _permission_key
    if _permission_key then
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=_permission_key, is_on_hint = true}, "CheckCondition")
        if a and not b then
            return false
        end
        return true
    else
        return true
    end
end
-- 创建入口按钮时调用
function M.CheckIsShow()
    return M.IsActive()
end
-- 活动面板调用
function M.CheckIsShowInActivity()
    return M.IsActive()
end

-- 所有可以外部创建的UI
function M.GotoUI(parm)
    if parm.goto_scene_parm == "panel" then
        if M.IsActive() then
            return Act_051_NSSHZPanel.Create(parm.parent)
        end
    end 
    dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
end
-- 活动的提示状态
function M.GetHintState(parm)
	return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
end
function M.on_global_hint_state_set_msg(parm)
	if parm.gotoui == M.key then
		M.SetHintState()
	end
end
-- 更新活动的提示状态(针对那种 打开界面就需要修改状态的需求)
function M.SetHintState()
    Event.Brocast("global_hint_state_change_msg", { gotoui = M.key })
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
    lister["EnterScene"] = M.EnterScene
    lister["OnLoginResponse"] = this.OnLoginResponse
    lister["query_rank_base_info_response"] = this.query_rank_base_info_response
    lister["year_btn_created"] = this.on_year_btn_created
    lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed
    lister["global_hint_state_set_msg"] = this.on_global_hint_state_set_msg
end

function M.Init()
	M.Exit()

	this = Act_051_NSSHZManager
    this.m_data = {}
    this.m_data.mydata = {}
    this.m_data.alldata = {}
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
end

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
        for i = 1,#M.base_types do
            Network.SendRequest("query_rank_base_info",{rank_type = M.base_types[i]})
        end        
	end
end
function M.OnReConnecteServerSucceed()
end

function M.EnterScene()
    if notice_timer then
        notice_timer:Stop()
    end
end

function M.ShowNoticePrefab()
   
end

function M.on_year_btn_created(data)

end

function M.query_rank_base_info_response(_,data)
    if data and data.result == 0 then
        this.m_data.mydata[data.rank_type] = data
        Event.Brocast("act_051_base_info_get",{rank_type = data.rank_type})
    end
end

function M.QueryMyData(rank_type)
    Network.SendRequest("query_rank_base_info",{rank_type = rank_type})
end

function M.GetRankData(rank_type)
    return this.m_data.mydata[rank_type]
end

function M.GetBestRank()
    local best_rank = 100000
    for k,v in pairs(this.m_data.mydata) do
        if v.rank > 0 and v.rank < best_rank then
            best_rank = v.rank
        end
    end
    return best_rank
end

function M.IButton()
    
end