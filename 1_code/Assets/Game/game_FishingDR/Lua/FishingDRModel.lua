local basefunc = require "Game.Common.basefunc"
require "Game.game_FishingDR.Lua.FishingDRConfig"

FishingDRModel = {}
-- 别名
FishingModel = FishingDRModel
local M = FishingDRModel
local update_frame_msg
M.Model_Status = {
    bet = "bet",
    gaming = "game",
    gameover = "end"
}

M.EventType = {
    [1] = "add_2",--加一倍
    [2] = "add_3",--加二倍
    [3] = "add_4",--加三倍
    [4] = "rem_sp",--减速
}

M.DeathType = {
    [1] = "norml",--正常死亡
    [2] = "sd",--闪电
    [3] = "jg",--激光
}
M.maxPlayerNumber = 8

M.Defines = {
    FrameTime = 0.033,
    WorldDimensionUnit={xMin=-9.6, xMax=9.6, yMin=-5.4, yMax=5.4},
    ControlMode = {Manual = 0,Auto = 1},

    bullet_speed = 1000, -- 子弹运动速度
    bullet_num_limit = 50, -- 每个玩家同屏最多的子弹数
    nor_bullet_cooldown = 0.15, -- 子弹发射频率
    bullet_life = 3,--子弹的生命
    bg_speed = 5,--背景速度
    end_location = 1400,--终点位置
    fish_hp_total = { 10000,10000,10000,10000,10000,10000,10000 },
    --fish_hp_total = { 15000,25000,35000,45000,55000,65000,75000 },
    fish_hp_hurt = 300,

    energy_reduce = 0.2
}

local lister
local m_data
local function MakeLister()
    lister = {}
    lister["fishing_dr_all_info_response"] = M.fishing_dr_all_info_response
    lister["fishing_dr_enter_game_response"] = M.fishing_dr_enter_game_response
    
    lister["fishing_dr_enter_room"] = M.fishing_dr_enter_room
    lister["fishing_dr_game_begin"] = M.fishing_dr_game_begin
    lister["fishing_dr_game_end"] = M.fishing_dr_game_end
    lister["fishing_dr_game_new"] = M.fishing_dr_game_new
    lister["add_history_log"] = M.add_history_log

    lister["fish_trigger_item"] = M.fish_trigger_item
    lister["bullet_trigger_fish"] = M.bullet_trigger_fish
    lister["shoot"] = M.shoot
    lister["game_click"] = M.game_click

    lister["fishing_dr_quit_room_response"] = M.on_fishing_dr_quit_room

    lister["fishing_dr_auto_bet_response"] = M.handle_auto_bet
    lister["fishing_dr_reset_auto_bet_response"] = M.handle_reset_auto_bet
    lister["fishing_dr_receive_prize_response"] = M.handle_receive_prize
    lister["fishing_dr_use_energy_response"] = M.handle_use_energy

end

local function MsgDispatch(proto_name, data)
    local func = lister[proto_name]
    if not func then
        error("brocast " .. proto_name .. " has no event.")
    end
    --临时限制   一般在断线重连时生效  由logic控制
    if M.data.limitDealMsg and not M.data.limitDealMsg[proto_name] then
        return
    end
    func(proto_name, data)
end

function M.AddMsgListener()
    for proto_name, _ in pairs(lister) do
        Event.AddListener(proto_name, MsgDispatch)
    end
end

function M.RemoveMsgListener()
    for proto_name, _ in pairs(lister) do
        Event.RemoveListener(proto_name, MsgDispatch)
    end
end

function M.Update()
    
end

local function InitConfig(cfg,cfg2)
    M.Config = FishingDRConfig.InitUIConfig()
end

local function InitModelData()
    M.data = {}
    m_data = M.data
end

function M.Init()
    InitConfig()
    InitModelData()
    MakeLister()
    M.AddMsgListener()
    return M
end

function M.Exit()
    M.RemoveMsgListener()
    lister = nil
    M.data = nil
    M = nil
end

