-- 创建时间:2021-05-24
-- Panel:FKZJDPanel
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

FKZJDPanel = basefunc.class()
local C = FKZJDPanel
C.name = "FKZJDPanel"
local M = FKZJDManager


local tx_time = {1.2, 1.5, 6}
local show_gloden_time = {0.1, 0.2, 4}
local isPlayingAnim = false

function C.Create(parent, backball)
	return C.New(parent, backball)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["AssetChange"] = basefunc.handler(self,self.OnAssetChange)
	self.lister["ExitScene"] = basefunc.handler(self, self.MyExit)
    self.lister["EnterBackGround"] = basefunc.handler(self, self.OnEnterBackGround)
    self.lister["gift_bag_status_change_msg"] = basefunc.handler(self, self.on_gift_bag_status_change_msg)
    self.lister["get_task_award_response"] = basefunc.handler(self,self.on_get_task_award_response)
    self.lister["get_task_award_new_response"] = basefunc.handler(self,self.on_get_task_award_response)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:ClearTimer()
	self:EventAssetGet()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ClearTimer()
	if self.czAnimTimer then 
        self.czAnimTimer:Stop()
    end
	if self.qdTxTimer then 
        self.qdTxTimer:Stop()
    end
	if self.openTxTimer then 
        self.openTxTimer:Stop()
    end
	if self.showGlodenTimer then 
        self.showGlodenTimer:Stop()
    end
	isPlayingAnim = false
end

function C:EventAssetGet()
	if self.assetGetData then
		Event.Brocast("AssetGet", self.assetGetData)
		self.assetGetData = nil
	end
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:OnEnterBackGround()
	self:ClearTimer()
	self:EventAssetGet()
end

local function BuyGift(gift_id)
	local data = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, gift_id)
	if not data then
		HintPanel.Create(1, "未获取到商品数据")
		return
	end
	local isInTime = MathExtend.isTimeValidity(data.start_time, data.end_time)
	if not isInTime then
		HintPanel.Create(1, "抱歉，此商品不在售卖时间内")
		return
	end
	if GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios" then
		GameManager.GotoUI({gotoui = "sys_service_gzh", goto_scene_parm = "panel", desc = "请前往公众号获取"})
	else
		PayTypePopPrefab.Create(gift_id, "￥" .. (data.price / 100))
	end	
	data, isInTime = nil
end

function C:ctor(parent, backball)
	ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitGiftCfg()
	self:InitUI()
	self:ChangeHammer(M.GetDefaultHamIndex())
	self:RefreshHammerView()
	self:RefreshGiftView()
end

function C:InitGiftCfg()
	self.giftCfg = M.GetGiftCfg()
end

