-- 创建时间:2021-04-15
-- Panel:Act_055_DJLBTaskPanel
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

Act_055_DJLBTaskPanel = basefunc.class()
local C = Act_055_DJLBTaskPanel
local M = Act_055_DJLBManager
C.name = "Act_055_DJLBTaskPanel"

local awardImg = {
	"pay_icon_gold4",
	"bbsc_icon_hb",
	"bbsc_icon_hb",
}
local awardTxt = {
	"20000鲸币",
	"1元福卡",
	"3元福卡",
}


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
	self.lister["act_055_djlb_task_change"] = basefunc.handler(self,self.on_act_055_djlb_task_change)
	self.lister["act_055_djlb_base_info_change"] = basefunc.handler(self,self.on_act_055_djlb_base_info_change)
	self.lister["refresh_dui_ju_li_bao_task_response"] = basefunc.handler(self,self.on_refresh_dui_ju_li_bao_task_response)
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

function C:ctor()
	ExtPanel.ExtMsg(self)
	local parent = GameObject.Find("Canvas/LayerLv3").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	Network.SendRequest("query_one_task_data",{task_id = M.father_task_id1})
	Network.SendRequest("query_one_task_data",{task_id = M.father_task_id2})
	Network.SendRequest("query_dui_ju_li_bao_base_info")
	self:MakeLister()
	self:AddMsgListener()
	self.cur_tasks_data = M.GetCurTasks()
	self:InitUI()
end

function C:InitUI()
	self.close_btn.onClick:AddListener(function()
		self:MyExit()
	end)

	self.help_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OpenHelp()
	end)
	self:InitTaskList()
	self:MyRefresh()
end

function C:on_act_055_djlb_task_change()
	self.cur_tasks_data = M.GetCurTasks()
	if not self.transform then
		return
	end
	self:RefreshTaskListUI()
end

function C:on_act_055_djlb_base_info_change()
	self.base_info_data = M.GetBaseInfo()
	if not self.transform then
		return
	end
	CommonTimeManager.GetCutDownTimer(self.base_info_data.over_time,self.time_txt)
	self:RefreshTaskListUI()
end

function C:on_refresh_dui_ju_li_bao_task_response(_,data)
	if data and data.result == 0 then
		dump(data,"<color=red>+++++on_refresh_dui_ju_li_bao_task_response+++++</color>")
	end
end

function C:InitTaskList()
	self.task_pre = {}
	for i = 1, 3 do
		local b = GameObject.Instantiate(self.item, self.node.transform)
		b.gameObject:SetActive(true)
		local b_ui = {}
		LuaHelper.GeneratingVar(b.transform,b_ui)
		b_ui.award_img.sprite = GetTexture(awardImg[i])
		b_ui.award_txt.text = awardTxt[i]
		b_ui.refresh_btn.onClick:AddListener(function()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			self:RefreshTask(i)
		end)
		b_ui.get_btn.onClick:AddListener(function()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			self:GetAward(i)
		end)
		b_ui.go_btn.onClick:AddListener(function()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			self:GotoUI(i)
		end)

		self.task_pre[#self.task_pre + 1] = b
	end
end
local had_show = false
function C:RefreshTaskListUI()
	--dump("<color=red>-----RefreshTaskListUI------111------</color>")
	if not self.base_info_data then
		return
	end

	if  had_show == false and M.IsAllGet() then
		had_show = true
		self:MyExit()
		Act_055_DJLBHintPanel.Create(1)
	end 

	if not self.task_pre then
		return
	end
	--dump("<color=red>-----RefreshTaskListUI------222------</color>")
	for i = 1, #self.task_pre do
		local b  = self.task_pre[i]
		local b_ui = {}
		LuaHelper.GeneratingVar(b.transform,b_ui)

		if not self.cur_tasks_data[i] then
			b.gameObject:SetActive(false)
		else
			local b_task_id = self.cur_tasks_data[i]
			local b_task_data = GameTaskModel.GetTaskDataByID(b_task_id)
			if not b_task_data then
				b.gameObject:SetActive(false)
			else
				b.gameObject:SetActive(true)
				b_ui.slider = b_ui.Slider:GetComponent("Slider")
				if i == 1 then
					b_ui.task_txt.text = "每日登陆"
					b_ui.refresh_btn.gameObject:SetActive(false)
					b_ui.shuaxin.gameObject:SetActive(false)
					b_ui.bfb_txt.text =  "1/1"
					b_ui.slider.value = 1
				else
					local b_cfg = M.GetCfgFromTaskId(b_task_id)
					b_ui.task_txt.text = b_cfg.text
					b_ui.refresh_btn.gameObject:SetActive(b_task_data.award_status ~= 2)
					b_ui.shuaxin.gameObject:SetActive(not M.IsFreeRefresh())
					b_ui.bfb_txt.text = b_task_data.now_total_process .. "/" .. b_cfg.total
					b_ui.slider.value = b_task_data.now_total_process / b_cfg.total
				end
				b_ui.get_btn.gameObject:SetActive(b_task_data.award_status == 1)
				b_ui.go_btn.gameObject:SetActive(b_task_data.award_status == 0)
				b_ui.ylq.gameObject:SetActive(b_task_data.award_status == 2)
				b_ui.count_txt.text = "剩余" .. self.base_info_data["remain_num_"..i] .. "次"
			end
		end
	end
end

function C:RefreshTask(index)
	if index == 1 then
		return
	end

	if MainModel.UserInfo.jing_bi >= 100 or M.IsFreeRefresh() then
		local task_data = GameTaskModel.GetTaskDataByID(self.cur_tasks_data[index])
		if task_data then
			local send_message = function()
				Network.SendRequest("refresh_dui_ju_li_bao_task",{task_type  = index - 1})
			end

			if task_data.now_total_process > 0 then
				local b = HintPanel.Create(7,"刷新后已累计的任务进度会被清空\n是否确定刷新？",function ()
					send_message()
				end)
				b:SetBtnTitle("考虑一下","刷新")
			else
				send_message()
			end
		end
	else
		HintPanel.Create(1,"鲸币不足~")
	end
end

function C:GetAward(index)
	Network.SendRequest("get_task_award",{id = self.cur_tasks_data[index]})
end

function C:GotoUI(index)

	local cfg = M.GetCfgFromTaskId(self.cur_tasks_data[index])
	local game_id = cfg.game_id
	local sceneID = cfg.sceneID
	if not sceneID or not game_id then
		self:MyExit()
		return
	end
	local check = function ()
		local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="freestyle_game_"..game_id,vip_hint_type = 2, cw_btn_desc = "确定"}, "CheckCondition")
		if a and not b then
			return
		end
        local ss = GameFreeModel.IsRoomEnter(game_id)
        if ss == 1 then
            LittleTips.Create("当前鲸币不足")
            return
        end
        if ss == 2 then
            LittleTips.Create("当前鲸币太多")
            return
        end
		GameFreeModel.SetCurrSceneID(sceneID)
		GameFreeModel.SetCurrGameID(game_id)
		self:MyExit()
		GameManager.CommonGotoScence({gotoui = GameSceneCfg[GameFreeModel.data.sceneID].SceneName, p_requset={id =game_id}, })
    end
    check()
end

function C:OpenHelp()
	local str =""
    for i = 1, #M.rule do
        str = str .. "\n" ..M.rule[i]
    end
    self.introduce_txt.text = str
    IllustratePanel.Create({ self.introduce_txt.gameObject }, GameObject.Find("Canvas/LayerLv5").transform)
end

function C:MyRefresh()
end
