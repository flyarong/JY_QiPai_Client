
local basefunc = require "Game.Common.basefunc"

HintPanel = basefunc.class()

--[[提示板
    type = 1 - 只有一个确认按钮
    type = 2 - 有确认和取消按钮
    type = 3 - 有购买和取消按钮
    type = 10 - 大幅文档显示方案
    msg - 显示的消息
    confirmCbk - 确定按钮回调
    cancelCbk - 取消按钮回调

    理论上来说应该只有一个实例，不会有两个提示板同时存在
    但是这里仍然使用类进行，即可以多个实例
    层级应当比菊花还要高
]]
function HintPanel.Create(type,msg,confirmCbk,cancelCbk,parent,title,prefab_name,parms)
    return HintPanel.New(type,msg,confirmCbk,cancelCbk,parent,title,prefab_name,parms)
end

--[[错误提示板
    直接提供错误编号即可
]]
function HintPanel.ErrorMsg(errorID,callback,parent,prefab_name,parms)
    local msg
    if errorID then
        if errorID == 0 then
            return
        elseif errorID == -666 then
            return
        else
            msg = errorCode[errorID] or ("错误："..errorID)
        end
    else
        msg = "错误：errorID is nil"
    end    
    return HintPanel.New(1,msg,callback,nil,parent,nil,prefab_name,parms)
end


function HintPanel:ctor(type,msg,confirmCbk,cancelCbk,parent,title,prefab_name,parms)

	ExtPanel.ExtMsg(self)

    log("<color=yellow>--->>>Create hintpanel. type:" .. type .. ", msg:" .. (msg or "") .. "</color>")
    self.type = type
    self.msg = msg
    self.confirmCbk = confirmCbk
    self.cancelCbk = cancelCbk
    self.prefab_name = prefab_name

    if not parent then
        local tf = GameObject.Find("Canvas/LayerLv50") or GameObject.Find("Canvas/LayerLv5")
        parent = tf.transform
    end
    self.parent = parent
    
    local useHintPanel = (self.type == 4)
    if (MainModel.myLocation == "game_MatchHall" or MainModel.myLocation == "game_DdzMatch" or MainModel.myLocation == "game_DdzMillion" or MainModel.myLocation == "game_MjMatchNaming" or MainModel.myLocation == "game_CityMatch" or
        MainModel.myLocation == "game_MjXzMatchER3D" or MainModel.myLocation == "game_MjXzMatch3D") and not useHintPanel then
        self:InitUIMatch()
    else
        self:InitUIHall()
    end
    self.transform = self.UIEntity.transform
    if GuideLogic and not GuideLogic.IsHaveGuide() then
        --DOTweenManager.OpenPopupUIAnim(self.transform)
    end
    --print(title)
    self.title=title
    if self.title~=nil and IsEquals(self.transform:Find("ImgTitle/Image")) and IsEquals(self.transform:Find("ImgTitle/Text")) then 
        self.transform:Find("ImgTitle/Text"):GetComponent("Text").text=self.title
        self.transform:Find("ImgTitle/Image").gameObject:SetActive(false)
        self.transform:Find("ImgTitle/Text").gameObject:SetActive(true)
    elseif IsEquals(self.transform:Find("ImgTitle/Image")) and IsEquals(self.transform:Find("ImgTitle/Text")) then 
        self.transform:Find("ImgTitle/Image"):GetComponent("Image").sprite=GetTexture("com_imgf_hint")
        self.transform:Find("ImgTitle/Image").gameObject:SetActive(true)
        self.transform:Find("ImgTitle/Text").gameObject:SetActive(false)
    end 
end

