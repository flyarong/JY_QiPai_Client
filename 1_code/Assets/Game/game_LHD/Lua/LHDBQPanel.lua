-- 创建时间:2019-12-23
-- Panel:LHDBQPanel
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

LHDBQPanel = basefunc.class()
local C = LHDBQPanel
C.name = "LHDBQPanel"
local M = LHDModel

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
	self.clock_pre:MyExit()
	self:RemoveListener()
	destroy(self.gameObject)

	 
end

function C:ctor()

	ExtPanel.ExtMsg(self)

	local parent = GameObject.Find("Canvas/LayerLv2").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.clock_pre = LHDClockPrefab.Create(self.js_node)
	self.clock_pre:SetActive(false)
	self.FQ_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnFQClick()
    end)
	self.BQ_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnBQClick()
    end)
	self:MyRefresh()
end

function C:MyRefresh()
	local m_data = M.data
	if M.IsCanBQ(m_data.seat_num) then
		self.gameObject:SetActive(true)
		if m_data.countdown and m_data.countdown > 0 then
			self.js_node.gameObject:SetActive(true)
			self.clock_pre:RunDownTime(m_data.countdown)
		else
			self.js_node.gameObject:SetActive(false)
			self.clock_pre:StopRunTime()
		end

		local d = m_data.room_info.init_stake * (M.GetCurRate() - M.GetCurPlayerMDRate(m_data.seat_num))
		local no = M.GetOnePlayerJBSeatno()
		if no > 0 then
			local player = M.GetSeatnoToPlayer(no)
			self.hint1_txt.text = "玩家" .. player.base.name .. "进行了加倍砸蛋"
		else
			self.hint1_txt.text = "玩家XXX进行了加倍砸蛋"
		end
		self.hint2_txt.text = "是否跟" .. StringHelper.ToCash(d) .. "鲸币,进入下一轮砸蛋"
	else
		self.gameObject:SetActive(false)
	end
end

function C:OnFQClick()
	Network.SendRequest("nor_lhd_nor_buqi", {buqi=0}, "弃牌", function (data)
		if data.result ~= 0 then
			HintPanel.ErrorMsg(data.result)
		end
	end)
	self.gameObject:SetActive(false)
	self.clock_pre:StopRunTime()
end

function C:OnBQClick()
	Network.SendRequest("nor_lhd_nor_buqi", {buqi=1}, "跟牌", function (data)
		if data.result ~= 0 then
			if data.result == 1003 then
				M.hintCondition()
			else
				HintPanel.ErrorMsg(data.result)
			end
		end
	end)
	self.gameObject:SetActive(false)
	self.clock_pre:StopRunTime()
end

