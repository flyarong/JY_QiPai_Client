-- 创建时间:2022-03-03
-- Panel:ACT_073_JDCARDWaitWebPanel
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

ACT_073_JDCARDWaitWebPanel = basefunc.class()
local C = ACT_073_JDCARDWaitWebPanel
C.name = "ACT_073_JDCARDWaitWebPanel"
local M = ACT_073_JDCARDManager
function C.Create(unlock_id)
	return C.New(unlock_id)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"] = basefunc.handler(self,self.MyExit)
    self.lister["jd_card_award"] = basefunc.handler(self,self.on_jd_card_award)
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

function C:ctor(unlock_id)
	ExtPanel.ExtMsg(self)
    self.unlock_id = unlock_id
	local parent = GameObject.Find("Canvas/LayerLv5").transform
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
	self:MyRefresh()
end

function C:MyRefresh()
end

function C:on_jd_card_award(_,data)
    dump(data,"<color=yellow><size=15>++++++++++on_jd_card_award++++++++++</size></color>")
    if self.unlock_id == data.unlock_id then
        if data.result == 0 then  
            ACT_073_JDCARDXQPanel.Create(data)
        else
            M.MarkTime(data.unlock_id)
            LittleTips.Create("京东卡暂时没货了")
        end
        self:MyExit()
    end
end