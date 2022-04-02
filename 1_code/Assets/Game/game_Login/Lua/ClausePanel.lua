local basefunc = require "Game.Common.basefunc"

ClausePanel = basefunc.class()
ClausePanel.name = "ClausePanel"

local instance

function ClausePanel.Create(ident, title, text)
	instance = ClausePanel.New(ident, title, text)
	return instance
end

function ClausePanel:MyExit()
	destroy(self.gameObject)
end

function ClausePanel.Close()
	if instance then
		instance:MyExit()
		instance = nil
	end
end

function ClausePanel:ctor(ident, title, text)

	ExtPanel.ExtMsg(self)

	local parent = GameObject.Find("Canvas/LayerLv5")
	local obj = newObject(ClausePanel.name, parent.transform)
	self.transform = obj.transform
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self:InitRect(ident, title, text)
end

function ClausePanel:InitRect(ident, title, text)
	local transform = self.transform

	local okBtn = transform:Find("OK_btn"):GetComponent("Button")
	okBtn.onClick:AddListener(function()
		ClausePanel.Close()
		Event.Brocast("clause_ok", ident)
	end)

	local uiTitle = transform:Find("ScrollView/Viewport/Content/Title_txt"):GetComponent("Text")
	uiTitle.text = title
	local uiText = transform:Find("ScrollView/Viewport/Content/Text_txt"):GetComponent("Text")
	uiText.text = text
end

--启动事件--
function ClausePanel:Awake()
end

function ClausePanel:Start()	
end

function ClausePanel:OnDestroy()
end
