-- 创建时间:2021-06-30
-- Panel:Act_061_CZJCCardQP
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

Act_061_CZJCCardQP = basefunc.class()
local C = Act_061_CZJCCardQP
C.name = "Act_061_CZJCCardQP"
local M = Act_061_CZJCCardManager

local instance
function C.Create(parent)
	if not instance then
		instance = C.New(parent)
	else
		instance:RefreshMyView()
	end
	return instance
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
	self.lister["czjccard_used_success"] = basefunc.handler(self, self.on_czjccard_used_success)
	self.lister["model_czjccard_data_change"] = basefunc.handler(self, self.on_model_czjccard_data_change)
	self.lister["ExitScene"] = basefunc.handler(self, self.OnExitScene)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.mTimer then
		self.mTimer:Stop()
		self.mTimer = nil
	end
	dump("<color=red> 【充值加成卡:销毁大厅气泡】 </color>")
	instance = nil
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
	self:MyRefresh()
end

function C:on_czjccard_used_success()
	self:RefreshMyView()
end

function C:on_model_czjccard_data_change()
	self:RefreshMyView()
end

function C:MyRefresh()
	self.time_txt.gameObject:SetActive(M.IsUsingCard())
	if M.IsUsingCard() then
		self.cfg = M.GetUsingCardCfg()
		local usingData = M.GetUsingCard()
		local tempTime = usingData.valid_time - os.time()
		self.time_txt.text = StringHelper.formatTimeDHMS5(tempTime)
		if self.mTimer then
			self.mTimer:Stop()
			self.mTimer = nil
		end
		self.mTimer = Timer.New(function()
			tempTime = tempTime - 1 
			self.time_txt.text = StringHelper.formatTimeDHMS5(tempTime)
			if tempTime <= 0 then
				if self.gameObject then
					self:RefreshMyView()
				end
			end
		end,1,-1)
		self.mTimer:Start()
	else
		self.cfg = M.GetCurCardCfg()
	end
	self.name_txt.text = "充值加成" .. self.cfg.add_rate .. "%"
end

function C:RefreshMyView()
	if M.IsUsingCard() or M.IsHaveCard() then
		self:MyRefresh()
	else
		self:MyExit()
	end
end

function C:OnExitScene()
	self:MyExit()
end