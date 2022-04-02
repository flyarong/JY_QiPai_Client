local basefunc = require "Game.Common.basefunc"

FishingDRItemPrefab = basefunc.class()

local C = FishingDRItemPrefab
C.name = "FishingDRItemPrefab"

local IMAGE_TBL = {
	"bydr_game_icon_b2_1", "bydr_game_icon_b3_1", "bydr_game_icon_b4_1", "bydr_game_icon_bs"
}

function C.Create(parent,data)
    return C.New(parent,data)
end

function C:Awake()
end

function C:Start()
end

function C:ctor(parent,data)
    local b = newObject(C.name,parent)
    self.transform = b.transform
    self.gameObject = b.gameObject
    self.data = data
    self.transform.parent = parent
    self.transform.position= data.pos
    self.transform:GetComponent("LuaBehaviour").luaTable = self

    self:UpdateImage()
end

function C:MyExit()
    if IsEquals(self.transform) then 
        GameObject.Destroy(self.gameObject)
    end 
end

function C:MyRefresh()
    if table_is_null(self.data) or not IsEquals(self.transform) then return end

end

function C:FrameUpdate(time_elapsed)

    self:MyRefresh()
end

function C:UpdateImage()
	local image_file = IMAGE_TBL[self.data.id]
	local transform = self.transform
	local image = transform:Find("BulletImage"):GetComponent("SpriteRenderer")
    image.sprite = GetTexture(image_file)
    image.gameObject.transform.localScale = Vector3.New(0.8, 0.8, 0.8)
end

-- 碰撞检测
function C:OnTriggerEnter2D(collision)
    if collision then 
        local data  = {}
        data.index = self.data.index
        data.fish_id = tonumber(collision.transform.name)
        data.pos = self.transform.position
        data.up = self.transform.up
        -- print(string.format("collision xxxxxxxxxxxxxxxxxxxx %d %d", data.fish_id, self.data.index))
        Event.Brocast("fish_trigger_item","fish_trigger_item",data)
    end 
end

