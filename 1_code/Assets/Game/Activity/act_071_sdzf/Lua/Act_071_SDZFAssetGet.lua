-- 创建时间:2021-12-10
-- Panel:Act_071_SDZFAssetGet
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

Act_071_SDZFAssetGet = basefunc.class()
local C = Act_071_SDZFAssetGet
C.name = "Act_071_SDZFAssetGet"

local M = Act_071_SDZFManager

function C.Create(data)
	return C.New(data)
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

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(data)
	ExtPanel.ExtMsg(self)
	local parent = GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self.normalData = data
	self:InitZZData()
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	DOTweenManager.OpenPopupUIAnim(self.transform)
end

function C:InitZZData()
	self.type = M.GetGetAwardSignsAwardType()
	self.normalSign = M.GetGetAwardSigns()
	if self.normalSign == 0 then
		dump("<color=white>获取当前至尊奖励异常</color>")
		self:MyExit()
	end
	
	self.zzData = {}
	if self.type == 1 then
		self.zzData.data = {}
		local cfg =  M.GetConfigFromLevel(self.normalSign)
		self.zzData.data[1] = { asset_type = cfg.zz_award2, value = cfg.zz_award2_num }
		self.zzData.data[2] = { asset_type = cfg.zz_award1, value = cfg.zz_award1_num }
	elseif self.type == -1 then

	end
end

function C:InitUI()
	self.BG_btn.onClick:AddListener(function()
		self:MyExit()
	end)
	self.confirm_btn.onClick:AddListener(function()
		self:MyExit()
	end)
	self.buy_btn.onClick:AddListener(function()
		GameManager.BuyGift(M.gift_id)
		self:MyExit()
	end)
	self:InitNormalAwards()
	self:InitZZAwards()
	self:MyRefresh()
end

function C:InitNormalAwards()
	dump(self.normalData, "<color=white>self.normalData</color>")
	for i = 1, #self.normalData.data do
		local b = GameObject.Instantiate(self.AwardPrefab, self.AwardNode1)
		self:ViewAward(b, self.normalData.data[i])
	end
end

function C:InitZZAwards()
	dump(self.zzData, "<color=white>self.zzData</color>")
	for i = 1, #self.zzData.data do
		local b = GameObject.Instantiate(self.AwardPrefab, self.AwardNode2)
		self:ViewAward(b, self.zzData.data[i])
	end
end

function C:ViewAward(obj, data)
	obj.gameObject:SetActive(true)
	local awardUI = {}
	LuaHelper.GeneratingVar(obj, awardUI)
	local item = GameItemModel.GetItemToKey(data.asset_type)
	awardUI.AwardIcon_img.sprite = GetTexture(item.image)
	awardUI.DescText_txt.text = item.name .. "x" .. StringHelper.ToCash(data.value)
	if data.asset_type == "shop_gold_sum" then
		awardUI.DescText_txt.text = item.name .. "x" .. StringHelper.ToCash(data.value / 100) 
	end
end

function C:MyRefresh()
end
