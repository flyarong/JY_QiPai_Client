-- 创建时间:2018-09-04
local basefunc = require "Game.Common.basefunc"


CityMatchSharePanel = basefunc.class()

function CityMatchSharePanel.Create(shareType, parm, finishcall)
    return CityMatchSharePanel.New(shareType, parm, finishcall)
end

function CityMatchSharePanel:ctor(shareType, parm, finishcall)

	ExtPanel.ExtMsg(self)

    self.parm = parm
	self.shareType = shareType
    self.finishcall = finishcall
	local parent = GameObject.Find("Canvas/LayerLv4")
    self.gameObject = newObject("CityMatchSharePanel", parent.transform)
    self.transform = self.gameObject.transform
    local tran = self.transform
    
    self.UIRoot = tran:Find("UIRoot")
    self.ShareRoot = tran:Find("ShareRoot")
    self.BackButton = tran:Find("UIRoot/BackButton"):GetComponent("Button")
    self.BackButton.onClick:AddListener(function ()
        self:OnBackClick()
    end)
    self.PYQButton = tran:Find("UIRoot/ImgPopupPanel/PYQButton"):GetComponent("Button")
	self.PYQButton.onClick:AddListener(function ()
        self:OnPYQClick()
    end)
    self.EWMImage = tran:Find("ShareRoot/EWMImage"):GetComponent("Image")

    self.node1 = tran:Find("ShareRoot/node1")
    self.node2 = tran:Find("ShareRoot/node2")
    self.camera = GameObject.Find("Canvas/Camera"):GetComponent("Camera")

    self.DescText = tran:Find("UIRoot/ImgPopupPanel/DescText"):GetComponent("Text")
    
    self:InitUI()
end
function CityMatchSharePanel:ShowShare(b)
	self.UIRoot.gameObject:SetActive(not b)
	self.ShareRoot.gameObject:SetActive(b)
end
function CityMatchSharePanel:InitUI()
	self:ShowShare(false)

    if self.parm == "share" then
        self.DescText.text = "您当前没有海选赛门票\n分享朋友圈可立即获得门票！\n(分享无次数限制)"
    else
		self.DescText.text = "很遗憾您在海选赛中被淘汰了\n分享朋友圈可立即获得门票再次参赛！\n(分享无次数限制)"
	end
end
function CityMatchSharePanel:UpdateUI()
	
end

function CityMatchSharePanel:MyExit()
    destroy(self.gameObject)
end

function CityMatchSharePanel:Close()
	self:MyExit()
end

function CityMatchSharePanel:OnBackClick()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	self:Close()
end
function CityMatchSharePanel:OnPYQClick()
	
end