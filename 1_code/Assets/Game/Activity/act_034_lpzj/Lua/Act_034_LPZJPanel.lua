-- 创建时间:2020-10-06
-- Panel:Act_034_LPZJPanel
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

Act_034_LPZJPanel = basefunc.class()
local C = Act_034_LPZJPanel
C.name = "Act_034_LPZJPanel"
local M = Act_034_LPZJManager
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
	self.lister["click_like_activity_collect_advise_response"] = basefunc.handler(self,self.on_click_like_activity_collect_advise)
	self.lister["model_task_change_msg"] = basefunc.handler(self,self.on_model_task_change_msg)
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

function C:ctor(parent)
	ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.huxi = CommonHuxiAnim.Go(self.get_btn.gameObject)
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self:on_model_task_change_msg()
end

function C:InitUI()
	self.main_ipf.text = PlayerPrefs.GetString(MainModel.UserInfo.user_id.."034_lpzj","")
	self.main_ipf.onValueChanged:AddListener(function (val)
		if self.main_ipf.text == "" then
			self.num_txt.text = 0
		else
			self.num_txt.text = #basefunc.string.string_to_vec(self.main_ipf.text)
		end
	end)
	self.go_btn.onClick:AddListener(
		function()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			if self.main_ipf.text == "" then 
				HintPanel.Create(1,"请填写您喜欢的实物礼品")
			elseif #basefunc.string.string_to_vec(self.main_ipf.text) < 2 then				
				HintPanel.Create(1,"输入的字数太少哦")
			else
				self:SendText()
			end
		end
	)
	self.get_btn.onClick:AddListener(
		function()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			local data = GameTaskModel.GetTaskDataByID(M.task_id)
			if data and data.award_status == 1 then
				Network.SendRequest("get_task_award",{id = M.task_id})
			end
		end
	)
	self:MyRefresh()
end

function C:MyRefresh()
	self:on_model_task_change_msg()
end

function C:SendText()
	local str = self.main_ipf.text or ""
	PlayerPrefs.SetString(MainModel.UserInfo.user_id.."034_lpzj",str)
	Network.SendRequest("click_like_activity_collect_advise", {advise = str}, "提交建议")
end

function C:OnDestroy()
	self:MyExit()
end

function C:on_model_task_change_msg()
	local data = GameTaskModel.GetTaskDataByID(M.task_id)
	if data and data.award_status == 1 then
		self.huxi.Start()
		if  data.task_round > 1 then
			self.get_btn.gameObject:SetActive(false)
		end
	elseif (data and data.award_status ~= 1 and data.now_total_process > 0) then
		self.get_btn.gameObject:SetActive(false)
	end
	if data then
		if data.now_total_process >= 10 then
			self.mask.gameObject:SetActive(true)
		else
			self.mask.gameObject:SetActive(false)
		end
	end
end

function C:on_click_like_activity_collect_advise(_,data)
	dump(data,"<color=red>提交返回</color>")
	if data and data.result ~= 0 then
		HintPanel.Create(1,"建议提交过于频繁，请您30秒后再试");
	else
		LittleTips.Create("提交成功")
	end
end