-- 新开游戏 初始化游戏状态相关数据，游戏外数据保留
function M.InitStatusData(status)
    m_data.status = status
    m_data.bet = nil
    m_data.my_bet = nil
    m_data.fish = nil
    m_data.flood_data = nil
    m_data.event_data = nil
    m_data.settlement_data = nil
    m_data.auto_bet_data = nil
    m_data.energy_waiting = nil
end

--***********************all
function M.fishing_dr_all_info_response(p_n, data)
    dump(data, "<color=yellow>fishing_dr_all_info_response</color>")
    if data.result ~= 0 then
        if data.result == 1004 or data.result == -1 then
            Event.Brocast("model_fishing_dr_all_info_error")
            return
        end
        HintPanel.ErrorMsg(data.result,function()
            Event.Brocast("model_fishing_dr_all_info_error")
        end)
        return
    end

    -- if data.game_data.game_state ~= M.Model_Status.gaming then
    --     data.event_data = nil
    --     data.fish = nil
    -- end

    -- 测试
    -- data.fish = data.fish or {}
    -- data.fish[1] = {}
    -- data.fish[1].location = 300
    -- data.fish[1].start_speed = 100
    -- data.event_data = data.event_data or {}
    -- data.event_data[1] = nil
    -- data.flood_data = data.flood_data or {}
    -- data.flood_data[1] = {}
    -- data.flood_data[1].bj_data = {{location = 100, value = 1000 }}
    m_data.test_dead_fishid = 1
    if data.fish then
        for i=1, #data.fish do
            if data.fish[i].location and data.fish[i].location > 0 then
                m_data.test_dead_fishid = i
                break
            end
        end
    end
    print("xxxxxxxxxxxxxxxxxxxxxxxxxxxxx all info "..os.time())

    M.all_info_init(data)
    Event.Brocast("model_fishing_dr_all_info")
    Event.Brocast("model_recover_finish")
end

function M.all_info_init(data)
    m_data.bet = data.game_bet
    m_data.my_bet = data.my_bet
    m_data.game_data = data.game_data
    m_data.fish = data.fish
    m_data.flood_data = data.flood_data
    m_data.energy_location = data.energy_location
    m_data.event_data = data.event_data
    m_data.settlement_data = data.settlement_data
    m_data.model_status = data.game_data.game_state

    m_data.auto_bet_data = data.auto_bet_data
    m_data.energy_waiting = false

    M.InitTrackData()
    
    dump(M.data, "<color=yellow>断线重连数据整理结果</color>")
end

function M.InitEnergy()
    m_data.energy = 0
    m_data.total_energy = 0
    if type(m_data.my_bet) == "table" and next(m_data.my_bet) then
        for i, v in pairs(m_data.my_bet) do
            m_data.total_energy = m_data.total_energy + v
        end
    end
    m_data.energy = m_data.total_energy
end

function M.InitLocalData()
    --本地数据
    m_data.player = {}
    m_data.gun = {}
    m_data.item = {}
    for i=1,8 do
        --枪
        local gun_data = {}
        gun_data.id = i
        gun_data.is_use = m_data.game_data.game_state == M.Model_Status.gaming
        gun_data.bullet_num_limit = FishingDRModel.Defines.bullet_num_limit
        if i ~= 8 then
            gun_data.control_mode = FishingDRModel.Defines.ControlMode.Auto
            gun_data.level = 1
            if m_data.my_bet and m_data.my_bet[i] and m_data.my_bet[i] > 0 then
                gun_data.level = gun_data.level + 1
                gun_data.is_bet = true
            else
                gun_data.is_bet = false
            end
            if m_data.energy_location and m_data.energy_location[i] and m_data.energy_location[i] > 0 then
                gun_data.level = gun_data.level + 1
                gun_data.is_energy = true
            else
                gun_data.is_energy = false
            end
            gun_data.cooldown = 0.4-- FishingDRModel.Defines.nor_bullet_cooldown
            gun_data.cooldown_coefficient = 1
        else
            gun_data.control_mode = FishingDRModel.Defines.ControlMode.Manual
            gun_data.level = 2
            gun_data.cooldown = 0.2-- FishingDRModel.Defines.nor_bullet_cooldown
            gun_data.cooldown_coefficient = 1
        end
        m_data.gun[gun_data.id] = gun_data

        --玩家
        local player_data = {}
        player_data.id = i
        player_data.gun_id = i
        m_data.player[player_data.id] = player_data
    end
    if not table_is_null(m_data.event_data) then
        for i,v in ipairs(m_data.event_data) do
            local var = {}
            var = basefunc.deepcopy(v)
            var.index = i
            m_data.item[var.index] = var
        end
    end
    dump(m_data.item, "<color=yellow>道具</color>")
