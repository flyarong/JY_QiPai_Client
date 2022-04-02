-- 创建时间:2019-03-28
FishingActivityManager = {}
local M = FishingActivityManager
local config = HotUpdateConfig("Game.normal_fishing_common.Lua.fish_activity_config")
package.loaded["Game.normal_fishing_common.Lua.FishingActivityBullet"] = nil
require "Game.normal_fishing_common.Lua.FishingActivityBullet"
package.loaded["Game.normal_fishing_common.Lua.FishingActivityTime"] = nil
require "Game.normal_fishing_common.Lua.FishingActivityTime"
package.loaded["Game.normal_fishing_common.Lua.FishingActivityBK"] = nil
require "Game.normal_fishing_common.Lua.FishingActivityBK"
package.loaded["Game.normal_fishing_common.Lua.FishingActivityZT"] = nil
require "Game.normal_fishing_common.Lua.FishingActivityZT"
package.loaded["Game.normal_fishing_common.Lua.FishingActivityDCP"] = nil
require "Game.normal_fishing_common.Lua.FishingActivityDCP"

--活动
local activity_map = {}
FISHING_ACTIVITY_ENUM = {
    free_bullet = "free_bullet",
    power_bullet = "power_bullet",
    crit_bullet = "crit_bullet",
    quick_shoot = "quick_shoot",
    shell_lottery = "shell_lottery",
    drill_bullet = "drill_bullet",
    pierce_bullet = "pierce_bullet",
    time_free_power_bullet = "time_free_power_bullet",
    laser_bullet = "laser_bullet",
}

FISHING_ACTIVITY_STATUS_ENUM = {
    begin = "begin",
    running = "running",
    over = "over",
}

FISHING_ACTIVITY_HINT_STATUS_ENUM = {
    free_bullet = 1,
    power_bullet = 2,
    crit_bullet = 3,
    quick_shoot = 4,
    shell_lottery = 5,
    drill_bullet = 6,
    pierce_bullet = 7,
    time_free_power_bullet = 8,
    laser_bullet = 9,
}

-- 活动对应的子弹类型
FISHING_BULLET_TYPE = {
    free_bullet = 1,
    power_bullet = 2,
    crit_bullet = 3,
    quick_shoot = 4,
    drill_bullet = 5,
    pierce_bullet = 6,
    time_free_power_bullet = 7,
}

local audio
function M.PlaySoundBGM(seat_num, data)
    if not audio then
        if not seat_num or (seat_num and seat_num == FishingModel.GetPlayerSeat()) then
            if data and (data.msg_type == FISHING_ACTIVITY_ENUM.shell_lottery
                        or data.msg_type == FISHING_ACTIVITY_ENUM.drill_bullet
                        or data.msg_type == FISHING_ACTIVITY_ENUM.laser_bullet) then
                return
            end
            ExtendSoundManager.PauseSceneBGM()
            audio = ExtendSoundManager.PlaySound(audio_config.by.bgm_by_huodong.audio_name,-1)    
        end
    end
end

function M.StopSoundBGM(seat_num)
    if audio and seat_num == FishingModel.GetPlayerSeat() then
        if not seat_num or (seat_num and seat_num == FishingModel.GetPlayerSeat()) then
            soundMgr:CloseLoopSound(audio)
            soundMgr:ContinuePlayBG()
            audio = nil
        end
    end
end

local lister
function M.MakeLister()
    lister = {}
    lister["fish_activity_recover"] = M.fish_activity_recover
    lister["fish_activity"] = M.fish_activity
    lister["fish_activity_exit_all"] = M.fish_activity_exit_all
    
    lister["activity_get_gold"] = M.activity_get_gold
    lister["activity_kill_fish"] = M.activity_kill_fish
    lister["activity_shoot"] = M.activity_shoot
    lister["activity_fish_gun_rotation"] = M.activity_fish_gun_rotation

    lister["model_fsg_leave_msg"] = M.on_fsg_leave_msg
    lister["ui_fsg_quit_game"] = M.ui_fsg_quit_game
    lister["fishing_activity_begin"] = M.fishing_activity_begin
end

function M.AddListener()
    M.MakeLister()
    for proto_name,func in pairs(lister) do
        Event.AddListener(proto_name, func)
    end
end

function M.RemoveListener()
    for proto_name,func in pairs(lister) do
        Event.RemoveListener(proto_name, func)
    end
end

