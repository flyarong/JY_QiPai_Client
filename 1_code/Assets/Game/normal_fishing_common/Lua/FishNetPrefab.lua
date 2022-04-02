-- 创建时间:2019-03-12
-- 渔网

local basefunc = require "Game/Common/basefunc"

FishNetPrefab = basefunc.class()
local C = FishNetPrefab
C.name = "FishNetPrefab"

function C.Create(parent, data)
	return C.New(parent, data)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"] = basefunc.handler(self, self.OnExitScene)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:OnExitScene()
    self:MyExit()
end

function C:MyExit()
    if self.anim_time then
        self.anim_time:Stop()
        self.anim_time = nil
    end
	self:RemoveListener()
    CachePrefabManager.Back(self.prefab)
end

function C:ctor(parent, data)
	self.data = data
    local bullet =  BulletManager.GetIDToBullet(data.id)
    local gun_config = FishingModel.GetGunSkinCfg(bullet.seat_num, bullet.index)

    local net_type = FishingActivityManager.GetFishNetType(bullet.seat_num)
    if net_type then
        self.prefab = CachePrefabManager.Take("FishNetPrefab_" .. net_type)
    else
        if gun_config.net_prefab then
            self.prefab = CachePrefabManager.Take(gun_config.net_prefab)
            if gun_config.is_fx_net and gun_config.is_fx_net == 0 then
                self.is_fx_net = false
            else
                self.is_fx_net = true
            end
        else
            self.prefab = CachePrefabManager.Take("FishNetPrefab_1")
        end
    end
    self.prefab.prefab:SetParent(parent)
	local tran = self.prefab.prefab.prefabObj.transform
	self.transform = tran

	-- self.NetLevel = tran:Find("NetLevel"):GetComponent("Image")


	self.transform.position = FishingModel.Get2DToUIPoint(bullet.Obj.transform.position + bullet.Obj.transform.up * 0.4)
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
    if not self.is_fx_net then
        local tran = self.transform
        tran.localScale = Vector3.New(0.2, 0.2, 0.2)
        local ss = 1
        local seq = DoTweenSequence.Create()

        seq:Append(tran:DOScale(1.2*ss, 0.2))
        seq:Append(tran:DOScale(0.9*ss, 0.2))
        seq:Append(tran:DOScale(1*ss, 0.1))
    end

    self.anim_time = Timer.New(function ()
        self:MyExit()
        self.anim_time = nil
    end, 0.5, 1)
    self.anim_time:Start()
end


