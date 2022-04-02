local basefunc = require "Game/Common/basefunc"

Act_054_JZQFPanel = basefunc.class()
local C = Act_054_JZQFPanel
C.name = "Act_054_JZQFPanel"
local M = Act_054_JZQFManager
local config = 	Act_054_JZQFManager.config
function C.Create(parent)
	return C.New(parent)
end

local offset_data = {
	{min = 0,max = 69},
	{min = 9,max = 115},
	{min = 9,max = 115},
	{min = 9,max = 115},
	{min = 9,max = 115},
}

local max_size_x = 115
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
	self.lister["query_fake_data_response"] = basefunc.handler(self, self.AddPMD)
	self.lister["EnterBackGround"] = basefunc.handler(self, self.on_enter_back_ground)
end

function C:RemoveListener()
	for proto_name,func in pairs(self.lister) do
		Event.RemoveListener(proto_name, func)
	end
	self.lister = {}
end

function C:MyExit()
	if self.timer_pmd then
        self.timer_pmd:Stop()
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
	for i=1,5 do
		self["can"..i.."_get_btn"].gameObject:SetActive(false)
		self["mask"..i].gameObject:SetActive(false)
	end
	Network.SendRequest("query_one_task_data", {task_id = 21733})
	CommonTimeManager.GetCutDownTimer(M.endTime,self.remain_txt)
end

function C:RereshState()
	if M.GetItemCount(1) >= M.item1_consume_num * 10 then 
		self.state = 1
	elseif M.GetItemCount(1) >= M.item1_consume_num and M.GetItemCount(1) < M.item1_consume_num *10 then
		self.state = 2
	else
		self.state = 3
	end
end

function C:RefreshConsumeUI()

	self.lottery1_icon_img.gameObject:SetActive(false)
	self.lottery2_icon_img.gameObject:SetActive(false)
	self.lottery1_2_icon_img.gameObject:SetActive(false)
	self.lottery2_2_icon_img.gameObject:SetActive(false)

	if self.state == 1 then
		self.lottery1_icon_img.gameObject:SetActive(true)
		self.lottery2_icon_img.gameObject:SetActive(true)
		self.lottery1_num_txt.text = "x" .. M.item1_consume_num
		self.lottery2_num_txt.text = "x" .. M.item1_consume_num * 10
	elseif self.state == 2 then
		self.lottery1_icon_img.gameObject:SetActive(true)
		self.lottery2_2_icon_img.gameObject:SetActive(true)
		self.lottery1_num_txt.text = "x" .. M.item1_consume_num
		self.lottery2_num_txt.text = "x" .. (M.item2_consume_num /100) * 10
	else
		self.lottery1_2_icon_img.gameObject:SetActive(true)
		self.lottery2_2_icon_img.gameObject:SetActive(true)
		self.lottery1_num_txt.text = "x" .. (M.item2_consume_num /100)
		self.lottery2_num_txt.text = "x" .. (M.item2_consume_num /100) * 10
	end
end

function C:RefreshItemCount()
	self.hb_num_txt.text = "x" .. M.GetItemCount(2)/100
	self.xiang_num_txt.text = "x" .. M.GetItemCount(1)
end

function C:InitUI()
	self.lottery1_btn.onClick:AddListener(
		function ()
			self:Lottery1()
		end
	)
	self.lottery10_btn.onClick:AddListener(
		function ()
			self:Lottery10()
		end
	)

	self.more_gift_btn.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
			Act_054_JZQFMorePanel.Create()
		end
	)
	for i=1, 5 do
		self["can"..i.."_get_btn"].onClick:AddListener(
			function ()
				ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
				Network.SendRequest("get_task_award_new", {id = 21733, award_progress_lv = i})
				if config.TaskAward[i].real == 1 then 
					RealAwardPanel.Create({image = config.TaskAward[i].img,text = config.TaskAward[i].text})
				end 
			end
		)
		self["tip"..i.."_btn"].onClick:AddListener(
			function ()
				local cfg = M.config.Tips[i]
				LTTipsPrefab.Show2(self["tip"..i.."_btn"].transform,cfg[1],cfg[2])
			end
		)
	end
	-- self.help_btn.onClick:AddListener(
	-- 	function ()
	-- 		self:OpenHelpPanel()
	-- 	end
	-- )
	self.pmd_cont = CommonPMDManager.Create({ parent = self.pmd_node, speed = 18, space_time = 10, start_pos = 1000 })
	self:UpdatePMD()
	self:MyRefresh()
	--self:InitAwardTips()
