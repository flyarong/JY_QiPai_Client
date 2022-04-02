local basefunc = require "Game/Common/basefunc"

QHBHelpPanel = basefunc.class()
local M = QHBHelpPanel
M.name = "QHBHelpPanel"
package.loaded["Game.normal_qhb_common.Lua.qhb_help_config"] = nil
local config = require "Game.normal_qhb_common.Lua.qhb_help_config"
config = config.help
local instance
function M.Create()
    if instance then
        instance:MyExit()
    end
    instance = M.New()
	return instance
end
function M.Close()
	if instance then
		instance:MyExit()
	end
	instance = nil
end

function M:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function M:MakeLister()
    self.lister = {}
    self.lister["ExitScene"] = basefunc.handler(self, self.MyExit)
end

function M:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function M:MyExit()
    self:RemoveListener()
    GameObject.Destroy(self.gameObject)
    IllustratePanel.Close()
end

function M:ctor()
	local parent = GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(M.name, parent)
	local tran = obj.transform
	self.transform = tran
    self.gameObject = obj
    LuaHelper.GeneratingVar(self.transform, self)
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function M:InitUI()
    self:OpenHelpPanel()
end

function M:OpenHelpPanel()
    local str = config[1].info
    for i = 2, #config do
        str = str .. "\n" .. config[i].info
    end
    self.introduce_txt.text = str
    local rt = self.introduce_txt.transform:GetComponent("RectTransform")
    rt.sizeDelta = {x = 1200,y = 1110}
    self.introduce_sp_txt.text = str
    rt = self.introduce_sp_txt.transform:GetComponent("RectTransform")
    rt.sizeDelta = {x = 915,y = 1380}
    local prefab_name = "IllustratePanel"
    local prefab_obj = self.introduce_txt.gameObject
    if MainLogic.GetCurSceneName() == "game_QHB" then
        prefab_name = "IllustratePanelSP"
        prefab_obj = self.introduce_sp_txt.gameObject
    end
    IllustratePanel.Create({ prefab_obj }, GameObject.Find("Canvas/LayerLv5").transform,prefab_name)
    local fun_old_quit = IllustratePanel.Close
    IllustratePanel.Close = function ()
        IllustratePanel.Close = fun_old_quit
        fun_old_quit(instance)
        self:MyExit()
    end 
end
