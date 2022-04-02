-- 创建时间:2021-02-23
-- Panel:RXCQLoadPanel
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

RXCQLoadPanel = basefunc.class()
local C = RXCQLoadPanel
C.name = "RXCQLoadPanel"
local max_len = 989.3
function C.Create(backcall)
	return C.New(backcall)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.backcall then
		self.backcall()
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

function C:ctor(backcall)
	ExtPanel.ExtMsg(self)
	local parent = GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.backcall = backcall
	self:MakeLister()
	self:AddMsgListener()
	self.BG = self.transform:Find("BG"):GetComponent("Image")
	self:InitUI()
	ExtendSoundManager.PauseSceneBGM()
	ExtendSoundManager.PlaySound(audio_config.rxcq.rxcq_loading.audio_name)
end 

function C:InitUI()
	self.Timer = nil
	self.Timer = Timer.New(function()
		local p = RXCQPrefabManager.PreLoad()
		if p then
			self.info_txt.text = "加载中..."
			local index = math.floor(p * 10) + 1
			if index >= 10 then	
				index = 10
			end
			self.main_img.sprite = GetTexture("cqdl_bg_m"..index)
			self.pl.transform.sizeDelta = {y = 26.36,x = p * max_len}
		else
			self.BG.sprite = nil
			self.main_img.sprite = nil
			self.Timer:Stop()
			self:MyExit()
			Util.ClearMemory()
			Event.Brocast("loding_finish")
		end
	end,0.04,-1)
	self.Timer:Start()
end