-- 参考比赛场提示效果
function HintPanel:InitUIMatch()
    self.UIEntity = newObject("HintMatchPanel", self.parent.transform)
    LuaHelper.GeneratingVar(self.UIEntity.transform, self)
    self.gameObject = self.UIEntity

    self.text = self.UIEntity.transform:Find("ImgPopupPanel/hint_info_txt"):GetComponent("Text")
    
    self.confirmBtnEntity = self.UIEntity.transform:Find("ImgPopupPanel/confirm_btn")
    self.confirmBtn = self.confirmBtnEntity:GetComponent("Button")
    self.confirm_txt = self.UIEntity.transform:Find("ImgPopupPanel/confirm_btn/Text"):GetComponent("Text")

    self.cancelBtnEntity = self.UIEntity.transform:Find("ImgPopupPanel/close_btn")
    self.cancelBtn = self.cancelBtnEntity:GetComponent("Button")


    self.payBtnEntity = self.UIEntity.transform:Find("ImgPopupPanel/pay_btn")
    self.payBtn = self.payBtnEntity:GetComponent("Button")
    self.close_txt = self.UIEntity.transform:Find("ImgPopupPanel/pay_btn/Text"):GetComponent("Text")

    self.text.text = self.msg
    if  self.type == 2 or self.type == 1 or self.type ==10 then
        self.confirmBtn.onClick:AddListener(function ()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            if self.confirmCbk then
                self.confirmCbk()
            end
            self:Close()
        end)
        self.payBtnEntity.gameObject:SetActive(false)
        self.confirmBtnEntity.gameObject:SetActive(true)
        self.close_btn.gameObject:SetActive(false)
    elseif self.type == 3 then
        self.payBtn.onClick:AddListener(function ()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            if self.confirmCbk then
                self.confirmCbk()
            end
            self:Close()
        end)
        self.payBtnEntity.gameObject:SetActive(true)
        self.confirmBtnEntity.gameObject:SetActive(false)
    elseif self.type == 5 then
        self.cancelBtnEntity.gameObject:SetActive(false)
        self.confirmBtnEntity.gameObject:SetActive(true)
        self.payBtnEntity.gameObject:SetActive(true)
        self.payBtnEntity.transform.localPosition = Vector3.New(-210, -122, 0)
        self.confirmBtnEntity.transform.localPosition = Vector3.New(210, -122, 0)
        self.payBtn.onClick:AddListener(function ()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            if self.confirmCbk then
                self.confirmCbk()
            end
            self:Close()
        end)
        self.confirmBtn.onClick:AddListener(function ()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            if self.cancelCbk then
                self.cancelCbk()
            end
            self:Close()
        end)
    elseif self.type == 6 then
        self.cancelBtnEntity.gameObject:SetActive(true)
        self.confirmBtnEntity.gameObject:SetActive(true)
        self.payBtnEntity.gameObject:SetActive(true)
        self.payBtnEntity.transform.localPosition = Vector3.New(-210, -122, 0)
        self.confirmBtnEntity.transform.localPosition = Vector3.New(210, -122, 0)
        self.payBtn.onClick:AddListener(function ()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            if self.confirmCbk then
                self.confirmCbk()
            end
            self:Close()
        end)
        self.confirmBtn.onClick:AddListener(function ()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            if self.cancelCbk then
                self.cancelCbk()
            end
            self:Close()
        end)
    elseif self.type == 7 then
        self.cancelBtnEntity.gameObject:SetActive(false)
        self.confirmBtnEntity.gameObject:SetActive(false)
        self.yes_btn.gameObject:SetActive(true)
        self.no_btn.gameObject:SetActive(true)
        self.cancelBtnEntity.gameObject:SetActive(true)
        self.payBtnEntity.gameObject:SetActive(false)
        --!!!在畅玩卡的需求里面，两个按钮调换了位置
        self.yes_btn.onClick:AddListener(basefunc.handler(self, self.OnNoClicked))
        self.no_btn.onClick:AddListener(basefunc.handler(self, self.OnYesClicked))
    end
   
    if self.type == 6 or self.type == 7 then
        self.cancelBtn.onClick:AddListener(function ()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            self:Close()
        end)
    else
        self.cancelBtn.onClick:AddListener(function ()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            if self.cancelCbk then
                self.cancelCbk()
            end
            self:Close()
        end)
    end

    if self.type == 1 or self.type==10 then
        self.cancelBtnEntity.gameObject:SetActive(false)
    end
end
function HintPanel:SetSmallHint(tt)
    if self.small_hint then
        self.small_hint.text = tt
    end
end
function HintPanel:SetButtonText(btn1, btn2)
    if btn1 then
        self.close_txt.text = btn1
    end
    if btn2 then
        self.confirm_txt.text = btn2
    end
