-- 创建时间:2018-11-06
-- 条件管理器

local config = SysConditionManager.config

ConditionManager = {}

local this
local UpdateTimer
local lister
local InformList = {}

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
end

function ConditionManager.Init()
	ConditionManager.Exit()
	print("<color=red>初始化条件管理器</color>")
	this = ConditionManager

    MakeLister()
    AddLister()

    this.Config={
        config={},
    }
    this.Config.config = config.config
end
function ConditionManager.Exit()
	if this then
		RemoveLister()
		this = nil
	end
end

local checkRange = function (val, min, max)
	if (min == -1 or val >= min) and (max == -1 or val <= max) then
		return true
	end
	return false
end
-- 条件是否满足
local IsCondition = function (id)
	if not id then
		return true
	end
	local data = this.Config.config[id]
	if not data then
		dump(id, "<color=red>条件ID不存在</color>")
		return true
	end
	if data.ct_type == "honor" then
		local v = GameHonorModel.GetCurHonorValue()
		return checkRange(v, data.min_val, data.max_val)
	elseif data.ct_type == "vip" then
		return false
	elseif data.ct_type == "jing_bi" then
		local v = MainModel.UserInfo.jing_bi or 0
		return checkRange(v, data.min_val, data.max_val)
	else
		dump(data, "<color=red>条件类型不存在</color>")
		return true
	end
end
-- id:条件ID  ishint:是否在不满足条件是弹出提示框
function ConditionManager.CheckCondition(id, ishint)
	local b = IsCondition(id)
	ishint = ishint or 0
	if not b and ishint > 0 then
		local data = this.Config.config[id]
		if ishint == 1 then
			LittleTips.Create(data.hint_desc)
		else
			HintPanel.Create(1, data.hint_desc)
		end
	end
	return b
end

function ConditionManager.GetConditionToID(id)
	local data = this.Config.config[id]
	return data
end
