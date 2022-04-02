-- 创建时间:2019-07-03
-- Panel:FishingMatchSignupPanel
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
 ext_require_audio("Game.normal_fishing_common.Lua.audio_by_config","by")
local basefunc = require "Game/Common/basefunc"
local game_smallhint_config = HotUpdateConfig("Game.CommonPrefab.Lua.game_smallhint_config")

FishingMatchSignupPanel = basefunc.class()
local C = FishingMatchSignupPanel
C.name = "FishingMatchSignupPanel"

FishingMatchSignupPanel.SignupStart = 
{
	SS_Null = "SS_Null", -- 空
	SS_Wait = "SS_Wait", -- 等待报名
	SS_BeginSignup = "SS_BeginSignup", -- 开始报名
	SS_BeginGame = "SS_BeginGame", -- 开始游戏
}

local instance
function C.Create(pram)
	instance = C.New(pram)
	return instance
end

function C.Close(  )
	if instance then
		instance:MyExit()
	end
	instance = nil
end
function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["EnterForeGround"] = basefunc.handler(self, self.on_backgroundReturn_msg)
    self.lister["EnterBackGround"] = basefunc.handler(self, self.on_background_msg)
    self.lister["ExitScene"] = basefunc.handler(self, self.onExitScene)
    self.lister["AssetChange"] = basefunc.handler(self, self.onAssetChange)

    self.lister["fsmg_signup_response"] = basefunc.handler(self, self.on_fsmg_signup)
    self.lister["fsmg_req_specified_signup_num_response"] = basefunc.handler(self, self.on_fsmg_req_player_num)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.update_time then
		self.update_time:Stop()
		self.update_time = nil
	end
	if self.game_btn_pre then
		self.game_btn_pre:MyExit()
	end
	FishingMatchAwardPanel.Close()
	FishingMatchOldRankPanel.Close()
	self:RemoveListener()
	instance = nil
end

