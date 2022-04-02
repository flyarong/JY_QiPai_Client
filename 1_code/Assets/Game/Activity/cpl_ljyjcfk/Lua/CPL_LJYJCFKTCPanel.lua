-- 创建时间:2020-07-21

local basefunc = require "Game/Common/basefunc"

CPL_LJYJCFKTCPanel = basefunc.class()
local C = CPL_LJYJCFKTCPanel
C.name = "CPL_LJYJCFKTCPanel"
local M = CPL_LJYJCFKManager

function C.Create(parm)
	return C.New(parm)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"] = basefunc.handler(self, self.ExitScene)
    self.lister["cpl_ljyjcfk_refresh"] = basefunc.handler(self,self.cpl_ljyjcfk_refresh)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end
function C:ExitScene()
	self:MyExit()
end

function C:ctor(parm)
	ExtPanel.ExtMsg(self)
	local parent = GameObject.Find("Canvas/LayerLv3").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.parm = parm
	LuaHelper.GeneratingVar(self.transform, self)

	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	HandleLoadChannelLua(C.name,self)
end

function C:InitUI()
	self.GoGame_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
     	self:MyExit()
    end)
	self.BackButton_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		if self.parm and self.parm.callback and type(self.parm.callback) == "function" then
			self.parm.callback()
		end
		self:MyExit()
    end)

	self:MyRefresh()
end

function C:MyRefresh()
	self.task_data = CPL_LJYJCFKManager.GetData()
	if not self.task_data then return end
	self.hb_txt.text = M.config.base[self.task_data.now_lv].show_hb
	self:RefreshNeedText()
end

function C:cpl_ljyjcfk_refresh(data)
	self:MyRefresh()
end

function C:RefreshNeedText()
	self.need_txt.text = StringHelper.ToCash(self.task_data.need_process - self.task_data.now_process)
end