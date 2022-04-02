-- 创建时间:2020-01-14
-- 实名认证系统管理器

local basefunc = require "Game/Common/basefunc"
SYSSMRZManager = {}
local M = SYSSMRZManager
M.key = "sys_smrz"
GameButtonManager.ExtLoadLua(M.key, "SYSSMRZ_JYFLEnterPrefab")
--GameButtonManager.ExtLoadLua(M.key, "SignInPanel")
--local signIn_cfg = GameButtonManager.ExtLoadLua(M.key, "signIn_cfg")

local this
local lister

function M.CheckIsShow()
    return true
end
function M.GotoUI(parm)
    if parm.goto_scene_parm == "panel" then
    	if M.CheakPerMiss() then
             return GameManager.GotoUI({gotoui = "sys_binding_verifide",goto_scene_parm = "panel"})
        end
    elseif parm.goto_scene_parm == "jyfl_enter" then
	if M.CheakPerMiss() then
    		return SYSSMRZ_JYFLEnterPrefab.Create(parm.parent, parm.cfg)
        end
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end
-- 活动的提示状态
function M.GetHintState(parm)
	-- if this.m_data then
	-- 	if not table_is_null(this.m_data.acc_award) or this.m_data.sign_in_award == 1 then
	-- 		return ACTIVITY_HINT_STATUS_ENUM.AT_Get
	-- 	else
	-- 		return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
	-- 	end
	-- end
    -- return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
    if MainModel.UserInfo.verifyData and MainModel.UserInfo.verifyData.status 
        and MainModel.UserInfo.verifyData.status == 0 then
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

    lister["MainModelUpdateVerify"] = this.UpdateVerifide
end

function M.Init()
	M.Exit()

	this = SYSSMRZManager
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
    -- this.UIConfig={
    --     config = {},
    -- }
    -- this.UIConfig.config = signIn_cfg
end

function M.OnLoginResponse(result)
	-- if result == 0 then
	-- 	Network.SendRequest("query_sign_in_data")
	-- end
end
function M.OnReConnecteServerSucceed()
end

function M.UpdateVerifide()
	print("SYSSMRZManager UpdateVerifide")
	Event.Brocast("global_hint_state_change_msg", {gotoui=M.key})
end

function M.CheakPerMiss()
    local _permission_key = "drt_block_real_name_verify"
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