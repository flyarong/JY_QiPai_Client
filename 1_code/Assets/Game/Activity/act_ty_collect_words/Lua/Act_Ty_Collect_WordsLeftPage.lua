-- 创建时间:2021-01-04
-- Panel:Act_Ty_Collect_WordsLeftPage
--[[
 *      ┌─┐       ┌─┐
 *   ┌──┘ ┴───────┘ ┴──┐
 *   │                 │
 *   │       ───       │
 *   │  ─┬┘       └┬─  │
 *   │                 │
 *   │       ─┴─       │
 *   │                 │
 *   └───┐         ┌───┘
 *       │         │
 *       │         │
 *       │         │
 *       │         └──────────────┐
 *       │                        │
 *       │                        ├─┐
 *       │                        ┌─┘
 *       │                        │
 *       └─┐  ┐  ┌───────┬──┐  ┌──┘
 *         │ ─┤ ─┤       │ ─┤ ─┤
 *         └──┴──┘       └──┴──┘
 *                神兽保佑
 *               代码无BUG!
 --]]

local basefunc = require "Game/Common/basefunc"

Act_Ty_Collect_WordsLeftPage = basefunc.class()
local C = Act_Ty_Collect_WordsLeftPage
C.name = "Act_Ty_Collect_WordsLeftPage"
local M = Act_Ty_Collect_WordsManager

function C.Create(panelSelf,parent,index,config)
	return C.New(panelSelf,parent,index,config)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"]=basefunc.handler(self,self.MyExit)
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

function C:MyClose()
	self:MyExit()
end

function C:ctor(panelSelf,parent,index,config)
	self.panelSelf = panelSelf
	self.index = index
	self.config = config
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
	self.icon_img.sprite = GetTexture(self.config.gift_page[1])	
	self.btn_img.sprite = GetTexture(self.config.gift_page[2])	
	self.selet_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self.panelSelf:Selet(self.index)
	end)
	self:MyRefresh()
end

function C:MyRefresh()
end

function C:RefreshSelet(index)
	self.selet_img.gameObject:SetActive(index == self.index)
	self.selet_btn.gameObject:SetActive(index ~= self.index)
end
