-- 创建时间:2019-07-03
-- Panel:FishingMatchWaitPanel
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
local game_smallhint_config = HotUpdateConfig("Game.CommonPrefab.Lua.game_smallhint_config")

FishingMatchWaitPanel = basefunc.class()
local C = FishingMatchWaitPanel
C.name = "FishingMatchWaitPanel"

local old_signup_num

function C.Create()
	return C.New()
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["fsmg_cancel_signup_response"] = basefunc.handler(self, self.on_fsmg_cancel_signup)
    self.lister["model_status_msg"] = basefunc.handler(self, self.on_status_msg)
    self.lister["fsmg_req_cur_player_num_response"] = basefunc.handler(self, self.on_signup_num_msg)

    self.lister["EnterForeGround"] = basefunc.handler(self, self.on_backgroundReturn_msg)
    self.lister["EnterBackGround"] = basefunc.handler(self, self.on_background_msg)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyClose()
	self:MyExit()
end
function C:MyExit()
	if self.update then
		self.update:Stop()
		self.update = nil
	end
	if self.small_hint then
		self.small_hint:MyExit()
		self.small_hint = nil
	end
	FishingMatchAwardPanel.Close()
	
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor()

	ExtPanel.ExtMsg(self)

	local parent = GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()

    self.hint_no_money.gameObject:SetActive(false)

	self.game_id = FishingMatchModel.data.game_id
	
	self.back_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnBackClick()
    end)
	self.award_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnAwardRankClick()
    end)
	self.help_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnHelpClick()
    end)
    self.award_top3 = {}
    self.award_top3[#self.award_top3 + 1] = self.award1
    self.award_top3[#self.award_top3 + 1] = self.award2
    self.award_top3[#self.award_top3 + 1] = self.award3

	self.chaidai_par = self.chaidai:GetComponent("ParticleSystem")
	
	self.time_call_map = {}
	self.time_call_map["time"] = {time_call = self:GetCall(1), run_call = basefunc.handler(self, self.UpdateTime)}
	self.time_call_map["back_time"] = {time_call = self:GetCall(1), run_call = basefunc.handler(self, self.UpdateBackTime)}
    self.time_call_map["caidai"] = {time_call = self:GetCall(5), run_call = basefunc.handler(self, self.RunChaidai)}
    self.time_call_map["query"] = {time_call = self:GetCall(3), run_call = basefunc.handler(self, self.UpdateQuerySignup)}

	self:InitUI()
end

function C:InitUI()
	self.signup_num = 0
	self.game_cfg = FishingManager.GetGameIDToConfig(self.game_id)
	self.award_cfg = FishingManager.GetGameIDToAward(self.game_id)

	self:MyRefresh()
end

function C:MyRefresh()
	self.back_time = FishingMatchModel.data.countdown or 0
	self.down_time = FishingMatchModel.data.game_time or 0

	if self.small_hint then
	    self.small_hint:MyClose()
	end
    self.small_hint = GameSmallHintPanel.Create(game_smallhint_config.fishingmatch_config, self.transform, 42)	

    if not self.update then
	    self.update = Timer.New(function ()
	    	self:Update()
	    end, 1, -1, nil, true)    	
    end
	if self.back_time <= 0 then
		self.back_btn.gameObject:SetActive(true)
	else
		self.back_btn.gameObject:SetActive(false)
	end
	self.update:Start()

	self.rect1.gameObject:SetActive(true)
	self:RefreshTime()
	self:RefreshTop3()
	self:UpdateTime(true)
	self:UpdateBackTime(true)
	self:UpdateQueryAward(old_signup_num)
end

function C:GetCall(t)
	local tt = t
	local cur = 0
	return function (st)
		cur = cur + st
		if cur >= tt then
			cur = cur - tt
			return true
		end
		return false
	end
end
function C:Update()
	for k,v in pairs(self.time_call_map) do
		if v.time_call(1) then
			v.run_call()
		end
	end
end
function C:RunChaidai()
	self.chaidai_par:Play(true)
	self.time_call_map["caidai"].time_call = self:GetCall(math.random(10, 30))
end
function C:UpdateQuerySignup()
	Network.SendRequest("fsmg_req_cur_player_num")
end

function C:UpdateQueryAward(num)
	num = num or 0
	old_signup_num = num
	self.award_pool_txt.text = 10 * num .. "福卡"
end
function C:RefreshTime()
	
end

function C:UpdateTime(b)
	if not b then
		if self.down_time then
			self.down_time = self.down_time - 1
		end
	end
	if not self.down_time or self.down_time <= 0 then
		self.countdown_1_txt.text = "00"
		self.countdown_2_txt.text = "00"
		self.time_call_map["time"] = nil
	else
		local ff = math.floor(self.down_time / 60)
		local mm = self.down_time % 60
		self.countdown_1_txt.text = string.format("%02d", ff)
		self.countdown_2_txt.text = string.format("%02d", mm)
	end
end
function C:UpdateBackTime(b)
	if not b then
		if self.back_time then
			self.back_time = self.back_time - 1
		end
	end
	if not self.back_time or self.back_time <= 0 then
		self.back_txt.text = ""
		self.time_call_map["back_time"] = nil
		self.back_btn.gameObject:SetActive(true)
	else
		self.back_txt.text = string.format("%d秒后可返回", self.back_time)
	end
end

function C:RefreshTop3()
	if self.award_cfg then
		for i = 1, 3 do
			if i <= #self.award_cfg then
				local cfg = self.award_cfg[i]
				self.award_top3[i].gameObject:SetActive(true)
				local dd = {}
				LuaHelper.GeneratingVar(self.award_top3[i], dd)
				GetTextureExtend(dd.award_icon_img, cfg.icon, cfg.is_local_icon)
				dd.award_txt.text = cfg.award
				if cfg.extra_award_desc then
					local ew = math.floor(cfg.extra_award_desc * 100)
					dd.award2_txt.text = "额外+" .. ew .. "%奖池金"
				else
					dd.award2_txt.text = ""
				end

			else
				self.award_top3[i].gameObject:SetActive(false)
			end
		end
	else
		for i = 1, 3 do
			self.award_top3[i].gameObject:SetActive(false)
		end
	end
end

function C:OnBackClick()
	HintPanel.Create(2, "比赛即将开始，现在离开可能错过比赛，请记得提前来参赛哦！", function ()
		Network.SendRequest("fsmg_cancel_signup", nil, "取消报名")
	end)
end
function C:OnAwardRankClick()
	local pp = {}
	pp.game_id = self.game_id
	pp.signup_num_response = "fsmg_req_cur_player_num_response"
	pp.num = self.signup_num
	FishingMatchAwardPanel.Create(pp)
end
function C:OnHelpClick()
	-- IllustratePanel.Create({self.introduce_txt}, self.transform)
	FishingBKPanel.New(true)
end

function C:on_fsmg_cancel_signup(_, data)
	if data.result == 0 then
		MainLogic.ExitGame()
		GameManager.GotoUI({gotoui = "game_FishingHall"})
	else
		HintPanel.ErrorMsg(data.result)
	end
end

function C:on_status_msg(st)
	if st == FishingMatchModel.Model_Status.wait_begin then
		if old_signup_num then
			self.hint_zero_txt.text = "已报名人数：" .. old_signup_num
		else
			self.hint_zero_txt.text = "已报名人数：--"
		end
	elseif st == FishingMatchModel.Model_Status.wait_table then
		self.hint_zero_txt.text = "请稍等，比赛即将开始"
		self.time_call_map["query"] = nil
	else
		self.hint_zero_txt.text = "--"
	end
end
function C:on_signup_num_msg(_, data)
	self.signup_num = (data.signup_num or 0)
	self.hint_zero_txt.text = "已报名人数：" .. self.signup_num
	self:UpdateQueryAward(data.signup_num)
end
function C:on_backgroundReturn_msg()
	if self.small_hint then
	    self.small_hint:MyClose()
	end
    self.small_hint = GameSmallHintPanel.Create(game_smallhint_config.fishingmatch_config, self.transform, 42)	
end
function C:on_background_msg()
	if self.small_hint then
	    self.small_hint:MyClose()
	end
	if self.update then
		self.update:Stop()
		self.update = nil
	end
end

