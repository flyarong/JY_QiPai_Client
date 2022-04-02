--ganshuangfeng 比赛场等待界面
--2018-04-17
local basefunc = require "Game.Common.basefunc"

CityMatchWaitRematchPanel = basefunc.class()

CityMatchWaitRematchPanel.name = "CityMatchWaitRematchPanel"
local lister
local listerRegisterName="CityMatchWaitRematchListerRegister"
local instance
function CityMatchWaitRematchPanel.Create()
	instance=CityMatchWaitRematchPanel.New()
	return createPanel(instance,CityMatchWaitRematchPanel.name)
end
function CityMatchWaitRematchPanel.Bind()
	local _in=instance
	instance=nil
	return _in
end

function CityMatchWaitRematchPanel:Awake()
	self:MyInit()
end

function CityMatchWaitRematchPanel:Start()
	self:MyRefresh()
end


function CityMatchWaitRematchPanel:OnDestroy()
	lister = nil
	self.behaviour:ClearClick()
end

--[[初始化功能，创建好panel后在Award中调用，只做一次]]
function CityMatchWaitRematchPanel:MyInit()
	LuaHelper.GeneratingVar(self.transform, self)
	self.behaviour:AddClick(self.back_btn.gameObject, CityMatchWaitRematchPanel.OnClickCloseSignup, self)

	self:MakeLister()
	CityMatchLogic.setViewMsgRegister(lister,listerRegisterName)
	--倒计时
	self.timer = Timer.New(basefunc.handler(self,self.UpdateCountdown) , 1, -1, true)
	self.timer:Start()
	--********************
	self.countdown=0
	self.curPlayerNum = 0

    if MatchModel.data.game_id then
        log("---------------->>> Current game id:" .. MatchModel.data.game_id)
        self.RankReward = ComMatchRankRewardPanel.Create(MatchModel.GetGameCfg(MatchModel.data.game_id), MatchModel.GetGameIDToAward(MatchModel.data.game_id))
        self.RankReward.transform.position = self.transform:Find("RankReward").position
    end
end

function CityMatchWaitRematchPanel:UpdateCountdown()
	if self.countdown  and self.countdown>0 then
		self.countdown= self.countdown-1
		self:RefreshCountdown()
	end
end

function CityMatchWaitRematchPanel:RefreshCountdown()
	local list = split(os.date("%M:%S", self.countdown), ":")
		self.countdown_1_txt.text = list[1]
		self.countdown_2_txt.text = list[2]
end

--[[刷新功能，供Logic和model调用，重复性操作]]
function CityMatchWaitRematchPanel:MyRefresh()
	if CityMatchModel.data then
		local func_get_state_data = function ( state_data )
			dump(state_data, "<color=green>state_data:</color>")
			if IsEquals(self.transform)then
				if state_data.state == MainModel.CityMatchState.CMS_MatchStage_Two_Singup  then
					self.countdown = state_data.time
					self:RefreshCountdown()
				else
					self.timer:Stop()
					--请等待，即将开赛
					self.hint_zero.gameObject:SetActive(true)
				end
			end
		end
		CityMatchModel.GetGameStateData(func_get_state_data)
		self:refreshCurPlayer(CityMatchModel.data.signup_num)
	end
end

--[[退出功能，供logic和model调用，只做一次]]
function CityMatchWaitRematchPanel:MyExit()
	self.timer:Stop()
	
    if self.RankReward then
        self.RankReward:Close()
    end
	CityMatchLogic.clearViewMsgRegister(listerRegisterName)
	--closePanel(CityMatchWaitRematchPanel.name)
end
function CityMatchWaitRematchPanel:MyClose()
    self:MyExit()
    closePanel(CityMatchWaitRematchPanel.name)
end

function CityMatchWaitRematchPanel:MakeLister()
	lister={}
	lister["city_match_refersh_state"] = basefunc.handler(self,  self.city_match_refersh_state)
end

function CityMatchWaitRematchPanel:city_match_refersh_state()
	self:MyRefresh()
end

function CityMatchWaitRematchPanel:OnClickCloseSignup(go)
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	HintPanel.Create(2,"复赛马上就要开始了，退出可能会错过比赛，您确定真的要退出么？",function ()
		Network.SendRequest("citymg_cancel_signup",{},"取消报名",function (data)
			if data.result == 0 then
				Event.Brocast("citymg_cancel_signup_response","citymg_cancel_signup_response",data)
			else
				HintPanel.ErrorMsg(data.result)
			end
		end)
	end)
end

function CityMatchWaitRematchPanel:refreshCurPlayer(num)
    if not num or num == self.curPlayerNum then
        return
	end
	
	self.curPlayerNum = num
    self.hint_zero.text = "已报名人数：" .. num
end
