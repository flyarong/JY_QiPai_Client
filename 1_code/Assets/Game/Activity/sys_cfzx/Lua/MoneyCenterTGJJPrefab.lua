-- 创建时间:2018-12-21

local basefunc = require "Game.Common.basefunc"

MoneyCenterTGJJPrefab = basefunc.class()

local C = MoneyCenterTGJJPrefab

C.name = "MoneyCenterTGJJPrefab"


function C.Create(parent_transform, config, call, panelSelf)
	return C.New(parent_transform, config, call, panelSelf)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:OnDestroy()
	GameObject.Destroy(self.gameObject)
	self:MyExit()
end

function C:MyExit()
	self:RemoveListener()
end

function C:ctor(parent_transform, config, call, panelSelf)
	self.config = config
	self.call = call
	self.panelSelf = panelSelf
	local obj = newObject(C.name, parent_transform)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj

	self:MakeLister()
	self:AddMsgListener()
    LuaHelper.GeneratingVar(self.transform, self)

	self.BG_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        self:OnClick()
    end)
    
    self:InitUI()
end

function C:InitUI()
	self.icon_img.sprite = GetTexture(self.config.icon)
	self.desc_txt.text = self.config.desc
end

function C:MyRefresh()
end

function C:OnClick()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    --直接进行分享
    if true then
        GameMoneyCenterSharePanel.Create()
        return
    end
    if self.config.id == 1 then
        MoneyCenterShareHintPanel.Create("moneycenter")
    else     
        self.gift_status = MainModel.GetGiftShopStatusByID(GoldenPigModel.GetGiftBagGoodsID())
        if self.gift_status == 1 then
            MoneyCenterVipHintPanel.Create()
        else
	        Event.Brocast("open_golden_pig")
        end   
    end
end
