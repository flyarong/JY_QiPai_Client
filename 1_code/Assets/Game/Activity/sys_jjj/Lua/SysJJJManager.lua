local basefunc = require "Game/Common/basefunc"
SysJJJManager = {}
local M = SysJJJManager
M.key = "sys_jjj" -- 救济金
GameButtonManager.ExtLoadLua(M.key, "SYSJJJ_JYFLEnterPrefab")
local lister
function M.CheckIsShow()
    return true
end

function M.GotoUI(parm)
	if parm.goto_scene_parm == "jyfl_enter" then 
        return SYSJJJ_JYFLEnterPrefab.Create(parm.parent)
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end

local function AddLister()
    for msg, cbk in pairs(lister) do
        Event.AddListener(msg, cbk)
    end
end

local function RemoveLister()
    if lister then
        for msg, cbk in pairs(lister) do
            Event.RemoveListener(msg, cbk)
        end
    end
    lister = nil
end
local function MakeLister()
    lister = {}
    lister["Ext_OnLoginResponse"] = M.OnLoginResponse
    lister["ReConnecteServerResponse"] = M.SentQ
    lister["AssetChange"] =  M.RefreshJYFLEnter
    lister["free_broke_subsidy_response"] =  M.RefreshJYFLEnter
    lister["share_count_change_msg"] = M.RefreshJYFLEnter
    lister["query_broke_subsidy_num_response"] = M.on_query_broke_subsidy_num_response
    lister["query_free_broke_subsidy_num_response"] = M.on_query_free_broke_subsidy_num_response
end

function M.Init()
    M.Exit()
    m_data = {}
    MakeLister()
    AddLister()
end

function M.Exit()
    if M then
        RemoveLister()
    end
end

function M.SentQ()
    Network.SendRequest("query_broke_subsidy_num")
    Network.SendRequest("query_free_broke_subsidy_num")
end

function M.GetHintState(parm)
    if M.CheakNumAndJB() then 
        return ACTIVITY_HINT_STATUS_ENUM.AT_Get
    else
        return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
    end
end

function M.RefreshJYFLEnter() 
    Event.Brocast("global_hint_state_change_msg", {gotoui = M.key})
end

function M.CheakNumAndJB()
    if (not MainModel.UserInfo.shareCount or MainModel.UserInfo.shareCount <= 0) and (not MainModel.UserInfo.freeSubsidyNum or MainModel.UserInfo.freeSubsidyNum <= 0) 
	or MainModel.UserInfo.jing_bi >= 3000 then 
		return false
	else
		return true
	end 
end

function M.on_query_broke_subsidy_num_response(_,data)
    dump(data,"<color=red>分享救济金数据</color>")
    MainModel.UserInfo.shareCount = data.num or 0
    MainModel.UserInfo.shareAllNum = data.all_num or 0
    M.RefreshJYFLEnter()
end

function M.on_query_free_broke_subsidy_num_response(_,data)
    dump(data,"<color=red>免费救济金数据</color>")
    MainModel.UserInfo.freeSubsidyNum = data.num or 0
    MainModel.UserInfo.freeSubsidyAllNum = data.all_num or 0
    M.RefreshJYFLEnter()
end

function M.OnLoginResponse()
    M.SentQ()
end