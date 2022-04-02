-- 创建时间:2019-12-31
-- YX_CDMManager 管理器

local basefunc = require "Game/Common/basefunc"
YX_CDMManager = {}
local M = YX_CDMManager
M.key = "act_yx_cdm"

local this
local lister
local s_time = 1580772600
local e_time = 1581350399
local is_share = 0
local is_award = 0
local is_guess = 0
local count = 0
local config = GameButtonManager.ExtLoadLua(M.key, "yx_cdm_config")
GameButtonManager.ExtLoadLua(M.key, "YX_CDMPanel")

-- 创建入口按钮时调用
function M.CheckIsShow()
    return true
end
-- 所有可以外部创建的UI
function M.GotoUI(parm)
    if parm.goto_scene_parm == "panel" then
        return YX_CDMPanel.Create(parm.parent)
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end

function M.on_global_hint_state_set_msg(parm)
	if parm.gotoui == M.key then
		M.SetHintState()
        Event.Brocast("global_hint_state_change_msg", parm)
	end
end
-- 更新活动的提示状态(针对那种 打开界面就需要修改状态的需求)
function M.SetHintState()
    PlayerPrefs.SetString(M.key .. MainModel.UserInfo.user_id, os.time())
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
    lister["query_cai_dengmi_status_response"] = this.on_query_cai_dengmi_status_response
end

function M.Init()
	M.Exit()

	this = YX_CDMManager
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
        Network.SendRequest("query_cai_dengmi_status")
    end
end

function M.OnReConnecteServerSucceed()

end

function M.GetFAQConfig()
    return config
end

--在min到max中，随机选择num个数字，组成数组,min 默认是 1
function M.GetRandomList(_num,_max,random_seed,_min)
	_min = _min or 1
	if _num > _max or _min >= _max then 
		print("<color=yellow>Error 数据不合法了</color>")
		return 
	end
	local _m = {}
	local _n = {}
	for i=1,_max + 1 - _min  do
		_m[i] = i
	end
	if random_seed then
		math.randomseed(random_seed)
	end 
	while #_n < _num do
		local x = math.random(1,#_m)
		if _m[x] ~= nil then 
			_n[#_n + 1] = _m[x]
			table.remove(_m,x)
		end 
	end
	if _min  then 
		for i=1,#_n do
			_n[i] = _n[i] + _min - 1
		end
	end 
	return _n
end

function M.GetDayIndex()
    local t1 = basefunc.get_today_id(s_time)
    local t2 = basefunc.get_today_id(os.time())
    return  t2 - t1
end

function M.on_query_cai_dengmi_status_response(_,data)
    dump(data,"<color=red>-------猜灯谜数据-----</color>")
    if data and data.result == 0 then 
        is_guess = data.my_cai_dengmi_data.is_guess
        is_share = data.my_cai_dengmi_data.is_share
        is_award = data.my_cai_dengmi_data.is_award
        count = data.my_cai_dengmi_data.count
        Event.Brocast("global_hint_state_change_msg",{gotoui = M.key})
    end 
end

function M.Is_Can_GetAward()
    if count >= 1 then
        return true
    else
        return false
    end 
end


function M.GetHintState(parm)
    if parm and parm.gotoui == M.key then 
        if M.Is_Can_GetAward() then
            return ACTIVITY_HINT_STATUS_ENUM.AT_Get
        else
            return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
        end
    end 
end

function M.CheckIsShowInActivity(parm)
    local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="actp_lanterns_riddles", is_on_hint = true}, "CheckCondition")
    if a and not b then
        return false
    end
    return true
end

function M.Get_Is_Award()
    return is_award
end

function M.Get_Is_Share()
    return is_share
end

function M.Get_Is_Guess()
    return is_guess
end

function M.Get_Count()
    return count
end
