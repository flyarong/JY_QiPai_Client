local basefunc = require "Game/Common/basefunc"
CommonAwardPanelManager = {}
local M = CommonAwardPanelManager

local this
local lister
local AwardPanels = {}
local index = 1
-- 是否有活动
function M.IsActive()
   
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
    lister["ExitScene"] = this.ExitScene
    lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed
    lister["global_hint_state_set_msg"] = this.on_global_hint_state_set_msg
end

function M.Init()
	M.Exit()

	this = CommonAwardPanelManager
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

function M.AddPanel(panself)
    if not panself or not IsEquals(panself.gameObject) then return end
    local can_show = true
    local data = {}
    data.panel = panself
    data.had_show = false
    for k , v in pairs(AwardPanels) do
        if v.panel and IsEquals(v.panel.gameObject) and v.panel.gameObject.activeSelf then
            can_show = false
        end
    end
    panself.gameObject:SetActive(can_show)
    if can_show then
        data.had_show = true
    end
    AwardPanels[#AwardPanels + 1] = data
end

function M.DelPanel()
    for k ,v in pairs(AwardPanels) do
        if v.panel and IsEquals(v.panel.gameObject) and v.had_show == false then
            v.had_show = true
            v.panel.gameObject:SetActive(true)
            return
        end
    end
end


function M.ExitScene()
    AwardPanels = {}
end
