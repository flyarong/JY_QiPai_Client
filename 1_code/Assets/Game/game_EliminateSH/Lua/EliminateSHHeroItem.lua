local basefunc = require "Game.Common.basefunc"
EliminateSHHeroItem = basefunc.class()
local M = EliminateSHHeroItem

M.name = "EliminateSHHeroItem"
M.Status = {
    speed_up = "speed_up",
    speed_uniform = "speed_uniform",
    speed_down = "speed_down",
}

M.StatusLucky = {
    speed_up = "speed_up",
    speed_uniform = "speed_uniform",
    speed_down = "speed_down",
}

function M.Create(data)
    if not data then return end
	return M.New(data)
end

function M:ctor(data)
	ExtPanel.ExtMsg(self)
    self.ui = {}
    self.data = data
    local parent = self.data.parent or EliminateSHHeroManager.GetHeroItemContent()
    if not parent then return end
    local obj = EliminateSHObjManager.item_obj["EliminateSHHeroItem" .. self.data.id]
    if not obj then return end
    self.ui.gameObject = GameObject.Instantiate(obj,parent)
    self.ui.transform = self.ui.gameObject.transform
    if not self.data.is_down then
        --不掉落创建
        self.ui.transform.localPosition = eliminate_sh_algorithm.get_pos_by_index(self.data.x,self.data.y)
    else
        --掉落创建
        self.ui.transform.localPosition = eliminate_sh_algorithm.get_pos_by_index(self.data.x,self.data.y + EliminateSHModel.size.max_y)
    end
    self.ui.gameObject.name = "hero_" .. self.data.x .. "_" .. self.data.y
	self.gameObject = self.ui.gameObject
	self.transform = self.ui.transform

    LuaHelper.GeneratingVar(self.ui.transform, self.ui)
    if data.id == 0 then
        self.ui.icon_img.sprite =  GetTexture("shxxl_icon_hero_1") -- EliminateSHObjManager.item_obj["xxl_icon_" .. EliminateSHModel.eliminate_enum.lucky]
    end
    self.ui.animator = self.ui.icon_img.transform:GetComponent("Animator")
    self.ui.mask = self.ui.transform:GetComponent("Mask")
    self:InitUI()
end

function M:Exit()
    self.data = nil
    if IsEquals(self.gameObject) and not table_is_null(self.ui) then
        self.ui.icon_img.sprite = nil
        self.ui.icon_img.material = nil
        self.ui.animator = nil
        self.ui = nil
    end
	destroy(self.gameObject)
end

function M:Refresh(data)
    self.data.x = data.x or self.data.x
    self.data.y = data.y or self.data.y
    self.data.id = data.id or self.data.id
    if data.id then
        self.ui.icon_img.sprite = EliminateSHObjManager.item_obj["xxl_icon_hero" .. self.data.id]
    end
    if data.id == 0 then
        self.ui.icon_img.sprite =  GetTexture("shxxl_icon_hero_1") -- EliminateSHObjManager.item_obj["xxl_icon_" .. EliminateSHModel.eliminate_enum.lucky]
    end
    self.ui.gameObject.name = "hero_" .. self.data.x .. "_" .. self.data.y
    self.ui.transform.localPosition = eliminate_sh_algorithm.get_pos_by_index(self.data.x,self.data.y)
end

function M:SetHeroItemGray()
    if IsEquals(self.ui.icon_img) then
        self.ui.icon_img.material = GetMaterial("imageGrey")
    end
end


function M:InitUI()
    
end

function M:GetPos()
    if self.ui.transform then
        return self.ui.transform.position
    end
    return Vector3.zero
end

function M:Move(t_pos)
    if self.ui.transform.localPosition ~= t_pos then
        local seq = DoTweenSequence.Create()
        seq:Append(self.ui.transform:DOLocalMove(t_pos, EliminateSHModel.GetTime(EliminateSHModel.time.ys_yd)))
        seq:SetEase(DG.Tweening.Ease.InCirc)
        seq:OnForceKill(function ()
            self.ui.transform.localPosition = t_pos
        end)
    end
end

function M:PlaySpring()
    if self.ui.animator then
        self.ui.mask.enabled = false
        self.ui.animator.enabled = true
        -- self.ui.animator:SetBool("spring",true)
    end
end

function M:StopSpring()
    if self.ui.animator then
        self.ui.mask.enabled = true
        self.ui.animator.enabled = false
        self.ui.animator.transform.localScale = Vector3.one
        -- self.ui.animator:SetBool("spring",false)
    end
end