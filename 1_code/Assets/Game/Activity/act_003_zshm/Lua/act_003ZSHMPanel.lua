local basefunc = require "Game/Common/basefunc"

Act_003ZSHMPanel = basefunc.class()
local C = Act_003ZSHMPanel
C.name = "Act_003ZSHMPanel"
local config = 	Act_003ZSHMManager.config
function C.Create(parent,backcall)
	return C.New(parent,backcall)
end

local offset_data = {
	{min = 0,max = 49.39},
	{min = 20.6,max = 114.92},
	{min = 12.02,max = 109.2},
	{min = 18,max = 111.27},
	{min = 27.3,max = 121},
}

local max_size_x = 70
local max_size_y = 21.08
function C:AddMsgListener()
	for proto_name,func in pairs(self.lister) do
		Event.AddListener(proto_name, func)
	end
end

function C:MakeLister()
	self.lister = {}
	self.lister["box_exchange_response"] = basefunc.handler(self,self.on_box_exchange_response)
	self.lister["model_task_change_msg"] = basefunc.handler(self,self.on_model_task_change_msg)
	self.lister["model_query_one_task_data_response"] = basefunc.handler(self,self.on_model_query_one_task_data_response)
	self.lister["AssetChange"] = basefunc.handler(self, self.OnAssetChange)
end

function C:RemoveListener()
	for proto_name,func in pairs(self.lister) do
		Event.RemoveListener(proto_name, func)
	end
	self.lister = {}
end

function C:MyExit()
	if self.timer then 
		self.timer:Stop()
	end

	if self.anim_timer then 
		self.anim_timer:Stop()
	end
	if self.backcall then 
		self.backcall()
	end
	self:RemoveListener()
	destroy(self.gameObject)

	 
end

function C:ctor(parent,backcall)
	ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Canvas/LayerLv3").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.backcall = backcall
	LuaHelper.GeneratingVar(self.transform, self)
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	for i=1,5 do
		self["can"..i.."_get_btn"].gameObject:SetActive(false)
		self["mask"..i].gameObject:SetActive(false)
	end
	self.animator = self.transform:Find("Act_003ZSHMPanel_jiaoshui"):GetComponent("Animator")
	self.animator:Play("Act_003ZSHMPanel_tz")
	Network.SendRequest("query_one_task_data", {task_id = Act_003ZSHMManager.task_id})
end

function C:InitUI()
	self.lottery1_btn.onClick:AddListener(
		function ()
			if  MainModel.GetHBValue() < 1 then 
				HintPanel.Create(1,"您的福卡不足！")
			else	
				self:PlayAnim(function ()
					Network.SendRequest("box_exchange",{id = 14,num = 1})
				end)				
			end 
		end
	)
	self.lottery10_btn.onClick:AddListener(
		function ()
			if MainModel.GetHBValue() < 10 then 
				HintPanel.Create(1,"您的福卡不足！")
			else
				self:PlayAnim(function ()
					Network.SendRequest("box_exchange",{id = 14,num = 10})
				end)
			end 
		end
	)
	self.show_list_btn.onClick:AddListener(
		function ()
			Act_003ZSHMListPanel.Create()
		end
	)
	self.close_btn.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
			self:MyExit()
		end
	)
	self.more_gift_btn.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
			Act_003ZSHMMorePanel.Create()
		end
	)
	for i=1, 5 do
		self["can"..i.."_get_btn"].onClick:AddListener(
			function ()
				ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
				Network.SendRequest("get_task_award_new", {id = Act_003ZSHMManager.task_id, award_progress_lv = i})
				if config.TaskAward[i].real == 1 then 
					RealAwardPanel.Create({image = config.TaskAward[i].img,text = config.TaskAward[i].text})
				end 
			end
		)
	end
	self.help_btn.onClick:AddListener(
		function ()
			self:OpenHelpPanel()
		end
	)
	self:MyRefresh()
end

function C:MyRefresh()
end

function C:on_box_exchange_response(_,data)
	dump(data,"<color=red>----------抽奖数据-----------</color>")
	if data.result == 0 then
		local real_list = self:GetRealInList(data.award_id)
		dump(real_list,"<color=red>-------实物奖励------</color>")
		if self:IsAllRealPop(data.award_id,real_list) then 
			RealAwardPanel.Create(self:GetShowData(real_list))
		else
			self.call = function ()
				if not table_is_null(real_list) then 
					MixAwardPopManager.Create(self:GetShowData(real_list),nil,2)
				end
			end 
		end
		self:TryToShow()
	end 
end

function C:on_model_task_change_msg(data)
	dump(data,"<color=red>----------任务改变-----------</color>")
	if data and data.id == Act_003ZSHMManager.task_id then
		--self.num_txt.text = data.now_total_process
		local b = basefunc.decode_task_award_status(data.award_get_status)
		b = basefunc.decode_all_task_award_status(b, data, 5)
		self:ReFreshProgress(data.now_total_process)
		self:ReFreshTaskButtons(b)
		self.total_times_txt.text = "当前："..data.now_total_process.."次"
	end 
