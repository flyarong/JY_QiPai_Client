-- 创建时间:2018-11-06
AchievementTGManager = {}
local M = AchievementTGManager
M.key = "sys_cfzx"
local achievement_tg_cfg = GameButtonManager.ExtLoadLua(M.key, "achievement_tg_config")
GameButtonManager.ExtLoadLua(M.key, "AchievementTGInvitePanel")
GameButtonManager.ExtLoadLua(M.key, "AchievementTGCenterPanel")
GameButtonManager.ExtLoadLua(M.key, "AchievementPointAwardPanel")
GameButtonManager.ExtLoadLua(M.key, "AchievementTGTestPanel")
   

local basefunc = require "Game.Common.basefunc"
local config = {}
local M = AchievementTGManager
local task_ids = {69,70,71,72,73}
local task_data = {}
local lister
local this
local m_data
local function MakeLister()
	lister = {}
    lister["OnLoginResponse"] = this.OnLoginResponse

	lister["model_query_one_task_data_response"] =  this.on_get_data
	lister["model_task_change_msg"] = this.on_get_data  
	lister["model_get_task_award_response"] = this.on_model_get_task_award_response
end

local function AddLister()
    for msg,cbk in pairs(lister) do
        Event.AddListener(msg, cbk)
    end
end
local function RemoveLister()
    if lister == nil then return end
    for msg,cbk in pairs(lister) do
        Event.RemoveListener(msg, cbk)
    end
    lister=nil
end
local function InitData()
	M.data={}
	m_data = M.data
end
function M.Init()
    M.Exit()
    print("<color=red>推广成就>>>>>>>>>>>>>>>>>>>>>>>>>>>></color>")
    this=M
    InitData()
    MakeLister()
	AddLister()
	config = M.InitCfg()
    return this
end

function M.Exit()
    if this then
        RemoveLister()
        m_data=nil
        this=nil
    end
end

function M.InitCfg()
	return achievement_tg_cfg
end

--在min到max中，随机选择num个数字，组成数组,min 默认是 1
function M.GetRandomList(_num,_max,set_seed_by_sec,_min)
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
	if set_seed_by_sec then
		math.randomseed(os.time())
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
--CJD = 成就点
function M.Get_Title_By_PlayerCJD(cjd_num)
	if cjd_num >= config.level[#config.level].need then return config.level[#config.level].title end 
	for i=1,#config.level do
		if cjd_num>= config.level[i].need and cjd_num < config.level[i+1].need then 
			return config.level[i].title
		end 
	end
	return  config.level[1].title
end

function M.GetCurrLevel()
	if task_data[69] then
		local data = task_data[69].now_lv - 1
		if data == 0 then data = 0 end
		if data > #achievement_tg_cfg.level then data = #achievement_tg_cfg.level end
		return data
	end
	return	1 
end

function M.GetCurrPoint()
    if task_data[69] then
		return task_data[69].now_total_process
	end 
	return	0 
end

function M.on_get_data(data)
	M.GetTaskInfo()
	if M.IsIncluded(task_ids,data.id) then	
		Event.Brocast("Refresh_TG_Achievement_Btn")
	end 	
end

function M.GetTaskInfo()
	for i=1,#task_ids do
		local data = GameTaskModel.GetTaskDataByID(task_ids[i])
		--dump(data,"<color=red>成就系统任务</color>")
		task_data[task_ids[i]] = data
	end
end

function M.IsIncluded(_table,_item)
	for i=1,#_table do
		if _table[i] == _item then 
			return  true
		end
	end
	return  false
end

function M.GetTaskDataByID(ID)
	return task_data[ID]
end


function M.on_model_get_task_award_response(_,data)
	
end

function M.GetMatchStatus()
	if task_data[71] then
		return task_data[71].award_status
	end
	return	0 
end

function M.GetGiftStatus()
	if task_data[72] then
		return task_data[72].award_status
	end 
	return	0 
end

function M.GetFAQStatus()
	if task_data[73] then
		return task_data[73].award_status
	end 
	return	0 
end

function M.GetAwardStatusTable()
	dump(task_data[69],"<color=red>成就总任务</color>")
	if 	task_data[69] == nil then return end 
	local temp  = basefunc.decode_task_award_status(task_data[69].award_get_status)
	local data = basefunc.decode_all_task_award_status(temp,task_data[69],#config.level)
	return data
end

function M.OnLoginResponse(result)
	if result==0 then
		M.GetTaskInfo()
    end
end
-- 
M.Init()