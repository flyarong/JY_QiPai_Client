-- 创建时间:2022-01-11
-- Act_072_CDMManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_072_CDMManager = {}
local M = Act_072_CDMManager
M.key = "act_072_cdm"
GameButtonManager.ExtLoadLua(M.key,"Act_072_CDMPanel")
GameButtonManager.ExtLoadLua(M.key,"Act_072_CDMItemBase")
GameButtonManager.ExtLoadLua(M.key,"Act_072_CDMInputPanel")
local this
local lister
M.e_time = 1645459199
local config = {
    [1] = {
        index = 1,
        bg2_txt = "一加一\n(打一字)",
        bg3_txt = "一加一\n(打一字)\n\n___王",
        ans = "王",
        bgbg1_img = "cdm_imgf_fxgz",
        desc = "登录游戏",
        award_txt = "2000鲸币",
        award_img = "ty_icon_jb_6y",
        task1 = 21911,
        task2 = 21910,
    },
    [2] = {
        index = 2,
        bg2_txt = "一百减一\n(打一字)",
        bg3_txt = "一百减一\n(打一字)\n\n___白",
        ans = "白",
        bgbg1_img = "cdm_imgf_gxfc",
        desc = "打10条鱼",
        award_txt = "2000鲸币",
        award_img = "ty_icon_jb_6y",
        task1 = 21913,
        task2 = 21912,
    },
    [3] = {
        index = 3,
        bg2_txt = "守门员\n(打一字)",
        bg3_txt = "守门员\n(打一字)\n\n___闪",
        ans = "闪",
        bgbg1_img = "cdm_imgf_wsry",
        desc = "赢金10万",
        award_txt = "3000鲸币",
        award_img = "ty_icon_jb_15y",
        task1 = 21915,
        task2 = 21914,
    },
    [4] = {
        index = 4,
        bg2_txt = "一只牛\n(打一字)",
        bg3_txt = "一只牛\n(打一字)\n\n___生",
        ans = "生",
        bgbg1_img = "cdm_imgf_cygj",
        desc = "充值3元",
        award_txt = "0.5福卡",
        award_img = "jbsdt_icon_fk1",
        task1 = 21917,
        task2 = 21916,
    },
    [5] = {
        index = 5,
        bg2_txt = "九只鸟\n(打一字)",
        bg3_txt = "九只鸟\n(打一字)\n\n___鸠",
        ans = "鸠",
        bgbg1_img = "cdm_imgf_zcjb",
        desc = "充值10元",
        award_txt = "1福卡",
        award_img = "jbsdt_icon_fk2",
        task1 = 21919,
        task2 = 21918,
    },
}
-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    local e_time = M.e_time
    local s_time = 1644881400
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
function M.CheckIsShow(parm, type)
    return M.IsActive()
end
-- 活动面板调用
function M.CheckIsShowInActivity()
    return M.IsActive()
end

-- 所有可以外部创建的UI
function M.GotoUI(parm)
    if not M.CheckIsShow(parm) then
        dump(parm, "<color=red>不满足条件</color>")
        return
    end
    if parm.goto_scene_parm == "panel" then
        return Act_072_CDMPanel.Create(parm.parent)
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end
-- 活动的提示状态
function M.GetHintState(parm)
    if M.IsCanGet() then
        return ACTIVITY_HINT_STATUS_ENUM.AT_Get
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

    lister["model_task_change_msg"] = this.on_model_task_change_msg
end

function M.Init()
	M.Exit()

	this = Act_072_CDMManager
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

    this.UIConfig.task_map = {}
    for k,v in pairs(config) do
        this.UIConfig.task_map[v.task1] = v.task1
        this.UIConfig.task_map[v.task2] = v.task2
    end
end

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
	end
end
function M.OnReConnecteServerSucceed()
end

function M.IsCanGet()
    for k,v in pairs(config) do
        local data = GameTaskModel.GetTaskDataByID(v.task2)
        local data2 = GameTaskModel.GetTaskDataByID(v.task1)
        if data and data.award_status == 1 and data2 and data2.award_status ~= 2 then
            return true
        end
    end
end

function M.GetConfig()
    return config
end

function M.on_model_task_change_msg(data)
    if this.UIConfig.task_map[data.id] then
        M.SetHintState()
    end
end