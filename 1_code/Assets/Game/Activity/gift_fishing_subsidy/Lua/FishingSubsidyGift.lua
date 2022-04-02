-- 创建时间:2019-04-18
-- Panel:FishingSubsidyGift
local basefunc = require "Game/Common/basefunc"

FishingSubsidyGift = basefunc.class()
local C = FishingSubsidyGift
C.name = "FishingSubsidyGift"

local gift_map = {
	[1] = {gift_ids={10163, 10164, 10165}, idx="1",
	title_img = {"xsth_imgf_6","xsth_imgf_18","xsth_imgf_48"},
	tips = {"加赠8000鱼币","加赠12000鱼币","加赠38000鱼币"},
	btn_text = {"6元领取","18元领取","48元领取"},
	}, 

	[2] = {gift_ids={10052, 10053, 10054}, idx="2",
	title_img = {"xsth_imgf_48","xsth_imgf_98","xsth_imgf_198"},
	tips = {"加赠38000鱼币","加赠68000鱼币","加赠158000鱼币"},
	btn_text = {"48元领取","98元领取","198元领取"},
	}, 
	

	[3] = {gift_ids={10055, 10056, 10057}, idx="3",
	title_img = {"xsth_imgf_198","xsth_imgf_498","xsth_imgf_998"},
	tips = {"加赠158000鱼币","加赠348000鱼币","加赠708000鱼币"},
	btn_text = {"198元领取","498元领取","998元领取"},
	}, 
}
local instance
function C.Create(tag, giveUpCb, buyCb, parm)
	dump(tag,"<color=red>捕鱼限时特惠配置--------</color>")
	if not GameGlobalOnOff.LIBAO then
		if giveUpCb then giveUpCb() end
		return
	end
	if not instance or not IsEquals(instance.gameObject) then
		instance = C.New(tag, giveUpCb, buyCb, parm)
	else
		instance:MyRefresh()
	end
	return instance
end

function C.Close()
	if instance then
		if instance.timer then
			instance.timer:Stop()
			instance.timer = nil
		end
		instance:MyExit()
	end
	instance = nil
end

function C.IsShow()
	return instance ~= nil
end


function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
	self.lister = {}
	self.lister["ExitScene"] = C.Close
	self.lister["ReceivePayOrderMsg"] = basefunc.handler(self, self.OnReceivePayOrderMsg)
	self.lister["model_finish_gift_bag_msg"] = basefunc.handler(self, self.OnQueryStatusResponse)
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

function C:ctor(tag, giveUpCb, buyCb, parm)
	self.parm = parm
	local parent = GameObject.Find("Canvas/LayerLv3").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.tag = tag
	self.giveUpCb = giveUpCb
	self.buyCb = buyCb
	self.gameObject:SetActive(false)
	LuaHelper.GeneratingVar(self.transform, self)

	self.gift_list = gift_map[tag]

	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	for i=1, #gift_map[self.tag].gift_ids do
		self["buy"..i.."_btn"].onClick:AddListener(
			function ()
				self:OnBuyClicked(gift_map[self.tag].gift_ids[i])
			end
		)
	end
	self.endTime = os.time() + 3600 * 2
	self.timeleft_txt.text = '02:00:00'
	self.countdown_txt.text = '02:00:00'

	if GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios" then
		LuaHelper.AddDeferred(function()
			HintPanel.Create(1, "内购未完成")
			FullSceneJH.RemoveByTag("FishingSubsidyGift")
		end)

		LuaHelper.AddPurchasingUnavailable(function()
			HintPanel.Create(1, "手机设置了禁止APP内购")
			FullSceneJH.RemoveByTag("FishingSubsidyGift")
		end)

		LuaHelper.AddPurchaseFailed(function()
			HintPanel.Create(1, "购买失败")
			FullSceneJH.RemoveByTag("FishingSubsidyGift")
		end)
	end

	EventTriggerListener.Get(self.close_btn.gameObject).onClick = basefunc.handler(self, self.OnCloseClicked)
	EventTriggerListener.Get(self.giftbox_btn.gameObject).onClick = basefunc.handler(self, self.ShowBuyGift)
	
	self.timer = Timer.New(basefunc.handler(self, self.UpdateTimer), 1, -1, false)
	self.timer:Start()
	self:OnQueryStatusResponse()

	self:MyRefresh()
end

