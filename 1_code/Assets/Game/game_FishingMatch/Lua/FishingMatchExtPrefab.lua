-- 创建时间:2019-06-28
-- 捕鱼比赛扩展界面

local basefunc = require "Game.Common.basefunc"

FishingMatchExtPrefab = basefunc.class()

local C = FishingMatchExtPrefab

C.name = "FishingMatchExtPrefab"

function C.Create(tran, panelSelf)
	return C.New(tran, panelSelf)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["model_change_rank_msg"] = basefunc.handler(self, self.on_change_rank_msg)
    self.lister["model_change_barbette_time_msg"] = basefunc.handler(self, self.on_change_barbette_time_msg)
    self.lister["model_change_luck_time_msg"] = basefunc.handler(self, self.on_change_luck_time_msg)
    self.lister["model_barbette_info_change_msg"] = basefunc.handler(self, self.on_barbette_info_change_msg)
    self.lister["ui_fish_match_rank_up_msg"] = basefunc.handler(self, self.on_ui_rank_up_msg)

    self.lister["fsmg_query_total_award_pool_response"] = basefunc.handler(self, self.on_fsmg_query_total_award_pool)
    self.lister["model_fsmg_gameover_msg"] = basefunc.handler(self, self.on_model_fsmg_gameover_msg)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:RemoveListener()
	if self.update_time then
		self.update_time:Stop()
	end
	self.update_time = nil
end

function C:ctor(tran, panelSelf)
	self.panelSelf = panelSelf
	self.gameObject = tran.gameObject
	self.transform = tran

	self:MakeLister()
    self:AddMsgListener()
    LuaHelper.GeneratingVar(self.transform, self)

    self.pao_Image = self.LockRect:Find("pao/Image"):GetComponent("Image")
    self.rank_btn.onClick:AddListener(function ()
    	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    	FishingMatchRankPanel.Create({game_id = FishingMatchModel.data.game_id})
    end)
	self.RankWait.gameObject:SetActive(false)

    self.game_time_state = nil
    self.game_time_state10 = nil
    self.lock_time_state = nil
    self.luck_time_state = nil
    self.luck_wave_time_state = nil

    self.time_call_map = {}
	self.time_call_map["match_time"] = {time_call = self:GetCall(1), run_call = basefunc.handler(self, self.UpdateTime)}
	self.time_call_map["lock_time"] = {time_call = self:GetCall(1), run_call = basefunc.handler(self, self.UpdateLockTime)}
	self.time_call_map["luck_time"] = {time_call = self:GetCall(1), run_call = basefunc.handler(self, self.UpdateLuckTime)}
	self.time_call_map["query_pond"] = {time_call = self:GetCall(10), run_call = basefunc.handler(self, self.UpdateQueryPond)}
	self.game_time_anim = self.RTRect:GetComponent("Animator")
	self.lock_time_anim = self.LockRect:GetComponent("Animator")
	self.luck_time_anim = self.LuckRect:GetComponent("Animator")
	self.glow_anim = self.glow:GetComponent("Animator")

    self.update_time = Timer.New(function ()
    	self:Update()
    end, 1, -1, nil, false)
    self.red_award_txt.text = "0福卡"
    -- self:MyRefresh()
end
function C:MyRefresh()
	self.wave_tip_hint_rate.gameObject:SetActive(false)
	self.wave_node.gameObject:SetActive(false)

	local m_data = FishingMatchModel.data
	if m_data and m_data.model_status == FishingMatchModel.Model_Status.gaming then
	    self.game_time_value = FishingMatchModel.data.game_time
    	self.lock_time_value = FishingMatchModel.data.main_barbette_time
    	self.luck_time = FishingMatchModel.data.luck_time

	    self.update_time:Start()
	    self:UpdateQueryPond()
		self:UpdateTime(true)
		self:UpdateLockTime(true)
		self:UpdateLuckTime(true)
		self.my_rank = m_data.rank
		self.rank_txt.text = m_data.rank .. "/" .. m_data.total_players
		self:RefreshRankRed()
		self:RefreshLockAndLuck()
		self:on_barbette_info_change_msg()
	end
