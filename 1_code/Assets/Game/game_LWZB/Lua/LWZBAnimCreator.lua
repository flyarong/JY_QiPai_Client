-- 创建时间:2020-12-03
-- LWZBAnimCreator 管理器

local basefunc = require "Game/Common/basefunc"
LWZBAnimCreator = {}
local cur_path = "Game.game_LWZB.Lua."
local M = LWZBAnimCreator
M.config = ext_require(cur_path .. "lwzb_anim_config")
M.Timer = {}
local this
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
    lister["ExitScene"] = M.ExitScene
end

function M.Init()
    M.Timer = {}
    this = LWZBAnimCreator
    MakeLister()
    AddLister()
end

function M.Exit()
    if this then
        RemoveLister()
        this = nil
    end
end

function M.ExitScene()
    for i = 1,#M.Timer do
        if M.Timer[i] then
            M.Timer[i]:Stop() 
        end
    end
    M.Timer = {}
end

function M.PlayAnim(animator,group_id,backcall)

    local clips_todo = {}
    for i = 1,#M.config.AnimGroup[group_id].AnimClips do
        local data = {}
        data.clipname = M.GetClipConfigByID(M.config.AnimGroup[group_id].AnimClips[i]).ClipName
        data.delay_t = M.GetClipConfigByID(M.config.AnimGroup[group_id].AnimClips[i]).AnimLen
        clips_todo[#clips_todo + 1] = data
    end
    local all_data = {}
    all_data.now_index = 1
    all_data.backcall = backcall
    all_data.animator = animator
    all_data.group_id = group_id
    all_data.clips_todo = clips_todo
    dump(all_data,"all_data+++++++++++++++++++++++++++++")
    M.RunAnim(all_data)
end

function M.RunAnim(all_data)
    if all_data.now_index == 1 then
        all_data.animator:Play(all_data.clips_todo[all_data.now_index].clipname)
        all_data.now_index = all_data.now_index + 1
        M.RunAnim(all_data)
    elseif all_data.now_index <= #all_data.clips_todo then
        M.TimerCreator(function ()
            all_data.animator:Play(all_data.clips_todo[all_data.now_index].clipname)
            all_data.now_index = all_data.now_index + 1
            M.RunAnim(all_data)
        end,all_data.clips_todo[all_data.now_index - 1].delay_t,1)
    else
        M.TimerCreator(function ()
            if all_data.backcall then
                all_data.backcall()
            end
        end,all_data.clips_todo[all_data.now_index - 1].delay_t,1)
    end
end

function M.GetClipConfigByID(id)
    return M.config.AnimClip[id]
end

function M.TimerCreator(func,delay_t,run_times)
    local timer = Timer.New(
        function ()
            func()
        end
    ,delay_t,run_times,nil,true)
    M.Timer[#M.Timer + 1] = timer
    timer:Start()
end


--用于动画持续时长不定的情况
function M.PlayAnim_TimeNotSure(animator,group_id,time_tab,backcall)
    local clips_todo = {}
    for i = 1,#M.config.AnimGroup[group_id].AnimClips do
        local data = {}
        data.clipname = M.GetClipConfigByID(M.config.AnimGroup[group_id].AnimClips[i]).ClipName
        data.delay_t = time_tab[i]
        clips_todo[#clips_todo + 1] = data
    end
    local all_data = {}
    all_data.now_index = 1
    all_data.backcall = backcall
    all_data.animator = animator
    all_data.group_id = group_id
    all_data.clips_todo = clips_todo
    dump(all_data,"all_data+++++++++++++++++++++++++++++")
    M.RunAnim(all_data)
end