-- 创建时间:2019-08-27
-- 钻头子弹

local basefunc = require "Game.Common.basefunc"

BulletPrefabZT = basefunc.class()

local C = BulletPrefabZT

C.name = "BulletPrefabZT"

BulletPrefabZT.BulletState = {
	BS_DJ = "待机",
	BS_Nor = "常态",
	BS_Unnor = "不稳定态",
	BS_Boom = "爆炸态",
}

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
    local gun_config = FishingModel.GetGunCfgByPlayer(userdata)

    local index = FishingModel.GetGunIdToIndex(userdata.index)
    if FishingModel.is3D then
        self.prefab = CachePrefabManager.Take("BulletPrefab_zt1", parent)
    else
        self.prefab = CachePrefabManager.Take("BulletPrefab_zt", parent)
    end

    self.bulled_speed = FishingModel.Defines.BulledSpeed
    if gun_config.bullet_move_speed and gun_config.bullet_move_speed > 0 then
        self.bulled_speed = gun_config.bullet_move_speed
    end

    local tran = self.prefab.prefab.prefabObj.transform
    self.transform = tran
    self.gameObject = tran.gameObject
    self.gameObject:SetActive(false)
    self.transform.rotation = Quaternion.Euler(0, 0, self.angle)
    self.transform.position = self.pos
    self:MakeLister()
    self:AddMsgListener()

    self.BulletImage = tran:Find("BulletImage"):GetComponent("SpriteRenderer")
    self.Trail = tran:Find("Trail")
    self.box2d = tran:GetComponent("BoxCollider2D")

    tran:GetComponent("LuaBehaviour").luaTable = self
    
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
    self.state = BulletPrefabZT.BulletState.BS_DJ
    self:SetBox2D(false)
    self.Trail.gameObject:SetActive(false)
end
function C:SetBox2D(b)
	self.box2d.enabled = b
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
	if self.state == BulletPrefabZT.BulletState.BS_DJ then
		self.state = BulletPrefabZT.BulletState.BS_Nor
		self:SetBox2D(true)
		self.Trail.gameObject:SetActive(true)
		return
	end
    if self.isSendFishList then
        FishingModel.SendBulletBoom( { seat_num = self.seat_num, id = self.id, fish_list = self.fishList})
        self.fishList = {}
        self.isSendFishList = false
        -- return
    end
    
    self.transform.localPosition = self.transform.localPosition + self.transform.up * time_elapsed * self.bulled_speed

    -- 子弹两帧都在某一边外边是因为在四个角的位置有可能出现子弹同时超过两边的坐标，这样下一帧折射回来的时候就还会在某一边的外
    if self.transform.localPosition.x > FishingModel.Defines.WorldDimensionUnit.xMax or self.transform.localPosition.x < FishingModel.Defines.WorldDimensionUnit.xMin then
        self.lock_fish_id = nil
        -- 碰撞四周后取消锁定
        if (self.transform.localPosition.x > FishingModel.Defines.WorldDimensionUnit.xMax and self.lineType == 1) or
            (self.transform.localPosition.x < FishingModel.Defines.WorldDimensionUnit.xMin and self.lineType == 2) then
            return
        end
        if self.transform.localPosition.x > FishingModel.Defines.WorldDimensionUnit.xMax then
            self.lineType = 1
        end
        if self.transform.localPosition.x < FishingModel.Defines.WorldDimensionUnit.xMin then
            self.lineType = 2
        end
        self.angle = - self.angle
        self.transform.rotation = Quaternion.Euler(0, 0, self.angle)
    	if self.seat_num == 1 then
	        Event.Brocast("ui_shake_screen_msg", 1, 0.6)
	    end
        ExtendSoundManager.PlaySound(audio_config.by.bgm_by_zuantoudan5.audio_name)
        return
    end
    if self.transform.localPosition.y > FishingModel.Defines.WorldDimensionUnit.yMax or self.transform.localPosition.y < FishingModel.Defines.WorldDimensionUnit.yMin then
        self.lock_fish_id = nil
        -- 碰撞四周后取消锁定
        if (self.transform.localPosition.y > FishingModel.Defines.WorldDimensionUnit.yMax and self.lineType == 4) or
            (self.transform.localPosition.y < FishingModel.Defines.WorldDimensionUnit.yMin and self.lineType == 3) then
            return
        end
        if self.transform.localPosition.y > FishingModel.Defines.WorldDimensionUnit.yMax then
            self.lineType = 4
        end
        if self.transform.localPosition.y < FishingModel.Defines.WorldDimensionUnit.yMin then
            self.lineType = 3
        end
        self.angle = 180 - self.angle
        self.transform.rotation = Quaternion.Euler(0, 0, self.angle)
        if self.seat_num == 1 then
	        Event.Brocast("ui_shake_screen_msg", 1, 0.6)
        end
        ExtendSoundManager.PlaySound(audio_config.by.bgm_by_zuantoudan5.audio_name)
        return
    end