end

function C:Lottery1()
	if (self.state == 1 or self.state == 2) and M.GetItemCount(1) < M.item1_consume_num then
		HintPanel.Create(1,"您的香不足！")
		return 
	end

	if self.state == 3 and M.GetItemCount(2) < M.item2_consume_num  then
		HintPanel.Create(1,"您的福卡不足！")
		return 
	end
	local _id = self.state == 3 and 185 or 184
	dump(_id,"<color=red>Id</color>")
	Network.SendRequest("box_exchange",{id = _id,num = 1})
end

function C:Lottery10()
	local _id
	if self.state == 1 and M.GetItemCount(1) < M.item1_consume_num * 10 then
		HintPanel.Create(1,"您的香不足！")
		return 
	end

	if (self.state == 2 or self.state == 3) and M.GetItemCount(2) < M.item2_consume_num * 10 then
		HintPanel.Create(1,"您的福卡不足！")
		return 
	end
	local _id = self.state == 1 and 184 or 185
	dump(_id,"<color=red>Id</color>")
	Network.SendRequest("box_exchange",{id = _id,num = 10})
end

function C:MyRefresh()
	self:RefreshLotteryUI()
end

function C:RefreshLotteryUI()
	self:RereshState()
	self:RefreshConsumeUI()
	self:RefreshItemCount()
end

function C:on_box_exchange_response(_,data)
	dump(data,"<color=red>----------抽奖数据-----------</color>")
	if data.result == 0 then
		self:AddMyPMD(data.award_id) --PMD Self
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
	if data and data.id == 21733 then
		--self.num_txt.text = data.now_total_process
		local b = basefunc.decode_task_award_status(data.award_get_status)
		b = basefunc.decode_all_task_award_status(b, data, 5)
		self:ReFreshProgress(data.now_lv,data.now_process,data.need_process,data.now_total_process)
		self:ReFreshTaskButtons(b)
		--elf.total_times_txt.text = "当前抽奖次数："..data.now_total_process
	end 
end

function C:on_model_query_one_task_data_response(data)
	dump(data,"<color=red>----------任务信息获得-----------</color>")
	if data and data.id == 21733 then
		--self.num_txt.text = data.now_total_process
		local b = basefunc.decode_task_award_status(data.award_get_status)
		b = basefunc.decode_all_task_award_status(b, data, 5)
		self:ReFreshProgress(data.now_lv,data.now_process,data.need_process,data.now_total_process)
		self:ReFreshTaskButtons(b)
		--self.total_times_txt.text = "当前抽奖次数："..data.now_total_process
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
	if data.change_type
	 and (data.change_type == "box_exchange_active_award_184" or data.change_type == "box_exchange_active_award_185")
	 and not table_is_null(data.data) then
		self.Award_Data = data
		self:TryToShow()
	end
end

function C:TryToShow()
	if self.Award_Data and self.call then
		self.call() 
		Event.Brocast("AssetGet",self.Award_Data)
		self:RefreshLotteryUI()
		self.Award_Data = nil
		self.call = nil 
	end 
end

function C:ReFreshTaskButtons(list)
	for i=1,#list do
		if list[i] == 0 then
			self["can"..i.."_get_btn"].gameObject:SetActive(false)
			self["tip"..i.."_btn"].gameObject:SetActive(true)
			self["mask"..i].gameObject:SetActive(false)
		end
		if list[i] == 1 then
			self["can"..i.."_get_btn"].gameObject:SetActive(true)
			self["tip"..i.."_btn"].gameObject:SetActive(false)
			self["mask"..i].gameObject:SetActive(false)
		end
		if list[i] == 2 then
			self["can"..i.."_get_btn"].gameObject:SetActive(false)
			self["tip"..i.."_btn"].gameObject:SetActive(false)
			self["mask"..i].gameObject:SetActive(true)
		end
	end
