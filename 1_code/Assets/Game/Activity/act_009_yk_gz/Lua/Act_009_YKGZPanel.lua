local basefunc = require "Game/Common/basefunc"

Act_009_YKGZPanel = basefunc.class()
local C = Act_009_YKGZPanel
C.name = "Act_009_YKGZPanel"

function C.Create(parent)
	return C.New(parent)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
	self.lister = {}
	self.lister["AssetsGetPanelConfirmCallback"] = basefunc.handler(self,self.AssetsGetPanelConfirmCallback)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	DSM.PopAct()
	self:RemoveListener()
	destroy(self.gameObject)

	 
end

function C:OnDestroy()
	self:MyExit()
end

function C:ctor(parent)

	ExtPanel.ExtMsg(self)

	DSM.PushAct({panel = C.name})
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	
end

function C:InitUI()
	self.buy_btn.onClick:AddListener(
		function ()
			self:OnBuyClick(Act_009_YKGZManager.gift_id)
		end
	)
	self.get_btn.onClick:AddListener(
		function ()
			GameManager.GotoUI({gotoui = "sys_yk",goto_scene_parm = "panel"})
		end
	)
	self:MyRefresh()
end

function C:MyRefresh()
	local v = SYSYKManager.IsBuy1
	if v then 
		self.get_btn.gameObject:SetActive(true)
		self.buy_btn.gameObject:SetActive(false)
	else	
		self.get_btn.gameObject:SetActive(false)
		self.buy_btn.gameObject:SetActive(true)
	end
end


function C:OnBuyClick(id)
	local gift_config = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, id)
	local status = MainModel.GetGiftShopStatusByID(gift_config.id)
    local b1 = MathExtend.isTimeValidity(gift_config.start_time, gift_config.end_time)
    if b1 then
		if status ~= 1 then
			LittleTips.Create("抱歉，暂时不能购买此商品")
			return
		end
    else
		LittleTips.Create("抱歉，此商品不在售卖时间内")
		return
    end
    
	if GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios" then
		GameManager.GotoUI({gotoui = "sys_service_gzh",goto_scene_parm = "panel",desc="请前往公众号获取"})
	else
		PayTypePopPrefab.Create(gift_config.id, "￥" .. (gift_config.price / 100))
	end
end

function C:AssetsGetPanelConfirmCallback(data)
	if data and data.change_type == "buy_gift_bag_" .. Act_009_YKGZManager.gift_id then 
		self:MyRefresh()
		GameManager.GotoUI({gotoui = "sys_yk",goto_scene_parm = "panel"})
	end
end