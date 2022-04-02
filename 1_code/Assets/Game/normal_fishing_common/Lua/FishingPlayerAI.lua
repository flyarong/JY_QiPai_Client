-- 创建时间:2019-03-11
--[[
    座位
    4   3
    1   2
--]]
local basefunc = require "Game.Common.basefunc"
FishingPlayerAI = basefunc.class()

local M = FishingPlayerAI
M.name = "FishingPlayerAI"
local Manager = FishingPlayerAIManager
local ExpectType = {
    random = "random",
    min_rate = "min_rate",
    max_rate = "max_rate",
    min_dis = "min_dis",
    max_dis = "max_dis",
    min_live = "min_live",
    max_live = "max_live",
}

local PlayerCurState = {}

function M.Create(player, config, player_instance)
    return M.New(player, config, player_instance)
end

function M:StartUpdate()
    self.update_timer = Timer.New(function(  )
        self:FrameUpdate()
    end,self.update_duration,-1,false,true)
    self.update_timer:Start()

    self.update_time = Timer.New(function(  )
        self.cur_time = self.cur_time or os.time()
        self.cur_time = self.cur_time + 0.1
    end,0.1,-1,false,false)
    self.update_time:Start()
end

function M:ctor(player, config, player_instance)
    self.player = player
    self.config = config
    self.player_instance = player_instance
    self.camera2d = GameObject.Find("CatchFish2DCamera"):GetComponent("Camera")
    self.update_running = true
    self.update_duration = 0.1
    self.cur_time = self.cur_time or os.time()
    self:Init()
end

function M:Init()
    if not self.player or not self.config then return end
    if not self.update_running then return end
    self:FrameUpdateStatus()
    local s_d, s_t
    if self:CheckPlayerCurState("gun") then
        local cur_gun = self:GetPlayerCurState("gun")
        s_d, s_t = cur_gun.s_d, cur_gun.s_t
    else
        s_d, s_t = M.GetStatusData(self.config.player_speed.change_gun_level,self.config.player_status.change_gun_level,self.change_gun_time,self.cur_time)
        if not s_d or not s_d.key then return end
        self:SavePlayerCurState("gun",{s_d = s_d,s_t = s_t})
    end
    local cur_event = FishingActivityManager.CheckIsGanChangeGun(self.player.base.seat_num)
    --活动时间不能切换
    if not cur_event or cur_event == 0 then return end
    if not s_d or not s_d.key then return end
    self.change_gun_time = s_t
    local cur_level = M.GetCurGunLevel(self.player_instance)
    local interval = M.SetGunLevel(s_d.key, cur_level, self.player, self)
    self:RefreshPauseShootTime(interval)
end

function M:FrameUpdate()
    -- dump(self.player, "<color=white>player>>>>></color>")
    -- dump(self.config, "<color=white>config>>>>></color>")
    if not self.player or not self.config then return end
    if not self.update_running then return end
    self:FrameUpdateStatus()
    self:FrameUpdateFish()
    self:FrameUpdateShoot()
    self:FrameUpdateGun()
    self:FrameUpdateSkill()
end

function M:Exit()
    print("<color=yellow>AI退出</color>")
    if self.update_timer then
        self.update_timer:Stop()
        self.update_timer = nil
    end
    self.update_running = nil

    if self.update_time then
        self.update_time:Stop()
        self.update_time = nil
    end
    if self.change_gun_timer then
        self.change_gun_timer:Stop()
        self.change_gun_timer = nil
    end
    self = nil
end

function M:SetUpdateRunning(running)
    self.update_running = running
end

-----------------------------------------------------status
function M:FrameUpdateStatus()
    local is_can, s_t = M.CheckIsAction(self.config.player_speed.switch,self.switch_time,self.cur_time)

    --活动即使切状态
    local sw_cfg = self.config.player_switch
    if not sw_cfg then return end
    if sw_cfg.event then
        for i,v in ipairs(sw_cfg.event) do
            if v.event and v.event == M.GetCurEvent(self.player) then
                is_can = true
            end
        end
    end
    if not is_can then return end
    self.switch_time = s_t
    self.config = M.ChangeStatus(self.player,self.player_instance,self.fish_list,self.config)
end

