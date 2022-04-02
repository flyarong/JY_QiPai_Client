-- 创建时间:2019-01-03
local free_activity_one_config
local operator_activity_one_config
local free_activity_two_config
local operator_activity_two_config
if AppDefine.IsEDITOR() then
    free_activity_one_config = GameButtonManager.ExtLoadLua(SysActOperatorManager.key, "free_activity_one_config")
    operator_activity_one_config = GameButtonManager.ExtLoadLua(SysActOperatorManager.key, "operator_activity_one_config")
    free_activity_two_config = GameButtonManager.ExtLoadLua(SysActOperatorManager.key, "free_activity_two_config")
    operator_activity_two_config = GameButtonManager.ExtLoadLua(SysActOperatorManager.key, "operator_activity_two_config")
else
    free_activity_one_config = LocalDatabase.LoadFileDataToTable(gameMgr:getLocalPath("localconfig/free_activity_one_config.lua"))
        free_activity_two_config = LocalDatabase.LoadFileDataToTable(gameMgr:getLocalPath("localconfig/free_activity_two_config.lua"))
		operator_activity_one_config = LocalDatabase.LoadFileDataToTable(gameMgr:getLocalPath("localconfig/operator_activity_one_config.lua"))
		operator_activity_two_config = LocalDatabase.LoadFileDataToTable(gameMgr:getLocalPath("localconfig/operator_activity_two_config.lua"))

    if not free_activity_one_config then
    	free_activity_one_config = GameButtonManager.ExtLoadLua(SysActOperatorManager.key, "free_activity_one_config")
    end
    if not operator_activity_one_config then
    	operator_activity_one_config = GameButtonManager.ExtLoadLua(SysActOperatorManager.key, "operator_activity_one_config")
    end
    if not free_activity_two_config then
    	free_activity_two_config = GameButtonManager.ExtLoadLua(SysActOperatorManager.key, "free_activity_two_config")
    end
    if not operator_activity_two_config then
    	operator_activity_two_config = GameButtonManager.ExtLoadLua(SysActOperatorManager.key, "operator_activity_two_config")
    end
end

OperatorActivityModel = {}
local M = OperatorActivityModel
ActivityType = {
	DuiJuHongBao = 1,
	Consecutive_Win = 2,
	TianJiangCaiShen = 3,
}

local this
local m_data
local lister
local isBannerShown = false

local function AddLister()
    for msg,cbk in pairs(lister) do
        Event.AddListener(msg, cbk)
    end
end

local function RemoveLister()
    for msg,cbk in pairs(lister) do
        Event.RemoveListener(msg, cbk)
    end
    lister=nil
end
local function MakeLister()
    lister={}
end

-- 初始化Data
local function InitMatchData()
    M.data={
    }
    m_data = M.data
end

function M.Init()
    this = M
    InitMatchData()
    MakeLister()
    AddLister()
    this.InitUIConfig()
    return this
end
function M.Exit()
    if this then
        RemoveLister()
        lister=nil
        this=nil
    end
end

