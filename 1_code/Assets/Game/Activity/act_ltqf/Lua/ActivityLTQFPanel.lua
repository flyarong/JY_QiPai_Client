local basefunc = require "Game/Common/basefunc"

ActivityLTQFPanel = basefunc.class()
local C = ActivityLTQFPanel
C.name = "ActivityLTQFPanel"
C.key = "dragon_blessing"
local config = LTQFManager.config
local c_gray = Color.gray
local curr_level = 0
local bless_img = {
	[1] = {on = "ltqf_imgf_1_1",off = "ltqf_imgf_1_2"},
	[2] = {on = "ltqf_imgf_1_3",off = "ltqf_imgf_1_4"},
	[3] = {on = "ltqf_imgf_1_5",off = "ltqf_imgf_1_6"},
	[4] = {on = "ltqf_imgf_1_7",off = "ltqf_imgf_1_8"},
	[5] = {on = "ltqf_imgf_1_9",off = "ltqf_imgf_1_10"},
	[6] = {on = "ltqf_imgf_1_11",off = "ltqf_imgf_1_12"},
	[7] = {on = "ltqf_imgf_1_13",off = "ltqf_imgf_1_14"},
	[8] = {on = "ltqf_imgf_1_15",off = "ltqf_imgf_1_16"},
	[9] = {on = "ltqf_imgf_1_17",off = "ltqf_imgf_1_18"},
	[10] = {on = "ltqf_imgf_1_19",off = "ltqf_imgf_1_20"},
}
function C.Create(parent, cfg, backcall)
	return C.New(parent, cfg, backcall)
end

function C:AddMsgListener()
	for proto_name,func in pairs(self.lister) do
		Event.AddListener(proto_name, func)
	end
end

function C:MakeLister()
	self.lister = {}
	self.lister["AssetChange"] = basefunc.handler(self, self.OnAssetChange)
	self.lister["AssetsGetPanelConfirmCallback"] = basefunc.handler(self, self.AssetsGetPanelConfirmCallback)
	self.lister["get_one_common_lottery_info"] = basefunc.handler(self, self.RefreshMyHL)
	self.lister["common_lottery_kaijaing_response"] = basefunc.handler(self, self.Get_KAIJIANG_info)
end

function C:RemoveListener()
	for proto_name,func in pairs(self.lister) do
		Event.RemoveListener(proto_name, func)
	end
	self.lister = {}
end

function C:MyExit()
	self:RemoveListener()
	GameTipsPrefab.Hide()
	destroy(self.gameObject)

	 
end

function C:ctor(parent, cfg, backcall)

	ExtPanel.ExtMsg(self)

	self.backcall = backcall
	local parent = parent or GameObject.Find("Canvas/LayerLv3").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self:Refresh()
end

function C:InitUI()
	self.help_btn.onClick:AddListener(
		function()
			self:OpenHelpPanel()
		end
	)
	self.make_hl_btn.onClick:AddListener(
		function()
			self:GoToUI()
		end	
	)
	self.close_btn.onClick:AddListener(
		function ()
			if self.backcall then
				self.backcall()
			end
			self:MyExit()
		end
	)
	for i = 1,#config.Award do
		local temp_ui = {} 
		LuaHelper.GeneratingVar(self["award_item"..i], temp_ui)
		temp_ui.need_txt.text = config.Award[i].need_credits.."福气领取"
		temp_ui.bless_img.sprite = GetTexture(bless_img[i].on)
		temp_ui.box_btn.enabled = false
		if i < 10 then
			temp_ui.box_btn.gameObject.transform:GetComponent("Image").sprite = GetTexture("ltqf_btn_jl2")
		end 
	end 
	for i=1,#config.Award do
		local temp_ui = {} 
		LuaHelper.GeneratingVar(self["award_item"..i], temp_ui)

		PointerEventListener.Get(temp_ui.box_btn.gameObject).onDown = function ()
	        GameTipsPrefab.ShowDesc(config.Award[i].tips, UnityEngine.Input.mousePosition)
	    end
		PointerEventListener.Get(temp_ui.box_btn.gameObject).onUp = function ()
	        GameTipsPrefab.Hide()
	    end
	end
end


function C:OpenHelpPanel()
	local str = config.DESCRIBE_TEXT[1].text
	for i = 2, #config.DESCRIBE_TEXT do
		str = str .. "\n" .. config.DESCRIBE_TEXT[i].text
	end
	self.introduce_txt.text = str
	IllustratePanel.Create({ self.introduce_txt.gameObject }, GameObject.Find("Canvas/LayerLv5").transform)
