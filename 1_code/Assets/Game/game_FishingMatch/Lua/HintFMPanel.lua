
local basefunc = require "Game.Common.basefunc"

HintFMPanel = basefunc.class()

--[[提示板
    type = 1 - 只有一个确认按钮
    type = 2 - 有确认和取消按钮
    msg - 显示的消息
    confirmCbk - 确定按钮回调
    cancelCbk - 取消按钮回调

    理论上来说应该只有一个实例，不会有两个提示板同时存在
    但是这里仍然使用类进行，即可以多个实例
    层级应当比菊花还要高
]]
function HintFMPanel.Create(type,msg,confirmCbk,cancelCbk,parent)
    return HintFMPanel.New(type,msg,confirmCbk,cancelCbk,parent)
end

--[[错误提示板
    直接提供错误编号即可
]]
function HintFMPanel.ErrorMsg(errorID,callback,parent)
    local msg
    if errorID then
        if errorID == 0 then
            return
        else
            msg = errorCode[errorID] or ("错误："..errorID)
        end
    else
        msg = "错误：errorID is nil"
    end    
    return HintFMPanel.New(1,msg,callback,nil,parent)
end


function HintFMPanel:ctor(type,msg,confirmCbk,cancelCbk,parent)

	ExtPanel.ExtMsg(self)

    log("<color=yellow>--->>>Create HintFMPanel. type:" .. type .. ", msg:" .. (msg or "") .. "</color>")
    self.type = type
    self.msg = msg
    self.confirmCbk = confirmCbk
    self.cancelCbk = cancelCbk

    if not parent then
        local tf = GameObject.Find("Canvas/LayerLv50") or GameObject.Find("Canvas/LayerLv5")
        parent = tf.transform
    end
    self.parent = parent
    
    self:InitUIHall()
    self.transform = self.UIEntity.transform
    self.gameObject = self.UIEntity
    DOTweenManager.OpenPopupUIAnim(self.transform)
end

function HintFMPanel:SetButtonText(btn1)
    if btn1 then
        self.confirm_txt.text = btn1
    end
end

-- 参考大厅提示效果
function HintFMPanel:InitUIHall()
    self.UIEntity = newObject("HintFMPanel", self.parent.transform)
    LuaHelper.GeneratingVar(self.UIEntity.transform, self)

    self.text = self.UIEntity.transform:Find("hint_info_txt"):GetComponent("Text")

    self.confirmBtnEntity = self.UIEntity.transform:Find("confirm_btn")
    self.confirmBtn = self.confirmBtnEntity:GetComponent("Button")
    self.confirm_txt = self.UIEntity.transform:Find("confirm_btn/Text"):GetComponent("Text")

    self.cancelBtnEntity = self.UIEntity.transform:Find("close_btn")
    self.cancelBtn = self.cancelBtnEntity:GetComponent("Button")

    self.text.text = self.msg

    if not self.type or self.type == 1 or self.type == 2 then
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
        self.confirmBtnEntity.gameObject:SetActive(true)
    end

    self.cancelBtn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        if self.cancelCbk then
            self.cancelCbk()
        end
        self:Close()
    end)

    self.gou_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self.is_gou = not self.is_gou
        self:SetGou()
    end)

    if self.type == 1 then
        self.cancelBtnEntity.gameObject:SetActive(false)
    end
end

function HintFMPanel:ShowGou()
    self.is_gou = true
    self.gourect.gameObject:SetActive(true)
    self:SetGou()
end

function HintFMPanel:SetGou()
    if self.is_gou then
        self.gou.gameObject:SetActive(true)
    else
        self.gou.gameObject:SetActive(false)
    end
end

function HintFMPanel:HideConfirmBtn()
    if IsEquals(self.confirmBtn) then
        self.confirmBtn.gameObject:SetActive(false)
    end
end

function HintFMPanel:MyExit()
    if IsEquals(self.transform) then
        self.transform:SetParent(nil)
    end
    destroy(self.gameObject)
end
function HintFMPanel:Close()
    self:MyExit()
end

function HintFMPanel:SetDesc(desc)
    if IsEquals(self.text.gameObject) then
        if desc then
            self.text.text = desc
        end
        return true
    else
        return false
    end
end