function C:ctor(pram)

	ExtPanel.ExtMsg(self)
	if not audio_config.by then
		ext_require_audio("Game.normal_fishing_common.Lua.audio_by_config","by")
	end
	--ExtendSoundManager.PlaySceneBGM(audio_config.by.bgm_bymatch_baoming.audio_name, true)

	local parent = GameObject.Find("Canvas/LayerLv3").transform
	local prefab_name = C.name
	if pram and pram.parent then
		parent = pram.parent
	end
	if pram and pram.name then
		prefab_name = pram.name
	end		
	
	local obj = newObject(prefab_name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()

	self.award_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnAwardRankClick()
    end)
	self.help_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnHelpClick()
    end)
	self.signup_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnSignupClick()
    end)
	self.back_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnBackClick()
    end)
	self.oldmatch_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnOldMatchClick()
    end)
    
	self.signup_start = FishingMatchSignupPanel.SignupStart.SS_Null
    self.award_top3 = {}
    self.award_top3[#self.award_top3 + 1] = self.award1
    self.award_top3[#self.award_top3 + 1] = self.award2
    self.award_top3[#self.award_top3 + 1] = self.award3
    self.award_pool_txt.text = "0福卡"
    self.chaidai_par = self.chaidai:GetComponent("ParticleSystem")

    self.time_call_map = {}

    self.update_time = Timer.New(function ()
    	self:Update()
    end, 1, -1, nil, true)

    local btn_map = {}
	btn_map["left_down"] = {self.act_node}
	self.game_btn_pre = GameButtonPanel.Create(btn_map, "fishing_match_bm")
	self:InitUI()
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
function C:UpdateTime(b)
	if not b then
		if self.down_time then
			self.down_time = self.down_time - 1
		end
		if self.down_time <= 0 then
			self:MyRefresh()
			return
		end
	end
	if not self.down_time then
		self.time_txt.text = "--:--:--"
	else
		self.time_txt.text = StringHelper.formatTimeDHMS(self.down_time)
	end
end

function C:UpdateQuerySignup()
	if self.game_id then
		Network.SendRequest("fsmg_req_specified_signup_num", {id=self.game_id})
	end
end

function C:UpdateQueryAward(num)
	num = num or 0
	self.award_pool_txt.text = 10 * num .. "福卡"
end
function C:RunChaidai()
	self.chaidai_par:Play(true)
	self.time_call_map["caidai"].time_call = self:GetCall(math.random(10, 30))
end

function C:InitUI()
	self:MyRefresh()
end

function C:MyRefresh()
	self.signup_num = 0
	self.game_id = FishingManager.GetRecentlyGameID()
	dump(self.game_id, "<color=red>self.game_id</color>")
	if self.game_id then
		self.game_cfg = FishingManager.GetGameIDToConfig(self.game_id)
		self.award_cfg = FishingManager.GetGameIDToAward(self.game_id)
		dump(self.game_cfg, "<color=red>self.game_cfg</color>")
		dump(self.award_cfg, "<color=red>self.award_cfg</color>")
	end

	self.signup_start = FishingMatchSignupPanel.SignupStart.SS_Null
	if self.game_id then
	    local now = os.time()
	    if now < self.game_cfg.start_time then
	    	self.signup_start = FishingMatchSignupPanel.SignupStart.SS_Wait
	    elseif now >= self.game_cfg.start_time and now <= self.game_cfg.over_time then
	    	self.signup_start = FishingMatchSignupPanel.SignupStart.SS_BeginSignup
	    else
	    	dump(self.game_cfg, "<color=red>self.game_cfg 配置异常</color>")
	    end
	end
	
	-- 捕鱼比赛的第一场比赛
	if self.game_id == 10000 then
		self.oldmatch_btn.gameObject:SetActive(false)
	else
		self.oldmatch_btn.gameObject:SetActive(true)
	end

	dump(self.signup_start, "<color=red>self.signup_start 状态</color>")
	if self.signup_start == FishingMatchSignupPanel.SignupStart.SS_Null then
		self.rect1.gameObject:SetActive(false)
		self.rect2.gameObject:SetActive(true)
		self.award_btn.gameObject:SetActive(false)
		self.ticket_txt.text = ""
		self.signup_num_txt.text = ""
		self.signup_btn.gameObject:SetActive(false)
		self.time_rect.gameObject:SetActive(false)
	elseif self.signup_start == FishingMatchSignupPanel.SignupStart.SS_Wait or
			self.signup_start == FishingMatchSignupPanel.SignupStart.SS_BeginSignup then
		if self.signup_start == FishingMatchSignupPanel.SignupStart.SS_Wait then
			self.rect1.gameObject:SetActive(false)
			self.rect2.gameObject:SetActive(true)
		else
			self.rect1.gameObject:SetActive(true)
			self.rect2.gameObject:SetActive(false)
		end
		self.time_rect.gameObject:SetActive(true)
		self.award_btn.gameObject:SetActive(true)

		-- 特殊处理 todo
		local itemkey, item_count = FishingManager.GetMatchCanUseTool(self.game_id)
		if not itemkey or itemkey == "jing_bi" then
			local is_have_jb = false
			for k,v in ipairs(self.game_cfg.enter_condi_itemkey) do
				if v == "jing_bi" then
					is_have_jb = true
					break
				end
			end
			if is_have_jb then
				local num = MainModel.UserInfo.jing_bi
				self.ticket_txt.text = string.format("持有鲸币：%s", StringHelper.ToCash(num))
				self.hint_hf_txt.text = "10万"
				self.hint_hf_img.sprite = GetTexture("com_award_icon_jingbi")
			else
				local num = 0
				self.ticket_txt.text = string.format("持有门票：%s", StringHelper.ToCash(num))
				self.hint_hf_txt.text = "1张"
				self.hint_hf_img.sprite = GetTexture("com_award_icon_bybsq")
			end
		else
			if itemkey == "obj_fish_match" or itemkey == "prop_fish" then
				local num = GameItemModel.GetItemTotalCount({"obj_fish_match", "prop_fish"})
				self.ticket_txt.text = string.format("持有门票：%s张", StringHelper.ToCash(num))
				self.hint_hf_txt.text = "1张"
				self.hint_hf_img.sprite = GetTexture("com_award_icon_bybsq")
			elseif itemkey == "shop_gold_sum" then
				local num = MainModel.GetHBValue()
				self.ticket_txt.text = string.format("持有福卡：%s", StringHelper.ToRedNum(num))
				self.hint_hf_txt.text = "10元"
				self.hint_hf_img.sprite = GetTexture("com_award_icon_money")
			end
		end


	    self.time_call_map["caidai"] = {time_call = self:GetCall(5), run_call = basefunc.handler(self, self.RunChaidai)}
		self.signup_num_txt.text = "--"
		self.signup_btn.gameObject:SetActive(true)
		if self.signup_start == FishingMatchSignupPanel.SignupStart.SS_Wait then
			self.time_call_map["query"] = nil
			self.signup_num_txt.gameObject:SetActive(false)
		else
		    self.time_call_map["query"] = {time_call = self:GetCall(3), run_call = basefunc.handler(self, self.UpdateQuerySignup)}
			self.signup_num_txt.gameObject:SetActive(true)
		end
	else
		dump(self.signup_start, "<color=red>self.signup_start 错误的状态</color>")
	end

	self.update_time:Start()

	self:RefreshTime()
	self:RefreshTop3()
	self:UpdateTime(true)
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
local WeekToTable = {
    [0] = "天",
    [1] = "一",
    [2] = "二",
    [3] = "三",
    [4] = "四",
    [5] = "五",
    [6] = "六",
}
function C:RefreshTime()
	if self.game_id then
	    self.time_call_map["time"] = {time_call = self:GetCall(1), run_call = basefunc.handler(self, self.UpdateTime)}
	    local now = os.time()
	    if now < self.game_cfg.start_time then
	    	self.down_time = self.game_cfg.start_time - now

			local newtime = tonumber(os.date("%Y%m%d", os.time()))
			local oldtime = tonumber(os.date("%Y%m%d", self.game_cfg.start_time))

	    	if newtime ~= oldtime then
			    local cur_w_time = os.date("%W",os.time())
			    local w_time = os.date("%W", self.game_cfg.start_time)
			    local week_day = os.date("%w", self.game_cfg.start_time)
	            if cur_w_time == w_time then
		            self.hint1_txt.text = "本周"  .. WeekToTable[tonumber(week_day)] .. "  " .. os.date("%H:%M",self.game_cfg.start_time) .. "报名："
		        elseif cur_w_time - w_time == -1 then
		            self.hint1_txt.text = "下周"  .. WeekToTable[tonumber(week_day)] .. "  " .. os.date("%H:%M",self.game_cfg.start_time) .. "报名："
		        else
		        	self.hint1_txt.text = "报名倒计时："
		        end
		    else
		    	self.hint1_txt.text = "报名倒计时："
		    end
	    elseif now >= self.game_cfg.start_time and now <= self.game_cfg.over_time then
	    	self.hint1_txt.text = "开赛倒计时："
	    	self.down_time = self.game_cfg.over_time - now
	    end
	end
end

function C:OnAwardRankClick()
	local pp = {}
	pp.game_id = self.game_id
	pp.signup_num_response = "fsmg_req_specified_signup_num_response"
	pp.num = self.signup_num
	FishingMatchAwardPanel.Create(pp)
end
function C:OnHelpClick()
	FishingBKPanel.New(true)
end
function C:OnSignupClick()
	if self.game_id then
		if self.signup_start == FishingMatchSignupPanel.SignupStart.SS_Wait then
	        local str = "比赛" .. StringHelper.formatTimeDHMS(self.down_time) .. "后开始"
	        LittleTips.Create(str)
			return
		end

		local signup = function ()
			Network.SendRequest("fsmg_signup", {id=self.game_id}, "请求报名")		
		end

		local itemkey, item_count = FishingManager.GetMatchCanUseTool(self.game_id)
		if itemkey then
			signup()	
		else
			local is_have_jb = false
			for k,v in ipairs(self.game_cfg.enter_condi_itemkey) do
				if v == "jing_bi" then
					is_have_jb = true
					break
				end
			end
			-- 第一届比赛不需要金币报名
			if is_have_jb then
				HintPanel.Create(2, "报名参赛需要10万鲸币，是否立刻前往增加鲸币？", function ()
					PayPanel.Create(GOODS_TYPE.jing_bi, "normal")			
				end)
			else
				HintPanel.Create(1, "捕鱼大奖赛门票不足")
			end
		end
	else
		HintPanel.Create(1, "尽请期待")
	end
end

---
function C:onAssetChange()
	self:MyRefresh()
end
function C:on_backgroundReturn_msg()
	self:InitUI()
end
function C:on_background_msg()
	if self.update_time then
		self.update_time:Stop()
	end
end
function C:onExitScene()
	self:MyExit()
end
function C:on_fsmg_signup(_, data)
	dump(data, "<color=red>on_fsmg_signup</color>")
	if data.result == 0 then
		GameManager.GotoUI({gotoui ="game_FishingMatch",goto_scene_parm = {game_id = self.game_id}})
	else
		if data.result == 1000 then
			HintPanel.Create(1, "目前捕鱼比赛不在报名阶段")
		else
			HintPanel.ErrorMsg(data.result)
		end
	end
end
function C:on_fsmg_req_player_num(_, data)
	dump(data, "<color=red>on_fsmg_req_player_num</color>")
	if data.result == 0 then
		self.signup_num = (data.signup_num or 0)
		self.signup_num_txt.text = "已报名：" .. self.signup_num .. "人"
		self:UpdateQueryAward(data.signup_num)
	else
		self.time_call_map["query"] = nil
	end
end

function C:OnBackClick()
	ExtendSoundManager.PlayOldBGM()
	self:MyExit()
	destroy(self.gameObject)
end
function C:OnOldMatchClick()
	FishingMatchOldRankPanel.Create()
end
