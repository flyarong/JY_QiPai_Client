local basefunc = require "Game/Common/basefunc"

ActivitySDQQLPanel = basefunc.class()
local C = ActivitySDQQLPanel
C.name = "ActivitySDQQLPanel"
C.key = "christmas_break"
local config = SDQQLManager.config
local qd_anim_time = 1.2
local tx_time = {
	[1] = 1.2,
	[2] = 1.5,
	[3] = 6,
}

function C.Create(parent,cfg,backcall)
	return C.New(parent,cfg,backcall)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
	self.lister = {}
	--self.lister["get_one_common_lottery_info"] = basefunc.handler(self,self.Refresh_UI)
	self.lister["common_lottery_kaijaing_response"] = basefunc.handler(self, self.Get_KAIJIANG_info)
	self.lister["AssetChange"] = basefunc.handler(self, self.OnAssetChange)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
	self.lister = {}
end

function C:MyExit()
	if self.PlayQQLTX_Timer then 
		self.PlayQQLTX_Timer:Stop()
	end
	if self.PlayQQLAnim_Timer then 
		self.PlayQQLAnim_Timer:Stop()
	end 
	GameTipsPrefab.Hide()
	self:RemoveListener()
	destroy(self.gameObject)

	 
end

function C:ctor(parent,cfg,backcall)

	ExtPanel.ExtMsg(self)

	local parent =  GameObject.Find("Canvas/LayerLv3").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.backcall = backcall
	self.Animtion_Finsh = true
	LuaHelper.GeneratingVar(self.transform, self)
	self.map_data = self:GetMapping(10)
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.help_btn.onClick:AddListener(
		function ()
			self:OpenHelpPanel()
		end
	)
	self.close_btn.onClick:AddListener(
		function ()
			if self.Animtion_Finsh then 
				self:MyExit()
				if self.backcall then 
					self.backcall()
				end 
			end 
		end
	)
	self.go_btn.onClick:AddListener(
		function ()
			self:MyExit()
			GameManager.GotoUI({gotoui = "game_MiniGame"})
		end
	)
	self.award_btn.onClick:AddListener(
		function ()
			self.showawardpanel.gameObject:SetActive(true)
		end
	)
	self.close_show_btn.onClick:AddListener(
		function ()
			self.showawardpanel.gameObject:SetActive(false)
		end
	)
	self:InitTips()
	self:Refresh_UI()
	self:InitAwardButton()
end

function C:MyRefresh()
end

--存储破损蛋的位置
function C:SaveBrokeEggPos(game_times,egg_pos)
	PlayerPrefs.SetInt(MainModel.UserInfo.user_id.."SDQQL"..game_times,egg_pos)
end

--获取破损蛋的位置
function C:GetBrokeEggPos(game_times)
	--当本地存储的蛋的位置丢失时，则使用由自己ID为种子随机而成的排列顺序。(注意，极端条件下如果只是本地某一条的顺序错误，则有可能会出问题)
	if	PlayerPrefs.GetInt(MainModel.UserInfo.user_id.."SDQQL"..game_times,-1) == -1 then
		PlayerPrefs.SetInt(MainModel.UserInfo.user_id.."SDQQL"..game_times,self.map_data[game_times])
		return self.map_data[game_times]
	else
		return 	PlayerPrefs.GetInt(MainModel.UserInfo.user_id.."SDQQL"..game_times,-1)
	end
end

