local basefunc = require "Game.Common.basefunc"
EliminateSGItem = basefunc.class()
local M = EliminateSGItem

local is_debug = false
M.name = "EliminateSGItem"
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
    --dump(data,"<color=yellow><size=15>++++++++++data++++++++++</size></color>")
    self.ui = {}
    self.data = data
    local parent = self.data.parent or EliminateSGObjManager.GetItemContent()
    if not parent then return end
    local obj = EliminateSGObjManager.item_obj["EliminateSGItem" .. self.data.id]
    if not obj or not IsEquals(obj) then return end
    --dump({obj = obj,data = self.data,xx = EliminateSGObjManager.item_obj["EliminateSGItem" .. self.data.id],name = "EliminateSGItem" .. self.data.id},"<color=yellow><size=15>++++++++++obj++++++++++</size></color>")
    self.ui.gameObject = GameObject.Instantiate(obj,parent)
    self.ui.transform = self.ui.gameObject.transform
    if not self.data.is_down then
        --不掉落创
        self.ui.transform.localPosition = eliminate_sg_algorithm.get_pos_by_index(self.data.x,self.data.y)
    else
        --掉落创建
        self.ui.transform.localPosition = eliminate_sg_algorithm.get_pos_by_index(self.data.x,self.data.y + EliminateSGModel.size.max_y)
    end
    self.ui.gameObject.name = "eliminate_" .. self.data.x .. "_" .. self.data.y
    LuaHelper.GeneratingVar(self.ui.transform, self.ui)
    if data.id == 0 then
        self.ui.icon_img.sprite =  GetTexture("xxl_icon_0")
    end
    self.ui.animator = self.ui.icon_img.transform:GetComponent("Animator")
    self.ui.mask = self.ui.transform:GetComponent("Mask")

    if is_debug then
        local obj_de = GameObject.New()
        obj_de.transform:SetParent(self.ui.transform)
        self.debug_txt = obj_de.gameObject:AddComponent(typeof(UnityEngine.UI.Text))
        self.debug_txt.text = "debug=" .. debug.traceback() .. "\n\nindex=" .. (EliminateSGModel.debug_index or 0)
        self.debug_txt.text = self.debug_txt.text .."\n" .. basefunc.tostring(self.data)

        EliminateSGModel.debug_map = EliminateSGModel.debug_map or {}
        EliminateSGModel.debug_map[self.data.type] = EliminateSGModel.debug_map[self.data.type] or {}

        local kk = self.data.x .. "_" .. self.data.y
        if EliminateSGModel.debug_map[self.data.type][kk] then
            print("<color=red>XXXXXXXXXXXXXXXXXXXXXXXXXXXXX</color>")
            print("<color=red>XXXXXXXXXXXXXXXXXXXXXXXXXXXXX</color>")
            dump(EliminateSGModel.debug_map[self.data.type][kk].debug_txt.text)
            dump(self.debug_txt.text)
        else
            EliminateSGModel.debug_map[self.data.type][kk] = self
        end
        
    end
    self:InitUI()
end

function M:Exit()
    destroy(self.ui.gameObject)
    self.ui = nil
end

function M:SetView(b)
    if is_debug then
        self.debug_txt.text = self.debug_txt.text .."\nSetView"
    end
    self.ui.gameObject:SetActive(b)
end

function M:Refresh(data)
    self.data.x = data and data.x or self.data.x
    self.data.y = data and data.y or self.data.y
    self.data.id = data and data.id or self.data.id
    if (EliminateSGModel.data.state == EliminateSGModel.xc_state.nor) or (EliminateSGModel.data.state == EliminateSGModel.xc_state.null) or (EliminateSGModel.data.state == EliminateSGModel.xc_state.select) then
        self.ui.icon_img.sprite = EliminateSGObjManager.item_obj["xxl_icon_" .. self.data.id]
    elseif (EliminateSGModel.data.state == EliminateSGModel.xc_state.hscb_2) or (EliminateSGModel.data.state == EliminateSGModel.xc_state.hscb_1) then
        self.ui.icon_img.sprite = EliminateSGObjManager.item_obj["xxl_icon_hscb_" .. self.data.id]
        self.ui.icon_img:SetNativeSize()
    elseif (EliminateSGModel.data.state == EliminateSGModel.xc_state.ccjj_2) or (EliminateSGModel.data.state == EliminateSGModel.xc_state.ccjj_cs)then
        self.ui.icon_img.sprite = EliminateSGObjManager.item_obj["xxl_icon_ccjj_" .. self.data.id]
        self.ui.icon_img:SetNativeSize()
    end
    if data and data.id == 0 then
        self.ui.icon_img.sprite = GetTexture("xxl_icon_0")
    end
    self.ui.gameObject.name = "eliminate_" .. self.data.x .. "_" .. self.data.y
    self.ui.transform.localPosition = eliminate_sg_algorithm.get_pos_by_index(self.data.x,self.data.y)
