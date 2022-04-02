-- 创建时间:2020-09-22
-- Panel:Act_030_CJFBLBItemPanel
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

Act_030_CJFBLBItemPanel = basefunc.class()
local C = Act_030_CJFBLBItemPanel
C.name = "Act_030_CJFBLBItemPanel"

function C.Create(parent,b)
	return C.New(parent,b)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    --完成礼包购买
     self.lister["finish_gift_shop"] = basefunc.handler(self, self.on_finish_gift_shop)
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

function C:ctor(parent,b)
	self.shop_id = b
	ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	

	self.tps1_btn.onClick:AddListener(
		function () 
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			LittleTips.Create("超级奖池瓜分时可获得相应翻倍")
		end
	)

	self.tong_btn.onClick:AddListener(
		function () 
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			self:BuyShop(self.shop_id)
		end
	)


	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self:ShowDiffUI()
	self:MyRefresh()
end

function C:MyRefresh()
	self:GetFinshGiftShowUI(self.shop_id)
end

function C:BuyShop(shopid)
    local price = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, shopid).price
    dump(MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, shopid))
    if  GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios" then
        ServiceGzhPrefab.Create({desc="请前往公众号获取"})
    else
        PayTypePopPrefab.Create(shopid, "￥" .. (price / 100))
    end
end

function C:ShowDiffUI()
	local config_shop = Act_030_CJFBLBManager.GetConfigByID(self.shop_id)
	if self.shop_id then
		self.lbname_txt.text = config_shop.title
		self.number_txt.text = tostring(config_shop.number)
		self.jg_txt.text = config_shop.jg.."领取"
		self.ka_txt.text = config_shop.ka
		self.bx_img.sprite = GetTexture(config_shop.bx_img)
		self.kaname_img.sprite = GetTexture(config_shop.ka_img)
	end
end

function C:GetFinshGiftShowUI(shopid)
	local status = MainModel.GetGiftShopStatusByID(shopid)
	if IsEquals(self.gameObject) then
		if status == 1 then
			self.tong_btn.gameObject:SetActive(true)
			self.hui_img.gameObject:SetActive(false)
		else
			self.tong_btn.gameObject:SetActive(false)
			self.hui_img.gameObject:SetActive(true)
		end
	end
end

function C:on_finish_gift_shop(id)
	local shop_config = {
    10419, 10420, 10421, 10422, 10423, 10424, 10425, 10426, 10427,
	}
	for i=1,#shop_config do
		if id == shop_config[i] then
			self:MyRefresh()
		end
	end
	
end