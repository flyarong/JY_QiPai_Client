-- 创建时间:2020-07-28
-- Panel:Act_022_WYZJFPanel
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

Act_022_WYZJFPanel = basefunc.class()
local C = Act_022_WYZJFPanel
C.name = "Act_022_WYZJFPanel"
local M = Act_022_WYZJFManager
local task_config = M.task_config

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
	self.lister["AssetChange"] = basefunc.handler(self, self.OnAssetChange)
	self.lister["global_hint_state_change_msg"] = basefunc.handler(self,self.on_global_hint_state_change_msg)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.UpdateTimer then
		self.UpdateTimer:Stop()
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
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	
end

function C:InitUI()
	self.phb_btn.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			ActivityYearPanel.Create(nil,nil,{ID = 108})
		end
	)
	self.reset_btn.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			local reset_func = function()
				local offtime = math.abs(os.time() - PlayerPrefs.GetInt(M.key.."lastresettime",0))
				if	offtime <= 5 then
					LittleTips.Create((5 - offtime + 1).."秒后可再次重置任务")
					return
				end
				local set_func = function(index)
					PlayerPrefs.SetInt(MainModel.UserInfo.user_id..M.key.."renwu"..os.date("%Y%m%d",os.time()),index)
				end
				if PlayerPrefs.GetInt(MainModel.UserInfo.user_id..M.key.."renwu"..os.date("%Y%m%d",os.time()),0) == 0 then
					local b = HintPanel.Create(2,"任务重置后,所有任务将重新开始，是否重置？",function ()
						Network.SendRequest("get_task_award",{id = M.special_task_id})
						PlayerPrefs.SetInt(M.key.."lastresettime",os.time())
					end)
					b:ChangeTitleImg("zjf_imgf_czrw_activity_act_022_wyzjf")
					b:ShowGou()
					b:SetGouCall(function()
						set_func(1)
					end,function()
						set_func(0)
					end)
				else
					Network.SendRequest("get_task_award",{id = M.special_task_id})
					PlayerPrefs.SetInt(M.key.."lastresettime",os.time())
				end
			end
			local t = M.GetRefreshTime()
			if t < 3 then
				reset_func()
			else
				if MainModel.UserInfo.jing_bi >= 1000 then
					reset_func()
				else
					HintPanel.Create(1,"鲸币不足")
				end
			end			
		end
	)
	self:MainUICtor()
	self:MyRefresh()
	for k ,v in pairs(self.UI_Items) do
		local data = GameTaskModel.GetTaskDataByID(k)
		dump(data,"<color=red>任务数据</color>")	
	end
end

function C:MyRefresh()
	self:RefreshSX()
	self:RefreshItems()
	self.curr_txt.text = "当前积分："..GameItemModel.GetItemCount("prop_grade")
end

function C:OnDestroy()
	self:MyExit()
end


function C:MainUICtor()
	self.UI_Items = {}
	for k,v in pairs(M.task_config) do
		local b = self:CreateTaskItem(k,v)
		self.UI_Items[k] = b
	end	
end

function C:CreateTaskItem(task_id,ui_data)
	local b = GameObject.Instantiate(self.item,self.Content)
	b.gameObject:SetActive(true)
	local temp_ui = {}
	LuaHelper.GeneratingVar(b.transform,temp_ui)
	temp_ui.title_txt.text = ui_data.name
	temp_ui.reward_btn.onClick:AddListener(
		function()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			
			Network.SendRequest("get_task_award",{id = task_id})
		end
	)
	temp_ui.recharge_btn.onClick:AddListener(
		function()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			GameManager.CommonGotoScence(ui_data.gotoui, function ()
				self:MyExit()
			end)
		end
	)
	temp_ui.recharge_btn.gameObject:SetActive(true)
	self:CreateAwardItem(b,ui_data,task_id)
	b.name = task_id
	return b 
end

