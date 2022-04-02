-- 创建时间:2020-07-31
-- Panel:SYSChangeHeadPanel
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

SYSChangeHeadPanel = basefunc.class()
local C = SYSChangeHeadPanel
C.name = "SYSChangeHeadPanel"
local M = SYSChangeHeadAndNameManager
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
    self.lister["ExitScene"] = basefunc.handler(self,self.MyExit)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	Event.Brocast("OnePanel_had_been_Close_msg")
	self:CloseItemPrefab()
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
	local parent = GameObject.Find("Canvas/LayerLv4").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self.img_type = 0
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.back_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:on_BackClick()
	end)
	Event.Brocast("OnePanel_had_been_Open_msg")
	self:CreateItemPrefab()
	self:MyRefresh()
end

function C:MyRefresh()
end

function C:on_BackClick()
	dump(self.img_type,"<color=yellow>+++++++++++++++</color>")
	if self.img_type ~= 0 then
		Network.SendRequest("set_head_image",{img_type = self.img_type})
	end
	self:MyExit()
end

function C:CreateItemPrefab()
	self:CloseItemPrefab()
	local cfg_free = M.GetFreeImgTypeList()
	local cfg_vip = M.GetVIPImgTypeList()

	if #cfg_free > 0 then
		self.spawn_cell_list[#self.spawn_cell_list + 1] = SYSChangePageItemBase.Create(self.Content.transform,"经典头像")
		self.obj_free = GameObject.Instantiate(self.FreeImgContent, self.Content.transform)
		self.obj_free.gameObject:SetActive(true)
	end
	for i=1,#cfg_free do
		local pre = SYSChangeHeadItemBase.Create(self.obj_free,self,cfg_free[i])
		self.spawn_cell_list[#self.spawn_cell_list + 1] = pre
	end
	if #cfg_vip > 0 then
		self.spawn_cell_list[#self.spawn_cell_list + 1] = SYSChangePageItemBase.Create(self.Content.transform,"VIP尊享")
		self.obj_vip = GameObject.Instantiate(self.VIPImgContent, self.Content.transform)
		self.obj_vip.gameObject:SetActive(true)
	end
	for i=1,#cfg_vip do
		local pre = SYSChangeHeadItemBase.Create(self.obj_vip,self,cfg_vip[i])
		self.spawn_cell_list[#self.spawn_cell_list + 1] = pre
	end
end

function C:CloseItemPrefab()
	if self.spawn_cell_list then
		for k,v in ipairs(self.spawn_cell_list) do
			v:MyExit()
		end
	end
	self.spawn_cell_list = {}
end

function C:SetImgType(img_type)
	dump(img_type,"<color=yellow>+++++++++++++++</color>")
	self.img_type = img_type
end