end

function HintPanel:SetMiniHitText(text)
    local txt = self.transform:Find("ImgPopupPanel/mini_hint_info_txt"):GetComponent("Text")
    if IsEquals(txt) then
        txt.text = text
    end
end

-- 参考大厅提示效果
function HintPanel:InitUIHall()
    local prefab_name = self.prefab_name or "HintPanel"
    self.UIEntity = newObject(prefab_name, self.parent.transform)
    LuaHelper.GeneratingVar(self.UIEntity.transform, self)
    self.gameObject = self.UIEntity

    self.title_img = self.UIEntity.transform:Find("ImgTitle/Image"):GetComponent("Image")
    self.text = self.UIEntity.transform:Find("ImgPopupPanel/hint_info_txt"):GetComponent("Text")
    self.small_hint = self.UIEntity.transform:Find("ImgPopupPanel/small_hint"):GetComponent("Text")
    self.scrolltext=self.UIEntity.transform:Find("ImgPopupPanel/scrolltext/Viewport/Content/hint_info_txt"):GetComponent("Text")

    self.confirmBtnEntity = self.UIEntity.transform:Find("ImgPopupPanel/confirm_btn")
    self.confirmBtn = self.confirmBtnEntity:GetComponent("Button")
    self.confirm_txt = self.UIEntity.transform:Find("ImgPopupPanel/confirm_btn/Text"):GetComponent("Text")

    self.cancelBtnEntity = self.UIEntity.transform:Find("ImgPopupPanel/close_btn")
    self.cancelBtn = self.cancelBtnEntity:GetComponent("Button")

    self.payBtnEntity = self.UIEntity.transform:Find("ImgPopupPanel/pay_btn")
    self.payBtn = self.payBtnEntity:GetComponent("Button")
    self.close_txt = self.UIEntity.transform:Find("ImgPopupPanel/pay_btn/Text"):GetComponent("Text")

    self.text.text = self.msg
    self.scrolltext.text= self.msg
    if  self.type==10 then 
        self.UIEntity.transform:Find("ImgPopupPanel/hint_info_txt").gameObject:SetActive(false)
        self.UIEntity.transform:Find("ImgPopupPanel/scrolltext").gameObject:SetActive(true)
    else
        self.UIEntity.transform:Find("ImgPopupPanel/hint_info_txt").gameObject:SetActive(true)
        self.UIEntity.transform:Find("ImgPopupPanel/scrolltext").gameObject:SetActive(false)
    end 

    if  self.type == 2 or self.type == 1 or  self.type==10  then
        local destroy = true
        self.confirmBtn.onClick:AddListener(function ()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            if self.confirmCbk then
                destroy = self.confirmCbk(self.is_gou)
		if destroy == nil then destroy = true end
            end
	    if destroy then
            self:Close()
	    end
        end)
        self.payBtnEntity.gameObject:SetActive(false)
        self.confirmBtnEntity.gameObject:SetActive(true)
    elseif self.type == 3 then
        self.payBtn.onClick:AddListener(function ()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            if self.confirmCbk then
                self.confirmCbk(self.is_gou)
            end
            self:Close()
        end)
        self.payBtnEntity.gameObject:SetActive(true)
        self.confirmBtnEntity.gameObject:SetActive(false)
    elseif self.type == 4 then
        self.UIEntity.transform:Find("ImgPopupBG").gameObject:SetActive(false)
        self.UIEntity.transform:Find("ImgTitle").gameObject:SetActive(false)
        self.cancelBtnEntity.gameObject:SetActive(false)
        self.confirmBtnEntity.gameObject:SetActive(false)
        self.yes_btn.gameObject:SetActive(true)
        self.no_btn.gameObject:SetActive(true)
        self.small_bg_img.gameObject:SetActive(true)
        self.yes_btn.onClick:AddListener(basefunc.handler(self, self.OnYesClicked))
        self.no_btn.onClick:AddListener(basefunc.handler(self, self.OnNoClicked))
    elseif self.type == 5 then
        self.cancelBtnEntity.gameObject:SetActive(false)
        self.confirmBtnEntity.gameObject:SetActive(true)
        self.payBtnEntity.gameObject:SetActive(true)
        self.payBtnEntity.transform.localPosition = Vector3.New(-210, -122, 0)
        self.confirmBtnEntity.transform.localPosition = Vector3.New(210, -122, 0)
        self.payBtn.onClick:AddListener(function ()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            if self.confirmCbk then
                self.confirmCbk()
            end
            self:Close()
        end)
        self.confirmBtn.onClick:AddListener(function ()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            if self.cancelCbk then
                self.cancelCbk()
            end
            self:Close()
        end)
    elseif self.type == 6 then
        self.cancelBtnEntity.gameObject:SetActive(true)
        self.confirmBtnEntity.gameObject:SetActive(true)
        self.payBtnEntity.gameObject:SetActive(true)
        self.payBtnEntity.transform.localPosition = Vector3.New(-210, -122, 0)
        self.confirmBtnEntity.transform.localPosition = Vector3.New(210, -122, 0)
        self.payBtn.onClick:AddListener(function ()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            if self.confirmCbk then
                self.confirmCbk()
            end
            self:Close()
        end)
        self.confirmBtn.onClick:AddListener(function ()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            if self.cancelCbk then
                self.cancelCbk()
            end
            self:Close()
        end)
    elseif self.type == 7 then
        self.confirmBtnEntity.gameObject:SetActive(false)
        self.yes_btn.gameObject:SetActive(true)
        self.no_btn.gameObject:SetActive(true)
        self.cancelBtnEntity.gameObject:SetActive(true)
        --!!!在畅玩卡的需求里面，两个按钮调换了位置
        self.yes_btn.onClick:AddListener(basefunc.handler(self, self.OnNoClicked))
        self.no_btn.onClick:AddListener(basefunc.handler(self, self.OnYesClicked))
    end
   
    if self.type == 6 then
        self.cancelBtn.onClick:AddListener(function ()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            self:Close()
        end)
    else
        self.cancelBtn.onClick:AddListener(function ()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            if self.cancelCbk then
                self.cancelCbk()
            end
            self:Close()
        end)
    end

    self.gou_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self.is_gou = not self.is_gou
        self:SetGou()
    end)

    if self.type == 1 or self.type==10 then
        self.cancelBtnEntity.gameObject:SetActive(false)
    end
