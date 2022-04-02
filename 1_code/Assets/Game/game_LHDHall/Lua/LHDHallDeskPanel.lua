-- 创建时间:2019-12-09
-- Panel:LHDHallDeskPanel
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

LHDHallDeskPanel = basefunc.class()
local C = LHDHallDeskPanel
C.name = "LHDHallDeskPanel"
local M = LHDHallModel

function C.Create(parm)
	return C.New(parm)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["model_update_desk_data_msg"] = basefunc.handler(self, self.on_model_update_desk_data_msg)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	print("<color=red>LHDHallDeskPanel MyExit</color>")
	self:RemoveListener()
	destroy(self.gameObject)

	 
end

function C:ctor(parm)

	ExtPanel.ExtMsg(self)

	dump(parm, "<color=red>[LHD] LHDHallDeskPanel parm</color>")
	self.parm = parm
	self.game_id = parm.game_id
	self.panelSelf = parm.panelSelf

	local parent = self.parm.parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self.max_page = 1
	self.page_index = 1
	self.type_index = M.DeskType.DT_Nor
	self.show_max_desk = 10
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.cc_node.gameObject:SetActive(false)
	self.qs_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnQSClick()
	end)
	self.cc_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnCCClick()
	end)
	self.cc_xz_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnCCXZClick()
	end)
    EventTriggerListener.Get(self.top_mybutton.gameObject).onClick = basefunc.handler(self, self.ExitUI)

	self:MyRefresh()
end

function C:MyRefresh()
	if self.type_index == M.DeskType.DT_Nor then
		self.cur_cc_img.sprite = GetTexture("dld_ccbtn_mfc_1")
		self.cc_img.sprite = GetTexture("dld_ccbtn_vipc")
	else
		self.cur_cc_img.sprite = GetTexture("dld_ccbtn_vipc_1")
		self.cc_img.sprite = GetTexture("dld_ccbtn_mfc")
	end
	self.cur_cc_img:SetNativeSize()
	self.cc_img:SetNativeSize()

	M.query_desk_data({game_id=self.game_id, model=self.type_index, page=self.page_index})
end
function C:RefreshDesk()
	self:ClearCellList()

	for k,v in ipairs(self.cur_show_desk_data) do
		local pre = LHDDeskPrefab.Create(self.desk_node, v, C.OnEnterClick, self, k)
		self.CellList[#self.CellList + 1] = pre
	end	
end
function C:RefreshPage()
	self:ClearPageCellList()
	for i=1, self.max_page do
		local pre = LHDPagePrefab.Create(self.page_node, C.OnPageClick, self, i)
		self.PageCellList[#self.PageCellList + 1] = pre
		if self.page_index == i then
			pre:SetSelect(true)
		end
	end
end

function C:ClearCellList()
	if self.CellList then
		for k,v in ipairs(self.CellList) do
			v:OnDestroy()
		end
	end
	self.CellList = {}
end
function C:ClearPageCellList()
	if self.PageCellList then
		for k,v in ipairs(self.PageCellList) do
			v:OnDestroy()
		end
	end
	self.PageCellList = {}
end


function C:OnQSClick()
	self.panelSelf:CallSignup({game_id = self.game_id})
end

function C:ExitUI()
	self.cc_xz_btn.gameObject:SetActive(false)
end
function C:OnCCClick()
	self.cc_xz_btn.gameObject:SetActive(true)
end
function C:OnCCXZClick()
	if self.type_index ~= M.DeskType.DT_Vip then
		self.type_index = M.DeskType.DT_Vip
	else
		self.type_index = M.DeskType.DT_Nor
	end
	self.page_index = 1
	self:MyRefresh()
end

function C:OnEnterClick(index, seat_num)
	dump(self.cur_show_desk_data[index], "<color=red>desk data</color>")
	print("<color=red>index=" .. index .. " ,seat_num=" .. seat_num .. "</color>")

	local page_data = self.cur_show_desk_data[index]
	if page_data.p_info then
		for k,v in ipairs(page_data.p_info) do
			if v.seat_num == seat_num then
				LHDPlayerInfoPrefab.Create(v, UnityEngine.Input.mousePosition)
				return
			end
		end
	end
	self.panelSelf:CallSignup({game_id = self.game_id, room_no=self.cur_show_desk_data[index].room_no, seat_num=seat_num})
end
function C:OnPageClick(index)
	print("<color=red>index=" .. index .. "</color>")
	if index ~= self.page_index then
		self.page_index = index

		self:MyRefresh()
	end
end


function C:on_model_update_desk_data_msg(data)
	self.cur_show_desk_data = M.get_desk_data(data)
	self.max_page = M.get_desk_page_count(data)
	self:RefreshDesk()
	self:RefreshPage()
end
