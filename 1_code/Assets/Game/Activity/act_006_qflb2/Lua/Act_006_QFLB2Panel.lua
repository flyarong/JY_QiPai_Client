-- 创建时间:2020-03-26
-- Panel:Act_006_QFLB2Panel
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

local basefunc = require "Game/Common/basefunc"

Act_006_QFLB2Panel = basefunc.class()
local C = Act_006_QFLB2Panel
C.name = "Act_006_QFLB2Panel"

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
	self.config = MoneyCenterQFLBManager.get_cfg()
	self.buy_btn.onClick:AddListener(
		function ()
			self:OnBuyClick(10085)
		end
	)
	self.get_btn.onClick:AddListener(
		function ()
			MoneyCenterQFLBPanel.Create()
		end
	)
	self.help_btn.onClick:AddListener(
		function ()
			LTTipsPrefab.Show(self.help_btn.gameObject.transform,2,self.config.qflb[2].desc)
		end
	)
	self:MyRefresh()
end

function C:MyRefresh()
	self.data = MoneyCenterQFLBManager.get_data_all_return_lb_info()
	local n = "all_return_lb_"
	local v = self.data[n .. 2]
	if v.is_buy == 1 then 
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
			LittleTips.Create("请重新登录后购买")
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
	if data and data.change_type == "buy_gift_bag_10085" then 
		self:MyRefresh()
		MoneyCenterQFLBPanel.Create()
	end
	if data and data.change_type == "buy_gift_bag_10086" then 
		self:MyRefresh()
		MoneyCenterQFLBPanel.Create()
	end
end