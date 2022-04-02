local basefunc = require "Game/Common/basefunc"

NewPlayerActivityPanelBIG_New = basefunc.class()
local C = NewPlayerActivityPanelBIG_New
C.name = "NewPlayerActivityPanelBIG_New"
--配置相关
local config = SYSXRZSManager.config_new
--排行榜相关
--改动数据相关
local LOTTERY_TYPE = { "exclusive_newplayer" }
local RANK_TYPE = { "october_19_lottery_2_rank" }
local Timers = {}
local Anim_Data = {
	step1_time = 1.4,
	step2_time = 3.0,
	step3_time = 1.6,
}
local LotteryStr = "积分"
local His_Prefab = "CommonlotteryinfoPrefab"
-------------------

function C.Create(parent,backcall)
	return C.New(parent,backcall)
end
function C:AddMsgListener()
	for proto_name, func in pairs(self.lister) do
		Event.AddListener(proto_name, func)
	end
end
function C:MakeLister()
	self.lister = {}
	self.lister["AssetChange"] = basefunc.handler(self, self.OnAssetChange)
	self.lister["common_lottery_base_info_change"] = basefunc.handler(self, self.ReFreshInfo)
	self.lister["query_common_lottery_base_info_response"] = basefunc.handler(self, self.ReFreshInfo)
	self.lister["common_lottery_kaijaing_response"] = basefunc.handler(self, self.Get_KAIJIANG_info)
	self.lister["common_lottery_get_broadcast_response"] = basefunc.handler(self, self.GetBroadcast)
	self.lister["ExitScene"] = basefunc.handler(self, self.MyExit)
end
function C:RemoveListener()
	for proto_name, func in pairs(self.lister) do
		Event.RemoveListener(proto_name, func) 
	end
	self.lister = {}
end