end

function M.InitTrackData()
    m_data.track_data = {}
    if m_data.fish and next(m_data.fish) then
        for i,v in ipairs(m_data.fish) do
            local _d = {}
            m_data.track_data[i] = _d --赛道id就是鱼的id
            _d.fish = v
            _d.fish.track_id = i
            _d.fish.fish_id = i
            _d.fish.fish_type = i
            _d.fish.cur_speed = _d.fish.start_speed
            _d.fish.cur_rate = 1
            _d.fish.cur_location = 0
            _d.fish.pos = Vector3.zero
            _d.fish.angle = 0
            _d.fish.is_dead = 0
            _d.fish.is_flee = 0

            -- _d.fish.total_hp = M.Defines.fish_hp_total[i] or 0
            -- _d.fish.cur_hp = _d.fish.total_hp
            -- _d.fish.baoji_data = nil
            -- _d.fish.cur_deal_bj_idx = 0
   
            if v.death_type then
                _d.fish.trigger_type = v.death_type % 10
            end
            _d.event = {}
            if m_data.event_data and next(m_data.event_data) then
                for e_i,e_v in ipairs(m_data.event_data) do
                    if e_v.track_id == i then
                        e_v.index = e_i
                        table.insert(_d.event,e_v)
                    end
                end
            end
        end
    end
    m_data.ave_sp = M.GetAverageSpeed() --相机速度取平均速度
    M.InitLocalData()
    M.InitEnergy()
    M.InitDealEnergy()
end

-- function M.dealHp(fish,dt)
--     if not M.check_is_dead_or_flee(fish.fish_id) then
-- 		if fish.cur_hp > 0 then
-- 			fish.cur_hp = fish.cur_hp - M.Defines.fish_hp_hurt * dt
-- 			if fish.cur_hp < 0 then
-- 				fish.cur_hp = 0
-- 			end
-- 		end
-- 	end
-- end

-- function M.dealBaoji(fish,dt)
--  local cur_location = fish.cur_location
-- 	local next_idx = fish.cur_deal_bj_idx + 1
-- 	local bj_data = M.data.flood_data

-- 	if next_idx < #bj_data then
-- 		local bj_location = bj_data[next_idx].location
-- 		if cur_location >= bj_location then
-- 			fish.cur_deal_bj_idx = next_idx
-- 			if fish.cur_hp > 0 then
-- 				fish.cur_hp = self.cur_hp - bj_data[next_idx].value
-- 				if fish.cur_hp < 0 then
-- 					fish.cur_hp = 0
-- 				end
-- 			end

-- 			fish.baoji_data = bj_data[next_idx]
-- 		end
-- 	end
-- end

function M.GetAverageSpeed()
    local ave_sp = 0
    if not M.data.track_data or not next(M.data.track_data) then return ave_sp end
    for i,v in ipairs(M.data.track_data) do
        ave_sp = ave_sp + v.fish.cur_speed
    end
    return ave_sp / #M.data.track_data
end

