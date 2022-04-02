local basefunc = require "Game.Common.basefunc"
EliminateFruitBG = basefunc.class()
local M = EliminateFruitBG

math.randomseed(tostring(os.time()):reverse():sub(1, 6))
M.random = math.random(1,2)

M.name = "EliminateFruitBG"

function M.Create(data)
    if not data then return end
	return M.New(data)
end

function M:ctor(data)
    local parent = GameObject.Find("BGContent")
    if parent then
        parent = parent.transform
    end
    if not parent then return end
    self.data = data
    self.ui = {}
	self.ui.gameObject = GameObject.Instantiate(EliminateObjManager.item_obj.EliminateFruitBG,parent)
    self.ui.transform = self.ui.gameObject.transform
    self.ui.transform.localPosition = eliminate_algorithm.get_pos_by_index(self.data.x,self.data.y)
    self.ui.gameObject.name = "eliminate_bg_" .. self.data.x .. "_" .. self.data.y
    LuaHelper.GeneratingVar(self.ui.transform, self.ui)
    self:Init()
    self:Refresh(data)
end

function M:Exit()
    Destroy()
    self.data = nil
    self.ui = nil
end

function M:Init()
    local set_sprite = function (id1,id2)
        if M.random == 1 then
            --(1,1)位置使用浅色
            if (self.data.x + self.data.y) % 2 == 0 then
                self.ui.bg_img.sprite = GetTexture("xxl_bg_icon".. id1)
            else
                self.ui.bg_img.sprite = GetTexture("xxl_bg_icon" .. id2)
            end
        else
            --(1,1)位置使用暗色
            if (self.data.x + self.data.y) % 2 == 0 then
                self.ui.bg_img.sprite = GetTexture("xxl_bg_icon" .. id2)
            else
                self.ui.bg_img.sprite = GetTexture("xxl_bg_icon" .. id1)
            end
        end
    end
    set_sprite(3,4)

    -- if self.data.x == 1 and self.data.y == 1 then
    --     set_sprite(1,2)
    --     self.ui.bg_img.transform.localRotation =Quaternion.Euler(0, 0, 90)
    -- elseif self.data.x == 1 and self.data.y == 8 then
    --     set_sprite(1,2)
    -- elseif self.data.x == 8 and self.data.y == 1 then
    --     set_sprite(1,2)
    --     self.ui.bg_img.transform.localRotation =Quaternion.Euler(0, 0, 180)
    -- elseif self.data.x == 8 and self.data.y == 8 then
    --     set_sprite(1,2)
    --     self.ui.bg_img.transform.localRotation =Quaternion.Euler(0, 0, 270)
    -- end
end

function M:GetPos()
    if self.ui.transform then
        return self.ui.transform.position
    end
    return Vector3.zero
end

function M:Refresh(data)
    if true then return end
    if data.id == EliminateModel.fruit_enum.lucky then
        self.ui.lucky_bg_img.transform.gameObject:SetActive(true)
        return
    end
    self.ui.lucky_bg_img.transform.gameObject:SetActive(false)
end

--[[
    GetTexture("xxl_bg_icon3")
    GetTexture("xxl_bg_icon4")
    GetTexture("xxl_bg_icon5")
]]