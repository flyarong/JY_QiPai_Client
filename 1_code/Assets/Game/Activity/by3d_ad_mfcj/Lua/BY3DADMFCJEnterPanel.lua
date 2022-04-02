-- 创建时间:2020-08-03
-- Panel:BY3DADMFCJPanel
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

 BY3DADMFCJEnterPanel = basefunc.class()
 local C = BY3DADMFCJEnterPanel
 C.name = "BY3DADMFCJEnterPanel"
 local M = BY3DADMFCJManager
 
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
 
 function C:ctor(parent)
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
	 self.gameObject:GetComponent("Button").onClick:AddListener(function ()
		 ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		 self:OnEnterClick()
	 end)
	 self:MyRefresh()
 end
 
 function C:MyRefresh()
 
 end
 
 function C:OnEnterClick()
	BY3DADMFCJPanel.Create()
 end