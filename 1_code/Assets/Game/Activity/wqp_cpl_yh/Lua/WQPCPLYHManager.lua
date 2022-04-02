local basefunc = require "Game/Common/basefunc"
WQPCPLYHManager = {}
local M = WQPCPLYHManager
M.key = "wqp_cpl_yh"
GameButtonManager.ExtLoadLua(M.key, "WQPCPLYHPanel")
local this
local lister

-- 是否有活动
function M.IsActive()
    if true then return true end
    -- 活动的开始与结束时间
    local e_time
    local s_time
    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
        return
    end

    local _permission_key
    if _permission_key then
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=_permission_key, is_on_hint = true}, "CheckCondition")
        if not a or not b then
            return
        end
    end

    return true
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
    if parm.goto_scene_parm == "ddz_free_clearing" then
        --2021.9.16 关闭此功能
        do return end
        if not M.CheckIsWQPCPL() then
            return
        end
        local parm = {
            ui = "DdzFreeClearing",
            data = parm.data
        }
        return WQPCPLYHPanel.Create(parm)
    end
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
    lister["OnLoginResponse"] = this.OnLoginResponse
    lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed
    lister["global_hint_state_set_msg"] = this.on_global_hint_state_set_msg
    lister["ddz_free_clearing_set_btn"] = this.ddz_free_clearing_set_btn
end

function M.Init()
	M.Exit()

	this = WQPCPLYHManager
    this.m_data = {}
    M.InitUIConfig()
	MakeLister()
    AddLister()
end
function M.Exit()
	if this then
		RemoveLister()
		this = nil
	end
end
function M.InitUIConfig()
    
end

function M.OnLoginResponse(result)
	if result ~= 0 then return end
    -- 数据初始化
end

function M.OnReConnecteServerSucceed()

end

function M.GetData()
    return GameTaskModel.GetTaskDataByID(M.task_id)
end

function M.CheckIsWQPCPL()
    if gameMgr:getMarketPlatform() == "wqp" and gameMgr:getMarketChannel() ~= "wqp" then
        return true
    end
end

function M.ddz_free_clearing_set_btn(data)
    dump(gameMgr:getMarketPlatform(),"<color=green>-------gameMgr:getMarketPlatform()------</color>")
    dump(gameMgr:getMarketChannel(),"<color=green>-------gameMgr:getMarketChannel()------</color>")
    M.GotoUI({goto_scene_parm = "ddz_free_clearing",data = data})
end