local basefunc = require "Game.Common.basefunc"
EliminateXYItem = basefunc.class()
local M = EliminateXYItem

M.name = "EliminateXYItem"
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
    -- dump(data, "<color=data>EliminateXYItem data:</color>")
    self.ui = {}
    self.data = data
    local parent = self.data.parent or EliminateXYObjManager.GetItemContent()
    if not parent then return end
    local obj = EliminateXYObjManager.item_obj["EliminateXYItem" .. self.data.id]
    if not obj or not IsEquals(obj) then return end
    self.ui.gameObject = GameObject.Instantiate(obj,parent)
    self.ui.transform = self.ui.gameObject.transform
    if not self.data.is_down then
        --不掉落创建
        self.ui.transform.localPosition = eliminate_xy_algorithm.get_pos_by_index(self.data.x,self.data.y)
    else
        --掉落创建
        self.ui.transform.localPosition = eliminate_xy_algorithm.get_pos_by_index(self.data.x,self.data.y + EliminateXYModel.size.max_y)
    end
    self.ui.gameObject.name = "eliminate_" .. self.data.x .. "_" .. self.data.y
    LuaHelper.GeneratingVar(self.ui.transform, self.ui)
    if data.id == 0 then
        self.ui.icon_img.sprite =  GetTexture("xxl_icon_0_game_eliminatexy")
    end
    self.ui.animator = self.ui.icon_img.transform:GetComponent("Animator")
    self.ui.mask = self.ui.transform:GetComponent("Mask")
    if data.money then
        self.data.money = data.money
        self.ui.money_txt.text = data.money
        self.ui.bg.gameObject:SetActive(true)
    end
    self:InitUI()
end

function M:Exit()
    if self.ui and IsEquals(self.ui.gameObject) then
        Destroy(self.ui.gameObject) 
    end
    self.data = nil
    self.ui = nil
end

function M:SetView(b)
    self.ui.gameObject:SetActive(b)
end

function M:Refresh(data)
    self.data.x = data.x or self.data.x
    self.data.y = data.y or self.data.y
    self.data.id = data.id or self.data.id
    if data.id then
        self.ui.icon_img.sprite = EliminateXYObjManager.item_obj["xxl_icon_" .. self.data.id]
    end
    if data.id == 0 then
        self.ui.icon_img.sprite =  GetTexture("xxl_icon_0_game_eliminatexy")
    end
    self.ui.gameObject.name = "eliminate_" .. self.data.x .. "_" .. self.data.y
    self.ui.transform.localPosition = eliminate_xy_algorithm.get_pos_by_index(self.data.x,self.data.y)
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
        seq:Append(self.ui.transform:DOLocalMove(t_pos, EliminateXYModel.GetTime(EliminateXYModel.time.ys_yd)))
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

function M.MoneyPlayAni(money_txt,money)
    if not money_txt or not IsEquals(money_txt) then return end
    money_txt.text = money or money_txt.text
    local seq = DoTweenSequence.Create()
    local obj = money_txt.gameObject
    obj.gameObject:SetActive(true)
    seq:Append(obj.transform:DOScale(Vector3.one * 1,0.05))
    seq:AppendInterval(EliminateXYModel.GetTime(0.02))
    seq:Append(obj.transform:DOScale(Vector3.one * 0.8,0.04))
    seq:OnKill(function (  )
        if IsEquals(obj) then
            obj.transform.localScale = Vector3.one * 0.8
        end
    end)
    seq:OnForceKill(function ()
        if IsEquals(obj) then
            obj.transform.localScale = Vector3.one * 0.8
        end
    end)
end

function M.ChangeMoneyTxtLayer(money_txt,layer)
    if not money_txt or not IsEquals(money_txt) then return end
    layer = layer or 0
    local canvas = money_txt.transform.gameObject:AddComponent(typeof(UnityEngine.Canvas))
    canvas.overrideSorting = true
    canvas.sortingOrder = layer
end