end
function C:RefreshRankRed()
	local m_data = FishingMatchModel.data
	if m_data and m_data.model_status == FishingMatchModel.Model_Status.gaming then
		local cfg = FishingManager.GetCfgByRank(m_data.game_id, self.my_rank)
		if cfg then
			local gd = cfg.fixed_value or 0
			local ew = cfg.extra_award_desc or 0
			local ok, arg = xpcall(function ()
				local total_award_pool = m_data.total_award_pool or 0
				ew = ew * math.floor(total_award_pool / 10000)
				self.rank_award_txt.text = "当前排名 " .. StringHelper.ToRedNum(gd + ew) .. "福卡"
		    end,
		    function (error)
				self.rank_award_txt.text = "当前排名 " .. StringHelper.ToRedNum(gd) .. "福卡"
			end)
		else
			self.rank_award_txt.text = "当前排名 0福卡"
		end
	else
		self.rank_award_txt.text = "当前排名 0福卡"
	end
end
-- 显示最近的一个
function C:RefreshLockAndLuck()
	if self.lock_time_value and self.luck_time then
		if self.lock_time_value > self.luck_time then
			self.LockRect.gameObject:SetActive(false)
			self.LuckRect.gameObject:SetActive(true)
			self.wave_node.gameObject:SetActive(false)

			self.luck_time_state = nil
			self.luck_wave_time_state = nil
			if FishingMatchModel.data.luck_type and FishingMatchModel.data.luck_type == 1 then
				self.wave_tip_hint_rate.gameObject:SetActive(true)
				self.wave_tip_hint_txt.text = "好运鱼潮即将来临!"
			else
				self.wave_tip_hint_rate.gameObject:SetActive(false)
				self.wave_tip_hint_txt.text = "好运时刻即将来临!"
			end
		else
			self.LockRect.gameObject:SetActive(true)
			self.LuckRect.gameObject:SetActive(false)
			self.lock_time_state = nil
		end
	end
end
-- *********************************
-- 时间控制
-- *********************************
function C:Update()
	for k,v in pairs(self.time_call_map) do
		if v.time_call(1) then
			v.run_call()
		end
	end
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
function C:UpdateQueryPond()
	Network.SendRequest("fsmg_query_total_award_pool", nil)
end
function C:UpdateTime(b)
	if not b then
		if self.game_time_value then
			self.game_time_value = self.game_time_value - 1
		end
	end

	if self.game_time_value <= 0 then
		self.time_txt.text = ""
		self.OverRect.gameObject:SetActive(false)
	else
		if self.game_time_value <= 5 then
			if not self.game_time_state or self.game_time_state == "nor" then
    			self.game_time_state = "last5s"
	    		self.game_time_anim:Play("by_@rtrect", -1, 0)
	    		self.time_txt.gameObject:SetActive(false)
	    	end
		else
			if not self.game_time_state or self.game_time_state == "last5s" then
	    		self.game_time_state = "nor"
	    		self.game_time_anim:Play("djs_nor", -1, 0)
	    		self.time_txt.gameObject:SetActive(true)
	    	end
		end
		if self.game_time_value <= 10 and self.game_time_value > 0 then
			if not self.game_time_state10 or self.game_time_state10 == "nor" then
    			self.game_time_state10 = "last10s"
	    		self.OverRect.gameObject:SetActive(true)
	    	end
		else
			if not self.game_time_state10 or self.game_time_state10 == "last10s" then
	    		self.game_time_state10 = "nor"
	    		self.OverRect.gameObject:SetActive(false)
	    	end
		end
		local mm = math.floor(self.game_time_value / 60)
		local ss = self.game_time_value % 60
		self.time_txt.text = string.format("%02d:%02d", mm, ss)
		self.over_time_txt.text = string.format("%02d", ss)
	end
end
function C:UpdateLockTime(b)
	if not b then
		if self.lock_time_value then
			self.lock_time_value = self.lock_time_value - 1
		end
	end
	if not self.lock_time_value then
		self.LockRect.gameObject:SetActive(false)
		self.time_call_map["lock_time"] = nil
	else
		if self.lock_time_value <= 10 then
			if not self.lock_time_state or self.lock_time_state == "nor" then
    			self.lock_time_state = "last10s"
	    		self.lock_time_anim:Play("by_sjdjs_pao_3", -1, 0)
	    	end
		else
			if not self.lock_time_state or self.lock_time_state == "last10s" then
	    		self.lock_time_state = "nor"
	    		self.lock_time_anim:Play("by_sjdjs_pao_2", -1, 0)
	    	end
		end
		if b then
			self.LockRect.gameObject:SetActive(true)
		end
		if self.lock_time_value <= 0 then
			self.lock_time_txt.text = "00:00"
		else
			local mm = math.floor(self.lock_time_value / 60)
			local ss = self.lock_time_value % 60
			self.lock_time_txt.text = string.format("%02d:%02d", mm, ss)
		end
	end