local cur_time = 0
local is_reset = false
function M.FrameUpdateByTime(time)
    dump(time, "<color=yellow>time::>>>>>.</color>")
    cur_time = 0
    is_reset = true
    if time == 0 then
        is_reset = false
        return
    end
    local count =  time / 10 / FishingDRModel.Defines.FrameTime
    for i=1,count do
        M.FrameUpdate()
        FishingDRGamePanel.FrameUpdate(FishingDRModel.Defines.FrameTime)
    end
    is_reset = false
end

local testfirst = false
function M.FrameUpdate()
    -- 测试
    if not testfirst then
        print("xxxxxxxxxxxxxxxxxxxxxxxxxxxxx fishmode FrameUpdate first"..os.time())	
    end
    testfirst = true

    local ft = FishingDRModel.Defines.FrameTime
    cur_time = cur_time + ft
    for i,v in ipairs(m_data.track_data) do
        v.fish.cur_location = v.fish.cur_location + v.fish.cur_speed * ft
        --M.dealHp(v.fish, ft)
        if v.fish.location then
            if v.fish.cur_location >= v.fish.location then
                -- 测试
                if v.fish.fish_id == m_data.test_dead_fishid and v.fish.is_dead ~= 1 then
                    print("xxxxxxxxxxxxxxxxxxxxxxxxxxxxx fish dead"..os.time())	
                    
                    local fish = FishingDRFishManager.Get(v.fish.fish_id)
                    print(string.format("xxxxxxxxxxxxxxxxxxxxxxxxxxxxx fish dead hp %d / %d ", fish.cur_hp, fish.total_hp)..os.time())
                end

                v.fish.is_dead = 1
                if v.fish.trigger_type == 1 then
                    --正常死亡只影响自己
                    
                elseif v.fish.trigger_type == 2 then
                    --闪电
                    if not table_is_null(v.fish.trigger) then
                        for k,ft_id in pairs(v.fish.trigger) do
                            local ft = M.data.track_data[ft_id].fish
                            if ft and ft.is_dead == 0 then
                                ft.is_dead = 1
                                ft.location = ft.cur_location
                            end
                        end
                    end
                elseif v.fish.trigger_type == 3 then
                    --激光
                    if not table_is_null(v.fish.trigger) then
                        for k,ft_id in pairs(v.fish.trigger) do
                            local ft = M.data.track_data[ft_id].fish
                            if ft and ft.is_dead == 0 then
                                local seq = DoTweenSequence.Create()
                                seq:AppendInterval(3)
                                seq:AppendCallback(function(  )
                                    ft.is_dead = 1
                                    ft.location = ft.cur_location
                                end)
                                seq:OnForceKill(function()
                                    ft.is_dead = 1
                                    ft.location = ft.cur_location
                                end)
                            end
                        end
                    end
                end
                if not v.fish.process_dead then
                    --鱼死亡事件触发
                    if M.check_is_reset() then
                        Event.Brocast("model_fish_dead_msg",v)
                        v.fish.process_dead = 1
                    else
                        if not v.fish.process_dead and (v.fish.cur_location - v.fish.location > 10 or v.fish.cur_location > M.Defines.end_location) then
                            Event.Brocast("model_fish_dead_msg",v)
                            v.fish.process_dead = 1
                        end
                    end
                end
            end
        else
            if v.fish.cur_location >= M.Defines.end_location then
                v.fish.is_flee = 1
                v.fish.cur_speed = v.fish.start_speed * 15
                if not v.fish.process_flee then
                    --鱼逃离事件触发
                    if M.check_is_reset() then
                        Event.Brocast("model_fish_flee_msg",v)
                        v.fish.process_flee = 1
                    else
                        if v.fish.cur_location > M.Defines.end_location then
                            Event.Brocast("model_fish_flee_msg",v)
                            v.fish.process_flee = 1
                        end
                    end
                end
            end
        end
        if not table_is_null(v.event) then
            for e_i,e_v in ipairs(v.event) do
                if v.fish.cur_location >= e_v.location then
                    --事件触发
                    if e_v.id == 1 or e_v.id == 2 or e_v.id == 3 then
                        v.fish.cur_rate = tonumber(e_v.id) + 1
                    elseif e_v.id == 4 then
                        v.fish.cur_speed = v.fish.start_speed * e_v.speed_effect
                    end
                    if e_v.time and not e_v.end_location then
                        e_v.end_location = v.fish.cur_location + v.fish.cur_speed * e_v.time
                    end
                    e_v.trigger = 1
                    if not e_v.process_trigger then
                        if M.check_is_reset() then
                            Event.Brocast("model_event_trigger_msg",e_v)
                            e_v.process_trigger = 1
                        else
                            if v.fish.cur_location > M.Defines.end_location or v.fish.cur_location - e_v.location > 10 then
                                Event.Brocast("model_event_trigger_msg",e_v)
                                e_v.process_trigger = 1
                            end
                        end
                    end
                end
                if e_v.end_location and v.fish.cur_location >= e_v.end_location then
                    --事件效果失效
                    if e_v.id == 1 or e_v.id == 2 or e_v.id == 3 then
                        v.fish.cur_rate = 1
                    elseif e_v.id == 4 then
                        if v.fish.cur_location >= e_v.end_location then
                            v.fish.cur_speed = v.fish.start_speed
                        end
                        if v.fish.cur_location >= M.Defines.end_location then
                            v.fish.cur_speed = v.fish.start_speed * 15
                        end
                    end
                    if not e_v.process_end then
                        Event.Brocast("model_event_trigger_end_msg",e_v)
                        e_v.process_end = 1
                    end
                end
            end
        end
    end

    M.dealEnergy(ft)
