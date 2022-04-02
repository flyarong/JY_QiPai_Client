--ganshuangfeng 比赛场界面
--2018-04-17
local basefunc = require "Game.Common.basefunc"
DdzMillionHallPanel = basefunc.class()

DdzMillionHallPanel.name = "DdzMillionHallPanel"
local lister
local listerRegisterName="ddzMillionHallListerRegister"
local curSwitchMatch
local instance
local update
local updateDt=1
local localStatus = -1
local dmg_match_list
-- 菊花Tag
local have_Jh
function DdzMillionHallPanel.Create()
	instance=DdzMillionHallPanel.New()
	return createPanel(instance,DdzMillionHallPanel.name)
end
function DdzMillionHallPanel.Bind()
	local _in = instance
	instance = nil
	return _in
end

function DdzMillionHallPanel:Awake()
	ExtendSoundManager.PlaySceneBGM(audio_config.ddz.ddz_bgm_game_hall.audio_name)
	local tran = self.transform
	self.RankItem = tran:Find("CellPrefab")
	self.BackButton = tran:Find("ImgTop/ImgBtn/BackButton")
	self.CenterRect = tran:Find("CenterRect")
	self.Content = tran:Find("CenterRect/RankRect/ScrollView/Viewport/Content").transform
	self.MyRankText = tran:Find("CenterRect/RankRect/DownRect/MyRankBG/MyRankText"):GetComponent("Text")
	self.MyNameText = tran:Find("CenterRect/RankRect/DownRect/MyNameText"):GetComponent("Text")
	self.MyMoneyText = tran:Find("CenterRect/RankRect/DownRect/MyMoneyText"):GetComponent("Text")
	self.ApplyButton = tran:Find("CenterRect/ApplyButton")
	self.AwardHintText = tran:Find("CenterRect/ApplyButton/AwardHintText"):GetComponent("Text")
	self.HintImage = tran:Find("CenterRect/ApplyButton/HintImage"):GetComponent("Image")

	self.SignupCountDown = tran:Find("CenterRect/ApplyButton/SignupCountDown").transform
	self.SignupCD = tran:Find("CenterRect/ApplyButton/SignupCountDown/CountDown").transform
	self.SignupDayText = tran:Find("CenterRect/ApplyButton/SignupCountDown/DayText"):GetComponent("Text")
	self.SignupH_txt = tran:Find("CenterRect/ApplyButton/SignupCountDown/CountDown/HImage/HText"):GetComponent("Text")
	self.SignupM_txt = tran:Find("CenterRect/ApplyButton/SignupCountDown/CountDown/MImage/MText"):GetComponent("Text")
	self.SignupS_txt = tran:Find("CenterRect/ApplyButton/SignupCountDown/CountDown/SImage/SText"):GetComponent("Text")

	self.StartCountDown = tran:Find("CenterRect/ApplyButton/StartCountDown").transform
	self.StartCD = tran:Find("CenterRect/ApplyButton/StartCountDown/CountDown").transform
	self.StartDayText = tran:Find("CenterRect/ApplyButton/StartCountDown/DayText"):GetComponent("Text")
	self.StartH_txt = tran:Find("CenterRect/ApplyButton/StartCountDown/CountDown/HImage/HText"):GetComponent("Text")
	self.StartM_txt = tran:Find("CenterRect/ApplyButton/StartCountDown/CountDown/MImage/MText"):GetComponent("Text")
	self.StartS_txt = tran:Find("CenterRect/ApplyButton/StartCountDown/CountDown/SImage/SText"):GetComponent("Text")
	self.EndText = tran:Find("CenterRect/ApplyButton/EndText"):GetComponent("Text")

	self.MyAllMoneyText = tran:Find("CenterRect/RightRect/Image5/MyMoneyText"):GetComponent("Text")
	self.GetMoneyButton = tran:Find("CenterRect/RightRect/GetMoneyButton")
	self.InviteFriendButton = tran:Find("CenterRect/RightRect/InviteFriendButton")
	self.RebirthNumText = tran:Find("CenterRect/RightRect/InviteFriendButton/RebirthNumText"):GetComponent("Text")

	self.behaviour:AddClick(self.BackButton.gameObject, DdzMillionHallPanel.OnBackClick, self)
	self.behaviour:AddClick(self.ApplyButton.gameObject, DdzMillionHallPanel.OnApplyClick, self)
	self.behaviour:AddClick(self.GetMoneyButton.gameObject, DdzMillionHallPanel.OnGetMoneyClick, self)
	self.behaviour:AddClick(self.InviteFriendButton.gameObject, DdzMillionHallPanel.OnInviteFriendClick, self)

	if not GameGlobalOnOff.Share then
		self.InviteFriendButton.gameObject:SetActive(false)
	end

	self.updateAssetInfoHandler = function ()
		self:RefreshMoney()
	end
	Event.AddListener("AssetChange",self.updateAssetInfoHandler)

	self.RankList = {}
