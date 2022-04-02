-- 创建时间:2019-10-15
-- 幸运抽奖管理器
-- 可以存放活动数据，配置，还有广播数据改变的消息

local basefunc = require "Game/Common/basefunc"
XYCJActivityManager = {}
local M = XYCJActivityManager
M.key = "xycj"
GameButtonManager.ExtLoadLua(M.key, "XYCJEnterPrefab")
GameButtonManager.ExtLoadLua(M.key, "GameActivityXXCJPanel")
GameButtonManager.ExtLoadLua(M.key, "HBDZPPrefab")
GameButtonManager.ExtLoadLua(M.key, "ActivityXXCJPrefab")
GameButtonManager.ExtLoadLua(M.key, "AssetsGet10Panel")


local this
local lister
local m_data

function M.CheckIsShow()
    return true
end
function M.GotoUI(parm)
    if parm.goto_scene_parm == "panel" then
        return GameActivityXXCJPanel.Create({type=parm.data})
    elseif parm.goto_scene_parm == "enter" then
    	return XYCJEnterPrefab.Create(parm.parent, parm.cfg)
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end
function M.CheckActivityState(parm)
	
end
-- 活动的提示状态
function M.GetHintState(parm)
	local newtime = tonumber(os.date("%Y%m%d", os.time()))
    local oldtime = tonumber(os.date("%Y%m%d", tonumber(PlayerPrefs.GetString("HallXYCJHintTime" .. MainModel.UserInfo.user_id, 0))))
	if MainModel.UserInfo.jing_bi >= 1000000 and  oldtime ~= newtime then
		return ACTIVITY_HINT_STATUS_ENUM.AT_Red
	end
	return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
end
function M.on_global_hint_state_set_msg(parm)
	if parm.gotoui == M.key then
		M.SetHintState()
	end
end

function M.model_vip_upgrade_change_msg(vip_data)
	M.UpdateData()
end

function M.SetHintState()
	PlayerPrefs.SetString("HallXYCJHintTime" .. MainModel.UserInfo.user_id, os.time())
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
    lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed
    lister["global_hint_state_set_msg"] = this.on_global_hint_state_set_msg
    lister["model_vip_upgrade_change_msg"] = this.model_vip_upgrade_change_msg

    lister["query_luck_lottery_data_response"] = this.on_query_luck_lottery_data
end

function M.Init()
	M.Exit()

	this = XYCJActivityManager
	this.m_data = {}
	-- 这个逻辑上线时间
	this.sxsj = 1581982200
	MakeLister()
    AddLister()
end
function M.Exit()
	if this then
		RemoveLister()
		this = nil
	end
end
-- 数据更新
function M.UpdateData()
	print("<color=white>请求幸运抽奖数据</color>")
	Network.RandomDelayedSendRequest("query_luck_lottery_data")
end

function M.OnLoginResponse(result)
	if result == 0 then
		M.UpdateData()
	end
end
function M.OnReConnecteServerSucceed()
end

function M.on_query_luck_lottery_data(_, data)
	-- dump(data, "<color=red>on_query_luck_lottery_data</color>")
	if data.result == 0 then
		this.m_data.get_num = data.num
		this.m_data.ptcj_num = data.ptcj_num or 0
		Event.Brocast("model_query_luck_lottery_data")
	end
end


