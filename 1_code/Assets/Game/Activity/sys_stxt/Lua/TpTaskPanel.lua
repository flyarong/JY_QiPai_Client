local basefunc = require "Game/Common/basefunc"

TpTaskPanel = basefunc.class()
local C = TpTaskPanel
C.name = "TpTaskPanel"
local max_progress_x = 738.8
local max_progress_y = 26
local t_task = SYSSTXTManager.master_daily_task_server  
local p_task = SYSSTXTManager.task_master_daily_server 
function C.Create(parent,task_data,TeacherORPupil,p_id)
	return C.New(parent,task_data,TeacherORPupil,p_id)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
	self.lister = {}
	self.lister["model_task_change_msg"] = basefunc.handler(self, self.on_model_task_change_msg)
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

function C:ctor(parent,task_data,TeacherORPupil,p_id)

	ExtPanel.ExtMsg(self)

	local parent = parent or GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	dump(task_data,"<color=red>组装好的数据</color>")
	self.transform = tran
	self.gameObject = obj
	self.task_data = task_data
	self.task_id = task_data.id
	self.p_id = p_id
	self.TeacherORPupil = TeacherORPupil
	LuaHelper.GeneratingVar(self.transform, self)
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self:R_task_ui(self.task_data)
end

function C:InitUI()
	self.close_btn.onClick:AddListener(
		function ()
			self:MyExit()
		end
	)
	self:MyRefresh()
end

function C:MyRefresh()
	
end

function C:on_model_task_change_msg(data)
	if data and data.id == self.task_id then 
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:MyExit()
	end 
end

function C:GetInfoByConfig()
	self.message_txt.text = self:GetTaskName(self.task_id)
	local data
	if self.TeacherORPupil == "Teacher" then
		data = self:GetTeacherAwardInfo(self.task_id)
	end
	if self.TeacherORPupil == "Pupil" then 
	 	data = self:GetPupilAwardInfo(self.task_id)
	end
	dump(data,"<color=red>----任务UI数据----</color>")
	self:InitTaskAward_UI(data)
end

function C:GetTaskName(task_id)
	if p_task.task[task_id] then
		return p_task.task[task_id].name
	end 
end

function C:GetTeacherAwardInfo(task_id)
	local data 
	for k,v in pairs(t_task.master_daily_task) do
		if v.task_id == task_id then 
			data = v
		end 
	end
	if data then 
		for k,v in pairs(t_task.master_award) do
			if v.award_id == data.master_award_id then 
				return v
			end 
		end
	end  
end

function C:GetPupilAwardInfo(task_id)
	for k,v in pairs(p_task.award_data) do
		if v.award_id == task_id then 
			return v
		end 
	end   
end

function C:InitTaskAward_UI(data)
	local temp_ui = {}
	if typeof(data.asset_type) == "table" then 
		for i=1,#data.asset_type do
			local item =  GameItemModel.GetItemToKey(data.asset_type[i])
			local b = GameObject.Instantiate(self.award_item,self.Content)
			b.gameObject:SetActive(true)
			LuaHelper.GeneratingVar(b.transform, temp_ui)
			temp_ui.award_img.sprite = GetTexture(item.image)
			if data.asset_type[i] == "shop_gold_sum" then 
				temp_ui.award_txt.text = (data.asset_count[i] / 100)..item.name
			else
				temp_ui.award_txt.text = data.asset_count[i]..item.name
			end 
		end
	else
		local item =  GameItemModel.GetItemToKey(data.asset_type)
		local b = GameObject.Instantiate(self.award_item,self.Content)
		b.gameObject:SetActive(true)
		LuaHelper.GeneratingVar(b.transform, temp_ui)
		temp_ui.award_img.sprite = GetTexture(item.image)
		if data.asset_type == "shop_gold_sum" then 
			temp_ui.award_txt.text = (data.asset_count / 100)..item.name
		else
			temp_ui.award_txt.text = data.asset_count..item.name
		end
	end 
end

function C:R_task_ui(data)
	if data  then
		local award_status = self.TeacherORPupil == "Pupil" and  data.award_status or  (data.master_task_status and  data.master_task_status.master_is_can_get_award or 0)
		local v = tonumber(data.now_process/data.need_process)
		self.progress_img.gameObject.transform.sizeDelta = {x = max_progress_x * v,y = max_progress_y}
		self.progress_txt.text = data.now_process.."/"..data.need_process
		dump(data,"<color=red>任务数据---------------</color>")
		if award_status == 1 then 
			self.confirm_txt.text = "领  取"
			self.confirm_btn.gameObject.transform:GetComponent("Image").sprite = GetTexture("com_btn_5")
		elseif award_status == 2 then
			self.confirm_txt.text = "已领取"
			self.confirm_btn.gameObject.transform:GetComponent("Image").sprite = GetTexture("com_btn_8")
		else
			self.confirm_txt.text = "确  定"
			self.confirm_btn.gameObject.transform:GetComponent("Image").sprite = GetTexture("com_btn_7")
		end 
		self.award_status  = award_status
		self.confirm_btn.onClick:RemoveAllListeners()
		if award_status ~= 1 then 
			self.confirm_btn.onClick:AddListener(
				function ()
					ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
					self:MyExit()
				end
			)
		else
			self.confirm_btn.onClick:AddListener(
				function ()
					ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
					if self.TeacherORPupil == "Pupil" then 
						Network.SendRequest("get_task_award", {id = data.id})
						self.confirm_txt.text = "已领取"
						data.award_status = 2
						self.confirm_btn.gameObject.transform:GetComponent("Image").sprite = GetTexture("com_btn_8")			
					else
						Network.SendRequest("get_everyday_task_awards",{apprentice_id = self.p_id})
						self.confirm_txt.text = "已领取"
						data.master_task_status.master_is_can_get_award = 2
						self.confirm_btn.gameObject.transform:GetComponent("Image").sprite = GetTexture("com_btn_8")			
					end 
					Event.Brocast("tp_CloseTHENOpen")			
				end
			)
		end 
	else
		self.confirm_btn.onClick:RemoveAllListeners()
		self.confirm_txt.text = "确  定"
		self.confirm_btn.onClick:AddListener(
			function ()
				ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
				self:MyExit()
			end
		)
	end 	
	self:GetInfoByConfig()
end