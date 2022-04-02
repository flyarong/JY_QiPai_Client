-- 创建时间:2020-08-31
-- Panel:LWZBSnatchItemBase
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

LWZBSnatchItemBase = basefunc.class()
local C = LWZBSnatchItemBase
C.name = "LWZBSnatchItemBase"

function C.Create(parent,index,data)
	return C.New(parent,index,data)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"] = basefunc.handler(self,self.MyExit)
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

function C:ctor(parent,index,data)
	self.index = index
	self.data = data
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
	self.rank_txt.text = self.index - 1
	URLImageManager.UpdateHeadImage(self.data.player_info.head_image, self.head_img)
	self.name_txt.text = self.data.player_info.player_name
	if self.data.player_info.vip_level then
		VIPManager.set_vip_text(self.vip_txt,self.data.player_info.vip_level)
	else
		self.vip_txt.gameObject:SetActive(false)
	end
	if self.data.player_info.player_id == "sys_dragon" then
		self.curjingbi_txt.text = "保密"
	else
		self.curjingbi_txt.text = StringHelper.ToCash(self.data.jing_bi)
	end
	if self.index == 1 then--是龙王
		self.rank_txt.gameObject:SetActive(false)
		self.rank_img.gameObject:SetActive(true)
	else
		self.rank_txt.gameObject:SetActive(true)
		self.rank_img.gameObject:SetActive(false)
	end
	if MainModel.UserInfo.user_id == self.data.player_info.player_id then
		self.kuang.gameObject:SetActive(true)
	else
		self.kuang.gameObject:SetActive(false)
	end
	self:MyRefresh()
end

function C:MyRefresh()
end
