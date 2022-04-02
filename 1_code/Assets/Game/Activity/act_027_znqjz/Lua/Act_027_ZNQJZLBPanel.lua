-- 创建时间:2020-08-19
-- Panel:Act_027_ZNQJZLBPanel
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
 -- 取消按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
 -- 确认按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
 --]]

local basefunc = require "Game/Common/basefunc"

Act_027_ZNQJZLBPanel = basefunc.class()
local C = Act_027_ZNQJZLBPanel
C.name = "Act_027_ZNQJZLBPanel"
local M = Act_027_ZNQJZManager
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
	ExtPanel.ExtMsg(self)
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
	self.buy_btn.onClick:AddListener(
		function()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			local gb =  MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, M.shop_id)
			if not gb then return end
			local price = gb.price
			if  GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios" then
				ServiceGzhPrefab.Create({desc="请前往公众号获取"})
			else
				PayTypePopPrefab.Create(M.shop_id, "￥" .. (price / 100))
			end
		end
	)
	
	self.close_btn.onClick:AddListener(
		function()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
			self:MyExit()
		end
	)
	PointerEventListener.Get(self["wan"].gameObject).onDown = function ()
		GameTipsPrefab.ShowDesc("万能字可替代任意字，兑换时自动使用", UnityEngine.Input.mousePosition)
	end
	PointerEventListener.Get(self["wan"].gameObject).onUp = function ()
		GameTipsPrefab.Hide()
	end

	self:MyRefresh()
end

function C:MyRefresh()
	local s = MainModel.GetGiftShopStatusByID(M.shop_id)
	if s == 1 then
		self.mask.gameObject:SetActive(false)
	else
		self.mask.gameObject:SetActive(true)
		if os.time() >= 1599321600 then
			self.mask_txt.text = "已购买"
		else
			self.mask_txt.text = "明日再来"
		end
	end
end

function C:AssetsGetPanelConfirmCallback()
	self:MyRefresh()
end