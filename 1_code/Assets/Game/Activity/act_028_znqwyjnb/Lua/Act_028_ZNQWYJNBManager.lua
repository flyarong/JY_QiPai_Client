local basefunc = require "Game/Common/basefunc"
Act_028_ZNQWYJNBManager = {}
local M = Act_028_ZNQWYJNBManager
M.key = "act_028_znqwyjnb"
local config_1 = GameButtonManager.ExtLoadLua(M.key, "act_028_znqwyjnb_config1")
local config_2 = GameButtonManager.ExtLoadLua(M.key, "act_028_znqwyjnb_config2")
local config_3 = GameButtonManager.ExtLoadLua(M.key, "act_028_znqwyjnb_config3")
GameButtonManager.ExtLoadLua(M.key,"Act_028_ZNQWYJNBPanel")
local this
local lister

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
    dump({parm,M.cfg}, "<color=red>我要纪念币</color>")
    if parm.goto_scene_parm == "panel" then
        M.InitUIConfig()
        return ActivityTaskPanel.Create(parm.parent, parm.cfg, nil, M.cfg)
    elseif parm.goto_scene_parm == "Down3DFishing" then
        --下载3D捕鱼
        local url = "https://cwww.game3396.com/downloadBind/downloadHlbyBind.html?platform=normal&market_channel=normal&pageType=normal&category=1"
        UnityEngine.Application.OpenURL(url)
        Network.SendRequest("visit_client_upgrade_act")
	end
    dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
end
-- 活动的提示状态
function M.GetHintState(parm)
    if parm and parm.gotoui == M.key then
        if not M.CheckIsShowInActivity(parm) then
            return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
        end
        if M.IsAwardCanGet() then
            return ACTIVITY_HINT_STATUS_ENUM.AT_Get
        else
            if MainModel and MainModel.UserInfo and MainModel.UserInfo.user_id then
                local newtime = tonumber(os.date("%Y%m%d", os.time()))
                local oldtime = tonumber(os.date("%Y%m%d", tonumber(PlayerPrefs.GetString(M.key .. MainModel.UserInfo.user_id, 0))))
                if oldtime ~= newtime then
                    return ACTIVITY_HINT_STATUS_ENUM.AT_Red
                end
            end
            return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
        end
    end 
end
function M.on_global_hint_state_set_msg(parm)
	if parm.gotoui == M.key then
		M.SetHintState()
	end
end
-- 更新活动的提示状态(针对那种 打开界面就需要修改状态的需求)
function M.SetHintState()
    PlayerPrefs.SetString(M.key .. MainModel.UserInfo.user_id, os.time())
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
    lister["ActivityTaskPanel_Had_Finish"] = M.on_ActivityTaskPanel_Had_Finish
    lister["ActivityTaskPanel_Exit"] = M.ActivityTaskPanel_Exit
    lister["model_query_task_data_response"] = M.Refresh_Status
	lister["model_task_change_msg"] = M.Refresh_Status
end

function M.Init()
	M.Exit()

	this = Act_028_ZNQWYJNBManager
	this.m_data = {}
	MakeLister()
    AddLister()
    M.InitUIConfig()

    MainModel.AddUnShowAssetGet(M.unShowAssetGetType,M.CheckUnShowAssetGet)
    MainModel.AddUnShowAssetGet(M.unShowAssetGetType1,M.CheckUnShowAssetGet1)
    MainModel.AddUnShowAssetGet(M.unShowAssetGetType2,M.CheckUnShowAssetGet2)
    MainModel.AddUnShowAssetGet(M.unShowAssetGetType3,M.CheckUnShowAssetGet3)
end
function M.Exit()
	if this then
		RemoveLister()
		this = nil
    end
    MainModel.DelUnShowAssetGet(M.unShowAssetGetType,M.CheckUnShowAssetGet)
    MainModel.DelUnShowAssetGet(M.unShowAssetGetType1,M.CheckUnShowAssetGet1)
    MainModel.DelUnShowAssetGet(M.unShowAssetGetType2,M.CheckUnShowAssetGet2)
    MainModel.DelUnShowAssetGet(M.unShowAssetGetType3,M.CheckUnShowAssetGet3)