function M.ChangeStatus(p,p_instance,fish_list,cfg)
    if not p or not cfg then return cfg end
    local sw_cfg = cfg.player_switch
    if not sw_cfg then return cfg end
    if sw_cfg.event then
        for i,v in ipairs(sw_cfg.event) do
            if v.event and v.event == M.GetCurEvent(p) then
                return M.ChangeCurStatus(cfg,v.status)
            end
        end
    end
    if sw_cfg.fish and fish_list then
        for i,v in ipairs(sw_cfg.fish) do
            if v.rate and M.GetFishByRate(fish_list,v.rate) then
                return M.ChangeCurStatus(cfg,v.status)
            end
            if v.num and v.num == #fish_list then
                return M.ChangeCurStatus(cfg,v.status)
            end
            local min_fish,min_dis = M.GetFishForDis(p_instance,fish_list,ExpectType.min_dis)
            if v.dis and v.dis >= min_dis then
                return M.ChangeCurStatus(cfg,v.status)
            end
        end
    end
    if sw_cfg.gold then
        for i,v in ipairs(sw_cfg.gold) do
            if v.num and M.GetCurGold(p) and v.num <= M.GetCurGold(p) then
                return M.ChangeCurStatus(cfg,v.status)
            end
        end
    end
    return cfg
end

function M.ChangeCurStatus(cfg,st_id)
    cfg = Manager.CreateAIConfigByStatus(st_id)
    return cfg
end
-----------------------------------------------------fish
function M:FrameUpdateFish()
    local is_can, s_t = M.CheckIsAction(self.config.player_speed.see_fish,self.see_fish_time,self.cur_time)
    --不看鱼
    if not is_can then return end
    self.see_fish_time = s_t
    self.fish_list = M.SeeAllFish()
    self.fish_list = self:CheckIsInPoolWholeCanShoot(self.fish_list,self.player.base.seat_num,self.p_instance)
    self.fish_list = self:CheckIsMySeatFish(self.fish_list,self.player.base.seat_num,self.p_instance)
end

