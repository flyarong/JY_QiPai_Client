-- 创建时间:2018-12-12

local basefunc = require "Game.Common.basefunc"

SevenDayTopPrefab = basefunc.class()

local C = SevenDayTopPrefab

C.name = "SevenDayTopPrefab"

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

function C:ctor(parent_transform, config, call, panelSelf)
	-- dump(config, "<color=white>SevenDayTopPrefab config:</color>")
	self.config = config
	self.call = call
	self.panelSelf = panelSelf
	local obj = newObject(C.name, parent_transform)
	self.gameObject = obj
	self.transform = obj.transform
	self:MakeLister()
    self:AddMsgListener()

    LuaHelper.GeneratingVar(obj.transform, self)

	self.day_btn.onClick:AddListener(function()
        self:OnClick()
    end)

    self:InitUI()
end

function C:InitUI()
	self.money_txt.text = string.format( "%d",self.config.money)
	self.day_txt.text = string.format( "第%d天",self.config.day)
	self.ani_component = self.root.transform:GetComponent("Animator")
	self:SetSelect(false)
	ClipUIParticle(self.transform)
end

function C:UpdateUI()
	local is_over = false
	for i,v in ipairs(self.config.task_list) do
		for j,id in ipairs(v) do
			local task = ActivitySevenDayModel.GetTaskToID(id)
			if task then
				if task.award_status == 2 then
					is_over = true
					break
				else
					is_over = false
				end
			elseif self.config.day and
					ActivitySevenDayModel.data.now_big_step and 
					type(self.config.day) == "number" and
					type(ActivitySevenDayModel.data.now_big_step) == "number" and
					self.config.day <= ActivitySevenDayModel.data.now_big_step then
				is_over = true
			end
		end
	end
	self:SetIsOver(is_over)
end

function C:OnClick()
	if self.call then
		self.call(self.panelSelf, self.config.day)
	end
end

function C:SetSelect(b)
	if b == true then
		self.root.transform.localPosition = Vector3.New(0,-17,0)
		self.icon_img.transform.localScale = Vector3.New(1,1,1)
		self.Particle.gameObject:SetActive(true)
		self.ani_component.enabled = true
	elseif b == false then
		self.root.transform.localPosition = Vector3.New(0,-2,0)
		self.icon_img.transform.localScale = Vector3.New(0.9,0.9,1)
		self.Particle.gameObject:SetActive(false)
		self.ani_component.enabled = false
	end
end

function C:SetIsOver(b)
	if IsEquals(self.gameObject) then
		if b == true then
			self.gettag.gameObject:SetActive(true)
			self.day.gameObject:SetActive(false)
			self.icon_img.color = Color.gray
			self.money_txt.color = Color.gray
		elseif b == false then
			self.gettag.gameObject:SetActive(false)
			self.day.gameObject:SetActive(true)
			self.icon_img.color = Color.white
			self.money_txt.color = Color.white
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
