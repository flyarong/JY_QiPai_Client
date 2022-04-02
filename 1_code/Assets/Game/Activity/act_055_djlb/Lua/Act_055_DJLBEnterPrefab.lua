-- 创建时间:2021-04-15
-- Panel:Act_055_DJLBEnterPrefab
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

Act_055_DJLBEnterPrefab = basefunc.class()
local C = Act_055_DJLBEnterPrefab
local M = Act_055_DJLBManager
C.name = "Act_055_DJLBEnterPrefab"

function C.Create(parent)
	return C.New(parent)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
	self.lister["act_055_djlb_task_change"] = basefunc.handler(self,self.MyRefresh)
	self.lister["act_055_djlb_base_info_change"] = basefunc.handler(self,self.MyRefresh)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.huxi then
		self.huxi:Stop()
		self.huxi = nil
	end
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(parent)
	ExtPanel.ExtMsg(self)
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

	self.huxi = CommonHuxiAnim.Go(self.gameObject)
	self.huxi:Start()
	self.enter_btn.onClick:AddListener(function()
		local type = M.ShowType()
		if type == 1 or M.IsAllGet() or (type == 2 and M.GetOverTime() ~= 0 and os.time() > M.GetOverTime()) then
			Act_055_DJLBBuyPanel.Create()
		elseif type == 2 then
			Act_055_DJLBTaskPanel.Create()
		end
		type = nil
	end)
	self:MyRefresh()
end

function C:MyRefresh()
	if M.IsHint() then
		self.LFL.gameObject:SetActive(true)
	else
		self.LFL.gameObject:SetActive(false)
	end
end