end

function M.GetData()
    return M.data
end

--是否在断线重连重置游戏，重置过程中部分表现要屏蔽
function M.check_is_reset()
    return is_reset
end

function M.check_is_dead_or_flee(id)
    if m_data and m_data.fish then
        local f = M.data.fish[id]
        if f then
            return f.is_dead == 1 or f.is_flee == 1
        end
    end
end

function M.set_fish_dead(id)
    if m_data and m_data.fish then
        local f = M.data.fish[id]
        if f then
            f.is_dead = 1
            f.location = f.cur_location
        end
    end
end

function M.get_fish_sp(id)
    local sp = 0
    if m_data and m_data.fish then
        local f = M.data.fish[id]
        if f then
            sp = f.cur_speed
        end
    end
    if sp == 0 then
        print("<color=red>鱼的速度为0</color>")
    end
    return M.s2c_size(sp)
end

function M.set_fish_sp(id)
    if m_data and m_data.fish then
        local f = M.data.fish[id]
        if f then
            f.cur_speed = f.start_speed * 15
        end
    end
end

function M.get_fish_rate(id)
    local rate = 1
    if m_data and m_data.fish then
        local f = M.data.fish[id]
        if f then
            rate = f.cur_rate
        end
    end
    return rate
end

function M.get_fish(id)
    if m_data and m_data.fish then
        local f = M.data.fish[id]
        if f then
            return f
        end
    end
end

function M.get_fish_trigger(id)
    local trigger = {}
    local trigger_type = 1
    if m_data and m_data.fish then
        local f = M.data.fish[id]
        if f then
            trigger = f.trigger
            if not table_is_null(trigger) then
                local ft = M.data.fish[trigger[1]]
                if ft then
                    trigger_type = ft.trigger_type
                end
            end
        end
    end
    return trigger,trigger_type
end

function M.check_fish_is_fj(id)
    if m_data and m_data.fish then
        local f = M.data.fish[id]
        if f then
            return f.is_fj
        end
    end
    return false
end

--鱼是否死亡
function M.check_fish_is_dead(fish_id)
    if not M.data.track_data then return end
    local td = M.data.track_data[fish_id]
    if td then
        return td.fish.is_dead == 1
    end
end

function M.check_fish_is_reale_flee(fish_id)
    local td = M.data.track_data[fish_id]
    if td then
        return td.fish.is_flee == 1 and td.fish.cur_location > M.Defines.end_location
    end
end

