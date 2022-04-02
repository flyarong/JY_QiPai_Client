local basefunc = require "Game.Common.basefunc"
EliminateSHItem = basefunc.class()
local M = EliminateSHItem

M.name = "EliminateSHItem"
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
    -- dump(data, "<color=data>EliminateSHItem data:</color>")
	ExtPanel.ExtMsg(self)

    self.ui = {}
    self.data = data
    local parent = self.data.parent or EliminateSHObjManager.GetItemContent()
    if not parent then return end
    local obj = EliminateSHObjManager.item_obj["EliminateSHItem" .. self.data.id]
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
    self.ui.gameObject.name = "eliminate_" .. self.data.x .. "_" .. self.data.y
	self.gameObject = self.ui.gameObject
	self.transform = self.ui.transform
    LuaHelper.GeneratingVar(self.ui.transform, self.ui)
    if data.id == 0 then
        self.ui.icon_img.sprite =  GetTexture("xxl_icon_0_game_eliminatesh")
    end
    self.ui.animator = self.ui.icon_img.transform:GetComponent("Animator")
    self.ui.mask = self.ui.transform:GetComponent("Mask")
    self:InitUI()
end

function M:Exit()
    if IsEquals(self.ui.icon_img) then
        self.ui.icon_img.sprite = nil
    end
    self.data = nil
    self.ui = nil
	destroy(self.gameObject)
end

function M:Refresh(data)
    self.data.x = data.x or self.data.x
    self.data.y = data.y or self.data.y
    self.data.id = data.id or self.data.id
    if data.id then
        self.ui.icon_img.sprite = EliminateSHObjManager.item_obj["xxl_icon_" .. self.data.id]
    end
    if data.id == 0 then
        self.ui.icon_img.sprite =  GetTexture("xxl_icon_0_game_eliminatesh") -- EliminateSHObjManager.item_obj["xxl_icon_" .. EliminateSHModel.eliminate_enum.lucky]
    end
    self.ui.gameObject.name = "eliminate_" .. self.data.x .. "_" .. self.data.y
    self.ui.transform.localPosition = eliminate_sh_algorithm.get_pos_by_index(self.data.x,self.data.y)
end

function M:InitUI()
    --手动消除
    if EliminateSHModel.Manually then
        self.ui.icon_img.gameObject:AddComponent(typeof(UnityEngine.UI.Button))
        self.ui.click_btn = self.ui.icon_img.transform:GetComponent("Button")
        EventTriggerListener.Get(self.ui.click_btn.gameObject).onClick = function(  )
            EliminateSHObjManager.OnClickLotteryManually(self.data)
        end
    end
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