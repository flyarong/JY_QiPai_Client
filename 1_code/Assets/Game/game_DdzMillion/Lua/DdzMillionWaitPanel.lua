--ganshuangfeng 比赛场等待界面
--2018-04-17
local basefunc = require "Game.Common.basefunc"

DdzMillionWaitPanel = basefunc.class()

DdzMillionWaitPanel.name = "DdzMillionWaitPanel"
local lister
local listerRegisterName="ddzMillionWaitListerRegister"
local instance
function DdzMillionWaitPanel.Create()
	instance=DdzMillionWaitPanel.New()
	return createPanel(instance,DdzMillionWaitPanel.name)
end
function DdzMillionWaitPanel.Bind()
	local _in=instance
	instance=nil
	return _in
end

function DdzMillionWaitPanel:Awake()
	self:MyInit()
end

function DdzMillionWaitPanel:Start()
	self:MyRefresh()
end


function DdzMillionWaitPanel:OnDestroy()
	lister = nil
	self.behaviour:ClearClick()
end

--[[初始化功能，创建好panel后在Award中调用，只做一次]]
function DdzMillionWaitPanel:MyInit()
	LuaHelper.GeneratingVar(self.transform, self)
	self.behaviour:AddClick(self.back_btn.gameObject, DdzMillionWaitPanel.OnClickCloseSignup, self)

	self:MakeLister()
	DdzMillionLogic.setViewMsgRegister(lister,listerRegisterName)
	--倒计时
	self.timer = Timer.New(basefunc.handler(self,self.UpdateCountdown) , 1, -1, true)
	self.timer:Start()
	--********************
	self.gold=0
	self.countdown=0
end

function DdzMillionWaitPanel:UpdateCountdown()
	if self.countdown  and self.countdown>0 then
		self.countdown= self.countdown-1
		self:RefreshCountdown()
	end
end

function DdzMillionWaitPanel:RefreshCountdown()
	local list = split(os.date("%M:%S", self.countdown), ":")
		self.countdown_1_txt.text = list[1]
		self.countdown_2_txt.text = list[2]
end

function DdzMillionWaitPanel:RefreshGold(num)
	self.gold=num
	self.gold_txt.text = "￥" .. math.floor(num / 100)
end


--[[刷新功能，供Logic和model调用，重复性操作]]
function DdzMillionWaitPanel:MyRefresh()
	if DdzMillionModel.data then
		self:RefreshGold(DdzMillionModel.data.match_info.bonus)
		self.countdown = tonumber(DdzMillionModel.data.match_info.begin_time) - os.time()
		self:RefreshCountdown()
	end
end

--[[退出功能，供logic和model调用，只做一次]]
function DdzMillionWaitPanel:MyExit()
	self.timer:Stop()
	DdzMillionLogic.clearViewMsgRegister(listerRegisterName)
	--closePanel(DdzMillionWaitPanel.name)
end
function DdzMillionWaitPanel:MyClose()
    self:MyExit()
    closePanel(DdzMillionWaitPanel.name)
end

function DdzMillionWaitPanel:MakeLister()
	lister={} 
	lister["dbwgModel_dbwg_cancel_signup_fail_response"]=basefunc.handler(self,self.dbwgModel_dbwg_cancel_signup_fail_response) 
end

function  DdzMillionWaitPanel:dbwgModel_dbwg_cancel_signup_fail_response(result)
	--错误处理 （弹窗）
	HintPanel.ErrorMsg(result)
end

function DdzMillionWaitPanel:OnClickCloseSignup(go)
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	Network.SendRequest("dbwg_cancel_signup",{})
end