--设置处理鱼死亡
function M.set_fish_process_dead(fish_id)
    if table_is_null(M.data.track_data) then return end
    local td = M.data.track_data[fish_id]
    if td then
        td.fish.process_dead = 1
    end
end

--设置处理鱼逃离
function M.set_fish_process_flee(fish_id)
    local td = M.data.track_data[fish_id]
    if td then
        td.fish.process_flee = 1
    end
end

--设置处理事件结束
function M.set_event_process_end(index)
    for i,v in ipairs(m_data.track_data) do
        if not table_is_null(v.event) then
            for e_i,e_v in ipairs(v.event) do
                if e_v.index == index then
                    e_v.trigger = 1
                    e_v.process_end = 1
                end
            end
        end
    end
end

--设置处理事件触发
function M.set_event_process_trigger(index)
    for i,v in ipairs(m_data.track_data) do
        if not table_is_null(v.event) then
            for e_i,e_v in ipairs(v.event) do
                if e_v.index == index then
                    e_v.trigger = 1
                    e_v.process_trigger = 1
                end
            end
        end
    end
end

function M.fish_trigger_item(_,data)
    dump(data, "<color=yellow>fish_trigger_item</color>")
    if M.data and M.data.fish and next(M.data.fish) and M.data.event_data and next(M.data.event_data) then
        local e = M.data.event_data[data.index]
        local f = M.data.fish[data.fish_id]
        if e and f then
            data.id = e.id
            if e.id == 1 or e.id == 2 or e.id == 3 then
                f.cur_rate = f.cur_rate + tonumber(e.id)
            elseif e.id == 4 then
                --减速
                f.cur_speed = f.start_speed * e.speed_effect
            else
                print("<color=white>其他事件触发</color>")
            end
        end
    end
    Event.Brocast("model_fish_trigger_item", data)
end

function M.bullet_trigger_fish(_,data)
    -- dump(data, "<color=yellow>bullet_trigger_fish</color>")
    data.fish.is_dead = M.check_fish_is_dead(data.fish.id)
    data.fish.trigger,data.fish.trigger_type = M.get_fish_trigger(data.fish.id)
    data.fish.reply_level = 1
    data.fish.is_fj = M.check_fish_is_fj(data.fish.id)
    data.bullet.is_destroy = true
    data.net = {}
    data.net.pos = data.base.pos
    data.net.up = data.base.up
    data.net.offset = 0.4
    data.net.type = 1
    data.net.duration = 0.5
    Event.Brocast("model_bullet_trigger_fish", data)
end

function M.shoot(_,data)
    -- dump(data, "<color=yellow>shoot</color>")
    data.bullet = {}
    data.bullet.gun_id = data.gun_id
    data.bullet.angle = data.angle
    data.bullet.pos = data.pos
    if data.gun_id == 8 then
        print("shooot88888888888888888888888888888888888")
        data.bullet.prefab = "bulletprefab_z_4_game_fishingdr"
        data.bullet.speed =  M.s2c_size(M.Defines.bullet_speed * 1.6)
    else
        -- 测试
        if data.level > 1 then
            data.bullet.prefab = "bulletprefab_z_4_game_fishingdr"
        else
            data.bullet.prefab = "bulletprefab_1_game_fishingdr"
        end
        data.bullet.speed =  M.s2c_size(M.Defines.bullet_speed)
    end
    
    Event.Brocast("model_shoot", data)
end

function M.game_click(_,data)
    -- dump(data, "<color=yellow>game_click</color>")
    data.players = {}
    data.players[8] = {}
    data.players[8].gun_id = 8

    Event.Brocast("model_game_click", data)
end

function M.on_fishing_dr_quit_room(_, data)
    --dump(data,"<color=red>+++++on_fishing_dr_quit_room+++++</color>")
    if data.result == 0 then
        InitModelData()
        MainLogic.ExitGame()
        --FishingDRLogic.change_panel("hall")
        --GameManager.GotoUI({gotoui = "game_MiniGame"})
    else
        HintPanel.ErrorMsg(data.result)
    end
