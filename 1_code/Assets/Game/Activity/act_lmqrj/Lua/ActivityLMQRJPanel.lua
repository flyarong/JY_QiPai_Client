local basefunc = require "Game/Common/basefunc"

ActivityLMQRJPanel = basefunc.class()
local C = ActivityLMQRJPanel
C.name = "ActivityLMQRJPanel"
C.key = "romantic_valentine_day"
local config = LMQRJManager.config
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
	self.ACT_LOCK = false
	LuaHelper.GeneratingVar(self.transform, self)
	self.map_data = self:GetMapping(10)
	self.real_config = self:InitRealAwardConfig()
	dump(self.real_config,"<color=red>InitRealAwardConfig</color>")
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.AWARD_OBJS = {}
	self.AWARD_OBJS_Animator = {}
	for i=1,10 do
		local temp_ui = {}
		self.AWARD_OBJS[i] = GameObject.Instantiate(self.egg_item,self["Node"..i])
		self.AWARD_OBJS[i].gameObject:SetActive(true)
		self.AWARD_OBJS[i].transform.localPosition = Vector3.zero
		self.AWARD_OBJS_Animator[i] = self.AWARD_OBJS[i].transform:GetComponent("Animator")
		self.AWARD_OBJS_Animator[i]:Play("Activity_@egg_item_2")
		LuaHelper.GeneratingVar(self.AWARD_OBJS[i].transform, temp_ui)
		temp_ui.award_img.sprite = GetTexture(config.Award[i].award_image)
		temp_ui.award2_img.sprite = GetTexture(config.Award[i].award_image)
	end
	self.help_btn.onClick:AddListener(
		function ()
			if self.ACT_LOCK then return end 
			self:OpenHelpPanel()
		end
	)
	self.close_btn.onClick:AddListener(
		function ()
			if self.ACT_LOCK then return end 
			self:MyExit()
			if self.backcall then 
				self.backcall()
			end 
		end
	)
	self.go_btn.onClick:AddListener(
		function ()
			if self.ACT_LOCK then return end 
			self:MyExit()
			GameManager.GotoUI({gotoui = "game_MiniGame"})
		end
	)
	self.award_btn.onClick:AddListener(
		function ()
			if self.ACT_LOCK then return end 
			self.showawardpanel.gameObject:SetActive(true)
		end
	)
	self.close_show_btn.onClick:AddListener(
		function ()
			if self.ACT_LOCK then return end 
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
	PlayerPrefs.SetInt(MainModel.UserInfo.user_id..C.name..game_times,egg_pos)
end

--获取破损蛋的位置
function C:GetBrokeEggPos(game_times)
	--当本地存储的蛋的位置丢失时，则使用由自己ID为种子随机而成的排列顺序。(注意，极端条件下如果只是本地某一条的顺序错误，则有可能会出问题)
	if	PlayerPrefs.GetInt(MainModel.UserInfo.user_id..C.name..game_times,-1) == -1 then
		PlayerPrefs.SetInt(MainModel.UserInfo.user_id..C.name..game_times,self.map_data[game_times])
		return self.map_data[game_times]
	else
		return 	PlayerPrefs.GetInt(MainModel.UserInfo.user_id..C.name..game_times,-1)
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
	local main_data = LotteryBaseManager.GetData(C.key)
	dump(main_data,"<color=red>main_datamain_datamain_datamain_data</color>")
	if main_data then 
		self.main_data = main_data
		self.curr_txt.text = "当前积分:<color=#FFFD9B>"..main_data.ticket_num.."</color>"
		if main_data.now_game_num >= 10 then 
			self.need_txt.text = "已获得所有奖励"
		else
			self.need_txt.text = "消耗:<color=#FFFD9B>"..config.Award[main_data.now_game_num + 1].need_credits.."</color>积分开礼盒"
		end 
		local temp_ui = {}
		if main_data.now_game_num < 1 then 
			self.ACT_LOCK = true
			for i=1,10 do
				self.AWARD_OBJS_Animator[i]:Play("Activity_@egg_item",0,0)
			end
			Timer.New(function ()
				self:GuideAnim(self.AWARD_OBJS,function ()
					self.ACT_LOCK = false
				end)
			end,1.4,1):Start()
		end
		for i=1,main_data.now_game_num do
			local index = self:GetBrokeEggPos(i)
			LuaHelper.GeneratingVar(self.AWARD_OBJS[index].transform, temp_ui)
			self["mask"..i].gameObject:SetActive(true)
			temp_ui.bad.gameObject:SetActive(false)
			temp_ui.good.gameObject:SetActive(false)
			temp_ui.got.gameObject:SetActive(true)
			temp_ui.yhd.gameObject:SetActive(true)
			temp_ui.award3_img.sprite = GetTexture(config.Award[i].award_image)
			temp_ui.award_txt.text = config.Award[i].award_text
		end
	end
	local is_can_get = LotteryBaseManager.IsAwardCanGet(LMQRJManager.lottery_type)
	self.huxi.gameObject:SetActive(is_can_get)
	self.huxi_not.gameObject:SetActive(false)
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
	if LotteryBaseManager.IsAwardCanGet(LMQRJManager.lottery_type) then 
		Network.SendRequest("common_lottery_kaijaing", {lottery_type = C.key})
		self.Curr_Egg_Pos = index
		self.Curr_Game_Times = self.main_data.now_game_num + 1
	else
		HintPanel.Create(1,"当前积分不足，快去玩小游戏赚取积分吧")
	end
end

function C:Get_KAIJIANG_info(_,data)
	dump(data, "<color=red>----Get_KAIJIANG_info-----</color>")
	if data and data.lottery_type == C.key then 
		if self.real_config[data.award_id] then
			local temp_ui = {}
			self.AWARD_OBJS_Animator[self.Curr_Egg_Pos]:Play("Activity_@egg_item_3",0,0)
			LuaHelper.GeneratingVar(self.AWARD_OBJS[self.Curr_Egg_Pos].transform,temp_ui)
			temp_ui.award_img.sprite = GetTexture(config.Award[self.Curr_Game_Times].award_image)
			temp_ui.award2_img.sprite = GetTexture(config.Award[self.Curr_Game_Times].award_image)
			temp_ui.award3_img.sprite = GetTexture(config.Award[self.Curr_Game_Times].award_image)
			self:SaveBrokeEggPos(self.Curr_Game_Times,self.Curr_Egg_Pos)
			local func = function ()
				RealAwardPanel.Create({text = config.Award[self.Curr_Game_Times].award_text,image = config.Award[self.Curr_Game_Times].award_image})
				temp_ui.award_txt.text = config.Award[self.Curr_Game_Times].award_text
				self:Refresh_UI()
			end
			self:WaitToDo(func)
		end
	end
end

function C:OnAssetChange(data)
    dump(data, "<color=red>----奖励类型-----</color>")
	if data.change_type and data.change_type == "common_lottery_" .. C.key then
		local temp_ui = {}
		self.AWARD_OBJS_Animator[self.Curr_Egg_Pos]:Play("Activity_@egg_item_3",0,0)
		LuaHelper.GeneratingVar(self.AWARD_OBJS[self.Curr_Egg_Pos].transform,temp_ui)
		temp_ui.award_img.sprite = GetTexture(config.Award[self.Curr_Game_Times].award_image)
		temp_ui.award2_img.sprite = GetTexture(config.Award[self.Curr_Game_Times].award_image)
		temp_ui.award3_img.sprite = GetTexture(config.Award[self.Curr_Game_Times].award_image)
		self:SaveBrokeEggPos(self.Curr_Game_Times,self.Curr_Egg_Pos)
		local func = function ()
			Event.Brocast("AssetGet",data)
			temp_ui.award_txt.text = config.Award[self.Curr_Game_Times].award_text
			self:Refresh_UI()
		end
		self:WaitToDo(func)
    end
end

function C:InitAwardButton()
	local temp_ui = {}
	for i = 1,#config.Award do
		LuaHelper.GeneratingVar(self.AWARD_OBJS[i].transform, temp_ui)
		temp_ui.lottery_btn.onClick:AddListener(
			function ()
				if not self.ACT_LOCK then
					self:GetAward(i)
				end 
			end
		)
	end
end

function C:GuideAnim(objs,backcall)
	local finsh_times = 0
	for i=1,#objs do
		self.seq = DoTweenSequence.Create()
		local old_p  = objs[i].parent
		objs[i].parent = self.transform
		local v  = objs[i].transform.localPosition
		self.seq:Append(objs[i]:DOLocalMove(self.mid_pos.transform.localPosition, 1))
		self.seq:AppendInterval(0.5)
		self.seq:Append(objs[i]:DOLocalMove(v, 0.7))
		self.seq:OnKill(function ()
			finsh_times = finsh_times + 1
			if finsh_times == #objs then 
				if backcall then 
					backcall()
				end 
			end 
			objs[i].parent = old_p
			self.seq = nil
		end)
	end
end

--奖励展示
function C:WaitToDo(func)
	self.ACT_LOCK = true
	if self.Delay_Timer then 
		self.Delay_Timer:Stop()
		self.Delay_Timer = nil
	end
	self.Delay_Timer = Timer.New(function ()
		if func then 
			func()
		end
		self.ACT_LOCK = false
	end,1.6,1)
	self.Delay_Timer:Start()
end

function C:InitRealAwardConfig()
	local real = {}
	for i=1,#config.Award do
		if config.Award[i].real == 1 then 
			real[config.Award[i].server_award_id] = config.Award[i]
		end 
	end
	return real
end