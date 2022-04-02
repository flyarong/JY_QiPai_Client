local basefunc = require "Game/Common/basefunc"
ActHQYDPanel = basefunc.class()
local C = ActHQYDPanel
C.name = "ActHQYDPanel"
local M  = HQYDManager

--改动数据相关
local LOTTERY_TYPE = { "ceremony_lottery" }
local Timers = {}
local Anim_Data = {
	step1_time = 1.4,
	step2_time = 3.0,
	step3_time = 1.6,
}
local LotteryStr = "积分"

local sw_award ={
	[7008] = {image = "activity_icon_gift99_spz",text = "手帕纸"},
	[7009] = {image = "activity_icon_gift66",text = "香软大米"},
	[7010] = {image = "activity_icon_gift100_qnq",text = "电暖器"},
}

local box_tips = {
	[1] = "宝箱可随机开出：\n手帕纸,10福卡,5福卡,1福卡\n1万鲸币,5000鲸币,3000鲸币,1000鲸币",
	[2] = "宝箱可随机开出：\n香软大米,手帕纸,10福卡,5福卡\n1福卡,1万鲸币,5000鲸币,3000鲸币,1000鲸币",
	[3] = "宝箱可随机开出：\n电暖器,香软大米,手帕纸,10福卡\n5福卡,1福卡,1万鲸币,5000鲸币\n3000鲸币,1000鲸币",
	[4] = "宝箱可随机开出：\nOPPO手机,电暖器,香软大米,手帕纸\n10福卡,5福卡,1福卡,1万鲸币\n5000鲸币,3000鲸币,1000鲸币",
}

local DESCRIBE_TEXT = {
	[1] = "1.活动时间：2020年1月1日07点30-2020年1月6日23点59分；",
	[2] = "2.活动期间，玩小游戏累计赢金也可获得积分，消消乐和敲敲乐游戏每累计赢金10000获得1积分，捕鱼类游戏每累计赢金20000获得1积分；",
	[3] = "3.请及时使用您的积分和活动字符，活动结束后积分和活动字符将自动清除；",
	[4] = "4.实物奖励，请在活动结束后7个工作日内联系客服QQ：4008882620领取，否则视为自动放弃奖励；",
	[5] = "5.实物奖励将在活动结束后7天内统一发放。",
}

local anim_way = {
	1,2,3,4,5,6,7,8,9,
}
local img_data
local zi_data 

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
	self.lister["global_hint_state_change_msg"] = basefunc.handler(self,self.Refresh_JF)
	self.lister["box_exchange_response"] = basefunc.handler(self,self.on_box_exchange_response)
	self.lister["ExitScene"] = basefunc.handler(self, self.MyExit)
end
function C:RemoveListener()
	for proto_name, func in pairs(self.lister) do
		Event.RemoveListener(proto_name, func) 
	end
	self.lister = {}
end

function C:ctor(_parent,backcall)

	ExtPanel.ExtMsg(self)

	local parent = _parent or GameObject.Find("Canvas/LayerLv4").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.NoStart_By_Anim = true -- 通过动画判断是不是能够启动抽奖
	self.CanStart_By_Info_Ticket = false -- 通过服务器的抽奖券判断是不是能够启动抽奖
	self.CanStart_By_Info_Num = false -- 通过服务器的抽奖次数判断是不是能够启动抽奖
	self.box_anim = true -- 打开面板时，默认当满足条件可以开始宝箱 
	self.Is_Open_Panel = true
	img_data = M.GetData()
	zi_data = {img_data.xin.img,img_data.nian.img,img_data.kuai.img,img_data.le.img,img_data.shu.img,img_data.yuan.img,img_data.dan.img,img_data.fa.img,img_data.cai.img}
	self.ShowText = {}
	self.Showhp={}
	self.backcall = backcall 
	LuaHelper.GeneratingVar(self.transform, self)
	local Mapping = self:GetMapping(9)
	self.Mapping = Mapping
	self:InitLotteryBGUI(Mapping)
	self:CloseAnimSound()
	self:MakeLister()
	self:AddMsgListener()
	self:Idle_Anim()
	self:OnButtonClick()
	self:InitTips()
	self:InitUI()
	self:ReFreshInfo()
	self.my_txt.gameObject.transform.anchorMin = Vector2.New(0.5,0.5)
	self.my_txt.gameObject.transform.anchorMax  = Vector2.New(0.5,0.5)
	self.my_txt.gameObject.transform.pivot  = Vector2.New(0.5,0.5)
	self.my_txt.gameObject.transform.localPosition = Vector2.New(-506,285.6)
end

function C:InitUI()

end

function C:InitLotteryBGUI(mapping)
	for i = 1, #mapping do
		self["lotteryitem" .. i].transform:Find("awardimg"):GetComponent("Image").sprite = GetTexture(zi_data[mapping[i]])
	end
end