end
function M.InitUIConfig()
    this.UIConfig = {}
    M.cfg = {}
    local _permission_key = "actp_own_task_p_2year_anniversary_celebration_v3"
    if _permission_key then
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=_permission_key, is_on_hint = false}, "CheckCondition")
        if a and b then
            M.cfg = config_1
            M.task_id_reset = 21481
        end
    end
    _permission_key = "actp_own_task_p_2year_anniversary_celebration_v7"
    if _permission_key then
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=_permission_key, is_on_hint = false}, "CheckCondition")
        if a and b then
            M.cfg = config_2
            M.task_id_reset = 21491
        end
    end

    _permission_key = "actp_own_task_p_2year_anniversary_celebration_v12"
    if _permission_key then
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=_permission_key, is_on_hint = false}, "CheckCondition")
        if a and b then
            M.cfg = config_3
            M.task_id_reset = 21501
        end
    end

    -- dump({M.cfg,M.task_id_reset},"<color=green>我要纪念币配置</color>") 
    if table_is_null(M.cfg) then
        M.cfg = config_1
    end
    if not M.task_id_reset then
        M.task_id_reset = 21481
    end

    M.task_id_hash = {}
    for i,v in ipairs(M.cfg.tge1) do
        M.task_id_hash[v.task] = v.task
    end
    Network.SendRequest("query_one_task_data", {task_id = M.task_id_reset})
end

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
	end
end
function M.OnReConnecteServerSucceed()
end

--创建扩展部分
function M.on_ActivityTaskPanel_Had_Finish(data)
	if data and data.key and data.key == M.key then
		Act_028_ZNQWYJNBPanel.Create(data)
        data = nil
	end
end

function M.ActivityTaskPanel_Exit()
    Act_028_ZNQWYJNBPanel.Close()
end

function M.Refresh_Status()
    Event.Brocast("global_hint_state_change_msg",{gotoui = M.key})
end

function M.IsAwardCanGet()
    local d
    for k,v in pairs(M.task_id_hash) do
        d = GameTaskModel.GetTaskDataByID(v)
        if d then 
            if d.award_status == 1 then 
                return true
            end 
        end 
    end
    return false
end

function M.GetFreeResetCount()
    if not M.task_id_reset then return 0 end
    local td = GameTaskModel.GetTaskDataByID(M.task_id_reset)
    if table_is_null(td) then return 0 end
    -- dump(td,"<color=green>我要纪念币重置任务</color>")
    if not td.task_round then return 0 end
    return 4 - td.task_round
end

M.unShowAssetGetType = "task_permission_task"
function M.CheckUnShowAssetGet(change_type,change_assets_get)
    --获取到纪念卡
    if change_type == M.unShowAssetGetType then
        if not table_is_null(change_assets_get) and #change_assets_get == 1 and change_assets_get[1].asset_type == "prop_2year_jinianbi3" then
            local parent = GameObject.Find("SYSACTBASEEnterPrefab_2")
            if not IsEquals(parent) then
                parent = GameObject.Find("@left_top")
            end
            if IsEquals(parent) then
                parent = parent.transform
                GameComAnimToolDownGet.Create(change_assets_get[1].value,parent,"yjlqjnb_icon_jnb")
            end
            return true
        end
    end
end

M.unShowAssetGetType1 = "fish_game_1"
function M.CheckUnShowAssetGet1(change_type,change_assets_get)
    --获取到纪念卡
    if change_type == M.unShowAssetGetType1 then
        if not table_is_null(change_assets_get) and #change_assets_get == 1 and change_assets_get[1].asset_type == "prop_2year_jinianbi3" then
            local parent = GameObject.Find("SYSACTBASEEnterPrefab_2")
            if not IsEquals(parent) then
                parent = GameObject.Find("@ACTNode1")
            end
            if IsEquals(parent) then
                parent = parent.transform
                GameComAnimToolDownGet.Create(change_assets_get[1].value,parent,"yjlqjnb_icon_jnb")
            end
            return true
        end
    end
end

M.unShowAssetGetType2 = "fish_game_2"
function M.CheckUnShowAssetGet2(change_type,change_assets_get)
    --获取到纪念卡
    if change_type == M.unShowAssetGetType2 then
        if not table_is_null(change_assets_get) and #change_assets_get == 1 and change_assets_get[1].asset_type == "prop_2year_jinianbi3" then
            local parent = GameObject.Find("SYSACTBASEEnterPrefab_2")
            if not IsEquals(parent) then
                parent = GameObject.Find("@ACTNode1")
            end
            if IsEquals(parent) then
                parent = parent.transform
                GameComAnimToolDownGet.Create(change_assets_get[1].value,parent,"yjlqjnb_icon_jnb")
            end
            return true
        end
    end
end

M.unShowAssetGetType3 = "fish_game_3"
function M.CheckUnShowAssetGet3(change_type,change_assets_get)
    --获取到纪念卡
    if change_type == M.unShowAssetGetType3 then
        if not table_is_null(change_assets_get) and #change_assets_get == 1 and change_assets_get[1].asset_type == "prop_2year_jinianbi3" then
            local parent = GameButtonManagerbject.Find("SYSACTBASEEnterPrefab_2")
            if not IsEquals(parent) then
                parent = GameObject.Find("@ACTNode1")
            end
            if IsEquals(parent) then
                parent = parent.transform
                GameComAnimToolDownGet.Create(change_assets_get[1].value,parent,"yjlqjnb_icon_jnb")
            end
            return true
        end
    end
end