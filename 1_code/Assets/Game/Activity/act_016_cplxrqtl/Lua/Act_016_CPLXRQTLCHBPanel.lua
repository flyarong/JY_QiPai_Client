-- 创建时间:2020-06-04
-- Panel:Act_016_CPLXRQTLCHBPanel
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

Act_016_CPLXRQTLCHBPanel = basefunc.class()
local C = Act_016_CPLXRQTLCHBPanel
C.name = "Act_016_CPLXRQTLCHBPanel"
local M = Act_016_CPLXRQTLManager
function C.Create(parent,backcall)
	return C.New(parent,backcall)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
	self.lister = {}
	self.lister["cplxrqtl_task_change"] = basefunc.handler(self,self.cplxrqtl_task_change)
	self.lister["get_task_award_response"] = basefunc.handler(self,self.get_task_award_new_response)
	self.lister["ExitScene"] = basefunc.handler(self,self.MyExit)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	-- if self.backcall then
	-- 	self.backcall()
	-- end
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor(parent,backcall)
	local parent = parent or GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.backcall = backcall
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()

end

function C:InitUI()
	self.get_btn.onClick:AddListener(
		function ()
			Network.SendRequest("get_task_award",{id = M.task_id})
		end
	)
	self:MyRefresh()
end

function C:MyRefresh()
end

function C:get_task_award_new_response(_,data)
	if data and data.result == 0 and data.id == M.task_id then
		ExtendSoundManager.PlaySound(audio_config.game.bgm_hall_huodewupin.audio_name)
		self.step1.gameObject:SetActive(false)
		self.step2.gameObject:SetActive(true)
		Timer.New(function ()
			if IsEquals(self.gameObject) then
				self:MyExit()
			end
		end,4,1):Start()
	end
end

function C:cplxrqtl_task_change()
	if M.task_id then
		if M.GetTodayNum() ~= 0 then
			if IsEquals(self.num_txt) then
				self.num_txt.text =  string.format("%.2f", M.GetTodayNum()/100)
			end
			Timer.New(function ()
				self:MyExit()
				Act_016_CPLXRQTLPanel.Create(nil,self.backcall)
			end,2,1):Start()
		end
	end
end