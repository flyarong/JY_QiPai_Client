-- 创建时间:2019-10-24
-- 通用礼包管理器

local basefunc = require "Game/Common/basefunc"
Act_025_ZBLBManager = {}
local M = Act_025_ZBLBManager
M.key = "act_025_zblb"
M.config = GameButtonManager.ExtLoadLua(M.key, "act_025_zblb_config").config
GameButtonManager.ExtLoadLua(M.key, "Act_025_ZBLBEnterPrefab")
local this
local lister
local permiss = {
    "actp_buy_gift_bag_class_024_zblb_nor",
    "actp_buy_gift_bag_class_024_zblb_v1",
    "actp_buy_gift_bag_class_024_zblb_v4",
    "actp_buy_gift_bag_class_024_zblb_v8",
}

function M.IsActive()
    -- 活动的开始与结束时间
    local e_time
    local s_time
    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
        return false
    end

    -- 对应权限的key
   local cheak_func = function (_permission_key)
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=_permission_key, is_on_hint = true}, "CheckCondition")
        if a and not b then
            return false
        end
        return true
   end
   M.level = 0
   for i = 1,#permiss do
        if cheak_func(permiss[i]) then
            M.level = i
        end
   end
   return M.level ~= 0
end
-- 创建入口按钮时调用
function M.CheckIsShow()
    return M.IsActive()
end

function M.GotoUI(parm)
    if parm.goto_scene_parm == "enter" then
        if parm.parent.parent.gameObject.name == "ActivityYearPanel" then
            local b =  Act_025_ZBLBEnterPrefab.Create(parm.parent)
            CommonHuxiAnim.Start(b.gameObject,1.2,1.2,1.4)
            return  b
        else
            return Act_025_ZBLBEnterPrefab.Create(parm.parent)
        end
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
    lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed
    lister["global_hint_state_set_msg"] = this.on_global_hint_state_set_msg
end

function M.Init()
	M.Exit()

	this = Act_025_ZBLBManager
	this.m_data = {}
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
   
end

function M.OnLoginResponse(result)
	if result == 0 then
	end
end

function M.OnReConnecteServerSucceed()

end