function C:OnButtonClick()
	self.start_lottery_btn.onClick:AddListener(
		function()
			self.my_txt.text = "我的积分：".. M.GetJF()
			if self.NoStart_By_Anim then
				if M.GetJF() >= 50 then 
					Network.SendRequest("box_exchange",{id = 6,num = 1})
				else
					HintPanel.Create(1,"您的积分不足，快去玩小游戏赚取积分吧！")
				end 
			end
		end
	)
	self.start_lottery2_btn.onClick:AddListener(
		function()
			self.my_txt.text = "我的积分：".. M.GetJF()
			if self.NoStart_By_Anim then
				if M.GetJF() >= 500 then 
					Network.SendRequest("box_exchange",{id = 6,num = 10})
				else
					HintPanel.Create(1,"您的积分不足，快去玩小游戏赚取积分吧！")
				end 
			end
		end
	)
	for i=1,4 do
		self["box"..i.."_btn"].onClick:AddListener(
			function ()
				self:OpenBox(i)
			end
		)
	end
	self.close_btn.onClick:AddListener(
		function ()
			self:MyExit()
		end
	)
	self.help_btn.onClick:AddListener(
		function ()
			self:OpenHelpPanel()
		end
	)
	self.show_list_btn.onClick:AddListener(
		function ()
			HQYDListPanel.Create()
		end
	)
end

function C:Close()
	self:MyExit()
end

function C:Step1_Anim(startPos, Step, maxStep)
	local AnimationName = "Step1"
	startPos = startPos or 1
	maxStep = maxStep or #anim_way
	local _End = 0
	local Time = self:TimerCreator(function()	
		self:ShakeLotteryPraticSys(anim_way[startPos])
		startPos = startPos + 1
		_End = _End + 1
		while startPos > maxStep do startPos = startPos - maxStep end
		if _End >= Step then
			self:OnFinshName(AnimationName, startPos)
		end
	end, Anim_Data.step1_time / Step, -1, AnimationName)
	Time:Start()

end

function C:Step2_Anim(startPos, Step, maxStep)
	local AnimationName = "Step2"
	startPos = startPos or 1
	maxStep = maxStep or #anim_way
	local _End = 0
	local Time = self:TimerCreator(function()
		self:ShakeLotteryPraticSys(anim_way[startPos])
		startPos = startPos + 1
		_End = _End + 1
		while startPos > maxStep do startPos = startPos - maxStep end
		if _End >= Step then
			self:OnFinshName(AnimationName, startPos)
		end
	end, Anim_Data.step2_time / Step, -1, AnimationName)
	Time:Start()
end

function C:Step3_Anim(startPos, Step, maxStep)
	local AnimationName = "Step3"
	startPos = startPos or 1
	maxStep = maxStep or #anim_way
	local _End = 0
	local Time = self:TimerCreator(function()
		self:ShakeLotteryPraticSys(anim_way[startPos])
		startPos = startPos + 1
		_End = _End + 1
		while startPos > maxStep do startPos = startPos - maxStep end
		if _End >= Step then
			self:OnFinshName(AnimationName, startPos)
		end
	end, Anim_Data.step3_time / Step, -1, AnimationName)
	Time:Start()
end

