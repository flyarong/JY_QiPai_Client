-- 创建时间:2020-02-24
-- act_002UIChangeManager 管理器

local basefunc = require "Game/Common/basefunc"
act_002UIChangeManager = {}
local M = act_002UIChangeManager
M.key = "act_002_UIChange"
local this
local lister

-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    local e_time = 1583769599
    local s_time = 1583191800 
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
    lister["qql_panel_created"] = this.on_qql_panel_created
    lister["act_ns_sprite_change"] = this.on_act_ns_sprite_change
end

function M.Init()
	M.Exit()

	this = act_002UIChangeManager
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

function M.on_qql_panel_created(data)
    if M.IsActive() then 
        if data and data.panelSelf then 
            local PS = data.panelSelf
            PS.ns_node.gameObject:SetActive(PS.goto2EggMode)
            PS.Title_cs.transform:GetComponent("Image").sprite = GetTexture("zjd_bg_nsd")
            local func = function () --将切换图片的操作加在之前的切换程序之后
                PS.modeIcon_img.sprite = GetTexture(PS.is2EggMode and "zjd_btn_ptms2_activity_act_002_uichange" or "zjd_btn_nsms2")
                PS.modebtn_img.sprite = GetTexture(PS.is2EggMode and "zjd_btn_ptms_activity_act_002_uichange" or "zjd_btn_nsms") 
                PS.ns_node.gameObject:SetActive( PS.is2EggMode)
            end
            PS.mode_btn.onClick:AddListener(basefunc.handler(PS, func))
        end
    end 
end

function M.on_act_ns_sprite_change(data)
    if M.IsActive() then 
        if data and data.sprite then
            data.sprite.sprite = GetTexture("ns_zjd_icon19")
        end 
        if data and data.button_img then 
            data.button_img.sprite = GetTexture("nsqql_btn_nsqql")
        end
    end 
end