function C:ctor(_parent,backcall)
	local parent = _parent or GameObject.Find("Canvas/LayerLv4").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.NoStart_By_Anim = true -- 通过动画判断是不是能够启动抽奖
	self.CanStart_By_Info_Ticket = false -- 通过服务器的抽奖券判断是不是能够启动抽奖
	self.CanStart_By_Info_Num = false -- 通过服务器的抽奖次数判断是不是能够启动抽奖
	self.Is_Open_Panel = true
	self.ShowText = {}
	self.Showhp={}
	self.backcall = backcall
	self.dengAnimator = self.transform:Find("deng"):GetComponent("Animator") 
	LuaHelper.GeneratingVar(self.transform, self)
	local Mapping = self:GetMapping(#config.Award)
	self.Mapping = Mapping
	self:InitLotteryBGUI(Mapping, config.Award)
	self:CloseAnimSound()
	self:MakeLister()
	self:AddMsgListener()
	self:Idle_Anim()
	self:OnButtonClick()
	self:InitHistroy_UI()
	self:SlowUpAnim()
	self:RandomToSent()
	self:InitUI()
	Network.SendRequest("query_common_lottery_base_info", { lottery_type = LOTTERY_TYPE[1] }, " ")
	if self:IsFristOpenThisPanel() then
		--self:OpenRank()
	end
	PlayerPrefs.SetInt("IsFristOpenThisPanel"..LOTTERY_TYPE[1]..MainModel.UserInfo.user_id..os.date("%Y%m%d", os.time()),1)
end

function C:InitUI()
	local t = MainModel.FirstLoginTime() + 7 * 86400 - os.time()
	self.time_txt.text = "距离活动结束："..StringHelper.formatTimeDHMS(t)
	self:InitCountTimer()
end

function C:OnButtonClick()
	self.help_btn.onClick:AddListener(
	function()
		self:OpenHelpPanel()
	end
	)
	self.close_btn.onClick:AddListener(
	function()
		self:Close()
	end
	)
	self.rank_btn.onClick:AddListener(
	function()
		self:OpenRank()
	end
	)
	self.start_lottery_btn.onClick:AddListener(
	function()
		if not self.CanStart_By_Info_Num then 
			HintPanel.Create(1,"您抽奖次数不足")
			return 
		end
		if not self.CanStart_By_Info_Ticket then 
			HintPanel.Create(1,LotteryStr.."不足,\n玩小游戏可获得"..LotteryStr.."！")
			return 
		end
		if self.NoStart_By_Anim == true then
			if VIPManager.get_vip_level() >= 1 then
				Network.SendRequest("common_lottery_kaijaing", { lottery_type = LOTTERY_TYPE[1] }, "")
			else
				HintPanel.Create(2,"您的VIP等级不足VIP1，无法参与，请前往提升VIP等级",function ()
					PayPanel.Create(GOODS_TYPE.jing_bi, "normal")
				end)
			end 
		end
	end
	)
end

function C:OpenHelpPanel()
	local str = config.DESCRIBE_TEXT[1].text
	for i = 2, #config.DESCRIBE_TEXT do
		str = str .. "\n" .. config.DESCRIBE_TEXT[i].text
	end
	self.introduce_txt.text = str
	IllustratePanel.Create({ self.introduce_txt.gameObject }, GameObject.Find("Canvas/LayerLv5").transform)
end

function C:OpenRank()
	
end

function C:Close()
	self:MyExit()
end

function C:Step1_Anim(startPos, Step, maxStep)
	local AnimationName = "Step1"
	self.dengAnimator:Play("fqj_deng")
	startPos = startPos or 1
	maxStep = maxStep or 10
	local _End = 0
	local Time = self:TimerCreator(function()
		while startPos > maxStep do startPos = startPos - maxStep end
		self:ShakeLotteryPraticSys(startPos)
		startPos = startPos + 1
		_End = _End + 1
		if _End >= Step then
			self:OnFinshName(AnimationName, startPos)
		end
	end, Anim_Data.step1_time / Step, -1, AnimationName)
	Time:Start()

end

function C:Step2_Anim(startPos, Step, maxStep)
	local AnimationName = "Step2"
	startPos = startPos or 1
	maxStep = maxStep or 10
	local _End = 0
	local Time = self:TimerCreator(function()
		while startPos > maxStep do startPos = startPos - maxStep end
		self:ShakeLotteryPraticSys(startPos)
		startPos = startPos + 1
		_End = _End + 1
		if _End >= Step then
			self:OnFinshName(AnimationName, startPos)
		end
	end, Anim_Data.step2_time / Step, -1, AnimationName)
	Time:Start()
end

function C:Step3_Anim(startPos, Step, maxStep)
	local AnimationName = "Step3"
	startPos = startPos or 1
	maxStep = maxStep or 10
	local _End = 0
	local Time = self:TimerCreator(function()
		while startPos > maxStep do startPos = startPos - maxStep end
		self:ShakeLotteryPraticSys(startPos)
		startPos = startPos + 1
		_End = _End + 1
		if _End >= Step then
			self:OnFinshName(AnimationName, startPos)
		end
	end, Anim_Data.step3_time / Step, -1, AnimationName)
	Time:Start()
end

function C:Idle_Anim(startPos, maxStep)
	local AnimationName = "Idle"
	self.dengAnimator:Play("fqj_deng2")
	startPos = startPos or 1
	maxStep = maxStep or 10
	local constant_sec = 1
	local sec = 1
	local time_space = 0.1
	local During_Times = 10
	local Time = self:TimerCreator(function()
		if sec <= 0 then  
			while startPos > maxStep do startPos = startPos - maxStep end
			self:ShakeLotteryPraticSys(startPos)
			startPos = startPos + 1
			sec = constant_sec 
		end
		sec = sec - time_space 
		if  not self.NoStart_By_Anim then
			self:OnFinshName(AnimationName, startPos)
		end
	end, time_space, -1, AnimationName)
	Time:Start()
end

function C:Twinkle_Anim(startPos, Step, maxStep)
	local AnimationName = "Twinkle"
	maxStep = maxStep or 10
	local _End = 0
	local Time = self:TimerCreator(function()
		while startPos > maxStep do startPos = startPos - maxStep end
		self:ShakeLotteryPraticSys(startPos)
		_End = _End + 1
		if _End >= Step then
			self:OnFinshName(AnimationName, startPos)
		end
	end, 0.33, Step, AnimationName)
	Time:Start()
end

function C:StopAllAnim()
	for k, v in pairs(Timers) do
		if v then
			v:Stop()
		end
	end
end

function C:GetMapping(max, disturb)
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

function C:InitLotteryBGUI(mapping, config_list)
	for i = 1, #mapping do
		local config = config_list[mapping[i]]
		self["lotteryitem" .. i].transform:Find("Text"):GetComponent("Text").text = self:LotteryType2Str(config.num, config.type)
		local Img = self["lotteryitem" .. i].transform:Find("awardimg"):GetComponent("Image")
		Img.sprite = GetTexture(config.img)
		Img:SetNativeSize()
	end
end

function C:LotteryType2Str(Num, type)
	if type == "jing_bi" then
		return Num .. "鲸币"
	elseif type == "jipaiqi" then
		return Num .. "记牌器"
	elseif type == "fish_coin" then
		return Num .. "鱼币"
	elseif type == "shop_gold_sum" then
		return Num/100 .. "福卡"
	else
		return type
	end
end

function C:TimerCreator(func, duration, loop, animationName,scale,durfix)
	local timer = Timer.New(func, duration, loop)
	if Timers[animationName] then
		Timers[animationName]:Stop()
		Timers[animationName] = nil
	end
	Timers[animationName] = timer
	return timer
end

function C:ShakeLotteryPraticSys(pos)
	self["lotteryitem" .. pos]:Find("fqj_kuang").gameObject:SetActive(false)
	self["lotteryitem" .. pos]:Find("fqj_kuang").gameObject:SetActive(true)  
end
--
function C:OnFinshName(animationName, startPos)
	if animationName == "Idle" then
		self:StopAllAnim()
		self:Step1_Anim(startPos, 7)
		self.curSoundKey = ExtendSoundManager.PlaySound(audio_config.game.bgm_duijihongbao.audio_name, 1, function()
			self.curSoundKey = nil
		end)
	end
	if animationName == "Twinkle" then
		self.NoStart_By_Anim = true
		self:StopAllAnim()
		self:EndLottery()
		self:Idle_Anim(startPos)
	end
	if animationName == "Step1" then
		self:StopAllAnim()
		self:Step2_Anim(startPos, 65)
	end
	if animationName == "Step2" then
		self:StopAllAnim()
		local award_index = self:GetAwardIndex(self.award_id)
		local step = self:GetStopStep(self.Mapping, award_index, startPos)
		self:Step3_Anim(startPos, step)
	end
	if animationName == "Step3" then
		self:StopAllAnim()
		self:CloseAnimSound()
		self:Twinkle_Anim(startPos, 6)
	end
end

function C:GetStopStep(mapping, award_index, startPos)
	for i = 1, #mapping do
		if mapping[i] == award_index then
			return 2 * #mapping + i - startPos
		end
	end
end

function C:GetAwardIndex(award_id)
	for    i = 1, #config.Award do
		if config.Award[i].server_award_id == award_id then
			return i
		end
	end
end

function C:Get_KAIJIANG_info(_, data)
	dump(data, "<color=red>Get_KAIJIANG_info</color>")
	if data and data.result == 0 then
		self.award_id = data.award_id
		self.NoStart_By_Anim = false
	end
end

function C:GetMask()
	if self.now_game_num > #config.Award then
		self.now_game_num = #config.Award
	end
	for i = 1, self.now_game_num do
		local _index = 1
		for j = 1, #self.Mapping do
			if self.Mapping[j] == i then
				_index = j
			end
		end
		self["lotteryitem" .. _index].transform:Find("getmask").gameObject:SetActive(true)
	end
end

function C:ReFreshInfo(_, data)
	dump(data, "<color=red>----------抽奖数据-----------</color>")
	if data == nil or data.ticket_num == nil or not IsEquals(self.gameObject) or not self:IsCurrLotteryType(data.lottery_type) then
		return
	end
	if data.now_game_num == nil then
		data.now_game_num = 0
	end
	self.CanStart_By_Info_Num = data.now_game_num < #config.Award - 5
	local now_game_num = data.now_game_num
	if now_game_num + 1 > #config.Award then
		now_game_num = now_game_num - 1
	end
	self.ticket_num = data.ticket_num
	self.need_credits = config.Award[now_game_num + 1].need_credits
	self.now_game_num = data.now_game_num
	self.expend_txt.text = self.need_credits..LotteryStr.."(剩余次数:"..5-self.now_game_num..")"
	self.current_txt.text = self.ticket_num
	self.CanStart_By_Info_Ticket = self.ticket_num >= self.need_credits

	if self.Is_Open_Panel then
		self:GetMask()
		self.Is_Open_Panel = false
	end
end

function C:EndLottery()
	if self.award_id ~= nil then
		Event.Brocast("AssetGet", self.cur_award)
		local award_index = self:GetAwardIndex(self.award_id)
		if config.Award[award_index].real == 1 then
			ExtendSoundManager.PlaySound(audio_config.game.bgm_hall_huodewupin.audio_name)
			RealAwardPanel.Create({ text = config.Award[award_index].type, image = config.Award[award_index].img })			
		end
		local hp = newObject(His_Prefab, self.ShowContent)
		hp.transform:Find("Text"):GetComponent("Text").text = self:GetUserName() .. "抽中了" .. self:LotteryType2Str(config.Award[award_index].num, config.Award[award_index].type)
		self.award_id = nil
		self.cur_award = nil
		self:GetMask()
	end
end

function C:OnAssetChange(data)
	dump(data, "<color=red>----奖励类型-----</color>")
	if data.change_type and data.change_type == "common_lottery_" .. LOTTERY_TYPE[1] then
		self.cur_award = data
	end
end

function C:MyExit()
	if self.backcall then 
		self.backcall()
	end 
	if self.RandomToSent_Timer  then
		self.RandomToSent_Timer:Stop()
	end
	if self.SlowUP_Timer then
		self.SlowUP_Timer:Stop()
	end
	if self.CountTimer then 
		self.CountTimer:Stop()
	end  
	self:StopAllAnim()
	self:EndLottery()
	self:SetHistroyInLocal()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:CloseAnimSound()
	if self.curSoundKey then
		soundMgr:CloseLoopSound(self.curSoundKey)
		self.curSoundKey = nil
	end
end

function C:GetBroadcast(_, data)
	dump(data,"<color=red>GetBroadcast</color>")
	if IsEquals(self.gameObject) and data.award_id then   
		local award_index =  self:GetAwardIndex(data.award_id)
		local hp = newObject(His_Prefab, self.ShowContent)
		hp.transform:Find("Text"):GetComponent("Text").text = data.player_name .. "抽中了" .. self:LotteryType2Str(config.Award[award_index].num, config.Award[award_index].type)
		self.Showhp[#self.Showhp + 1] = hp																	
		self.ShowText[#self.ShowText + 1] = data.player_name .. "抽中了" .. self:LotteryType2Str(config.Award[award_index].num, config.Award[award_index].type)
	end
end

function C:SlowUpAnim()
	if self.SlowUP_Timer then
		self.SlowUP_Timer:Stop()
	end 
	self.SlowUP_Timer = Timer.New(function()
		self.ShowContent.transform:Translate(Vector3.up * 0.1 )
	end, 0.016, -1,nil,true)
	self.SlowUP_Timer:Start()
end



function C:InitHistroy_UI()
	for i = 1, PlayerPrefs.GetInt(LOTTERY_TYPE[1], 0) do
		if PlayerPrefs.GetString(LOTTERY_TYPE[1] .. i, "") ~= "" then
			local hp = newObject(His_Prefab, self.ShowContent)
			hp.transform:Find("Text"):GetComponent("Text").text = PlayerPrefs.GetString(LOTTERY_TYPE[1] .. i, "")
			self.Showhp[#self.Showhp + 1] = hp
			self.ShowText[#self.ShowText + 1] = PlayerPrefs.GetString(LOTTERY_TYPE[1] .. i, PlayerPrefs.GetString(LOTTERY_TYPE[1] .. i, ""))    
		end
	end
end

function C:SetHistroyInLocal()
	local ShowTextLengh = #self.ShowText
	if ShowTextLengh > 20 then
		ShowTextLengh = 20
	end
	PlayerPrefs.SetInt(LOTTERY_TYPE[1], ShowTextLengh)
	for i = ShowTextLengh, 1, -1 do
		if self.ShowText[#self.ShowText + i - ShowTextLengh] ~= "" then
			PlayerPrefs.SetString(LOTTERY_TYPE[1] .. i, self.ShowText[#self.ShowText + i - ShowTextLengh])
		end
	end
	self.ShowText = {}
	self.Showhp = nil
end

function C:SentBroadcast()
	if  IsEquals(self.gameObject) then
		Network.SendRequest("common_lottery_get_broadcast", { lottery_type = LOTTERY_TYPE[1] }, "")
	end
end

function C:RandomToSent()
	if self.RandomToSent_Timer  then
		self.RandomToSent_Timer:Stop()
	end
	self.RandomToSent_Timer=nil
	math.randomseed(os.time())
	local t=math.random(3,6)
	self.RandomToSent_Timer=Timer.New(function ()
			self:RandomToSent()
			self:SentBroadcast()	
		end
	,t,-1,nil,true)
	self.RandomToSent_Timer:Start()
end

function C:GetUserName()
	self.localname = ""
	local v=basefunc.string.string_to_vec(MainModel.UserInfo.name)
	if v then
		for  i=1,#v do
			if i <= 4 then
				self.localname= self.localname .. v[i]
			else
				break
			end
		end
	end
	return  self.localname
end

function C:IsCurrLotteryType(lottery_type)
	for i=1,#LOTTERY_TYPE do
		if lottery_type == LOTTERY_TYPE[i] then
			return true
		end 
	end
	return false
end

function C:IsFristOpenThisPanel()
	if  PlayerPrefs.GetInt("IsFristOpenThisPanel"..LOTTERY_TYPE[1]..MainModel.UserInfo.user_id..os.date("%Y%m%d", os.time()),0) == 0  then 
		return true
	else
		return false
	end
end

function C:InitCountTimer()
	if self.CountTimer then 
		self.CountTimer:Stop()
	end 
	self.CountTimer = Timer.New(
		function ()
			local t = MainModel.FirstLoginTime() + 7 * 86400 - os.time()
			if IsEquals(self.time_txt.gameObject) then 
				self.time_txt.text = "距离活动结束："..StringHelper.formatTimeDHMS(t)
			end 
		end
	,1,-1)
	self.CountTimer:Start()
end

function C:OnDestroy()
	self:MyExit()
end