function M.Init()
    config = M.InitConfig(config)
    M.AddListener()
    activity_map = {}
end

function M.Exit()
    M.RemoveListener()    
    M.fish_activity_exit_all()
end

function M.InitConfig(cfg)
    local _cfg = {}
    for _k,v in pairs(cfg.fish_activity_config) do
        _cfg[v.type] = _cfg[v.type] or {}
        _cfg[v.type].change_gun = v.change_gun
        _cfg[v.type].bullet_type = v.bullet_type
        _cfg[v.type].net_type = v.net_type
    end
    return _cfg
end

function M.fish_activity_recover(data)
    dump(data, "<color=green>断线重连S2C活动数据</color>")
    if data then
        local msg_type = data.msg_type
        local seat_num = data.seat_num
        local cfg = config[data.msg_type]
        local a_status,a_instance = M.GetStatusAndInstance(data)
        if a_status then
            if a_status == FISHING_ACTIVITY_STATUS_ENUM.begin then
                FishingModel.SendActivity(data)
                -- M.ActivityBegin(data,a_instance,cfg)
                -- Event.Brocast("activity_set_gun_level",data)
                -- M.PlaySoundBGM(seat_num)
            elseif a_status == FISHING_ACTIVITY_STATUS_ENUM.running then
                M.ActivityRefresh(data,a_instance,cfg)
                if data.msg_type ~= "drill_bullet" then
                    M.PlaySoundBGM(seat_num, data)
                end
                Event.Brocast("activity_set_gun_level",data)
            elseif a_status == FISHING_ACTIVITY_STATUS_ENUM.over then
                M.ActivityOver(data)
                if data.msg_type ~= "drill_bullet" then
                    M.StopSoundBGM(seat_num)
                end
                Event.Brocast("activity_over_msg", data)
            end
        end
    end
end

function M.fish_activity(data)
    dump(data, "<color=green>S2C活动数据</color>")
    if data then
        local msg_type = data.msg_type
        local seat_num = data.seat_num
        local cfg = config[data.msg_type]
        local a_status,a_instance = M.GetStatusAndInstance(data)
        if a_status then
            if a_status == FISHING_ACTIVITY_STATUS_ENUM.begin then
                M.ActivityBegin(data,a_instance,cfg)
                Event.Brocast("activity_set_gun_level",data)
                if data.msg_type ~= "drill_bullet" then
                    M.PlaySoundBGM(seat_num, data)
                end
            elseif a_status == FISHING_ACTIVITY_STATUS_ENUM.running then
                M.ActivityRefresh(data,a_instance,cfg)
                if data.msg_type ~= "drill_bullet" then
                    M.PlaySoundBGM(seat_num, data)
                end
                Event.Brocast("activity_set_gun_level",data)
            elseif a_status == FISHING_ACTIVITY_STATUS_ENUM.over then
                M.ActivityOver(data)
                if data.msg_type ~= "drill_bullet" then
                    M.StopSoundBGM(seat_num)
                end
                Event.Brocast("activity_over_msg", data)
            end
        end
    end
end

function M.fishing_activity_begin()
    print("<color=green>fishing_activity_begin</color>")
    for k,v in pairs(activity_map) do
        if M.CheckIsOnePlayerActiviey(k) then
            --个人活动
            for _k,_v in pairs(v) do
                if _v.ChangeGame and type(_v.ChangeGame) == "function" then
                    _v:ChangeGame()
                end
            end
        else
            if v.ChangeGame and type(v.ChangeGame) == "function" then
               v:ChangeGame()
            end
        end
    end
end

function M.fish_activity_exit_all()
    print("<color=green>fish_activity_exit_all</color>")
    dump(activity_map)
    for k,v in pairs(activity_map) do
        if M.CheckIsOnePlayerActiviey(k) then
            --个人活动
            for _k,_v in pairs(v) do
                if _v.Exit and type(_v.Exit) == "function" then
                    _v:Exit()
                end
            end
        else
            if v.Exit and type(v.Exit) == "function" then
               v:Exit()
            end
        end
    end
    activity_map = {}
end

function M.ui_fsg_quit_game()
    M.Exit()
end

