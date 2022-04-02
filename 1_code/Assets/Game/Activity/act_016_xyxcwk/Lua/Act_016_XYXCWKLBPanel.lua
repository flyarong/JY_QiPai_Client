-- 创建时间:2020-06-09
-- Panel:Act_016_XYXCWKLBPanel
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

Act_016_XYXCWKLBPanel = basefunc.class()
local C = Act_016_XYXCWKLBPanel
C.name = "Act_016_XYXCWKLBPanel"
local M = Act_016_XYXCWKManager
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
	self.lister["finish_gift_shop"] = basefunc.handler(self,self.on_finish_gift_shop) 
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
	Network.SendRequest("query_one_task_data",{task_id = M.day_task_id})	
	-- dump(GameTaskModel.GetTaskDataByID(M.day_task_id),"<color=red>111</color>")
	-- dump(GameTaskModel.GetTaskDataByID(M.father_task_id1),"<color=red>222</color>")
	-- dump(GameTaskModel.GetTaskDataByID(M.father_task_id2),"<color=red>333</color>")
end

function C:InitUI()
	self.buy_btn.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			M.BuyShop()
		end
	)
	self.close_btn.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
			self:MyExit()
		end
	)
	self.help_btn.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			Act_016_XYXCWKHelpPanel.Create()
		end
	)
	self:MyRefresh()
end

function C:MyRefresh()
	
end

function C:on_finish_gift_shop(id)
	if id == M.shop_id then
		self:MyExit()
		Timer.New(
			function ()
				Act_016_XYXCWKPanel.Create()				
			end
		,2,1):Start()
    end
end