end

function M:InitUI()
    self:SpecialHandling()
    self:Refresh()
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
        seq:Append(self.ui.transform:DOLocalMove(t_pos, EliminateSGModel.GetTime(EliminateSGModel.time.ys_yd)))
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
    seq:AppendInterval(EliminateSGModel.GetTime(0.02))
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

function M:SpecialHandling()
    if is_debug then
        self.debug_txt.text = self.debug_txt.text .."\nSpecialHandling"
    end
    local rect = self.ui.transform:GetComponent("RectTransform")
    local img_rect = self.ui.icon_img.transform:GetComponent("RectTransform")
    if (EliminateSGModel.data.state == EliminateSGModel.xc_state.nor) or (EliminateSGModel.data.state == EliminateSGModel.xc_state.null) or (EliminateSGModel.data.state == EliminateSGModel.xc_state.select) then
        rect.sizeDelta = Vector2.New(105,105)
        img_rect.sizeDelta = Vector2.New(105,105)
        self.ui.bg_img.gameObject:SetActive(false)
    elseif (EliminateSGModel.data.state == EliminateSGModel.xc_state.hscb_2) or (EliminateSGModel.data.state == EliminateSGModel.xc_state.hscb_1) then
        rect.sizeDelta = Vector2.New(190,130)
        img_rect.sizeDelta = Vector2.New(190,130)
        self.ui.transform.localPosition = eliminate_sg_algorithm.get_pos_by_index(self.data.x,self.data.y)
        self.ui.bg_img.gameObject:SetActive(true)
        if self.data.id >= 100 or self.data.id == eliminate_sg_algorithm.eliminate_id[7] then
            self.ui.bg_img.sprite = GetTexture("xcys_bg_2")
        else
            self.ui.bg_img.sprite = GetTexture("xcys_bg_1")
        end
        if is_debug then
            self.debug_txt.text = self.debug_txt.text .."\nicon_icon"..self.data.id
        end
        if self.data.id >= 100 then
            self:LitBoat(true)
        else
            self:LitBoat(false)
        end
    elseif (EliminateSGModel.data.state == EliminateSGModel.xc_state.ccjj_2) or (EliminateSGModel.data.state == EliminateSGModel.xc_state.ccjj_cs) then
        rect.sizeDelta = Vector2.New(190,130)
        img_rect.sizeDelta = Vector2.New(190,130)
        self.ui.transform.localPosition = eliminate_sg_algorithm.get_pos_by_index(self.data.x,self.data.y)
        self.ui.bg_img.gameObject:SetActive(true)
        if self.data.id == eliminate_sg_algorithm.eliminate_id[8] then
            self.ui.bg_img.sprite = GetTexture("xcys_bg_2")
        else
            self.ui.bg_img.sprite = GetTexture("xcys_bg_1")
        end
    end 
end

function M:LitBoat(b)
    if b then
        EliminateSGPartManager.LitFire(self.data)
    else
        EliminateSGPartManager.PutOutFire(self.data)
    end
    self.is_fire = b
    --[[self.ui.lit_fx.gameObject:SetActive(b)
    if is_debug then
        --self.debug_txt.text = self.debug_txt.text .."\n".. debug.traceback() .. "\n\n"
        self.debug_txt.text = self.debug_txt.text .."\nLitBoat   "..tostring(b)
    end--]]
end

function M:IsAlreadyLit()
    return self.is_fire
end