function M.GetStatusAndInstance(data)
    local a_status
    local a_instance
    if data and data.msg_type then
        if data.msg_type == FISHING_ACTIVITY_ENUM.crit or
            data.msg_type == FISHING_ACTIVITY_ENUM.time_free_power_bullet or
           data.msg_type == FISHING_ACTIVITY_ENUM.power then
            a_status = FishingActivityTime.CheckActivityStatus(data)
            a_instance = FishingActivityTime
        elseif data.msg_type == FISHING_ACTIVITY_ENUM.free_bullet or
               data.msg_type == FISHING_ACTIVITY_ENUM.crit_bullet or
               data.msg_type == FISHING_ACTIVITY_ENUM.power_bullet or
               data.msg_type == FISHING_ACTIVITY_ENUM.quick_shoot or
               data.msg_type == FISHING_ACTIVITY_ENUM.pierce_bullet then
            a_status = FishingActivityBullet.CheckActivityStatus(data)
            a_instance = FishingActivityBullet
        elseif data.msg_type == FISHING_ACTIVITY_ENUM.shell_lottery then
            a_status = FishingActivityBK.CheckActivityStatus(data)
            a_instance = FishingActivityBK
        elseif data.msg_type == FISHING_ACTIVITY_ENUM.drill_bullet then
            a_status = FishingActivityZT.CheckActivityStatus(data)
            a_instance = FishingActivityZT
        elseif data.msg_type == FISHING_ACTIVITY_ENUM.laser_bullet then
            a_status = FishingActivityDCP.CheckActivityStatus(data)
            a_instance = FishingActivityDCP
        else
            print("<color=red>全新的活动 data.msg_type=" .. data.msg_type .. "</color>")
        end
    end
    return a_status,a_instance
end

function M.ActivityBegin(data,a_instance,cfg)
    local msg_type = data.msg_type
    local seat_num = data.seat_num
    if seat_num then
        if activity_map[msg_type] and activity_map[msg_type][seat_num] then
            --存在这个活动先退出
            local v = activity_map[msg_type][seat_num]
            if v.Exit and type(v.Exit) == "function" then
                v:Exit()
            end
            activity_map[msg_type][seat_num] = nil
        end
        activity_map[msg_type] = activity_map[msg_type] or {}
        activity_map[msg_type][seat_num] = activity_map[msg_type][seat_num] or {}
        if a_instance then
            activity_map[msg_type][seat_num] = a_instance.New(data,cfg)
        end
    else
        if activity_map[msg_type] then
            local v = activity_map[msg_type]
            if v.Exit and type(v.Exit) == "function" then
                v:Exit()
            end
        end
        activity_map[msg_type] = activity_map[msg_type] or {}
        if a_instance then
            activity_map[msg_type] = a_instance.New(data,cfg)
        end
    end
end

function M.ActivityRefresh(data,a_instance,cfg)
    local msg_type = data.msg_type
    local seat_num = data.seat_num
    if seat_num then
        if activity_map[msg_type] and activity_map[msg_type][seat_num] then
            --存在这个活动先退出
            local v = activity_map[msg_type][seat_num]
            if v.Refresh and type(v.Refresh) == "function" then
                v:Refresh(data)
                return
            end
        end
        activity_map[msg_type] = activity_map[msg_type] or {}
        activity_map[msg_type][seat_num] = activity_map[msg_type][seat_num] or {}
        if a_instance then
            activity_map[msg_type][seat_num] = a_instance.New(data,cfg)
        end
    else
        if activity_map[msg_type] then
            activity_map[msg_type]:Refresh(data)
            return
        end
        if a_instance then
            activity_map[msg_type] = a_instance.New(data,cfg)
        end
    end
end

function M.ActivityOver(data)
    local msg_type = data.msg_type
    local seat_num = data.seat_num
    if seat_num then
        --单个玩家活动
        if activity_map[msg_type] and activity_map[msg_type][seat_num] then
            local v = activity_map[msg_type][seat_num]
            if v.Exit and type(v.Exit) == "function" then
                v:Exit(data)
            end
            activity_map[msg_type][seat_num]  = nil
            if not next(activity_map[msg_type]) then
                activity_map[msg_type] = nil
            end
        end
    else
        if activity_map[msg_type] then
            local v = activity_map[msg_type]
            if v.Exit and type(v.Exit) == "function" then
                v:Exit(data)
            end
            activity_map[msg_type] = nil
        end
    end
end

