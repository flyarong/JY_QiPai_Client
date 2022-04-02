-- 创建时间:2021-03-05
-- Panel:RXCQClearing
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
 -- 取消按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
 -- 确认按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
 --]]

local basefunc = require "Game/Common/basefunc"

RXCQClearing = basefunc.class()
local C = RXCQClearing
C.name = "RXCQClearing"

local pre_names = {
	"RXCQClearing_Jhxx",
	"RXCQClearing_txws",
	"RXCQClearing_zszt",
}

local clear_state = {
	init = 0,
	score_showing = 1,
	score_show_end = 2,
}

local cut_down_config = {
	1,6,6
}

function C.Create(parent,cfg,overcall)
	return C.New(parent,cfg,overcall)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.add_money_timer then
		self.add_money_timer:Stop()
	end
	if 	self.Cut_Timer then
		self.Cut_Timer:Stop()
	end
	if self.overcall then
		self.overcall()
	else
		Event.Brocast("rxcq_clear_over")
	end
	ExtendSoundManager.CloseSound(self.audio_key)
	RXCQModel.all_award = nil
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(parent ,cfg,overcall)
	ExtPanel.ExtMsg(self)
	self.score = cfg.score
	local rate = self.score / rxcq_main_config.base[RXCQModel.BetIndex].Bet
	if rate >= 8 then
		self.lv = 3
	elseif rate >=4 then
		self.lv = 2
	else
		self.lv = 1
	end

	local parent = parent or  GameObject.Find("Canvas/LayerLv5").transform
	local pre_name_show = pre_names[self.lv]
	local obj = newObject(pre_name_show, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.overcall = overcall
	LuaHelper.GeneratingVar(self.transform, self)
	self.state = clear_state.init
	self:MakeLister()
	self:AddMsgListener()
	self.Animator = self.transform:GetComponent("Animator")
	local audio_name_config = {
		"rxcq_jiangli1","rxcq_jiangli2","rxcq_jiangli3"
	}
	if self.lv > 1 then
		self.audio_key = ExtendSoundManager.PlaySound(audio_config.rxcq[audio_name_config[self.lv]].audio_name)
	end
	self.cut_txt.text = cut_down_config[self.lv].."s~"
	local cut_t = cut_down_config[self.lv]
	self.Cut_Timer = Timer.New(
		function()
			cut_t = cut_t - 1
			self.cut_txt.text = cut_t.."s~"
			if cut_t <= 0 then
				self:MyExit()
			end
		end
	,1,-1,nil,true)
	self.Cut_Timer:Start()
	RXCQModel.AddTimers(self.Cut_Timer)
	self:InitUI()
	ExtendSoundManager.PauseSceneBGM()
end

function C:InitUI()
	self.clear_btn.onClick:AddListener(function()
		self:OnClickClearBtn()
	end)
	if self.lv > 1 then
		self:ShowScoreAnim()
	else
		self.score_txt.text = "+" .. string.format("%.0f", self.score)
		self.state = clear_state.score_show_end
	end

	if RXCQModel.player_chuansong_type == "mini_game" then
		RXCQModel.GetRegisterObj("RXCQGamePanel_temp_player_node").gameObject:SetActive(true)
	end
	self:MyRefresh()
end


function C:OnClickClearBtn()
	dump(self.state ,"<color=white>---------Clearing----------OnClickClearBtn-------</color>")
	if self.state == clear_state.score_showing then
		if self.add_money_timer then
			self.add_money_timer:Stop()
		end
		self:StopShowScoreAnim()
		if self.lv == 3 then
			self.Animator:Play("RXCQClearing_zszt_xunhuan")
		elseif self.lv == 2 then
			self.Animator:Play("RXCQClearing_txws_xunhuan")
		end
	elseif self.state == clear_state.score_show_end then
		self:MyExit()
	end
end

function C:ShowScoreAnim()

	if self.state ~= clear_state.score_showing then
		self.state = clear_state.score_showing
	end

	--间隔时间
	local durtion_time = 0.05
	--初始数值比例
	local start_rate = 0.25
	--动画持续时间
	local anim_show_time = 3
	
	local time_index = 0
	--初始化显示数字
	self.start_score = self.score * start_rate
	self.cur_show_score = self.start_score

	if self.add_money_timer then
		self.add_money_timer:Stop()
	end
	self.add_money_timer = nil
	self.add_money_timer = Timer.New(function()
		time_index = time_index + 1
		if self.cur_show_score > self.score * 0.9 then
			self:StopShowScoreAnim()
			if self.add_money_timer then
				self.add_money_timer:Stop()
			end
		else
			local d = time_index / (anim_show_time / durtion_time)
			self.cur_show_score = self.start_score + (self.score - self.start_score ) * d
			self:ShowScoreTxt(self.cur_show_score)
		end
	end,durtion_time,-1,nil,true)
	self.add_money_timer:Start()
	RXCQModel.AddTimers(self.add_money_timer)
end

function C:StopShowScoreAnim()
	self:ShowScoreTxt(self.score)
	if self.state ~= clear_state.score_show_end then
		self.state = clear_state.score_show_end
	end

end

function C:ShowScoreTxt(_score)
	self.score_txt.text = "+" .. string.format("%.0f", _score)
end

function C:MyRefresh()

end
