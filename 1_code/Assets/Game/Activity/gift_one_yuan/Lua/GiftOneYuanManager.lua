-- 创建时间:2019-10-24
local basefunc = require "Game/Common/basefunc"
GiftOneYuanManager = {}
local M = GiftOneYuanManager
M.key = "gift_one_yuan"
GameButtonManager.ExtLoadLua(M.key, "OneYuanGift")
GameButtonManager.ExtLoadLua(M.key, "GameShop1YuanPanel")
GameButtonManager.ExtLoadLua(M.key, "GameShop3YuanPanel")
GameButtonManager.ExtLoadLua(M.key, "ReliefGoldPanel")

local lister
function M.CheckIsShow()
    return true
end
function M.GotoUI(parm)
    if parm.goto_scene_parm == "panel" then
        return GameShop1YuanPanel.Create(nil,parm.backcall)
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
    lister["shared_finish_response"] = M.shared_finish_response
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
	end
end
function M.OnReConnecteServerSucceed()
end

function M.shared_finish_response(data)
    dump(data,"<color=green>分享完成</color>")
    if table_is_null(data) or data.result ~= 0 or table_is_null(data.share_cfg) then return end
    if data.share_cfg.key ~= "img_zyj" then return end
    Network.SendRequest("broke_subsidy", nil, "请求数据")
end