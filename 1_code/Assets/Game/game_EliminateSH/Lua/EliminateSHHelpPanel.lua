-- 创建时间:2019-05-30
-- Panel:New Lua
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

EliminateSHHelpPanel = basefunc.class()
local C = EliminateSHHelpPanel
C.name = "EliminateSHHelpPanel"

local instance
function C.Create()
	if not instance then
		instance = C.New()
	else
		instance:MyRefresh()
	end
	return instance
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
	self.lister = {}
	self.lister["view_quit_game"] = basefunc.handler(self, self.Close)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end
function C:Close()
	self:MyExit()
end

function C:MyExit()
	self:RemoveListener()
	instance = nil
	GameObject.Destroy(self.gameObject)

	 
end

function C:ctor()

	ExtPanel.ExtMsg(self)

	local parent = GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.ui={}
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self:OnChoose(1)
end

function C:InitUI()
	self.back_btn.onClick:AddListener(
		function ()
			self:Close()
		end
	)
	for i=1,7 do
		self["tgeItem"..i.. "_tge"].onValueChanged:AddListener(
			function (val)
				self:OnToggleClick(val,i)
			end
		)	
	end
	local rate_map = eliminate_sh_algorithm.rate_map

	local obj_map = {}
	self.ui.rate_obj_map = {}
	self.ui.lp_rate_obj_map = {}
	local obj = {}
	for i=3,8 do
		obj = GameObject.Instantiate(self.rate_item,self.rate_content)
		obj.gameObject:SetActive(true)
		self.ui.rate_obj_map[i] = {}
		LuaHelper.GeneratingVar(obj.transform, self.ui.rate_obj_map[i])

		obj = GameObject.Instantiate(self.lp_rate_item,self.lp_rate_content)
		obj.gameObject:SetActive(true)
		self.ui.lp_rate_obj_map[i] = {}
		LuaHelper.GeneratingVar(obj.transform, self.ui.lp_rate_obj_map[i])
	end

	local ui_table = {}
	for xc_count = 3,8 do
		ui_table = self.ui.rate_obj_map[xc_count]
		if xc_count == 8 then
			ui_table.nl_txt.text = xc_count .. "连+"
		else
			ui_table.nl_txt.text = xc_count .. "连"
		end
		for xc_id = 1,5 do
			ui_table["id" .. xc_id .. "_txt"].text = eliminate_sh_algorithm.get_rate(xc_id,xc_count) .. "倍"
		end
	end

	for xc_count = 3,8 do
		ui_table = self.ui.lp_rate_obj_map[xc_count]
		if xc_count == 8 then
			ui_table.nl_txt.text = xc_count .. "连+"
		else
			ui_table.nl_txt.text = xc_count .. "连"
		end
		ui_table["id2_txt"].text = eliminate_sh_algorithm.get_rate(6,xc_count) .. "倍"
		local hero_count = eliminate_sh_algorithm.get_hero_count(xc_count)
		if hero_count then
			ui_table["id1_txt"].text = hero_count .. "个英雄 或"
		end
	end
end

function C:MyRefresh()
end

-- 当选择中一个
function C:OnChoose(index)
	self["tgeItem"..index .. "_tge"].isOn = true 
	self:HideAll()
	self["sv"..index].gameObject:SetActive(true) 
end


function C:HideAll()
	for i=1,7 do
		self["sv"..i].gameObject:SetActive(false) 
	end
end

function C:OnToggleClick(val,i)
	if val then
		self:OnChoose(i)
	end 
end
