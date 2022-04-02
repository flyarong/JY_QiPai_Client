-- 创建时间:2022-03-09
-- Panel:ACT_074_TCXBPreviewPanel
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
 -- 取消按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
 -- 确认按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
 --]]

local basefunc = require "Game/Common/basefunc"

ACT_074_TCXBPreviewPanel = basefunc.class()
local C = ACT_074_TCXBPreviewPanel
C.name = "ACT_074_TCXBPreviewPanel"
local M = ACT_074_TCXBManager
function C.Create()
	return C.New()
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"] = basefunc.handler(self,self.MyExit)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
    self:ClearItem()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor()
	ExtPanel.ExtMsg(self)
	local parent = GameObject.Find("Canvas/LayerLv4").transform
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
    self.back_btn.onClick:AddListener(
        function()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
            self:OnBackClick()
        end
    )
    self.sv = self.ScrollView:GetComponent("ScrollRect")
    EventTriggerListener.Get(self.sv.gameObject).onBeginDrag = function()
        Event.Brocast("ACT_074_TCXBPreviewItemBase_tip_msg")
    end
	self:MyRefresh()
end

function C:MyRefresh()
    self:CreateItem()
end

function C:OnBackClick()
    self:MyExit()
end

function C:CreateItem()
   self:ClearItem()
   local config = M.GetConfig().pool
   for i=1,#config do
       local pre = ACT_074_TCXBPreviewItemBase.Create(self.Content.transform,config[i])
       self.pre_cell[#self.pre_cell + 1] = pre
   end
end

function C:ClearItem()
    if self.pre_cell then
        for k,v in pairs(self.pre_cell) do
            v:MyExit()
        end
    end
    self.pre_cell = {}
end