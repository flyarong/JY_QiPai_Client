local basefunc = require "Game/Common/basefunc"
CommonHuxiAnim = {}
local M = CommonHuxiAnim
    
local this
local lister
local CurrIndex = 0
local Timers = {}
local Objs = {}
local BeforeScale = {}
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
	lister["ExitScene"] = M.ExitScene
    lister["OnLoginResponse"] = this.OnLoginResponse
    lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed
    lister["global_hint_state_set_msg"] = this.on_global_hint_state_set_msg
end

function M.Init()
	M.Exit()
	this = CommonHuxiAnim
	MakeLister()
    AddLister()
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

--[[
    obj:预制体
    space:从最小到最大的时间间隔
    min:相对初始大小的最小比值
    max:相对初始大小的最大比值
]]
function M.Start(obj,space,min,max)
    min = min or 0.95
    max = max or 1.05
    space = space or 1.6
    local base_scale = obj.transform.localScale
    local loop_scale = base_scale
    local cha = max - min
    if cha <= 0 then
        cha = 0 - cha
    end
    --单帧变化大小
    local speed = cha * 0.02/space
    local diraction = 1
    local t = Timer.New(function ()
        if IsEquals(obj) then
            if  base_scale.x * max < loop_scale.x then
                diraction = -1
            end
            if  base_scale.x * min > loop_scale.x then
                diraction = 1
            end
            loop_scale = M.Vector3Add(loop_scale,M.Vector3Mul(base_scale,diraction * speed))
            obj.transform.localScale = loop_scale
        end
    end,0.02,-1)
    t:Start()
    Timers[#Timers + 1] = t
    BeforeScale[#BeforeScale + 1] = base_scale
    Objs[#Objs + 1] = obj
    return #Timers
end

function M.Stop(index,scale)
    if index and Timers[index] and IsEquals(Objs[index]) and BeforeScale[index] then
        Timers[index]:Stop()
        Objs[index].transform.localScale = scale or BeforeScale[index]
    end
end

function M.ExitScene()
    for k ,v in pairs(Timers) do
        if v then 
            v:Stop()
        end
    end
    Objs = {}
    Timers = {}
    BeforeScale = {}
end

function M.Vector3Add(v1,v2)
    return Vector3.New(v1.x + v2.x,v1.y + v2.y,v1.z + v2.z)
end

function M.Vector3Mul(v1,num)
    return Vector3.New(v1.x * num,v1.y * num,v1.z * num)
end

function M.Go(obj,space,min,max)
    min = min or 0.95
    max = max or 1.05
    space = space or 1.6
    local base_scale = obj.transform.localScale
    local loop_scale = base_scale
    local cha = max - min
    if cha <= 0 then
        cha = 0 - cha
    end
    --单帧变化大小
    local speed = cha * 0.02/space
    local diraction = 1
    local t = Timer.New(function ()
        if IsEquals(obj) then
            if  base_scale.x * max < loop_scale.x then
                diraction = -1
            end
            if  base_scale.x * min > loop_scale.x then
                diraction = 1
            end
            loop_scale = M.Vector3Add(loop_scale,M.Vector3Mul(base_scale,diraction * speed))
            obj.transform.localScale = loop_scale
        end
    end,0.02,-1)
    Timers[#Timers + 1] = t
    local index = #Timers
    BeforeScale[#BeforeScale + 1] = base_scale
    Objs[#Objs + 1] = obj
    return {Stop = function()
        M.Stop(index)
    end,Start = function()
        t:Start()
    end}
end