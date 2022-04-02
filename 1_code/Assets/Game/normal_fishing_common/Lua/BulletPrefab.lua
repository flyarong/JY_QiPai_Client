-- 创建时间:2019-03-11
-- 子弹

local basefunc = require "Game.Common.basefunc"

BulletPrefab = basefunc.class()

local C = BulletPrefab

C.name = "BulletPrefab"

local instance
function C.Create(parent, data)
    return C.New(parent, data)
end

function C:Awake()
end

function C:Start()
end

--[[

    id 子弹ID
    seat_num 用户座位号
    IsRobot 是否是机器人
    lock_fish_id 被锁定鱼的ID，没有则为空
--]]
function C:ctor(parent, data)
    for k,v in pairs(data) do
        self[k] = v
    end

    local userdata = FishingModel.GetSeatnoToUser(self.seat_num)
    local gun_config = FishingModel.GetGunSkinCfg(self.seat_num, userdata.index)

    local index = FishingModel.GetGunIdToIndex(userdata.index)
    if data.type then
        if data.type == 2 then
            self.prefab = CachePrefabManager.Take("BulletPrefab_cjhl")
        elseif data.type == 1 then            
            local rate = index > 5 and 2 or 1
            rate = 2-- rate or 1
            if rate == 1 then
                self.prefab = CachePrefabManager.Take("BulletPrefab_free1")
            else
                self.prefab = CachePrefabManager.Take("BulletPrefab_free2")
            end
        elseif data.type == 3 then
            self.prefab = CachePrefabManager.Take("BulletPrefab_sbsk")
        elseif data.type == 4 then
            self.prefab = CachePrefabManager.Take("BulletPrefab_f_cs")
        elseif data.type == 6 then
            self.prefab = CachePrefabManager.Take("BulletPrefab_gd")
        else
            if gun_config.bullet_prefab then
                self.prefab = CachePrefabManager.Take(gun_config.bullet_prefab)
            else
                self.prefab = CachePrefabManager.Take("BulletPrefab_" .. index)
            end
        end
    else
        if gun_config.bullet_prefab then
            self.prefab = CachePrefabManager.Take(gun_config.bullet_prefab)
        else
            self.prefab = CachePrefabManager.Take("BulletPrefab_" .. index)
        end
    end

    self.bulled_speed = FishingModel.Defines.BulledSpeed
    if gun_config.bullet_move_speed and gun_config.bullet_move_speed > 0 then
        self.bulled_speed = gun_config.bullet_move_speed
    end
    
    self.prefab.prefab:SetParent(parent)
    local tran = self.prefab.prefab.prefabObj.transform
    self.transform = tran
    self.gameObject = tran.gameObject
    self.transform.rotation = Quaternion.Euler(0, 0, self.angle)
    self.transform.position = self.pos
    self:MakeLister()
    self:AddMsgListener()

    tran:GetComponent("LuaBehaviour").luaTable = self

    if self:IsDebug() then
        local obj = GameObject.New()
        obj.name = "bullet_debug"
        self.debug_txt = obj.gameObject:AddComponent(typeof(UnityEngine.UI.Text))
        obj.transform:SetParent(self.transform)

        self.debug_obj = obj

        local ss = ""
        self.debug_txt.text = ""
        ss = ss .. "id=" .. self.id .. " "
        ss = ss .. "seat_num=" .. self.seat_num .. " "
        if self.num then
            ss = ss .. "num=" .. self.num .. " "
        else
            ss = ss .. "num=nil "
        end
        ss = ss .. "type=" .. data.type .. "\n"
        self.debug_txt.text = ss
    end

    self.tongbian_num = 0

    
    self.gameObject.name = self.id
    self.gameObject:SetActive(true)

    self.fishList = { }--碰撞到的鱼列表

    self.parent = parent
    self.lineType = 0-- 0无 1上 2下 3左 4右
    self.isSendFishList = false
    -- 鱼的ID不为负
    if self.lock_fish_id and self.lock_fish_id <= 0 then
        self.lock_fish_id = nil
    end    
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:FrameUpdate(time_elapsed)
    if self.isSendFishList then
        if self:IsDebug() then
            local ss = ""
            for _,v in ipairs(self.fishList) do
                ss = ss .. v .. " "
            end
            self.debug_txt.text = self.debug_txt.text .. "发送列表=" .. ss .. "\n"
        end
        FishingModel.SendBulletBoom( { seat_num = self.seat_num, id = self.id, fish_list = self.fishList})
        self.fishList = {}
        self.isSendFishList = false
        if not self.num or (self.num <= 0) then
            if self:IsDebug() then
                self.debug_txt.text = self.debug_txt.text .. "设置隐藏" .. "\n"
            end
            BulletManager.SetHideBullet(self.id)
        end
        return
    end
    if self.stop then
        return
    end
    local ct = time_elapsed
    while (true) do
        if ct >= FishingModel.Defines.FrameTime then
            self:RunCalc(FishingModel.Defines.FrameTime)
            ct = ct - FishingModel.Defines.FrameTime
        else
            if ct > 0.01 then
                self:RunCalc(ct)
            end
            break
        end
    end
end
function C:LS_tongbianchuli()
    if self.tongbian_num > 5 then
        print("<color=red><size=15>LS_tongbianchuli</size></color>")
        -- if true then
        --     dump(self)
        --     dump(self.transform.localPosition)
        --     dump(self.transform.up)
        --     dump(self.bulled_speed)
        --     dump(self.lineType)
        --     dump(self.angle)
        --     self.stop = true
        --     return
        -- end
        self.tongbian_num = 0
        self.lineType = 0
        self.transform.localPosition = Vector3.zero
    end
