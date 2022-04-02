local basefunc = require "Game.Common.basefunc"

ShowGGPanel = basefunc.class()
ShowGGPanel.name = "ShowGGPanel"

local instance = nil

local lister = {}
function ShowGGPanel:MakeLister()
	lister = {}

	--lister["view_sge_close"] = basefunc.handler(self, self.handle_sge_close)
end
function ShowGGPanel:AddLister()
	for proto_name,func in pairs(lister) do
		Event.AddListener(proto_name, func)
	end
end

function ShowGGPanel:RemoveLister()
	if lister and next(lister) then
		for msg,cbk in pairs(lister) do
			Event.RemoveListener(msg, cbk)
		end	
	end
	lister=nil
end

function ShowGGPanel.Create(param)
	if not instance then
		instance = ShowGGPanel.New(param)
	end
	return instance
end

function ShowGGPanel:ctor(param)

	ExtPanel.ExtMsg(self)

	local parent = GameObject.Find("Canvas/LayerLv50").transform
	local obj = newObject(ShowGGPanel.name, parent)
	self.transform = obj.transform
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)

	self:MakeLister()
	self:AddLister()
	self:InitRect(param)
end

function ShowGGPanel:MyExit()
	self:RemoveLister()
	self:ClearAll()
	destroy(self.gameObject)
end

function ShowGGPanel.Close()
	if instance then
		instance:MyExit()
		instance = nil
	end
end

function ShowGGPanel:InitRect(param)
	local callback = param.callback

	local transform = self.transform
	
	--[[local imgFile = param.imgFile
	if imgFile then
		local img = transform:Find("ImgBackBG/ImgFrontBG/Image"):GetComponent("Image")
		img.sprite = GetTexture(imgFile)
	end]]--

	local cdCount = 8

	local timerTxt = transform:Find("wait_time/wait_time_txt"):GetComponent("Text")
	timerTxt.text = cdCount
	
	self.cdTimer = Timer.New(function()
		cdCount = cdCount - 1

		if IsEquals(timerTxt) then
			timerTxt.text = cdCount
		end

		if cdCount <= 0 then
			if self.cdTimer then
				self.cdTimer:Stop()
				self.cdTimer = nil
			end
			if callback then callback(param.panelSelf) end
			ShowGGPanel.Close()
		end
	end, 1, -1, false, false)
	self.cdTimer:Start()
end

function ShowGGPanel:ClearAll()
	if self.cdTimer then
		self.cdTimer:Stop()
		self.cdTimer = nil
	end
end
