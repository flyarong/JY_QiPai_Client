--ganshuangfeng 比赛场等待界面
--2018-04-17
local basefunc = require "Game.Common.basefunc"
ComMatchWaitRematchPanel = basefunc.class()
local M = ComMatchWaitRematchPanel
M.name = "ComMatchWaitRematchPanel"
local lister
local listerRegisterName="DdzMatchWaitRematchListerRegister"
local instance
function M.Create(parm)
	DSM.PushAct({panel = M.name})
	SysInteractivePlayerManager.Close()
    SysInteractiveChatManager.Hide()
	if instance then
        instance:MyExit()
    end
    instance = M.New(parm)
    return instance
end

function M.CloseUI()
    if instance then
        instance:MyClose()
    end
end

function M:ctor(parm)
	self.parm = parm
	self.cfg = MatchModel.GetGameCfg(MatchModel.GetCurrGameID())
	dump(self.cfg,"<color=white>self.cfg</color>")
    local parent = GameObject.Find("Canvas/LayerLv1").transform
    self:MakeLister()
    local obj = newObject(M.name, parent)
    local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
    self:MyInit()
    self:MyRefresh()
end

--[[初始化功能，创建好panel后在Award中调用，只做一次]]
function M:MyInit()
	ExtendSoundManager.PlaySceneBGM(audio_config.match.bgm_bisai_bisaidengdai.audio_name)
	LuaHelper.GeneratingVar(self.transform, self)
	self.back_btn.onClick:AddListener(
        function()
			self:OnClickCloseSignup()
        end
	)
	self.leave_btn.onClick:AddListener(
        function()
			self:OnClickLeave()
        end
    )
	self:MakeLister()
	self.parm.logic.setViewMsgRegister(lister,listerRegisterName)
	self.timer = Timer.New(basefunc.handler(self,self.UpdateCountdown) , 1, -1, true)
	self.timer:Start()
	self.countdown=0
	self.curPlayerNum = 0
	local gameId = MatchModel.GetCurrGameID()
	if gameId and MatchModel.CheckIsTryouts(gameId) then
		MainModel.CheckPushNotification()
	end
end

function M:UpdateCountdown()
	if self.countdown  and self.countdown>0 then
		self.countdown= self.countdown-1
		self:RefreshCountdown()
	elseif self.countdown  and self.countdown == 0 then
		self.hint_zero_txt.text = "请稍等，比赛即将开始"
	end

	self:updateCountdownClose()
end

function M:RefreshCountdown()
	local list = split(os.date("%M:%S", self.countdown), ":")
		self.countdown_1_txt.text = list[1]
		self.countdown_2_txt.text = list[2]
end

--[[刷新功能，供Logic和model调用，重复性操作]]
function M:MyRefresh()
	dump(self.parm.model.data,"<color=green>self.parm.model.data</color>")
	local game_id = MatchModel.GetCurrGameID()
	if game_id then
		if not self.RankReward then
			local game_cfg = MatchModel.GetGameCfg(game_id)
			self.RankReward = ComMatchRankRewardPanel.Create(game_cfg, game_cfg.award,self.RankRewardNode)
		end

		Network.SendRequest("nor_mg_get_match_status",{id = game_id})
		self.countdown_root.gameObject:SetActive(true)
	elseif not game_id then
		self.countdown_root.gameObject:SetActive(false)
	end
	self:refreshCurPlayer(self.parm.model.data.signup_num)

	self:refreshCancelSignBtn(self.parm.model.data.is_cancel_signup, self.parm.model.data.countdown)
end

function M:refreshCancelSignBtn(isCancelSignup, countdown)
    if isCancelSignup == 0 then
        self.back_btn.gameObject:SetActive(false)
        return
    end

    self.back_btn.gameObject:SetActive(false)
    if not countdown then
        return
    end
    local time = math.ceil(countdown)
    if time ~= self.countdown_close then
        self.countdown_close = time
        self.back_btn.interactable = false
        self.back_btn.gameObject:SetActive(false)
        self.close_txt.gameObject:SetActive(true)
    end
    self:refreshCountDown()
end

function M:refreshCountDown()
    self.close_txt.text = self.countdown_close .. "秒后可退出比赛"
    if self.countdown_close <= 0 then
        self.back_btn.interactable = true
        self.back_btn.gameObject:SetActive(true)
        self.leave_btn.interactable = true
        self.leave_btn.gameObject:SetActive(false)
        self.close_txt.gameObject:SetActive(false)
    end
end

function M:updateCountdownClose()
    if self.countdown_close and self.countdown_close > 0 then
        self.countdown_close = self.countdown_close - 1
        self:refreshCountDown()
    end
end

--[[退出功能，供logic和model调用，只做一次]]
function M:MyExit()
	DSM.PopAct()
	if self.timer then
		self.timer:Stop()
		self.timer = nil
	end
	
    if self.RankReward then
        self.RankReward:Close()
	end
	if self.parm then
		self.parm.logic.clearViewMsgRegister(listerRegisterName)
	end
	self.parm = nil
	GameObject.Destroy(self.gameObject)
	instance = nil
end

function M:MyClose()
    self:MyExit()
end

function M:MakeLister()
	lister={}
	lister["model_nor_mg_req_cur_signup_num_response"] = basefunc.handler(self, self.model_nor_mg_req_cur_signup_num_response)
	lister["model_nor_mg_get_match_status_response"] = basefunc.handler(self,  self.model_nor_mg_get_match_status_response)
end

function M:model_nor_mg_req_cur_signup_num_response(result)
    if result == 0 then
        self:refreshCurPlayer(self.parm.model.data.signup_num)
    else
        --错误处理 （弹窗）
        -- HintPanel.ErrorMsg(result)
        print("<color=red>mg_req_cur_signup_num_response</color>",result)
    end
end

function M:model_nor_mg_get_match_status_response()
	local data = self.parm.model.data
	if data and data.model_status == self.parm.model.Model_Status.wait_begin then
	   if data.start_time and data.start_time > 0 then
			self.countdown = data.start_time
			self:UpdateCountdown()
		end
    end
end

function M:OnClickCloseSignup(go)
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	local pre = HintPanel.Create(2,"比赛即将开始，大额奖励等您领取，千万不要错过！",function ()
		Network.SendRequest("nor_mg_cancel_signup", {})
	end)
	pre:SetButtonText(nil, "残忍退出")
	pre:SetMiniHitText("确定要现在退出比赛吗？")
end

function M:OnClickLeave(go)
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	local pre = HintPanel.Create(2,"比赛即将开始，现在离开可能错过比赛，请记得提前来参赛哦！",function ()
		Network.SendRequest("leave_match_game", {})
	end)
	pre:SetButtonText(nil, "离开一会儿")
end

function M:refreshCurPlayer(num)
    if not num or num == self.curPlayerNum then
        return
	end
	self.curPlayerNum = num
	self.hint_zero_txt.text = "已报名人数：" .. num
end