end

function DdzMillionHallPanel:UpdateCountdown()
	if self.signupCD  and self.signupCD>0 then
		if self.signupCD < 86400 then
			self.signupCD= self.signupCD-1
			self:RefreshSignupCountdown()
			self.SignupDayText.gameObject:SetActive(false)
		else
			-- local list = split(os.date("%H:%M:%S", self.signupCD), ":")
			local day = self.signupCD / 86400
			self.SignupDayText.text =string.format("<color=FFF375FF>%d</color><color=F4BA80FF>天</color>",day)
			self.SignupDayText.gameObject:SetActive(true)
		end
	end

	if self.beginCD and self.beginCD > 0 then
		if self.beginCD < 86400 then
			self.beginCD= self.beginCD-1
			self:RefreshBeginCountdown()
			self.StartDayText.gameObject:SetActive(false)
		else
			-- local list = split(os.date("%H:%M:%S", self.beginCD), ":")
			local day = self.signupCD / 86400
			self.StartDayText.text =string.format("<color=FFF375FF>%d</color><color=F4BA80FF>天</color>",day)
			self.StartDayText.gameObject:SetActive(true)
		end
	end
end

function DdzMillionHallPanel:Start()
	self:MyInit()
	self:MyRefresh()
	update=Timer.New(basefunc.handler(self,self.Update),updateDt,-1)
    update:Start()
end

function DdzMillionHallPanel:Update()
	if dbwg_match_list then
		self:UpdateCountdown()
		local data = dbwg_match_list
		if data.status == 0 then
			self.HintImage.gameObject:SetActive(false)
			self.AwardHintText.text = "0"
		elseif data.status == 4 then
			self.HintImage.sprite = GetTexture("million_imgf_kasai")
			self.HintImage:SetNativeSize()
			self.SignupCountDown.gameObject:SetActive(false)
			self.StartCountDown.gameObject:SetActive(false)
			self.EndText.gameObject:SetActive(true)
		else
			if tonumber(data.signup_time) > os.time() then
				self.HintImage.sprite = GetTexture("million_imgf_remind")
				self.HintImage:SetNativeSize()
				self.SignupCountDown.gameObject:SetActive(true)
				self.StartCountDown.gameObject:SetActive(false)
				self.EndText.gameObject:SetActive(false)
				dbwg_match_list.status = 1
			elseif tonumber(data.signup_time) <= os.time() and os.time() <= tonumber(data.begin_time) then
				self.HintImage.sprite = GetTexture("million_imgf_apply")
				self.HintImage:SetNativeSize()
				self.SignupCountDown.gameObject:SetActive(false)
				self.StartCountDown.gameObject:SetActive(true)
				self.EndText.gameObject:SetActive(false)
				dbwg_match_list.status = 2
			elseif tonumber(data.begin_time) < os.time()  then
				self.HintImage.sprite = GetTexture("million_imgf_kasai")
				self.HintImage:SetNativeSize()
				self.EndText.gameObject:SetActive(true)
				self.SignupCountDown.gameObject:SetActive(false)
				self.StartCountDown.gameObject:SetActive(false)
				dbwg_match_list.status = 3
			end
		end
    end
end

function DdzMillionHallPanel:OnDestroy()
	update:Stop()
	self:CloseRankList()
	if have_Jh then
		FullSceneJH.RemoveByTag(have_Jh)
		have_Jh=nil
	end
end

