-- 创建时间:2019-05-27
-- Panel:ActivityShopDWPanel
--[[
 *      ┌─┐       ┌─┐
 *   ┌──┘ ┴───────┘ ┴──┐
 *   │                 │
 *   │       ───       │
 *   │  ─┬┘       └┬─  │
 *   │                 │
 *   │       ─┴─       │
 *   │                 │
 *   └───┐         ┌───┘
 *       │         │
 *       │         │
 *       │         │
 *       │         └──────────────┐
 *       │                        │
 *       │                        ├─┐
 *       │                        ┌─┘
 *       │                        │
 *       └─┐  ┐  ┌───────┬──┐  ┌──┘
 *         │ ─┤ ─┤       │ ─┤ ─┤
 *         └──┴──┘       └──┴──┘
 *                神兽保佑
 *               代码无BUG!
 --]]
-- 端午节礼包
local basefunc = require "Game/Common/basefunc"

StageShopPanel = basefunc.class()
local C = StageShopPanel
C.name = "StageShopPanel"

local instance
function C.Create(parent,backcall)

    if C:getCurrentShopID()==0 then
        HintPanel.Create(1, "抱歉，已经不可购买") 
        return
    end
    if  instance==nil then
        instance = C.New(parent,backcall)
        --return instance		
    else
       -- print("<color=red>============卧槽================ </color>")
        return instance	
    end
	
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
	self.lister["ExitScene"] = basefunc.handler(self, self.OnExitScene)
	self.lister["model_sclb_gift_change_msg"] = basefunc.handler(self, self.on_model_sclb_gift_change_msg)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
    destroy(self.gameObject)
    if self.backcall then 
        self.backcall()
    end 
	self:RemoveListener()
	instance=nil

	 
end

function C:ctor(parent, backcall)

	ExtPanel.ExtMsg(self)

    self.shopidindex=self:getCurrentShopID()
    dump(self.shopidindex,"<color=red>--------------数组索引-------------</color>")
    if self.shopidindex==0 then     
        HintPanel.Create(1, "您已经购买了全部新人折扣礼包") 
        return
    else 
       self.shopid=SYSSCLBManager.shopid[self.shopidindex] 
    end
    dump({self.shopid,self.shopidindex},"<color=red>--------------<礼包信息>-----------------</color>")
	self.backcall = backcall
	local parent = parent or GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject("SCLBShopPanel", parent)
	local tran = obj.transform
	self.transform = tran
    self.gameObject = obj
    self.chlids={}
    for i = 1, #SYSSCLBManager.shopid do
        self.chlids[#self.chlids+1]=self.transform:Find("Stage"..i)
    end
	self:MakeLister()
    self:AddMsgListener()
    self.ShopButtons=self.transform:Find("Stage"..self.shopidindex.."/Button"):GetComponent("Button")
    self.ShopButtons.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        self:OnShopClick()
    end
    )
	self.CloseButton = tran:Find("CloseButton"):GetComponent("Button")
    self.CloseButton.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        self:CloseButtonClick()
    end)  
	self:InitUI()
end


function C:InitUI()
	self:MyRefresh()
end

function C:MyRefresh()    
    for i = 1, #self.chlids do
        self.chlids[i].gameObject:SetActive(false)
    end
    self.chlids[self.shopidindex].gameObject:SetActive(true)
end

function C:CloseButtonClick()
    self:MyExit()
end

function C:OnShopClick()
	if GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios" then
		GameManager.GotoUI({gotoui = "sys_service_gzh",goto_scene_parm = "panel",desc="请关注“鲸鱼新家园”公众号获取"..self.gift_config.pay_title})
	else
		PayTypePopPrefab.Create(self.gift_config.id, "￥" .. (self.gift_config.price / 100))
	end
end

function C:on_model_sclb_gift_change_msg()
    self:MyExit()
end

function C:OnExitScene()
	self:MyExit()
end

function C:getCurrentShopID()
    for i=1, #SYSSCLBManager.shopid do
	    self.gift_config = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, SYSSCLBManager.shopid[i])
        self.status = MainModel.GetGiftShopStatusByID(self.gift_config.id)

        -- if i==1 then
        --     self.status=1
        -- end
	    if  self.status==1 then					    
		    return i
		end
    end	    
    return 0
end

--[[
	GetTexture("hall_btn_gift20")
	GetTexture("hall_btn_gift21")
	GetTexture("hall_btn_gift22")
	GetTexture("hall_btn_gift23")
	GetTexture("hall_btn_gift24")
	GetTexture("hall_btn_gift25")
	GetTexture("hall_btn_gift26")
	GetTexture("hall_btn_gift28")
	GetTexture("hall_btn_giftcz")
	GetTexture("hall_btn_gifthh")
	GetTexture("hall_btn_giftwz")
	GetTexture("hall_btn_giftxs")
	GetTexture("hall_btn_giftzz")
]]