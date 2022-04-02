-- 创建时间:2019-03-11

BulletManager = {}

local C = BulletManager
-- 本地临时子弹ID，发射子弹立刻生成子弹，不用等服务器返回
local NextBulletID = 0
-- 子弹列表
local BulletMap = {}
-- 隐藏的子弹列表
local HideBulletMap = {}
-- 待发送的子弹碰撞消息(子弹碰撞时子弹的服务器确认消息还未到达)
local SendTriggerFishMap = {}
local BulletNodeTran

function C.Init(bullet_node_list)
	BulletNodeTran = bullet_node_list
end
function C.Exit()
    C.RemoveAll()
    BulletNodeTran = nil
end

function C.FrameUpdate(time_elapsed)
    for k, v in pairs(BulletMap) do
        if v ~= nil then
            v.bulletSpr:FrameUpdate(time_elapsed)
        end
    end
end

function C.AddSendTriggerFishMap(data)
    if not SendTriggerFishMap[data.Boom.seat_num] then
        SendTriggerFishMap[data.Boom.seat_num] = {}
    end
    SendTriggerFishMap[data.Boom.seat_num][data.Boom.id] = data
end
function C.CloseSendTriggerFishMap(seat_num)
    SendTriggerFishMap[seat_num] = {}
end

-- 管理自己子弹ID
function C.GetNextBulletID()
    NextBulletID = NextBulletID - 1
    return NextBulletID
end

-- 添加子弹
function C.AddBullet(data)
	BulletMap[data.id] = data
end
-- 删除子弹
function C.RemoveBullet(bulletId)
	if BulletMap[bulletId] then
		local obj = BulletMap[bulletId].Obj
        BulletMap[bulletId] = nil
        return obj
	end
	if HideBulletMap[bulletId] then
		local obj = HideBulletMap[bulletId].Obj
        HideBulletMap[bulletId] = nil
        return obj
	end
end
-- 获取对应座位号的子弹数量
function C.GetBulletNumber(seat_num)
    local nn = 0
    for k, v in pairs(BulletMap) do
        if v.seat_num == seat_num then
            nn = nn + 1
        end
    end
    -- 隐藏子弹也算，隐藏的子弹是发射了碰撞信息的子弹
    for k, v in pairs(HideBulletMap) do
        if v.seat_num == seat_num then
            nn = nn + 1
        end
    end
    return nn
end

-- 根据子弹ID获取子弹数据
function C.GetIDToBullet(bulletId)
	if BulletMap[bulletId] then
		return BulletMap[bulletId]
	end
	if HideBulletMap[bulletId] then
		return HideBulletMap[bulletId]
	end
end

-- 子弹消耗的钱
function C.GetBulledXHMoney(data)
    if data.type and (data.type == 1 or data.type == 7) then
        return 0
    end
    local gun_config = FishingModel.GetGunCfg(data.index)
    return gun_config.gun_rate
end
-- 更新子弹数据
-- -999钱不够 -998座位号异常 -997index不对
function C.UpdateBulledID(data)
    if data.id == -998 then
        Event.Brocast("fsg_leave_msg", "fsg_leave_msg", {seat_num = data.seat_num})
    end
    if BulletMap[data.id] and BulletMap[data.id].bulletSpr and BulletMap[data.id].bulletSpr.TiHuan then
        print("<color=red>1111 OOOOOOOOOOOOOOOOOOOOOOO</color>")
        BulletMap[data.id].bulletSpr:TiHuan("BulletMap")
    end
    if HideBulletMap[data.id] and HideBulletMap[data.id].bulletSpr and HideBulletMap[data.id].bulletSpr.TiHuan then
        print("<color=red>2222 OOOOOOOOOOOOOOOOOOOOOOO</color>")
        HideBulletMap[data.id].bulletSpr:TiHuan("HideBulletMap")
    end

    local is_bullet_xt = function (v1, v2)
        if v1.seat_num == v2.seat_num and v1.index == v2.index and ((not v1.type and not v2.type) or (v1.type and v2.type and v1.type == v2.type) ) then
            return true
        end
    end
    if data.rate then
        if BulletMap[data.rate] then
            if SendTriggerFishMap[data.seat_num] and SendTriggerFishMap[data.seat_num][data.rate] then
                -- 子弹碰撞数据
                local sendData = SendTriggerFishMap[data.seat_num][data.rate]
                sendData.Boom.id = data.id
                sendData.Boom.type = data.type
                FishingModel.C2SFrameMessage(sendData)
                SendTriggerFishMap[data.seat_num][data.rate] = nil
            end
            local v = BulletMap[data.rate]
            local bd = C.GetBulledXHMoney(v)
            v.id = data.id
            v.index = data.index
            v.type = data.type
            local fd = C.GetBulledXHMoney(v)
            if bd ~= fd then
                Event.Brocast("ui_bullet_scale_s2c", data.seat_num, (bd - fd))
            end
            BulletMap[v.id] = v
            BulletMap[data.rate] = nil
            if v.id <= 0 then
                dump(data, "<color=red>服务器返回的子弹ID有问题</color>")
                C.CloseBullet(v.id)
            else
                v.bulletSpr:SetBulledData(data)
            end
            return
        end
        if HideBulletMap[data.rate] then
            if SendTriggerFishMap[data.seat_num] and SendTriggerFishMap[data.seat_num][data.rate] then
                -- 子弹碰撞数据
                local sendData = SendTriggerFishMap[data.seat_num][data.rate]
                sendData.Boom.id = data.id
                sendData.Boom.type = data.type
                FishingModel.C2SFrameMessage(sendData)
                SendTriggerFishMap[data.seat_num][data.rate] = nil
            end
            local v = HideBulletMap[data.rate]
            local bd = C.GetBulledXHMoney(v)
            v.id = data.id
            v.index = data.index
            v.type = data.type
            local fd = C.GetBulledXHMoney(v)
            if bd ~= fd then
                local user = FishingModel.GetSeatnoToUser(data.seat_num)
                Event.Brocast("ui_bullet_scale_s2c", data.seat_num, (bd - fd))
            end
            HideBulletMap[v.id] = v
            HideBulletMap[data.rate] = nil
            if v.id <= 0 then
                dump(data, "<color=red>服务器返回的子弹ID有问题</color>")
                C.CloseBullet(v.id)
            else
                v.bulletSpr:SetBulledData(data)
            end
            return
        end
    else
        dump(data)
        print("<color=red>DDDDDDDDDDDDDDD</color>")
    end

    if FishingModel.IsRecoverRet then
        C.CreateBullet(data)
        return
    end
    print("<color=red>MMMMMMMMMMMM XXXXXXXXXXXXX OOOOOOOOOOO</color>")
    dump(data)
    dump(BulletMap)
    dump(HideBulletMap)
