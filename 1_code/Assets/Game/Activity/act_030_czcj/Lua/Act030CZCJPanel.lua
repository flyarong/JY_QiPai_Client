local basefunc = require "Game/Common/basefunc"

Act030CZCJPanel = basefunc.class()
local C = Act030CZCJPanel
C.name = "Act030CZCJPanel"
--配置相关
local M = Act030CZCJManager
local config = M.config
--排行榜相关
--改动数据相关
local LOTTERY_TYPE = { "lottery_game_drop" }
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
	self.lister["common_lottery_base_info_change"] = basefunc.handler(self, self.common_lottery_base_info_change)
	self.lister["query_common_lottery_base_info_response"] = basefunc.handler(self, self.query_common_lottery_base_info_response)
	self.lister["common_lottery_kaijaing_response"] = basefunc.handler(self, self.Get_KAIJIANG_info)
	self.lister["common_lottery_get_broadcast_response"] = basefunc.handler(self, self.common_lottery_get_broadcast_response)
	self.lister["ExitScene"] = basefunc.handler(self, self.MyExit)

	self.lister["EnterForeGround"] = basefunc.handler(self, self.on_backgroundReturn_msg)
    self.lister["EnterBackGround"] = basefunc.handler(self, self.on_background_msg)
end

function C:on_background_msg()
	for i,v in ipairs(self.pmd_obj or {}) do
		destroy(v)
	end
	self.pmd_obj = {}
end

function C:on_backgroundReturn_msg()
	for i,v in ipairs(self.pmd_obj or {}) do
		destroy(v)
	end
	self.pmd_obj = {}
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
	self:InitUI()
	self:RandomToSent()
	self.cutdown_timer=CommonTimeManager.GetCutDownTimer(M.e_time,self.time_txt)
	
	Network.SendRequest("query_common_lottery_base_info", { lottery_type = LOTTERY_TYPE[1] }, " ")
	self.pmd_cont = CommonPMDManager.Create({parent = self.pmd_node,speed = 5,space_time = 10,start_pos = 1000})
end

function C:InitUI()
	self.start_lottery_img = self.start_lottery_btn.transform:GetComponent("Image")
	self.pmd_item = GetPrefab("Act030PMDItem")
	self:OnButtonClick()
end

function C:OnButtonClick()
	self.pay_btn.onClick:AddListener(function (  )
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		PayPanel.Create(GOODS_TYPE.jing_bi, "normal")
	end)
	self.help_btn.onClick:AddListener(function (  )
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OpenHelpPanel()
	end)
	self.start_lottery_btn.onClick:AddListener(
	function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		if not self.CanStart_By_Info_Num then 
			LittleTips.Create("您抽奖次数已用尽，请参与其他活动。")
			return 
		end
		if not self.CanStart_By_Info_Ticket then 
			LittleTips.Create(LotteryStr.."不足")
			return 
		end
		if self.NoStart_By_Anim == true then
			Network.SendRequest("common_lottery_kaijaing", { lottery_type = LOTTERY_TYPE[1] }, "")
		end
	end
	)
end

function C:OpenHelpPanel()
	local str
	local help_info = {
		"1.活动时间：1月11日7:30:00~1月24日23:59:59",
		"2.苹果大战小游戏消耗鲸币不获得积分",
		"3.实物奖励请联系QQ公众号客服4008882620领取",
		"4.实物奖励图片仅供参考，请以实际获得的奖励为准",
		"5.所有实物奖励年后发货，即2022年2月8日后陆续发货",
	}
	help_info[1] = "1.活动时间:" .. self:GetStart_t() .. "~" .. self:GetEnd_t()
	str = help_info[1]
	for i = 2, #help_info do
		str = str .. "\n" .. help_info[i]
	end
	self.introduce_txt.text = str
	IllustratePanel.Create({ self.introduce_txt.gameObject }, GameObject.Find("Canvas/LayerLv5").transform, "IllustratePanel")
end

function C:GetStart_t()
    return string.sub(os.date("%m月%d日%H:%M",M.s_time),1,1) ~= "0" and os.date("%m月%d日%H:%M",M.s_time) or string.sub(os.date("%m月%d日%H:%M",M.s_time),2)
end

function C:GetEnd_t()
    return string.sub(os.date("%m月%d日%H:%M:%S",M.e_time),1,1) ~= "0" and os.date("%m月%d日%H:%M:%S",M.e_time) or string.sub(os.date("%m月%d日%H:%M:%S",M.e_time),2)
end

function C:Step1_Anim(startPos, Step, maxStep)
	local AnimationName = "Step1"
	self.dengAnimator:Play("fqj_deng")
	startPos = startPos or 1
	maxStep = maxStep or 12
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
	maxStep = maxStep or 12
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
	maxStep = maxStep or 12
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
	maxStep = maxStep or 12
	local constant_sec = 1
	local sec = 1
	local time_space = 0.1
	local During_Times = 12
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
	maxStep = maxStep or 12
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
		if config.server_award_id == 166 then
			Img = self["lotteryitem" .. i].transform:Find("big_award")
			Img.gameObject:SetActive(true)
		end
		Img = nil
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

