-- 创建时间:2019-01-08

FreeOperatorPrefab = {}

local basefunc = require "Game.Common.basefunc"

FreeOperatorPrefab = basefunc.class()

local C = FreeOperatorPrefab

C.name = "FreeOperatorPrefab"
function C.Create(parent_transform, config, call, panelSelf, index, gameId)
	return C.New(parent_transform, config, call, panelSelf, index, gameId)
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

function C:ctor(parent_transform, config, call, panelSelf, index, gameId)
	self.config = config
	self.call = call
	self.panelSelf = panelSelf
	self.index = index
	self.gameId = gameId
	local obj = newObject(C.name, parent_transform)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj

	self:MakeLister()
	self:AddMsgListener()
	LuaHelper.GeneratingVar(self.transform, self)
	self.BGImage_btn = self.icon_img.gameObject:GetComponent("Button")
	self.BGImage_btn.onClick:AddListener(function ()
		self:OnClick()
	end)

	self:UpdateUI()
	self:StartUpdateState()
end

function C:StartUpdateState()
	self.switch = false
	self.UpdateState = Timer.New(function()
		local state = "no"
		local a,b = GameButtonManager.RunFun({gotoui="sys_act_operator",game_id = self.gameId,activity_type = self.config.activity_id}, "CheckIsActivated")
        local is_true = a and b
		if is_true then
			state = "yes"
		end
		
		if state ~= self.config.state and IsEquals(self.gameObject) then
			self.config.state = state
			if state == "no" then
				self.icon_img.material = GetMaterial("imageGrey")
				self.name_img.material = GetMaterial("imageGrey")
			else
				self.icon_img.material = nil
				self.name_img.material = nil
			end
			
			if self.panelSelf and self.panelSelf.select_operator_index then
				self.panelSelf:OnOperatorClick(self.panelSelf.select_operator_index)
			end
		end
	end, 3, -1, false)
	self.UpdateState:Start()
end

function C:UpdateUI()
	self.icon_img.sprite = GetTexture("pzjcp_btn_" .. self.config.activity_config.activity_icon)
	self.name_img.sprite = GetTexture("pp_imgf_" .. self.config.activity_config.activity_icon)
	self.name_img:SetNativeSize()

	if self.config.state ~= "yes" then
		self.icon_img.material = GetMaterial("imageGrey")
		self.name_img.material = GetMaterial("imageGrey")
	end
end

function C:GetIconTransform()
	return self.icon_img.transform
end

-- 点击
function C:OnClick()
	if self.call then
		self.call(self.panelSelf, self.index)
	end
end

function C:MyExit()
	self:RemoveListener()
	if self.UpdateState then
		self.UpdateState:Stop()
		self.UpdateState = nil
	end
end

function C:OnDestroy()
	self:MyExit()
	GameObject.Destroy(self.gameObject)
end



