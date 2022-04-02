-- 创建时间:2019-12-26
-- DZYLManager 管理器
-- 点赞有礼

local basefunc = require "Game/Common/basefunc"
DZYLManager = {}
local M = DZYLManager
M.key = "act_dzyl"
GameButtonManager.ExtLoadLua(M.key, "DZYLPanel") -- 活动内右边界面
GameButtonManager.ExtLoadLua(M.key, "DZYLGetPanel") -- 领取宝箱的界面
GameButtonManager.ExtLoadLua(M.key, "DZYLJysjPanel") -- 建议收集界面

local this
local lister
local s_time = 1578958200
local e_time = 1579535999

function M.IsActive()
    local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="actp_thumbs_up", is_on_hint = true}, "CheckCondition")
    if a and not b then
        return false
    end
    return true
end
-- 创建入口按钮时调用
function M.CheckIsShow()
    if M.IsActive() then
        if os.time() < e_time and os.time() > s_time then
            return true
        end
    end
end
-- 活动面板调用
function M.CheckIsShowInActivity()
    if M.IsActive() then
        return true
    end
end
-- 所有可以外部创建的UI
function M.GotoUI(parm)
    if parm.goto_scene_parm == "panel" then
        return DZYLPanel.Create(parm)
    elseif parm.goto_scene_parm == "get" then
        return DZYLGetPanel.Create()
    elseif parm.goto_scene_parm == "jysj" then
        return DZYLJysjPanel.Create()
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end
-- 活动的提示状态
function M.GetHintState(parm)
    if parm and parm.gotoui == M.key then
        if M.IsAwardCanGet() then
            return ACTIVITY_HINT_STATUS_ENUM.AT_Get
        else
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

    lister["query_click_like_activity_info_response"] = this.on_activity_info_msg
    lister["query_click_like_activity_box_status_response"] = this.on_my_activity_info_msg
end

function M.Init()
	M.Exit()

	this = DZYLManager
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
    this.UIConfig={
    }
end

function M.OnLoginResponse(result)
	if result == 0 then
        Network.RandomDelayedSendRequest("query_click_like_activity_info")
        Network.RandomDelayedSendRequest("query_click_like_activity_box_status")

        M.LoadAdvise()
	end
end
function M.OnReConnecteServerSucceed()
end

-- 本地建议
function M.LoadAdvise()
    local path = AppDefine.LOCAL_DATA_PATH
    path = path .. "/advise_".. MainModel.UserInfo.user_id .. ".txt"
    if File.Exists(path) then
        this.m_data.advise = File.ReadAllText(path)
    else
        this.m_data.advise = ""
    end
end
function M.SaveAdvise()
    local path = AppDefine.LOCAL_DATA_PATH
    path = path .. "/advise_".. MainModel.UserInfo.user_id .. ".txt"
    File.WriteAllText(path, this.m_data.advise or "")    
end

-- 上一次的建议内容
function M.GetOldJY()
    if this.m_data and this.m_data.advise then
        return this.m_data.advise
    end
end
function M.SetOldJY(advise)
    if this.m_data then
        this.m_data.advise = advise
        M.SaveAdvise()
    end
end
function M.GetMyDzNum()
    local dz = 0
    if this.m_data.my_dz_data then
        for k,v in pairs(this.m_data.my_dz_data) do
            if v > 0 then
                dz = dz + 1
            end
        end
    end
    return dz
end
function M.GetAllDzByGame(gt)
    if M.m_data.all_dz_data and M.m_data.all_dz_data[gt] then
        local da = M.m_data.all_dz_data[gt]
        return da
    else
        return 0
    end
end
function M.GetMyDzByGame(gt)
    if M.m_data.my_dz_data and M.m_data.my_dz_data[gt] then
        local da = M.m_data.my_dz_data[gt]
        return da
    else
        return 0
    end
end
function M.OnDzByGame(gt, op)
    if not M.m_data.my_dz_data then
        M.m_data.my_dz_data = {}
    end
    if op == 1 then
        M.m_data.my_dz_data[gt] = 1
    else
        M.m_data.my_dz_data[gt] = 0
    end

    if not M.m_data.all_dz_data then
        M.m_data.all_dz_data = {}
    end
    if not M.m_data.all_dz_data[gt] then
        M.m_data.all_dz_data[gt] = 0
    end
    if op == 1 then
        M.m_data.all_dz_data[gt] = M.m_data.all_dz_data[gt] + 1
    else
        M.m_data.all_dz_data[gt] = M.m_data.all_dz_data[gt] - 1
    end
    dump(M.m_data)
    
    Event.Brocast("model_dzyl_data_change_msg")
end

function M.on_activity_info_msg(_, data)
    dump(data, "<color=red>DZYL on_activity_info_msg</color>")
    if data.result == 0 then
        this.m_data.all_dz_data = {}
        if data.click_like_data then
            for k,v in ipairs(data.click_like_data) do
                this.m_data.all_dz_data[v.game_type] = v.num
            end
        end
        Event.Brocast("model_dzyl_data_change_msg")
    end
end
function M.on_my_activity_info_msg(_, data)
    dump(data, "<color=red>DZYL on_my_activity_info_msg</color>")
    if data.result == 0 then
        this.m_data.my_dz_data = {}
        if data.player_click_like_data then
            if data.player_click_like_data.game_num then
                for k,v in ipairs(data.player_click_like_data.game_num) do
                    this.m_data.my_dz_data[v.game_type] = v.num
                end
            end
            this.m_data.box_status = data.player_click_like_data.box_status or 0
        end
        Event.Brocast("model_dzyl_data_change_msg")
    end
end

function M.IsAwardCanGet()
    if this.m_data and this.m_data.box_status and this.m_data.my_dz_data then
        if M.GetMyDzNum() > 0 and this.m_data.box_status == 0 then
            return true
        end
    end
end