end

function C:GoToUI()
	GameManager.GotoUI({gotoui="game_MiniGame"})
end

function C:Refresh()
	if not IsEquals(self.gameObject) then return end 
	self:ShowNeed()
	self:SetDzPos()
	self:SetMask()
	self:RefreshMyHL()
end

function C:SetDzPos()
end

function C:ShowNeed()
	local data = LotteryBaseManager.GetData(C.key)
	local curr_level = 11
	if data then 
		curr_level = data.now_game_num + 1
	end
	self:HideAllNeed()
	if curr_level <= 10 then 
		self:ShowNeedItem(curr_level)
	end
end

function C:SetMask()
	local data = LotteryBaseManager.GetData(C.key)
	if data then 
		for i = 1,data.now_game_num do 
			local  temp_ui = {}
			LuaHelper.GeneratingVar(self["award_item"..i], temp_ui)
			temp_ui.yhd.gameObject:SetActive(true)
			temp_ui.bless_img.sprite = GetTexture(bless_img[i].on)
			if i < 10 then 
				temp_ui.box_btn.gameObject.transform:GetComponent("Image").sprite = GetTexture("ltqf_btn_jl4")
			end 
			if i == 10 then
				temp_ui.box_btn.gameObject.transform:GetComponent("Animator"):Play("ltqf_stop")
			end
		end 
	end 
end

function C:PlayAnim()
	if not IsEquals(self.gameObject) then return end 
	local temp_ui = {}
	LuaHelper.GeneratingVar(self["award_item"..self.curr_level], temp_ui)
	local b = GameObject.Instantiate(self.open_tx,temp_ui.box_btn.gameObject.transform)
	b.transform.localPosition = Vector3.zero
	b.gameObject:SetActive(true)
	Timer.New(function()
		if self.real then 
			RealAwardPanel.Create(self.real)
			self.real = nil
		end
		if self.award_data then
			Event.Brocast("AssetGet",self.award_data)
			self.award_data = nil
		end 
	end,0.5,1):Start()
end

function C:OnAssetChange(data)
	dump(data, "<color=red>----奖励类型-----</color>")
	if data.change_type and data.change_type == "common_lottery_" .. C.key then
		self.award_data = data
		self:PlayAnim()
	end
end

function C:GetAward()
	local data = LotteryBaseManager.GetData(C.key)
	local curr_level = 11
	if data then 
		curr_level = data.now_game_num + 1
	end
	self.curr_level = curr_level
	if curr_level <= 10 then
		if data.ticket_num >= config.Award[curr_level].need_credits then 
			Network.SendRequest("common_lottery_kaijaing", {lottery_type = C.key})		
			if config.Award[curr_level].real == 1 then 
				local real = {text = config.Award[curr_level].type, image = config.Award[curr_level].img}
				self.real = real
			else
				self.real = nil
			end 
		else
			HintPanel.Create(1,"福气不足哦，赶快去玩小游戏赚取福气吧")
		end 	
	else
		print("<color=red>奖励已经完全领取</color>")
	end 
end

function C:HideAllNeed()
	for i = 1,#config.Award do 
		local temp_ui = {}
		LuaHelper.GeneratingVar(self["award_item"..i], temp_ui)
		temp_ui.need.gameObject:SetActive(false)
	end 
end

function C:ShowNeedItem(index)
	local temp_ui = {}
	LuaHelper.GeneratingVar(self["award_item"..index], temp_ui)
	temp_ui.need.gameObject:SetActive(true)
	temp_ui.box_btn.enabled = true
	temp_ui.bless_img.sprite = GetTexture(bless_img[index].on)
	if index < 10 then 
		temp_ui.box_btn.gameObject.transform:GetComponent("Image").sprite = GetTexture("ltqf_btn_jl2")
	end 
	temp_ui.box_btn.onClick:RemoveAllListeners()
	temp_ui.box_btn.onClick:AddListener(
		function ()
			self:GetAward()
		end
	)
end

function C:AssetsGetPanelConfirmCallback()
	self:Refresh()
end

function C:RefreshMyHL()
	if not IsEquals(self.gameObject) then return end 
	local data = LotteryBaseManager.GetData(C.key)
	if data then
		self.curr_hl_txt.text = "当前福气："..data.ticket_num 
	end  
end

function C:Get_KAIJIANG_info(_,data)
	if data and data.result == 0 then 
		if self.real then 
			self:PlayAnim()
		end 
	end 
end