local basefunc = require "Game/Common/basefunc"
CommonLotteryAnim = basefunc.class()
local C = CommonLotteryAnim
C.name = "CommonLotteryAnim"
--[[idle模式：循环开始
    lottery模式: 以常用规律做抽奖动作,在完成后执行回调
]]

local Anim_Data = {
	step1_time = 1.4,
	step2_time = 3.0,
	step3_time = 1.6,
}

--要求OBJS是一个从1开始的数组
--anim_way 是指动画遵循的路线
function C.Create(objs,todo,anim_way)
	return C.New(objs,todo,anim_way)
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

function C:ctor(objs,todo,anim_way)
	self:MakeLister()
    self.Timers = {}
    local func = function ()
        local d = {}
        for i = 1,#objs do
            d[i] = i
        end
        return d
    end
    self.anim_way = anim_way or func()
    self.todo = todo
    self.objs = objs
    self:Idle_Anim(1,#objs)
end

function C:Step1_Anim(startPos, Step, maxStep)
	local AnimationName = "Step1"
	startPos = startPos or 1
	maxStep = maxStep or #self.anim_way
	local _End = 0
	local Time = self:TimerCreator(function()	
		self:ShakeLotteryPraticSys(self.anim_way[startPos])
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
	maxStep = maxStep or #self.anim_way
	local _End = 0
	local Time = self:TimerCreator(function()
		self:ShakeLotteryPraticSys(self.anim_way[startPos])
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
	maxStep = maxStep or #self.anim_way
	local _End = 0
	local Time = self:TimerCreator(function()
		self:ShakeLotteryPraticSys(self.anim_way[startPos])
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
	maxStep = maxStep or #self.anim_way
	local constant_sec = 1
	local sec = 1
	local time_space = 0.1
	local During_Times = 10
	local Time = self:TimerCreator(function()
		if sec <= 0 then 
			self:ShakeLotteryPraticSys(self.anim_way[startPos])
			startPos = startPos + 1
			while startPos > maxStep do startPos = startPos - maxStep end
			sec = constant_sec 
		end
		sec = sec - time_space 
		if  self.Can_Run then
			self:OnFinshName(AnimationName, startPos)
		end
	end, time_space, -1, AnimationName)
	Time:Start()
end

function C:Twinkle_Anim(startPos, Step, maxStep)
	local AnimationName = "Twinkle"
	maxStep = maxStep or #self.anim_way
	local _End = 0
	local Time = self:TimerCreator(function()
		self:ShakeLotteryPraticSys(self.anim_way[startPos])
		_End = _End + 1
		while startPos > maxStep do startPos = startPos - maxStep end
		if _End >= Step then
			self:OnFinshName(AnimationName, startPos)
		end
	end, 0.33, Step, AnimationName)
	Time:Start()
end

function C:StopAllAnim()
	for k, v in pairs(self.Timers) do
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

function C:TimerCreator(func, duration, loop, animationName,scale,durfix)
	local timer = Timer.New(func, duration, loop)
	if self.Timers[animationName] then
		self.Timers[animationName]:Stop()
		self.Timers[animationName] = nil
	end
	self.Timers[animationName] = timer
	return timer
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
		self.Can_Run = false
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
		local step = self:GetStopStep(self.award_index, startPos)
		self:Step3_Anim(startPos, step)
	end
	if animationName == "Step3" then
		self:StopAllAnim()
		self:CloseAnimSound()
		self:Twinkle_Anim(startPos, 6)
	end
end

function C:EndLottery()
	if self.backcall then
		self.backcall()
		self.backcall = nil
	end
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

function C:OnDestroy()
	self:MyExit()
end

function C:ShakeLotteryPraticSys(pos)
    self.todo(self.objs[pos],pos)
end

--award_index 停到哪个位置
function C:GetStopStep(award_index,startPos)
	local index = 1
	for i = 1,#self.anim_way do
		if self.anim_way[i] == award_index then
			index = i
		end
	end
    if index then
        return 2 * #self.objs - startPos + index
    end
end
--开始 由
function C:StartLottery(award_index,backcall,anim_way)
	self.anim_way = anim_way
	dump(self.anim_way,"<color=red>111111111111111111111</color>")
    self.award_index = award_index
	self.Can_Run = true
	self.backcall = backcall
end

function C:SetBackCall(backcall)
   self.backcall = backcall
end

--就这么用
function C:Test()
	local objs = {}
	for i = 1,6 do 
		objs[i] = self["obj"..i]
	end
	local todo = function (obj,pos)
		for i = 1,#objs do
			local show = objs[i].transform:Find("@show")
			show.gameObject:SetActive(false)
		end
		local show = obj.transform:Find("@show")
		show.gameObject:SetActive(true)
		-- local t = Timer.New(function ()
		-- 	show.gameObject:SetActive(false)
		-- end,0.4,1)
		-- t:Start()
	end
	self.anim = CommonLotteryAnim.Create(objs,todo)
	self.kaishi_btn.onClick:AddListener(function ()
		self.anim:StartLottery(5,function ()
			print("<color=red>动画完成</color>")
		end)
	end)
end