-- 创建时间:2020-12-07
-- Panel:Template_NAME
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

Act_043_SDCDJPanel = basefunc.class()
local C = Act_043_SDCDJPanel
C.name = "Act_043_SDCDJPanel"
local M = Act_043_SDCDJManager
map = {14,13,12,4,11,6,2,10,9,8,3,7,5,1}
local offset = {
	0,10,50,100,200,500
}
local tips_1 = {
	"OPPO手机",
	"OPPO手环",
	"小麻花",
	"纯棉长袜",
	"50福卡赛门票",
	"10元优惠券",
	"福卡",
	"鲸币",
	"特殊鱼币",
	"话费碎片",
	"福卡",
	"鲸币",
	"鱼币",
	"话费碎片",
}
local tips_2 = {
	"Reno4 SE",
	"OPPO Band oppoband手环",
	"网红休闲零食",
	"纯棉长袜5双",
	"可参与50福卡赛",
	"充值商城中可使用",
	"随机获得1~5福卡",
	"随机获得10000~30000鲸币",
	"随机获得20000~50000鱼币",
	"随机获得100~300话费碎片",
	"随机获得0.3~2福卡",
	"随机获得3000~10000鲸币",
	"随机获得3000~10000鱼币",
	"随机获得30~100话费碎片",
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
	self.lister["model_task_change_msg"] = basefunc.handler(self, self.on_model_task_change_msg)
    self.lister["model_query_one_task_data_response"] = basefunc.handler(self, self.on_model_query_one_task_data_response)
	self.lister["box_exchange_response"] = basefunc.handler(self,self.on_box_exchange_response)
	self.lister["AssetChange"] = basefunc.handler(self,self.on_AssetChange)
	self.lister["query_fake_data_response"] = basefunc.handler(self, self.AddPMD)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.UpdatePMD then
        self.UpdatePMD:Stop()
    end
	self.MainAnim:MyExit()
	self:TryToShow()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:ctor(parent)
	ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	Network.SendRequest("query_one_task_data", { task_id = M.task_id })
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	local temp_items = {}
	for i = 1,14 do
		temp_items[#temp_items + 1] = self["lottery_item"..i]
	end
	self.MainAnim = CommonLotteryAnim.Create(temp_items, function (obj,pos)
		for i = 1,#temp_items do
			local show = temp_items[i].transform:Find("fqj_kuang")
			show.gameObject:SetActive(false)
		end
		local show = obj.transform:Find("fqj_kuang")
		show.gameObject:SetActive(true)
	end)
	self.help_btn.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			self:OpenHelpPanel()
		end
	)
	self.Anims = {}
	for i = 1,5 do
		self.Anims[#self.Anims + 1] = CommonHuxiAnim.Go(self["task_award"..i.."_img"].gameObject,0.9,1,1.3)
		self["task_award"..i.."_btn"].onClick:AddListener(
			function()
				local data = GameTaskModel.GetTaskDataByID(M.task_id)
				if data then
					local b = basefunc.decode_task_award_status(data.award_get_status)
					b = basefunc.decode_all_task_award_status(b, data, 5)
					if b[i] == 1 then
						Network.SendRequest("get_task_award_new", { id = M.task_id, award_progress_lv = i })
						if i == 5 then
							RealAwardPanel.Create({image = "activity_icon_gift251_jly",text = "食用油"})
						end
					end
				end
			end
		)
	end
	self.lottery1_btn.onClick:AddListener(
		function () 
			if self.lock then return end
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			if M.GetCurrIndex(1) == 1 then
				self.lock = true
				Network.SendRequest("box_exchange",{id = M.box_ids[M.GetCurrIndex(1)],num = 1})				
			else
				if GameItemModel.GetItemCount("shop_gold_sum")/100 >= 2 then
					self.lock = true
					Network.SendRequest("box_exchange",{id = M.box_ids[M.GetCurrIndex(1)],num = 1})				
				else
					LittleTips.Create("福卡不足")
				end
			end
		end
	)
	self.lottery10_btn.onClick:AddListener(
		function ()
			if self.lock then return end
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			if M.GetCurrIndex(10) == 1  then
				self.lock = true
				Network.SendRequest("box_exchange",{id = M.box_ids[M.GetCurrIndex(10)],num = 10})				
			else
				if GameItemModel.GetItemCount("shop_gold_sum")/100 >= 20 then
					self.lock = true
					Network.SendRequest("box_exchange",{id = M.box_ids[M.GetCurrIndex(10)],num = 10})				
				else
					LittleTips.Create("福卡不足")
				end
			end
		end
	)
	EventTriggerListener.Get(self.task_award5_btn.gameObject).onClick = function()
		self:CreateTips(self.task_award5_btn.gameObject.transform,"食用油","金龙鱼精炼一级大豆油")
	end
	EventTriggerListener.Get(self.task_award5_img.gameObject).onClick = function()
		self:CreateTips(self.task_award5_img.gameObject.transform,"食用油","金龙鱼精炼一级大豆油")
	end
	self:InitMainUI()
	self:MyRefresh()
    self.pmd_cont = CommonPMDManager.Create({ parent = self.pmd_node, speed = 18, space_time = 10, start_pos = 1000 })
	self:UpDatePMD()
end

function C:InitMainUI()
	for i = 1,#M.config.Award1 do
		EventTriggerListener.Get(self["award"..i.."_img"].gameObject).onDown = function()
			self:CreateTips(self["award"..i.."_img"].gameObject.transform,tips_1[map[i]],tips_2[map[i]])
		end
		EventTriggerListener.Get(self["award"..i.."_img"].gameObject).onUp = function()
			self.tip_item.transform.gameObject:SetActive(false)
		end
		self["award"..i.."_img"].gameObject.transform.localScale = Vector3.New(0.8,0.8,0.8)
		self["award"..i.."_img"].sprite = GetTexture(M.config.Award1[map[i]].img)
	end
end

function C:CreateTips(transform,title,desc)
	local str = title..":" .. "\n--------------".."\n"..desc
	LTTipsPrefab.Show2(transform,title,desc)
	-- self.tips_tit_txt.text = title
	-- self.tips_desc_txt.text = desc
	-- self.tip_item.transform.parent = transform
	-- self.tip_item.transform.localPosition = Vector3.zero
	-- self.tip_item.transform.gameObject:SetActive(true)
end

function C:MyRefresh()
	self.lottery_num_txt.text = "x"..GameItemModel.GetItemCount(M.lottery_key)
	--使用抽奖券
	if M.GetCurrIndex(1) == 1 then
		self.lottery1_txt.text = "消耗4抽奖券"
	else
		self.lottery1_txt.text = "消耗2福卡"
	end
	if M.GetCurrIndex(10) == 1 then
		self.lottery10_txt.text = "消耗40抽奖券"
	else
		self.lottery10_txt.text = "消耗20福卡"
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
	local config = M.config
	for i=1,#config.Award1 do
		if config.Award1[i].server_award_id == server_award_id then 
			return config.Award1[i]
		end 
	end
	for i=1,#config.Award2 do
		if config.Award2[i].server_award_id == server_award_id then 
			return config.Award2[i]
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

function C:RefreshNum(total)
	for i = 1,5 do
		local num = total >= offset[i + 1] and  offset[i + 1] or total
		self["task"..i.."_txt"].text = num.."/"..offset[i + 1]
	end
end

function C:ReFreshTaskButtons(list)
	for i = 1,#list do
		if list[i] == 1 then
			self.Anims[i].Start()
		else
			self.Anims[i].Stop()
		end
		self["mask"..i].gameObject:SetActive(list[i] == 2)
	end
end

function C:ReFreshProgress(total)
	local len = {
		[1] = {min = 0,max = 66.71},
		[2] = {min = 107.58,max = 235.98},
		[3] = {min = 279.8,max = 408.37},
		[4] = {min = 447.73,max = 577.65},
		[5] = {min = 620.21,max = 779.29},
	}
	local now_level = 1
	for i = #offset,1,-1 do
		if total >= offset[i] then
			now_level = i
			break
		end
	end
	if now_level > 5 then
		self.progress.sizeDelta={x = len[#len].max,y = 29.78}
	else
		local now_need = offset[now_level + 1] - offset[now_level]
		local now_have = total - offset[now_level]
		local l = (now_have/now_need) * (len[now_level].max - len[now_level].min) + len[now_level].min
		self.progress.sizeDelta={x = l,y = 20.8}
	end
	self:RefreshNum(total)
end

function C:on_AssetChange(data)
	if data.change_type and (data.change_type == "box_exchange_active_award_122" or data.change_type == "box_exchange_active_award_123")and 
		not table_is_null(data.data) then
		self.Award_Data = data
	end
	self:MyRefresh()
end

function C:TryToShow()
	if self.Award_Data and self.call then
		self.call() 
		Event.Brocast("AssetGet",self.Award_Data)
		self.Award_Data = nil
		self.call = nil 
	end 
end

function C:OpenHelpPanel()
	local DESCRIBE_TEXT = M.config.DESCRIBE_TEXT
	local str = DESCRIBE_TEXT[1].text
	for i = 2, #DESCRIBE_TEXT do
		str = str .. "\n" .. DESCRIBE_TEXT[i].text
	end
	self.introduce_txt.text = str
	IllustratePanel.Create({ self.introduce_txt.gameObject }, GameObject.Find("Canvas/LayerLv5").transform)
end

function C:on_box_exchange_response(_,data)
	dump(data,"<color=red>返回</color>")
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
		local award_index = self:GetAwardIndexInUI(data.award_id[1])
		self.MainAnim:StartLottery(award_index,function ()
			self.lock = false
			self:TryToShow()
		end)
	else
		self.lock = false
	end 
end

function C:GetAwardIndexInUI(award_id)
	local config_index
	for i = 1,#M.config.Award1 do
		if M.config.Award1[i].server_award_id == award_id then
			config_index = i
			break
		end
	end
	for i = 1,#M.config.Award2 do
		if M.config.Award2[i].server_award_id == award_id then
			config_index = i
			break
		end
	end
	for i = 1,#map do
		if map[i] == config_index then
			return i
		end
	end
end

function C:on_model_task_change_msg(data)
    dump(data, "<color=red>----------任务改变-----------</color>")
    if data and data.id == M.task_id then
        --self.num_txt.text = data.now_total_process
        local b = basefunc.decode_task_award_status(data.award_get_status)
        b = basefunc.decode_all_task_award_status(b, data, 5)
        self:ReFreshProgress(data.now_total_process)
        self:ReFreshTaskButtons(b)
    end
end

function C:on_model_query_one_task_data_response(data)
    dump(data, "<color=red>----------任务信息获得-----------</color>")
    if data and data.id == M.task_id then
        --self.num_txt.text = data.now_total_process
        local b = basefunc.decode_task_award_status(data.award_get_status)
        b = basefunc.decode_all_task_award_status(b, data, 5)
		self:ReFreshProgress(data.now_total_process)
		--dump(b,"<color=white>bbbbbbbbbbbbbbbbbbbbbbbbbb</color>")
        self:ReFreshTaskButtons(b)
    end
end

function C:UpDatePMD()
    if self.UpdatePMD then
        self.UpdatePMD:Stop()
    end
    Network.SendRequest("query_fake_data", { data_type = "act_043_sdcdj" })
    self.UpdatePMD = Timer.New(
        function()
            --dump("<color=red>-------------------------------------------   query_fake_data-------------------------------------------------</color>")
			Network.SendRequest("query_fake_data", { data_type = "act_043_sdcdj" })
		end
    , 20, -1)
    self.UpdatePMD:Start()
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
        temp_ui.t1_txt.text = "恭喜" .. data.player_name .. "鸿运当头，抽中了" .. data.award_data
        UnityEngine.UI.LayoutRebuilder.ForceRebuildLayoutImmediate(b.transform)
        self.pmd_cont:AddObj(b)
    end
end
