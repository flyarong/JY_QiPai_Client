-- 创建时间:2019-06-04
--[[ *      ┌─┐       ┌─┐
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

NationalDayLotteryPanel = basefunc.class()
local C = NationalDayLotteryPanel
C.name = "NationalDayLotteryPanel"
local config = HotUpdateConfig("Game.CommonPrefab.Lua.10yue_lottery_cfg")
local LOTTERY_TYPE = {"19_october_lottery"}
local RANK_TYPE = {"19_october_lottery"}
local Timers = {}
local Anim_Data = {
	step1_time = 1.62,
	step2_time = 3.5,
	step3_time = 1.2,
}
local LotteryStr = "奖券"
function C.Create(parent)
	return 
    --return C.New()
end
function C:AddMsgListener()
    for proto_name, func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end
function C:MakeLister()
	self.lister = {}
	 self.lister["AssetChange"] = basefunc.handler(self, self.OnAssetChange)
    -- self.lister["EnterBackGround"] = basefunc.handler(self, self.onEnterBackGround)
    -- self.lister["EnterForeGround"] = basefunc.handler(self, self.ReConnecteServerSucceed)
    -- self.lister["ReConnecteServerSucceed"] = basefunc.handler(self, self.ReConnecteServerSucceed)
    self.lister["common_lottery_base_info_change"] = basefunc.handler(self, self.ReFreshInfo)
    self.lister["query_common_lottery_base_info_response"] = basefunc.handler(self, self.ReFreshInfo)
    self.lister["common_lottery_kaijaing_response"] = basefunc.handler(self, self.Get_KAIJIANG_info)
    --self.lister["common_lottery_get_broadcast_response"] = basefunc.handler(self, self.GetBroadcast)
    -- self.lister["ExitScene"] = basefunc.handler(self, self.MyExit)
end
function C:RemoveListener()
    for proto_name, func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:ctor(_parent)

	ExtPanel.ExtMsg(self)

	local parent = GameObject.Find("Canvas/LayerLv4").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.OnStart = false
	self.Is_Open_Panel = true
	LuaHelper.GeneratingVar(self.transform, self)
	local Mapping = self:GetMapping(#config.Award)
	self.Mapping = Mapping
	self:InitLotteryBGUI(Mapping,config.Award)
	self:MakeLister()
	self:AddMsgListener()
	self:Idle_Anim()
	self:OnButtonClick()
	Network.SendRequest("query_common_lottery_base_info", { lottery_type = LOTTERY_TYPE[1] } ," ")
end

function C:InitUI()
	self.time_txt = ""
	self.bottom_txt = ""
end

function C:OnButtonClick()
	self.help_btn.onClick:AddListener(
		function ()
			self:OpenHelpPanel()
		end
	)
	-- self.close_btn.onClick:AddListener(
	-- 	function ()
	-- 		self:Close()
	-- 	end
	-- )
	-- self.rank_btn.onClick:AddListener(
	-- 	function ()
	-- 		self:OpenRank()
	-- 	end
	-- )
	self.start_lottery_btn.onClick:AddListener(
		function ()
			if self.OnStart == false then 
				Network.SendRequest("common_lottery_kaijaing", { lottery_type = LOTTERY_TYPE[1] }, "")
			end 
		end
	)
end

function C:OpenHelpPanel()
    local str=config.DESCRIBE_TEXT[1].text
    for i=2,#config.DESCRIBE_TEXT do 
         str=str.."\n"..config.DESCRIBE_TEXT[i].text
    end
    self.introduce.text=str
    IllustratePanel.Create({self.introduce_txt.gameObject}, GameObject.Find("Canvas/LayerLv5").transform)
end

function C:OpenRank()
	
end

function C:Close()
	self:MyExit()
end

function C:Step1_Anim(startPos,Step,maxStep)
	local AnimationName = "Step1"
	startPos = startPos or 1
	maxStep = maxStep or 10
	local _End = 0
	local Time = self:TimerCreator(function ()
		while startPos > maxStep do startPos = startPos - maxStep end 
		self:HideAllLotteryPraticSys(maxStep)
		self["lotteryitem"..startPos]:Find("fqj_kuang").gameObject:SetActive(true)
		startPos = startPos + 1 
		_End = _End + 1
		if _End >= Step then
			self:OnFinshName(AnimationName,startPos)
		end
	end,Anim_Data.step1_time/Step,-1,AnimationName)
	Time:Start() 
		
end

function C:Step2_Anim(startPos,Step,maxStep)
	local AnimationName = "Step2"
	startPos = startPos or 1
	maxStep = maxStep or 10
	local _End = 0
	local Time = self:TimerCreator(function ()
		while startPos > maxStep do startPos = startPos - maxStep end 
		self:HideAllLotteryPraticSys(maxStep)
		self["lotteryitem"..startPos]:Find("fqj_kuang").gameObject:SetActive(true)
		startPos = startPos + 1 
		_End = _End + 1
		if _End >= Step then
			self:OnFinshName(AnimationName,startPos)
		end
	end,Anim_Data.step2_time/Step,-1,AnimationName)
	Time:Start() 	
end

function C:Step3_Anim(startPos,Step,maxStep)
	local AnimationName = "Step3"
	startPos = startPos or 1
	maxStep = maxStep or 10
	local _End = 0
	local Time = self:TimerCreator(function ()
		while startPos > maxStep do startPos = startPos - maxStep end 
		self:HideAllLotteryPraticSys(maxStep)
		self["lotteryitem"..startPos]:Find("fqj_kuang").gameObject:SetActive(true)
		startPos = startPos + 1 
		_End = _End + 1
		if _End >= Step then
			self:OnFinshName(AnimationName,startPos)
		end		
	end,Anim_Data.step3_time/Step,-1,AnimationName)
	Time:Start() 	
end

function C:Idle_Anim(startPos,maxStep)
	local AnimationName = "Idle"
	startPos = startPos or 1
	maxStep = maxStep or 10
	local Time = self:TimerCreator(function ()
		while startPos > maxStep do startPos = startPos - maxStep end 
		self:HideAllLotteryPraticSys(maxStep)
		self["lotteryitem"..startPos]:Find("fqj_kuang").gameObject:SetActive(true)
		startPos = startPos + 1 
		if self.OnStart then
			self:OnFinshName(AnimationName,startPos)
		end
	end,1,-1,AnimationName)
	Time:Start() 	
end

function C:Twinkle_Anim(startPos,Step,maxStep)
	local AnimationName = "Twinkle"
	maxStep = maxStep or 10
	local _End = 0
	local Time = self:TimerCreator(function ()
		while startPos > maxStep do startPos = startPos - maxStep end 
		self:HideAllLotteryPraticSys(maxStep)
		self["lotteryitem"..startPos]:Find("fqj_kuang").gameObject:SetActive(true)
		_End = _End + 1
		if _End >= Step then
			self:OnFinshName(AnimationName,startPos)
		end		
	end,0.33,Step,AnimationName)
	Time:Start() 		
end

function C:StopAllAnim()
	for k , v in pairs(Timers) do
		if v then 
			v:Stop()
		end
	end 
end

function C:GetMapping(max,disturb)
	local temp_list = {}
	local List = {}
	for i = 1, max do
		List[i] = i
	end
	math.randomseed(MainModel.UserInfo.user_id)
	while #temp_list < max do
		local  R = math.random(1,max)
		if List[R] ~= nil then
			temp_list[#temp_list + 1] = List[R]
			table.remove(List, R)
		end
	end
	return temp_list
end

function C:InitLotteryBGUI(mapping,config_list)
	for i = 1, #mapping do
		local config = config_list[mapping[i]]
		self["lotteryitem"..i].transform:Find("Text"):GetComponent("Text").text = self:LotteryType2Str(config.num,config.type)
		local Img = self["lotteryitem"..i].transform:Find("awardimg"):GetComponent("Image")
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
        return Num .. "福卡"
    else
        return type
    end
end

function C:TimerCreator(func,duration,loop,animationName)
	local timer = Timer.New(func,duration,loop)
	if Timers[animationName] then 
		Timers[animationName]:Stop()
		Timers[animationName] = nil 
	end
	Timers[animationName] = timer
	return timer
end

function C:HideAllLotteryPraticSys(max)
	for i = 1, max do
		self["lotteryitem"..i]:Find("fqj_kuang").gameObject:SetActive(false)
	end
end

function C:OnFinshName(animationName,startPos)
	if animationName == "Idle" then
		self:StopAllAnim()
		self:Step1_Anim(startPos,7)
	end
	if animationName == "Twinkle" then
		self.OnStart = false
		self:StopAllAnim()
		self:EndLottery()
		self:Idle_Anim(startPos)
	end 
	if animationName == "Step1" then
		self:StopAllAnim()
		self:Step2_Anim(startPos,65)
	end 
	if animationName == "Step2" then
		self:StopAllAnim()
		local award_index = self:GetAwardIndex(self.award_id)
		local step = self:GetStopStep(self.Mapping,award_index,startPos)
		self:Step3_Anim(startPos,step)
	end 
	if animationName == "Step3" then
		self:StopAllAnim()
		self:Twinkle_Anim(startPos,6)
	end 
end

function C:GetStopStep(mapping,award_index,startPos)
	for  i = 1, #mapping do
		if mapping[i] == award_index then 
			return  2 * #mapping  + i - startPos
		end
	end	
end

function C:GetAwardIndex(award_id)
	for	i = 1 , #config.Award do 
		if config.Award[i].server_award_id == award_id then 
			return i 
		end
	end 
end

function C:Get_KAIJIANG_info(_,data)
	dump(data,"<color=red>Get_KAIJIANG_info</color>")
	if data and data.result == 0 then 
		self.award_id = data.award_id
		self.OnStart = true		
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
        self["lotteryitem".._index].transform:Find("getmask").gameObject:SetActive(true)
    end
end

function C:ReFreshInfo(_,data)
	dump(data, "<color=red>----------抽奖数据-----------</color>")
    if data == nil or data.ticket_num == nil or not IsEquals(self.gameObject) then
        return
    end
    if data.now_game_num == nil then
        data.now_game_num = 0
    end
    local now_game_num = data.now_game_num
    if now_game_num + 1 > #config.Award then
        now_game_num = now_game_num - 1
    end
    self.ticket_num = data.ticket_num
    self.need_credits = config.Award[now_game_num + 1].need_credits
    self.now_game_num = data.now_game_num
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
			RealAwardPanel.Create({text = config.Award[award_index].type,image = config.Award[award_index].img})
        end
        self.award_id = nil
        self.cur_award = nil
        self:GetMask()
    end
end

function C:OnAssetChange(data)
    dump(data, "<color=red>----奖励类型-----</color>")
    if data.change_type and data.change_type == "common_lottery_"..LOTTERY_TYPE[1] then
        self.cur_award = data
    end
end

function C:MyExit()
	self:StopAllAnim()
	self:EndLottery()
	self:RemoveListener()
	destroy(self.gameObject)

	 
end