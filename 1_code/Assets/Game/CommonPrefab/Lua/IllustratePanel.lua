local basefunc = require "Game.Common.basefunc"

IllustratePanel = basefunc.class()
IllustratePanel.name = "IllustratePanel"

local instance = nil

local lister = {}

local function AddLister()
	for msg,cbk in pairs(lister) do
		Event.AddListener(msg, cbk)
	end
end

local function RemoveLister()
	if lister then
		for msg,cbk in pairs(lister) do
			Event.RemoveListener(msg, cbk)
		end
	end
	lister={}
end

local function MakeLister()
	lister = {}

	lister["ExitScene"] = IllustratePanel.OnExitScene
	lister["OnLoginResponse"] = IllustratePanel.OnExitScene
	lister["will_kick_reason"] = IllustratePanel.OnExitScene
	lister["DisconnectServerConnect"] = IllustratePanel.OnExitScene
end

function IllustratePanel.Create(tmpl_list, parent, prefab_name, callback)
	if not instance then
		instance = IllustratePanel.New(tmpl_list, parent, prefab_name, callback)
	end
	return instance
end

function IllustratePanel:ctor(tmpl_list, parent, prefab_name, callback)

	ExtPanel.ExtMsg(self)

	self.tmpl_list = tmpl_list
	self.callback = callback
	if not parent then
		parent = GameObject.Find("Canvas/LayerLv5").transform
	end
	IllustratePanel.name = prefab_name or IllustratePanel.name
	local obj = newObject(IllustratePanel.name, parent)
	self.transform = obj.transform
	self.gameObject = obj

	LuaHelper.GeneratingVar(self.transform, self)

	MakeLister()
	AddLister()

	self:InitRect()
end

function IllustratePanel:MyExit()
	RemoveLister()
	self:ClearAll()
	destroy(self.gameObject)
end
function IllustratePanel.Close()
	if instance then
		instance:MyExit()
		instance = nil
	end
end

function IllustratePanel.IsShow()
	if not instance then return false end
	return instance.transform.gameObject.activeSelf
end

function IllustratePanel:InitRect()
	local transform = self.transform

	self.close_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		if self.callback then
			self.callback()
			self.callback = nil
		end
		IllustratePanel.Close()
	end)

	self.content = transform:Find("CenterRect/Scroll View/Viewport/Content")

	self.listElement = {}

	self:Refresh()
end

function IllustratePanel:Refresh()
	if not IsEquals(self.content) then
		return
	end

	for _, v in ipairs(self.tmpl_list or {}) do
		local elem = GameObject.Instantiate(v, self.content)
		elem.transform.localPosition = Vector3.zero
		elem.transform.localScale = Vector3.one
		table.insert(self.listElement, elem)
		elem.gameObject:SetActive(true)
	end
end

function IllustratePanel:ClearAll()
	if IsEquals(self.transform) then
		self.transform:SetParent(nil)
	end
	self:ClearList()
	self.tmpl_list = nil
end

function IllustratePanel:OnExitScene()
	IllustratePanel.Close()
end

function IllustratePanel:ClearList()
	for i,v in pairs(self.listElement) do
		if IsEquals(v) then
			GameObject.Destroy(v.gameObject)
		end
	end
	self.listElement = {}
end
