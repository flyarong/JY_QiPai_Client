-- 创建时间:2019-12-17
-- Panel:Act_021_SXLBPanel
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

Act_021_SXLBPanel = basefunc.class()
local C = Act_021_SXLBPanel
C.name = "Act_021_SXLBPanel"
local cz_shopid = {[10087] = 1,[10088] = 1}
function C.Create(parent, backcall, config,isMini)
	dump(config,"<color=red>configconfigconfigconfig</color>")
	return C.New(parent, backcall, config,isMini)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
	self.lister["ExitScene"] = basefunc.handler(self, self.OnExitScene)
	self.lister["finish_gift_shop"] = basefunc.handler(self, self.on_finish_gift_shop)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	GameTipsPrefab.Hide()
	self:RemoveListener()
	destroy(self.gameObject)

	 
end

function C:ctor(parent, backcall, config,isMini)

	ExtPanel.ExtMsg(self)

	local parent = parent or GameObject.Find("Canvas/LayerLv4").transform
	self.backcall = backcall
	self.config = config
	local Cname  = isMini and "GameComGiftT4MiniPanel" or C.name
	local obj = newObject(Cname, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

local function color16z10(str)
	if str and string.len(str) == 8 then
		local n1 = string.sub(str, 1, 2)
		local n2 = string.sub(str, 3, 4)
		local n3 = string.sub(str, 5, 6)
		local n4 = string.sub(str, 7, 8)
		local num1 = tonumber(string.format("%d", "0x"..n1))
		local num2 = tonumber(string.format("%d", "0x"..n2))
		local num3 = tonumber(string.format("%d", "0x"..n3))
		local num4 = tonumber(string.format("%d", "0x"..n4))
		return Color.New(num1/255, num2/255, num3/255, num4/255)
	end
end

function C:InitUI()
	self.back_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnBackClick()
	end)
	self.bg_img.sprite = GetTexture(self.config.bg_img)
	self.buy_yes_img = {}
	self.buy_no_img = {}
	self.shopid = self.config.gift_id
	dump(self.shopid,"<color=red>XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX</color>")
	local _color
	for i = 1, 3 do
		local ui = {}
		LuaHelper.GeneratingVar(self["gift_rect"..i], ui)
		self.buy_yes_img[#self.buy_yes_img + 1] = ui.buy_btn
		self.buy_no_img[#self.buy_no_img + 1] = ui.buy_no_img
		--ui.buy_img.sprite = GetTexture(self.config.db_img[i])
		ui.cz_notice.gameObject:SetActive( cz_shopid[self.shopid[i]] == 1)
		ui["name_txt"].text = self.config.name_txt[i]
		--ui.buy_img:SetNativeSize()
		for j = 1, 2 do
			local iii = (i-1) * 2 + j
			ui["icon"..j.."_img"].sprite = GetTexture(self.config.icon_img[iii])
			ui["icon"..j.."_img"]:SetNativeSize()
			ui["icon"..j.."_txt"].text = self.config.pay_name[iii]
			_color = color16z10(self.config.font_c)
			if j == 1 and _color then
				ui["icon"..j.."_txt"].color = _color
			end
			_color = color16z10(self.config.gift_c)
			if j ~= 1 and _color then
				ui["icon"..j.."_txt"].color = _color
			end
			_color = color16z10(self.config.outline_c)
			if j == 1 and _color then
				local outLine = ui["icon"..j.."_txt"].transform:GetComponent("Outline")
				outLine.effectColor = _color
			end
		end

		local index = i
		local gift_config = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, self.shopid[index])
		ui.buy_btn.onClick:AddListener(function ()
			self:OnBuyClick(self.shopid[index])
		end)
		local ui_price = math.floor((gift_config.price or 0) / 100)
		ui.buy_txt.text = ui_price .. "元领取"
		ui.buy_no_txt.text = ui_price .. "元领取"
		--[[if self.config.name_img and #self.config.name_img > 0 then
			ui.cxz.gameObject:SetActive(false)
			ui.name_img.gameObject:SetActive(true)
			ui.name_img.sprite = GetTexture(self.config.name_img[i])
			ui.name_img:SetNativeSize()
		else
			ui.cxz.gameObject:SetActive(true)
			ui.name_img.gameObject:SetActive(false)
			if self.config.is_hz and self.config.is_hz == 0 then
				ui.hz_img.gameObject:SetActive(false)
			else
				ui.hz_img.gameObject:SetActive(true)
			end
			ui.name_txt.text = ui_price .. "元礼包"
			
			_color = color16z10(self.config.name_c)
			if _color then
				ui.name_txt.color = _color
			end
			_color = color16z10(self.config.name_outline)
			if _color then
				local outLine = ui.name_txt.transform:GetComponent("Outline")
				outLine.effectColor = _color
			end
		end--]]
		PointerEventListener.Get(self["tip_"..i].gameObject).onDown = function ()
			GameTipsPrefab.ShowDesc(--[[self:GetContentStr(self.shopid[i])--]]"超级奖池瓜分时可获得相应翻倍。", UnityEngine.Input.mousePosition)
		end
		PointerEventListener.Get(self["tip_"..i].gameObject).onUp = function ()
			GameTipsPrefab.Hide()
		end
	end
	self:MyRefresh()
end

function C:MyRefresh()
	for i = 1, 3 do
		local status = MainModel.GetGiftShopStatusByID(self.shopid[i])
		if status == 1 then
			self.buy_yes_img[i].gameObject:SetActive(true)
			self.buy_no_img[i].gameObject:SetActive(false)
		else
			self.buy_yes_img[i].gameObject:SetActive(false)
			self.buy_no_img[i].gameObject:SetActive(true)
		end
	end

end

function C:OnBackClick()
	if self.backcall then
		self.backcall()
	end
	self:MyExit()
end
function C:OnExitScene()
	self:MyExit()
end
function C:on_finish_gift_shop(id)
	self:MyRefresh()
end

function C:OnBuyClick(id)
	local gift_config = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, id)
	local status = MainModel.GetGiftShopStatusByID(gift_config.id)
    local b1 = MathExtend.isTimeValidity(gift_config.start_time, gift_config.end_time)

    if b1 then
		if status ~= 1 then
			local s1 = os.date("%m月%d日%H点", gift_config.start_time)
			local e1 = os.date("%m月%d日%H点", gift_config.end_time)
			HintPanel.Create(1, string.format( "您今日已购买过了，请明日再来购买。",s1,e1))
			return
		end
    else
		HintPanel.Create(1, "抱歉，此商品不在售卖时间内")
		return
    end
    
	if GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios" then
		GameManager.GotoUI({gotoui = "sys_service_gzh",goto_scene_parm = "panel",desc="请前往公众号获取"})
	else
		PayTypePopPrefab.Create(gift_config.id, "￥" .. (gift_config.price / 100))
	end
end

function C:GetContentStr(_shopid)
	local config =  MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, _shopid)
	local str = ""
	if config.content then 
		str = config.content[1]
		for i = 2, #config.content do
			str = str.."\n"..config.content[i]
		end
	end
	return str 
end

function C:OnDestroy()
	self:MyExit()
end