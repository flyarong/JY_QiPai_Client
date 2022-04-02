-- 创建时间:2020-12-21
-- Template_NAME 管理器

local basefunc = require "Game/Common/basefunc"
Act_045_CQGManager = {}
local M = Act_045_CQGManager
M.key = "act_045_cqg"
GameButtonManager.ExtLoadLua(M.key, "Act_045_CQGPanel")
GameButtonManager.ExtLoadLua(M.key, "Act_045_CQGEnterPanel")
GameButtonManager.ExtLoadLua(M.key, "CQG_JYFLEnterPrefab")

local this
local lister

M.cqg_limit = 500000

local deposit_value
--local hintPanel

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
    if not M.CheckIsShow() then
        return 
    end
    if parm.goto_scene_parm == "panel" then
        return Act_045_CQGPanel.Create(parm.parent, parm.backcall)
    elseif parm.goto_scene_parm == "enter" and M.CheckIsEnter() then
        return Act_045_CQGEnterPanel.Create(parm.parent, parm.backcall)
    elseif parm.goto_scene_parm == "jyfl_enter" and M.CheckIsEnter() then
        return CQG_JYFLEnterPrefab.Create(parm.parent)
    else
        --dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end
-- 活动的提示状态
function M.GetHintState(parm)
    if M.GetDepositValue() > 0 then
        return  ACTIVITY_HINT_STATUS_ENUM.AT_Get
    end
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
    lister["deposit_info_max_change_msg"] = this.on_deposit_info_max_change_msg
    lister["query_deposit_data_response"] = this.on_query_deposit_data_response
    lister["vip_upgrade_change_msg"] = this.on_vip_upgrade_change_msg
    lister["jyfl_init_ui_start"] = this.on_jyfl_init_ui_start
end

function M.Init()
	M.Exit()

	this = Act_045_CQGManager
	this.m_data = {}
	MakeLister()
    AddLister()
	M.InitUIConfig()
    M.QueryCqgData()
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

function M.QueryCqgData()
	Network.SendRequest("query_deposit_data")
end


function M.on_deposit_info_max_change_msg(_,data)
    --dump(data,"<color=red>存钱罐:deposit_info_max_change</color>")
    if not M.IsCanTrigger() then
        return
    end
    --Event.Brocast("stop_auto_lotttery")
    
    M.QueryCqgData()
    if M.IsShowPanel() then
        Act_045_CQGPanel.Create()
        M.SetFirstShowPanel()
    else
        LittleTips.Create("超出鲸币已放入存钱罐，次日0点清除！",{x = 0, y = 210})
    end

    -- local show_txt = "超出【携带限制】的<color=red>"..StringHelper.ToCash(data.value).."</color>鲸币\n已放入【存钱罐】中,请及时领取"
    -- if hintPanel then
    --     hintPanel:MyExit()
    -- end
    -- hintPanel = HintPanel.Create(2,show_txt,function ()
    --     Act_045_CQGPanel.Create()
    -- end)
    -- hintPanel.confirmBtnEntity.transform:Find("Text"):GetComponent("Text").text = "前往领取"
    -- return
end

function M.on_query_deposit_data_response(_,data)
    -- dump(data,"<color=red>存钱罐数据</color>")
    if data.result == 0 then
        deposit_value = data.value
        JYFLManager.InitRedHint()
        if deposit_value > 0 and VIPManager.get_vip_level() ~= 0 then
            Network.SendRequest("get_deposit_award")
        end
    end
end

function M.GetDepositValue()
    if deposit_value then
        return deposit_value
    end
    return 0
end

function M.ReSetDepositValue()
    deposit_value = 0
end

--是否有入口的检测
function M.CheckIsEnter()
    if not M.CheckIsShow() then
        return false
    end

    if VIPManager.get_vip_level() == 0 then
        return true
    elseif M.GetDepositValue() ~= 0 then
        return true
    end
end

function M.on_vip_upgrade_change_msg(_,data)
    dump(data, "<color=red>+++++on_vip_upgrade_change_msg+++++</color>")
    if data then
        if VIPManager.get_vip_level() ~= 0 then
            M.QueryCqgData()
        end
    end
end

-- function M.on_enter_scene()
--     if M.CheckIsShowTip() then
--         local show_txt = "您携带的鲸币数量将要超过可携带50万鲸币数量上限，超过部分将放入存钱罐中。\n充值10元，解锁携带鲸币数量上限。\n\n<color=#007900><size=26>小提示：存钱罐在大厅福利中心中查看</size></color>"
--         local hint = HintPanel.Create(2,show_txt)
--         local txt_ui = hint.transform:Find("ImgPopupPanel/hint_info_txt"):GetComponent("Text")
--         txt_ui.fontSize = 36
--     end
-- end

-- function M.CheckIsShowTip()
--     if VIPManager.get_vip_level() == 0 
--     and MainModel.UserInfo.jing_bi >= 300000
--     and MainModel.UserInfo.jing_bi <= 500000 then
--         return true
--     end
--     return false
-- end

function M.IsCanTrigger()
    if not M.CheckIsShow() then
        return false
    end
    return true
end

function M.SetFirstShowPanel()
    local cur_date = tonumber(os.date("%Y%m%d", os.time()))
    PlayerPrefs.SetString("CQG_FIRST_SHOW" .. MainModel.UserInfo.user_id, cur_date)
end

function M.IsShowPanel()
    --玩家首次触发存钱罐时，弹出存钱罐界面
    if PlayerPrefs.GetString("CQG_FIRST_SHOW" .. MainModel.UserInfo.user_id, "000") == "000" then
        return true
    end
end

function M.on_jyfl_init_ui_start()
    if M.GetDepositValue() > 0 then
        JYFLManager.ResetEnterOrder("act_045_cqg")
    else
        JYFLManager.ChangeEnterOrder(false, "act_045_cqg")
    end
end