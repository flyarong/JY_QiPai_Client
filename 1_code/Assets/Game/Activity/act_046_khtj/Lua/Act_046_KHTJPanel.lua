-- 创建时间:2020-12-29
-- Panel:Act_046_KHTJPanel
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
 -- 取消按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
 -- 确认按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
 --]]

local basefunc = require "Game/Common/basefunc"

Act_046_KHTJPanel = basefunc.class()
local C = Act_046_KHTJPanel
C.name = "Act_046_KHTJPanel"
local M = Act_046_KHTJManager
local btn_cfg = {
	[1] = {name = "普通鱼",click_func = "InitLevel1UI"},
	[2] = {name = "黄金鱼",click_func = "InitLevel2UI"},
	[3] = {name = "Boss鱼",click_func = "InitLevel3UI"},
	[4] = {name = "图鉴背包",click_func = "OpenBag"},
}
local task_info = {
	"集齐所有普通鱼图鉴可领","集齐所有黄金鱼图鉴可领","集齐所有Boss鱼图鉴可领"
}
 
local special_task = {
	M.config.group[1].task_id,M.config.group[2].task_id,M.config.group[3].task_id
}

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
	self.lister["model_task_change_msg"] = basefunc.handler(self,self.on_model_task_change_msg)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self.huxi1.Stop()
	self.huxi2.Stop()
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
	self.curr_index = 1
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:OnDestroy()
	self:MyExit()
end

