-- 创建时间:2020-09-28
-- JjcyXxlbdManger 管理器
local basefunc = require "Game/Common/basefunc"
Act_043_LWDRManager = {}
local M = Act_043_LWDRManager
M.key = "act_043_lwdr"
GameButtonManager.ExtLoadLua(M.key, "Act_043_LWDRPanel")

local this
local lister
local  notice_timer
local  btn_gameObject
local  notice_prefab

local awd_cfg = {
    1000, 300, 100, 30, 30, 30, 20, 20, 20, 20, 10, 10, 10, 10, 10, 5, 5, 5, 5, 5
}

local HGList = {
    [1] = "localpop_icon_1",
    [2] = "localpop_icon_2",
    [3] = "localpop_icon_3",
}

M.help_info = {
    "-----",
    "-----",

}

local user_data = {}
local rank_data = {}
local _rank_type = "sdkl_043_lwdr_rank"

-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    local s_time --= 1607988600
    local e_time---= 1608566399
    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
        return false
    end

    -- 对应权限的key
    local _permission_key
    if _permission_key then
        local a, b = GameButtonManager.RunFun({ gotoui = "sys_qx", _permission_key = _permission_key, is_on_hint = true }, "CheckCondition")
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
        if M.CheckIsShow() then
            return Act_043_LWDRPanel.Create(parm.parent, parm.backcall)
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
-- 更新活动的提示状态(针对那种 打开界面就需要修改状态的需求)
function M.SetHintState()
    Event.Brocast("global_hint_state_change_msg", { gotoui = M.key })
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
    lister["OnLoginResponse"] = this.OnLoginResponse
    lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed
    lister["global_hint_state_set_msg"] = this.on_global_hint_state_set_msg
    lister["query_rank_base_info_response"] = this.query_rank_base_info_response
    lister["query_rank_data_response"] = this.query_rank_data_response
    lister["year_btn_created"] = this.on_year_btn_created
end

function M.Init()
    M.Exit()

    this = Act_043_LWDRManager
    this.m_data = {}
    this.m_data.mydata = {}

    MakeLister()
    AddLister()

    M.GetBaseDataFromNet()
    M.GetRankDataFromNet()
    M.InitUIConfig()
end

function M.ReInit()
    M.GetBaseDataFromNet()
    M.GetRankDataFromNet()
    this.UIConfig = {}
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
        M.ReInit()
    end
end

function M.OnReConnecteServerSucceed()
    M.ReInit()
end

function M.InitRankData(_data)
    rank_data = {}
    if table_is_null(_data.rank_data) then
        return
    end
    for i = 1, #_data.rank_data do
        local lis_prop = {}
        lis_prop["name"] = _data.rank_data[i].name or ""
        if _data.rank_data[i].rank then
            lis_prop["ranking_num"] = _data.rank_data[i].rank
        else
            lis_prop["ranking_num"] = -1
        end
        lis_prop["rank_score"] = _data.rank_data[i].score
        lis_prop["rank_award"] = awd_cfg[_data.rank_data[i].rank]
        lis_prop["player_id"]=_data.rank_data[i].player_id
        rank_data[i] = lis_prop
        lis_prop = {}
    end
end

---name:名字，ranking_num：排名，rank_game：所属游戏
---rank_mult：倍数，rank_award：奖励
function M.InitUserData(_data)
    if _data.result ~= 0 then return end
    user_data["name"] = MainModel.UserInfo.name
    if _data.rank then
        user_data["ranking_num"] = _data.rank
    else
        user_data["ranking_num"] = -1
    end
    --user_data["ranking_num"] = _data.rank
    local json_data = json2lua(_data.other_data)
    if json_data then
        user_data["rank_game"] = json_data.source_type
    end
    user_data["rank_score"] = _data.score
    user_data["rank_award"] = awd_cfg[_data.rank]
end


function M.GetBaseDataFromNet()
    Network.SendRequest("query_rank_base_info", { rank_type = _rank_type })
end

function M.GetRankDataFromNet()
    --第1页
    Network.SendRequest("query_rank_data", { page_index = 1, rank_type = _rank_type })
end

function M.GetRankData()
    return rank_data
end

function M.GetUserRankData()
    return user_data
end

function M.GetHGList(hg_num)
    return HGList[hg_num]
end

--------------response------------
function M.query_rank_base_info_response(_, data)
    dump(data, "<color=red><size=14>礼物达人rank_base_info-----</size></color>")
    if data and data.result == 0 then
        this.m_data.mydata[data.rank_type] = data
        M.InitUserData(data)
        Event.Brocast(M.key.."_rank_base_info_get",{rank_type = data.rank_type})
    end
end

function M.query_rank_data_response(_, data)
    -- body
    dump(data, "<color=red><size=14>礼物达人rank_data-------</size></color>")
    if data and data.result == 0 then
        M.InitRankData(data)
        Event.Brocast(M.key.."_rank_info_get",{rank_type = data.rank_type})
    end
end

function M.on_year_btn_created(data)
    if data and data.enterSelf then
        btn_gameObject = data.enterSelf.gameObject
        notice_prefab = newObject("Act_043_LWDRPrefab", btn_gameObject.transform)
        notice_prefab.transform.localPosition = Vector2.New(126.4, 4)
        notice_prefab.gameObject:SetActive(false)
        CommonHuxiAnim.Start(notice_prefab, 1)
        M.StopNoticeTime()
        M.ShowNoticePrefab()
    end
end

function M.ShowNoticePrefab()

    if M.GetBestRank() > 20 or M.GetBestRank() < 2 then
        return
    end
    if MainModel.myLocation == "game_Hall"
    -- or MainModel.myLocation == "game_Eliminate"
    -- or MainModel.myLocation == "game_EliminateSH"
    -- or MainModel.myLocation == "game_EliminateCS" 
    or MainModel.myLocation == "game_Fishing" then--每次返回大厅时提示一次
        if btn_gameObject and IsEquals(btn_gameObject) and IsEquals(notice_prefab) then
            notice_prefab.gameObject:SetActive(true)
            Timer.New(
            function()
                if IsEquals(notice_prefab) then
                    notice_prefab.gameObject:SetActive(false)
                end
            end
            , 4, 1):Start()
        end
    end
    if MainModel.myLocation == "game_Hall"
    -- or MainModel.myLocation == "game_Eliminate"
    -- or MainModel.myLocation == "game_EliminateSH"
    -- or MainModel.myLocation == "game_EliminateCS" 
    or MainModel.myLocation == "game_Fishing" then
        M.StopNoticeTime()
        if btn_gameObject and IsEquals(btn_gameObject) and IsEquals(notice_prefab) then
            local time_index = 0
            local space = 60
            local show_time = 4
            notice_timer = Timer.New(
            function()
                if IsEquals(notice_prefab) then
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
            , 1, -1)
            notice_timer:Start()
        end
    end

end
function M.StopNoticeTime()
    if notice_timer then
        notice_timer:Stop()
        notice_timer=nil
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