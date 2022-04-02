-- 创建时间:2020-02-06
-- Panel:LHDPlayerClockPrefab
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

LHDPlayerClockPrefab = basefunc.class()
local C = LHDPlayerClockPrefab
C.name = "LHDPlayerClockPrefab"

function C.Create(parent)
	return C.New(parent)
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
	self:StopRunTime()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor(parent)
	local obj = newObject("lhd_player_clock_prefab", parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self:MyRefresh()
end
function C:UpdateUI(b)
	self.clock_txt.text = math.floor(self.down_t)
	if b and self.down_t <= 10 then
		self:RunAnim()
		self:RunSSAnim()
		ExtendSoundManager.PlaySound(audio_config.dld.dld_game_timeout.audio_name)
	end
end
function C:UpdateClockImg(t)
	local val = (self.down_t-t) / self.max_down_t
	self.clock_img.fillAmount = val
end

function C:RunAnim()
	self:StopAnim()
	local tran = self.clock_txt.transform
	tran.localScale = Vector3.one
	self.seq = DoTweenSequence.Create()
	self.seq:Append(tran:DOScale(0.8, 3/15))
	self.seq:Append(tran:DOScale(2.3, 3/15))
	self.seq:Append(tran:DOScale(2.36, 4/15))
	self.seq:Append(tran:DOScale(1, 5/15))
	self.seq:OnKill(function ()
		if IsEquals(self.clock_txt) then
			self.clock_txt.transform.localScale = Vector3.one
		end
	end)
end
function C:StopAnim()
	if self.seq then
		self.seq:Kill()
		self.seq = nil
	end
end
-- 闪烁
function C:RunSSAnim()
	self:StopSSAnim()
	local tran = self.clock_txt.transform
	tran.localScale = Vector3.one
	self.ss_seq = DoTweenSequence.Create()
	-- 频率
	local pl = 1
	if self.down_t <= 10 and self.down_t > 5 then
		pl = 1
	elseif self.down_t <= 5 and self.down_t >= 3 then
		pl = 3
	else
		pl = 5
	end

	local ss = 1 / (pl * 2)
	for i = 1, pl do
		self.ss_seq:AppendCallback(function ()
			self.glow.gameObject:SetActive(true)
		end)
		self.ss_seq:AppendInterval(ss)
		self.ss_seq:AppendCallback(function ()
			self.glow.gameObject:SetActive(false)
		end)
		self.ss_seq:AppendInterval(ss)
	end
	self.ss_seq:AppendInterval(-1 * ss)
	self.ss_seq:OnKill(function ()
		if IsEquals(self.glow) then
			self.glow.gameObject:SetActive(false)
		end
	end)
end
function C:StopSSAnim()
	if self.ss_seq then
		self.ss_seq:Kill()
		self.ss_seq = nil
	end
end
function C:MyRefresh()
end
   
function C:SetActive(b)
	self.gameObject:SetActive(b)
	self.glow.gameObject:SetActive(false)
end
function C:SetRectAttr(pos, scale)
	if pos then
		self.transform.localPosition = pos
	end
	if scale then
		self.transform.localScale = Vector3.New(scale, scale, scale)
	else
		self.transform.localScale = Vector3.one
	end
end

function C:StopRunTime()
	self.is_run = false
	self:SetActive(false)
	self:StopAnim()
	self:StopSSAnim()
	if self.run_time then
		self.run_time:Stop()
		self.run_time = nil
	end
end
function C:RunDownTime(t)
	self:StopRunTime()
	if t and t > 0 then
		self.is_run = true
		t = math.floor(t)
		self:SetActive(true)
		self.down_t = t
		self.cur_t = 0
		self.max_down_t = t
		if self.max_down_t < 10 then
			self.max_down_t = 10
		end
		self.clock_txt.transform.localScale = Vector3.one
		self.run_time = Timer.New(function ()
			self.cur_t = self.cur_t + 0.033
			self:UpdateClockImg(self.cur_t)
			if self.cur_t >= 1 then
				self.down_t = self.down_t - 1
				self.cur_t = self.cur_t - 1
				if self.down_t <= 0 then
					self:StopRunTime()
				end
				self:UpdateUI(true)
			end
		end, 0.033, -1)
		self.run_time:Start()
		self:UpdateUI()
	end
end