end
function C:UpdateLuckTime(b)
	if not b then
		if self.luck_time then
			self.luck_time = self.luck_time - 1
		end
	end
	if not self.luck_time then
		self.LuckRect.gameObject:SetActive(false)
		self.time_call_map["luck_time"] = nil
	else
		if self.luck_time <= 10 then
			if not self.luck_time_state or self.luck_time_state == "nor" then
    			self.luck_time_state = "last10s"
	    		self.luck_time_anim:Play("by_@luckrect_3", -1, 0)
	    	end
	    	if FishingMatchModel.data.luck_type and FishingMatchModel.data.luck_type == 1 then
				if not self.luck_wave_time_state or self.luck_wave_time_state == "nor" then
	    			self.luck_wave_time_state = "last10s"
	    			self.wave_node.gameObject:SetActive(true)
		    	end
		    end
		else
			if not self.luck_time_state or self.luck_time_state == "last10s" then
	    		self.luck_time_state = "nor"
	    		self.luck_time_anim:Play("by_@luckrect_2", -1, 0)
	    	end
	    	if FishingMatchModel.data.luck_type and FishingMatchModel.data.luck_type == 1 then
		    	if not self.luck_wave_time_state or self.luck_wave_time_state == "last10s" then
	    			self.luck_wave_time_state = "nor"
	    			self.wave_node.gameObject:SetActive(false)
		    	end
		    end
		end
		if b then
			self.LuckRect.gameObject:SetActive(true)
		end
		if self.luck_time <= 0 then
			self.luck_time_txt.text = "00:00"
			self.wave_node.gameObject:SetActive(false)
		else
			local mm = math.floor(self.luck_time / 60)
			local ss = self.luck_time % 60
			self.luck_time_txt.text = string.format("%02d:%02d", mm, ss)
			if FishingMatchModel.data.luck_type and FishingMatchModel.data.luck_type == 1 then
				if self.luck_wave_time_state == "last10s" then
					self.wave_hint_txt.text = string.format("%ds", ss)
				end
			end
		end
	end
end

function C:on_background_msg()
	self.update_time:Stop()
end
function C:on_backgroundReturn_msg()
	
end
function C:on_change_rank_msg()
	local m_data = FishingMatchModel.data
	if self.my_rank > m_data.rank then
		FishingAnimManager.PlayRankUp(self.panelSelf.FXNode, Vector3.zero, self.RTRect.position)
	end
	self.rank_txt.text = m_data.rank .. "/" .. m_data.total_players	
	self.my_rank = m_data.rank
	self:RefreshRankRed()
end
function C:on_change_barbette_time_msg()
	self.lock_time_value = FishingMatchModel.data.main_barbette_time
	self:RefreshLockAndLuck()
end
function C:on_change_luck_time_msg(data)
	self.luck_time = FishingMatchModel.data.luck_time
	self:RefreshLockAndLuck()
	if #data == 1 and data[1] == -1 then
		-- 纯粹的好运鱼潮不用在这里播表现
		return
	end
	local beginPos = self.LuckRect.position
	local endPos = Vector3.zero
	FishingAnimManager.PlayLuckFX(self.panelSelf.FXNode, data, beginPos, endPos)
end

function C:GetLockRectPos()
	return self.LockRect.position
end
function C:on_barbette_info_change_msg(type)
	local m_data = FishingMatchModel.data
	local bullet_index = m_data.players_info[1].gun_info.bullet_index + 1
	local cfg = FishingMatchModel.GetGunCfg(bullet_index)
	self.pao_Image.sprite = GetTexture(cfg.gun_icon)
end

function C:on_ui_rank_up_msg()
	print("<color=red>on_change_rank_msg ddd </color>")
	self.glow_anim:Play("by_bs_shan1", -1, 0)	
end

function C:on_fsmg_query_total_award_pool(_, data)
	dump(data, "<color=red>on_fsmg_query_total_award_pool</color>")
	if data.result == 0 then
		FishingMatchModel.data.total_award_pool = tonumber(data.value)
		self.red_award_txt.text = math.floor(FishingMatchModel.data.total_award_pool / 10000) .. "福卡"
		self:RefreshRankRed()
	end
end
function C:on_model_fsmg_gameover_msg(parm)
	self.over_parm = parm
	self.time_call_map["over_time"] = {time_call = self:GetCall(4), run_call = basefunc.handler(self, self.UpdateOverTime)}
	self.RankWait.gameObject:SetActive(true)
	self.OverRect.gameObject:SetActive(false)
end
function C:UpdateOverTime()
	Event.Brocast("model_change_panel", self.over_parm)
end