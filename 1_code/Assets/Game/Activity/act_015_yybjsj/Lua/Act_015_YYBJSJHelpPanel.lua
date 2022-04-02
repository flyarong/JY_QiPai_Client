local basefunc = require "Game/Common/basefunc"

Act_015_YYBJSJHelpPanel = basefunc.class()
local C = Act_015_YYBJSJHelpPanel
C.name = "Act_015_YYBJSJHelpPanel"

function C.Create(parent,parm)
	return C.New(parent,parm)
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

function C:MyExit()
	DSM.PopAct()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:ctor(parent,parm)
	ExtPanel.ExtMsg(self)
	DSM.PushAct({panel = C.name})
	self.parm = parm
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	
end

function C:InitUI()
	self.close_btn.onClick:AddListener(
		function ()
			self:MyExit()
		end
	)
	self:MyRefresh()
end

function C:MyRefresh()
	self.desc1_txt.text = self.parm.cfg.game_zpg
	self.desc2_txt.text = self.parm.cfg.game_by
	self.desc3_txt.text = self.parm.cfg.game_xxl_sg
end