end
function C:RunCalc(time_elapsed)
    self.transform.localPosition = self.transform.localPosition + self.transform.up * time_elapsed * self.bulled_speed

    -- 子弹两帧都在某一边外边是因为在四个角的位置有可能出现子弹同时超过两边的坐标，这样下一帧折射回来的时候就还会在某一边的外
    if self.transform.localPosition.x > FishingModel.Defines.WorldDimensionUnit.xMax or self.transform.localPosition.x < FishingModel.Defines.WorldDimensionUnit.xMin then
        self.lock_fish_id = nil
        -- 碰撞四周后取消锁定
        if (self.transform.localPosition.x > FishingModel.Defines.WorldDimensionUnit.xMax and self.lineType == 1) or
            (self.transform.localPosition.x < FishingModel.Defines.WorldDimensionUnit.xMin and self.lineType == 2) then
                self.tongbian_num = self.tongbian_num + 1
                self:LS_tongbianchuli()
            return
        end
        self.tongbian_num = 0
        if self.transform.localPosition.x > FishingModel.Defines.WorldDimensionUnit.xMax then
            self.lineType = 1
        end
        if self.transform.localPosition.x < FishingModel.Defines.WorldDimensionUnit.xMin then
            self.lineType = 2
        end
        self.angle = - self.angle
        self.transform.rotation = Quaternion.Euler(0, 0, self.angle)
        return
    end
    if self.transform.localPosition.y > FishingModel.Defines.WorldDimensionUnit.yMax or self.transform.localPosition.y < FishingModel.Defines.WorldDimensionUnit.yMin then
        self.lock_fish_id = nil
        -- 碰撞四周后取消锁定
        if (self.transform.localPosition.y > FishingModel.Defines.WorldDimensionUnit.yMax and self.lineType == 4) or
            (self.transform.localPosition.y < FishingModel.Defines.WorldDimensionUnit.yMin and self.lineType == 3) then
                self.tongbian_num = self.tongbian_num + 1
                self:LS_tongbianchuli()
            return
        end
        self.tongbian_num = 0
        if self.transform.localPosition.y > FishingModel.Defines.WorldDimensionUnit.yMax then
            self.lineType = 4
        end
        if self.transform.localPosition.y < FishingModel.Defines.WorldDimensionUnit.yMin then
            self.lineType = 3
        end
        self.angle = 180 - self.angle
        self.transform.rotation = Quaternion.Euler(0, 0, self.angle)
        return
    end
end

function C:IsDebug()
    if FishingModel.isDebug and self.type and self.type == 6 then
        return true
    end
end
function C:Print()
    print("BulletID=" .. self.id .. " Pos x=" .. self.transform.position.x .. " y=" .. self.transform.position.y)
end
function C:TiHuan(tt)
    if self:IsDebug() then
        self.debug_txt.text = self.debug_txt.text .. "被替换" .. tt .. "\n"
    end
end
-- 更新子弹的ID，客户端先创建自己的子弹，再发送消息给服务器，等服务器返回子弹ID再做更新。优化子弹发射卡顿问题。
function C:SetBulledData(data)
    self.id = data.id
    self.type = data.type
    self.gameObject.name = self.id
    if self:IsDebug() then
        self.debug_txt.text = self.debug_txt.text .. "更新id=" .. self.id .. "\n"
    end
end
-- 碰撞检测
function C:OnTriggerEnter2D(collision)
    -- 子弹为负值碰撞有bug，钢弹可以碰撞多次
    -- 但是BulletManager.SendTriggerFishMap是存的map，客户端在为负数期间如果碰撞多次
    -- 等子弹验证通过后只会发送一次碰撞给服务器，导致钢弹活动无法结束
    -- 本次改动仅针对钢弹做处理
    if self.id < 0 and self.type == 6 then
        return
    end
    if self.isSendFishList then
        return
    end
    local name = collision.transform.name
    local fish_id = tonumber(name)
    local fish = FishManager.GetFishByID(fish_id)
    if self.type == 6 then
        if not fish or not (not fish.data.seat_num or fish.data.seat_num == self.seat_num) then        
            return
        end
        if self.num then
            self.num = self.num - 1
        end
        self.fishList[#self.fishList + 1] = fish_id
    else
        if self.lock_fish_id and self.lock_fish_id ~= fish_id then
            return
        end
        if self.lock_fish_id then
            self.fishList[#self.fishList + 1] = fish_id
        else
            if fish and (not fish.data.seat_num or fish.data.seat_num == self.seat_num) then
                self.fishList = FishManager.CalcBulletHarm(fish_id, self.transform.position, self.seat_num)
            else
                return
            end
        end
    end

    if self:IsDebug() then
        local ss = ""
        for _,v in ipairs(self.fishList) do
            ss = ss .. v .. " "
        end
        self.debug_txt.text = self.debug_txt.text .. "num=" .. self.num .. "  trigger=" .. ss .. "\n"
    end

    self.isSendFishList = true
end

function C:MyExit()
    if self:IsDebug() then
        print("<color=red>MyExit Bullet</color>\n" .. self.debug_txt.text)
        destroy(self.debug_obj)
    end

    self:RemoveListener()
    BulletManager.RemoveBullet(self.id)
    if self.b_p then
        CachePrefabManager.Back(self.b_p)
    end
    CachePrefabManager.Back(self.prefab)
end