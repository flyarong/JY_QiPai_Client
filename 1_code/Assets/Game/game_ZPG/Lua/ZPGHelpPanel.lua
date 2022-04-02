-- 创建时间:2020-4-10
local basefunc = require "Game.Common.basefunc"

ZPGHelpPanel = basefunc.class()
local C = ZPGHelpPanel
C.name = "ZPGHelpPanel"
local M = ZPGModel

function C.Create()
	return C.New()
end

function C:ctor()

	ExtPanel.ExtMsg(self)

    local parent = GameObject.Find("Canvas/LayerLv3").transform
    local obj = newObject(C.name,parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
    LuaHelper.GeneratingVar(self.transform, self)
    
    self.back_btn.onClick:AddListener(function () self:MyExit() end)
end

function C:MyExit()
    destroy(self.gameObject)
end