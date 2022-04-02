-- 创建时间:2019-05-29
-- Panel:XXLSGPHBManager
local basefunc = require "Game/Common/basefunc"

XXLSHPHBManager = basefunc.class()
local M = XXLSHPHBManager
M.key = "sys_shphb"
GameButtonManager.ExtLoadLua(M.key, "XXLSHPHBEnterPrefab")
GameButtonManager.ExtLoadLua(M.key, "EliminateSHRankPanel")
local lister
local m_data

function M.CheckIsShow()
	if M.CheckPermiss() then 
		return true and os.time() < 1621202400
	end 
end

function M.GotoUI(parm)
	if parm.goto_scene_parm == "panel" then
		if M.CheckPermiss() then 
			return EliminateSHRankPanel.Create()
		end  
	elseif parm.goto_scene_parm == "enter" then
		if M.CheckPermiss() then 
			return XXLSHPHBEnterPrefab.Create(parm.parent, parm.cfg)
		end 
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end

function M.GetData()
	return m_data
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
    lister["OnLoginResponse"] = M.OnLoginResponse
	lister["ReConnecteServerSucceed"] = M.OnReConnecteServerSucceed
	lister["EnterForeGround"] = M.OnReConnecteServerSucceed
	lister["global_hint_state_set_msg"] = M.SetHintState
end

function M.Init()
	M.Exit()
	m_data = {}
	MakeLister()
    AddLister()
end

function M.Exit()
	if M then
		RemoveLister() 
	end
end

-- 数据更新
function M.UpdateData()
	
end

function M.OnLoginResponse(result)
	if result == 0 then
		Timer.New(function ()
			M.UpdateData()		
		end, 3, 1):Start()
	end
end

function M.OnReConnecteServerSucceed()
	M.UpdateData()
end

-- 活动的提示状态
function M.GetHintState(parm)
	
end

function M.SetHintState(parm)
	if parm.gotoui == M.key then
		Event.Brocast("global_hint_state_change_msg", parm)
	end
end

function M.CheckPermiss()
    local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="rank_xiaoxiaole_shuihu_once_rank", is_on_hint = true}, "CheckCondition")
    if a and not b then
        return false
    end
    return true
end