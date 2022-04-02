-- 创建时间:2019-09-25
-- Panel:SYSXRZSEnterPrefab
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

SYSXRZSEnterPrefab = basefunc.class()
local M = SYSXRZSEnterPrefab
M.name = "SYSXRZSEnterPrefab"

function M.Create(parent, cfg)
	return M.New(parent, cfg)
end

function M:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function M:MakeLister()
	self.lister = {}
	self.lister["global_hint_state_change_msg"] = basefunc.handler(self, self.on_global_hint_state_change_msg)
end

function M:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function M:MyExit()
	if self.update_timer then
        self.update_timer:Stop()
        self.update_timer = nil
    end

	self:RemoveListener()
	destroy(self.gameObject)
end

function M:ctor(parent, cfg)
	self.config = cfg

	local obj = newObject("SYSXRZSEnterPrefab", parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()

	self.transform.localPosition = Vector3.zero

	self:InitUI()
end

function M:OnDestroy(  )
	self:MyExit()
end

function M:InitUI()
	self.enter_btn = self.transform:GetComponent("Button")
	self.enter_btn.onClick:AddListener(function ()
		self:OnEnterClick()
	end)
	self:MyRefresh()
end

function M:MyRefresh()
	local data = SYSXRZSManager.GetData()
	if not data then return end
	self.red_img.gameObject:SetActive(false)
	self.get_img.gameObject:SetActive(false)
	if data.at_status == ACTIVITY_HINT_STATUS_ENUM.AT_Nor then

	elseif data.at_status == ACTIVITY_HINT_STATUS_ENUM.AT_Red then
		self.red_img.gameObject:SetActive(true)
	elseif data.at_status == ACTIVITY_HINT_STATUS_ENUM.AT_Get then
		self.get_img.gameObject:SetActive(true)
	end
	self.time = MainModel.FirstLoginTime() + 7*86400  - os.time()
	if self.update_timer then
		self.update_timer:Stop()
		self.update_timer = nil
	end
	self.update_timer = Timer.New(function()
		self.time = self.time - 1
		self:UpdateTime()
	end, 1, -1, nil, true)
	self.update_timer:Start()
	self:UpdateTime()
end

function M:UpdateTime()
    if self.time<=0 then
        self.time=0
    end 
	local str 	
	str = StringHelper.formatTimeDHMS3(self.time)
	if IsEquals(self.time_txt) then
		self.time_txt.text = str
	end
	if self.time <= 0 then
		if self.update_timer then
			self.update_timer:Stop()
		end
        self.update_timer = nil
	end
end

function M:OnEnterClick()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
	if SYSXRZSManager.ShowOldorNew() == "Old" then 
		return NewPlayerActivityPanel.Create(nil, 1)
	else
		return NewPlayerActivityPanelBIG_New.Create()
	end
end

function M:OnDestroy()
	self:MyExit()
end

function M:on_global_hint_state_change_msg(parm)
	if parm.gotoui == SYSXRZSManager.key then
		self:MyRefresh()
	end
end

function M:ToTimeStr(second)
	if not second or second < 0 then
        return "0秒"
    end
    local timeDay = math.floor(second/86400)
    local timeHour = math.fmod(math.floor(second/3600), 24)
    local timeMinute = math.fmod(math.floor(second/60), 60)
    local timeSecond = math.fmod(second, 60)
    if timeDay > 0 then
        return string.format("%d天%d时%d分", timeDay, timeHour, timeMinute)
    elseif timeHour > 0 then
        return string.format("%d时%d分", timeHour, timeMinute)
    elseif timeMinute > 0 then
        return string.format("%d分", timeMinute)
    else
        return string.format("%d秒", timeSecond)
    end
end