function C:InitPrefabH()
	self.hammerPre = {}
	for i = 1, 3 do
		local obj = newObject("FKZJDItemH", self.h_content.transform)
		obj.transform:Find("@h_img"):GetComponent("Image").sprite = GetTexture(M.GetEggCfg(i).hammer_icon)
		obj.transform:Find("@h_btn"):GetComponent("Button").onClick:AddListener(function()
			self:ChangeHammer(i)
		end)
		local giftUI = {}
		LuaHelper.GeneratingVar(obj.transform, giftUI)
		self.hammerPre[#self.hammerPre + 1] = giftUI
	end
end

function C:InitPrefabG()
	self.giftPre = {}
	for i = 1, 3 do
		local obj = newObject("FKZJDItemG", self.g_content.transform)
		local hamUI = {}
		LuaHelper.GeneratingVar(obj.transform, hamUI)
		self.giftPre[#self.giftPre + 1] = hamUI
	end
end

function C:RefreshHammerView()
	for i = 1, #self.hammerPre do
		self.hammerPre[i].h_txt.text = "x" .. M.GetHammerCount(i)
	end
end

function C:RefreshGiftView()
	dump(self.giftCfg)
	for i = 1, #self.giftPre do
		self.giftPre[i].coin_img.sprite = GetTexture("pay_icon_gold2")
		self.giftPre[i].ham_img.sprite = GetTexture(GameItemModel.GetItemToKey(self.giftCfg[i].item[2]).image)
		self.giftPre[i].coin_txt.text = "x" .. self.giftCfg[i].content[1]
		self.giftPre[i].ham_txt.text = "x" .. self.giftCfg[i].content[2]
		local _data = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, self.giftCfg[i].gift_id)
		self.giftPre[i].get_txt.text = _data.price/100 .. "元领取"
		self.giftPre[i].get_btn.onClick:RemoveAllListeners()
		self.giftPre[i].get_btn.onClick:AddListener(function()
			BuyGift(self.giftCfg[i].gift_id)
		end)
	end
end

function C:RefreshEggView()
	local hit_num = M.GetCurHitNum(self.curHammerId)
	if hit_num == 0 then
		if not self.egg_a_img.gameObject.activeSelf then
			self.egg_a_img.gameObject:SetActive(true)
			self.egg_b_img.gameObject:SetActive(false)
		end
		self.egg_a_img.sprite = GetTexture(M.GetEggCfg(self.curHammerId).egg_img[hit_num + 1])
	else
		if not self.egg_b_img.gameObject.activeSelf then
			self.egg_b_img.gameObject:SetActive(true)
			self.egg_a_img.gameObject:SetActive(false)
		end
		self.egg_b_img.sprite = GetTexture(M.GetEggCfg(self.curHammerId).egg_img[hit_num + 1])
	end
end

function C:ChangeHammer(id)

	if isPlayingAnim then
		return
	end

	self.curHammerId = id
	if self.oldHammerId then
		self.hammerPre[self.oldHammerId].h_s.gameObject:SetActive(false)
	end
	if self.curHammerId then
		self.oldHammerId = self.curHammerId
	end
	self.hammerPre[self.curHammerId].h_s.gameObject:SetActive(true)
	self.egg_get_txt.text = StringHelper.ToCash(M.GetEggAward(self.curHammerId)) .. "鲸币"
	self:RefreshEggView()
end

function C:OpenEgg()
	if isPlayingAnim then
		return
	end
	if M.GetHammerCount(self.curHammerId) < 1 then
		LittleTips.Create(M.GetEggCfg(self.curHammerId).need_hammer .. "不足")
        return
    end
    Network.SendRequest("get_task_award",{id = M.GetEggCfg(self.curHammerId).task_id})
end

function C:InitUI()

	self:InitPrefabH()
	self:InitPrefabG()

    CommonTimeManager.GetCutDownTimer(M.GetInfoCfg().endTime, self.act_time_txt)
	self.egg_btn.onClick:AddListener(function()
		self:OpenEgg()
	end)
	self.close_btn.onClick:AddListener(
		function ()
			self:MyExit()
		end
	)
	self.rule_btn.onClick:AddListener(
		function ()
        	self:OpenHelpPanel()
		end
	)
	self:MyRefresh()
end

function C:MyRefresh()

end

--砸锤子的动画
function C:PlayAnimCZ(isSuccess, openFunc)
	isPlayingAnim = true
	self.anim_qd.gameObject:SetActive(true)
	self.qd_animator = self.anim_qd.transform:GetComponent("Animator")
	self.qd_animator:Play("Dachui_Pt_H_fk", -1 ,0)
	if self.czAnimTimer then 
        self.czAnimTimer:Stop()
    end 
	self.czAnimTimer = Timer.New(function()
		self.tx_qd.gameObject:SetActive(true)
		self.qdTxTimer = Timer.New(function()
			self.tx_qd.gameObject:SetActive(false)
			self.anim_qd.gameObject:SetActive(false)
			if isSuccess then
				self:PlayAnimOpen(openFunc)
			else
				self:RefreshEggView()
				isPlayingAnim = false
			end
		end, 0.7, 1)
		self.qdTxTimer:Start()
	end, 0.5, 1)
	self.czAnimTimer:Start()
end

--金蛋打开的动画
function C:PlayAnimOpen(openFunc)
	self["tx_open_" .. self.curHammerId].gameObject:SetActive(true)
	if not self.egg_b_img.gameObject.activeSelf then
		self.egg_b_img.gameObject:SetActive(true)
		self.egg_a_img.gameObject:SetActive(false)
	end
	self.openTxTimer = Timer.New(function()
		self["tx_open_" .. self.curHammerId].gameObject:SetActive(false)
		if openFunc then
			openFunc()
		end
	end, tx_time[self.curHammerId],1)
	self.openTxTimer:Start()
	self:ShowGold()
end

function C:ShowGold()
	self.showGlodenTimer = Timer.New(function()
		--金币弹出的动画
		self.egg_b_img.sprite = GetTexture(M.GetEggCfg(self.curHammerId).egg_img[6])
		local icon = self.gold_img.transform
		local seq = DG.Tweening.DOTween.Sequence()
		local tweenKey = DOTweenManager.AddTweenToStop(seq)
		local image = icon.transform:GetComponent("Image")
		icon.gameObject:SetActive(true)
		seq:Append(icon:DOLocalMoveY(120, 2))
		seq:OnKill(function()
			if IsEquals(icon) then
				icon.localPosition = Vector3.New(0, 120, 0)
				local seq = DG.Tweening.DOTween.Sequence()
				local tweenKey = DOTweenManager.AddTweenToStop(seq)
				seq:Append(image:DOFade(0, 2))
				seq:OnKill(function()
					if IsEquals(icon) then
						image.color = Color.white
						icon.localPosition = Vector3.zero
						icon.gameObject:SetActive(false)
						self:RefreshEggView()
					end
				end)
			end
		end)
	end,show_gloden_time[self.curHammerId],1)
	self.showGlodenTimer:Start()
end

function C:OnAssetChange(_, data)
	self:RefreshHammerView()
	Event.Brocast("global_hint_state_set_msg", {gotoui = M.key })
	Event.Brocast("UpdateHallActivityYearRedHint")
end

function C:on_gift_bag_status_change_msg(_, data)
	if data.result ~= 0 then
        return
    end
	if M.IsCareGiftId(data.gift_bag_id) then
		dump(data, "<color=red>+++++on_gift_bag_status_change_msg+++++</color>")
		self:RefreshGiftView()
	end
end

function C:on_get_task_award_response(_, data)
	dump(data, "<color=red>+++++on_get_task_award_response+++++</color>")
	if data.result ~= 0 then
		HintPanel.ErrorMsg(data.result)
        return
    end
	if M.IsCareTaskId(data.id) then

		if table_is_null(data.award_list) then   
			self:PlayAnimCZ(false)
		else 
			self.assetGetData = {data = {{asset_type = data.award_list[1].asset_type, value = data.award_list[1].asset_value}}}
			local openFunc = function()
				if self.assetGetData then
					Event.Brocast("AssetGet", self.assetGetData)
					self.assetGetData = nil
				end
				isPlayingAnim = false
				self:RefreshGiftView()
			end
			self:PlayAnimCZ(true, openFunc)
		end 
		Event.Brocast("global_hint_state_set_msg", {gotoui = M.key })
	end
end

function C:OpenHelpPanel()
    local str =""
	local help_info = M.GetInfoCfg().help_info
    for i = 1, #help_info do
        str = str .. "\n" .. help_info[i]
    end
    self.introduce_txt.text = str
    IllustratePanel.Create({ self.introduce_txt.gameObject }, GameObject.Find("Canvas/LayerLv5").transform)
end