function C:GetMapping(max)
	local temp_list = {}
	local List = {}
	for i = 1, max do
		List[i] = i
	end
	math.randomseed(MainModel.UserInfo.user_id)
	while #temp_list < max do
		local R = math.random(1, max)
		if List[R] ~= nil then
			temp_list[#temp_list + 1] = List[R]
			table.remove(List, R)
		end
	end
	return temp_list
end

function C:Refresh_UI()
	local temp_ui = {}
	if SDQQLManager.GetData() then 
		self.m_data = SDQQLManager.GetData().at_data
	else
		return 
	end 
	dump(self.m_data,"<color=red>圣诞敲敲乐数据</color>")
	if self.m_data then
		self.curr_txt.text = "当前积分："..self.m_data.ticket_num 
		self.now_game_num = self.m_data.now_game_num
		for i=1,self.now_game_num do
			self["mask"..i].gameObject:SetActive(true)
		end
		if self.now_game_num >= 1 then 
			self.Guide.gameObject:SetActive(false)
			self.showawardpanel.gameObject:SetActive(false)
		else
			self.Guide.gameObject:SetActive(true)
			self.showawardpanel.gameObject:SetActive(true)
		end 
		if self.m_data then 
			for i = 1, self.now_game_num do
				local index = self:GetBrokeEggPos(i)
				LuaHelper.GeneratingVar(self["egg_item"..index].transform, temp_ui)
				temp_ui.bad.gameObject:SetActive(true)
				temp_ui.good.gameObject:SetActive(false)
			end
		end
		if self.now_game_num >= #config.Award then 
			self.need_txt.text = "所有奖励已获取"
		else
			self.need_txt.text = config.Award[self.now_game_num + 1].need_credits.."积分/次"
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

function C:InitTips()
	for i=1,#config.Award do
		if config.Award[i].tips then 
			PointerEventListener.Get(self["show_item"..i].gameObject).onDown = function ()
				GameTipsPrefab.ShowDesc(config.Award[i].tips, UnityEngine.Input.mousePosition)
			end
			PointerEventListener.Get(self["show_item"..i].gameObject).onUp = function ()
				GameTipsPrefab.Hide()
			end
		end 
	end
end

function C:GetAward(index)
	if not self.m_data then return  end
	if self.now_game_num >= #config.Award then
		return 
	end
	if self.m_data.ticket_num >= config.Award[self.now_game_num + 1].need_credits then 
		Network.SendRequest("common_lottery_kaijaing", {lottery_type = C.key})
		self.tx_level = config.Award[self.now_game_num + 1].tx
		self.now_total = self.now_game_num + 1
		self.broke_pos = index
		if config.Award[self.now_game_num + 1].real == 1 then 
			self.real = {image = config.Award[self.now_game_num + 1].award_image ,text = config.Award[self.now_game_num + 1].award_text}
		end
		self:PlayQQLAnim(index)
	else
		HintPanel.Create(1,"您的积分不足，赶快去玩小游戏赚取积分吧")
	end 
end

function C:Get_KAIJIANG_info(_,data)
	dump(data,"<color=red>Get_KAIJIANG_info</color>")
	if data and data.result == 0 then
		self.kaijiang_succ = true  
		self:TryToShow()
	end 
end

function C:PlayQQLAnim(index)
	self.Animtion_Finsh = false
	local temp_ui = {}
	local b = GameObject.Instantiate(self.anim_item,self["anim_node"..index])
	b.gameObject:SetActive(true)
	b.transform.localPosition = Vector3.New(0,0,0)
	b.transform.localScale = Vector3.New(1.24,1.24,1.24)
	LuaHelper.GeneratingVar(self["egg_item"..index].transform, temp_ui)
	temp_ui.good.gameObject:SetActive(false)
	temp_ui.anim_qd.gameObject:SetActive(true)
	temp_ui.animator = temp_ui.anim_qd.gameObject.transform:GetComponent("Animator")
	temp_ui.animator:Play("Dachui_Pt_H",-1,0)
	if self.PlayQQLAnim_Timer then 
		self.PlayQQLAnim_Timer:Stop()
	end 
	self.PlayQQLAnim_Timer = Timer.New(      
		function ()
			temp_ui.anim_qd.gameObject:SetActive(false)
			temp_ui.bad.gameObject:SetActive(true)
			self:PlayQQLTX(index)
		end
	,qd_anim_time,1)
	self.PlayQQLAnim_Timer:Start()
end

function C:PlayQQLTX(index)
	local temp_ui = {}
	LuaHelper.GeneratingVar(self["egg_item"..index].transform, temp_ui)
	temp_ui.good.gameObject:SetActive(false)
	temp_ui.anim_qd.gameObject:SetActive(false)
	temp_ui["tx_"..self.tx_level].gameObject:SetActive(true)
	if self.PlayQQLTX_Timer then 
		self.PlayQQLTX_Timer:Stop()
	end 
	self.PlayQQLTX_Timer = Timer.New(      
		function ()
			temp_ui["tx_"..self.tx_level].gameObject:SetActive(false)
			self.Animtion_Finsh = true
			self:TryToShow()
		end
	,tx_time[self.tx_level],1)
	self.PlayQQLTX_Timer:Start()
end

function C:OnAssetChange(data)
    dump(data, "<color=red>----奖励类型-----</color>")
	if data.change_type and data.change_type == "common_lottery_" .. C.key then
		self.AssetGet = data
        self:TryToShow()
    end
end


function C:TryToShow()
	if self.AssetGet and self.Animtion_Finsh then 
		Event.Brocast("AssetGet", self.AssetGet)
		self.AssetGet = nil
		self:SaveBrokeEggPos(self.now_total,self.broke_pos)
		self:Refresh_UI()
	end
	if self.real and self.Animtion_Finsh and self.kaijiang_succ then 
		RealAwardPanel.Create(self.real)
		self.real = nil
		self.kaijiang_succ = false
		self:SaveBrokeEggPos(self.now_total,self.broke_pos)
		self:Refresh_UI()
	end  
end

function C:InitAwardButton()
	local temp_ui = {}
	for i = 1,#config.Award do
		LuaHelper.GeneratingVar(self["egg_item"..i].transform, temp_ui)
		temp_ui.lottery_btn.onClick:AddListener(
			function ()
				if self.Animtion_Finsh then
					self:GetAward(i)
				end 
			end
		)
	end
end