end

-- 设置子弹的隐藏
function C.SetHideBullet(bulletId)
	if BulletMap[bulletId] then
        local v = BulletMap[bulletId]
		local obj = v.bulletSpr.gameObject
        obj.transform.gameObject:SetActive(false)
        HideBulletMap[bulletId] = v
        BulletMap[bulletId] = nil
	end
end

-- 是不是自己的子弹
function C.IsPlayerBullet(id)
	local seat_num = FishingModel.GetPlayerSeat()
    local bulled = C.GetIDToBullet(id)
    if bulled ~= nil then
        if bulled.seat_num == seat_num then
            return true
        end
    end
end

-- 服务器验证通过-子弹碰撞事件
function C.S2CBulletCrash(id)
    local bullet = C.GetIDToBullet(id)
    if bullet then
        if bullet.num and bullet.num > 0 then
            bullet.num = bullet.num - 1
        end
        if not bullet.num or bullet.num <= 0 then
            bullet.bulletSpr:MyExit()
            if BulletMap[id] then
                BulletMap[id] = nil
            end
            if HideBulletMap[id] then
                HideBulletMap[id] = nil
            end
        end
    end
end
-- 根据ID回收(或者清除)子弹
function C.CloseBullet(id)
    local bullet = C.GetIDToBullet(id)
    if bullet then
        bullet.bulletSpr:MyExit()
        if BulletMap[id] then
            BulletMap[id] = nil
        end
        if HideBulletMap[id] then
            HideBulletMap[id] = nil
        end
    end
end
-- 创建子弹(玩家座位号，子弹类型，x，y，lock_fish_id)
function C.CreateBullet(data)
    if not data.angle then
        local panel = FishingLogic.GetPanel()
        local uipos = FishingModel.GetSeatnoToPos(data.seat_num)

        local pos = panel.PlayerClass[uipos]:GetBulletPos()
        local dirVec = {x = data.x, y = data.y}
        local r = Vec2DAngle(dirVec)
        local rr = r - 90
        data.angle = rr
        data.pos = pos
    end

    local cur_time = tonumber(FishingModel.data.system_time)
    local begin_time = tonumber(FishingModel.data.begin_time)
    if not begin_time then
        return
    end
    if not cur_time then
        return
    end
    cur_time = cur_time - begin_time
    
    -- 本地创建6号子弹
    if not data.num and data.type == 6 then
        data.num = FishingActivityManager.GetBulletCrash({seat_num=data.seat_num})
    end

	if not data.id then
		data.id = C.GetNextBulletID()
	end
    if not C.GetIDToBullet(data.id) then
        local pre
        if data.type == 5 then
            pre = BulletPrefabZT.Create(BulletNodeTran[data.seat_num], data)
        else
            pre = BulletPrefab.Create(BulletNodeTran[data.seat_num], data)
        end

        local mm = {}
        mm.bulletSpr = pre
        mm.id = data.id
        mm.index = data.index
        mm.seat_num = data.seat_num
        mm.type = data.type
        mm.num = data.num
        mm.Obj = pre.gameObject
        if data.time and (cur_time - data.time) > 1000 then
            print("<color=red>EEE time == " .. (cur_time - data.time) .. "</color>")
            FishingModel.SendBulletBoom( { seat_num = data.seat_num, id = data.id, fish_list = {} })
            pre:MyExit()
            return
        end
        C.AddBullet(mm)

        if data.time then
            local ct = cur_time - data.time
            while (true) do
                if ct >= FishingModel.Defines.FrameTime then
                    pre:FrameUpdate(FishingModel.Defines.FrameTime)
                    ct = ct - FishingModel.Defines.FrameTime
                else
                    if ct > 0 then
                        pre:FrameUpdate(ct)
                    end
                    break
                end
            end
        end
    else

    end
end

function C.RemoveAll()
    for k,v in pairs(BulletMap) do
        v.bulletSpr:MyExit()
    end
    for k,v in pairs(HideBulletMap) do
        v.bulletSpr:MyExit()
    end

    NextBulletID = 0
    BulletMap = {}
    HideBulletMap = {}
    SendTriggerFishMap = {}
end

-- 移除某个座位号的子弹数据
function C.RemoveBulletBySeatno(seat_num)
    for k,v in pairs(BulletMap) do
        if v.seat_num == seat_num then
            v.bulletSpr:MyExit()
            BulletMap[k] = nil
        end
    end
    for k,v in pairs(HideBulletMap) do
        if v.seat_num == seat_num then
            v.bulletSpr:MyExit()
            HideBulletMap[k] = nil
        end
    end
    SendTriggerFishMap[seat_num] = nil
end