function C:MyRefresh()
	local a = FishingManager.CheckCanEnter(tonumber(self.gift_list.idx))
	if not a then
		self.BuyBox.gameObject:SetActive(true)
	else
		self.BuyBox.gameObject:SetActive(false)
	end
end

function C:OnCloseClicked()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
	self.BuyBox.gameObject:SetActive(false)
	if self.parm and self.parm.is_close then
		C.Close()
	else
		self:CheckBuyGift()
	end
end

function C:OnBuyClicked(shop_id)
	local price = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, shop_id).price
	ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
	if GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios" then
		GameManager.GotoUI({gotoui = "sys_service_gzh",goto_scene_parm = "panel",desc="请关注“%s”公众号领取充捕鱼限时特惠礼包"})
	else
		PayTypePopPrefab.Create(shop_id, "￥" .. (price / 100), function (result)
			if result == 0 then
			end
		end)
	end
end

function C:OnReceivePayOrderMsg(msg)
	if msg.result == 0 then
		UIPaySuccess.Create()
		self:OnQueryStatusResponse()
    else
        HintPanel.ErrorMsg(msg.result)
    end
    FullSceneJH.RemoveByTag("FishingSubsidyGift")
end

function C:ShowBuyGift()
	self.BuyBox.gameObject:SetActive(true)
end

function C:UpdateTimer()
	local t = self.endTime - os.time()
	if t >= 0 then
		local cd = C.FormatTime(t)
		self.timeleft_txt.text = cd
		self.countdown_txt.text = cd
	else
		C.Close()
	end
end

function C:CheckBuyGift()
	self:DoCloseAnim()
end

function C.FormatTime(t)
	local h = math.floor(t/3600)
	local m = math.floor((t%3600)/60)
	local s = t - h * 3600 - m * 60
	return (h < 10 and "0" .. h or h) .. ":" .. (m < 10 and "0" .. m or m) .. ":" .. (s < 10 and "0" .. s or s)
end

function C:OnQueryStatusResponse()
	if not IsEquals(self.gameObject) then return end 
	local can_show = false
	self.endTime = nil
	for i=1,#gift_map[self.tag].gift_ids do
		local gift_id = gift_map[self.tag].gift_ids[i]
		local data = GameFlashSaleGiftManager.GetGiftData(gift_id)
		local gift_config = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, gift_id)

		dump(gift_map[self.tag].btn_text[i],"")
		self["buy"..i.."_txt"].text = gift_map[self.tag].btn_text[i]
		self["title"..i.."_img"].sprite = GetTexture(gift_map[self.tag].title_img[i]) 
		self["title"..i.."_img"]:SetNativeSize()
		self["tips"..i.."_txt"].text = gift_map[self.tag].tips[i]
		if MainModel.IsCanBuyGiftByID(gift_id) then
			can_show = true
			if not self.endTime then
				self.endTime = MainModel.GetGiftEndTimeByID(gift_id)
			end
			self["buy"..i.."_btn"].gameObject.transform:GetComponent("Image").sprite = GetTexture("com_btn_5")
			self["buy"..i.."_btn"].enabled = true
		else
			self["buy"..i.."_btn"].gameObject.transform:GetComponent("Image").sprite = GetTexture("com_btn_8")
			self["buy"..i.."_btn"].enabled = false
		end
	end
	if can_show then
		if self.endTime > os.time() then
			self.gameObject:SetActive(true)
			self:UpdateTimer()
		end
	else
		if self.giveUpCb then
			self.giveUpCb()
		end
		C.Close()
	end 
end

function C:DoCloseAnim()
	local seq = DG.Tweening.DOTween.Sequence()
	local tweenKey = DOTweenManager.AddTweenToExit(seq)

	self.giftbox_img.gameObject:SetActive(true)
	self.giftbox_img.transform.localPosition = Vector3.zero
	self.giftbox_img.transform.localScale = Vector3.one * 2
	seq:Append(self.giftbox_img.transform:DOMoveBezier(self.giftbox_btn.transform.position, 150, 0.5))
	seq:Join(self.giftbox_img.transform:DOScale(1, 0.5))

	seq:OnKill(function ()
		DOTweenManager.RemoveExitTween(tweenKey)
		self.giftbox_img.gameObject:SetActive(false)
		if self.giveUpCb then self.giveUpCb() end
	end)
end

function C:GetShopIdIndex(tag,shop_id)
	for i=1,#gift_map[tag].gift_ids do
		if 	shop_id ==  gift_map[tag].gift_ids[i] then 
			return i
		end 
	end
end