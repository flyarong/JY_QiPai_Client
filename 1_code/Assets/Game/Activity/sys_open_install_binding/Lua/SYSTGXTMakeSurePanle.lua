-- 创建时间:2020-07-30
-- Panel:SYSTGXTMakeSurePanle
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

SYSTGXTMakeSurePanle = basefunc.class()
local C = SYSTGXTMakeSurePanle
C.name = "SYSTGXTMakeSurePanle"

function C.Create(data)
	return C.New(data)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"] = basefunc.handler(self,self.MyExit)
    self.lister["player_parent_id_msg"] = basefunc.handler(self,self.player_parent_id_msg)
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

function C:ctor(data)
	self.data = data
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
	EventTriggerListener.Get(self.back_btn.gameObject).onClick = basefunc.handler(self, self.on_BackClick)
	EventTriggerListener.Get(self.make_sure_btn.gameObject).onClick = basefunc.handler(self, self.on_MakeSureClick)

	self:MyRefresh()
end

function C:MyRefresh()
end

function C:on_BackClick()
	self:MyExit()
end

function C:on_MakeSureClick()
	Network.SendRequest("register_by_introducer",{parent_id = self.parent_id_txt.text})
	self:MyExit()
end


function C:player_parent_id_msg(data)
	dump(data,"<color=red>WWWWWWWWWWWWWW</color>")
	self.data = data
	self.parent_id_txt.text = self.data.parent_id
	URLImageManager.UpdateHeadImage(self.data.data.head_image,self.parent_head_img)
	--URLImageManager.WWWImage(self.data.data.head_image,self.parent_head_img)
	self.parent_name_txt.text = "昵称:  "..self.data.data.name
end