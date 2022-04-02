-- 创建时间:2019-01-07

local basefunc = require "Game.Common.basefunc"

OperatorActivityPanel = basefunc.class()

local C = OperatorActivityPanel

C.name = "OperatorActivityPanel"
local instance
function C.Create(parent, game_id)
	print("<color=red>OperatorActivityPanel Create </color>")
	instance = C.New(parent, game_id)
	return instance
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

function C:MyClose()
	self:MyExit()
end

function C:MyExit()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor(parent, game_id)

	ExtPanel.ExtMsg(self)

	self.game_id = game_id
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj

	self:MakeLister()
	self:AddMsgListener()
	self.data = OperatorActivityModel.GetActivityUnderway(self.game_id)
	LuaHelper.GeneratingVar(self.transform, self)

	EventTriggerListener.Get(self.Icon_img.gameObject).onClick = basefunc.handler(self, self.OnClick)
end

function C:UpdateUI()
	if self.data and self.data.activity_id == 1 then
		local cfg = OperatorActivityModel.GetActivityConfig(self.data.activity_id)
		self.Cell.gameObject:SetActive(true)
		self.Icon_img.sprite = GetTexture("operator_icon_" .. cfg.activity_icon)
		self.RedHint.gameObject:SetActive(true)
	else
		self.Cell.gameObject:SetActive(false)
	end
end

function C:OnClick()
	if self.data.activity_id == 1 then
		Event.Brocast("open_operator_activity", "djhb")
	elseif self.data.activity_id == 2 then
		Event.Brocast("open_operator_activity", "ls")
	else
		dump(self.data, "<color=red>未知的运营活动</color>")
	end
end

function C:Show()
	self:UpdateUI()
end

function C:Hide()
	self.Cell.gameObject:SetActive(false)
end

