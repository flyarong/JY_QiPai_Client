local basefunc = require "Game/Common/basefunc"
EliminateCSZPGamePanel = basefunc.class()
local C = EliminateCSZPGamePanel
C.name = "EliminateCSZPGamePanel"
local instance
--改动数据相关
local Timers = {}
local Anim_Data = {
	step1_time = 1.4,
	step2_time = 3.0,
	step3_time = 1.6,
}

local Is_Random_Order = false

local anim_way = {
	1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16
}

local sky_girl_image = {
	[1] = "csxxl_icon_11",
	[2] = "csxxl_icon_12",
	[3] = "csxxl_icon_13",
}
local sky_girl_desc = {
	"金花",
	"银花",
	"铜花",
}
function C.Create(data,config,backcall,state)
	if instance then
		C.Close()
	end
	instance = C.New(data,config,backcall,state)
	return instance
end

function C.Close()
	if instance then
		instance:MyExit()
	end
end

function C:AddMsgListener()
	for proto_name, func in pairs(self.lister) do
		Event.AddListener(proto_name, func)
	end
end
function C:MakeLister()
	self.lister = {}
	self.lister["ExitScene"] = basefunc.handler(self, self.MyExit)
end
function C:RemoveListener()
	for proto_name, func in pairs(self.lister) do
		Event.RemoveListener(proto_name, func) 
	end
	self.lister = {}
end

function C:ctor(data,config,backcall,state)

	ExtPanel.ExtMsg(self)

	local parent = GameObject.Find("Canvas/LayerLv1").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.backcall = backcall
	self.config = config
	if data then
		self.Index = data.index
	end
	for i,v in ipairs(self.config) do
		if self.Index == v.id then
			self.Index = i
			break
		end
	end

	self.NoStart_By_Anim = true
	LuaHelper.GeneratingVar(self.transform, self)
	local Mapping = Is_Random_Order and self:GetMapping(16) or anim_way
	self.Mapping = Mapping
	self:InitLotteryBGUI(Mapping)
	self:CloseAnimSound()
	self:MakeLister()
	self:AddMsgListener()
	self:Idle_Anim()
	self:OnButtonClick()
	self:InitUI(state)
	if state then
		self:StartLottery()
	end
end

function C:StartLottery()
	Timer.New(function() 
		self.NoStart_By_Anim = false
	end ,2.5,1):Start()
end

function C:InitUI(state)
	if state then
		ExtendSoundManager.PlaySceneBGM(audio_config.csxxl.bgm_csxxl_caishenyaojiang.audio_name,true)
	end
	self.back_btn.gameObject:SetActive(not state)
	self.hint_txt.gameObject:SetActive(not state)
	self.back_btn.onClick:AddListener(
		function ()
			self:MyExit()
		end
	)
end

function C:InitLotteryBGUI(mapping)
	for i = 1, #mapping do
		local config = self.config[mapping[i]]
		self["lotteryitem" .. i].transform:Find("Text"):GetComponent("Text").text = self:LotteryType2Str(config)
		local Img = self["lotteryitem" .. i].transform:Find("awardimg"):GetComponent("Image")
		Img.sprite = GetTexture(self:LotteryType2Ima(config))
		config.scale = config.scale or 1
		Img.transform.localScale = Vector3.one * config.scale
		Img:SetNativeSize()
	end
end

function C:OnButtonClick()
	
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
	local time_space = 0.05
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

function C:LotteryType2Str(config_item)
	if config_item.award_type == "jing_bi" then
		return StringHelper.ToCash(config_item.rate  *  EliminateCSModel.GetBet()[1]) .. config_item.name
	elseif config_item.award_type == "sky_girl" then
		return config_item.name
	else
		return config_item.name
	end
end

function C:LotteryType2Ima(config_item)
	if true then return config_item.image end
	if config_item.award_type == "jing_bi" then
		return "com_award_icon_jingbi"
	elseif config_item.award_type == "sky_girl" then
		return sky_girl_image[config_item.rate]
	else
		return config_item.award_type
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
	self["lotteryitem" .. pos]:Find("choujiang_zoumadeng_jin").gameObject:SetActive(false)
	self["lotteryitem" .. pos]:Find("choujiang_zoumadeng_jin").gameObject:SetActive(true)
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
		local award_index = self.Index
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

function C:EndLottery()
	if self.config[self.Index].award_type == "sky_girl" then 
		Event.Brocast("AssetGet",{data = {[1] = {desc = sky_girl_desc[self.config[self.Index].rate],image = sky_girl_image[self.config[self.Index].rate]}},
		callback = function ()
			if not self.config then return end
			Event.Brocast("view_xxl_caishen_tnsh_kj",{rate = self.config[self.Index].rate})
			EliminateCSPartManager.CreateZaDanComplete(self.config[self.Index].rate)
			local seq = DoTweenSequence.Create()
			seq:AppendInterval(EliminateCSModel.time.xc_zp_xs)
			seq:OnForceKill(function ()
				if self.backcall then 
					self.backcall()
				end
				self:MyExit()
				ExtendSoundManager.PlaySceneBGM(audio_config.csxxl.bgm_csxxl_tiannvsanhuabeijing.audio_name,true)
			end)
		end,skip_data = true})
	else
		Event.Brocast("AssetGet",{data = {{asset_type=self.config[self.Index].award_type, value=self.config[self.Index].rate  * EliminateCSModel.GetBet()[1]}},
		callback = function ()
			if self.backcall then 
				self.backcall()
			end
			self:MyExit()
			ExtendSoundManager.PlaySceneBGM(audio_config.csxxl.bgm_csxxl_beijing.audio_name,true)
		end})	
	end 
end

function C:MyExit()
	if self.CountTimer then 
		self.CountTimer:Stop()
	end  
	self:StopAllAnim()
	self:RemoveListener()
	destroy(self.gameObject)
	instance = nil

	 
end

function C:CloseAnimSound()
	if self.curSoundKey then
		soundMgr:CloseLoopSound(self.curSoundKey)
		self.curSoundKey = nil
	end
end

function C:OnDestroy()
	self:MyExit()
end



