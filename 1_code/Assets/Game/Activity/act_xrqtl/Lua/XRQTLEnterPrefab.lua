local basefunc = require "Game/Common/basefunc"

XRQTLEnterPrefab = basefunc.class()
local C = XRQTLEnterPrefab
C.name = "XRQTLEnterPrefab"
local M = XRQTLManager
function C.Create(parent)
	return C.New(parent)
end
function C:AddMsgListener()
	for proto_name, func in pairs(self.lister) do
		Event.AddListener(proto_name, func)
	end
end

function C:MakeLister()
	self.lister = {}
	self.lister["global_hint_state_change_msg"] = basefunc.handler(self, self.on_global_hint_state_change_msg)
end

function C:RemoveListener()
	for proto_name, func in pairs(self.lister) do
		Event.RemoveListener(proto_name, func)
	end
	self.lister = {}
end

function C:MyExit()
	if self.update_timer then
        self.update_timer:Stop()
	end
	self.update_timer = nil
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end


function C:ctor(parent)
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self) 
	--self.transform.localPosition = Vector3.zero
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	--Event.Brocast("year_btn_created",{enterSelf = self})

end

function C:InitUI()
	self.transform:GetComponent("Button").onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnEnterClick()
	end)
	self:MyRefresh()
end

function C:OnEnterClick()
	XRQTLPanel.Create()
	PlayerPrefs.SetString(M.key .. MainModel.UserInfo.user_id, os.time())
	self:MyRefresh()
end

function C:MyRefresh()
	if self.update_timer then
		self.update_timer:Stop()
		self.update_timer = nil
	end
	if not IsEquals(self.Red) then
		return
	end
	local s = M.GetHintState({gotoui= M.key})
	self.LFL.gameObject:SetActive(false)
	self.Red.gameObject:SetActive(false)
	if s == ACTIVITY_HINT_STATUS_ENUM.AT_Get then 
		self.LFL.gameObject:SetActive(true)
	end 
	if s == ACTIVITY_HINT_STATUS_ENUM.AT_Red then 
		self.Red.gameObject:SetActive(true)
	end
	self:SetHint()

	self.time = StringHelper.GetTodayEndTime() - os.time()
	self.update_timer = Timer.New(function()
        self.time = self.time - 1
        self:UpdateTime()
    end, 1, -1, nil, true)
    self.update_timer:Start()
    self:UpdateTime()
end

function C:on_global_hint_state_change_msg(parm)
	if parm.gotoui == M.key then
		self:MyRefresh()
	end
end

function C:SetHint()
	local day = M.GetDayIndex() + 1
	if day > 6 or day < 1 then return end
	local task_data = M.GetCurrTaskData()
	if task_data and task_data.award_status == 1 then
		--self.lfl_txt.text = "领福利"
	elseif task_data and task_data.award_status == 2 then
		local str = ""
		if string.find(XRQTLManager.config.Info[day + 1].task_award_text,"鲸币") then
			str = string.gsub(XRQTLManager.config.Info[day + 1].task_award_text,"鲸币","")
		elseif string.find(XRQTLManager.config.Info[day + 1].task_award_text,"福卡") then
			str = string.gsub(XRQTLManager.config.Info[day + 1].task_award_text,"福卡","")
			str = str .. "元"
		end
		local txt = "领" .. str
		--self.lfl_txt.text = txt
	end
	--去掉新人七天乐次日的奖励tips提示，玩家领取当天的奖励后，不再展示次日奖励的提示。8.4.2020
	if task_data and task_data.award_status == 1 then
		self.LFL.gameObject:SetActive(true)
	elseif task_data and task_data.award_status == 2 then
		self.LFL.gameObject:SetActive(false)
	end
end

function C:UpdateTime()
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

function C:ToTimeStr(second)
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