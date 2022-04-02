-- 创建时间:2020-11-05
-- Act_037_SYYLBManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_037_SYYLBManager = {}
local M = Act_037_SYYLBManager
M.key = "act_037_ssylb"
GameButtonManager.ExtLoadLua(M.key, "Act_037_SYYLBEnterPrefab")
M.config = GameButtonManager.ExtLoadLua(M.key, "act_037_syylb_config").config

M.level = 1
local this
local lister

local permiss = {
    "actp_buy_gift_bag_class_ssylb_037_nor",
    "actp_buy_gift_bag_class_ssylb_037_v1",
    "actp_buy_gift_bag_class_ssylb_037_v4",
    "actp_buy_gift_bag_class_ssylb_037_v8",
}

-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    local e_time
    local s_time
    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
        return false
    end

    -- 对应权限的key
    local check_func = function(_permission_key)
        local a, b = GameButtonManager.RunFun({ gotoui = "sys_qx", _permission_key = _permission_key, is_on_hint = true }, "CheckCondition")
        if a and not b then
            return false
        end
        return true
    end
    --return true
    for i = 1, #permiss do
        if check_func(permiss[i]) then
            M.level = i
        end
    end
    return M.level ~= 0
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
    --dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    if parm.goto_scene_parm == "enter" then
        return Act_037_SYYLBEnterPrefab.Create(parm.parent, parm.cfg)
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
end

function M.Init()
	M.Exit()

	this = Act_037_SYYLBManager
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
        Timer.New(
            function()
                M.UpDate()
            end, 30, -1
            ):Start()
	end
end
function M.OnReConnecteServerSucceed()
end

function M.IButton(parm)
    return Act_037_SYYLBEnterPrefab.Create(parm.switchPanel.transform)
end

function M.GetBeiShu()
    if M.level ~= 0 then
        local shopids = M.config[M.level].gift_id
        local num = 0
        if shopids then
            for i = 1, #shopids do
                local status = MainModel.GetGiftShopStatusByID(shopids[i])
                if status == 0 then
                    num = num + 1
                end
            end
        end
        return num
    end
    return 0
end

function M.UpDate()
    local d = os.date("%Y/%m/%d")
    local strs = {}
    string.gsub(d, "[^-/]+", function(s)
        strs[#strs + 1] = s
    end)
    local et = os.time({ year = strs[1], month = strs[2], day = strs[3], hour = "23", min = "59", sec = "59" })
    et = et + 1
    if math.abs(os.time() - (et - 86400)) <= 70 then
        Network.SendRequest("query_all_gift_bag_status")
        --Event.Brocast("Act_033_DHPanel_Refresh")
    end
end
