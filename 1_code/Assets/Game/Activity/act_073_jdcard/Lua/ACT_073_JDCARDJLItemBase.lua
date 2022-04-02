-- 创建时间:2022-03-02
-- Panel:ACT_073_JDCARDJLItemBase
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

ACT_073_JDCARDJLItemBase = basefunc.class()
local C = ACT_073_JDCARDJLItemBase
C.name = "ACT_073_JDCARDJLItemBase"
local M = ACT_073_JDCARDManager
function C.Create(parent,data,config,index)
	return C.New(parent,data,config,index)
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
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(parent,data,config,index)
	ExtPanel.ExtMsg(self)
    self.data = data
    self.config = config
    self.index = index
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
    self.ckxq_btn.onClick:AddListener(
        function()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
            self:OnCKXQClick()
        end
    )
	self:MyRefresh()
end

function C:MyRefresh()
    self.desc_txt.text = self.config.award_txt
    self.time_txt.text = self.data.complete_time--self:GetData(tonumber(self.data.complete_time))
end

function C:OnCKXQClick()
    ACT_073_JDCARDXQPanel.Create(self.data.task_index,self.index)
end

function C:GetData(unixTime) 
    local tb = {}
    tb.year = tonumber(os.date("%Y",unixTime))
    tb.month = tonumber(os.date("%m",unixTime))
    tb.day = tonumber(os.date("%d",unixTime))
    tb.hour = tonumber(os.date("%H",unixTime))
    tb.minute = tonumber(os.date("%M",unixTime))
    tb.second = tonumber(os.date("%S",unixTime))
    return tb.year .. "-" .. tb.month .. "-" .. tb.day .. " " .. tb.hour .. ":" .. tb.minute .. ":" .. tb.second
end