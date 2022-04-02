-- 创建时间:2019-12-02
-- Panel:ActivityFKSSEPanel
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

ActivityFKSSEPanel = basefunc.class()
local C = ActivityFKSSEPanel
C.name = "ActivityFKSSEPanel"
local config = 	FKSSEManager.config
function C.Create()
	return C.New()
end

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
	self:RemoveListener()
	destroy(self.gameObject)

	 
end

function C:ctor()

	ExtPanel.ExtMsg(self)

	local parent = GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	Network.SendRequest("query_one_task_data", {task_id = 21031})
end

function C:InitUI()
	self.lottery1_btn.onClick:AddListener(
		function ()
			if MainModel.GetHBValue() < 2 then 
				HintPanel.Create(1,"您的福卡不足！")
			else
				Network.SendRequest("box_exchange",{id = 3,num = 1})
			end 
		end
	)
	self.lottery5_btn.onClick:AddListener(
		function ()
			if MainModel.GetHBValue() < 20 then 
				HintPanel.Create(1,"您的福卡不足！")
			else
				Network.SendRequest("box_exchange",{id = 3,num = 10})
			end 
		end
	)
	self.show_list_btn.onClick:AddListener(
		function ()
			FKSSEListPanel.Create()
		end
	)
	self.close_btn.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
			self:MyExit()
		end
	)
	for i=1, 5 do
		self["can"..i.."_get_btn"].onClick:AddListener(
			function ()
				ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
				Network.SendRequest("get_task_award_new", {id = 21031, award_progress_lv = i})
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
	if data and data.id == 21031 then
		--self.num_txt.text = data.now_total_process
		local b = basefunc.decode_task_award_status(data.award_get_status)
		b = basefunc.decode_all_task_award_status(b, data, 5)
		self:ReFreshProgress(data.now_total_process)
		self:ReFreshTaskButtons(b)
	end 
end

function C:on_model_query_one_task_data_response(data)
	dump(data,"<color=red>----------任务信息获得-----------</color>")
	if data and data.id == 21031 then
		--self.num_txt.text = data.now_total_process
		local b = basefunc.decode_task_award_status(data.award_get_status)
		b = basefunc.decode_all_task_award_status(b, data, 5)
		self:ReFreshProgress(data.now_total_process)
		self:ReFreshTaskButtons(b)
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
	if data.change_type and data.change_type == "box_exchange_active_award_3" and not table_is_null(data.data) then
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
    local str = config.DESCRIBE_TEXT[1].text
    for i = 2, #config.DESCRIBE_TEXT do
        str = str .. "\n" .. config.DESCRIBE_TEXT[i].text
    end
    self.introduce_txt.text = str
    IllustratePanel.Create({ self.introduce_txt.gameObject }, GameObject.Find("Canvas/LayerLv5").transform)
end
