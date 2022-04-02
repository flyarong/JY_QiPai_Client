-- 创建时间:2019-03-11
local basefunc = require "Game/Common/basefunc"

FishManager = {}
local C = FishManager

-- 数据
local FishDataTable = {}
local FishTable = {}
-- 鱼的父节点
local FishNodeTran
local FishGroupNodeTran

local cache_fish_map = {}

-- 实例化所有类型的鱼
function C.InstantiateFish(data)
    local fish
    local is_game_create = false
    if not FishingModel.IsRecoverRet then
        is_game_create = true
    end
    local tran = FishNodeTran
    -- if data.clear_level == 10 then
    --     tran = FishGroupNodeTran
    -- end
    
    -- 创建3D鱼
    if MainModel.myLocation == "game_Fishing3D" then
        if data.fish_style == "fish_team" then
            fish = FishTeam.Create(tran, data)
        else
            local use_fish_cfg = FishingModel.Config.use_fish_map[data.fish_type]
            if use_fish_cfg.fish_id == 30 then
                fish = Fish.Create(FishGroupNodeTran, data, is_game_create)
            elseif use_fish_cfg.fish_id == 32 then
                fish = FishCS.Create(tran, data)
            elseif use_fish_cfg.fish_id == 60 then
                fish = FishZcm.Create(tran, data)
            else
                fish = Fish.Create(tran, data, is_game_create)
            end
        end
        return fish
    end

    if data.fish_style == "fish_team" then
        fish = FishTeam.Create(tran, data)
    else
        local use_fish_cfg = FishingModel.Config.use_fish_map[data.fish_type]
        local fish_cfg = FishingModel.Config.fish_map[use_fish_cfg.fish_id]
        -- 宝箱鱼
        if use_fish_cfg.fish_id == 19 then
            fish = FishTreasureBox.Create(tran, data, is_game_create)
        elseif use_fish_cfg.fish_id == 21 then
            fish = FishBK.Create(tran, data)
        elseif use_fish_cfg.fish_id == 29 then
            fish = FishCS.Create(tran, data)
        elseif use_fish_cfg.fish_id == 60 then
            fish = FishZcm.Create(tran, data, is_game_create)
        else
            fish = Fish.Create(tran, data, is_game_create)
        end
    end
    return fish
end

