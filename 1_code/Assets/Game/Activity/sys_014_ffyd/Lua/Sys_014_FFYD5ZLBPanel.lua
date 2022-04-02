-- 创建时间:2020-05-20
-- Panel:Sys_014_FFYD5ZLBPanel
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

Sys_014_FFYD5ZLBPanel = basefunc.class()
local C = Sys_014_FFYD5ZLBPanel
C.name = "Sys_014_FFYD5ZLBPanel"
-- local shopid = {10277,10278,10279}
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
	self.lister["AssetsGetPanelConfirmCallback"] = basefunc.handler(self, self.AssetsGetPanelConfirmCallback)
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

function C:ctor(parent)
	local parent = parent or GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self.cfg = Sys_014_FFYDManager.GetConfig()
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	dump(self.cfg, "<color=white>xxxxxxxxxxxxxxxxxxxxxxxxxxxxx</color>")
	for i = 1, #self.cfg do
		local itemCfg = self.cfg[i]
		local item = GameObject.Instantiate(self.item, self.item_content.transform)
		item.gameObject:SetActive(true)
		local itemUI = {}
		LuaHelper.GeneratingVar(item.transform, itemUI)
		itemUI.old_price_txt.text = "原价" .. itemCfg.old_price .. "元"
		itemUI.buy_txt.text = itemCfg.price .. "元领取"
		itemUI.buy_mask_txt.text = itemCfg.price .. "元领取"
		itemUI.buy_btn.onClick:AddListener(function()
			self:BuyShop(itemCfg.gift_id)
		end)
		for j = 1, #itemCfg.award_name do
			local award_item = GameObject.Instantiate(self.award_item, itemUI.awardNode.transform)
			award_item.gameObject:SetActive(true)
			local awardItemUI = {}
			LuaHelper.GeneratingVar(award_item.transform, awardItemUI)
			awardItemUI.award_img.sprite = GetTexture(itemCfg.award_icon[j])
			awardItemUI.award_name_txt.text = itemCfg.award_name[j]
			awardItemUI.award_num_txt.text = itemCfg.award_num[j]
			if j == #itemCfg.award_name then
				awardItemUI.add.gameObject:SetActive(false)
			end
		end
	end

	-- for i =1 ,3 do
	-- 	self["buy"..i.."_btn"].onClick:AddListener(
	-- 		function()
	-- 			self:BuyShop(shopid[i])
	-- 		end
	-- 	)
	-- end
	self.close_btn.onClick:AddListener(
		function ()
			self:MyExit()
		end
	)
	self:MyRefresh()
end

function C:MyRefresh()
	if not IsEquals(self.gameObject) then return end
	-- for i = 1,3 do
	-- 	local status = MainModel.GetGiftShopStatusByID(shopid[i])
	-- 	self["buy"..i.."_mask"].gameObject:SetActive( not (status == 1))
	-- end
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

function C:AssetsGetPanelConfirmCallback()
	self:MyRefresh()
end