local function parse_config(free_activity_config)
	local free_activity = {}
	for k,v in ipairs(free_activity_config.config) do
		local da1 = {}
		free_activity[v.game_id] = da1
		da1.game_id = v.game_id
		da1.activity_list = {}
		if v.activity_list then
			for k1,v1 in ipairs(v.activity_list) do
				local cfg1 = free_activity_config.activity[v1]
				local da2 = {}
				da2.activity_id = cfg1.activity_id
				da2.time_desc = cfg1.time_desc
				da2.activity_time = {}
				if cfg1.activity_time then
					local str1 = StringHelper.Split(cfg1.activity_time, "#")
					for k2,v2 in ipairs(str1) do
						if v2 and v2 ~= "" then
							local str2 = StringHelper.Split(v2, "+")
							da2.activity_time[#da2.activity_time+1] = {}
							da2.activity_time[#da2.activity_time].begin_time = tonumber(str2[1])
							da2.activity_time[#da2.activity_time].end_time = tonumber(str2[2])
							if not da2.activity_time[#da2.activity_time].end_time then
							end
						end
					end
				end

				da2.activity_award = {}
				da2.activity_parm = {}
				if cfg1.activity_award then
					for k2,v2 in ipairs(cfg1.activity_award) do
						local cfg2 = free_activity_config.award[v2]
						local str3 = StringHelper.Split(cfg2.activity_award, "#")
						local da3 = {}
						da2.activity_award[#da2.activity_award+1] = da3
						for k3,v3 in ipairs(str3) do
							local str4 = StringHelper.Split(v3, "+")
							da3[#da3+1] = {}
							da3[#da3].asset_type = str4[1]
							da3[#da3].value = tonumber(str4[2])
						end
						local da4 = {}
						da2.activity_parm[#da2.activity_parm+1] = da4
						local str5 = StringHelper.Split(cfg2.activity_parm, "#")
						for k3,v3 in ipairs(str5) do
							local str6 = StringHelper.Split(v3, "+")
							if tonumber(str6[2]) then
								da4[str6[1]] = tonumber(str6[2])
							else
								da4[str6[1]] = str6[2]
							end
						end
					end			
				end
				if cfg1.ext_award then
					da2.ext_award = {}
					for k2,v2 in ipairs(cfg1.ext_award) do
						local cfg2 = free_activity_config.ext_award[v2]
						local str3 = StringHelper.Split(cfg2.activity_award, "#")
						local da3 = {}
						da2.ext_award[#da2.ext_award+1] = da3
						for k3,v3 in ipairs(str3) do
							local str4 = StringHelper.Split(v3, "+")
							da3[#da3+1] = {}
							da3[#da3].asset_type = str4[1]
							da3[#da3].value = tonumber(str4[2])
						end
					end
				end
				da1.activity_list[#da1.activity_list+1] = da2
			end		
		end
	end
	return free_activity
end
function M.InitUIConfig()
	this.Config = {}
	this.Config.one_activity_config = {}
	this.Config.one_free_activity = {}
	this.Config.two_activity_config = {}
	this.Config.two_free_activity = {}
	for k,v in ipairs(operator_activity_one_config.config) do
		this.Config.one_activity_config[v.id] = v
	end
	for k,v in ipairs(operator_activity_two_config.config) do
		this.Config.two_activity_config[v.id] = v
	end
	this.Config.one_free_activity = parse_config(free_activity_one_config)
	this.Config.two_free_activity = parse_config(free_activity_two_config)
end

-- 根据匹配场ID获取活动列表
function M.GetActivityConfig(activity_id)
	if not StringHelper.is_double_week() then
		if this and this.Config and this.Config.one_activity_config then
			return this.Config.one_activity_config[activity_id]
		else
			return nil
		end
	else
		if this and this.Config and this.Config.one_activity_config then
			return this.Config.two_activity_config[activity_id]
		else
			return nil
		end
	end
end

-- 根据匹配场ID获取活动列表
function M.GetActivityList(id)
	if not StringHelper.is_double_week() then
		if this.Config.one_free_activity[id] then
			return this.Config.one_free_activity[id].activity_list
		end
	else
		if this.Config.two_free_activity[id] then
			return this.Config.two_free_activity[id].activity_list
		end
	end
end

-- 根据匹配场ID和活动ID获取活动
function M.GetActivity(id, activity_id)
	local data = M.GetActivityList(id)
	if data then
		for k,v in ipairs(data) do
			if v.activity_id == activity_id then
				return v
			end
		end
	end
end

-- 根据匹配场ID获取当前进行中的活动
function M.GetActivityUnderway(id)
	local activity_config
	if not StringHelper.is_double_week() then
		activity_config = this.Config.one_activity_config
	else
		activity_config = this.Config.two_activity_config
	end

	local data = M.GetActivityList(id)
	local curt = os.time()
	local onet = StringHelper.getThisWeekMonday()
	if data then
		for k,v in ipairs(data) do
			if activity_config[v.activity_id].isOnOff==1 then
				for k1,v1 in ipairs(v.activity_time) do
					local t1 = v1.begin_time + onet
					local t2 = v1.end_time + onet
					if t1 <= curt and curt < t2 then
						return v
					end
				end
			end
		end
	end
end

function M.IsActivated(gameId, activityId)
	local ret = false
	local ac = M.GetActivityConfig(activityId)
	if ac then
		local config = M.GetActivity(gameId, activityId)
		if config and ac.isOnOff == 1 then
			local curT = os.time()
			local monT = StringHelper.getThisWeekMonday()
			for _, t in ipairs(config.activity_time) do
				local st = t.begin_time + monT
				local et = t.end_time + monT
				if curT >= st and curT < et then
					ret = true
					break
				end
			end
		end
	end
	return ret
end

function M.GetActivatedActivityList()
	local data = {}
	if this then
		local ac = this.Config.one_activity_config
		if StringHelper.is_double_week() then
			ac = this.Config.two_activity_config
		end

		for _, cfg in ipairs(ac) do
			if cfg.isOnOff == 1 then
				data[#data + 1] = {id = cfg.id, activated = 0, icon = cfg.ad_icon, desc = cfg.ad_desc}
			end
		end

		local fa = this.Config.one_free_activity
		if StringHelper.is_double_week() then
			fa = this.Config.two_free_activity
		end

		for _, d in ipairs(data) do
			local isActivated = 0
			for _, list in ipairs(fa) do
				for _, act in ipairs(list.activity_list) do
					if act.activity_id == d.id and M.IsActivated(list.game_id, act.activity_id) then
						isActivated = 1
						break
					end
				end

				if isActivated == 1 then
					break
				end
			end

			d.activated = isActivated
		end
	end

	--dump(ac, "<color=yellow>M.GetActivatedActivityList:</color>")
	--dump(fa, "<color=yellow>M.GetActivatedActivityList:</color>")
	--dump(data, "<color=yellow>M.GetActivatedActivityList: isDoubleWeek:" .. (StringHelper.is_double_week() and "Yes" or "No") .. "</color>")

	return data
end

function M.IsBannerShown()
	return isBannerShown
end

function M.SetShowBannerDone()
	isBannerShown = true
end

-- 根据匹配场ID获取对应活动的状态
function M.GetActivityStateByFreeID(id)
	local activity_config
	if not StringHelper.is_double_week() then
		activity_config = this.Config.one_activity_config
	else
		activity_config = this.Config.two_activity_config
	end

	local list = M.GetActivityList(id)
	local curt = os.time()
	local onet = StringHelper.getThisWeekMonday()

	local data = {}
	if list then
		for k,v in ipairs(list) do
			local upt2 = onet
			local isb = false
			if v.activity_time and next(v.activity_time) then
				for k1,v1 in ipairs(v.activity_time) do
					local t1 = v1.begin_time + onet
					local t2 = v1.end_time + onet
					if t1 <= curt and curt < t2 then
						local da1 = {}
						da1.begin_time = t1
						da1.end_time = t2
						da1.time_desc = v.time_desc
						da1.activity_id = v.activity_id
						if activity_config[v.activity_id].isOnOff == 1 then
							da1.state = "yes"
							data[#data + 1] = da1
						else
							da1.state = "close"
						end
						da1.activity_config = activity_config[v.activity_id]
						isb = true
						break
					else
						if upt2 <= curt and curt < t1 then
							local da1 = {}
							da1.begin_time = t1
							da1.end_time = t2
							da1.time_desc = v.time_desc
							da1.activity_id = v.activity_id
							if activity_config[v.activity_id].isOnOff == 1 then
								da1.state = "no"
								data[#data + 1] = da1
							else
								da1.state = "close"
							end
							da1.activity_config = activity_config[v.activity_id]
							isb = true
							break
						end
					end
					upt2 = t2
				end
				if not isb then
					local da1 = {}
					da1.begin_time = 0
					da1.end_time = 0
					da1.time_desc = v.time_desc
					da1.activity_id = v.activity_id
					if activity_config[v.activity_id].isOnOff == 1 then
						da1.state = "no"
						data[#data + 1] = da1
					else
						da1.state = "close"
					end
					da1.activity_config = activity_config[v.activity_id]
				end
			else
				local da1 = {}
				da1.activity_id = v.activity_id
				da1.time_desc = v.time_desc
				da1.state = "close"
				da1.activity_config = activity_config[v.activity_id]
			end
		end
	end
	return data
end



