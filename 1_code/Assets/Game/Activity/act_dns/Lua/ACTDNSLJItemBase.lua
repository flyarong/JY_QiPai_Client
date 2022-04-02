-- 创建时间:2022-01-06
-- Panel:ACTDNSLJItemBase
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

ACTDNSLJItemBase = basefunc.class()
local C = ACTDNSLJItemBase
C.name = "ACTDNSLJItemBase"
local M = ACTDNSManager

function C.Create(parent,config)
	return C.New(parent,config)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"]=basefunc.handler(self,self.MyExit)
    self.lister["model_task_change_msg"] = basefunc.handler(self,self.on_model_task_change_msg)
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

function C:ctor(parent,config)
	ExtPanel.ExtMsg(self)
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
    self.get_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        if M.OutTime() then
            LittleTips.Create("活动已结束...")
            return
        end
        self:OnGetClick()
    end)
	self:MyRefresh()
end

function C:MyRefresh()
    self.award_img.sprite = GetTexture(self.config.award_img)
    self.award_txt.text = self.config.award
    self.need_txt.text = self.config.need_num .. "只"
    local data = GameTaskModel.GetTaskDataByID(self.config.task)
    if data then
        local b = basefunc.decode_task_award_status(data.award_get_status)
        b = basefunc.decode_all_task_award_status(b, data, 6)
        self.get_btn.gameObject:SetActive(b[self.config.level] == 1)
        self.ylq.gameObject:SetActive(b[self.config.level] == 2)
        self.gx.gameObject:SetActive(b[self.config.level] == 1)
    end
end

function C:OnGetClick()
    local data = GameTaskModel.GetTaskDataByID(self.config.task)
    if data then
        local b = basefunc.decode_task_award_status(data.award_get_status)
        b = basefunc.decode_all_task_award_status(b, data, 6)
        if b[self.config.level] == 1 then
            Network.SendRequest("get_task_award_new",{id = self.config.task, award_progress_lv = self.config.level})
        end
    end
end

function C:on_model_task_change_msg(data)
    if data.id == self.config.task then
        self:MyRefresh()
    end
end