end

function C:Print()
    print("BulletID=" .. self.id .. " Pos x=" .. self.transform.position.x .. " y=" .. self.transform.position.y)
end

-- 更新子弹的ID，客户端先创建自己的子弹，再发送消息给服务器，等服务器返回子弹ID再做更新。优化子弹发射卡顿问题。
function C:SetBulledData(data)
    self.id = data.id
    self.gameObject.name = self.id
end
-- 碰撞检测
function C:OnTriggerEnter2D(collision)
    if self.isSendFishList then
        return
    end
    local name = collision.transform.name
    local fish_id = tonumber(name)
    local fish = FishManager.GetFishByID(fish_id)
    if not fish or not (not fish.data.seat_num or fish.data.seat_num == self.seat_num) then        
        return
    end
    
    ExtendSoundManager.PlaySound(audio_config.by.bgm_by_zuantoudan4.audio_name)

    self.fishList[#self.fishList + 1] = fish_id
    self.isSendFishList = true
end

function C:MyExit()
    self.xh_audio = ExtendSoundManager.CloseSound(self.xh_audio)
    self:RemoveListener()
    BulletManager.RemoveBullet(self.id)
    if self.b_p then
        CachePrefabManager.Back(self.b_p)
    end
    CachePrefabManager.Back(self.prefab)
end

function C:UpdateData(data)
	local cur_n = data.rate or 1
	self.skill_id = data.skill_id
	if cur_n == 1 then
		if self.state ~= BulletPrefabZT.BulletState.BS_Nor then
			self.state = BulletPrefabZT.BulletState.BS_Nor
			self.BulletImage.color = Color.New(1, 1, 1, 1)
			self.bulled_speed = 20
		end
	else		
		if self.state ~= BulletPrefabZT.BulletState.BS_Unnor then
			self.state = BulletPrefabZT.BulletState.BS_Unnor
			self.BulletImage.color = Color.New(1, 0, 0, 1)
			self.bulled_speed = 5
			self.Trail.gameObject:SetActive(false)
			self:SetBox2D(false)

            if FishingModel.IsRecoverRet then
                self:PlayBoom()
            else
                self.xh_audio = ExtendSoundManager.PlaySound(audio_config.by.bgm_by_zuantoudan6.audio_name, -1)
    			self.seq_rota = DoTweenSequence.Create()
    			self.seq_rota:Append(self.BulletImage.transform:DORotate(Vector3.New(0, 0, 720), 5, DG.Tweening.RotateMode.FastBeyond360):SetEase(DG.Tweening.Ease.Linear))
                self.seq_rota:Join(self.BulletImage.transform:DOScale(Vector3.one * 2.5, 0.25):SetLoops(20, DG.Tweening.LoopType.Yoyo))
    			self.seq_rota:OnKill(function ()
                    self.xh_audio = ExtendSoundManager.CloseSound(self.xh_audio)
    				self.seq_rota = nil
    				self:PlayBoom()
    			end)
            end
		end
	end
end
function C:PlayBoom()
    ExtendSoundManager.PlaySound(audio_config.by.bgm_by_zuantoudan7.audio_name)
	local data = {}
	data.msg_type = "activity"
	data.type = FishingSkillManager.FishDeadAppendType.Boom
	data.id = self.skill_id
	data.bullet_id = self.id
	data.seat_num = self.seat_num
	data.status = 0
    data.parm = "zt"

	Event.Brocast("model_dispose_skill_data", data)
	BulletManager.CloseBullet(self.id)
end

