-- 创建时间:2020-10-26
-- Panel:Act_037_SSYSCPanel
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

Act_037_SSYSCPanel = basefunc.class()
local C = Act_037_SSYSCPanel
C.name = "Act_037_SSYSCPanel"
local M = Act_037_SSYSCManager

local exchange_type_id = 17

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
	ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Canvas/LayerLv3").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()

	self.get_gift_btn.onClick:AddListener(
		function ()
			GameManager.GotoUI({gotoui = "game_FishingHall"})
		end
	)
end

function C:InitUI()
	for k,v in ipairs(M.UIConfig.shop_item_config) do
		self:CreateShopItem(v)
	end
	self:MyRefresh()
end

function C:MyRefresh()
	for k,v in pairs(self.shop_item_list) do
		local cfg = v.cfg
		local item_tbl = v.tbl
		if (cfg.day_limit and cfg.day_limit ~= 0) and M.GetShopBuyCountToday(cfg.id) >= cfg.day_limit then
			item_tbl.buy_btn.gameObject:SetActive(false)
			item_tbl.buy_gray.gameObject:SetActive(true)
		else
			item_tbl.buy_btn.gameObject:SetActive(true)
			item_tbl.buy_gray.gameObject:SetActive(false)
		end
	end
	self.gift_count_txt.text = "x" .. GameItemModel.GetItemCount(M.item_key) .. ""
end

function C:OnDestroy()
	self:MyExit()
end

function C:CreateShopItem(cfg)
	local parent = self.shop_item_content
	local item = GameObject.Instantiate(self.shop_item,parent)
	local item_tbl = LuaHelper.GeneratingVar(item.transform)
	self.shop_item_list = self.shop_item_list or {}
	item_tbl.award_img.sprite = GetTexture(cfg.award_img)
	item_tbl.award_img:SetNativeSize()
	item_tbl.gray_name_txt.text = cfg.name
	item_tbl.normal_name_txt.text = cfg.name
	item_tbl.award_img.raycastTarget = false
	item_tbl.normal_name_txt.raycastTarget = false
	item_tbl.limit_icon.transform:GetComponent("Image").raycastTarget = false
	if cfg.day_limit and cfg.day_limit ~= 0 then
		item_tbl.limit_icon.gameObject:SetActive(true)
	else
		item_tbl.limit_icon.gameObject:SetActive(false)
	end
	item_tbl.item_cost_txt.text = "x" .. cfg.item_cost
	item_tbl.buy_btn.onClick:AddListener(function()
		self:BuyBtnOnClick(cfg)
	end)
	local tip_award_type = "prop_double11_cjq"
	if cfg.award_type == tip_award_type then
		item_tbl.tip_btn.gameObject:SetActive(true)
		item_tbl.tip_btn.onClick:AddListener(function()
			LittleTips.Create("可参与疯狂抽大奖活动，有效期：11月10日7:30~11月16日23:59:59。")
		end)
	else
		item_tbl.tip_btn.gameObject:SetActive(false)
		item_tbl.tip_btn.transform:GetComponent("Image").raycastTarget = false
	end
	item.gameObject:SetActive(true)
	self.shop_item_list[cfg.id] = {
		obj = item,
		tbl = item_tbl,
		cfg = cfg
	}
end

function C:BuyBtnOnClick(cfg)
	if GameItemModel.GetItemCount(M.item_key) >= cfg.item_cost then
		Network.SendRequest("activity_exchange",{type = exchange_type_id,id = cfg.id},"请求兑换",function(data)
			if data.result == 0 then
				M.AddShopBuyCountToday(cfg.id)
				self:MyRefresh()
			else
				HintPanel.ErrorMsg(data.result)
			end
		end)
	else
		LittleTips.Create("您的礼盒不足")
	end
end

function C:OnDestroy()
    self:MyExit()
end