--[[初始化功能，创建好panel后在Award中调用，只做一次]]
function DdzMillionHallPanel:MyInit()
	self:MakeLister()
	DdzMillionLogic.setViewMsgRegister(lister,listerRegisterName)
	dbwg_match_list = nil
end

function DdzMillionHallPanel:RefreshSignupCountdown()
	-- local list = split(os.date("%H:%M:%S", self.signupCD), ":")
		self.SignupH_txt.text = math.floor(self.signupCD % 86400 / 3600)
		self.SignupM_txt.text = math.floor(self.signupCD % 86400 % 3600 / 60)
		self.SignupS_txt.text = math.floor(self.signupCD % 86400 % 3600 % 60 / 1)
end

function DdzMillionHallPanel:RefreshBeginCountdown()
	-- local list = split(os.date("%H:%M:%S", self.beginCD), ":")
	self.StartH_txt.text = math.floor(self.beginCD % 86400 / 3600)
	self.StartM_txt.text = math.floor(self.beginCD % 86400 % 3600 / 60)
	self.StartS_txt.text = math.floor(self.beginCD % 86400 % 3600 % 60 / 1)
end

--[[刷新功能，供Logic和model调用，重复性操作]]
function DdzMillionHallPanel:MyRefresh()
	if DdzMillionModel.dbwg_match_list then
		dbwg_match_list = DdzMillionModel.dbwg_match_list
		local data = DdzMillionModel.dbwg_match_list
		self.CenterRect.gameObject:SetActive(true)

		self.HintImage.gameObject:SetActive(true)
		self.AwardHintText.text = "￥" ..math.floor(data.bonus / 100)
		self.signupCD = tonumber(data.signup_time) - os.time()
		self.beginCD =  tonumber(data.begin_time) - os.time()
		-- self.TimeText.text = DdzMillionModel.ToTimeH2M2(data.signup_time) .. " 报名 " .. DdzMillionModel.ToTimeH2M2(data.begin_time) .. " 开赛"
		-- self.DateText.text = DdzMillionModel.ToTimeM2D2(data.signup_time)
		self.EndText.gameObject:SetActive(false)
		if data.status == 0 then
			self.HintImage.gameObject:SetActive(false)
			self.AwardHintText.text = ""
			self.SignupCountDown.gameObject:SetActive(false)
			self.StartCountDown.gameObject:SetActive(false)
		elseif data.status == 1 then
			self.HintImage.sprite = GetTexture("million_imgf_remind")
			self.HintImage:SetNativeSize()
			self.SignupCountDown.gameObject:SetActive(true)
			self.StartCountDown.gameObject:SetActive(false)
		elseif data.status == 2 then
			self.HintImage.sprite = GetTexture("million_imgf_apply")
			self.HintImage:SetNativeSize()
			self.SignupCountDown.gameObject:SetActive(false)
			self.StartCountDown.gameObject:SetActive(true)
		elseif data.status == 3 then
			self.HintImage.sprite = GetTexture("million_imgf_kasai")
			self.HintImage:SetNativeSize()
			self.EndText.gameObject:SetActive(true)
			self.SignupCountDown.gameObject:SetActive(false)
			self.StartCountDown.gameObject:SetActive(false)
		elseif data.status == 4 then
			self.HintImage.sprite = GetTexture("million_imgf_kasai")
			self.HintImage:SetNativeSize()
			self.EndText.gameObject:SetActive(true)
			self.SignupCountDown.gameObject:SetActive(false)
			self.StartCountDown.gameObject:SetActive(false)
		end

		
		self:RefreshMoney()
		self:RefreshRebirth()

		if DdzMillionModel.CheckRank() then
			self:RefreshRankList(DdzMillionRankModel.rank_list)
			self:RefreshMyRank(DdzMillionRankModel.my_rank)
		else
			Network.SendRequest("dbwg_bonus_rank_list", nil)
		end

		if MainModel.UserInfo.million_fuhuo_ticket and MainModel.UserInfo.cash then
			self:RefreshMoney()
			self:RefreshRebirth()
		else
			Network.SendRequest("query_asset", nil)
		end
	else
		if not have_Jh then
			have_Jh = "ddz_match_hall_jh"
			FullSceneJH.Create("正在请求房间数据",have_Jh)
		end
		Network.SendRequest("dbwg_req_game_list")
	end
