-- 创建时间:2021-11-09
-- Panel:Act_069_XYHLBindIdPanel
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

Act_069_XYHLBindIdPanel = basefunc.class()
local C = Act_069_XYHLBindIdPanel
C.name = "Act_069_XYHLBindIdPanel"
local M = Act_069_XYHLManager

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
    self.lister["model_xyhl_bind_success_msg"] = basefunc.handler(self,self.on_model_xyhl_bind_success_msg)
    self.lister["model_xyhl_bind_fail_msg"] = basefunc.handler(self,self.on_model_xyhl_bind_fail_msg)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.djsTimer then
		self.djsTimer:Stop()
		self.djsTimer = nil
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

function C:ctor()
	ExtPanel.ExtMsg(self)
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

local function IsNeedShowDjs()
	local failTime = M.GetSetIdFailTime()
	if not failTime then
		return false
	end 

	if os.time() - failTime < 60 then
		return true
	end
	return false
end

local function GetDjsTime()
	if IsNeedShowDjs() then
		local failTime = M.GetSetIdFailTime()
		return (failTime + 60) - os.time()
	end
end

function C:InitUI()

	self.input = self.transform:Find("InputFieldBind"):GetComponent("InputField")
	self.back_btn.onClick:AddListener(function()
		self:MyExit()
	end)

	self.bind_btn.onClick:AddListener(function()
		if IsNeedShowDjs() then
			LittleTips.Create("请稍后再试")
			return
		end
		M.QueryBind(self.input.text)
	end)
	self:MyRefresh()
end

function C:MyRefresh()
	self:RefreshMyDjs()
end

function C:on_model_xyhl_bind_success_msg()
	self:MyExit()
end

function C:on_model_xyhl_bind_fail_msg()
	self:RefreshMyDjs()
end

--倒计时
function C:RefreshMyDjs()
	if IsNeedShowDjs() then
		self.djs_txt.gameObject:SetActive(true)
		self.djs_txt.text = "(" .. GetDjsTime() .. "s)"
		self.djsTimer = Timer.New(function()
			if IsNeedShowDjs() then
				self.djs_txt.text = "(" .. GetDjsTime() .. "s)"
			else
				self.djs_txt.gameObject:SetActive(false)
				self.djsTimer:Stop()
			end
		end,1,-1)
		self.djsTimer:Start()
	end
end