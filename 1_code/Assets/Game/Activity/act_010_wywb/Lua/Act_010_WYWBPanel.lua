local basefunc = require "Game/Common/basefunc"

Act_010_WYWBPanel = basefunc.class()
local C = Act_010_WYWBPanel
C.name = "Act_010_WYWBPanel"
local M = Act_010_WYWBManager
local config
function C.Create(parent)
	return C.New(parent)
end
local hide_time = 17
local Wait_Broadcast_data = {}
local Wait_OBj
local Loop_Order = {"RollPrefab1","RollPrefab2","RollPrefab3"}
local hide_left_pos = -1300
local space = 1100

local offset_data = {
	{min = 0,max = 45.12},
	{min = 10.88,max = 59.61},
	{min = 6.88,max = 58.96},
	{min = 9.35,max = 59.52},
	{min = 13.26,max = 62.52},
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
	self.lister["Act_010_wywb_Broadcast_Info"] = basefunc.handler(self,self.on_Act_010_wywb_Broadcast_Info)
end

function C:RemoveListener()
	for proto_name,func in pairs(self.lister) do
		Event.RemoveListener(proto_name, func)
	end
	self.lister = {}
end

function C:MyExit()
	for i = 1,#self.timer do 
		if self.timer[i] then 
			self.timer[i]:Stop()
		end
	end
	if self.Cheak_Timer then 
		self.Cheak_Timer:Stop()
	end
	if self.DelayToShow_Timer then
		self.DelayToShow_Timer:Stop()
	end
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor(parent)

	ExtPanel.ExtMsg(self)

	local parent = parent or GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self.timer = {}
	config = M.config
	for i=1,5 do
		self["can"..i.."_get_btn"].gameObject:SetActive(false)
		self["mask"..i].gameObject:SetActive(false)
		self["award"..i.."_txt"].text = config.TaskAward[i].text
		self["task"..i.."_need_txt"].text = config.TaskAward[i].need.."次"
		self["award"..i.."_img"].sprite = GetTexture(config.TaskAward[i].img)
	end
	Network.SendRequest("query_one_task_data", {task_id = M.task_id})
	for i=1,#Loop_Order do
		self:LoopAnim(self[Loop_Order[i]])
	end
	self.curr_chan_txt.text = "x"..GameItemModel.GetItemCount("prop_shovel")
end

function C:InitUI()
	self.lottery1_btn.onClick:AddListener(
		function ()
			if GameItemModel.GetItemCount("prop_shovel") < 2 then 
				HintPanel.Create(1,"您的铲子不足！",function()
					ActivityYearPanel.Create(nil, nil, { ID =  68}, true)
				end)
			else
				Network.SendRequest("box_exchange",{id = M.box_id,num = 1})
			end 
		end
	)
	self.lottery10_btn.onClick:AddListener(
		function ()
			if GameItemModel.GetItemCount("prop_shovel") < 20 then 
				HintPanel.Create(1,"您的铲子不足！",function()
					ActivityYearPanel.Create(nil, nil, { ID =  68}, true)
				end)
			else
				Network.SendRequest("box_exchange",{id = M.box_id,num = 10})
			end 
		end
	)
	self.show_list_btn.onClick:AddListener(
		function ()
			--YCS_CSSLListPanel.Create()
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
			Act_010_WYWBMorePanel.Create()
		end
	)
	for i=1, 5 do
		self["can"..i.."_get_btn"].onClick:AddListener(
			function ()
				ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
				Network.SendRequest("get_task_award_new", {id = M.task_id, award_progress_lv = i})
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
	if data and data.id == M.task_id then
		--self.num_txt.text = data.now_total_process
		local b = basefunc.decode_task_award_status(data.award_get_status)
		b = basefunc.decode_all_task_award_status(b, data, 5)
		self:ReFreshProgress(data.now_total_process)
		self:ReFreshTaskButtons(b)
		self.total_times_txt.text = "当前挖宝次数："..data.now_total_process
	end 
end

function C:on_model_query_one_task_data_response(data)
	dump(data,"<color=red>----------任务信息获得-----------</color>")
	if data and data.id == M.task_id then
		--self.num_txt.text = data.now_total_process
		local b = basefunc.decode_task_award_status(data.award_get_status)
		b = basefunc.decode_all_task_award_status(b, data, 5)
		self:ReFreshProgress(data.now_total_process)
		self:ReFreshTaskButtons(b)
		self.total_times_txt.text = "当前挖宝次数："..data.now_total_process
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
	if data.change_type and data.change_type == "box_exchange_active_award_"..M.box_id and not table_is_null(data.data) then
		self.Award_Data = data
		self:TryToShow()
		self.curr_chan_txt.text = "x"..GameItemModel.GetItemCount("prop_shovel")
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
	dump(list,"1111111111111111111111111111111111")
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
			self["p"..i].sizeDelta = {x = max_size_x,y = max_size_y}
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
	
	local help_info = self:CheakIsNormal() and config.Normal or config.Cpl
	dump(help_info)
	local str = help_info[1].text
	for i = 2, #help_info do
		str = str .. "\n" .. help_info[i].text
	end
	self.introduce_txt.text = str
	IllustratePanel.Create({ self.introduce_txt.gameObject }, GameObject.Find("Canvas/LayerLv5").transform)
end

function C:OnDestroy()
	self:MyExit()
end

--跑马灯UI 
function C:CheakNode()
	local ht = hide_time
	if self.DelayToShow_Timer then
		self.DelayToShow_Timer:Stop()
	end
	self.DelayToShow_Timer = Timer.New(
		function ()
			self.UINode.gameObject:SetActive(true)
		end
	,7,1) 
	self.DelayToShow_Timer:Start()
	if self.Cheak_Timer then 
		self.Cheak_Timer:Stop()
	end
	for i = 1,#self.timer do 
		if self.timer[i] then 
			self.timer[i]:Start()
		end
	end
	self.Cheak_Timer = Timer.New(
		function()
			ht = ht - 0.1
			if ht <= 0 then 
				ht = 9999999
				self.UINode.gameObject:SetActive(false)
				self:SetPos()
				for i = 1,#self.timer do 
					if self.timer[i] then 
						self.timer[i]:Stop()
					end
				end
			end 
		end 
	,0.1,-1)
	self.Cheak_Timer:Start()
end

function C:SetPos()
	for i=1,#Loop_Order do
		self[Loop_Order[i]].transform.localPosition = Vector3.New(hide_left_pos + space * (i - 1) + 2,0,0)
	end
end

function C:LoopAnim(obj)
	local temp_ui = {}
	self.timer[#self.timer + 1] = Timer.New(function ()
        obj.transform:Translate(Vector3.left * 3)
		if obj.transform.localPosition.x <= hide_left_pos then
			LuaHelper.GeneratingVar(obj.transform, temp_ui)
			temp_ui.info_txt.text = ""
			obj.transform.localPosition = Vector3.New(hide_left_pos + space * #Loop_Order,0,0)
			if self:GetWaitData() then
				temp_ui.info_txt.text = "恭喜玩家<color=#4eea3d>"..self:GetWaitData().playname.."</color>通过挖宝,获得<color=#ff9257>"..self:GetWaitData().awardname.."</color>"
				self:RemoveWaitData()
			end
        end
	end,0.02,-1,nil,true)
	self:SetPos()
end

function C:AddWaitData(data)
	self:CheakNode()
    table.insert(Wait_Broadcast_data,1,data)
end

function C:RemoveWaitData()
    table.remove(Wait_Broadcast_data,#Wait_Broadcast_data)
end

function C:GetWaitData()
	return Wait_Broadcast_data[#Wait_Broadcast_data]
end

function C:on_Act_010_wywb_Broadcast_Info(data)
    self:AddWaitData(data)
end
--检查是不是官方渠道
function C:CheakIsNormal()
	local _permission_key = "actp_own_task_p_digging_treasure"
	if _permission_key then
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=_permission_key, is_on_hint = true}, "CheckCondition")
        if a and not b then
            return false
        end
        return true
    else
        return true
    end
end