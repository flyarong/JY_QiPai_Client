-- 创建时间:2018-12-12
-- 新人福卡 7日活动

local basefunc = require "Game.Common.basefunc"

ActivitySevenDayLogic = {}
local M = ActivitySevenDayLogic
M.key = "xrhb"
GameButtonManager.ExtLoadLua(M.key, "ActivitySevenDayModel")
GameButtonManager.ExtLoadLua(M.key, "XRHBEnterPrefab")
GameButtonManager.ExtLoadLua(M.key, "ActivitySevenDayPanel")
GameButtonManager.ExtLoadLua(M.key, "ActivitySevenDayNewPanel")
GameButtonManager.ExtLoadLua(M.key, "SevenDayTopPrefab")
GameButtonManager.ExtLoadLua(M.key, "SevenDayTaskPrefab")
GameButtonManager.ExtLoadLua(M.key, "SevenDayNewTopPrefab")
M.config = GameButtonManager.ExtLoadLua(M.key, "bbsc_config")

local this -- 单例
local model
local countdown_timer = nil

function M.CheckIsShow()
	if not GameGlobalOnOff.BBSC_Task or ActivitySevenDayModel.GetCountdownTime() < 0 then
		return
	end
	if model and model.IsNewVersion() then
		if ActivitySevenDayLogic.CheckAllTaskFinish() then
			return
		else
			return true
		end
	else
		return
	end

    return true
end
function M.GotoUI(parm)
	if parm.goto_scene_parm == "panel" then
        return ActivitySevenDayPanel.Create(parm.parent, parm.backcall)
	elseif parm.goto_scene_parm == "enter" then
        return XRHBEnterPrefab.Create(parm.parent, parm.cfg)
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end

local lister
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
    -- lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed
    lister["OnLoginResponse"] = this.OnLoginResponse
    lister["open_activity_seven_day"] = this.open_activity_seven_day
end

function ActivitySevenDayLogic.Init()
    --屏蔽步步生才
    if not GameGlobalOnOff.BBSC_Task then
        return
    end
    print("<color=red>初始化新人福卡系统</color>")
    ActivitySevenDayLogic.Exit()
    this = ActivitySevenDayLogic
    MakeLister()
    AddLister()
    return this
end
function ActivitySevenDayLogic.Exit()
	if this then
		if model then
			model.Exit()
		end
		model = nil
		RemoveLister()
		ActivitySevenDayLogic.stop_countdown_time()
		this = nil
	end
end

--正常登录成功
function ActivitySevenDayLogic.OnLoginResponse(result)
    if result==0 then
    	if model then
    		model.Exit()
    	end
    	model = ActivitySevenDayModel.Init()

	ActivitySevenDayLogic.start_countdown_time()
    end
end

--正常登录成功
function ActivitySevenDayLogic.open_activity_seven_day(forceShow)
	ActivitySevenDayModel.forceShow = forceShow
	ActivitySevenDayPanel.Create()
end

function ActivitySevenDayLogic.start_countdown_time()
	ActivitySevenDayLogic.stop_countdown_time()
	countdown_timer = Timer.New(function ()
		if not model then return end
		ActivitySevenDayLogic.update_countdown_time()
	end, 1, -1)
	countdown_timer:Start()
end

function ActivitySevenDayLogic.stop_countdown_time()
	print("<color=red>EEE stop_countdown_time</color>")
	if countdown_timer ~= nil then
		countdown_timer:Stop()
		countdown_timer = nil
	end
end

local format_time = function (second)
	local timeDay = math.floor(second/(3600 * 24))
	local timeHour = math.fmod(math.floor(second/3600), 24)
	local timeMinute = math.fmod(math.floor(second/60), 60)
	return string.format("%02d天%02d小时%02d分", timeDay, timeHour, timeMinute)
end
function ActivitySevenDayLogic.update_countdown_time()
	local countdown = model.GetCountdownTime()
	if countdown > 0 then
		countdown = countdown - 1
		model.SetCountdownTime(countdown)

		local param = {}
		param.timer = format_time(countdown)

		Event.Brocast("seven_day_task_countdown_time", param)
	else
		if countdown == 0 then
			model.SetCountdownTime(-2)
			Event.Brocast("seven_day_task_over", 0)
		end
	end

	if model.IsNewVersion() then
		if ActivitySevenDayLogic.CheckAllTaskFinish() then
			Event.Brocast("seven_day_task_over", 1)
		end
	end
end

function ActivitySevenDayLogic.CheckAllTaskFinish()
	local TASK_ID = 61
	local task_data = GameTaskModel.GetTaskDataByID(TASK_ID)
	if not task_data then return false end

	if task_data.now_total_process < 7 then return false end
	local award_status = basefunc.decode_task_award_status(task_data.award_get_status)

	local days = {1,3,5,7}
	for k, v in ipairs(days) do
		local task_idx = ActivitySevenDayNewPanel.DayToTaskIdx(v)
		if not award_status[task_idx] then
			return false
		end
	end

	return true
end