end

function C:ReFreshProgress(now_lv,cur_process,need_process,total_process)
	for i = 1, 5 do
		if i > now_lv then 
			self["p"..i].sizeDelta = {x = 0,y = max_size_y}
		end
		if i < now_lv then 
			self["p"..i].sizeDelta = {x = max_size_x,y = max_size_y}
		end
		if i == now_lv then 
			local rate = cur_process /need_process 
			local dis = offset_data[i].max - offset_data[i].min 
			self["p"..i].sizeDelta = {x = offset_data[i].min + dis * rate ,y = max_size_y}
		end
		if total_process < config.TaskAward[i].need  then
			self["pg"..i]:GetComponent("Text").text = total_process .. "/" .. config.TaskAward[i].need 
		else
			self["pg"..i]:GetComponent("Text").text = config.TaskAward[i].need .. "/" .. config.TaskAward[i].need 
		end
	end
end

function C:GetProgressX(percentage,o_d)
	return ((o_d.max - o_d.min) * percentage) + o_d.min
end

-- function C:OpenHelpPanel()
-- 	local str = config.DESCRIBE_TEXT[1].text
-- 	for i = 2, #config.DESCRIBE_TEXT do
-- 		str = str .. "\n" .. config.DESCRIBE_TEXT[i].text
-- 	end
-- 	self.introduce_txt.text = str
-- 	IllustratePanel.Create({ self.introduce_txt.gameObject }, GameObject.Find("Canvas/LayerLv5").transform)
-- end

function C:OnDestroy()
	self:MyExit()
end

function C:UpdatePMD()

    if self.timer_pmd then
        self.timer_pmd:Stop()
    end
    Network.SendRequest("query_fake_data", { data_type = "act_043_sdcdj" })
    self.timer_pmd = Timer.New(
        function()
            --dump("<color=red>-------------------------------------------   query_fake_data-------------------------------------------------</color>")
			Network.SendRequest("query_fake_data", { data_type = "act_043_sdcdj" })
		end
    , 20, -1)
    self.timer_pmd:Start()
end


function C:AddMyPMD(data)
	if table_is_null(data) then return end
	if not self.Award_Data then return end
    local _data_info = self.Award_Data.data
	local _data = data
	local type2str = {
		shop_gold_sum = "福卡",
		prop_50y = ""
	}
    for i = 1, #_data_info do
        local cur_data_info = self:GetConfigByServerID(_data[i])
        if cur_data_info ~= nil then
            local cur_data_pmd = {}
            cur_data_pmd["result"] = 0
			cur_data_pmd["player_name"] = MainModel.UserInfo.name
			if cur_data_info.real == 1 then
				cur_data_pmd["award_data"] = tostring(cur_data_info.text)
			else
				if _data_info[i].asset_type == "shop_gold_sum" then
					cur_data_pmd["award_data"] = _data_info[i].value/100 .. tostring(GameItemModel.GetItemToKey(_data_info[i].asset_type).name)
				else
					cur_data_pmd["award_data"] = _data_info[i].value .. tostring(GameItemModel.GetItemToKey(_data_info[i].asset_type).name)
				end
			end
            self:AddPMD(0, cur_data_pmd)
        end
    end
end

function C:AddPMD(_, data)
    dump(data, "<color=red>PMD</color>")
    if not IsEquals(self.gameObject) then return end
    if data and data.result == 0 then
        local b = GameObject.Instantiate(self.pmd_item, self.pmd_node)
        b.gameObject:SetActive(true)
        local temp_ui = {}
        LuaHelper.GeneratingVar(b.transform, temp_ui)
        temp_ui.t1_txt.text = "恭喜" .. data.player_name .. "先祖保佑，抽中" .. data.award_data .. "奖品"
        UnityEngine.UI.LayoutRebuilder.ForceRebuildLayoutImmediate(b.transform)
        self.pmd_cont:AddObj(b)
    end
end

function C:on_enter_back_ground()
	if self.timer_pmd then
        self.timer_pmd:Stop()
    end
end
