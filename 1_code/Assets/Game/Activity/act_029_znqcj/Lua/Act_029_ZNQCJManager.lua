-- 创建时间:2020-08-17
-- Act_029_ZNQCJManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_029_ZNQCJManager = {}
local M = Act_029_ZNQCJManager
M.key = "act_029_znqcj"
M.config = {
	[12313] = {text = "夏日短袜",image = "activity_icon_gift228_dw"},
	[12315] = {text = "金龙鱼挂面",image = "activity_icon_gift223_jlyjdm"},
	[12316] = {text = "金龙鱼大豆油",image = "activity_icon_gift227_ddy"},
    [12317] = {text = "网红小麻花",image = "activity_icon_gift226_xmh"},
    [12318] = {text = "大枣夹核桃",image = "activity_icon_gift217_dzjht"},
    [12320] = {text = "怡宝矿泉水",image = "activity_icon_gift229_yb"},
    [12321] = {text = "金龙鱼大米",image = "activity_icon_gift215_jlydm"},
}
M.task_id = 21525
GameButtonManager.ExtLoadLua(M.key,"Act_029_ZNQCJPanel")
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
	if parm.goto_scene_parm == "panel"  then
		return Act_029_ZNQCJPanel.Create(parm.parent)
	end
    dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
end
-- 活动的提示状态
function M.GetHintState(parm)
    if GameItemModel.GetItemCount("prop_2year_jinianbi3") >= 10 or M.IsTaskAwardCanGet()  then 
        return ACTIVITY_HINT_STATUS_ENUM.AT_Get
    else
        local newtime = tonumber(os.date("%Y%m%d", os.time()))
        local oldtime = tonumber(os.date("%Y%m%d", tonumber(PlayerPrefs.GetString(M.key .. MainModel.UserInfo.user_id, 0))))
        if oldtime ~= newtime then
            return ACTIVITY_HINT_STATUS_ENUM.AT_Red
        end
        return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
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
    lister["model_task_change_msg"] = this.on_model_task_change_msg
    lister["AssetChange"] = this.OnAssetChange
    lister["OnLoginResponse"] = this.OnLoginResponse
    lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed
    lister["global_hint_state_set_msg"] = this.on_global_hint_state_set_msg
end

function M.Init()
	M.Exit()

	this = Act_029_ZNQCJManager
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
    this.UIConfig = {}
end

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
	end
end
function M.OnReConnecteServerSucceed()
end

function M.OnAssetChange(data)
    Event.Brocast("global_hint_state_change_msg", { gotoui = M.key })
end

function M.on_model_task_change_msg(data)
    if data and data.id == M.task_id then
		--self.num_txt.text = data.now_total_process
        Event.Brocast("global_hint_state_change_msg", { gotoui = M.key })
	end 
end

function M.IsTaskAwardCanGet()
    local data = GameTaskModel.GetTaskDataByID(M.task_id)
    if data and data.award_status == 1 then
        return true 
    end
end