-- 创建时间:2020-02-19
-- Panel:Fishing3DActBKPrefab
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

Fishing3DActBKPrefab = basefunc.class()
local C = Fishing3DActBKPrefab
C.name = "Fishing3DActBKPrefab"
local M = BY3DActXYCBManager

local XYCB_State = {
	Not = "Not", -- 未获得
	NotLock = "NotLock", -- 未解锁
	WaitOpen = "WaitOpen", -- 待开启
	Opening = "Opening", -- 开启中
	OpenFinish = "Finish", -- 开启完成
}
function C.Create(panelSelf, parent, index)
	return C.New(panelSelf, parent, index)
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
	self:StopDJS()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor(panelSelf, parent, index)
	self.panelSelf = panelSelf
	self.index = index
	local obj = newObject("fish3d_act_bk_prefab", parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	tran.localPosition = Vector3.zero
	
	self.cb_state = XYCB_State.Not
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.dj_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnDJClick()
    end)
	self:MyRefresh()
end

function C:MyRefresh()
	local cb_da
	if M.m_data.caibei_all_info and M.m_data.caibei_all_info[self.index] then
		cb_da = M.m_data.caibei_all_info[self.index]
		if cb_da.state ~= 0 then
			self.cfg = M.GetIDConfig(cb_da.type)
		end
	end
	self:UpdateState()
	
	self.dj_btn.gameObject:SetActive(true)
	self.bk_img.gameObject:SetActive(true)
	self.bk_nil_img.gameObject:SetActive(false)
	self.wc_node.gameObject:SetActive(false)
	self.ing_node.gameObject:SetActive(false)
	self.lock_node.gameObject:SetActive(false)
	self.open_node.gameObject:SetActive(false)

	self:StopDJS()
	dump(self.cb_state)
	if self.cb_state == XYCB_State.Not then
		self.dj_btn.gameObject:SetActive(false)
		self.bk_img.gameObject:SetActive(false)
		self.bk_nil_img.gameObject:SetActive(true)
	elseif self.cb_state == XYCB_State.NotLock then
		self.lock_node.gameObject:SetActive(true)
		self.bk_nil_img.gameObject:SetActive(true)
		self.bk_img.gameObject:SetActive(false)
		self.js_desc_txt.text = "VIP3"
	elseif self.cb_state == XYCB_State.WaitOpen then
		self.bk_img.sprite = GetTexture(self.cfg.icon)
		if M.GetOpeningCBMax() > M.GetOpeningCBNum() then
			self.open_node.gameObject:SetActive(true)
		else
			self.open_node.gameObject:SetActive(false)
		end
	elseif self.cb_state == XYCB_State.Opening then
		self.bk_img.sprite = GetTexture(self.cfg.icon)
		self.ing_node.gameObject:SetActive(true)
		self:RunDJS()
	elseif self.cb_state == XYCB_State.OpenFinish then
		self.bk_img.sprite = GetTexture(self.cfg.icon)
		self.wc_node.gameObject:SetActive(true)
	else
		dump(self.cb_state)
	end
end

function C:UpdateState()
	if self.index == 5 and VIPManager.get_vip_level() < 3 then
		self.cb_state = XYCB_State.NotLock
	else
		if M.m_data.caibei_all_info and M.m_data.caibei_all_info[self.index] then
			local cb_da = M.m_data.caibei_all_info[self.index]
			if cb_da.state == 0 then
				self.cb_state = XYCB_State.Not
			elseif cb_da.state == 1 then
				self.cb_state = XYCB_State.WaitOpen
			else
				local tt = cb_da.start_time + self.cfg.cd - os.time()
				if tt > 0 then
					self.cb_state = XYCB_State.Opening
				else
					self.cb_state = XYCB_State.OpenFinish
				end
			end
		else
			self.cb_state = XYCB_State.Not
		end
	end
end

function C:OnDJClick()
	dump(self.cb_state, "<color=red>彩贝状态</color>")
	self.panelSelf:OnBKClick(self.index)
end

function C:RunDJS()
	self:StopDJS()
	local cb_da = M.m_data.caibei_all_info[self.index]
	self.down_val = cb_da.start_time + self.cfg.cd - os.time()

	self.update_time = Timer.New(function ()
    	self:UpdateTime()
    end, 1, -1, nil, true)
    self:UpdateTime(true)
    self.update_time:Start()
end
function C:StopDJS()
	if self.update_time then
		self.update_time:Stop()
	end
	self.update_time = nil
end
function C:UpdateTime(b)
	if not b then
		if self.down_val then
			self.down_val = self.down_val - 1
		end
	end
	if not self.down_val or self.down_val <= 0 then
		self.djs_txt.text = "00:00:00"
		self:MyRefresh()
	else
		local hh = math.floor(self.down_val / 3600)
		local ff = math.floor((self.down_val % 3600) / 60)
		local mm = self.down_val % 60
		self.djs_txt.text = string.format("%02d:%02d:%02d", hh, ff, mm)
	end
end

