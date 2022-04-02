-- 创建时间:2018-08-14
local basefunc = require "Game.Common.basefunc"

ActivityYearPanel = basefunc.class()
local C = ActivityYearPanel
local M = SYSACTBASEManager


local instance
function C.Create(goto_type, parent, backcall, parm , is_lock,goto_scene_call)
	if instance then
		if goto_type == instance.goto_type then
			instance:update(parm)
		else
			instance:MyExit()
			instance = C.New(goto_type, parent, backcall, parm, is_lock, goto_scene_call)	
		end
	else
		instance = C.New(goto_type, parent, backcall, parm, is_lock, goto_scene_call)	
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
	self.lister["finish_gift_shop"] = basefunc.handler(self, self.MyRefresh)
	self.lister["ExitScene"] = basefunc.handler(self, self.MyExit)
	self.lister["ui_button_data_change_msg"] = basefunc.handler(self, self.ui_button_data_change_msg)
	self.lister["exit_fish_scene"] = basefunc.handler(self,self.on_exit_fish_scene)
	self.lister["uninstall_start"] = basefunc.handler(self,self.MyExit)
end
--

function C:ui_button_data_change_msg(parm)
	local _list = M.GetActiveTagData(self.goto_type, self.activeIndex)
	MathExtend.SortList(_list, "order", true)
	_list = M.ReSetOrder(_list)
	local data = self.activityList[self.selectIndex]
	local is_change = false
	if #self.activityList == #_list then
		for k,v in ipairs(self.activityList) do
			if v.ID ~= _list[k].ID then
				is_change = true
				break
			end
		end		
	else
		is_change = true
	end
	local is_del = true
	local index = 1
	if is_change then
		for k,v in ipairs(_list) do
			if v.ID == data.ID then
				is_del = false
				index = k
				break
			end
		end
		if is_del then
			self.selectIndex = nil
		else
			self.selectIndex = index
		end
		self:MyRefresh()
	end
end


function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.RightObj then
		self.RightObj:MyExit()
		self.RightObj = nil
	end
	self:ClearCellList()
	if self.backcall then
		self.backcall()
	end
	if self.game_btn_pre then
		self.game_btn_pre:MyExit()
	end
	instance = nil
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:ctor(goto_type, parent, backcall, parm, is_lock, goto_scene_call)
	ExtPanel.ExtMsg(self)

	self.goto_type = goto_type
	self.style_config = M.GetStyleConfig(self.goto_type)
	self.parm = parm
	self.backcall = backcall
	self.goto_scene_call = goto_scene_call
	local parent = parent or GameObject.Find("Canvas/LayerLv4").transform
	self.prefab_name = "ActivityYearPanel_" .. self.style_config.style_type 
	if not GetPrefab(self.prefab_name) then
		self.prefab_name = "ActivityYearPanel_normal"
	end
    self.gameObject = newObject(self.prefab_name, parent)
    self.transform = self.gameObject.transform
    local tran = self.transform
	LuaHelper.GeneratingVar(self.transform, self)
    self:MakeLister()
    self:AddMsgListener()
    if IsEquals(self.btn_node) then
		local btn_map = {}
		btn_map["left"] = {self.btn_node}
	    self.game_btn_pre = GameButtonPanel.Create(btn_map, "year_panel")
	end

	self.BlackBG = self.transform:Find("BG")
	if self.BlackBG then
		self.BlackBG.gameObject:SetActive(true)
	end
	self:InitUI()
	DOTweenManager.OpenPopupUIAnim(self.root.transform)
end


function C:update(parm)
	self.parm = parm
	self:MyRefresh()
end

function C:InitUI()
	-- 激活的标签 1-是精彩活动 2-是游戏公告
	self.activeIndex = 2
	
	self.back_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		if self.prefab_name ~= "ActivityYearPanel_normal" then
			Event.Brocast("ActivityYearPanelBack")
		end
		self:MyExit()
	end)
	self:InitUINormal()

	self:MyRefresh()