function C.CreateFish(data)
    local cur_time = FishingModel.data.system_time
    local begin_time = FishingModel.data.begin_time
    if not begin_time then
        return
    end
    cur_time = cur_time - begin_time
    local fish_cstime = data.time / 10
    if fish_cstime <= cur_time then
        if (cur_time - fish_cstime) > 1000 then
            dump(data)
            print("<color=red>EEE time == " .. (cur_time - fish_cstime) .. "</color>")
            return true
        end
        local cfg = FishingModel.Config.steer_map[data.path]
        if not cfg then
            dump(data, "<color=red>特殊鱼创建</color>")
            cfg = FishingModel.ts_steer_map[data.path]
            if not cfg then
                -- cache_fish_map[data.fish_id] = nil
                dump(data.path, "<color=red>steer_map 没有这个key</color>")
                return true
            end
        end
        local use_fish_cfg
        if data.fish_type then
            use_fish_cfg = FishingModel.Config.use_fish_map[data.fish_type]
        else
            use_fish_cfg = FishingModel.Config.use_fish_map[data.type]
        end
        if not use_fish_cfg then
            dump(data.fish_type, "<color=red>use_fish_map 没有这个key</color>")
            return true
        end
        local fish_cfg = FishingModel.Config.fish_map[use_fish_cfg.fish_id]

        local m_vPos = {x=cfg.posX, y=cfg.posY}
        local m_vHeading = {x=cfg.headX, y=cfg.headY}
        m_vHeading = Vec2DNormalize(m_vHeading)
        local m_vSide = Vec2DPerp(m_vHeading)

        local pilot

        local steer
        if data.offset then
            m_vPos = {x=m_vPos.x + data.offset.x, y=m_vPos.y + data.offset.y}
            steer = {}
            for k1,v1 in ipairs(cfg.steer) do
                local vv = {}
                steer[#steer + 1] = vv
                for k3,v3 in ipairs(v1) do
                    vv[#vv + 1] = basefunc.deepcopy(v3)
                    if v3.type == 1 then
                        for k2,v2 in ipairs(vv[#vv].WayPoints) do
                            if data.group_id then
                                if k2 ~= 1 then
                                    local r = math.random(0, 200) % 4
                                    if r == 0 then
                                        v2.x = v2.x + data.offset.x
                                        v2.y = v2.y + data.offset.y
                                    elseif r == 1 then
                                        v2.x = v2.x + data.offset.x
                                        v2.y = v2.y - data.offset.y
                                    elseif r == 2 then
                                        v2.x = v2.x - data.offset.x
                                        v2.y = v2.y + data.offset.y
                                    else
                                        v2.x = v2.x - data.offset.x
                                        v2.y = v2.y - data.offset.y
                                    end
                                else
                                    v2.x = v2.x + data.offset.x
                                    v2.y = v2.y + data.offset.y
                                end
                            else
                                v2.x = v2.x + data.offset.x
                                v2.y = v2.y + data.offset.y
                            end
                        end
                    end
                end
            end
        else
            steer = cfg.steer
        end
        -- 创建领航员
        pilot = VehicleManager.Create(FishNodeTran, {ID=data.fish_id, m_vPos=m_vPos, m_vHeading=m_vHeading, m_vSide=m_vSide})
        for k1,v1 in ipairs(steer) do
            VehicleManager.AddSteerings(pilot, v1)
        end
        local speed
        if data.speed then
            speed = data.speed / 100
        else
            speed = fish_cfg.max_speed or 1
        end
        pilot:SetMaxSpeed(speed)
        pilot:Start()

        if not FishingModel.IsRecoverRet then
            local fish = C.InstantiateFish(data)
            if fish then
                VehicleManager.SetInstantiate(data.fish_id, fish)
                FishTable[data.fish_id] = fish
            end
        end

        local out = false
        local ct = cur_time-fish_cstime
        -- 断线重连考虑冰冻技能会停止鱼的游动
        if FishingModel.IsRecoverRet then
            if FishingModel.data.frozen_time_data and next(FishingModel.data.frozen_time_data) then
                for k,v in ipairs(FishingModel.data.frozen_time_data) do
                    local a = v
                    local b = v + FishingModel.Defines.IceIndate
                    if b > cur_time then
                        b = cur_time
                    end
                    if fish_cstime < a then
                        ct = ct - (b - a)
                    end
                end
            end
        end
        while (true) do
            if ct >= FishingModel.Defines.FrameTime then
                out = pilot:FrameUpdate(FishingModel.Defines.FrameTime)
                ct = ct - FishingModel.Defines.FrameTime
                if out then
                    break
                end
            else
                out = pilot:FrameUpdate(ct)
                break
            end
        end
        if out then
            Event.Brocast("fish_move_finish", "fish_move_finish", data.fish_id)
        end

        if FishingModel.IsRecoverRet and not out then
            local fish = C.InstantiateFish(data)
            if fish then
                VehicleManager.SetInstantiate(data.fish_id, fish)
                FishTable[data.fish_id] = fish
            end
        end
        return true
    else
        return false
    end
end

function C.FrameUpdate(time_elapsed)
    for k, v in pairs(FishTable) do
        if v.data.path then
            v:FrameUpdate(time_elapsed)
        end
    end

    if cache_fish_map and next(cache_fish_map) then
        for k,v in pairs(cache_fish_map) do
            if C.CreateFish(v) then
                cache_fish_map[k] = nil
            end
        end
    end
end

function C.Init(_fishNodeTran, _fishGroupNodeTran)
	FishTable = {}
	FishNodeTran = _fishNodeTran
    FishGroupNodeTran = _fishGroupNodeTran

	C.material1 = GetMaterial("matFish")
	C.material2 = GetMaterial("glittering")
end
function C.Exit()
    for k, v in pairs(FishTable) do
        v:MyExit()
    end
end

function C.GetFishNum()
    local num = 0
    for k, v in pairs(FishTable) do
        num = num + 1
    end
    return num
end

local local_nodata_fish_id = -1
function C.GetNoDataFishID()
    local frame_id = local_nodata_fish_id
    local_nodata_fish_id = local_nodata_fish_id - 1
    if local_nodata_fish_id < -10000000 then
        local_nodata_fish_id = -1
    end
    return frame_id
end

-- 添加没有数据的鱼
-- 目前使用在贝壳鱼活动中
function C.AddPrefabNoDataFish(prefab)
    local key = C.GetNoDataFishID()
    FishTable[key] = prefab
end
function C.GetBKFish(seat_num)
    local list = {}
    for k,v in pairs(FishDataTable) do
        if v.seat_num and v.fish_tag and v.fish_tag == "shell_fish" and v.seat_num == seat_num then
            list[#list + 1] = k
        end
    end
    return list
end
function C.GetFishDataByID(id)
    return FishDataTable[id]
end

-- 设置鱼的冰冻状态
function C.SetIceState(isIce)
    for k, v in pairs(FishTable) do
        v:SetIceState(isIce)
    end
end
function C.SetIceDeblocking()
    print("<color=red>播放冰冻解封</color>")
    for k, v in pairs(FishTable) do
        v:SetIceDeblocking()
    end
end

local flee_list = {}
function C.RemoveAllFlee()
    for k,v in ipairs(flee_list) do
        if FishTable[v] then
            FishTable[v]:MyExit()
            FishTable[v] = nil
        end
    end
    FishDataTable = {}
    flee_list = {}
end
-- 播放逃离
function C.PlayFlee(clear_level)
    for k, v in pairs(FishTable) do
        if v.data.clear_level <= clear_level then
            v:Flee()
            -- flee_list[#flee_list + 1] = k
        end
    end
end

-- 移除缓存区待创建的鱼
-- 一网打尽可能会死掉还没有创建的鱼
function C.RemoveCacheFish(id)
    if cache_fish_map[id] then
        print("<color=red>一网打尽可能会死掉还没有创建的鱼</color>")
    end
    cache_fish_map[id] = nil
end

-- 鱼组
function C.AddFishGroup(data)
    local use_fish_cfg = FishingModel.Config.use_fish_map[data.types[1]]
    if not use_fish_cfg then
        dump(data.types[1], "<color=red>use_fish_map 没有这个key</color>")
        return
    end

    local fish_cfg = FishingModel.Config.fish_map[use_fish_cfg.fish_id]
    if not fish_cfg then
        dump(use_fish_cfg, "<color=red>鱼不存在</color>")
        return
    end
    local offset_list = C.CalcRandomPos({w=fish_cfg.size_w, h=fish_cfg.size_h}, #data.ids)
    for k,v in ipairs(data.ids) do
        local var = {}
        var.fish_id = v
        var.fish_type = data.types[k]
        var.path = data.path
        var.time = data.time
        var.group_id = data.group_id
        var.offset = offset_list[k]
        var.speed = data.speed
        var.clear_level = data.clear_level
        var.ori_life = data.ori_lifes[k]
        var.seat_num = data.seat_num
        var.status = data.status
        var.rate = data.value
        
        FishDataTable[var.fish_id] = var
        if data.path then
            C.CloseFishByID(var.fish_id)
            if not C.CreateFish(var) then
                cache_fish_map[var.fish_id] = var
            end
        end
    end
end
-- 鱼组
function C.AddFishTeam(data)
    data.fish_style = "fish_team"
    data.type = 10
    if not data.fish_id then
        data.fish_id = data.id
    end
    FishDataTable[data.fish_id] = data
    if not C.CreateFish(data) then
        cache_fish_map[data.fish_id] = data
    end
end

-- 获得所有鱼池内所有鱼的ServerID
function C.GetAllFishID()
    local rtnTable = { }
    for k, v in pairs(FishTable) do
        if v:CheckIsInPool() then
            table.insert(rtnTable, k)
        end
    end
    return rtnTable
end

function C.GetAllFish()
	return FishTable
end

-- 获得分数值最大的鱼ID
function C.GetMaxScorePoolFish(seat_num)
    local rtnVal = nil
    for k, v in pairs(FishTable) do
        if (not v.data.seat_num or v.data.seat_num == seat_num) and v:CheckIsInPool_Whole() then
            if rtnVal == nil or rtnVal:GetFishRate() < v:GetFishRate() then
                rtnVal = v
            end
        end
    end
    return rtnVal
end

-- 根据ID获取鱼
function C.GetFishByID(_fishID)
    if _fishID then
        return FishTable[_fishID]
    end
end

-- 根据ID移除鱼
function C.RemoveFishByID(_fishID)
    if _fishID then
        FishTable[_fishID] = nil
        FishDataTable[_fishID] = nil
    end
end

-- 根据ID清除鱼
function C.CloseFishByID(_fishID)
    if FishTable[_fishID] then
        print("<color=red>警告警告警告警告警告警告警告警告警告警告警告警告警告警告警告</color>")
        FishTable[_fishID]:MyExit()
        FishTable[_fishID] = nil
    end
    FishDataTable[_fishID] = nil
end
-- 根据ID清除鱼
function C.FishMoveFinish(_fishID)
    if _fishID then
        if FishTable[_fishID] then
            FishTable[_fishID]:MyExit()
            FishTable[_fishID] = nil
        end
        FishDataTable[_fishID] = nil
        Event.Brocast("fish_move_finish", "fish_move_finish", _fishID)

        if Fishing3DSceneAnim then
            Fishing3DSceneAnim.FishMoveFinish(_fishID)
        end
    end
end

-- 开始鱼潮
function C.BeginFishWave()
end
-- 结束鱼潮
function C.EndFishWave()
end

-- 打印所有鱼
function C.Print()
	print("<color=red>XXXXXXXXXXXXXX打印所有鱼</color>")
    for k, v in pairs(FishTable) do
    	v:Print()
    end
end

-- 清除所有鱼
function C.RemoveAll()
    for k, v in pairs(FishTable) do
        v:MyExit()
    end
    FishTable = {}
    FishDataTable = {}
    cache_fish_map = {}
end

--鱼受击
function C.PlayFishSuffer(fish_list)
	for k,v in ipairs(fish_list) do
		if FishTable[v] then
			FishTable[v]:Hit()
		end
	end
end
--鱼的死亡消息(注意: 鱼可以死多次)
function C.S2CFishDead(fish_id, ZZ)
    local fish = FishManager.GetFishByID(fish_id)
    if fish then
        if fish.data.status then
            fish.data.status = fish.data.status - 1
            if fish.UpdateStatus then
                fish:UpdateStatus()
            end
        end
        if not fish.data.status or fish.data.status <= 0 then
            fish:Dead(nil, ZZ)
        end
    end
end

-- <<<<<<<<<<<<<<<<<<<<<<<<<<
-- 碰撞检查
-- <<<<<<<<<<<<<<<<<<<<<<<<<<
function C.CalcTrigger()
    
end

-- 计算鱼的随机分布
-- 鱼的大小(w, h) 鱼的数量
function C.CalcRandomPos(size, num)
    local pos_list = {}
    pos_list[#pos_list + 1] = {x=0, y=0}
    num = num - 1
    local ceng = 1
    local fang_xiang = {{1,0},{1,1},{0,1},{-1,1},{-1,0},{-1,-1},{0,-1},{1,-1}}
    while (num > 0) do
        local poss = {}
        local W = ceng * size.w
        local H = ceng * size.h * 0.6
        for i = 1, 8 do
            poss[#poss + 1] = {x=W*fang_xiang[i][1] + math.random(0,1)-0.5, y=H*fang_xiang[i][2]}
        end
        local zhengxing
        if num == 1 then
            zhengxing = {5}
        elseif num == 2 then
            zhengxing = {4,6}
        elseif num == 3 then
            zhengxing = {1,4,6}
        elseif num == 4 then
            zhengxing = {3,4,6,7}
        elseif num == 5 then
            zhengxing = {1,3,4,6,7}
        elseif num == 6 then
            zhengxing = {1,3,4,5,6,7}
        elseif num == 7 then
            zhengxing = {1,2,3,4,6,7,8}
        else
            zhengxing = {1,2,3,4,5,6,7,8}
        end

        for i = 1, #zhengxing do
            pos_list[#pos_list + 1] = poss[zhengxing[i]]
        end

        ceng = ceng + 1
        num = num - 8
    end
    return pos_list
end

function C.calc_fish_hit_list(fish_list, sx_cfg)
    local max_num = sx_cfg.max_fish
    local rateList = {}-- 每个倍率的鱼的数量和ids
    local rateMap = {}-- 倍率对应的rateList的index
    for k,v in ipairs(fish_list) do
        local fish = FishTable[v]
        if fish then
            local rate = fish:GetFishRate()
            if rateMap[rate] then
                rateList[rateMap[rate]].num = rateList[rateMap[rate]].num + 1
                rateList[rateMap[rate]].ids[#rateList[rateMap[rate]].ids + 1] = v
            else
                rateList[#rateList + 1] = {rate = rate, num=1, ids = {v}}
                rateMap[rate] = #rateList
            end
        end
    end
    -- 优先大鱼
    rateList = MathExtend.SortList(rateList, "rate", true)
    local cur_rate = 0
    local cur_list = {}-- 选择的鱼列表
    local cur_fish_index = #rateList
    local cur_rate_num = 0
    local ii = 1

    for i = #sx_cfg.multi_list, 1, -1 do
        ii = 1
        cur_rate_num = 0

        while(true) do
            -- print("<color=yellow>cur_fish_index</color>",cur_fish_index)
            local v = rateList[cur_fish_index]
            if not v then
                break
            end
            if sx_cfg.multi_list[i].min <= v.rate and v.rate <= sx_cfg.multi_list[i].max then
                cur_rate = cur_rate + v.rate
                v.num = v.num - 1
                cur_list[#cur_list + 1] = v.ids[ii]
                ii = ii + 1
                if ii > #v.ids then
                    cur_fish_index = cur_fish_index - 1
                    ii = 1
                end
                cur_rate_num = cur_rate_num + 1
                if cur_rate_num > sx_cfg.multi_list[i].num then
                    break
                end
                if #cur_list >= max_num then
                    break
                end

            elseif v.rate < sx_cfg.multi_list[i].min then
                break
            else
                cur_fish_index = cur_fish_index - 1
            end
            if cur_fish_index < 1 then
                break
            end
        end
        if #cur_list >= max_num then
            break
        end
        if cur_fish_index < 1 then
            break
        end
    end
    return cur_list
end

-- 计算炸弹鱼死亡时炸死的鱼
-- 炸弹鱼ID 座位号 爆炸点坐标
function C.CalcBoomFishHarm(fish_id, seat_num, pos, r)
    local sx_cfg = FishingModel.Config.fish_shaixuan_map["bomb"]
    r = r or 4
    local list = {}--爆炸范围内的所有鱼
    local cur_list = {}
    local vec1 = {x=pos.x, y=pos.y}
    for k,v in pairs(FishTable) do
        if (not fish_id or k ~= fish_id) and (not v.data.seat_num or v.data.seat_num == seat_num) and v:CheckIsInPool() then
            local vec2 = {x=v.transform.position.x, y=v.transform.position.y}
            if Vec2DLength(Vec2DSub(vec1, vec2)) <= r then
                list[#list + 1] = v.data.fish_id
            end
        end
    end
    cur_list = C.calc_fish_hit_list(list, sx_cfg)
    dump(cur_list, "<color=red>计算炸弹鱼死亡时炸死的鱼</color>")
    return cur_list
end
-- 计算炸弹爆炸范围内的所有鱼 
-- 目的是做鱼被炸开的表现，所以与座位号无关
function C.CalcBoomAllFish(pos)
    local sx_cfg = FishingModel.Config.fish_shaixuan_map["bomb"]
    local r = 4
    local list = {}--爆炸范围内的所有鱼
    local vec1 = {x=pos.x, y=pos.y}
    for k,v in pairs(FishTable) do
        if v:CheckIsInPool() and k ~= fish_id then
            local vec2 = {x=v.transform.position.x, y=v.transform.position.y}
            if Vec2DLength(Vec2DSub(vec1, vec2)) <= r then
                list[#list + 1] = v.data.fish_id
            end
        end
    end
    dump(list, "<color=red>计算炸弹鱼范围内的鱼</color>")
    return list
end

-- 计算极光弄死的鱼
-- 极光起点 极光的方向向量
function C.CalcLaserFishHarm(beginPos, vec, seat_num)
    local sx_cfg = FishingModel.Config.fish_shaixuan_map["layer"]
    local r = 16
    local list = {}
    for k,v in pairs(FishTable) do
        if (not v.data.seat_num or v.data.seat_num == seat_num) and v:CheckIsInPool() then
            local p = v.transform.position - beginPos
            local vec1 = {x=p.x, y=p.y}
            local len1 = Vec2DDotMult(vec1, vec)
            if len1 >= 0 then
                local r1 = (p.x * p.x + p.y * p.y) - (len1 * len1)
                if r1 <= r then
                    list[#list + 1] = k
                end
            end
        end
    end
    local cur_list = C.calc_fish_hit_list(list, sx_cfg)
    dump(cur_list, "<color=red>计算极光弄死的鱼</color>")
    return cur_list
end

-- 计算电击鱼死亡时炸死的鱼
-- 电击鱼ID 最大倍率
function C.CalcLightningFishHarm(fish_id, max_rate, seat_num, max_num)
    local max_num = max_num or 10
    local pj_rate = max_rate / max_num

    local rateList1 = {}
    local rateMap1 = {}
    local rateList2 = {}
    local rateMap2 = {}
    local all_rate = 0
    for k,v in pairs(FishTable) do
        if (not fish_id or k ~= fish_id) and (not v.data.seat_num or v.data.seat_num == seat_num) and
            (not v.data.ori_life or v.data.ori_life <= 0) and v:CheckIsInPool_Whole() then
            local rate = v:GetFishRate()
            all_rate = all_rate + rate
            if pj_rate > rate then
                if rateMap1[rate] then
                    rateList1[rateMap1[rate]].num = rateList1[rateMap1[rate]].num + 1
                    rateList1[rateMap1[rate]].ids[#rateList1[rateMap1[rate]].ids + 1] = k
                else
                    rateList1[#rateList1 + 1] = {rate = rate, num=1, ids = {k}}
                    rateMap1[rate] = #rateList1
                end
            else
                if rateMap2[rate] then
                    rateList2[rateMap2[rate]].num = rateList2[rateMap2[rate]].num + 1
                    rateList2[rateMap2[rate]].ids[#rateList2[rateMap2[rate]].ids + 1] = k
                else
                    rateList2[#rateList2 + 1] = {rate = rate, num=1, ids = {k}}
                    rateMap2[rate] = #rateList2
                end
            end
        end
    end
    rateList1 = MathExtend.SortList(rateList1, "rate")
    rateList2 = MathExtend.SortList(rateList2, "rate", true)
    for k,v in ipairs(rateList1) do
        local ff = MathExtend.RandomGroup(#v.ids)
        local ll = {}
        for k1,v1 in ipairs(ff) do
            ll[#ll + 1] = v.ids[v1]
        end
        v.ids = ll
    end
    for k,v in ipairs(rateList2) do
        local ff = MathExtend.RandomGroup(#v.ids)
        local ll = {}
        for k1,v1 in ipairs(ff) do
            ll[#ll + 1] = v.ids[v1]
        end
        v.ids = ll
    end

    local cur_list = {}
    if all_rate <= max_rate then -- 不超过最大倍率，直接全部选取
        for k,v in ipairs(rateList2) do
            if #v.ids >0 then
                for k1,v1 in ipairs(v.ids) do
                    cur_list[#cur_list + 1] = v1
                    if #cur_list >= max_num then
                        break
                    end
                end
            end
        end
        if #cur_list < max_num then
            for k,v in ipairs(rateList1) do
                for k1,v1 in ipairs(v.ids) do
                    cur_list[#cur_list + 1] = v1
                    if #cur_list >= max_num then
                        break
                    end
                end
            end
        end
    else
        local cur_rate = 0
        local min_index = 1
        local max_index = 1
        while(true) do
            if min_index <= #rateList1 then
                if (cur_rate + rateList1[min_index].rate) > max_rate then
                    min_index = min_index + 1
                else
                    if rateList1[min_index].num > 0 then
                        cur_rate = cur_rate + rateList1[min_index].rate
                        cur_list[#cur_list + 1] = rateList1[min_index].ids[rateList1[min_index].num]
                        rateList1[min_index].num = rateList1[min_index].num - 1
                        if rateList1[min_index].num < 1 then
                            min_index = min_index + 1
                        end
                    end
                end
            end
            if #cur_list >= max_num then
                break
            end
            if max_index <= #rateList2 then
                if (cur_rate + rateList2[max_index].rate) > max_rate then
                    -- 不用往后筛选了，因为后面的倍率更大
                    max_index = #rateList2 + 1
                else
                    if rateList2[max_index].num > 0 then
                        cur_rate = cur_rate + rateList2[max_index].rate
                        cur_list[#cur_list + 1] = rateList2[max_index].ids[rateList2[max_index].num]
                        rateList2[max_index].num = rateList2[max_index].num - 1
                        if rateList2[max_index].num < 1 then
                            max_index = max_index + 1
                        end
                    end
                end
            end
            if #cur_list >= max_num then
                break
            end
            if min_index > #rateList1 and max_index > #rateList2 then
                break
            end
        end
    end
    dump(cur_list, "<color=red>计算电击鱼死亡时炸死的鱼</color>")
    return cur_list
end

-- 计算核弹弄死的鱼
-- 核弹爆炸点 核弹爆炸半径
function C.CalcMissileFishHarm(pos, r, seat_num)
    local sx_cfg = FishingModel.Config.fish_shaixuan_map["bomb"]
    local r = 5
    local list = {}--爆炸范围内的所有鱼
    local fish = FishTable[fish_id]
    local vec1 = {x=fish.transform.position.x, y=fish.transform.position.y}
    for k,v in pairs(FishTable) do
        if k ~= fish_id and (not v.data.seat_num or v.data.seat_num == seat_num) and v:CheckIsInPool() then
            local vec2 = {x=v.transform.position.x, y=v.transform.position.y}
            if Vec2DLength(Vec2DSub(vec1, vec2)) <= r then
                list[#list + 1] = v.data.fish_id
            end
        end
    end
    local cur_list = C.calc_fish_hit_list(list, sx_cfg)
    dump(cur_list, "<color=red>计算核弹弄死的鱼</color>")
    return cur_list
end

-- 计算子弹伤害
function C.CalcBulletHarm(fish_id, pos, seat_num)
    local sx_cfg = FishingModel.Config.fish_shaixuan_map["gun"]
    local r = 1.5
    local list = {}
    local cur_list = {}
    local vec1 = {x=pos.x, y=pos.y}
    for k,v in pairs(FishTable) do
        if k ~= fish_id and (not v.data.seat_num or v.data.seat_num == seat_num) and v:CheckIsInPool() and fish_id then
            local vec2 = {x=v.transform.position.x, y=v.transform.position.y}
            if Vec2DLength(Vec2DSub(vec1, vec2)) <= r then
                list[#list + 1] = v.data.fish_id
            end
        end
    end
    cur_list = C.calc_fish_hit_list(list, sx_cfg)
    if fish_id then
        cur_list[#cur_list + 1] = fish_id
    end
    return cur_list
end

-- 计算全屏炸弹炸死的鱼
function C.CalcQPBoomHarm(seat_num)
    seat_num = seat_num or 1
    local sx_cfg = FishingModel.Config.fish_shaixuan_map["qp_bomb"]
    local r = 4
    local list = {}--爆炸范围内的所有鱼
    local cur_list = {}
    for k,v in pairs(FishTable) do
        if (not v.data.seat_num or v.data.seat_num == seat_num) and v:CheckIsInPool() then
            list[#list + 1] = v.data.fish_id
        end
    end
    cur_list = C.calc_fish_hit_list(list, sx_cfg)
    dump(cur_list, "<color=red>计算全屏炸弹炸死的鱼</color>")
    return cur_list
end

-- 计算全屏激光炸死的鱼
function C.CalcQPLaserHarm(fish_id, max_rate, seat_num, max_num)
    return C.CalcLightningFishHarm(fish_id, max_rate, seat_num, max_num)
end

-- 计算全屏炸弹炸死的鱼
function C.CalcQPMinBoomHarm(seat_num)
    seat_num = seat_num or 1
    local sx_cfg = FishingModel.Config.fish_shaixuan_map["lower_qp_bomb"]
    local r = 4
    local list = {}--爆炸范围内的所有鱼
    local cur_list = {}
    for k,v in pairs(FishTable) do
        if (not v.data.seat_num or v.data.seat_num == seat_num) and v:CheckIsInPool() then
            list[#list + 1] = v.data.fish_id
        end
    end
    cur_list = C.calc_fish_hit_list(list, sx_cfg)
    dump(cur_list, "<color=red>计算全屏炸弹炸死的鱼</color>")
    return cur_list
end

-- 计算全屏激光炸死的鱼
function C.CalcQPLaserHarm(fish_id, max_rate, seat_num, max_num)
    return C.CalcLightningFishHarm(fish_id, max_rate, seat_num, max_num)
end