end

function M.handle_auto_bet(_, data)
	if data.result == 0 then
		m_data.auto_bet_data = data.auto_bet_data
		Event.Brocast("model_auto_bet", data)
	else
		HintPanel.ErrorMsg(data.result)
	end
end

function M.handle_reset_auto_bet(_, data)
	if data.result == 0 then
		m_data.auto_bet_data = data.auto_bet_data
		Event.Brocast("model_reset_auto_bet", data)
	else
		HintPanel.ErrorMsg(data.result)
	end
end

function M.handle_receive_prize(_, data)
	if data.result == 0 then
		m_data.auto_bet_data = nil
		Event.Brocast("model_receive_prize", data)
	else
		HintPanel.ErrorMsg(data.result)
	end
end

function M.handle_use_energy(_, data)
    FishingModel.data.energy_waiting = false
    
    if data.result == 0 then
        
        local gun_data = m_data.gun[data.track_id]

		if gun_data then
            if gun_data.level < 3 then
                gun_data.level = gun_data.level + 1
            end
            gun_data.is_energy = true
        end

		Event.Brocast("model_use_energy", data)
	else
		HintPanel.ErrorMsg(data.result)
	end
end

function M.dealEnergy(dt)
    if is_reset then return end

    if m_data.energy > 0 then
        local reduce = 0
        for i, v in pairs(m_data.gun) do
            if v.is_energy then
                reduce = reduce + m_data.total_energy * 0.2 * dt
            end
        end

        m_data.energy = m_data.energy - reduce
        if m_data.energy < 0 then
            m_data.energy = 0

            for i, v in pairs(m_data.gun) do
                if v.is_energy then
                    v.is_energy = false
                    if v.level > 1 then
                        v.level = v.level - 1
                    end
                end
            end
        end
    end
end

function M.InitDealEnergy()
    if m_data.energy > 0 then
        local reduce = 0
        for i, v in pairs(m_data.energy_location) do
            if v > 0 then
                local dt = os.time() - v
                reduce = reduce + m_data.total_energy * 0.2 * dt
            end
        end

        m_data.energy = m_data.energy - reduce
        if m_data.energy < 0 then
            m_data.energy = 0

            for i, v in pairs(m_data.gun) do
                if v.is_energy then
                    v.is_energy = false
                    if v.level > 1 then
                        v.level = v.level - 1
                    end
                end
            end
        end
    end
end

--********************response
--进入游戏
function M.fishing_dr_enter_game_response(_, data)
    dump(data, "<color=yellow>fishing_dr_enter_game_response</color>")
    InitModelData()
    Event.Brocast("model_fishing_dr_enter_game_response", data)
end

-- 开局
function M.fishing_dr_enter_room(_, data)
    dump(data, "<color=red>fishing_dr_enter_room</color>")
end
-- 开始游戏
function M.fishing_dr_game_begin(_, data)

    -- 测试
    -- testfirst = false
    -- data.fish = data.fish or {}
    -- data.fish[1] = {}
    -- data.fish[1].location = 300
    -- data.fish[1].start_speed = 100
    -- data.event_data = data.event_data or {}
    -- data.event_data[1] = nil
    -- data.flood_data = data.flood_data or {}
    -- data.flood_data[1] = {}
    -- data.flood_data[1].bj_data = {{location = 100, value = 1000 }}
    m_data.test_dead_fishid = 1
    if data.fish then
        for i=1, #data.fish do
            if data.fish[i].location and data.fish[i].location > 0 then
                m_data.test_dead_fishid = i
                break
            end
        end
    end
    print("xxxxxxxxxxxxxxxxxxxxxxxxxxxxx game new "..os.time())
        
    dump(data, "<color=red>fishing_dr_game_begin</color>")
    -- data = M.TestFish()
    m_data.bet = data.game_bet
    m_data.my_bet = data.my_bet
    m_data.game_data = data.game_data
    m_data.fish = data.fish
    m_data.event_data = data.event_data
    m_data.settlement_data = data.settlement_data
    m_data.model_status = data.game_data.game_state
    m_data.auto_bet_data = data.auto_bet_data
    m_data.flood_data = data.flood_data
    m_data.energy_location = data.energy_location

    M.InitTrackData()
    Event.Brocast("model_fishing_dr_game_begin")
