-- 创建时间:2020-02-14
-- Panel:EliminateCSZiPanel
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

EliminateCSZiPanel = basefunc.class()
local C = EliminateCSZiPanel
C.name = "EliminateCSZiPanel"
local Instance
local zi = {"天","女","散","花"}
--data:all_tnsh_list_cur
function C.Create(data)
	if Instance then 
		return Instance
	else
		Instance = C.New(data)
		return Instance
	end 
end

function C.Refresh(data)
	if Instance then 
		--设置当前进度
		if data then
			Instance.data = data
		end
		Instance:MyRefresh()
	end 
end

function C.Close()
	if Instance then 
		Instance:MyExit()
	end
end

function C.AddZi(zi)
	if not zi then return end
	if Instance then 
		--设置当前进度
		Instance.data = Instance.data or {}
		Instance.data.all_tnsh_list_cur = Instance.data.all_tnsh_list_cur or {}
		Instance.data.all_tnsh_list_cur[zi] = Instance.data.all_tnsh_list_cur[zi] or 0
		Instance.data.all_tnsh_list_cur[zi] = Instance.data.all_tnsh_list_cur[zi] + 1
		-- Instance:MyRefresh()
	end 
end

function C.GetZiNode(zi)
	if Instance then
		return Instance["z" .. zi]
	end
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
	self.lister = {}
	self.lister["view_quit_game"] = basefunc.handler(self, self.MyExit)
    self.lister["view_lottery_start"] = basefunc.handler(self, self.view_lottery_start)
    self.lister["view_lottery_end"] = basefunc.handler(self, self.view_lottery_end)
    self.lister["view_lottery_end_nor"] = basefunc.handler(self, self.view_lottery_end_nor)
	self.lister["view_lottery_error"] = basefunc.handler(self, self.view_lottery_error)
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
	Instance = nil

	 
end

function C:ctor(data)

	ExtPanel.ExtMsg(self)

	self.data = data
	local parent = GameObject.Find("Canvas/LayerLv1").transform
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
	for i,v in ipairs(zi) do
		self.zi_obj =self.zi_obj or {}
		self.zi_obj[i] = self.zi_obj[i] or {}
		self.zi_obj[i].transform = GameObject.Instantiate(self.z_item,self["z" .. i].transform)
		self.zi_obj[i].gameObject = self.zi_obj[i].transform.gameObject
		self.zi_obj[i].gameObject:SetActive(true)
		LuaHelper.GeneratingVar(self.zi_obj[i].transform, self.zi_obj[i])
		self.zi_obj[i].z_img.sprite = GetTexture("csxxl_bg_tnsh" .. i)
	end
	self:MyRefresh()
end

function C:MyRefresh()
	local obj
	local v
	for i,_v in ipairs(zi) do
		obj =  self.zi_obj[i]
		if table_is_null(self.data) or table_is_null(self.data.all_tnsh_list_cur) then
			self.zi_obj[i].gameObject:SetActive(false)
		else
			v = self.data.all_tnsh_list_cur[i]
			if v and v > 0 then
				self.zi_obj[i].gameObject:SetActive(true)
				local zi = 6 + i
				self.zi_obj[i].z_icon_img.sprite = EliminateCSObjManager.item_obj["xxl_icon_" .. zi]
			else
				self.zi_obj[i].gameObject:SetActive(false)
			end
		end
	end
end

function C:view_lottery_end(data)
	self.data = self.data or {}
	self.data.all_tnsh_list_cur = data.all_tnsh_list
	self:MyRefresh()
end

function C:view_lottery_end_nor(data)
	self.data = self.data or {}
	self.data.all_tnsh_list_cur = data.all_tnsh_list
	self:MyRefresh()
end

function C:view_lottery_start(data)
	self.data = nil
	self:MyRefresh()
end

function C:view_lottery_error(data)
	self.data = nil
	self:MyRefresh()
end

function C:csxxl_zi_refresh(data)
	self.data = data
	self:MyRefresh()
end