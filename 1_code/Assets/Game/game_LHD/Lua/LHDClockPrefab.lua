-- 创建时间:2019-11-28
-- Panel:LHDClockPrefab
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

LHDClockPrefab = basefunc.class()
local C = LHDClockPrefab
C.name = "LHDClockPrefab"

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
	local obj = newObject("clock_prefab", parent)
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
	self.clock_txt.text = self.down_t
	if b and self.down_t <= 5 then
		ExtendSoundManager.PlaySound(audio_config.dld.dld_game_timeout.audio_name)
	end
end

function C:MyRefresh()
end

function C:SetActive(b)
	self.gameObject:SetActive(b)
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
		self.run_time = Timer.New(function ()
			self.down_t = self.down_t - 1
			if self.down_t <= 0 then
				self:StopRunTime()
			end
			self:UpdateUI(true)
		end, 1, -1)
		self.run_time:Start()
		self:UpdateUI()
	end
end