end
-- 游戏结束
function M.fishing_dr_game_end(_, data)
    dump(data, "<color=red>fishing_dr_game_end</color>")
    m_data.settlement_data = data.settlement_data
    m_data.model_status = M.Model_Status.gameover
    m_data.game_data = data.game_data
    Event.Brocast("model_fishing_dr_game_end")
end
-- 开始下注
function M.fishing_dr_game_new(_, data)
    dump(data, "<color=red>fishing_dr_game_new</color>")
    M.InitStatusData()

    m_data.game_data = data.game_data
    m_data.model_status = data.game_data.game_state
    m_data.auto_bet_data = data.auto_bet_data
    Event.Brocast("model_fishing_dr_game_new")
end
-- 历史记录 新增
function M.add_history_log(_, data)
    dump(data, "<color=red>add_history_log</color>")

    Event.Brocast("model_add_history_log")
end

--*******************************方法
function M.SendAllInfo()
    print("<color=red>M.SendAllInfo()</color>")
    FishingDRLogic.is_quit = false
    if update_frame_msg then
        update_frame_msg:Stop()
    end
    --测试数据
    -- local data = {
    -- 	result = 0
    -- }
    -- Event.Brocast("fishing_dr_all_info_response","fishing_dr_all_info_response", data)

    Network.SendRequest("fishing_dr_all_info", nil, "")
end

-- 摄像机 用于坐标转化
function M.SetCamera(camera2d, camera)
    M.camera2d = camera2d
    M.camera = camera
end
-- 2D坐标转UI坐标
function M.Get2DToUIPoint(vec)
    vec = M.camera2d:WorldToScreenPoint(vec)
    vec = M.camera:ScreenToWorldPoint(vec)
    return vec
end
-- UI坐标转2D坐标
function M.GetUITo2DPoint(vec)
    vec = M.camera:WorldToScreenPoint(vec)
    vec = M.camera2d:ScreenToWorldPoint(vec)
    return vec
end 

function M.s2c_size(v)
    return v / 100
end

function M.TestFish(  )
    return { 
         event_data = {
             [1] = {
                 id             = 1,
                 location       = 350.0,
                 speed_effect   = 1,
                 time           = 1000000,
                 track_id       = 2,
             },
             [2] = {
                 id             = 4,
                 location       = 700.0,
                 speed_effect   = 0.5,
                 time           = 3,
                 track_id       = 6,
             },
         },
         fish = {
             [1] = {
                 death_type    = 31,
                 location      = 350.0,
                 start_speed   = 84,
                 trigger = {
                     [1] = 2,
                     [2] = 3,
                 },
             },
             [2] = {
                 death_type    = 33,
                 location      = 1232.0,
                 start_speed   = 119,
                 is_fj = 1000,
             },
             [3] = {
                 death_type    = 33,
                 location      = 1343.0,
                 start_speed   = 102,
             },
             [4] = {
                death_type    = 32,
                 start_speed   = 75,
                 location      = 543.0,
                 trigger = {
                    [1] = 5,
                    [2] = 6,
                },
             },
             [5] = {
                 start_speed   = 70,
                 death_type    = 32,
                 location      = 1343.0,
             },
             [6] = {
                 start_speed   = 85,
                 death_type    = 32,
                 location      = 1343.0,
             },
             [7] = {
                 start_speed   = 99,
             },
         },
         
         game_data={
             countdown_time=0,
             game_state="game",
             periods=992,
             new_status_time=4792,
         },
         game_bet={
             [1]=914000,
             [2]=616400,
             [3]=607600,
             [4]=326700,
             [5]=324400,
             [6]=368900,
             [7]=147200,
         },
     }
 end