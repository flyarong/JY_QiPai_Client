-- 创建时间:2019-12-18
-- Panel:VipShowYJTZPanel
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

VipShowYJTZPanel = basefunc.class()
local C = VipShowYJTZPanel
C.name = "VipShowYJTZPanel"
local config
-- local old_task_id = 112
-- local new_task_id = 21243
-- local three_task_id = 21315
-- local four_task_id = 21651

--第4个阶段之后 循环此任务
-- local loop_task_id = 21652

local now_task_id
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
	self.lister["model_vip_task_change_msg"] = basefunc.handler(self, self.OnReFreshInfo)
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
	self.transform.localPosition = Vector3.zero
	config = VIPManager.GetVIPCfg()
	self.is_new = false
	now_task_id = VIPManager.GetCurTaskYJTZ()
	local cur_state = VIPManager.GetCurStateYKTZ()
	if cur_state == 1 then
	elseif cur_state == 2 then
		config.yjtz = config.yjtz_new
	elseif cur_state == 3 then
		config.yjtz = config.yjtz_three
	elseif cur_state == 4 then
		config.yjtz = config.yjtz_four
	elseif cur_state == 5 then
		config.yjtz = config.yjtz_loop
	end

	-- now_task_id = old_task_id
	-- local td = GameTaskModel.GetTaskDataByID(old_task_id)
	-- if td and (td.award_status == 2 or td.award_status == 3) then
	-- 	self.is_new = true
	-- 	config.yjtz = config.yjtz_new
	-- 	now_task_id = new_task_id
	-- end
	-- td = GameTaskModel.GetTaskDataByID(new_task_id)
	-- if td and (td.award_status == 2 or td.award_status == 3) then
	-- 	self.is_new = true
	-- 	config.yjtz = config.yjtz_three
	-- 	now_task_id = three_task_id		
	-- end
	-- td = GameTaskModel.GetTaskDataByID(three_task_id)
	-- if td and (td.award_status == 2 or td.award_status == 3) then
	-- 	self.is_new = true
	-- 	config.yjtz = config.yjtz_four
	-- 	now_task_id = four_task_id		
	-- end
	-- td = GameTaskModel.GetTaskDataByID(four_task_id)
	-- if td and (td.award_status == 2 or td.award_status == 3) then
	-- 	self.is_new = true
	-- 	config.yjtz = config.yjtz_loop
	-- 	now_task_id = loop_task_id		
	-- end

	self.JDTlen = 391.48
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
    self.YJTZpanel = self.transform:Find("YJTZ")
	self.YJTZCText = self.YJTZpanel:Find("CText"):GetComponent("Text")
	self.YJTZChild = self.transform:Find("YJTZChild")
	self.YJTZContent = self.YJTZpanel:Find("Scroll View/Viewport/Content")
	self.YJTZHelpPanel = self.transform:Find("YJTZHelpPanel")
    self.YJTZHelpPanelButton = self.YJTZHelpPanel:Find("Button"):GetComponent("Button")
	self.YJTZHelpPanelClose = self.YJTZHelpPanel:Find("CloseButton"):GetComponent("Button")
	self.YJTZHelp = self.YJTZpanel.transform:Find("Help"):GetComponent("Button")
	self.AwardChild = self.transform:Find("AwardChild")
	self.YJTZHelp.onClick:AddListener(
		function()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
			self.YJTZHelpPanel.gameObject:SetActive(true)
		end
	)
	self.YJTZHelpPanelClose.onClick:AddListener(
		function()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
			self.YJTZHelpPanel.gameObject:SetActive(false)
		end
		)
	self.YJTZHelpPanelButton.onClick:AddListener(
		function()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
			self.YJTZHelpPanel.gameObject:SetActive(false)
		end
	)
	self:OnTask(VIPManager.get_vip_task())

	local mc = gameMgr:getMarketChannel()
	if mc == "normal" or mc == "wqp" then
		local help_txt = self.YJTZHelpPanel:Find("Scroll View/Viewport/Content/Text2"):GetComponent("Text")
		-- help_txt.text = help_txt.text .. "\n街机捕鱼累计赢金按50%计算"
		help_txt.text = help_txt.text .. "\n街机打鱼累计赢金按50%计算"
	end
end

function C:OnTask(data)
	if data == nil or not IsEquals(self.gameObject) then return end
	if data then
		self:DoYJTZ(data[now_task_id])
	end
