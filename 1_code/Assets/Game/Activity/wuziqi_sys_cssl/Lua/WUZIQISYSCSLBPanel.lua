-- 创建时间:2020-10-11
-- Panel:WUZIQISYSCSSLPanel
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

WUZIQISYSCSLBPanel = basefunc.class()
local C = WUZIQISYSCSLBPanel
C.name = "WUZIQISYSCSLBPanel"
local M = WUZIQISYSCSSLManager


local DESCRIBE_TEXT = {
    "1.礼包购买后获得对应的鲸币奖励，同时财神送金等级增加5级",
	"2.若财神送金等级已经为满级，则购买后不再增加财神送金等级"
}
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
	self.lister["ExitScene"]=basefunc.handler(self,self.MyExit)
	self.lister["shop_info_get"] = basefunc.handler(self,self.on_shop_info_get)
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

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(parent)
	local parent = parent or GameObject.Find("Canvas/LayerLv3").transform
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
	EventTriggerListener.Get(self.back_btn.gameObject).onClick = basefunc.handler(self, self.OnBackClick)
	EventTriggerListener.Get(self.get_btn.gameObject).onClick = basefunc.handler(self, self.OnGetLB)

	self.rule_btn.onClick:AddListener(
		function ()
        	self:OpenHelpPanel()
		end
	)
	self:MyRefresh()
end

function C:MyRefresh()
	self.get_already.gameObject:SetActive(not M.IsCanGetGift())
end

function C:OnBackClick()
	self:MyExit()
end

function C:OnGetLB()
	dump("------>OnGetLB<------")
	self:BuyShop(M.gift_id)
end

function C:on_sys_jjsl_data_msg()
	self:MyRefresh()
end

function C:on_shop_info_get()
	self:MyRefresh()
end
function C:BuyShop(shopid)
    local gb =  MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, shopid)
    if not gb then return end
	local price = gb.price
	if  GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios" then
		ServiceGzhPrefab.Create({desc="请前往公众号获取"})
	else
		PayTypePopPrefab.Create(shopid, "￥" .. (price / 100))
	end
end

function C:OpenHelpPanel()
    local str =""
    for i = 1, #DESCRIBE_TEXT do
        str = str .. DESCRIBE_TEXT[i] .. "\n" 
    end
    self.introduce_txt.text = str
    IllustratePanel.Create({ self.introduce_txt.gameObject }, GameObject.Find("Canvas/LayerLv5").transform)
end