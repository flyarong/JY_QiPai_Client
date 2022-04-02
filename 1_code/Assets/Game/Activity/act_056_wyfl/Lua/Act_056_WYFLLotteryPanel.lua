-- 创建时间:2020-05-12
-- Panel:Act_056_WYFLLotteryPanel
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
--]]

local basefunc = require "Game/Common/basefunc"

Act_056_WYFLLotteryPanel = basefunc.class()
local C = Act_056_WYFLLotteryPanel
C.name = "Act_056_WYFLLotteryPanel"
local M = Act_056_WYFLManager
function C.Create(parent)
	return C.New(parent)
end
local anim_way = {
	1,2,3,4,5,6,7,8
}
local Mapping = {
	6,2,3,4,5,1,7,8
}
local Anim_Data = {
	step1_time = 1.4,
	step2_time = 3.0,
	step3_time = 1.6,
}
local Timers = {}
function C:AddMsgListener()
	for proto_name,func in pairs(self.lister) do
		Event.AddListener(proto_name, func)
	end
end

function C:MakeLister()
	self.lister = {}
	self.lister["ExitScene"] = basefunc.handler(self,self.MyExit)
	self.lister["model_wyfl_unrealy_change_msg"] = basefunc.handler(self,self.on_model_wyfl_unrealy_change_msg)
	self.lister["model_wyfl_lottery_change_msg"] = basefunc.handler(self,self.on_model_wyfl_lottery_change_msg)
	self.lister["model_wyfl_data_change_msg"] = basefunc.handler(self,self.on_model_wyfl_data_change_msg)
	self.lister["AssetChange"] = basefunc.handler(self, self.OnAssetChange)
end

function C:RemoveListener()
	for proto_name,func in pairs(self.lister) do
		Event.RemoveListener(proto_name, func)
	end
	self.lister = {}
end

function C:MyExit()
	if self.seq then
		self.seq:Kill()
		self.seq = nil 
	end
	self:StopAllAnim()
	self:EndLottery()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor(parent)
	local parent = parent or GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.NoStart_By_Anim = true
	self.Mapping = Mapping
	self:Idle_Anim(1)
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.lottery_btn.onClick:AddListener(function ()
		Network.SendRequest("welfare_activity_lottery",{act_type = Act_056_WYFLManager.type})
		self.lottery_btn.gameObject:SetActive(false)
		self.no_lottery_btn.gameObject:SetActive(true)
	end)

	self:InitAward()
	self.times_txt.text = "剩余次数:"..(M.GetLotteryNum() or "0")
end

function C:MyRefresh()
end

function C:InitAward()
	local config = M.award_config
	-- self.award1_img.sprite = GetTexture(config[1].award_img)
	-- self.award1_txt.text = config[1].award_txt
	-- self.award2_img.sprite = GetTexture(config[2].award_img)
	-- self.award2_txt.text = config[2].award_txt
	-- self.award3_img.sprite = GetTexture(config[3].award_img)
	-- self.award3_txt.text = config[3].award_txt
	-- self.award4_img.sprite = GetTexture(config[4].award_img)
	-- self.award4_txt.text = config[4].award_txt
	-- self.award5_img.sprite = GetTexture(config[5].award_img)
	-- self.award5_txt.text = config[5].award_txt
	-- self.award6_img.sprite = GetTexture(config[6].award_img)
	-- self.award6_txt.text = config[6].award_txt
	-- self.award7_img.sprite = GetTexture(config[7].award_img)
	-- self.award7_txt.text = config[7].award_txt
	-- self.award8_img.sprite = GetTexture(config[8].award_img)
	-- self.award8_txt.text = config[8].award_txt

	for i = 1,#config do
		self["award"..i.."_img"].sprite = GetTexture(config[Mapping[i]].award_img)
		self["award"..i.."_txt"].text = config[Mapping[i]].award_txt
	end
	--[[
		GetTexture("gy_20_11")
		GetTexture("activity_icon_gift84_sjt")
	--]]
end


--虚假数据跑马灯
function C:on_model_wyfl_unrealy_change_msg()
	self.Lantern.gameObject:SetActive(true)
	self.Lantern2_txt.text = "恭喜玩家<color=#e7ff62>"..(M.GetUnrealyPlayerName() or "").."</color>抽中了<color=#ffc617>"..(M.GetUnrealyAwardName() or "").."</color>"
	self.seq = DoTweenSequence.Create()
	self.seq:Append(self.Lantern.transform:DOLocalMoveY(57.7,1.5))
	self.seq:OnKill(function ()
				self.Lantern1_txt.text = self.Lantern2_txt.text
				self.Lantern.transform.localPosition = Vector3.New(0,0,0)
	end)
end

function C:on_model_wyfl_lottery_change_msg()
	self.times_txt.text = "剩余次数:"..(M.GetLotteryNum() or "0")
	self.award_id = M.GetLotteryAwardId()
	self.NoStart_By_Anim = false
end

function C:on_model_wyfl_data_change_msg()
	self.times_txt.text = "剩余次数:"..(M.GetLotteryNum() or "0")
	if self.NoStart_By_Anim then
		if M.GetLotteryNum() > 0 then
			self.lottery_btn.gameObject:SetActive(true)
			self.no_lottery_btn.gameObject:SetActive(false)
		else
			self.lottery_btn.gameObject:SetActive(false)
			self.no_lottery_btn.gameObject:SetActive(true)
		end
	end
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
		local award_index = self.award_id
		local step = self:GetStopStep(self.Mapping, award_index, startPos)
		self:Step3_Anim(startPos, step)
	end
	if animationName == "Step3" then
		self:StopAllAnim()
		self:CloseAnimSound()
		self:Twinkle_Anim(startPos, 6)
	end
end

function C:EndLottery()
	if M.GetLotteryNum() > 0 then
		self.lottery_btn.gameObject:SetActive(true)
		self.no_lottery_btn.gameObject:SetActive(false)
	else
		self.lottery_btn.gameObject:SetActive(false)
		self.no_lottery_btn.gameObject:SetActive(true)
	end
	if self.Award_Data then 
		Event.Brocast("AssetGet",self.Award_Data)
		self.Award_Data = nil
	end
end

function C:OnAssetChange(data)
	dump(data, "<color=red>----奖励类型-----</color>")
	if data.change_type and data.change_type == "welfare_activity_lottery_award" and not table_is_null(data.data) then
		self.Award_Data = data
	end
	self:MyRefresh()
end

function C:StopAllAnim()
	for k, v in pairs(Timers) do
		if v then
			v:Stop()
		end
	end
end


function C:CloseAnimSound()
	if self.curSoundKey then
		soundMgr:CloseLoopSound(self.curSoundKey)
		self.curSoundKey = nil
	end
end

function C:ShakeLotteryPraticSys(pos)
	for i = 1,#anim_way do
		self["award" .. i]:Find("@bk"..i.."_img").gameObject:SetActive(false)
	end
	self["award" .. pos]:Find("@bk"..pos.."_img").gameObject:SetActive(true)
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

function C:TimerCreator(func, duration, loop, animationName,scale,durfix)
	local timer = Timer.New(func, duration, loop)
	if Timers[animationName] then
		Timers[animationName]:Stop()
		Timers[animationName] = nil
	end
	Timers[animationName] = timer
	return timer
end