end

-- 清空排行
function DdzMillionHallPanel:CloseRankList()
	for i,v in ipairs(self.RankList) do
		GameObject.Destroy(v.gameObject)
	end
	self.RankList = {}
end

--[[退出功能，供logic和model调用，只做一次]]
function DdzMillionHallPanel:MyExit()
	DdzMillionLogic.clearViewMsgRegister(listerRegisterName)
	lister = nil
	Event.RemoveListener("AssetChange",self.updateAssetInfoHandler)
	--closePanel(DdzMillionHallPanel.name)
end
function DdzMillionHallPanel:MyClose()
    self:MyExit()
    closePanel(DdzMillionHallPanel.name)
end

-- UI关注的事件
function DdzMillionHallPanel:MakeLister()
	lister = {}
	lister["dbwgModel_dbwg_req_game_list_response"] = basefunc.handler(self, self.RecGameList)
	lister["dbwgModel_dbwg_signup_fail_response"] = basefunc.handler(self, self.dbwgModel_dbwg_signup_fail_response)
	lister["dbwgModel_dbwg_bonus_rank_list_response"] = basefunc.handler(self, self.dbwgModel_dbwg_bonus_rank_list_response)
	
	lister["main_model_query_asset_response"] =  basefunc.handler(self, self.main_model_query_asset_response)	
end

-- 更新排行
function DdzMillionHallPanel:RefreshRankList(data)
	self:CloseRankList()
	for k,v in pairs(data) do
		self:CreateItem(v)
	end
end

function DdzMillionHallPanel:RefreshMyRank(data)
	if data and #data > 0 then
		self.MyRankText.text = data.rank
		self.MyNameText.text = data.name
		self.MyMoneyText.text = "¥" .. math.floor(data.bonus / 100) or "0"
	else
		self.MyRankText.text = "--"
		self.MyNameText.text = MainModel.UserInfo.name
		self.MyMoneyText.text = "¥0"
	end
end

function DdzMillionHallPanel:RefreshMoney()
	if MainModel.UserInfo.cash then
		self.MyAllMoneyText.text = "¥" .. StringHelper.ToCash(MainModel.UserInfo.cash/100)
	else
		self.MyAllMoneyText.text = "¥-"
	end
end


function DdzMillionHallPanel:RefreshRebirth()
	if MainModel.UserInfo.million_fuhuo_ticket then
		self.RebirthNumText.text =  MainModel.UserInfo.million_fuhuo_ticket
	else
		self.RebirthNumText.text = "-"
	end
end

