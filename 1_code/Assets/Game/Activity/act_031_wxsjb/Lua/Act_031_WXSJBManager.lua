-- 创建时间:2020-05-25
-- Act_031_WXSJBManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_031_WXSJBManager = {}
local M = Act_031_WXSJBManager
M.key = "act_031_wxsjb"
GameButtonManager.ExtLoadLua(M.key, "Act_031_WXSJBPanel")

local this
local lister
local notice_timer

M.base_types = {
    "happy_guoqing_aster_rank",
}
M.rank_names = {
    "五星收集排行榜"
}
-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    local e_time --= 1594655999
    local s_time --= 1594078200
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
            return Act_031_WXSJBPanel.Create(parm.parent)
        end
    elseif parm.goto_scene_parm == "enter" then
      
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
    lister["OnLoginResponse"] = this.OnLoginResponse
    lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed
    lister["global_hint_state_set_msg"] = this.on_global_hint_state_set_msg

    lister["EnterScene"] = M.EnterScene
    lister["ExitScene"] = M.ExitScene
    lister["year_btn_created"] = this.on_year_btn_created
    lister["query_rank_base_info_response"] = this.query_rank_base_info_response
end

function M.Init()
	M.Exit()

	this = Act_031_WXSJBManager
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
    M.ShowNoticePrefab()
end
function M.ExitScene()
    M.StopNoticeTime()
end

function M.StopNoticeTime()
    if notice_timer then
        notice_timer:Stop()
        notice_timer = nil
    end
end


function M.ShowNoticePrefab()
    if M.GetBestRank() >20 or M.GetBestRank() < 2 then
        return
    end
    if MainModel.myLocation == "game_Hall" then--每次返回大厅时提示一次
        if btn_gameObject and IsEquals(btn_gameObject) and IsEquals(notice_prefab) then
            notice_prefab.gameObject:SetActive(true)
            Timer.New(
                function()
                    if IsEquals(notice_prefab) then
                        notice_prefab.gameObject:SetActive(false)
                    end
                end 
            ,3,1):Start()
        end
    end
    if MainModel.myLocation == "game_Eliminate" or MainModel.myLocation == "game_EliminateSH" or MainModel.myLocation == "game_EliminateCS" or MainModel.myLocation == "game_EliminateXY" then
        M.StopNoticeTime()
        if btn_gameObject and IsEquals(btn_gameObject) and IsEquals(notice_prefab) then
            local time_index = 0
            local space = 60
            local show_time = 3
            notice_timer = Timer.New(
                function ()
                    if  IsEquals(notice_prefab) then
                        time_index = time_index + 1
                        if time_index == space then
                            notice_prefab.gameObject:SetActive(true)
                        end
                        if time_index == show_time + space then
                            notice_prefab.gameObject:SetActive(false)
                            time_index = 0
                        end
                    end
                end
            ,1,-1)
            notice_timer:Start()
        end
    end
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

function M.query_rank_base_info_response(_,data)
    dump(data,"<color=green><size=30>我的排行榜数据-----</size></color>")
    if data and data.result == 0 then
        this.m_data.mydata[data.rank_type] = data
        Event.Brocast("act_025_xxlbd_base_info_get",{rank_type = data.rank_type})
    end
end

function M.QueryMyData(rank_type)
    dump(rank_type,"<color>+++++++++++++++++++++++++++</color>")
    Network.SendRequest("query_rank_base_info",{rank_type = rank_type})
end

function M.GetRankData(rank_type)
    return this.m_data.mydata[rank_type]
end

function M.on_year_btn_created(data)
    if data and data.enterSelf then
        btn_gameObject = data.enterSelf.gameObject
        notice_prefab = newObject("Act_031_WXSJBPrefab",btn_gameObject.transform)
        notice_prefab.transform.localPosition = Vector2.New(126.4,4)
        notice_prefab.gameObject:SetActive(false)
        CommonHuxiAnim.Start(notice_prefab,1)
        M.StopNoticeTime()
        M.ShowNoticePrefab()
    end
end
