-- 创建时间:2019-11-27
-- Panel:LHDEggPrefab
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

LHDEggPrefab = basefunc.class()
local C = LHDEggPrefab
C.name = "LHDEggPrefab"
local M = LHDModel

function C.Create(parent_transform, config, call, panelSelf)
	return C.New(parent_transform, config, call, panelSelf)
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
function C:ctor(parent_transform, config, call, panelSelf)
	self.config = config
	self.call = call
	self.panelSelf = panelSelf
	local obj = newObject(C.name, parent_transform)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.tm_xh_txt = ComImageWordsPrefab.Create(self.tm_xh_node, GetPrefab("tm_xh_txt"), "0")
	self.tm_xh_txt:SetSpacing(-6)
	self.dan_anim = self.dan:GetComponent("Animator")
	self.card_pre = LHDCardPrefab.Create(self.card_node, 0)
	self.touch_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnTouchClick()
    end)
	self:MyRefresh()
end
function C:MyRefresh()
	self.data = M.GetEggByIndex(self.config.index)
	self:RefreshEgg()
end
function C:RefreshEgg()
	if self.data then
		if self.data.card_num <= 0 then
			self.is_tm_state = false
		end
		self.gameObject:SetActive(true)
		if self.data.card_num == -1 then
			self.dan.gameObject:SetActive(false)
			self.ps_dan.gameObject:SetActive(true)
			self.tm_egg.gameObject:SetActive(false)
			self.ps_tm_dan.gameObject:SetActive(false)
		elseif self.data.card_num == -2 then
			self.dan.gameObject:SetActive(false)
			self.ps_dan.gameObject:SetActive(false)
			self.tm_egg.gameObject:SetActive(false)
			self.ps_tm_dan.gameObject:SetActive(true)
		elseif self.data.card_num == 0 then
			self.dan.gameObject:SetActive(true)
			self.ps_dan.gameObject:SetActive(false)
			self.tm_egg.gameObject:SetActive(false)
			self.ps_tm_dan.gameObject:SetActive(false)
		else
			local call = function ()			
				local dz = M.data.room_info.init_stake * ( M.GetCurRate() + M.data.stake_rate_data[M.data.super_rate])
				self.tm_xh_txt:SetStr(StringHelper.ToCash(dz))
				self.dan.gameObject:SetActive(false)
				self.ps_dan.gameObject:SetActive(false)
				self.tm_egg.gameObject:SetActive(true)
				self.ps_tm_dan.gameObject:SetActive(false)
				self.card_pre:SetData(self.data.card_num)
			end

			if self.is_tm_state then
				call()
			else
				self.is_tm_state = true
				local beginPos = self:GetPos()
				LHDAnimation.PlayTSAnim(self.panelSelf.transform, beginPos, function ()
					call()
				end)
			end
		end
	else
		self.gameObject:SetActive(false)
	end
end

function C:OnTouchClick()
	dump(self.data, "<color=red>Egg data</color>")
	if self.call then
    	self.call(self.panelSelf, self.config.index)
    end
end

function C:SetPos(pos)
	self.transform.localPosition = pos
end
function C:GetPos(type)
	return self.transform.position
end
function C:SetData(data)
	self.data = data
	self:RefreshEgg()
end

-- 摸蛋
function C:PlayMPAnim()
	if self.data.card_num == 0 then
		self.dan.gameObject:SetActive(false)
		LHDAnimation.PlayZDAnim(self.panelSelf.panelSelf.transform, "lhd_dan_anim", self.dan_anim_node.position, 1, true, function ()
			self:MyRefresh()
		end)
	else
		self.tm_egg.gameObject:SetActive(false)
		LHDAnimation.PlayZDAnim(self.panelSelf.panelSelf.transform, "lhd_tmdan_anim", self.dan_anim_node.position, 1, true, function ()
			self:MyRefresh()
		end)
	end
end
