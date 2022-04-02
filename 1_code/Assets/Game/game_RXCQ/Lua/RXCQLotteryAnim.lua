local basefunc = require "Game/Common/basefunc"
RXCQLotteryAnim = basefunc.class()
local M = RXCQLotteryAnim
local lister = {}
local prefabs = {}
local curr_index = 1
local over_times = 0
local yunsu_times = 0
local PaoDong_Config = {
    [1] = {time_space = 0.2,times = 1,audio_func = 1},
    [2] = {time_space = 0.1,times = 1,audio_func = 1},
    [3] = {time_space = 0.05,times = 1,audio_func = 1},
    [4] = {time_space = 0.02,times = "get_len_func",audio_func = 2},
    [5] = {time_space = 0.1,times = 1,audio_func = 1},
    [6] = {time_space = 0.3,times = 1,audio_func = 1},
    [7] = {time_space = 0.5,times = "get_over_times",audio_func = 1}
}

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

function M.Init(p)
    prefabs = p
	MakeLister()
    AddLister()
end

function M.Exit()
	if this then
		RemoveLister()
		this = nil
	end
end

function M.PaoDong(speed,times,overcall,audio_func)
    local index = curr_index or 1
    local times_index = 0
    local t1 = Timer.New(
        function()
            M.PlayerPaoDongAudio(audio_func)
            if M.IsChangLiang(index) then
                prefabs[index]:ChangLiang()
            else
                prefabs[index]:ShowPaoDong(speed)
            end
			index = index + 1
			if index > #prefabs then
				index = 1
            end
            curr_index = index
            times_index = times_index + 1
            if times_index == times then
                if overcall then
                    overcall()
                end
            end
		end,0.2 / speed,times,nil,true
	)
	t1:Start()
    RXCQModel.AddTimers(t1)
end

function M.ShanDong(index)
    ExtendSoundManager.PlaySound(audio_config.rxcq.rxcq_Select.audio_name)
    prefabs[index or curr_index]:ShowXuanZhong()
end

function M.StartLottery(over_index)
    M.CreateRandomLine(over_index)
    local t1 = Timer.New(function()
        M.ReSetShow()
    end,PaoDong_Config[1].time_space,1,nil,true)
    t1:Start()
    RXCQModel.AddTimers(t1)
    local func
    func = function(now)
        if now <= #PaoDong_Config then
            local speed = 0.2 / PaoDong_Config[now].time_space
            local times
            if type(PaoDong_Config[now].times) == "number" then
                times = PaoDong_Config[now].times
            else
                times = M[PaoDong_Config[now].times]()
            end
            local overcall = function()
                func(now + 1)
            end
            M.PaoDong(speed,times,overcall,PaoDong_Config[now].audio_func)

        else
            local t1 = Timer.New(
                function()
                    M.ShanDong()   
                end
            ,PaoDong_Config[#PaoDong_Config].time_space,1,nil,true)
            t1:Start()
            RXCQModel.AddTimers(t1)
        end
    end
    func(1)
end

function M.get_over_times()
    return over_times
end

function M.get_len_func()
    return yunsu_times
end

function M.ReSetShow()
	for i = 1,#prefabs do
		prefabs[i]:ReSetShow()
	end
end

local ChangLiang = {}
function M.SetChangLiang(index)
    ChangLiang[#ChangLiang + 1] = index
    dump(ChangLiang,"<color=red> ChangLiang </color>")
end

function M.ClearChangLiang()
    ChangLiang = {}
end

function M.IsChangLiang(index)
    for i = 1,#ChangLiang do
        if index == ChangLiang[i] then
            return true
        end
    end
    return false
end

function M.CreateRandomLine(over_index)
    over_times = math.random(2,5)
    local func = function()
        local sum = 0
        for i = 1,#PaoDong_Config do
            if type(PaoDong_Config[i].times) == "number" then
                sum = sum + 1
            end
        end
        return sum
    end
    local re = {}
    local _re = {}
    for i = 1,6 do
        _re[#_re + 1] = over_index + i * #prefabs - curr_index - over_times - func()
    end
    for i = 1,#_re do
        if _re[i] <= 60 and _re[i] >= 36 then
            re[#re + 1] = _re[i]
        end
    end
    yunsu_times = re[math.random(1,#re)]
end

local yunxu_audio_key
local last_type
local is_can_paly_1 = true

local player_yunxu_audio_func = function()
    yunxu_audio_key = ExtendSoundManager.PlaySound(audio_config.rxcq.rxcq_turning.audio_name,1,function()
        is_can_paly_1 = true
    end)   
end

local stop_yunxu_audio_func = function()
    ExtendSoundManager.CloseSound(yunxu_audio_key)
end

function M.PlayerPaoDongAudio(_type)
    if last_type == _type and _type == 2 then
        return
    end
    last_type = _type
    if _type == 1 and is_can_paly_1 == true then
        --stop_yunxu_audio_func()
        ExtendSoundManager.PlaySound(audio_config.rxcq.rxcq_start.audio_name)
    elseif _type == 2 then
        is_can_paly_1 = false
        player_yunxu_audio_func()
    end
end 

--先确定最终是随机多少个格子 
--根据结果反推计算应该匀速多个格子再减速（控制最后一个格子的落点）
