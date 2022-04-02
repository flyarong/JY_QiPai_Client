-- 创建时间:2020-05-28
-- Panel:Act_016_CPLXRQTLLBPanel
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

Act_016_CPLXRQTLLBPanel = basefunc.class()
local C = Act_016_CPLXRQTLLBPanel
C.name = "Act_016_CPLXRQTLLBPanel"
local M = Act_016_CPLXRQTLManager

function C.Create()
	return C.New()
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
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor()
	local parent = GameObject.Find("Canvas/LayerLv5").transform
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
	self.close_btn.onClick:AddListener(function ()
		self:MyExit()
	end)
	self.buy_btn.onClick:AddListener(function ()
		local shopid = M.shop_id
		local gb =  MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, shopid)
		if not gb then return end
		local price = gb.price
		if  GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios" then
			ServiceGzhPrefab.Create({desc="请前往公众号获取"})
		else
			PayTypePopPrefab.Create(shopid, "￥" .. (price / 100))
		end
	end)
	self:MyRefresh()
end

function C:MyRefresh()
	local status = MainModel.GetGiftShopStatusByID(M.shop_id)
	self.mask.gameObject:SetActive(status == 0)
end

function C:AssetsGetPanelConfirmCallback(data)
	if data and data.change_type == "buy_gift_bag_"..M.shop_id then 
		self:MyExit()
	end
end