function M.SeeAllFish()
    local fish_hit = FishManager.GetAllFish()
    local fish_list = {}
    -- local pos
    -- local WorldDimensionUnit = FishingModel.Defines.WorldDimensionUnit
    for k,v in pairs(fish_hit) do
        -- if v.m_fish_state ~= Fish.FishState.FS_Dead then
        --     pos = v.transform.position
        --     --在视野内
        --     if pos.x < WorldDimensionUnit.xMax and pos.x > WorldDimensionUnit.xMin and pos.y < WorldDimensionUnit.yMax - 1 and pos.y > WorldDimensionUnit.yMin + 1.4 then
        --         fish_list[#fish_list + 1] = v
        --     end
        -- end
        if v:CheckIsInPool_Whole() then
            fish_list[#fish_list + 1] = v
        end
    end
    if next(fish_list) then
        return fish_list
    end
    return nil
end

--根据玩家坐标剔除不能攻击的鱼
function M:CheckIsInPoolWholeCanShoot(fish_list,seat_num,p_instance)
    if fish_list and seat_num and p_instance then
        local ui_seat = FishingModel.GetSeatnoToPos(seat_num)
        for k,v in pairs(fish_list) do
            if ui_seat == 1 or ui_seat == 2 then
                if v.transform.position.x < p_instance.transform.position.x then
                    --不能攻击自己后面的鱼
                    table.remove( fish_list,k)
                else
                    
                end
            else
                if v.transform.position.x > p_instance.transform.position.x then
                    table.remove( fish_list,k)
                else
                    
                end
            end
        end
    end
    return fish_list
end

--根据玩家坐标选择自己座位号的鱼优先攻击的鱼
function M:CheckIsMySeatFish(fish_list,seat_num,p_instance)
    if fish_list and seat_num and p_instance then
        local is_have = false
        for k,v in pairs(fish_list) do
            if v.data.seat_num and v.data.seat_num == seat_num then
                is_have = true
                break
            end
        end
        if is_have then
            for k,v in pairs(fish_list) do
                if  not v.data.seat_num or v.data.seat_num ~= seat_num then
                    table.remove( fish_list,k)
                end
            end
        end
    end
    return fish_list
end

-----------------------------------------------------shoot
--选择鱼并开枪
function M:FrameUpdateShoot()
    if self.pasue_shoot_time and self.pasue_shoot_time > 0 then
        if self.pasue_shoot_time > self.cur_time then
            return
        else
            self.pasue_shoot_time = nil
        end
    end

    local s_d ,s_t = M.GetStatusData(self.config.player_speed.shoot,self.config.player_status.shoot,self.shoot_time,self.cur_time)
    --不生成子弹
    if not s_d then return end
    self:SavePlayerCurState("shoot",{s_d = s_d,s_t = s_t})
    self.shoot_time = s_t

    --没有鱼什么都不做
    if not self.fish_list then return end
    local s_fish = M.GetFishByStatus(self.fish_list,self.config.player_status,self.lock_id,self.aim_fish,self.player_instance)
    --没有选到鱼
    if not s_fish then return end
    self.aim_fish = M.SetAimFish(s_fish,self.aim_fish,self.config.player_status)
    M.ManualShoot(s_fish,self.player)
end

function M.ManualShoot(s_fish,p)
    if IsEquals(s_fish.transform) then
        local worldpos = s_fish:GetPos()
        if worldpos then
            -- worldpos = self.camera2d:ScreenToWorldPoint(worldpos)
            if p and p.isLock then
            else
                local data = {}
                data.seatno = p.base.seat_num
                data.vec = worldpos
                if data.vec then
                    Event.Brocast("ai_manual_shoot",data)
                end
            end
        end
    end
end

function M.SetAimFish(s_fish, aim_fish,status)
    if s_fish then
        --上次瞄准的鱼和这次选择的鱼不一样重置瞄准的鱼
        if aim_fish and aim_fish.aim_id ~= s_fish.data.fish_id then
            aim_fish = {}
        end
        aim_fish = aim_fish or {}
        aim_fish.aim_id = s_fish.data.fish_id
        if not aim_fish.shoot_num_id then
            aim_fish.shoot_num_id = math.random(1,#status.shoot_num)
        end
        if not aim_fish.shoot_num then
            aim_fish.shoot_num = 0
        end
        aim_fish.shoot_num = aim_fish.shoot_num + 1
    else
        aim_fish = nil
    end
    return aim_fish
end

function M.GetFishByStatus(fish_list,status,lock_id,aim_fish,p_instance)
    if not fish_list or not status then return nil end
    local s_fish
    --优先选择指定id的鱼
    if lock_id and lock_id > 0 then
        s_fish = M.GetFishByID(fish_list,lock_id)
        if not s_fish then
            lock_id = nil
        end
        return s_fish
    end
    --再选择上次打的鱼
    if aim_fish and aim_fish.shoot_num and aim_fish.shoot_num_id and status.shoot_num[aim_fish.shoot_num_id]
        and aim_fish.shoot_num < status.shoot_num[aim_fish.shoot_num_id].key then
        s_fish = M.GetFishByID(fish_list,aim_fish.aim_id)
        if s_fish then
            return s_fish
        end
    end
    --攻击确定类型的鱼
    if status.shoot_fish_type then
        local fish_type = Manager.GetRandomData(status.shoot_fish_type)
        if fish_type then
            s_fish = M.GetFishByType(fish_list,fish_type.key)
            if s_fish then
                return s_fish
            end
        end
    end
    --攻击确定倍率的鱼
    if status.shoot_fish_rate then
        local fish_rate = Manager.GetRandomData(status.shoot_fish_rate)
        if fish_rate then
            s_fish = M.GetFishByRate(fish_list,fish_rate.key)
            if s_fish then
                return s_fish
            end
        end
    end
    --攻击带特殊奖励的鱼
    if status.shoot_fish_award then
        local fish_award = Manager.GetRandomData(status.shoot_fish_award)
        if fish_award then
            s_fish = M.GetFishByAward(fish_list,fish_award.key)
            if s_fish then
                return s_fish
            end
        end
    end
    --攻击距离内的鱼
    if status.shoot_fish_dis then
        local fish_dis = Manager.GetRandomData(status.shoot_fish_dis)
        if fish_dis then
            s_fish = M.GetFishByDis(fish_list,fish_dis.key,p_instance)
            if s_fish then
                return s_fish
            end
        end
    end
    --随机给一条鱼
    s_fish =  M.GetFishForRandom(fish_list)
    return s_fish
end

-----------------------------------------------------change_gun
--根据外部环境升级枪
function M:FrameUpdateGun()
    local cur_event = FishingActivityManager.CheckIsGanChangeGun(self.player.base.seat_num)
    --活动时间不能切换
    if not cur_event or cur_event == 0 then return end
    local s_d, s_t = M.GetStatusData(self.config.player_speed.change_gun_level,self.config.player_status.change_gun_level,self.change_gun_time,self.cur_time)
    if not s_d or not s_d.key then return end
    self:SavePlayerCurState("gun",{s_d = s_d,s_t = s_t})
    self.change_gun_time = s_t
    local cur_level = M.GetCurGunLevel(self.player_instance)
    local base_index = (self.player.index / 10 or 0) * 10
    local tar_level = s_d.key + base_index
    local interval = M.ChangeGunLevel(tar_level, cur_level, self.player, self)
    self:RefreshPauseShootTime(interval)
end

function M.ChangeGunLevel(tar_level, cur_level, p, c_self)
    --目标等级和当前等级相同
    if not tar_level or not cur_level then return 0 end
    if cur_level == tar_level then return 0 end
    --超过枪的最大等级
    --if cfg.gun_max_level and cfg.gun_max_level < tar_level then return end
    local data = {}
    data.seat_num = p.base.seat_num
    data.level = tar_level
    data.is_up = tar_level > cur_level
    if c_self.change_gun_timer then
        c_self.change_gun_timer:Stop()
        c_self.change_gun_timer = nil
    end
    c_self.change_gun_timer = Timer.New(function ()
        if p then
            Event.Brocast("ai_change_gun_level",data)
        else
            if c_self.change_gun_timer then
                c_self.change_gun_timer:Stop()
                c_self.change_gun_timer = nil
            end
        end
    end,0.5,math.abs( tar_level - cur_level ))
    c_self.change_gun_timer:Start()
    return 0.5 * math.abs( tar_level - cur_level ) + 0.5
end

function M.SetGunLevel(tar_level, cur_level, p, c_self)
    --目标等级和当前等级相同
    if not tar_level or not cur_level then return 0 end
    if cur_level == tar_level then return 0 end
    --超过枪的最大等级
    --if cfg.gun_max_level and cfg.gun_max_level < tar_level then return end
    local base_index = (p.index / 10 or 0) * 10
    local data = {}
    data.seat_num = p.base.seat_num
    data.level = tar_level
    data.bullet_index = tar_level + base_index
    Event.Brocast("ai_set_gun_level",data)
    return 0.5
end

-----------------------------------------------------freed_skill
function M:FrameUpdateSkill()
    local s_d ,s_t = M.GetStatusData(self.config.player_speed.freed_skill,self.config.player_status.freed_skill,self.freed_skill_time,self.cur_time)
    if not s_d then return end
    self:SavePlayerCurState("skill",{s_d = s_d,s_t = s_t})
    self.freed_skill_time = s_t
    local t_id = s_d.key
    if not t_id then return end
    local is_can = M.CheckFreeSkill(s_d,self.player,self.fish_list)
    if not is_can then return end
    local skill_type = M.FreedSkill(t_id,self.player,self.fish_list)

    local interval = M.GetPauseShootInterval(1, skill_type)
    self:RefreshPauseShootTime(interval)
end

function M.CheckFreeSkill(s_d,p,fish_list)
    local t_id = s_d.key
    local is_can = false
    if t_id == 1 then
        if p.frozen_state then
            --自己可以使用且场上没有人使用的情况才能使用冰冻
            -- dump(FishingModel.GetSceneIceState(), "<color=green>当前场上的冰冻技能</color>")
            is_can = p.frozen_state == "nor" and FishingModel.GetSceneIceState() ~= "inuse" and M.CheckOther(s_d,fish_list)
        end
    elseif t_id == 2 then
        if p.lock_state then
            is_can = p.lock_state == "nor" and M.CheckOther(s_d,fish_list)
        end
    elseif t_id == 3 then
        if p.summon_state then
            is_can = p.summon_state == "nor" and M.CheckOther(s_d,fish_list)
        end
    elseif t_id == 4 then
        local bullet_cfg = FishingModel.GetGunCfg(p.index, p.base.seat_num)
        local cur = p.laser_rate or 0
        local max = bullet_cfg.laser_max_rate
        is_can = cur >= max and M.CheckOther(s_d,fish_list)
    elseif t_id == 6 then
        is_can = FishingActivityManager.CheckHaveBullet(p.base.seat_num)
    elseif t_id == 7 then
        is_can = FishingActivityManager.CheckHaveBullet(p.base.seat_num)
    end
    return is_can
end

function M.FreedSkill(t_id, p,fish_list)
    --响应技能是正在使用的技能
    if not t_id then return end
    local data = {}
    data.seat_num = p.base.seat_num
    local msg_type
    if t_id == 1 then
        msg_type = "frozen"
    elseif t_id == 2 then
        msg_type = "lock"
    elseif t_id == 3 then
        msg_type = "summon"
    elseif t_id == 4 then
        msg_type = "laser"
        local f, r = M.GetFishForRate(fish_list, ExpectType.max_rate)
        if f and IsEquals(f.transform) then
            data.vec = f.transform.position
        else
            local WDU = FishingModel.Defines.WorldDimensionUnit
            data.vec = Vector3.New(math.random(WDU.xMin,WDU.xMax),
                                    math.random(WDU.yMin,WDU.yMax))
        end
    elseif t_id == 6 then
        msg_type = "drill"
        local f, r = M.GetFishForRate(fish_list, ExpectType.max_rate)
        if f and IsEquals(f.transform) then
            data.vec = f.transform.position
        else
            local WDU = FishingModel.Defines.WorldDimensionUnit
            data.vec = Vector3.New(math.random(WDU.xMin,WDU.xMax),
                                    math.random(WDU.yMin,WDU.yMax))
        end
    elseif t_id == 7 then
        msg_type = "dcp"
        local f, r = M.GetFishForRate(fish_list, ExpectType.max_rate)
        if f and IsEquals(f.transform) then
            data.vec = f.transform.position
        else
            local WDU = FishingModel.Defines.WorldDimensionUnit
            data.vec = Vector3.New(math.random(WDU.xMin,WDU.xMax),
                                    math.random(WDU.yMin,WDU.yMax))
        end        
    end
    data.msg_type = msg_type
    if data.msg_type and data.seat_num then
        -- dump(data, "<color=yellow>使用技能</color>")
        Event.Brocast("ai_freed_skill",data)
    end
    return msg_type
end

----------------------------------------------------funtion
--type 1:技能
function M.GetPauseShootInterval(type, skill_type)
    if type == 1 then
        if skill_type == "frozen" then
            return 0
        elseif skill_type == "lock" then
            return 0
        elseif skill_type == "summon" then
            return 0
        elseif skill_type == "laser" then
            return math.random( 1, 3)
        end
    end
    return 0
end

function M.CheckOther(s_d,fish_list)
    dump(s_d.other, "<color=green>额外条件</color>")
    local is_can = false
    if s_d.other then
        local other = s_d.other
        if other.condition and other.condition == "and" then
            if fish_list then
                if other.fish_num then
                    is_can = other.fish_num <= #fish_list
                end
                if other.fish_rate then
                    local f, r = M.GetFishForRate(fish_list, ExpectType.max_rate)
                    if f and r then
                        is_can = is_can and other.fish_rate <= r
                    end
                end
                return is_can
            end
        else
            if fish_list then
                if other.fish_num then
                    is_can = other.fish_num <= #fish_list
                    return is_can
                end
                if other.fish_rate then
                    local f, r = M.GetFishForRate(fish_list, ExpectType.max_rate)
                    if f and r then
                        is_can = other.fish_rate <= r
                    end
                    return is_can
                end
            end
        end
    else
        is_can = true
    end
    return is_can
end

function M.CheckIsAction(cfg,act_time,cur_time)
    if not cfg then return end
    local is_can = false
    local time = cur_time
    if act_time then
        local _sp_cfg = Manager.GetRandomData(cfg)
        is_can = time - act_time > _sp_cfg.duration
    else
        is_can = true
    end
    return is_can ,time
end

function M.GetStatusData(sp_cfg,st_cfg,act_time,cur_time)
    if not sp_cfg or not st_cfg then return end
    local data
    local time = cur_time
    if act_time then
        local _sp_cfg = Manager.GetRandomData(sp_cfg)
        if time - act_time > _sp_cfg.duration then
            data = Manager.GetRandomData(st_cfg)
        end
    else
        data = Manager.GetRandomData(st_cfg)
    end
    return data, time
end

--get视野内的指定id的鱼 id为服务器生成
function M.GetFishByID(fish_list,id)
    for k,v in pairs(fish_list) do
       if id == v.data.fish_id then
            return v
       end
    end
    return nil
end

function M.GetFishByRate(fish_list,rate)
    for k,v in pairs(fish_list) do
        if rate == v:GetFishRate() then
            return v
        end
    end
    return nil
end

function M.GetFishByType(fish_list,_type)
    for k,v in pairs(fish_list) do
        if _type == v:GetFishType() then
            return v
        end
    end
    return nil
end

function M.GetFishByAward(fish_list,_type)
    for k,v in pairs(fish_list) do
        if _type == v:GetFishAward() then
            return v
        end
    end
    return nil
end

function M.GetFishByDis(fish_list,dis,p_instacne)
    local _v
    for k,v in pairs(fish_list) do
        if v and IsEquals(v.transform) then
            _v = Vector3.Distance(p_instacne.transform.position,v.transform.position)
            _v = _v / 200
            if _v <= dis then
                return v
            end
        end
    end
    return nil
end

--get倍数最大或最小的鱼
function M.GetFishForRate(fish_list,_type)
    if not fish_list then return end
    local max = {}
    local min = {}
    max.v = 0
    min.v = 999999999
    local _v
    for k,v in pairs(fish_list) do
        _v = v:GetFishRate()
        if _v then
            if _v > max.v then
                max.fish = v
                max.v = _v
            end
            if _v < min.v then
                min.fish = v
                min.v = _v
            end
        end
    end
    if _type == ExpectType.min_rate then
        return min.fish, min.v
    elseif _type == ExpectType.max_rate then
        return max.fish, max.v
    end
    return max.fish, max.v
end

--get距离最近或最远的鱼
function M.GetFishForDis(p_instance,fish_list,_type)
    local max = {}
    local min = {}
    max.v = 0
    min.v = 999999999
    local _v
    for k,v in pairs(fish_list) do
        if IsEquals(p_instance) and IsEquals(v.transform) then
            _v = Vector3.Distance(p_instance.transform.position,v.transform.position) / 200
            if _v > max.v then
                    max.v = _v
                    max.fish = v
            end
            if _v < min.v then
                    min.v = _v
                    min.fish = v
            end
        end
    end
    if _type == ExpectType.min_dis then
        return min.fish, min.v
    elseif _type == ExpectType.max_dis then
        return max.fish, max,v
    end
    return min.fish, min.v
end

--get存活最短或最长的鱼
function M.GetFishForLive(fish_list,_type)
    local max = {}
    local min = {}
    max.v = 0
    min.v = os.time()
    local _v
    for k,v in pairs(fish_list) do
       _v = v:GetFishLive()
       if _v > max.v then
            max.v = _v
            max.fish = v
       end
       if _v < min.v then
            min.v = _v
            max.fish = v
       end
    end
    if _type == ExpectType.min_live then
        return min.fish, min.v
    elseif _type == ExpectType.max_live then
        return max.fish, max.v
    end
    return min.fish, min.v
end

--get随机一条鱼
function M.GetFishForRandom(fish_list)
    local _v = #fish_list
    _v = math.random( 1,_v )
    return fish_list[_v]
end

function M.GetCurEvent(p)
    if not p or not p.base then return 0 end
    local act_type = FishingActivityManager.GetCurActivityType(p.base.seat_num)
    return act_type
end

function M.GetCurGold(p)
    if p and p.base then
        return p.base.score
    end
    return nil
end

function M.GetCurGunLevel(p_instance)
    if p_instance then
        return p_instance:GetCurGunLevel()
    end
    return nil
end

function M:RefreshPauseShootTime(interval)
    self.pasue_shoot_time = self.pasue_shoot_time or self.cur_time
    if not self.pasue_shoot_time then return end
    self.pasue_shoot_time = self.pasue_shoot_time + interval
end

function M:SavePlayerCurState(s_type,data)
    if self.player and self.player.base and self.player.base.seat_num then
        PlayerCurState[self.player.base.seat_num] = PlayerCurState[self.player.base.seat_num] or {}
        PlayerCurState[self.player.base.seat_num][s_type] = data
        PlayerCurState[self.player.base.seat_num].player_id = self.player.base.id
        PlayerCurState[self.player.base.seat_num][s_type].save_time = os.time()
    end
end

function M:GetPlayerCurState(s_type)
    if PlayerCurState[self.player.base.seat_num] and
       PlayerCurState[self.player.base.seat_num].player_id == self.player.base.id and
       PlayerCurState[self.player.base.seat_num][s_type] and
       os.time() >= PlayerCurState[self.player.base.seat_num][s_type].save_time and
       os.time() - PlayerCurState[self.player.base.seat_num][s_type].save_time < 20 then
        return PlayerCurState[self.player.base.seat_num][s_type]
    end
    PlayerCurState[self.player.base.seat_num][s_type] = nil
    return PlayerCurState[self.player.base.seat_num][s_type]
end

function M:CheckPlayerCurState(s_type)
    if PlayerCurState[self.player.base.seat_num] and
       PlayerCurState[self.player.base.seat_num].player_id == self.player.base.id and
       PlayerCurState[self.player.base.seat_num][s_type] and
       os.time() >= PlayerCurState[self.player.base.seat_num][s_type].save_time and
       os.time() - PlayerCurState[self.player.base.seat_num][s_type].save_time < 20 then
        return true
    end
    return false
end