function C:CreateAwardItem(obj,ui_data,task_id)
	local temp_ui = {}
	LuaHelper.GeneratingVar(obj.transform,temp_ui)
	--普通奖励
	local award_item = {}
	for i = 1,#ui_data.award do
		local b =  GameObject.Instantiate(temp_ui.item_tmpl,temp_ui.list_node)
		b.gameObject:SetActive(true)
		local temp_ui1 = {}
		LuaHelper.GeneratingVar(b.transform,temp_ui1)
		temp_ui1.icon_img.sprite = GetTexture(ui_data.award[i].image)
		temp_ui1.count_txt.text = ui_data.award[i].text
		award_item[#award_item + 1] = b
		b.name = i
	end
	self.award_uis = self.award_uis or {}
	self.award_uis[task_id] = award_item

	--积分奖励
	local b =  GameObject.Instantiate(temp_ui.item_tmpl,temp_ui.list_node)
	b.gameObject:SetActive(true)
	b.name = "jf"
	local temp_ui2 = {}
	LuaHelper.GeneratingVar(b.transform,temp_ui2)
	temp_ui2.icon_img.sprite = GetTexture(ui_data.jf_award.image)
	temp_ui2.count_txt.text = ui_data.jf_award.text
end

function C:on_global_hint_state_change_msg(data)
	if data and data.gotoui == M.key then
		self:MyRefresh()
	end
end

--刷新 （刷新任务）的UI
function C:RefreshSX()
	if self.UpdateTimer then
		self.UpdateTimer:Stop()
	end
	local func = function ()
		local offtime = math.abs(os.time() - PlayerPrefs.GetInt(M.key.."lastresettime",0))		
		if offtime >= 5 then
			local t = M.GetRefreshTime()
			if t < 3 then
				self.xh_txt.text = "免费"..(t).."/3次"
			else
				self.xh_txt.text = "消耗1000鲸币"
			end	
		else
			self.xh_txt.text = "倒计时:"..5 - offtime + 1
		end
	end
	func()
	self.UpdateTimer = Timer.New(
		function ()
			func()
		end
	,1,-1)
	self.UpdateTimer:Start()
end

function C:RefreshItems()
	--重新规整
	local t = {-9999999,9999999}
	for k ,v in pairs(self.UI_Items) do
		for i = 1,#t do
			if t[i] < k and t[i + 1] > k then
				table.insert (t, i + 1 ,k)
			end
		end
	end
	table.remove(t,1)
	table.remove(t,#t)
	for i = 1,#t do
		self.UI_Items[t[i]].transform:SetSiblingIndex(i)
	end

	--根据任务数据刷新状态
	for i = 1,#t do
		local data = GameTaskModel.GetTaskDataByID(t[i])
		local temp_ui = {}
		LuaHelper.GeneratingVar(self.UI_Items[t[i]].transform,temp_ui)
		if data then
			temp_ui.bar.transform.sizeDelta = Vector2.New(data.now_process/data.need_process*341,42)
			temp_ui.bfb_txt.text = data.now_process.."/"..data.need_process
			if data.other_data_str then
				local re = basefunc.parse_activity_data(data.other_data_str)
				for m = 1,#self.award_uis[t[i]] do
					self.award_uis[t[i]][m].gameObject:SetActive(false)
				end
				self.award_uis[t[i]][re.real_award].gameObject:SetActive(true)
			end
			if data.award_status == 1 then
				temp_ui.recharge_btn.gameObject:SetActive(false)
				temp_ui.complete_img.gameObject:SetActive(false)
				temp_ui.reward_btn.gameObject:SetActive(true)
				self.UI_Items[t[i]].transform:SetSiblingIndex(0)
			elseif data.award_status == 2 then
				temp_ui.recharge_btn.gameObject:SetActive(false)
				temp_ui.complete_img.gameObject:SetActive(true)
				temp_ui.reward_btn.gameObject:SetActive(false)
				self.UI_Items[t[i]].transform:SetSiblingIndex(#t)
			else
				temp_ui.recharge_btn.gameObject:SetActive(true)
				temp_ui.complete_img.gameObject:SetActive(false)
				temp_ui.reward_btn.gameObject:SetActive(false)
			end
			
		end
	end
end

function C:OnAssetChange()
	self.curr_txt.text = "当前积分："..GameItemModel.GetItemCount("prop_grade")
end


--[[
	GetTexture("zjf_imgf_czrw_activity_act_022_wyzjf")
]]