-- 创建入口Item
function DdzMillionHallPanel:CreateItem(data)
	local obj = GameObject.Instantiate(self.RankItem, self.Content)
	self.RankList[#self.RankList + 1] = obj
	local tran = obj.transform
	obj.gameObject:SetActive(true)

	local RankImage = tran:Find("RankImage"):GetComponent("Image")
	local RankDB = tran:Find("RankDB")
	local RankText = tran:Find("RankDB/RankText"):GetComponent("Text")
	local NameText = tran:Find("NameText"):GetComponent("Text")
	local MoneyText = tran:Find("MoneyText"):GetComponent("Text")

	if data.rank == 1 then
		RankImage.sprite = GetTexture("million_icon_first")
		RankImage.gameObject:SetActive(true)
		RankDB.gameObject:SetActive(false)
	elseif data.rank == 2 then
		RankImage.sprite = GetTexture("million_icon_second")
		RankImage.gameObject:SetActive(true)
		RankDB.gameObject:SetActive(false)
	elseif data.rank == 3 then
		RankImage.sprite = GetTexture("million_icon_third")
		RankImage.gameObject:SetActive(true)
		RankDB.gameObject:SetActive(false)
	else
		RankImage.gameObject:SetActive(false)
		RankDB.gameObject:SetActive(true)
		RankText.text = "" .. data.rank
	end
	NameText.text = "" .. data.name
	MoneyText.text = string.format("￥%0.2f",(data.bonus / 100))
end

--退出
function DdzMillionHallPanel:OnBackClick( go )
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	local hall_type = MatchModel.GetCurHallType()
    if hall_type then
        local scene_name = GameConfigToSceneCfg.game_MatchHall.SceneName
        local parm = {hall_type = hall_type}
        MainLogic.GotoScene(scene_name,parm)
    else
		MainLogic.GotoScene("game_Hall")
	end
end
function DdzMillionHallPanel:OnApplyClick( go )

	Network.SendRequest("dbwg_query_shared_status", nil, "", function (data)
		if data.result == 0 then
			if data.status == 0 then

			else
				self:CallApply()
			end
		else
			HintPanel.ErrorMsg(data.result)
		end
	end)
end
function DdzMillionHallPanel:ShareFinishCall()
end
function DdzMillionHallPanel:CallApply()
	local data = dbwg_match_list

	if not data then
		data = {status = 0}
	end

	if data.status == 0 then
		HintPanel.Create(1, "没有比赛")
	elseif data.status == 1 then
		HintPanel.Create(1, "我们将在开始报名时提醒您")
	elseif data.status == 2 then
		Network.SendRequest("dbwg_signup",{id = 1})
		if not have_Jh then
			have_Jh="ddz_million_hall_jh"
			FullSceneJH.Create("正在报名",have_Jh)
		end
	elseif data.status == 3 then
		HintPanel.Create(1, "比赛已开始")
	elseif data.status == 4 then
		HintPanel.Create(1, "比赛已结束")
	end
end
function DdzMillionHallPanel:OnGetMoneyClick( go )
	if MainModel.UserInfo.cash < 100 then
		HintPanel.Create(1, "提现金额不足")
		return
	end
	Network.SendRequest("withdraw_cash", {cash_type=1}, "发送请求", function (data)
		if data.result == 0 then
			self:RefreshMoney()
			LittleTips.Create("提现成功")
		else
			HintPanel.ErrorMsg(data.result)
		end
	end)
end
function DdzMillionHallPanel:OnInviteFriendClick( go )
end

--[[*********************
网络数据刷新
*********************--]]
function DdzMillionHallPanel:RecGameList(result)
	if have_Jh then
		FullSceneJH.RemoveByTag(have_Jh)
		have_Jh=nil
	end
	if result == 0 then		
		self:MyRefresh()
	else
		self.CenterRect.gameObject:SetActive(false)
		if have_Jh then
			FullSceneJH.RemoveByTag(have_Jh)
			have_Jh=nil
		end
		HintPanel.Create(1,"获取游戏列表失败\n"..result,function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			MainLogic.GotoScene("game_Hall")
		end)
	end
end

function DdzMillionHallPanel:dbwgModel_dbwg_signup_fail_response(result)
	HintPanel.ErrorMsg(result)
end

function DdzMillionHallPanel:dbwgModel_dbwg_bonus_rank_list_response(result)
	if DdzMillionRankModel.rank_list then
		self:RefreshRankList(DdzMillionRankModel.rank_list)
		self:RefreshMyRank(DdzMillionRankModel.my_rank)
	end
end

function DdzMillionHallPanel:main_model_query_asset_response(result)
	if result == 0 then
		self:RefreshMoney()
		self:RefreshRebirth()
	else
		-- HintPanel.Create(1,result )
	end
end

--[[刷新功能，供Logic和model调用，重复性操作]]
function DdzMillionHallPanel:RefreshAward()
	LuaHelper.GeneratingVar(self.awardObj.transform,  self)
	local matchList = dbwg_match_list
	if not matchList then 
		--没有数据 网络请求
		if not have_Jh then
			have_Jh="ddz_million_hall_jh"
			FullSceneJH.Create("正在请求数据",have_Jh)
		end
	else
		if have_Jh then
			FullSceneJH.RemoveByTag(have_Jh)
			have_Jh=nil
		end
		if matchList.issue then
			self.issue_txt.text = "恭喜你获得第" .. matchList.issue .. "期大奖赛奖励"
		end
		if matchList.bonus then
			self.gold_txt.text = "￥" .. math.floor(matchList.bonus / 100)
		else
			self.gold_txt.text = "￥0"
		end
	end
end

