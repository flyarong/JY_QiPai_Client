-- 创建时间:2019-01-18

local basefunc = require "Game/Common/basefunc"

ActivityBanner = basefunc.class()

ActivityBanner.name = "ActivityBanner"

local m_data
local instance
local activityToShow = {}
local shownActivityIds = {}
local curOffX

function ActivityBanner.Create()
	if not GameGlobalOnOff.ActivityBanner then return end
	if not instance then
		instance = ActivityBanner.New()
	end
	return instance
end

function ActivityBanner.Start()
	Event.AddListener("EnterScene", ActivityBanner.OnEnterScene)
	Event.AddListener("ExitScene", ActivityBanner.OnExitScene)
end

function ActivityBanner:ctor()
	local parent = GameObject.Find("Canvas/LayerLv4").transform
	self.gameObject = newObject("ActivityBanner", parent)
	self.transform = self.gameObject.transform
	local a,b = GameButtonManager.RunFun({gotoui="sys_act_operator",}, "GetActivatedActivityList")
	if a and not table_is_null(b) then
		self.data = b
	end

	LuaHelper.GeneratingVar(self.transform, self)
	self:Init()
end

function ActivityBanner:Init()
	self.speed = -Screen.width/10
	self.rect = self.transform:GetComponent("RectTransform").rect
	self:ScrollShow()
end

function ActivityBanner:Show()
	local data = ActivityBanner.GetActivityData(activityToShow[1])
	if data then
		self.icon_img.sprite = GetTexture(data.icon)
		self.desc_txt.text = data.desc
		if curOffX then
			self.transform.localPosition = Vector3.New(curOffX, 300, 0)
			curOffX = nil
		else
			self.transform.localPosition = Vector3.New((Screen.width + self.rect.width)/2, 300, 0)
		end
	else
		self:ShowNext()
	end
end

function ActivityBanner:ScrollShow()
	if #activityToShow > 0 then
		self:Show()
		if not self.loopShow then
			self.loopShow = Timer.New(basefunc.handler(self, self.Move), 0.02, -1, false)
		end
		self.loopShow:Start()
	else
		self:Close()
	end
end

function ActivityBanner:Move()
	self.transform.localPosition = self.transform.localPosition + Vector3.New(self.speed * 0.02, 0, 0)
	if self.transform.localPosition.x < -(Screen.width + self.rect.width)/2 then
		self:ShowNext()
	end
end

function ActivityBanner:ShowNext()
	table.insert(shownActivityIds, #shownActivityIds + 1, activityToShow[1])
	table.remove(activityToShow, 1)
	self:ScrollShow()
end

function ActivityBanner:GetBannerOffsetX()
	if IsEquals(self.transform) then
	return self.transform.localPosition.x
	end
	return curOffX
end

function ActivityBanner:Close()
	if self.loopShow then
		self.loopShow:Stop()
		self.loopShow = nil
	end

	self.data = nil
	if instance then
		destroy(self.gameObject)
		instance = nil
	end
end

function ActivityBanner.OnEnterScene()
	if MainLogic.GetCurSceneName() ~= "game_Login" and MainLogic.GetCurSceneName() ~= "game_Fishing" and MainLogic.GetCurSceneName() ~= "game_FishingHall" then
		if not ActivityBanner.refreshActivity then
			ActivityBanner.refreshActivity = Timer.New(function()
				ActivityBanner.RefreshData()
			end, 3, -1, false)
		end
		ActivityBanner.refreshActivity:Start()

		if curOffX then
			ActivityBanner.Create()
		end
	end
end

function ActivityBanner.OnExitScene()
	if ActivityBanner.refreshActivity then
		ActivityBanner.refreshActivity:Stop()
	end
	if instance then
		curOffX = instance:GetBannerOffsetX()
		instance:Close()
	else
		curOffX = nil
	end
end

function ActivityBanner.RefreshData()
	local a,b = GameButtonManager.RunFun({gotoui="sys_act_operator",}, "GetActivatedActivityList")
	if a and not table_is_null(b) then
		m_data = b
	end
	
	if m_data then
		for _, d in ipairs(m_data) do
			if d.activated == 1 then
				if not ActivityBanner.IsInTable(d.id, shownActivityIds) and not ActivityBanner.IsInTable(d.id, activityToShow) then
					activityToShow[#activityToShow + 1] = d.id
				end
			elseif ActivityBanner.IsInTable(d.id, shownActivityIds) then
				ActivityBanner.RemoveFromTable(d.id, shownActivityIds)
			end
		end

		--dump(shownActivityIds, "<color=yellow>shownActivityIds:</color>")
		--dump(activityToShow, "<color=yellow>activityToShow:</color>")
		
		if #activityToShow > 0 then
			ActivityBanner.Create()
		end
	end
	ActivityBanner.Create()
end

function ActivityBanner.GetActivityData(id)
	local data
	if m_data then
		for _, d in ipairs(m_data) do
			if d.id == id then
				data = d
			end
		end
	end
	return data
end

function ActivityBanner.IsInTable(v, t)
	local ret = false
	if t then
		for i = 1, #t do
			if t[i] == v then
				ret = true
				break
			end
		end
	end
	return ret
end

function ActivityBanner.RemoveFromTable(v, t)
	if t then
		for i = 1, #t do
			if t[i] == v then
				table.remove(t, i)
				break
			end
		end
	end
end

if GameGlobalOnOff.Activity and GameGlobalOnOff.ActivityBanner then
	ActivityBanner.Start()
end