--[[
    @desc: 根据活动id检查该活动是否是单个玩家活动
    --@msg_type: 活动类型
    @return:true or false
]]
function M.CheckIsOnePlayerActiviey(msg_type)
    if msg_type == FISHING_ACTIVITY_ENUM.crit
        or msg_type == FISHING_ACTIVITY_ENUM.free_bullet
        or msg_type == FISHING_ACTIVITY_ENUM.crit_bullet
        or msg_type == FISHING_ACTIVITY_ENUM.power_bullet
        or msg_type == FISHING_ACTIVITY_ENUM.power
        or msg_type == FISHING_ACTIVITY_ENUM.shell_lottery
        or msg_type == FISHING_ACTIVITY_ENUM.quick_shoot
        or msg_type == FISHING_ACTIVITY_ENUM.drill_bullet
        or msg_type == FISHING_ACTIVITY_ENUM.pierce_bullet
        or msg_type == FISHING_ACTIVITY_ENUM.time_free_power_bullet
        or msg_type == FISHING_ACTIVITY_ENUM.laser_bullet
        then
        return true
    end
    return false
end

--[[
    @desc: 检测当前是否是游戏时间
    @return:true or false
]]
function M.CheckIsActivityTime(seat_num,func)
    if not activity_map or not next(activity_map) then
        return false
    end
    for k,v in pairs(activity_map) do
        if M.CheckIsOnePlayerActiviey(k) and seat_num then
            local _v = v[seat_num]
            if _v and _v.CheckIsActivityTime and _v.CheckIsActivityTime(_v.data) then
                if func and type(func) == "function" then func() end
                return true
            end
        else
            if v.CheckIsActivityTime and v.CheckIsActivityTime(v.data) then
                if func and type(func) == "function" then func() end
                return true
            end
        end
    end
    return false
end

function M.GetOnePlayerCurNum(msg_type)
    local msg_type = msg_type
    if activity_map and activity_map[msg_type] then
        return #activity_map[msg_type]
    end
    return 0
end

function M.GetCurActivityType(seat_num)
    if not activity_map or not next(activity_map) then
        return nil
    end
    for k,v in pairs(activity_map) do
        if M.CheckIsOnePlayerActiviey(k) then
            -- local seat_num = FishingModel.GetPlayerSeat()
            local _v = v[seat_num]
            if _v and _v.data and _v.data.status == 1 then
                return FISHING_ACTIVITY_HINT_STATUS_ENUM[_v.data.msg_type]
            end
        else
            if v.data and v.data.status == 1 then
                return FISHING_ACTIVITY_HINT_STATUS_ENUM[v.data.msg_type]
            end
        end
    end
    return nil
end

function M.GetCurActivityBulletType(seat_num)
    if not activity_map or not next(activity_map) then
        return nil
    end
    for k,v in pairs(activity_map) do
        if M.CheckIsOnePlayerActiviey(k) then
            local _v = v[seat_num]
            if _v and _v.data and _v.data.status == 1 and (not _v.data.num or _v.data.num > 0) then
                return FISHING_BULLET_TYPE[_v.data.msg_type]
            end
        else
            if v.data and v.data.status == 1 then
                return FISHING_BULLET_TYPE[v.data.msg_type]
            end
        end
    end
    return nil
end

function M.GetDropAwardRate(seat_num)
    local rate
    local function one(v)
        if seat_num and v[seat_num] and v[seat_num].GetDropAwardRate then
            local cur_drop_rate = v[seat_num]:GetDropAwardRate()
            if cur_drop_rate then
                rate = rate or 0
                rate = rate + cur_drop_rate
            end
        end
    end
    local function scene(v)
        if v.GetDropAwardRate then
            local cur_drop_rate = v:GetDropAwardRate()
            if cur_drop_rate then
                rate = rate or 0
                rate = rate + cur_drop_rate
            end
        end
    end
    for k,v in pairs(activity_map) do
        if M.CheckIsOnePlayerActiviey(k) then
             --个人活动
            one(v)
        else
            --场景活动
            scene(v)
        end
    end
    return rate
end

function M.CheckIsGanChangeGun(seat_num)
    local is_can = true
    local function check_one(v)
        if seat_num and v[seat_num] and v[seat_num].CheckIsGanChangeGun then
            is_can = v[seat_num]:CheckIsGanChangeGun()
        end
    end
    local function check_scene(v)
        if v.CheckIsGanChangeGun then
            is_can = v:CheckIsGanChangeGun()
        end
    end
    for k,v in pairs(activity_map) do
        if M.CheckIsOnePlayerActiviey(k) then
            --个人活动
            check_one(v)
            if not is_can then return false end
        else
            --场景活动
            check_scene(v)
            if not is_can then return false end
        end
    end
    return is_can
