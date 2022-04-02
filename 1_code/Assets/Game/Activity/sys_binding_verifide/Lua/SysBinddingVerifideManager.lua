-- 创建时间:2019-10-24
local basefunc = require "Game/Common/basefunc"
SysBinddingVerifideManager = {}
local M = SysBinddingVerifideManager
M.key = "sys_binding_verifide"
GameButtonManager.ExtLoadLua(M.key, "VerifidePanel")
local lister
M.status_code = {
    [0] = "未认证",  
    [1] = "未认证",  
    [2] = "认证中",  
    [3] = "认证失败",  
    [4] = "认证成功",  
}

local award_key = "authentication_award"
if AppDefine.IsEDITOR() then
    GameGlobalOnOff.ForceVerifide = false
else
    GameGlobalOnOff.ForceVerifide = true
end

if GameGlobalOnOff.ForceVerifide then
    TIPS_ASSET_CHANGE_TYPE[award_key] = nil -- 正常弹出奖励
else
    TIPS_ASSET_CHANGE_TYPE[award_key] = award_key -- 拦截奖励表现 on_AssetChange实现新效果
end

function M.CheckIsShow()
    return true
end
function M.GotoUI(parm)
    if parm.goto_scene_parm == "panel" then
        return VerifidePanel.Create(parm.backcall)
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
    lister["OnLoginResponse"] = M.OnLoginResponse
    lister["ReConnecteServerSucceed"] = M.OnReConnecteServerSucceed
    lister["global_hint_state_set_msg"] = M.on_global_hint_state_set_msg

    lister["AssetChange"] = M.on_AssetChange
    lister["global_game_panel_open_msg"] = M.on_global_game_panel_open_msg
end

function M.Init()
	M.Exit()
	M.m_data = {}
	MakeLister()
    AddLister()
	M.InitUIConfig()
end
function M.Exit()
	if M then
		RemoveLister()
		M.m_data = nil
	end
end
function M.InitUIConfig()
end

function M.OnLoginResponse(result)
	if result == 0 then
        MainModel.GetVerifyStatus()
	end
end
function M.OnReConnecteServerSucceed()
    MainModel.GetVerifyStatus()
end

-- 是否实名认证
function M.IsVerify()
    if MainModel.UserInfo 
        and MainModel.UserInfo.verifyData 
        and (MainModel.UserInfo.verifyData.status == 2 or MainModel.UserInfo.verifyData.status == 4) then
        return true
    end
    return false
end

function M.on_AssetChange(data)
    if data and data.change_type and data.change_type == award_key then
        dump(data,"<color>SM  on_AssetChange++++++++++++++++++</color>")
        local ll = AwardManager.GetAwardList(data.data)
        if #ll > 0 then
            local ss = ""
            for k,v in ipairs(ll) do
                ss = ss .. "  " .. v.desc
            end
            LittleTips.Create(ss, nil, {layerOrder=200})
        end
    end
end

function M.on_global_game_panel_open_msg(data)
    if data and data.ui == "GMPanel" then
        GameGlobalOnOff.ForceVerifide = false
        TIPS_ASSET_CHANGE_TYPE[award_key] = award_key
        MainModel.UserInfo.verifyData = {status = 4 }
        Event.Brocast("exit_verifide_panel_msg")
    end
end