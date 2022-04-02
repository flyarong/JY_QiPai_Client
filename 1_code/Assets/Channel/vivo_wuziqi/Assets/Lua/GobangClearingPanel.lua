-- 创建时间:2019-02-27

local basefunc = require "Game.Common.basefunc"

GobangClearingPanel = basefunc.class()

local C = GobangClearingPanel
C.name = "GobangClearingPanel"

local instance
function C.Create()
	if SysInteractivePlayerManager then
		SysInteractivePlayerManager.Close()
	end
	if SysInteractiveChatManager then
		SysInteractiveChatManager.Hide()
	end

	if not instance then
		instance = C.New()
	else
		instance:MyRefresh()
	end
	return instance
end

function C.Close()
	if instance then
		instance:MyExit()
	end
	instance = nil
end

function C.isGameOverStatus()
	return GobangModel.data.model_status == GobangModel.Model_Status.gameover
end

-- 关闭
function C:MyExit()
	Event.Brocast("activity_fg_close_clearing")
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["model_fg_gameover_msg"] = basefunc.handler(self, self.on_model_fg_gameover_msg)
    self.lister["fg_ready_response_code"] = basefunc.handler(self, self.on_fg_ready_response_code)
    self.lister["fg_huanzhuo_response_code"] = basefunc.handler(self, self.on_fg_huanzhuo_response_code)
end
function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
end

function C:ctor()

	ExtPanel.ExtMsg(self)

	self.gameExitTime = os.time()

	local parent = GameObject.Find("Canvas/LayerLv2").transform
	self:MakeLister()
	self:AddMsgListener()
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)

    self.Back_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnBackClick()
	end)
	self.Changedesk_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnChangedeskClick()
	end)
	self.Ready_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnReadyClick()
	end)
	self.SeeCard_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnLockClick()
	end)
	self.Mark_btn.onClick:AddListener(function ()
		self:OnLockClick()
	end)

	self.isLockChessboard = false
	local iswin_state = ""
	if GobangModel.data then
		local gd = GobangModel.data
		if gd.settlement_info.win_seat and gd.settlement_info.win_seat == 0 then
			iswin_state = "ping"
		elseif gd.settlement_info.win_seat == gd.seat_num then
			iswin_state = "win"
		else
			iswin_state = "lose"
		end
	end
	self.iswin_state = iswin_state
	if iswin_state == "ping" or iswin_state == "win" then
		ExtendSoundManager.PlaySound(audio_config.wzq.bgm_ying.audio_name)
	else
		ExtendSoundManager.PlaySound(audio_config.wzq.bgm_shu.audio_name)
	end

	self:MyRefresh()
end
function C:MyRefresh()
	self.GameExitTime_txt.text = os.date("%Y.%m.%d %H:%M:%S", self.gameExitTime)
	self:RefreshOper()
	
	self.WinNode.gameObject:SetActive(self.iswin_state == "win")
	self.LoseNode.gameObject:SetActive(self.iswin_state == "lose")
	self.PingNode.gameObject:SetActive(self.iswin_state == "ping")

	if self.iswin_state == "lose" then
		self:CheckShow1YuanGift()
	end

	self:RefreshLock()
end
function C:RefreshOper()
	local is_game_over = C.isGameOverStatus()

	self.Back_btn.gameObject:SetActive(is_game_over)
	self.Changedesk_btn.gameObject:SetActive(is_game_over)
	self.Ready_btn.gameObject:SetActive(is_game_over)
	self.SeeCard_btn.gameObject:SetActive(is_game_over)
end

function C:RefreshLock()
	local b = true
	if self.isLockChessboard then
		self.SeeCard_txt.text = "查看结算"
		b = false
	else
		b = true
		self.SeeCard_txt.text = "查看棋局"
	end
	self.Details.gameObject:SetActive(b)
	self.BigBG.gameObject:SetActive(b)
	self.Back_btn.gameObject:SetActive(b)
	self.SeeCard_btn.gameObject:SetActive(b)
	self.Changedesk_btn.gameObject:SetActive(b)
end

function C:on_model_fg_gameover_msg()
	self:RefreshOper()
    if GobangModel.data.glory_score_count then
		local v1 = GobangModel.data.glory_score_count
		local v2 = GobangModel.data.glory_score_change
    end
end

function C:on_fg_ready_response_code(result)
	if result == 0 then
		C.Close()
	end
end
function C:on_fg_huanzhuo_response_code(result)
	if result == 0 then
		C.Close()
	end
end

-- 换桌
function C:OnChangedeskClick()
	self:CheckShow1YuanGift(function ()	
	    GobangModel.HZCheck()
	end)
end

-- 准备
function C:OnReadyClick()
	self:CheckShow1YuanGift(function ()	
		GobangModel.ZBCheck()
	end)
end

-- 查看
function C:OnLockClick()
	self.isLockChessboard = not self.isLockChessboard
	self:RefreshLock()
end

-- 返回
function C:OnBackClick()
	local quit_game_func = function(data)
		if data.result == 0 then
			MainLogic.ExitGame()
			GameManager.GotoUI({gotoui = "game_Hall"})
		else
			HintPanel.ErrorMsg(data.result)
		end
	end
	if Network.SendRequest("fg_quit_game", nil, "请求返回",quit_game_func) then
		C.Close()
    else
		MJAnimation.Hint(2,Vector3.New(0,-350,0),Vector3.New(0,0,0))
    end
end

-- 破产
function C:CheckShow1YuanGift(call)
	if GameGlobalOnOff.Shop_10_gift_bag ~= nil and GameGlobalOnOff.Shop_10_gift_bag == false then
		if call then call() end
		return
	end

	local data = GobangModel.data
	if not data then return end

	local seat_num = data.seat_num
	local seat_data = GobangModel.GetSeatnoToPlayer(seat_num)
	if not seat_data then return end
	local myScore = seat_data.base.score
	local gameCfg = GameFreeModel.GetGameIDToConfig(GobangModel.baseData.game_id)

	local brokeUp = false
	if gameCfg.order == 1 and myScore < gameCfg.enterMin then
		brokeUp = true
	else
		local uiConfigs = GameFreeModel.UIConfig.gameConfigMap
		for _, config in ipairs(uiConfigs) do
			if config.game_type == gameCfg.game_type and config.order == 1 and myScore < config.enterMin then
				brokeUp = true
				break
			end
		end
	end
 
	if brokeUp then
		OneYuanGift.Create(nil, call)
	else
		if call then
			call()
		end
	end
end