function C:InitUI()
	self.button_uis = {}
	for i = 1,#btn_cfg do
		local temp = {}
		local b = GameObject.Instantiate(self.btn_item,self.button_node)
		b.gameObject:SetActive(true)
		LuaHelper.GeneratingVar(b.transform,temp)
		temp.main_txt.text = btn_cfg[i].name
		temp.mask_txt.text = btn_cfg[i].name
		temp.main_btn.onClick:AddListener(
			function()
				ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
				self:OnButtonClick(temp,btn_cfg[i].click_func)
			end
		)
		self.button_uis[#self.button_uis + 1] = temp
	end
	self.task_get_btn.onClick:AddListener(
		function()
			Network.SendRequest("get_task_award",{id = special_task[self.curr_index]})
		end
	)
	self.big2_btn.onClick:AddListener(
		function()
			Network.SendRequest("get_task_award",{id = 21638})
		end
	)
	self.big1_btn.onClick:AddListener(
		function()
			LTTipsPrefab.Show2(self.big1_btn.gameObject.transform,"豪华大礼","打开可随机\n获得100万~1000万鲸币！")
		end
	)
	self.task_go_btn.onClick:AddListener(
		function()
			ActivityYearPanel.Create(nil, nil, { ID =  164}, true)
		end
	)
	self.huxi1 = CommonHuxiAnim.Go(self.big1_btn.gameObject)
	self.huxi2 = CommonHuxiAnim.Go(self.big2_btn.gameObject)
	self.huxi1.Start()
	self.huxi2.Start()
	self:OnButtonClick(self.button_uis[1],btn_cfg[1].click_func)
	EventTriggerListener.Get(self.t3_img.gameObject).onClick = basefunc.handler(self,function()
		LTTipsPrefab.Show2(self.t3_img.gameObject.transform,"随机宝箱","打开可随机获得10万~100万鲸币")
	end)
	self:MyRefresh()
end

function C:ClearChild()
	destroyChildren(self.Content)
end

function C:MyRefresh()
	self:RefreshLJ()
end

function C:InitLevel1UI()
	self:CreateNormalUI(1)
end

function C:InitLevel2UI()
	self:CreateNormalUI(2)
end

function C:InitLevel3UI()
	self:CreateNormalUI(3)
end

function C:CreateNormalUI(index)
	self:ClearChild()
	self.curr_index = index
	local ids = M.config.group[index].ids
	self.Mian_UI = {}
	for i = 1,#ids do
		local temp = {}
		local data = {}
		local b = GameObject.Instantiate(self.item,self.Content)
		b.gameObject:SetActive(true)
		LuaHelper.GeneratingVar(b.transform,temp)
		temp.item_img.sprite = GetTexture(M.config.base[ids[i]].icon)
		temp.item_txt.text = "x"..M.config.base[ids[i]].award_txt
		temp.item_mask.gameObject:SetActive(false)
		temp.can_get_award_btn.onClick:AddListener(
			function()
				Network.SendRequest("get_task_award",{id = M.config.base[ids[i]].task_id})
			end
		)
		data.ui = temp
		data.task_id = M.config.base[ids[i]].task_id
		self.Mian_UI[#self.Mian_UI + 1] = data
	end
	self.task_txt.text = task_info[index]
	for i = 1,3 do
		self["task_item_"..i].gameObject:SetActive(false)
	end
	for i = 1,#M.config.group_award[index].award_name do
		self["task_item_"..i].gameObject:SetActive(true)
		self["t"..i.."_img"].sprite = GetTexture(M.config.group_award[index].award_image[i])
		self["t"..i.."_txt"].text = M.config.group_award[index].award_name[i]
	end
	PlayerPrefs.SetInt(C.name..MainModel.UserInfo.user_id..index,1)
	self:RefreshRed()
	self:RefreshMainUI()
	self:RefreshButtomTaskUI()
end

function C:OpenBag()
	Act_046_KHTJBagPanel.Create()
	PlayerPrefs.SetInt(C.name..MainModel.UserInfo.user_id..4,1)
	self.button_uis[4].btn_mask.gameObject:SetActive(false)
	self:RefreshRed()
end

function C:OnButtonClick(ui,func_name)
	for i = 1,#self.button_uis do
		self.button_uis[i].btn_mask.gameObject:SetActive(false)
	end
	ui.btn_mask.gameObject:SetActive(true)
	C[func_name](self)
end


function C:RefreshLJ()
	local find_task_id_func = function(index)
		local re = {}
		re[#re + 1] = M.config.group[index].task_id
		for i = 1,#M.config.group[index].ids do
			re[#re + 1] = M.config.base[M.config.group[index].ids[i]].task_id
		end
		return re
	end

	local check_is_lj_func = function(index)
		local task_ids = find_task_id_func(index)
		dump(task_ids,"当前的任务IDs")
		for j = 1,#task_ids do
			local data  = GameTaskModel.GetTaskDataByID(task_ids[j])
			if data then
				if data.award_status == 1 then
					return true
				end
			end
		end
		return false
	end
	for i = 1,3 do
		self.button_uis[i].lj.gameObject:SetActive(check_is_lj_func(i))
	end
	self.button_uis[4].lj.gameObject:SetActive(false)
end

function C:RefreshRed()
	for i = 1,4 do
		local tag = PlayerPrefs.GetInt(C.name..MainModel.UserInfo.user_id..i,0)
		if tag == 1 then
			self.button_uis[i].red.gameObject:SetActive(false)
		else
			self.button_uis[i].red.gameObject:SetActive(true)
		end
	end
end

function C:on_model_task_change_msg()
	self:RefreshLJ()
	self:RefreshMainUI()
	self:RefreshButtomTaskUI()
end

function C:RefreshButtomTaskUI()
	local data = GameTaskModel.GetTaskDataByID(special_task[self.curr_index])
	if data then
		self.task_pro_txt.text = "收集进度"..math.floor(data.now_process/data.need_process * 100).."%"
		self.pro.gameObject.transform.sizeDelta = {x = data.now_process/data.need_process * 291.8,y = 30}
		if data.award_status == 0 then
			self.task_get_btn.gameObject:SetActive(false)
			self.task_mask.gameObject:SetActive(false)
			self.task_go_btn.gameObject:SetActive(true)
		elseif data.award_status == 1 then
			self.task_get_btn.gameObject:SetActive(true)
			self.task_mask.gameObject:SetActive(false)
			self.task_go_btn.gameObject:SetActive(false)		
		else
			self.task_get_btn.gameObject:SetActive(false)
			self.task_mask.gameObject:SetActive(true)
			self.task_go_btn.gameObject:SetActive(false)		
		end
	end
	local big_task_data = GameTaskModel.GetTaskDataByID(21638)
	if big_task_data then
		if big_task_data.award_status == 0 then
			self.big2_btn.gameObject:SetActive(false)
			self.big_mask.gameObject:SetActive(false)
			self.big1_btn.gameObject:SetActive(true)
			self.big4_item.gameObject:SetActive(true)
		elseif big_task_data.award_status == 1 then
			self.big2_btn.gameObject:SetActive(true)
			self.big_mask.gameObject:SetActive(false)
			self.big1_btn.gameObject:SetActive(false)
			self.big4_item.gameObject:SetActive(false)		
		else
			self.big2_btn.gameObject:SetActive(false)
			self.big_mask.gameObject:SetActive(true)
			self.big1_btn.gameObject:SetActive(false)
			self.big4_item.gameObject:SetActive(false)
		end
	end
end


function C:RefreshMainUI()
	for i = 1,#self.Mian_UI do
		local data = self.Mian_UI[i]
		local task_id = data.task_id
		local ui = data.ui
		local task_data = GameTaskModel.GetTaskDataByID(task_id)
		if task_data then
			if task_data.award_status == 1 then
				ui.got.gameObject:SetActive(false)
				ui.item_mask.gameObject:SetActive(false)
				ui.can_get.gameObject:SetActive(true)
			elseif task_data.award_status == 2 then
				ui.got.gameObject:SetActive(true)
				ui.item_mask.gameObject:SetActive(false)
				ui.can_get.gameObject:SetActive(false)
			else
				ui.got.gameObject:SetActive(false)
				ui.item_mask.gameObject:SetActive(true)
				ui.can_get.gameObject:SetActive(false)
			end
		end
	end
end