end

function C:on_model_query_one_task_data_response(data)
	dump(data,"<color=red>----------任务信息获得-----------</color>")
	if data and data.id == Act_003ZSHMManager.task_id then
		--self.num_txt.text = data.now_total_process
		local b = basefunc.decode_task_award_status(data.award_get_status)
		b = basefunc.decode_all_task_award_status(b, data, 5)
		self:ReFreshProgress(data.now_total_process)
		self:ReFreshTaskButtons(b)
		self.total_times_txt.text = "当前："..data.now_total_process.."次"
	end 
end
--在奖励列表里面获取实物奖励的ID
function C:GetRealInList(award_id)
	local r_list = {}
	local temp
	for i=1,#award_id do
		temp = self:GetConfigByServerID(award_id[i])
		if temp.real == 1 then 
			r_list[#r_list + 1] = temp
		end
	end
	return r_list
end
--根据ID获取配置信息
function C:GetConfigByServerID(server_award_id)
	for i=1,#config.Award do
		if config.Award[i].server_award_id == server_award_id then 
			return config.Award[i]
		end 
	end
end
--如果全都是实物奖励，就直接用 realawardpanel
function C:IsAllRealPop(award_id,real_list)
	if #real_list >= #award_id then 
		return true
	else
		return false
	end 
end
--把配置数据转换为奖励展示面板所需要的数据格式
function C:GetShowData(real_list)
	local data = {}
	data.text = {}
	data.image = {}
	for i=1,#real_list do
		data.text[#data.text + 1] = real_list[i].text
		data.image[#data.image + 1] = real_list[i].img
	end
	return data
end

function C:OnAssetChange(data)
	dump(data,"<color=red>----奖励类型-----</color>")
	if data.change_type and data.change_type == "box_exchange_active_award_14" and not table_is_null(data.data) then
		self.Award_Data = data
		self:TryToShow()
	end
end

function C:TryToShow()
	if self.Award_Data and self.call then
		self.call() 
		Event.Brocast("AssetGet",self.Award_Data)
		self.Award_Data = nil
		self.call = nil 
	end 
end

function C:ReFreshTaskButtons(list)
	for i=1,#list do
		if list[i] == 0 then
			self["can"..i.."_get_btn"].gameObject:SetActive(false)
			self["mask"..i].gameObject:SetActive(false)
		end
		if list[i] == 1 then
			self["can"..i.."_get_btn"].gameObject:SetActive(true)
			self["mask"..i].gameObject:SetActive(false)
		end
		if list[i] == 2 then
			self["can"..i.."_get_btn"].gameObject:SetActive(false)
			self["mask"..i].gameObject:SetActive(true)
		end
	end
end

function C:ReFreshProgress(total)
	local nowlv = 1
	while config.TaskAward[nowlv].need <= total and nowlv < 5 do
		nowlv = nowlv + 1
	end
	for i = 1, 5 do
		if i > nowlv then 
			self["p"..i].sizeDelta = {x = 0,y = max_size_y}
		end
		if i < nowlv then 
			self["p"..i].sizeDelta = {x = offset_data[i].max,y = max_size_y}
		end
		if i == nowlv then
			self["p"..i].sizeDelta = {x = self:GetProgressX(self:GetCurrPercentage(nowlv,total),offset_data[i]),y = max_size_y}
		end
	end
end

function C:GetCurrPercentage(nowlv,total)
	local lastLevelNeed = nowlv > 1 and config.TaskAward[nowlv - 1].need or 0
	return (total - lastLevelNeed)/(config.TaskAward[nowlv].need - lastLevelNeed)
end

function C:GetProgressX(percentage,o_d)
	return ((o_d.max - o_d.min) * percentage) + o_d.min
end

function C:OpenHelpPanel()
	local str = config.DESCRIBE_TEXT[1].text
	for i = 2, #config.DESCRIBE_TEXT do
		str = str .. "\n" .. config.DESCRIBE_TEXT[i].text
	end
	self.introduce_txt.text = str
	IllustratePanel.Create({ self.introduce_txt.gameObject }, GameObject.Find("Canvas/LayerLv5").transform)
end

function C:OnDestroy()
	self:MyExit()
end

function C:PlayAnim(call)
	self.animator:Play("Act_003ZSHMPanel_jiaoshui")
	if self.anim_timer then 
		self.anim_timer:Stop()
	end
	self.anim_timer = Timer.New(function()
		self.animator:Play("Act_003ZSHMPanel_tz")
		if call then 
			call()
		end
	end,1.6,1)
	self.anim_timer:Start()
end