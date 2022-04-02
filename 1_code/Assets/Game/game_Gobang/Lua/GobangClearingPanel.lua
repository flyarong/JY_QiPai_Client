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
	
    if self.room_rent_time then
        self.room_rent_time:Stop()
    end
    self.room_rent_time = nil
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

	self.room_rent_time = Timer.New(function()
        if IsEquals(self.RoomRent_txt.gameObject) then
            self.RoomRent_txt.gameObject:SetActive(false)
        end
    end, 3, 1, true)
    self.room_rent_time:Start()

    -- 玩家UI
    self.player_ui = {}
    for i=1,2 do
    	local dd = {}
    	LuaHelper.GeneratingVar(self["PlayerRect"..i], dd)
    	self.player_ui[i] = dd
    end
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
		ExtendSoundManager.PlaySound(audio_config.game.sod_game_win.audio_name)
	else
		ExtendSoundManager.PlaySound(audio_config.game.sod_game_lose.audio_name)
	end

	local gameCfg = GameFreeModel.GetGameIDToConfig(GobangModel.baseData.game_id)
	if gameCfg then
		local gameTypeCfg = GameFreeModel.GetGameTypeToConfig(gameCfg.game_type)
		self.gameName_txt.text = gameTypeCfg.name
	end

	self:MyRefresh()
end
function C:MyRefresh()
	local room_rent = GobangModel.baseData.room_rent
	if room_rent then
		self.RoomRent_txt.text = room_rent.asset_count .. AwardManager.GetAwardName(room_rent.asset_type)
	end
	self.GameExitTime_txt.text = os.date("%Y.%m.%d %H:%M:%S", self.gameExitTime)
	self:RefreshOper()
	self:RefreshPlayer()

	
	if self.iswin_state == "win" then
		self.WinNode.gameObject:SetActive(true)
		self.LoseNode.gameObject:SetActive(false)
	else
		self.WinNode.gameObject:SetActive(false)
		self.LoseNode.gameObject:SetActive(true)
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

function C:RefreshPlayer()
	local call = function ()
		for i=1, 2 do
			local seatno = GobangModel.GetPosToSeatno(i)
			local user = GobangModel.data.settlement_players_info[seatno]

	        URLImageManager.UpdateHeadImage(user.head_link, self.player_ui[i].head_img)
			PersonalInfoManager.SetHeadFarme(self.player_ui[i].HeadFrameImage_img, user.dressed_head_frame)
			VIPManager.set_vip_text(self.player_ui[i].head_vip_txt,user.vip_level)
	        self.player_ui[i].name_txt.text = user.name
	        self.player_ui[i].base_score_txt.text = GobangModel.data.init_stake
	        self.player_ui[i].bei_score_txt.text = GobangModel.data.settlement_info.p_rate
	        self.player_ui[i].change_score_txt.text = StringHelper.ToCashSymbol(GobangModel.data.settlement_info.award[seatno])
		end		
	end

	if GobangModel.data.settlement_players_info then
		call()
	else
		Network.SendRequest("fg_get_settlement_players_info",nil,"正在请求数据",
		function (data)
	        if data and data.result == 0 and GobangModel.data then
		    	GobangModel.data.settlement_players_info = data.settlement_players_info
		    	call()
	        end
	    end)
	end
end

function C:on_model_fg_gameover_msg()
	self:RefreshOper()
    if GobangModel.data.glory_score_count then
		local v1 = GobangModel.data.glory_score_count
		local v2 = GobangModel.data.glory_score_change
		--GameHonorModel.UpdateHonorValue(v1)
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
	if Network.SendRequest("fg_quit_game", nil, "请求返回") then
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
