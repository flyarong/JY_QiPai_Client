-- 创建时间:2019-12-18
-- Panel:VipShowTQPanel
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

VipShowTQPanel = basefunc.class()
local C = VipShowTQPanel
C.name = "VipShowTQPanel"
local config
function C.Create(parent)
	DSM.PushAct({panel = C.name})
	return C.New(parent)
end

function C:AddMsgListener()
	for proto_name,func in pairs(self.lister) do
		Event.AddListener(proto_name, func)
	end
end

function C:MakeLister()
	self.lister = {}
	self.lister["model_vip_task_change_msg"] = basefunc.handler(self,self.Refresh)
end

function C:RemoveListener()
	for proto_name,func in pairs(self.lister) do
		Event.RemoveListener(proto_name, func)
	end
	self.lister = {}
end

function C:MyExit()
	if IsEquals(self.gameObject) and self.gameObject.activeSelf then
		DSM.PopAct()
	end
	self:RemoveListener()
	destroy(self.gameObject)

	 
end

function C:ctor(parent)

	ExtPanel.ExtMsg(self)

	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.transform.localPosition = Vector3.zero
	config = VIPManager.GetVIPCfg() 
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.TQPanel = self.transform:Find("TQ")
    VipShowInfoPanel.Create({tag = "mini", panel = "VipShowInfoMiniPanel",parent = self.TQPanel,callback = function ()
        self:MyExit()
    end})
end


function C:Refresh()
	
end

function C:OnDestroy()
	VipShowInfoPanel.Close()
	self:MyExit()
end

function C:OnShow(  )
	if IsEquals(self.gameObject) then
		DSM.PushAct({panel = C.name})
		self.gameObject:SetActive(true)
	end
end

function C:OnHide(  )
	if IsEquals(self.gameObject) and self.gameObject.activeSelf then
		DSM.PopAct()
		self.gameObject:SetActive(false)
	end
end