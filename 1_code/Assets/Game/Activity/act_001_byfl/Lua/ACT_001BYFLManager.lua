local basefunc = require "Game/Common/basefunc"

ACT_001BYFLManager = basefunc.class()
local M = ACT_001BYFLManager
M.key = "act_001_byfl"
local config_1 = GameButtonManager.ExtLoadLua(M.key, "activity_task_fish_config_1")
local config_2 = GameButtonManager.ExtLoadLua(M.key, "activity_task_fish_config_2")
local config_3 = GameButtonManager.ExtLoadLua(M.key, "activity_task_fish_config_3")
local config_4 = GameButtonManager.ExtLoadLua(M.key, "activity_task_fish_config_4")
local configs = {config_1,config_2,config_3,config_4}

local curr_level = 1
local lister
local function MakeLister()
    lister = {}
    lister["UpdateHallTaskRedHint"] = M.CheakStatus
    lister["model_query_task_data_response"] = M.Refresh_Status
	lister["model_task_change_msg"] = M.Refresh_Status
    lister["ActivityTaskPanel_Had_Finish"] = M.on_ActivityTaskPanel_Had_Finish
    lister["global_hint_state_set_msg"] = M.on_global_hint_state_set_msg
end
function M.CheckIsShow()
    return true
end

function M.GotoUI(parm)
    dump(parm)
    if parm.goto_scene_parm == "panel" then
        local cfg
        local curr_l = M.ChoosePlayerLevel()
        dump({cfg = cfg , curr_l = curr_l},"<color=red>------捕鱼福利----</color>")
        if curr_l then
            cfg = configs[curr_l]
            return ActivityTaskPanel.Create(parm.parent, parm.cfg, nil, cfg)
        end 
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end

function M.CheakStatus()

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

function M.Init()
    M.Exit()
    MakeLister()
    AddLister()
end

function M.Exit()
    if M then
        RemoveLister()
    end
end

function M.GetHintState(parm)
    if parm and parm.gotoui == M.key then
        if not M.CheckIsShowInActivity(parm) then
            return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
        end
        if M.IsAwardCanGet() then
            return ACTIVITY_HINT_STATUS_ENUM.AT_Get
        else
            local newtime = tonumber(os.date("%Y%m%d", os.time()))
            local oldtime = tonumber(os.date("%Y%m%d", tonumber(PlayerPrefs.GetString(M.key .. MainModel.UserInfo.user_id, 0))))
            if oldtime ~= newtime then
                return ACTIVITY_HINT_STATUS_ENUM.AT_Red
            end
            return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
        end
    end 
end

function M.CheckIsShowInActivity(parm)
    if M.ChoosePlayerLevel() then 
        return true
    end 
    return false
end

function M.GetTaskIDS(C)
    local _r = {}  
    local _t = M.get_task_id(C)
    for k, v in pairs(_t) do
        _r[#_r + 1] = k
    end
    return _r
end

function M.get_task_id(_config,_t)
    _t = _t or {}
    for k, v in pairs(_config) do
        if type(v) == "table" then
            M.get_task_id(v,_t)
        else
            if k == "task" then
                _t[v] = 1
            end
        end
    end
    return _t
end

function M.IsAwardCanGet()
    if M.ChoosePlayerLevel() then 
        local _b = M.GetTaskIDS(configs[M.ChoosePlayerLevel()])
        dump(_b,"<color=red>任务列表</color>")
        if _b then 
            for i=1,#_b do
                local d = GameTaskModel.GetTaskDataByID(_b[i])
                if d then 
                    if d.award_status == 1 then
                        return true
                    end 
                end 
            end
        end
    end 
    return false
end

function M.Refresh_Status()
    Event.Brocast("global_hint_state_change_msg",{gotoui = M.key})
end

--创建扩展部分
function M.on_ActivityTaskPanel_Had_Finish(data)
	-- if data and data.panelSelf then
	-- 	if data.panelSelf.act_cfg and data.panelSelf.act_cfg.key ==  M.key then 
	-- 		local b = CJS_GFJBPrefab.Create(data.panelSelf.transform)
	-- 		local fun_old_quit = data.panelSelf.OnDestroy
	-- 		data.panelSelf.OnDestroy = function ()
	-- 			fun_old_quit(data.panelSelf)
	-- 			b:MyExit()
	-- 		end
	-- 	end 
	-- end
end

--选择适应玩家的档次
function M.ChoosePlayerLevel()
    if M.level1() then 
        return 1
    end
    if M.level2() then 
        return 2
    end
    if M.level3() then 
        return 3
    end 
    if M.level4() then 
        return 4
    end 
end

function M.level1()
    local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="actp_fishing_welfare1", is_on_hint = true}, "CheckCondition")
    if a and not b then
        return false
    end
    return true
end

function M.level2()
    local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="actp_fishing_welfare2", is_on_hint = true}, "CheckCondition")
    if a and not b then
        return false
    end
    return true
end

function M.level3()
    local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="actp_fishing_welfare3", is_on_hint = true}, "CheckCondition")
    if a and not b then
        return false
    end
    return true
end

function M.level4()
    local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="actp_fishing_welfare4", is_on_hint = true}, "CheckCondition")
    if a and not b then
        return false
    end
    return true
end

function M.GetGFTaskID()
    local index = CJS_GFJBManager.ChoosePlayerLevel()
    if index then 
        return gf_tasks[index]
    end 
end

function M.IsCanGF()
    local task_id = M.GetGFTaskID()
    local task_data = GameTaskModel.GetTaskDataByID(task_id)
    if task_id and task_data then 
        if task_data.award_status == 1 then 
            return true
        end 
    end
    return false
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
