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

Act_Ty_GiftsItemBase = basefunc.class()
local C = Act_Ty_GiftsItemBase
C.name = "Act_Ty_GiftsItemBase"
local M = Act_Ty_GiftsManager

function C.Create(parent, gift_key, index)
	return C.New(parent, gift_key, index)
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

function C:ctor(parent,gift_key,index)
	ExtPanel.ExtMsg(self)
	self.gift_key = gift_key
	self.index = index

	self:InitCfg()
	local parent = parent or GameObject.Find("Canvas/LayerLv4").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitCfg()
    self.name_key = "gift_" .. self.index .. "_name"
    self.icon_key = "gift_" .. self.index .. "_icon"
    self.zs_key = { self.index * 2 - 1, self.index * 2 }
    self:UpdateCfg()
end
function C:UpdateCfg()
	self.cfg = M.GetGiftItemCfg(self.gift_key)
	self.style_path = M.GetGiftStyle(self.gift_key)
	self.gift_id = self.cfg.gift_ids[self.index]
	self.gift_shop_cfg = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, self.gift_id)
	if not self.gift_shop_cfg then
        dump(self.gift_id, "<color=red>[未配置当前gift_id]或者[初始化时未请求Gift_id]:</color>")
        return 
	end
	self.gift_price = self.gift_shop_cfg.price

	self:UpdateStatusCfg()
	self:UpdateIsInTimeCfg()
end

function C:UpdateStatusCfg()
    self.gift_status = MainModel.GetGiftShopStatusByID(self.gift_id)
end

function C:UpdateIsInTimeCfg()
    self.isInTime = MathExtend.isTimeValidity(self.gift_shop_cfg.start_time, self.gift_shop_cfg.end_time)
end

function C:InitUI()
	-- dump(self.index,"<color=white>index</color>")
	-- dump(self.cfg,"<color=white>cfg</color>")
	-- dump(self.gift_id,"<color=white>gift_id</color>")

	--self.item_bg:GetComponent("Image").sprite = GetTexture(self.cfg.item_bg[self.index])
	local item_bg_img = self.item_bg:GetComponent("Image")
	SetTextureExtend(item_bg_img,self.style_path.."_".."bg_2")
	local names = self.cfg[self.name_key]
	self.tit_txt.text = names[1]
	self.award_l_txt.text = names[2]
	self.award_r_txt.text = names[3]

	local icons = self.cfg[self.icon_key]
	self.item_icon:GetComponent("Image").sprite = GetTexture(icons[1])
	self.award_l_img.sprite = GetTexture(icons[2])
	self.award_r_img.sprite = GetTexture(icons[3])

	self.award_l_z.gameObject:SetActive(self.cfg.is_zs[self.zs_key] == 1)
	self.award_r_z.gameObject:SetActive(self.cfg.is_zs[self.zs_key] == 1)

	self:CheckTip(1)
	self:CheckTip(2)
	self:CheckTip(3)

	self:InitBtn()
	self:InitTxtFmt()
	--self:MyRefresh()
end

function C:InitBtn()

	local ui_price = math.floor((self.gift_price or 0) / 100)
	self.buy_txt.text = ui_price .. "元领取"
	self.buy_no_txt.text = ui_price .. "元领取"

	self.buy_btn.gameObject:SetActive(self.gift_status == 1)
	self.buy_no_img.gameObject:SetActive(self.gift_status ~= 1)

	self.buy_btn.onClick:AddListener(function ()
		self:BuyGift()
	end)

	if self.cfg.buy_all_gift_id then
		if not M.CheckCanBuySingle(self.cfg.buy_all_gift_id) then
			self.buy_no_img.gameObject:SetActive(true)
		end
	end
end

function C:BuyGift()

	self:UpdateStatusCfg()
	self:UpdateIsInTimeCfg()

	if not self.isInTime then
		HintPanel.Create(1, "抱歉，此商品不在售卖时间内")
		return
	end

	if self.gift_status ~= 1 then
		local s1 = os.date("%m月%d日%H点", self.gift_shop_cfg.start_time)
		local e1 = os.date("%m月%d日%H点", self.gift_shop_cfg.end_time)
		HintPanel.Create(1, string.format( "您今日已购买过了，请明日再来购买。",s1,e1))
		return
	end
    
	if GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios" then
		GameManager.GotoUI({gotoui = "sys_service_gzh",goto_scene_parm = "panel",desc="请前往公众号获取"})
	else
		PayTypePopPrefab.Create(self.gift_id, "￥" .. (self.gift_price / 100))
	end
end

function C:InitTxtFmt()
	if self.cfg.name_txt_fmt then
		self:SetTxt(self.tit_txt.transform,self.cfg.name_txt_fmt)
	end
	if self.cfg.award_z_txt_fmt then
		self:SetTxt(self.award_l_txt.transform,self.cfg.award_z_txt_fmt)
		self:SetTxt(self.award_r_txt.transform,self.cfg.award_z_txt_fmt)
	end
end

function C:CheckTip(index)
	local cur_tip_btn = self["tip_"..index.."_btn"]
	if self.cfg["tip_"..index] then
		local cfg = self.cfg["tip_"..index]
		cur_tip_btn.gameObject:SetActive(true)
		cur_tip_btn.onClick:AddListener(function ()
			LTTipsPrefab.Show2(cur_tip_btn.transform,cfg[1],cfg[2])
		end)
	else
		cur_tip_btn.gameObject:SetActive(true)
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
	self.buy_btn.onClick:RemoveAllListeners()
	self:UpdateCfg()
	self:InitUI()
end