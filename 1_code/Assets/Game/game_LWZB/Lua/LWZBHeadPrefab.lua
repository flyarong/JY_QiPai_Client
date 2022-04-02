-- 创建时间:2020-09-02
-- Panel:LWZBHeadPrefab
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

LWZBHeadPrefab = basefunc.class()
local C = LWZBHeadPrefab
C.name = "LWZBHeadPrefab"

function C.Create(parent, index)
	return C.New(parent, index)
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

function C:ctor(parent, index)
	self.index = index
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

function C:MyRefresh()
	if self.data then
		self.gameObject:SetActive(true)
	else
		self.gameObject:SetActive(false)
	end
end

function C:RefreshData(data,type)
	self.data = data
	self.type = type
	if self.type == "fh" then
		if self.index == 1 then
			self.tag_img.sprite = GetTexture("lwzb_icon_fh1")
			self.tag_img.gameObject:SetActive(true)
		else
			self.tag_img.gameObject:SetActive(false)
		end
	elseif self.type == "xyx" then
		self.tag_img.sprite = GetTexture("lwzb_icon_xyx")
		self.tag_img.gameObject:SetActive(true)
		self.tag_img.transform.localPosition = Vector3.New(0,56,0)
	end
	self.tag_img:SetNativeSize()
	URLImageManager.UpdateHeadImage(self.data.player_info.head_image, self.head_img)
	self.name_txt.text = self.data.player_info.player_name
	self:MyRefresh()
end