end

function HintPanel:ShowGou()
    self.is_gou = false
    self.gourect.gameObject:SetActive(true)
    self:SetGou()
end

function HintPanel:SetGou()
    if self.is_gou then
        self.gou.gameObject:SetActive(true)
        if self.gou_yescall then
            self.gou_yescall()
        end
    else
        self.gou.gameObject:SetActive(false)
        if self.gou_nocall then
            self.gou_nocall()
        end
    end
end

function HintPanel:SetGouCall(yescall,nocall)
    self.gou_yescall = yescall
    self.gou_nocall = nocall
end

function HintPanel:HideConfirmBtn()
    if IsEquals(self.confirmBtn) then
        self.confirmBtn.gameObject:SetActive(false)
    end
end

function HintPanel:ChangeTitleImg(img)
    if img and IsEquals(self.title_img) then
        self.title_img.sprite = GetTexture(img)
        self.title_img:SetNativeSize()
    end
end

function HintPanel:OnYesClicked()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    if self.confirmCbk then
        self.confirmCbk()
    end
    self:Close()
end

function HintPanel:OnNoClicked()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    if self.cancelCbk then
        self.cancelCbk()
    end
    self:Close()
end

function HintPanel:SetBtnTitle(t1, t2)
    if self.type == 4 or self.type == 7 then
        self.yes_txt.text = t1
        self.no_txt.text = t2
    end
end

function HintPanel:MyExit()
    if IsEquals(self.transform) then
        self.transform:SetParent(nil)
    end
    destroy(self.gameObject)
end

function HintPanel:Close()
    self:MyExit()
end

function HintPanel:SetPayBtnTitle(title)   
    if title then 
        self.payBtnEntity:Find("Text"):GetComponent("Text").text=title
    end 
end

function HintPanel:SetDescLeft()   
    self.text.alignment = UnityEngine.TextAnchor.MiddleLeft
end
