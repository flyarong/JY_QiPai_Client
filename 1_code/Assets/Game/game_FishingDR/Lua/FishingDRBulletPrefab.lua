-- 创建时间:2019-03-11
-- 子弹

local basefunc = require "Game.Common.basefunc"

FishingDRBulletPrefab = basefunc.class()

local C = FishingDRBulletPrefab

C.name = "FishingDRBulletPrefab"
BulletPrefab = FishingDRBulletPrefab

local instance
function C.Create(parent, data)
    return C.New(parent, data)
end

function C:Awake()
end

function C:Start()
end

function C:ctor(parent, data)
    self.data = data
    self.prefab = CachePrefabManager.Take(self.data.prefab)
    -- self.data.bulled_speed = FishingDRModel.Defines.BulledSpeed

    self.prefab.prefab:SetParent(parent)
    self.transform = self.prefab.prefab.prefabObj.transform
    self.gameObject = self.transform.gameObject
    self.transform.rotation = Quaternion.Euler(0, 0, self.data.angle)
    self.transform.position = self.data.pos
    self.box2d = self.transform:GetComponent("BoxCollider2D")

    self.transform:GetComponent("LuaBehaviour").luaTable = self
    self.b_sr = self.transform:Find("BulletImage"):GetComponent("SpriteRenderer")
    self.b_sr.sortingOrder = 5
    self.gameObject.name = self.data.id
    self.gameObject:SetActive(true)
    self.timer = Timer.New(function()
        FishingDRBulletManager.Remove(self.data.id)
    end,FishingDRModel.Defines.bullet_life,1,false,false)
    self.timer:Start()
end

function C:FrameUpdate(time_elapsed)
    if not IsEquals(self.transform) or not self.data then return end
    self.transform.localPosition = self.transform.localPosition + self.transform.up * time_elapsed * self.data.speed
end

function C:MyExit()
    if self.timer then
        self.timer:Stop()
        self.timer = nil
    end
    self.box2d.enabled = true
    CachePrefabManager.Back(self.prefab)
    self.data = nil
end

-- 碰撞检测
function C:OnTriggerEnter2D(collision)
    if self.is_trigger then return end
    if not self.is_trigger then self.is_trigger = true end
    self.box2d.enabled = false
    local data  = {}
    data.base = {}
    data.base.pos = self.transform.position
    data.base.up = self.transform.up
    data.player = {}
    data.player.id = self.data.player_id
    data.gun = {}
    data.gun.id = self.data.gun_id
    data.bullet = {}
    data.bullet.id = self.data.id
    data.fish = {}
    data.fish.id = tonumber(collision.transform.name)
    Event.Brocast("bullet_trigger_fish","bullet_trigger_fish",data)
end