end

function M.CheckHaveBullet(seat_num)
    local is_can = false
    local function check_one(v)
        if seat_num and v[seat_num] and v[seat_num].CheckHaveBullet then
            is_can = v[seat_num]:CheckHaveBullet()
        end
    end
    local function check_scene(v)
        if v.CheckHaveBullet then
            is_can = v:CheckHaveBullet()
        end
    end
    for k,v in pairs(activity_map) do
        if M.CheckIsOnePlayerActiviey(k) then
            --个人活动
            check_one(v)
        else
            --场景活动
            check_scene(v)
        end
    end
    return is_can
end

function M.GetBulletType(seat_num)
    local _type
    local function one(v)
        if seat_num and v[seat_num] and v[seat_num].GetBulletType then
            _type = v[seat_num]:GetBulletType()
        end
    end
    local function scene(v)
        if v.GetBulletType then
            _type = v:GetBulletType()
        end
    end
    for k,v in pairs(activity_map) do
        if M.CheckIsOnePlayerActiviey(k) then
            --个人活动
            one(v)
            if _type then return _type end
        else
            --场景活动
            scene(v)
            if _type then return _type end
        end
    end
    return _type
end

function M.GetFishNetType(seat_num)
    local _type
    local function one(v)
        if seat_num and v[seat_num] and v[seat_num].GetFishNetType then
            _type = v[seat_num]:GetFishNetType()
        end
    end
    local function scene(v)
        if v.GetFishNetType then
            _type = v:GetFishNetType()
        end
    end
    for k,v in pairs(activity_map) do
        if M.CheckIsOnePlayerActiviey(k) then
            --个人活动
            one(v)
            if _type then return _type end
        else
            --场景活动
            scene(v)
            if _type then return _type end
        end
    end
    return _type
end

function M.GetFreeData(seat_num)
    local free_data --{[1] = {type = "001",num = 30},[2] = {type = "002",num = 20}}
    local function one(v)
        if seat_num and v[seat_num] and v[seat_num].GetFreeData then
            local cur_free_data = v[seat_num]:GetFreeData()
            if cur_free_data then
                free_data = free_data or {}
                table.insert( free_data,cur_free_data )
            end
        end
    end
    local function scene(v)
        if v.GetFreeData then
            local cur_free_data = v:GetFreeData()
            if cur_free_data then
                free_data = free_data or {}
                table.insert( free_data,cur_free_data )
            end
        end
    end
    for k,v in pairs(activity_map) do
        if M.CheckIsOnePlayerActiviey(k) then
            --个人活动
            one(v)
        else
            --场景活动
            scene(v)
        end
    end
    return free_data
end

function M.activiey_get_func(data,func_name)
    local function one(v)
        local seat_num = data.seat_num
        if seat_num and v[seat_num] and v[seat_num][func_name] then
            return true, v[seat_num][func_name](v[seat_num],data)
        end
    end
    local function scene(v)
        if v[func_name] then
            return true, v[func_name](v,data)
        end
    end
    for k,v in pairs(activity_map) do
        if M.CheckIsOnePlayerActiviey(k) then
            --个人活动
            local is_have ,d = one(v)
            if is_have then
                return d
            end
        else
            --场景活动
            local is_have ,d = scene(v)
            if is_have then
                return d
            end
        end
    end
end

function M.GetBulletCrash(data)
    return M.activiey_get_func(data,"GetBulletCrash")
end

function M.activity_get_gold(data)
    -- dump(data, "<color=green>activity_get_gold</color>")
    M.activiey_get_func(data,"activity_get_gold")
end

function M.activity_kill_fish(data)
    -- dump(data, "<color=green>activity_kill_fish</color>")
    M.activiey_get_func(data,"activity_kill_fish")
end

function M.activity_shoot(data)
    M.activiey_get_func(data,"activity_shoot")
end

function M.activity_fish_gun_rotation(data)
    -- dump(data, "<color=green>activity_fish_gun_rotation</color>")
    M.activiey_get_func(data,"activity_fish_gun_rotation")
end

-- 玩家离开
function M.on_fsg_leave_msg(seat_num)
    dump(seat_num, "<color=green>on_fsg_leave_msg</color>")
    for k,v in pairs(activity_map) do
        --单个玩家活动
        if v and v[seat_num] then
            v[seat_num]:Exit()
            v[seat_num]  = nil
        end
    end
    M.StopSoundBGM(seat_num)
end