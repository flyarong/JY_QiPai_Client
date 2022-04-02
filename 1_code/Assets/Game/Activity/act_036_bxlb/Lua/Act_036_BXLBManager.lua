-- 创建时间:2020-10-18
-- Act_036_BXLBManager 管理器
local basefunc = require "Game/Common/basefunc"
Act_036_BXLBManager = {}
local M = Act_036_BXLBManager
M.key = "act_036_bxlb"
GameButtonManager.ExtLoadLua(M.key, "Act_036_BXLBEnterPrefab")
M.config = GameButtonManager.ExtLoadLua(M.key, "act_036_bxlb_config").config

M.level = 1

local this
local lister
local e_time = 1604937599 --11月9日23:59:59
--礼包权限
local permiss = {
    "actp_buy_gift_bag_class_bxlb_036_nor",
    "actp_buy_gift_bag_class_bxlb_036_v1",
    "actp_buy_gift_bag_class_bxlb_036_v4",
    "actp_buy_gift_bag_class_bxlb_036_v8",
}
-- @SYSQXManager.Debug("actp_buy_gift_bag_class_bxlb_036_v8")
-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
   
    local s_time 
    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
        return false
    end

    -- 对应权限的key
    --local _permission_key
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
    
    if parm.ui_type ~= nil then
        if M.GetPermissionIsJingYu() and parm.ui_type == "hall_config"   then
            return 
        end
    end

    if not M.GetPermissionPassWQP() and gameMgr:getMarketPlatform() == "wqp"  then
        return 
    end

    if parm.goto_scene_parm == "enter" then
        return Act_036_BXLBEnterPrefab.Create(parm.parent, parm.cfg)
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
    lister["model_task_change_msg"] = this.on_model_task_change_msg

end

function M.Init()
    M.Exit()

    this = Act_036_BXLBManager
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
    return Act_036_BXLBEnterPrefab.Create(parm.switchPanel.transform)
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

function M.GetPermissionIsJingYu()

    local is_jingyu = true --是否是鲸鱼斗地主平台，默认为是
    local _permission = "bzdh_033_nor"  
    if _permission then
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=_permission, is_on_hint = true}, "CheckCondition")
        if a and not b then
            --return false
            is_jingyu = false
        end
    end
    return is_jingyu
end



function M.GetPermissionPassWQP()
    local is_pass_wqp = true
    local _permission = "actp_wqp_xianshi"  
    if _permission then
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=_permission, is_on_hint = true}, "CheckCondition")
        if a and not b then
            --return false
            is_pass_wqp = false
        end
    end
    return is_pass_wqp
end
