-- 创建时间:2020-12-28
-- Panel:Template_NAME
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

Act_Ty_GiftsPanel = basefunc.class()
local C = Act_Ty_GiftsPanel
local M = Act_Ty_GiftsManager
C.name = "Act_Ty_GiftsPanel"

function C.Create(parent,gift_key)
	return C.New(parent,gift_key)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
	self.lister = {}
	self.lister["ExitScene"] = basefunc.handler(self, self.MyExit)
	self.lister["finish_gift_shop"] = basefunc.handler(self, self.MyRefresh)
	self.lister["model_task_change_msg"] = basefunc.handler(self, self.MyRefresh)
	self.lister["act_fmt_gifts_panel_refresh"] = basefunc.handler(self, self.MyRefresh)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	Event.Brocast("act_ty_giftspanel_create_msg",false)
	self:RemoveListener()
	self:ClearGiftItem()
	Event.Brocast("GiftPanelClosed")
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:ctor(parent,gift_key)
	ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.gift_key = gift_key

	self:UpdateCfg()

	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:UpdateCfg()
	self.cfg = M.GetGiftCfg(self.gift_key)
	self.style_path = M.GetGiftStyle(self.gift_key)
end

-- function C:UpdateData()
-- 	self.data = M.GetGiftData(self.gift_key)
-- end

function C:InitUI()
	self.back_btn.onClick:AddListener(function()
        self:MyExit()
    end)
    self:ResetRectList()
	self:InitGiftItem()
	
	SetTextureExtend(self.bg_img,self.style_path.."_".."bg_1")
	--self.bg_img:SetNativeSize()
	--self.back_btn_img = self.back_btn:GetComponent("Image")
	SetTextureExtend(self.back_btn_img,self.style_path.."_".."bg_3")
	self.back_btn_img:SetNativeSize()
	--self.bg_img.sprite = GetTexture(self.cfg.panel_bg)
	if self.cfg.panel_tit_icon then
		self.tit_img.gameObject:SetActive(true)
		self.tit_img.sprite = GetTexture(self.cfg.panel_tit_icon)
	else
		self.tit_img.gameObject:SetActive(false)
	end

	-- self.time_txt.text = self.cfg.time_txt
	-- self.desc_txt.text = self.cfg.desc_txt

	if self.cfg.time_txt_fmt then
		self:SetTxt(self.time_txt.transform,self.cfg.time_txt_fmt)
	end

	-- if self.cfg.desc_txt_fmt then
	-- 	self:SetTxt(self.desc_txt.transform,self.cfg.desc_txt_fmt)
	-- end
	CommonTimeManager.GetCutDownTimer(self.cfg.end_time,self.time_txt)
    --self:MyRefresh()
	self:InitBuyAll()
	self:RefreshBuyAll()
	Event.Brocast("act_ty_giftspanel_create_msg",true)
end

function C:ResetRectList()
	self.rect_list = {}
	self.rect_list [1] = self.rect1
	self.rect_list [2] = self.rect2
	self.rect_list [3] = self.rect3
end

function C:InitGiftItem()
	self:ClearGiftItem()
	for i = 1, 3 do
		local pre = Act_Ty_GiftsItemBase.Create(self.rect_list[i],self.gift_key,i)
		if pre then
			self.item_cell_list[#self.item_cell_list + 1] = pre
		end
	end
end

function C:ClearGiftItem()
	if self.item_cell_list then
		for k,v in ipairs(self.item_cell_list) do
			v:MyExit()
		end
	end
	self.item_cell_list = {}
end

function C:RefreshGiftItem()
	if self.item_cell_list then
		for k,v in ipairs(self.item_cell_list) do
			v:MyRefresh()
		end
	end
end

function C:SetTxt(txt_trans, fmt_cfg)
	if #fmt_cfg >= 1 then
		txt_trans:GetComponent("Text").color = M.ColorToRGB(fmt_cfg[1])
	end

	local outline_com = txt_trans:GetComponent("Outline")
	if #fmt_cfg == 1 then
		if outline_com then
			destroy(outline_com)
		end
	end

	if #fmt_cfg == 2 then
		if not outline_com then
			outline_com =  txt_trans.gameObject:AddComponent(typeof(UnityEngine.UI.Outline))
		end
		outline_com.effectColor = M.ColorToRGB(fmt_cfg[2])
    end
end

function C:MyRefresh()

	self:UpdateCfg()

	if M.IsGiftActive(self.gift_key) then
		self:RefreshGiftItem()
	else
		self:MyExit()
	end

	self:RefreshBuyAll()
end

--一键购买
function C:InitBuyAll()

	self.itemCfg = M.GetGiftItemCfg(self.gift_key)
	self.buy_all_gift_id = self.itemCfg.buy_all_gift_id
	dump(self.itemCfg, "<color=white>CCCCCCCCCCCCCCCCCCCCCfg</color>")
	if not self.buy_all_gift_id then
		return
	end
	local gift_config = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, self.buy_all_gift_id)
	self.buy_all_txt.text = gift_config.price / 100 .. "元"
	self.buy_all_gray_txt.text = gift_config.price / 100 .. "元"
	self.give_txt.text = "多送" .. M.GetCurBuyAllGive(self.gift_key)
	self.buy_all_btn.gameObject:SetActive(true)
	self.buy_all_give.gameObject:SetActive(true)
	self.buy_all_btn.onClick:AddListener(function()
		GameManager.BuyGift(self.buy_all_gift_id)
	end)
end

function C:RefreshBuyAll()
	if not self.buy_all_gift_id then
		return
	end
	self.buy_all_gift_status = MainModel.GetGiftShopStatusByID(self.buy_all_gift_id)
	if self.buy_all_gift_status ~= 1 then
		self.buy_all_gray.gameObject:SetActive(true)
		return
	end
	--是否已购买单个
	local isBuySingle = false
	local singleTaskIds = self.itemCfg.gift_ids
	for i = 1, #singleTaskIds do
		if not M.CheckCanBuySingle(singleTaskIds[i]) then
			isBuySingle = true
			break
		end
	end
	self.buy_all_gray.gameObject:SetActive(isBuySingle)
end