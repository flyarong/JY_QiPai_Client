--ganshuangfeng 比赛场等待界面
--2018-04-17
local basefunc = require "Game.Common.basefunc"

CityMatchWaitPanel = basefunc.class()

CityMatchWaitPanel.name = "CityMatchWaitPanel"
local lister
local listerRegisterName="CityMatchWaitListerRegister"

local instance
function CityMatchWaitPanel.Create()
	instance=CityMatchWaitPanel.New()
	return createPanel(instance,CityMatchWaitPanel.name)
end
function CityMatchWaitPanel.Bind()
	local _in=instance
	instance=nil
	return _in
end

function CityMatchWaitPanel:Awake()
	self:MyInit()
end

function CityMatchWaitPanel:Start()
	self:MyRefresh()
end


function CityMatchWaitPanel:OnDestroy()
	lister = nil
	self.behaviour:ClearClick()
end

--[[初始化功能，创建好panel后在Award中调用，只做一次]]
function CityMatchWaitPanel:MyInit()
	LuaHelper.GeneratingVar(self.transform, self)
	--self.behaviour:AddClick(self.close_btn.gameObject, CityMatchWaitPanel.OnClickCloseSignup, self)

	self.back_btn.onClick:AddListener(
        function()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
            self:OnClickCloseSignup()
        end
    )

	self:MakeLister()
	CityMatchLogic.setViewMsgRegister(lister,listerRegisterName)
	--倒计时
	self.timer = Timer.New(basefunc.handler(self,self.updateCountdown) , 1, -1, true)
	self.timer:Start()
	--********************
	self.allPlayer=0
	self.curPlayer=0
	self.countdown=0

    if MatchModel.data.game_id then
        log("---------------->>> Current game id:" .. MatchModel.data.game_id)
        self.transform:Find("ImgTitle").gameObject:SetActive(false)
        self.transform:Find("Slider").gameObject:SetActive(true)
        self.RankReward = ComMatchRankRewardPanel.Create(MatchModel.GetGameCfg(MatchModel.data.game_id), MatchModel.GetGameIDToAward(MatchModel.data.game_id))
        self.RankReward.transform.position = self.transform:Find("RankReward").position
    end
end

function CityMatchWaitPanel:updateCountdown()
	if self.countdown  and self.countdown>0 then
		self.countdown= self.countdown-1
		--self:refreshCountDown()
	end
end

--[[function CityMatchWaitPanel:refreshCountDown()
	self.close_txt.text = self.countdown .. "秒后可返回"
	if self.countdown<=0 then
		local close_btn_img = self.close_btn.gameObject:GetComponent("Image")
		close_btn_img.sprite = GetTexture("com_btn_5")
		close_btn_img:SetNativeSize()
		self.close_btn.enabled = true
		self.close_txt.gameObject:SetActive(false)
		self.close1_txt.gameObject:SetActive(true)
		-- self.close_txt.text = "<size=44>返  回</size>"
		-- self.close_txt.color = Color.New(247,246,242)
		-- local outLine = self.close_txt.gameObject:GetComponent("Outline")
		-- outLine.effectColor = Color.New(169,94,48)
	end
end]]

function CityMatchWaitPanel:refreshCountDown()
	self.back_txt.text = self.countdown .. "秒后可返回"
	if self.countdown<=0 then
		self.back_btn.enabled = true
		self.back_txt.text = ""
	end
end

function CityMatchWaitPanel:refreshAllPlayer(num)
	if not num or num==self.allPlayer then 
		return 
	end
	self.allPlayer=num
	self.all_player_txt.text = "满" .. num .. "人开赛"
end
function CityMatchWaitPanel:refreshCurPlayer(num)
	if not num or num==self.curPlayer then 
		return 
	end
	self.curPlayer=num
	self.num_txt.text = num
	local startFillAmount = self.fill_img.fillAmount
	local endFillAmount = self.curPlayer / self.allPlayer
	if startFillAmount ~= fillAmount then
		self.waitTimer = DDZAnimation.ChangeWaitUI(self.fill_img,self.effect,startFillAmount,endFillAmount)
	end
end

--[[function CityMatchWaitPanel:refreshCancelSignBtn(isCancelSignup,countdown)
	--断线重连缺少is_cancel_signup，待完成
	-- if not isCancelSignup then 
	-- 	return 
	-- end
	if isCancelSignup==0 then
		self.close_btn.gameObject:SetActive(false)
		return 
	end

	self.close_btn.gameObject:SetActive(true)
	if not countdown then
		return 
	end
	local time=math.ceil(countdown)
	if time ~=self.countdown then
		self.countdown=time
		local close_btn_img = self.close_btn.gameObject:GetComponent("Image")
		close_btn_img.sprite = GetTexture("com_btn_8")
		close_btn_img:SetNativeSize()
		self.close_btn.enabled = false
	end	
	self:refreshCountDown()
end]]

function CityMatchWaitPanel:refreshCancelSignBtn(isCancelSignup,countdown)
	--断线重连缺少is_cancel_signup，待完成
	-- if not isCancelSignup then 
	-- 	return 
	-- end
	if isCancelSignup==0 then
		self.back_btn.gameObject:SetActive(false)
		return 
	end

	self.back_btn.gameObject:SetActive(true)
	if not countdown then
		return 
	end
	local time=math.ceil(countdown)
	if time ~=self.countdown then
		self.countdown=time
		self.back_btn.enabled = false
	end	
	self:refreshCountDown()
end

--[[刷新功能，供Logic和model调用，重复性操作]]
function CityMatchWaitPanel:MyRefresh()
	if CityMatchModel.data then
		self:refreshAllPlayer(CityMatchModel.data.total_players)
		self:refreshCurPlayer(CityMatchModel.data.signup_num)
		self:refreshCancelSignBtn(CityMatchModel.data.is_cancel_signup, CityMatchModel.data.countdown)
	end
end

--[[退出功能，供logic和model调用，只做一次]]
function CityMatchWaitPanel:MyExit()
	self.timer:Stop()
	if self.waitTimer then
		self.waitTimer:Stop()
	end
	
    if self.RankReward then
        self.RankReward:Close()
    end
	CityMatchLogic.clearViewMsgRegister(listerRegisterName)
	--closePanel(CityMatchWaitPanel.name)
end

function CityMatchWaitPanel:MyClose()
    self:MyExit()
    closePanel(CityMatchWaitPanel.name)
end

function CityMatchWaitPanel:MakeLister()
	lister={} 
	lister["model_citymg_req_cur_signup_num_response"]=basefunc.handler(self,self.model_citymg_req_cur_signup_num_response)
end


function  CityMatchWaitPanel:model_citymg_req_cur_signup_num_response(result)
	if result==0 then
		self:refreshCurPlayer(CityMatchModel.data.signup_num)
	else
		--错误处理 （弹窗）
		-- HintPanel.ErrorMsg(result)
		print("<color=red>citymg_req_cur_signup_num_response</color>",result)
	end	
end

function CityMatchWaitPanel:OnClickCloseSignup()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	Network.SendRequest("citymg_cancel_signup",{},"取消报名",function (data)
		if data.result == 0 then
			Event.Brocast("citymg_cancel_signup_response","citymg_cancel_signup_response",data)
		else
			HintPanel.ErrorMsg(data.result)
		end
	end)
end