end
function C:InitUINormal()
	if not IsEquals(self.tag_node) then
		return
	end
	self.activity_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnActiveIndex(1)
	end)
	self.notice_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnActiveIndex(2)
	end)
end
function C:OnActiveIndex(index)
	if self.activeIndex ~= index then
		self.activeIndex = index
		self.selectIndex = nil
		self:MyRefresh()
	end
end
function C:MyRefresh()
	self.activityList = M.GetActiveTagData(self.goto_type, self.activeIndex)
	MathExtend.SortList(self.activityList, "order", true)
	self.activityList = M.ReSetOrder(self.activityList)
	local index = self.selectIndex
	if self.parm and self.parm.ID then
		for i = 1,#self.activityList do
			if self.activityList[i].ID == self.parm.ID then
				index = i
				break
			end
		end
		self.parm.ID = nil
	end
	self:ClearCellList()
	for k,v in ipairs(self.activityList) do
		local pre = ActivityYearLeftPrefab.Create(self.left_content, v, self.OnToggleClick, self, k)
		self.CellList[#self.CellList + 1] = pre
	end
	self:SetSelect(index or 1)
	self:SetActiveTag()
end

function C:SetActiveTag()
	if not IsEquals(self.tag_node) then
		return
	end
	if self.activeIndex == 1 then
		self.ActivityHi.gameObject:SetActive(true)
		self.activity_btn.gameObject:SetActive(false)
		self.NoticeHi.gameObject:SetActive(false)
		self.notice_btn.gameObject:SetActive(true)
	elseif self.activeIndex == 2 then
		self.ActivityHi.gameObject:SetActive(false)
		self.activity_btn.gameObject:SetActive(true)
		self.NoticeHi.gameObject:SetActive(true)
		self.notice_btn.gameObject:SetActive(false)
	else
		self.ActivityHi.gameObject:SetActive(true)
		self.activity_btn.gameObject:SetActive(false)
		self.NoticeHi.gameObject:SetActive(true)
		self.notice_btn.gameObject:SetActive(false)
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

function C:UpdateRight()
	if self.RightObj then
		self.RightObj:OnDestroy()
		self.RightObj = nil
	end
	self.right_content.localPosition = Vector3.zero

	local data = self.activityList[self.selectIndex]
	if data.local_type == "activity" then
		if data.showType == "image" then
			self.RightObj = ActivityYearRightPrefab.Create(self.right_content, data, self.OnGotoClick, self, self.selectIndex)
		elseif data.showType == "prefab" then
			local parm = {}
			SetTempParm(parm, data.gotoUI, "panel")
			parm.parent = self.prefab_node
			parm.backcall = self.goto_scene_call
			parm.cfg = data
			parm.mark = "year_activity"
			self.RightObj = GameManager.GotoUI(parm)
			if not self.RightObj then
				dump(data, "<color=red>活动不存在</color>")
			end
		else
			dump(data.showType, "<color=red>活动类型不匹配</color>")
		end
	else
		self.RightObj = ActivityYearNoticePrefab.Create(self.right_content, data, OnGotoClick, self, self.selectIndex)
	end
end

function C:OnToggleClick(index)
	ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
	self:SetSelect(index)
end

function C:OnGotoClick()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
	self:OnGoto()
end

function C:OnGoto()
	local data = self.activityList[self.selectIndex]
	if data.gotoUI and next(data.gotoUI) then
		local parm = {}
		SetTempParm(parm, data.gotoUI, "panel")
		GameManager.GotoUI(parm)
	end
	if not data.noCloseUI or data.noCloseUI == 0 then
		self:MyExit()
	end
end

-- Fun
function C:SetSelect(i)
	if table_is_null(self.activityList) then
		LittleTips.Create("当前没有活动")
		return
	end
	if self.selectIndex then
		self.CellList[self.selectIndex]:SetSelect(false)
	end
	self.selectIndex = i
	self.CellList[self.selectIndex]:SetSelect(true)
	self:UpdateRight()
end

function C:OnBackClick()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
	self:MyExit()
end
function C:on_exit_fish_scene()
	self:MyExit()
end