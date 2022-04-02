-- 创建时间:2020-02-21
-- BY3DAct6in1Manager 管理器

local basefunc = require "Game/Common/basefunc"
BY3DAct6in1Manager = {}
local M = BY3DAct6in1Manager
M.key = "by3d_act_6in1"
GameButtonManager.ExtLoadLua(M.key, "Fishing3DAct6in1Panel")
GameButtonManager.ExtLoadLua(M.key, "Fishing3DAct6in1BoxPrefab")
GameButtonManager.ExtLoadLua(M.key, "Fishing3DAct6in1EnterPrefab")

local this
local lister
local send_data

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
    if parm.goto_scene_parm == "panel" then
        if M.CheckIsShow() then
            this.m_data.round = 0
            this.m_data.award_multiple = 0
            return Fishing3DAct6in1Panel.Create()
        end 
    elseif parm.goto_scene_parm == "enter" then
        print("6in1 enter")
        if M.CheckIsShow() then
            print("6in1 enter2")
            return Fishing3DAct6in1EnterPrefab.Create(parm.parent)
        end 
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

    lister["nor_fishing_3d_6in1_start"] = this.on_nor_fishing_3d_6in1_start
    lister["nor_fishing_6in1_lottery_response"] = this.on_nor_fishing_6in1_lottery_response
end

function M.Init()
    print("6in1manager init!")
	M.Exit()

	this = BY3DAct6in1Manager
	this.m_data = {}
	MakeLister()
    AddLister()

    -- 0是失败 大于0是倍数,目前只用区分是否是0,倍数不显示
    this.round_map = {}
    this.round_map[1] = {50,40,30,20,10,0}
    this.round_map[2] = {50,40,30,20,10,0}
    this.round_map[3] = {50,40,30,20,10,0}
    this.round_map[4] = {50,40,30,20,0,0}
    this.round_map[5] = {50,40,30,20,0,0}
    this.round_map[6] = {50,40,30,20,10,0}
    this.round_map[7] = {50,40,30,20,0,0}
    this.round_map[8] = {50,40,30,0,0,0}
    this.round_map[9] = {50,40,30,0,0,0}
    this.round_map[10] = {50,0,0,0,0,0}
end
function M.Exit()
	if this then
		RemoveLister()
		this = nil
	end
end


function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
	end
end
function M.OnReConnecteServerSucceed()
end

local iii = 1
function M.RequestLottery()
    Network.SendRequest("nor_fishing_6in1_lottery", nil, "抽奖")

    --[[
    this.m_data.result = 0
    this.m_data.round = iii
    if iii < 4 then
        this.m_data.lottery_result = 0
    else
        this.m_data.lottery_result = 1
        iii = 1
    end
    iii = iii + 1
    this.m_data.award_multiple = this.m_data.award_multiple or 0
    this.m_data.award_multiple = this.m_data.award_multiple + 10

    Event.Brocast("model_by3d_act_6in1_lottery")
    --]]
end

function M.on_nor_fishing_3d_6in1_start(_, data)
    dump(data, "<color=red>on_nor_fishing_3d_6in1_start</color>")
end

function M.on_nor_fishing_6in1_lottery_response(_, data)
    dump(data, "<color=red>on_nor_fishing_6in1_lottery_response</color>")
    this.m_data.result = data.result
    this.m_data.round = data.round
    this.m_data.lottery_result = data.lottery_result
    this.m_data.award_multiple = data.award_multiple

    Event.Brocast("model_by3d_act_6in1_lottery")
end

function M.GetAwardData(_, data)
    return this.m_data
end

function M.GetRoundCfg(nn)
    local round = nn or this.m_data.round
    round = round or 1
    if round > 10 then
        round = 10
    end
    if round <= 0 then
        if AppDefine.IsEDITOR() then
            HintPanel.Create(1, "有错误！！！")
        end
        round = 1
    end
    return this.round_map[round]
end

function M.GetCurRound()
    return this.m_data.round
end