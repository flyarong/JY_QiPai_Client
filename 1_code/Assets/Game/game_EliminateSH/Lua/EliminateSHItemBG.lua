local basefunc = require "Game.Common.basefunc"
EliminateSHItemBG = basefunc.class()
local M = EliminateSHItemBG

math.randomseed(tostring(os.time()):reverse():sub(1, 6))
M.random = math.random(1,2)

M.name = "EliminateSHItemBG"

function M.Create(data)
    if not data then return end
	return M.New(data)
end

function M:ctor(data)
	ExtPanel.ExtMsg(self)

    local parent = EliminateSHObjManager.GetBGContent()
    if not parent then return end
    self.data = data
    self.ui = {}
	self.ui.gameObject = GameObject.Instantiate(EliminateSHObjManager.item_obj.EliminateSHHeroBG,parent)
    self.ui.transform = self.ui.gameObject.transform
    self.ui.transform.localPosition = eliminate_sh_algorithm.get_bg_pos_by_index(self.data.x,self.data.y)
    self.ui.gameObject.name = "eliminate_bg_" .. self.data.x .. "_" .. self.data.y
	self.gameObject = self.ui.gameObject
	self.transform = self.ui.transform

    LuaHelper.GeneratingVar(self.ui.transform, self.ui)
    self:Init()
    self:Refresh(data)
end

function M:Exit()
	self.ui.bg_img.sprite = nil
    self.data = nil
    self.ui = nil
	destroy(self.gameObject)
end

function M:Init()
    local set_sprite = function (id1,id2)
        if M.random == 1 then
            --(1,1)位置使用浅色
            if (self.data.x + self.data.y) % 2 == 0 then
                self.ui.bg_img.sprite = GetTexture("shxxl_bg_di2")
            else
                self.ui.bg_img.sprite = GetTexture("shxxl_bg_di2")
            end
        else
            --(1,1)位置使用暗色
            if (self.data.x + self.data.y) % 2 == 0 then
                self.ui.bg_img.sprite = GetTexture("shxxl_bg_di2")
            else
                self.ui.bg_img.sprite = GetTexture("shxxl_bg_di2")
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
    if data.id == EliminateSHModel.eliminate_enum.lucky then
        self.ui.lucky_bg_img.transform.gameObject:SetActive(true)
        return
    end
    self.ui.lucky_bg_img.transform.gameObject:SetActive(false)
end
