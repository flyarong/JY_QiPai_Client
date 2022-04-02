local basefunc = require "Game.Common.basefunc"
EliminateFXItem = basefunc.class()
local M = EliminateFXItem

local is_debug = false
M.name = "EliminateFXItem"
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
    local parent = self.data.parent or EliminateFXObjManager.GetItemContent()
    if not parent then return end
    local obj = EliminateFXObjManager.item_obj["EliminateFXItem" .. self.data.id]
    if not obj or not IsEquals(obj) then return end
    --dump({obj = obj,data = self.data,xx = EliminateFXObjManager.item_obj["EliminateFXItem" .. self.data.id],name = "EliminateFXItem" .. self.data.id},"<color=yellow><size=15>++++++++++obj++++++++++</size></color>")
    self.ui.gameObject = GameObject.Instantiate(obj,parent)
    self.ui.transform = self.ui.gameObject.transform
    if not self.data.is_down then
        --不掉落创
        self.ui.transform.localPosition = eliminate_fx_algorithm.get_pos_by_index(self.data.x,self.data.y)
    else
        --掉落创建
        self.ui.transform.localPosition = eliminate_fx_algorithm.get_pos_by_index(self.data.x,self.data.y + EliminateFXModel.size.max_y)
    end
    self.ui.gameObject.name = "eliminate_" .. self.data.x .. "_" .. self.data.y
    LuaHelper.GeneratingVar(self.ui.transform, self.ui)
    if data.id == 0 then
        self.ui.icon_img.sprite =  GetTexture("xxl_icon_0")
    end
    self.ui.animator = self.ui.icon_img.transform:GetComponent("Animator")
    self.ui.mask = self.ui.transform:GetComponent("Mask")
    self.ui.score_txt.gameObject:SetActive(false)
    if is_debug then
        local obj_de = GameObject.New()
        obj_de.transform:SetParent(self.ui.transform)
        self.debug_txt = obj_de.gameObject:AddComponent(typeof(UnityEngine.UI.Text))
        self.debug_txt.text = "debug=" .. debug.traceback() .. "\n\nindex=" .. (EliminateFXModel.debug_index or 0)
        self.debug_txt.text = self.debug_txt.text .."\n" .. basefunc.tostring(self.data)

        EliminateFXModel.debug_map = EliminateFXModel.debug_map or {}
        EliminateFXModel.debug_map[self.data.type] = EliminateFXModel.debug_map[self.data.type] or {}

        local kk = self.data.x .. "_" .. self.data.y
        if EliminateFXModel.debug_map[self.data.type][kk] then
            print("<color=red>XXXXXXXXXXXXXXXXXXXXXXXXXXXXX</color>")
            print("<color=red>XXXXXXXXXXXXXXXXXXXXXXXXXXXXX</color>")
            dump(EliminateFXModel.debug_map[self.data.type][kk].debug_txt.text)
            dump(self.debug_txt.text)
        else
            EliminateFXModel.debug_map[self.data.type][kk] = self
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
    self.ui.icon_img.sprite = EliminateFXObjManager.item_obj["xxl_icon_" .. self.data.id]
    if data and data.id == 0 then
        self.ui.icon_img.sprite = GetTexture("xxl_icon_0")
    end
    if self.data then
        if self.data.id >= 100 then
            self.ui.bg_img.gameObject:SetActive(true)
            self.ui.bg_img.sprite = GetTexture("fxgz_bg"..self.data.x..self.data.y)
            self.ui.bg_img:SetNativeSize()
            self.ui.bg_img.transform:GetComponent("RectTransform").sizeDelta = Vector2.New(160,150)
        else
            self.ui.bg_img.gameObject:SetActive(false)
        end
    end
    self.ui.gameObject.name = "eliminate_" .. self.data.x .. "_" .. self.data.y
    self.ui.transform.localPosition = eliminate_fx_algorithm.get_pos_by_index(self.data.x,self.data.y)
end

function M:InitUI()
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
        seq:Append(self.ui.transform:DOLocalMove(t_pos, EliminateFXModel.GetTime(EliminateFXModel.time.ys_yd)))
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
    seq:AppendInterval(EliminateFXModel.GetTime(0.02))
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

function M:LitBoat(b)
    if b then
        EliminateFXPartManager.LitFire(self.data)
    else
        EliminateFXPartManager.PutOutFire(self.data)
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

function M:SetBG()
    self.ui.bg_img.gameObject:SetActive(true)
    self.ui.bg_img.sprite = GetTexture("fxgz_bg"..self.data.x..self.data.y)
    self.ui.bg_img:SetNativeSize()
    self.ui.bg_img.transform:GetComponent("RectTransform").sizeDelta = Vector2.New(160,150)
end

function M:ClearScore()
    local is_show = self.ui.score_txt.gameObject.activeSelf
    self.ui.score_txt.gameObject:SetActive(false)
    return is_show
end

function M:ShowScore()
    if self.data.id == 6 or self.data.id == 101 then
        self.ui.score_txt.font = GetFont("fxgz_imgf_szlan")
    elseif self.data.id == 7 or self.data.id == 102 then
        self.ui.score_txt.font = GetFont("fxgz_imgf_szlv")
    elseif self.data.id == 8 or self.data.id == 103 then
        self.ui.score_txt.font = GetFont("fxgz_imgf_szz")
    elseif self.data.id == 9 or self.data.id == 100 then
        self.ui.score_txt.font = GetFont("fxgz_imgf_szh")
    end
    self.ui.score_txt.text = EliminateFXModel.data.eliminate_data.little_rate_map[self.data.x][self.data.y]
    self.ui.score_txt.gameObject:SetActive(true)
end