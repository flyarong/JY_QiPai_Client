-- 创建时间:2020-08-21
-- Act_027_ZNQGManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_027_ZNQGManager = {}
local M = Act_027_ZNQGManager
M.key = "act_027_znqg"
M.config = GameButtonManager.ExtLoadLua(M.key,"activity_exchange_server")
GameButtonManager.ExtLoadLua(M.key,"Act_027_ZNQGPanel")
GameButtonManager.ExtLoadLua(M.key,"Act_027_ZNQGEnterPrefab")
local this
local lister
M.e_time = 1600696800
M.s_time = 1600126200
-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    if (M.e_time and os.time() > M.e_time) or (M.s_time and os.time() < M.s_time) then
        return false
    end
	return true
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
        if M.IsActive() then 
            return Act_027_ZNQGPanel.Create(parm.parent,parm.backcall)
        end 
    end 
    if parm.goto_scene_parm == "enter" then
        return Act_027_ZNQGEnterPrefab.Create(parm.parent)
    end
    --dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
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
	lister["query_activity_exchange_response"] = this.on_query_activity_exchange_response
    lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed
    lister["global_hint_state_set_msg"] = this.on_global_hint_state_set_msg
end

function M.Init()
	M.Exit()

	this = Act_027_ZNQGManager
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
	for i = 1,#M.config.main do
		if M.config.main[i].enable == 1 then
			if os.time() >= M.config.main[i].start_time and os.time() <= M.config.main[i].end_time then
				this.UIConfig[#this.UIConfig + 1] = M.config.main[i]
			end
		end
	end
	
end

function M.OnLoginResponse(result)
	if result == 0 then
		-- 数据初始化
		if  M.IsActive() then
			M.UpDateLocalInfo()
			M.UpdateData()
		end
	end
end

function M.OnReConnecteServerSucceed()

end


function M.GetAwardData(id)
	if id then
		local data = {}
		for i = 1,#M.config.award do
			if M.config.award[i].award_cfg_id == id then
				--dump(M.config.award[i],"<color=red>FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF</color>")
				data[#data+1] = M.config.award[i]
			end
		end
		return data
	end
end


function M.GetIndex()
	if os.time()> M.e_time or os.time() < M.s_time then 
		--print("不在活动时间内")
		return  false
	end 
	for i = 1, #this.UIConfig do
		if os.time() < M.GetDurTime(this.UIConfig[i].day_end) and os.time() > M.GetDurTime(this.UIConfig[i].day_start) then
			return i,this.UIConfig[i]
		end 
	end
	return  false
end

function M.GetUIConfig()
	return this.UIConfig
end

function M.GetBaseData()
	local i,data = M.GetIndex()
	if i then
		return data
	end
end

function M.GetDurTime(x)
	--dump(debug.traceback())
	local t=os.time() + 8*60*60
	local f=math.floor(t/86400)
	return f*86400 + x -8*60*60
end

--获取当前状态
--M.Status = 1 处于售卖状态中
--M.Status = 2 最后一天，并且已经过了最后一次售卖时间了
--M.Status = 3 未处于售卖状态中，并且第一次的售卖还未开始
--M.Status = 4 未处于售卖状态中，并且是在第一次售卖完成后，最后一次售卖开始前
--M.Status = 5 未处于售卖状态中，处于最后一次售卖后到第二天售卖开始前
function M.SetInfo()
	local UIConfig = M.GetUIConfig()
	--dump(UIConfig,"<color=red>XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX</color>")
	if table_is_null(UIConfig) then return end
	local base_data = M.GetBaseData()
	--dump(base_data,"<color=red>XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX</color>")
	if base_data then
		M.Status = 1
		local str  = os.date("%H时%M分%S秒",M.GetDurTime(base_data.day_end) - os.time() + 16 * 3600)
		M.t1 = "距本轮结束:"..str
		--dump(M.GetIndex(),"<color=red>OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO</color>")
		M.StatusIndex = M.GetIndex()
		M.enterStr = str
	elseif os.time() > M.GetDurTime(UIConfig[#UIConfig].day_end) and os.time() + 86400 > M.e_time then -- 最后一次
		M.Status = 2
		M.t1 = "活动已经结束啦~"
		M.t2 = "活动已经结束啦~"
		M.StatusIndex = M.GetIndex()
	else
		for i = 1,#UIConfig do
			if i == 1 and os.time() <=M.GetDurTime(UIConfig[i].day_start) then
				M.Status = 3
				M.t1 = "距下轮开启:"..os.date("%H时%M分%S秒",M.GetDurTime(UIConfig[i].day_start) - os.time() + 16*3600)
				M.t2 = "距离开抢:"..StringHelper.formatTimeDHMS(M.GetDurTime(UIConfig[i].day_start) - os.time())
				M.StatusIndex = 1
			end
			if i>=2 and os.time() <= M.GetDurTime(UIConfig[i].day_start) and os.time() >= M.GetDurTime(UIConfig[i - 1].day_end)  then
				M.Status = 4
				M.t1 = "距下轮开启:"..os.date("%H时%M分%S秒",M.GetDurTime(UIConfig[i].day_start)-os.time()+16*3600)
				M.t2 = "距离开抢:"..StringHelper.formatTimeDHMS(M.GetDurTime(UIConfig[i].day_start)-os.time())
				M.StatusIndex = i	
			end
			if os.time() >= M.GetDurTime(UIConfig[#UIConfig].day_end) then
				M.Status = 5
				M.t1="距下轮开启:"..os.date("%H时%M分%S秒",M.GetDurTime(UIConfig[1].day_start)+86400-os.time()+3600*16)
				M.t2="距离开抢:"..StringHelper.formatTimeDHMS(M.GetDurTime(UIConfig[1].day_start)+86400-os.time())
				M.StatusIndex = 1
			end
		end
	end
end

function M.UpDateLocalInfo()
	if this.MainTimer then
		this.MainTimer:Stop()
	end
	M.SetInfo()
	this.MainTimer = Timer.New(
		function ()
			if M.IsActive() then
				M.SetInfo()
			end
		end
	,1,-1)
	this.MainTimer:Start()
end

function M.UpdateData()
	if this.MainTimer_2 then
		this.MainTimer_2:Stop()
	end
	local send_func = function()
		local d = M.GetBaseData()
		if M.IsActive() and d then
			Network.SendRequest("query_activity_exchange",{type = d.id})
		end
	end
	send_func()
	this.MainTimer_2 = Timer.New(
		function ()
			send_func()
		end
	,5,-1)
	this.MainTimer_2:Start()
end

function M.on_query_activity_exchange_response(_,data)
	if data.result == 0 then
		this.data = this.data or {}
		this.data[data.type] = data
		Event.Brocast("act_027_znqg_get_new_info")
	end
end

function M.GetData()
	return this.data
end