function C:Idle_Anim(startPos, maxStep)
	local AnimationName = "Idle"
	startPos = startPos or 1
	maxStep = maxStep or #anim_way
	local constant_sec = 1
	local sec = 1
	local time_space = 0.1
	local During_Times = 10
	local Time = self:TimerCreator(function()
		if sec <= 0 then 
			self:ShakeLotteryPraticSys(anim_way[startPos])
			startPos = startPos + 1
			while startPos > maxStep do startPos = startPos - maxStep end
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
	maxStep = maxStep or #anim_way
	local _End = 0
	local Time = self:TimerCreator(function()
		self:ShakeLotteryPraticSys(anim_way[startPos])
		_End = _End + 1
		while startPos > maxStep do startPos = startPos - maxStep end
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
	self["lotteryitem" .. pos]:GetComponent("Image").sprite = GetTexture("hqyd_bg_hqyd1")
	self["lotteryitem" .. pos]:GetComponent("Image").sprite = GetTexture("hqyd_bg_hqyd2")
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
		local award_index = self.award_id - 6000
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
	dump(mapping,"<color=red>mapping</color>")
	dump(award_index,"<color=red>award_index</color>")
	dump(startPos,"<color=red>startPos</color>")
	for i = 1, #mapping do
		if mapping[i] == award_index then
			return 2 * #anim_way + i - startPos
		end
	end
end

function C:Get_KAIJIANG_info(_, data)
	dump(data, "<color=red>Get_KAIJIANG_info</color>")
end


function C:ReFreshInfo()
	local type = M.GetLimitType()
	local num  = M.GetLimitNum() 
	for i=1,4 do
		for j=1,4 do 
			self[i.."_"..j.."_txt"].text = type[i][j].num.."/"..num[i][j]
			if type[i][j].num >= num[i][j] then 
				self[i.."_"..j.."_img"].sprite = GetTexture(type[i][j].img)
			else
				self[i.."_"..j.."_img"].sprite = GetTexture(type[i][j].not_img)
			end 
		end
		if M.IsCanOpenBox(i) then 
			self["box"..i.."_btn"].gameObject.transform:GetComponent("Animator"):Play("@box_yuandan_2")
		else
			self["box"..i.."_btn"].gameObject.transform:GetComponent("Animator"):Play("@box_yuandan")
		end 
	end
	self.my_txt.text = "我的积分：".. M.GetJF()
end

function C:EndLottery()
	if self.Award_Data then 
		Event.Brocast("AssetGet",self.Award_Data)
		self.Award_Data = nil
		self:ReFreshInfo()
	end 
end

function C:OnAssetChange(data)
	dump(data, "<color=red>----奖励类型-----</color>")
	if data.change_type and data.change_type == "box_exchange_active_award_6" and not table_is_null(data.data) then
		self.Award_Data = data
		if #data.data ~= 1 then
			Event.Brocast("AssetGet",self.Award_Data) 
			self.Award_Data = nil
			self:ReFreshInfo()
		end 
	end
	if data.change_type and data.change_type == "box_exchange_active_award_7" and not table_is_null(data.data) then
		self.box_award_data = data
		self:TryToShowAward()
	end
	if data.change_type and data.change_type == "box_exchange_active_award_8" and not table_is_null(data.data) then
		self.box_award_data = data
		self:TryToShowAward()
	end
	if data.change_type and data.change_type == "box_exchange_active_award_9" and not table_is_null(data.data) then
		self.box_award_data = data
		self:TryToShowAward()
	end
	if data.change_type and data.change_type == "box_exchange_active_award_10" and not table_is_null(data.data) then
		self.box_award_data = data
		self:TryToShowAward()
	end
	self.my_txt.text = "我的积分：".. M.GetJF()
end

function C:MyExit()
	if self.backcall then 
		self.backcall()
	end 

	if self.SlowUP_Timer then
		self.SlowUP_Timer:Stop()
	end
	if self.CountTimer then 
		self.CountTimer:Stop()
	end  
	self:StopAllAnim()
	self:EndLottery()
	self:RemoveListener()
	destroy(self.gameObject)

	 
end

function C:CloseAnimSound()
	if self.curSoundKey then
		soundMgr:CloseLoopSound(self.curSoundKey)
		self.curSoundKey = nil
	end
end
function C:SentBroadcast()

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

end

function C:OnDestroy()
	self:MyExit()
end

function C:OpenHelpPanel()
    local str = DESCRIBE_TEXT[1]
    for i = 2, #DESCRIBE_TEXT do
        str = str .. "\n" .. DESCRIBE_TEXT[i]
    end
    self.introduce_txt.text = str
    IllustratePanel.Create({ self.introduce_txt.gameObject }, GameObject.Find("Canvas/LayerLv5").transform)
end

function C:InitTips()
	for i=1,4 do
		PointerEventListener.Get(self["box"..i.."_btn"].gameObject).onDown = function ()
	        GameTipsPrefab.ShowDesc(box_tips[i], UnityEngine.Input.mousePosition)
	    end
		PointerEventListener.Get(self["box"..i.."_btn"].gameObject).onUp = function ()
	        GameTipsPrefab.Hide()
	    end
	end
end

function C:on_box_exchange_response(_,data)
	dump(data,"<color=red>开奖数据-------------</color>")
	if data.result == 0 then
		if data.id == 6 then
			if #data.award_id == 1 then 
				self.award_id = data.award_id[1]
				self.NoStart_By_Anim = false
			end 
		elseif data.id <= 10 and  data.id >= 6 then 
			if sw_award[data.award_id[1]] then 
				self.real = sw_award[data.award_id[1]]
				self:TryToShowAward()
			end 
		end 
	end 
end

function C:OpenBox(index)
	if M.IsCanOpenBox(index) and self.box_anim then
		self.box_anim = false 
		Network.SendRequest("box_exchange",{id = 6 + index,num = 1})
		self["box"..index.."_btn"].gameObject.transform:GetComponent("Animator"):Play("@box_yuandan_3")
		if self.box_anim_timer then 
			self.box_anim_timer:Stop()
		end 
		self.box_anim_timer = Timer.New(function ()
			self.box_anim = true
			self:TryToShowAward()
		end,1.2,1)
		self.box_anim_timer:Start()
	end
end

function C:TryToShowAward()
	if self.box_award_data and self.box_anim then 
		Event.Brocast("AssetGet",self.box_award_data)
		self.box_award_data = nil
		self:ReFreshInfo()
		return 
	end
	if self.real and self.box_anim then 
		RealAwardPanel.Create(self.real)
		self.real = nil
		self:ReFreshInfo() 
		return 
	end
end

function C:Refresh_JF()
	self.my_txt.text = "我的积分：".. M.GetJF()
end