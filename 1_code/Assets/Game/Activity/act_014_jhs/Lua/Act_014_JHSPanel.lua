
local basefunc = require "Game/Common/basefunc"
Act_014_JHSPanel = basefunc.class()
local C = Act_014_JHSPanel
C.name = "Act_014_JHSPanel"

local instance
function C.Create(parent,backcall)
    if  instance==nil then
        instance = C.New(parent,backcall)
    end
    return instance
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"] = basefunc.handler(self, self.OnExitScene)
	self.lister["AssetsGetPanelConfirmCallback"] = basefunc.handler(self, self.AssetsGetPanelConfirmCallback)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
    if self.backcall then 
        self.backcall()
    end 
	self:RemoveListener()
    instance=nil
    destroy(self.gameObject)

	 
end

function C:ctor(parent, backcall)

	ExtPanel.ExtMsg(self)

    self.backcall = backcall
	local parent = parent or GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject("Act_014_JHSPanel", parent)
	local tran = obj.transform
	self.transform = tran
    self.gameObject = obj
	self:MakeLister()
    self:AddMsgListener()
    LuaHelper.GeneratingVar(self.transform,self)
	self:InitUI()
end


function C:InitUI()
    self.close_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        self:MyExit()
    end)
    for i=1,#Act_014_JHSManager.shopid do
        self["gift" .. i .. "_btn"].onClick:AddListener(function ()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
            self:OnShopClick(Act_014_JHSManager.shopid[i])
        end)
    end
	self:MyRefresh()
end

function C:MyRefresh()
    local lock = false
    for i = 1,3 do
        local status = MainModel.GetGiftShopStatusByID(Act_014_JHSManager.shopid[i])
        if status == 0 then
            lock = true
            break
        end
    end
    for i = 1,3 do
        self["gift"..i.."_mask"].gameObject:SetActive(lock)
    end
end

function C:OnShopClick(id)
	if GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios" then
		GameManager.GotoUI({gotoui = "sys_service_gzh",goto_scene_parm = "panel",desc="请关注“鲸鱼新家园”公众号获取"..self.gift_config.pay_title})
    else
        local gift_config = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, id)
		PayTypePopPrefab.Create(gift_config.id, "￥" .. (gift_config.price / 100))
	end
end

function C:on_model_sclb1_gift_change_msg()
    self:MyExit()
end

function C:OnExitScene()
	self:MyExit()
end

function C:AssetsGetPanelConfirmCallback()
    self:MyRefresh()
end