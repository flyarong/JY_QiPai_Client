-- 创建时间:2018-12-12

local basefunc = require "Game.Common.basefunc"

SevenDayNewTopPrefab = basefunc.class()

local C = SevenDayNewTopPrefab

C.name = "SevenDayNewTopPrefab"

function C.Create(parent_transform, idx, call, panelSelf)
	return C.New(parent_transform, idx, call, panelSelf)
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

function C:ctor(parent_transform, idx, call, panelSelf)
	self.idx = idx
	self.call = call
	self.panelSelf = panelSelf
	local obj = newObject(C.name, parent_transform)
	self.gameObject = obj
	self.transform = obj.transform
	self:MakeLister()
	self:AddMsgListener()

	LuaHelper.GeneratingVar(obj.transform, self)

	self.day_num_txt.text = "第" .. idx .. "天"
	self.day_btn.onClick:AddListener(function()
		self:OnClick()
	end)

	self.get_btn.onClick:AddListener(function()
		Network.SendRequest("get_task_award_new", {id = ActivitySevenDayNewPanel.GetTaskID(), award_progress_lv=ActivitySevenDayNewPanel.DayToTaskIdx(idx)})
		Network.SendRequest("query_one_task_data", {task_id = ActivitySevenDayNewPanel.GetTaskID()})
	end)

	self:InitUI()
end

function C:InitUI()
	local money = ActivitySevenDayNewPanel.GetTaskMoney(self.idx)
	if money <= 0 then
		self.ui.gameObject:SetActive(false)
	end
	
	local v = money - math.floor(money)
	if v > 0 then
		self.money_txt.text = string.format("%3.1f", money)
	else
		self.money_txt.text = string.format("%d", money)
	end

	self.ani_component = self.root.transform:GetComponent("Animator")
	self.ani_component.enabled = false
	self.Particle.gameObject:SetActive(false)

	--ClipUIParticle(self.transform)
end

function C:UpdateUI(state)
	if not IsEquals(self.gameObject) then return end

	local money = ActivitySevenDayNewPanel.GetTaskMoney(self.idx)
	if money <= 0 then return end

	if state < 0 then	--已经领取
		self.gettag.gameObject:SetActive(true)
		self.get_btn.gameObject:SetActive(false)
		self.icon_img.color = Color.gray
		self.money_txt.color = Color.gray
		self.Particle.gameObject:SetActive(false)
		self.ani_component.enabled = false
	elseif state > 0 then
		self.gettag.gameObject:SetActive(false)
		self.get_btn.gameObject:SetActive(true)
		self.icon_img.color = Color.white
		self.money_txt.color = Color.New(1, 228 / 255, 29 / 255, 1)
		self.Particle.gameObject:SetActive(true)
		self.ani_component.enabled = true
	else
		self.gettag.gameObject:SetActive(false)
		self.get_btn.gameObject:SetActive(false)
		self.icon_img.color = Color.white
		self.money_txt.color = Color.New(1, 228 / 255, 29 / 255, 1)
		self.Particle.gameObject:SetActive(false)
		self.ani_component.enabled = false
	end
end

function C:OnClick()
	if self.call then
		if self.call(self.panelSelf, self.idx) then
			self.day_img.gameObject:SetActive(true)
		end
	end
end

function C:MyExit()
    self:RemoveListener()
end

function C:OnDestroy()
	self:MyExit()
	GameObject.Destroy(self.gameObject)
end

function C:ResetDayImg()
	if not IsEquals(self.day_img) then return end
	self.day_img.gameObject:SetActive(false)
end
