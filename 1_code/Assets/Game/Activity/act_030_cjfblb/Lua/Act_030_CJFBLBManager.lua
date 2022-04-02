-- 创建时间:2020-09-07
-- Act_030_CJFBLBManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_030_CJFBLBManager = {}
local M = Act_030_CJFBLBManager
M.key = "act_030_cjfblb"
GameButtonManager.ExtLoadLua(M.key,"Act_030_CJFBLBEnterPrefab")
GameButtonManager.ExtLoadLua(M.key,"Act_030_CJFBLBPanel")
GameButtonManager.ExtLoadLua(M.key,"Act_030_CJFBLBItemPanel")

local  act_030_shop_config = GameButtonManager.ExtLoadLua(M.key,"Act_030_CCFBLB_config")

local permisstions = {
    --彩金翻倍礼包（免费，小额，V1-V3玩家）
    "actp_buy_gift_bag_class_030_cjfblb_nor",
    --彩金翻倍礼包（V4-V7玩家）
    "actp_buy_gift_bag_class_030_cjfblb_v4",
    --彩金翻倍礼包（V8-V12玩家）
    "actp_buy_gift_bag_class_030_cjfblb_v8",
}

local cjfb_shop_config = {
    [1] = { 10419, 10420, 10421},
    [2] = { 10422, 10423, 10424},
    [3] = { 10425, 10426, 10427},
}


local this
local lister


function M.GetNowPerMiss()
    local cheak_fun = function (_permission_key)
        if _permission_key then
            local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=_permission_key, is_on_hint = true}, "CheckCondition")
            if a and not b then
                return false
            end
            return true
        else
            return false
        end
    end
    M.now_level = nil
    for i = 1,#permisstions do 
        if cheak_fun(permisstions[i]) then
            dump(permisstions[i],"符合条件的权限")
            M.now_level = i
            return i
        end
    end
end

--获取商品ID
function M.GetCurrShopID()
    return  cjfb_shop_config[M.GetNowPerMiss()]
end

-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    local e_time = 1601308799
    local s_time = 1600731000
    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
        return false
    end

    -- 对应权限的key
    if permisstions then
        for i = 1,#permisstions do 
            local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key= permisstions[i], is_on_hint = true}, "CheckCondition")
            if a and  b then
                return true
            end
        end
    else
        return false
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
        return Act_030_CJFBLBPanel.Create()
    elseif parm.goto_scene_parm == "enter" then
        return Act_030_CJFBLBEnterPrefab.Create(parm.parent)
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
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

	this = Act_030_CJFBLBManager
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
    this.UIConfig.shop_map_id = {}
    this.UIConfig.shop_map_ui = {}
    for k,v in pairs(act_030_shop_config.cjfblb) do
        this.UIConfig.shop_map_id[v.id] = v
    end

    for k,v in pairs(act_030_shop_config.cjfblb_ui) do
        this.UIConfig.shop_map_ui[v.shop_id] = v
    end
end

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
	end
end
function M.OnReConnecteServerSucceed()
end

function M.GetConfigByID(id)
    return this.UIConfig.shop_map_ui[id]


end
