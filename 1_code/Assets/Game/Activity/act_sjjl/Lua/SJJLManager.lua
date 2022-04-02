-- 创建时间:2019-11-19
local basefunc = require "Game/Common/basefunc"
SJJLManager = {}
SJJLManager = basefunc.class()
local M = SJJLManager
M.key = "act_sjjl"
local lister
GameButtonManager.ExtLoadLua(M.key, "SJJLPanel")
M.taskid = 21734
function M.CheckIsShow()
    return false
end

function M.Init()
	M.Exit()
	M.MakeLister()
    M.AddLister()
end

function M.Exit()
	if M then
        M.RemoveLister() 
	end
end

function M.RemoveLister()
    if lister then
        for msg,cbk in pairs(lister) do
            Event.RemoveListener(msg, cbk)
        end
    end
    lister=nil
end

function M.AddLister()
    for msg,cbk in pairs(lister) do
        Event.AddListener(msg, cbk)
    end
end

function M.MakeLister()
    lister = {}
	lister["global_hint_state_set_msg"] = M.SetHintState
end

function M.GotoUI(parm)
	if parm.goto_scene_parm == "panel" then
        return SJJLPanel.Create(parm)
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end

function M.GetStatus()
    local data = GameTaskModel.GetTaskDataByID(M.taskid)
    dump(data)
    if data then 
        return data.award_status
    end
    return 0  
end

function M.CheckIsShowInActivity(parm)
    local data = GameTaskModel.GetTaskDataByID(M.taskid)
    if data then 
        if data.award_status == 0 then 
            return false
        else
            return true
        end 
    end
    return false
end

function M.GetHintState(parm)
    dump(M.GetStatus())
    if M.GetStatus() == 1 then
        return ACTIVITY_HINT_STATUS_ENUM.AT_Get
    end
    return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
end

function M.SetHintState(parm)
	if parm.gotoui == M.key then
	end
end