function C:common_lottery_base_info_change(_,data)
	dump(data, "<color=white>common_lottery_base_info_change</color>")
	self:ReFreshInfo(data)
end

function C:query_common_lottery_base_info_response(_,data)
	dump(data, "<color=white>query_common_lottery_base_info_response</color>")
	self:ReFreshInfo(data)
end

function C:ReFreshInfo(data)
	dump(data, "<color=white>----------抽奖数据-----------</color>")
	if data == nil or data.ticket_num == nil or not IsEquals(self.gameObject) or not self:IsCurrLotteryType(data.lottery_type) then
		return
	end
	if data.now_game_num == nil then
		data.now_game_num = 0
	end
	self.CanStart_By_Info_Num = data.now_game_num < #config.Award
	local now_game_num = data.now_game_num
	if now_game_num + 1 > #config.Award then
		now_game_num = now_game_num - 1
	end
	self.ticket_num = data.ticket_num
	self.need_credits = config.Award[now_game_num + 1].need_credits
	self.now_game_num = data.now_game_num
	self.expend_txt.text = "消耗" ..  self.need_credits..LotteryStr --.."(剩余次数:"..12-self.now_game_num..")"
	self.current_txt.text = self.ticket_num
	self.CanStart_By_Info_Ticket = self.ticket_num >= self.need_credits

	if self.Is_Open_Panel then
		self:GetMask()
		self.Is_Open_Panel = false
	end

	if not self.CanStart_By_Info_Num or not self.CanStart_By_Info_Ticket then
		self.start_lottery_img.material = GetMaterial("imageGrey")
		self.start_lottery_img.raycastTarget = false
	else
		self.start_lottery_img.material = nil
		self.start_lottery_img.raycastTarget = true
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
		local data = {
			result = 0,
			award_id = self.award_id,
			lottery_type = "lottery_game_drop",
			player_name = MainModel.UserInfo.name
		}
		if self.award_id > 160 then
			Event.Brocast("common_lottery_get_broadcast_response", "common_lottery_get_broadcast_response",data)
		end
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
	Network.SendRequest("query_common_lottery_base_info", { lottery_type = LOTTERY_TYPE[1] }, " ")
end

function C:MyExit()
	if self.cutdown_timer then
		self.cutdown_timer:Stop()
	end
	if self.backcall then 
		self.backcall()
	end 
	if self.RandomToSent_Timer  then
		self.RandomToSent_Timer:Stop()
	end
	if self.SlowUP_Timer then
		self.SlowUP_Timer:Stop()
	end
 
	self:StopAllAnim()
	self:EndLottery()
	self:RemoveListener()
	for i,v in ipairs(self.pmd_obj or {}) do
		destroy(v)
	end
	self.pmd_obj = nil
	destroy(self.gameObject)
end

function C:CloseAnimSound()
	if self.curSoundKey then
		soundMgr:CloseLoopSound(self.curSoundKey)
		self.curSoundKey = nil
	end
end

function C:common_lottery_get_broadcast_response(_, data)
	dump(data,"<color=red>common_lottery_get_broadcast_response</color>")
	if not IsEquals(self.gameObject) or not data or data.result ~= 0 or not data.award_id then return end
	self.pmd_obj = self.pmd_obj or {}
	local b = GameObject.Instantiate(self.pmd_item,self.pmd_node)
	b.gameObject:SetActive(true)
	local cfg = Act030CZCJManager.GetCfgByAwardId(data.award_id)
	local temp_ui = {}
	LuaHelper.GeneratingVar(b.transform,temp_ui)
	temp_ui.t1_txt.text = "恭喜玩家【"..data.player_name.."】获得" .. self:LotteryType2Str(cfg.num, cfg.type) .. "奖励"
	UnityEngine.UI.LayoutRebuilder.ForceRebuildLayoutImmediate(b.transform)
	self.pmd_cont:AddObj(b)
	self.pmd_obj[#self.pmd_obj + 1] = b
	b = nil
end

function C:RandomToSent()
	if self.RandomToSent_Timer  then
		self.RandomToSent_Timer:Stop()
	end
	self.RandomToSent_Timer=nil
	math.randomseed(os.time())
	local t=10--math.random(10,20)
	self.RandomToSent_Timer=Timer.New(function ()
			if not IsEquals(self.gameObject) then return end
			self:RandomToSent()	
		end
	,t,1,nil,true)
	self.RandomToSent_Timer:Start()
	Network.SendRequest("common_lottery_get_broadcast", { lottery_type = LOTTERY_TYPE[1] }, "")
end

function C:IsCurrLotteryType(lottery_type)
	for i=1,#LOTTERY_TYPE do
		if lottery_type == LOTTERY_TYPE[i] then
			return true
		end 
	end
	return false
end

function C:OnDestroy()
	self:MyExit()
end