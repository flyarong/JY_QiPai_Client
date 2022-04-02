-- 创建时间:2019-09-25
-- Panel:SYSXYJLEnterPrefab
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

SYSXYJLEnterPrefab = basefunc.class()
local C = SYSXYJLEnterPrefab
C.name = "SYSXYJLEnterPrefab"

function C.Create(parent, cfg)
	return C.New(parent, cfg)
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
	RedHintManager.RemoveRed(RedHintManager.RedHintKey.RHK_Task_Accurate, self.task_accrate_can_get.gameObject)

	if self.update_time then
		self.update_time:Stop()
	end
	self.update_time = nil

	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor(parent, cfg)
	self.config = cfg

	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()

	self.transform.localPosition = Vector3.zero

	self.time_call_map = {}
	self.update_time = Timer.New(function ()
    	self:Update()
    end, 1, -1, nil, true)
	self.update_time:Start()

	self:InitUI()
end

function C:InitUI()
	self.enter_btn = self.transform:GetComponent("Button")
	self.enter_btn.onClick:AddListener(function ()
    	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnEnterClick()
	end)
	RedHintManager.AddRed(RedHintManager.RedHintKey.RHK_Task_Accurate, self.get_img.gameObject)

	self:MyRefresh()	
end

function C:MyRefresh()
	local cur_t = os.time()
	-- 活动时间到后执行
	local t = 1
	if t < 1 then
		t = 1
	end
    self.time_call_map["activity_over"] = {time_call = self:GetCall(t), run_call = basefunc.handler(self, self.MyRefresh)}

	local acc_task = SYSXYJLManager.GetAccurateTaskData()

	if not acc_task then
		return
	end

	if MainModel.UserInfo.AccurateTaskNotIsFirst then
		self:OnEnterClick()
	end

	self.end_valid_time = 0
	for k,v in pairs(acc_task) do
        self.end_valid_time = v.end_valid_time
        break
    end
	self.down_time = self.end_valid_time - cur_t
	if self.down_time > 0 then

	    self.time_call_map["time"] = {time_call = self:GetCall(1), run_call = basefunc.handler(self, self.UpdateTime)}
	    self:UpdateTime(true)
	else
		self.time_call_map["time"] = nil
		self.accurate_task_time_txt.text = "已结束"
	end
end
--返回当天的某一时间的unix时间戳
function C:GetDurTime(x)
	local t = os.time() + 8 * 60 * 60
	local f = math.floor(t / 86400)
	return f * 86400 + x - 8 * 60 * 60
end

function C:GetCall(t)
	local tt = t
	local cur = 0
	return function (st)
		cur = cur + st
		if cur >= tt then
			cur = cur - tt
			return true
		end
		return false
	end
end
function C:Update()
	for k,v in pairs(self.time_call_map) do
		if v.time_call(1) then
			v.run_call()
		end
	end
end
function C:UpdateTime(b)
	if not b then
		if self.down_time then
			self.down_time = self.down_time - 1
		end
		if self.down_time <= 0 then
			self:MyRefresh()
			return
		end
	end
	if not self.down_time then
		self.accurate_task_time_txt.text = "--:--"
	else
		self.accurate_task_time_txt.text = StringHelper.formatTimeDHMS2(self.down_time)
	end
end

function C:OnEnterClick()
	local task_map = SYSXYJLManager.GetAccurateTaskData()
	if task_map then
		AccurateTaskPanel.Create()
	else
		LittleTips.Create("没有活动")
	end
end

function C:OnDestroy()
	self:MyExit()
end