end

function C:OnReFreshInfo()
	local data = VIPManager.get_vip_task()
	if data == nil or not IsEquals(self.gameObject) then return end
	if data and data[now_task_id] then 
		self:RefreshYJTZ(data[now_task_id])
	end 
end

function C:DoYJTZ(data)
	if data == nil then
		data = {
			award_get_status = 0,
			award_status    = 0,
			end_valid_time = 32503651200,
			id            = now_task_id,
			need_process    = 1000000,
			now_lv    = 1,
			now_process    = 0,
			now_total_process = 0,
			over_time    = 32503651200,
			start_valid_time = 946677600,
			task_round    = 1,
			task_type    = "vip_game_award_task",
		}
	end
	dump(data.award_get_status, ">>>>>")
	local b = basefunc.decode_task_award_status(data.award_get_status)
	dump(b, ">>>>>")
	b = basefunc.decode_all_task_award_status2(b, data, #config.yjtz)
	dump(b, "-------赢金挑战------")
	self.YJTZChilds = {}
	for i = 1, #b do
		local m    = GameObject.Instantiate(self.YJTZChild, self.YJTZContent)
		self.YJTZChilds[#self.YJTZChilds + 1] = m
		m.gameObject:SetActive(true)
		local content = m.transform:Find("Scroll View/Viewport/Content")
		m.transform:Find("GOButton").gameObject:GetComponent("Button").onClick:AddListener(
		function()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
			if MainModel.myLocation == "game_Hall" then
				Event.Brocast("TRY_VIP_SHOW_TASK_COLSE")
			else
				local gotoparm = {gotoui = "hall"}
				GameManager.GotoUI(gotoparm)
			end            
		end        
		)
		m.transform:Find("LQButton").gameObject:GetComponent("Button").onClick:AddListener(
		function()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
			if config.yjtz[i].isreal == 1 then
				local string1
				if not config.yjtz[i].remark then
					string1 = "恭喜你获得<color=#E9AB1BFF><b>"..config.yjtz[i].text.."</b></color>\n请联系客服领取奖励"
				else
					string1 = "恭喜你获得<color=#E9AB1BFF><b>"..config.yjtz[i].text[1]..","
					..config.yjtz[i].text[2]..",".."</b></color>和<color=#E9AB1BFF><b>"..config.yjtz[i].text[3].."</b></color>(三选一)\n请联系客服QQ公众号4008882620领取奖励"
				end      
				VIPSWGetPanel.Create({ text = string1})
				Network.SendRequest("get_task_award_new", { id = now_task_id, award_progress_lv = i })
			else
				Network.SendRequest("get_task_award_new", { id = now_task_id, award_progress_lv = i })
			end            
		end        
		)
		m.transform:Find("SWLQButton").gameObject:GetComponent("Button").onClick:AddListener(
		function()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
			if config.yjtz[i].isreal == 1 then
				local string1
				if not config.yjtz[i].remark then
					string1 = "恭喜你获得<color=#E9AB1BFF><b>"..config.yjtz[i].text.."</b></color>\n请联系客服领取奖励"
				else
					string1 = "恭喜你获得<color=#E9AB1BFF><b>"..config.yjtz[i].remark.."</b></color>\n请联系客服领取奖励"
				end
				VIPSWGetPanel.Create({ text = string1})
				Network.SendRequest("get_task_award_new", { id = now_task_id, award_progress_lv = i })
			end            
		end        
		)
		m.transform:Find("TopText/Text1"):GetComponent("Text").text = "所有游戏累计赢金"
		m.transform:Find("tips_txt"):GetComponent("Text").text = config.yjtz[i].remark
		m.transform:Find("TopText/Text2"):GetComponent("Text").text = StringHelper.ToCash(config.yjtz[i].need)
		if type(config.yjtz[i].image) == "table" then
			for j = 1, #config.yjtz[i].image do
				local n = GameObject.Instantiate(self.AwardChild, content)
				n.gameObject:SetActive(true)
				n.transform:Find("Image"):GetComponent("Image").sprite = GetTexture(config.yjtz[i].image[j])
				n.transform:Find("Text"):GetComponent("Text").text = config.yjtz[i].text[j]
			end
		else
			local n = GameObject.Instantiate(self.AwardChild, content)
			n.gameObject:SetActive(true)
			n.transform:Find("Image"):GetComponent("Image").sprite = GetTexture(config.yjtz[i].image)
			n.transform:Find("Text"):GetComponent("Text").text = config.yjtz[i].text
		end
	end
	self:RefreshYJTZ(data)
end
function C:RefreshYJTZ(data)
	if data == nil then return end
	local b = basefunc.decode_task_award_status(data.award_get_status)
	b = basefunc.decode_all_task_award_status2(b, data, #config.yjtz)

	for i = 1, data.now_lv - 1 do
		self.YJTZChilds[i]:Find("Progress_bg/progress_mask").sizeDelta = {
			x = self.JDTlen * 1,
			y = self.YJTZChilds[i]:Find("Progress_bg/progress_mask").rect.height
		}
		self.YJTZChilds[i]:Find("BFBText"):GetComponent("Text").text = StringHelper.ToCash(config.yjtz[i].need) .. "/" .. StringHelper.ToCash(config.yjtz[i].need)
	end
	self.YJTZChilds[data.now_lv]:Find("Progress_bg/progress_mask").sizeDelta = {
		x = self.JDTlen * (data.now_total_process / config.yjtz[data.now_lv].need),
		y = self.YJTZChilds[data.now_lv]:Find("Progress_bg/progress_mask").rect.height
	}
	self.YJTZChilds[data.now_lv]:Find("BFBText"):GetComponent("Text").text = StringHelper.ToCash(data.now_total_process) .. "/" .. StringHelper.ToCash(config.yjtz[data.now_lv].need)
	for i = data.now_lv + 1, #config.yjtz do
		self.YJTZChilds[i]:Find("Progress_bg/progress_mask").sizeDelta = {
			x = self.JDTlen * (data.now_total_process / config.yjtz[i].need),
			y = self.YJTZChilds[i]:Find("Progress_bg/progress_mask").rect.height
		}
		self.YJTZChilds[i]:Find("BFBText"):GetComponent("Text").text = StringHelper.ToCash(data.now_total_process) .. "/" .. StringHelper.ToCash(config.yjtz[i].need)
	end
	local sibling_index = 0
	for i = 1, #self.YJTZChilds do
		if b[i] == 0 then
			self.YJTZChilds[i].transform:Find("GOButton").gameObject:SetActive(true)
			self.YJTZChilds[i].transform:Find("LQButton").gameObject:SetActive(false)
			self.YJTZChilds[i].transform:Find("MASK").gameObject:SetActive(false)
			self.YJTZChilds[i]:Find("Progress_bg").gameObject:SetActive(true)
			self.YJTZChilds[i]:Find("BFBText").gameObject:SetActive(true)
		end
		if b[i] == 1 then
			self.YJTZChilds[i].transform:Find("GOButton").gameObject:SetActive(false)
			self.YJTZChilds[i].transform:Find("LQButton").gameObject:SetActive(true)
			self.YJTZChilds[i].transform:Find("MASK").gameObject:SetActive(false)
		end
		if b[i] == 2 then        
			self.YJTZChilds[i].transform:Find("GOButton").gameObject:SetActive(false)
			self.YJTZChilds[i].transform:Find("LQButton").gameObject:SetActive(false)
			self.YJTZChilds[i].transform:Find("MASK").gameObject:SetActive(true)
			self.YJTZChilds[i].transform:SetSiblingIndex(#self.YJTZChilds)
			self.YJTZChilds[i]:Find("Progress_bg").gameObject:SetActive(false)
			self.YJTZChilds[i]:Find("BFBText").gameObject:SetActive(false)
			if config.yjtz[i].isreal == 1 then
				self.YJTZChilds[i].transform:Find("SWLQButton").gameObject:SetActive(true)
				self.YJTZChilds[i].transform:Find("MASK").gameObject:SetActive(false)
				--self.YJTZChilds[i].transform:SetSiblingIndex(#self.YJTZChilds-sibling_index)
			else
				sibling_index = sibling_index + 1
				self.YJTZChilds[i].transform:Find("SWLQButton").gameObject:SetActive(false)
			end
		end
	end
	if VIPManager.get_vip_data() then
		self.YJTZCText.text = VIPManager.get_vip_data().vip_level
	else
		self.YJTZCText.text = ""
	end
end
function C:OnDestroy()
	self:MyExit()
end