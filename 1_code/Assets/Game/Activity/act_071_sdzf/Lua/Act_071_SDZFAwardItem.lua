-- 创建时间:2021-12-08
-- Panel:Act_071_SDZFAwardItem
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

Act_071_SDZFAwardItem = basefunc.class()
local C = Act_071_SDZFAwardItem
C.name = "Act_071_SDZFAwardItem"

local M = Act_071_SDZFManager

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

function C:ctor()
	ExtPanel.ExtMsg(self)
	local parent = GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self.isHideFx = false
	self:InitUI()
end

function C:InitUI()
	self.lock_zz_lock1 = self.lock_zz.transform:Find("ImageLock1")
	self.lock_zz_lock2 = self.lock_zz.transform:Find("ImageLock2")
	self:MyRefresh()
end

function C:MyRefresh()
end

function C:RecycleToPool(pool)
	self.transform:SetParent(pool)
	self.transform.localPosition = Vector3.zero
	self.gameObject:SetActive(false)
end

function C:TakeFromPool(contaniner)
	self.transform:SetParent(contaniner)
	self.transform.localPosition = Vector3.zero
	self.gameObject:SetActive(true)
end

function C:RefreshView(index)

	self.index = index or self.index
	local cfg = M.GetConfigFromLevel(self.index)
	local data = M.GetData()
	self.lv_txt.text = cfg.level .. "级"
	self.icon_normal_img.sprite = GetTexture(cfg.normal_award_img)
	self.icon_zz1_img.sprite = GetTexture(cfg.zz_award1_img)
	self.icon_zz2_img.sprite = GetTexture(cfg.zz_award2_img)

	self.num_normal_txt.text = "x" .. StringHelper.ToCash(cfg.normal_award_num)
	self.num_zz1_txt.text = "x" .. StringHelper.ToCash(cfg.zz_award1_num)
	self.num_zz2_txt.text = "x" .. StringHelper.ToCash(cfg.zz_award2_num)
	
	self.showTxNormal = false
	self.showTxZZ = false
	self.geted.gameObject:SetActive(false)
	self.tx.gameObject:SetActive(false)
	if self.index < data.curGetLvNormal then
		self:GetedNormal()
	elseif self.index == data.curGetLvNormal and self.index <= data.curLv then
		self:GetNormal()
	else
		self:NoGetNormal(data.curGetLvNormal, data.curLv)
	end

	self.lock_zz.gameObject:SetActive(false)
	self.geted_zz.gameObject:SetActive(false)
	self.tx_zz.gameObject:SetActive(false)

	if data.isZZZF then
		if self.index < data.curGetLvZZ then
			self:GetedZZ()
		elseif self.index == data.curGetLvZZ and self.index <= data.curLv then
			self:GetZZ()
		else
			self:NoGetZZ(data.curGetLvZZ, data.curLv)
		end
	else
		self:LockZZ()
	end
end

--已获得
function C:GetedNormal()
	self.geted.gameObject:SetActive(true)
end

function C:GetNormal()
	self.showTxNormal = true
	self.tx.gameObject:SetActive(not self.isHideFx and self.showTxNormal)
	self.normal_get_btn.onClick:RemoveAllListeners()
	self.normal_get_btn.onClick:AddListener(function()
		M.SetGetAwardSigns(1)
		dump(1, "<color=white> 请求领取奖励 </color>")
		Network.SendRequest("christmas_blessing_recieve_award", {award_type = 1})
	end)
end

function C:NoGetNormal(curGetLvNormal, curLv)
	self.normal_get_btn.onClick:RemoveAllListeners()
	self.normal_get_btn.onClick:AddListener(function()
		if curLv == 0 or curLv < self.index then
			LittleTips.Create("请升级后再领取此奖励")
		else
			LittleTips.Create("请先领取" .. curGetLvNormal .. "级的奖励")
		end
	end)
end

function C:GetedZZ()
	self.geted_zz.gameObject:SetActive(true)
end

function C:LockZZ()
	self.lock_zz.gameObject:SetActive(true)
end

function C:GetZZ()
	self.showTxZZ = true
	self.tx_zz.gameObject:SetActive(not self.isHideFx and self.showTxZZ)
	self.zz_get_btn.onClick:RemoveAllListeners()
	self.zz_get_btn.onClick:AddListener(function()
		M.SetGetAwardSigns(2)
		dump(2, "<color=white> 请求领取至尊奖励 </color>")
		Network.SendRequest("christmas_blessing_recieve_award", {award_type = 2})
	end)
end

function C:NoGetZZ(curGetLvZZ, curLv)
	self.zz_get_btn.onClick:RemoveAllListeners()
	self.zz_get_btn.onClick:AddListener(function()
		if curLv == 0 or curLv < self.index then
			LittleTips.Create("请升级后再领取此奖励")
		else
			LittleTips.Create("请先领取" .. curGetLvZZ .. "级的至尊奖励")
		end
	end)
end

function C:HideFx()
	self.isHideFx = true
	self:RefreshFx()
end

function C:ShowFx()
	self.isHideFx = false
	self:RefreshFx()
end

function C:RefreshFx()
	self.tx.gameObject:SetActive(not self.isHideFx and self.showTxNormal)
	self.tx_zz.gameObject:SetActive(not self.isHideFx and self.showTxZZ)
end