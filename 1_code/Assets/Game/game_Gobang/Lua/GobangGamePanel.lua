local basefunc = require "Game/Common/basefunc"

GobangGamePanel = basefunc.class()

GobangGamePanel.name = "GobangGamePanel"

local CHESS_BLACK = 1
local CHESS_WHITE = 2
local MAX_GRID = 15
local HALF_GRID = 7
local GRID_UNIT = 68
local GRID_OFFSET = 34
local VOFFSET = 1000
local COOLDOWN_MAX = 30
local COOLDOWN_TIME = 10

local function GetUIOffset(pos)
	return (pos - 1 - HALF_GRID) * GRID_UNIT
end

local function GetLOffset(pos)
	local v = math.floor((pos + GRID_OFFSET) / GRID_UNIT)
	v = Mathf.Clamp(v, 0, MAX_GRID - 1)
	return v + 1
end

local function GetAngle(line)
	local head = line[1]
	local tail = line[#line]
	local x = tail[1] - head[1]
	local y = tail[2] - head[2]
	return math.deg(math.atan2(y, x))
end

local function FormatTime(second)
	if second <= 0 then return "00 : 00" end
	local minute = math.floor(second / 60)
	local second = math.floor(second) % 60
	return (minute < 10 and "0" .. minute or minute) .. " : " .. (second < 10 and "0" .. second or second)
end


local instance
local lister = {}

function GobangGamePanel:MakeLister()
	lister = {}

	lister["model_fg_all_info"] = basefunc.handler(self, self.fg_all_info)
	lister["model_fg_enter_room_msg"] = basefunc.handler(self, self.fg_enter_room_msg)
	lister["model_fg_join_msg"] = basefunc.handler(self, self.fg_join_msg)
	lister["model_fg_leave_msg"] = basefunc.handler(self, self.fg_leave_msg)
	lister["model_fg_score_change_msg"] = basefunc.handler(self, self.fg_score_change_msg)
	lister["model_fg_ready_msg"] = basefunc.handler(self, self.model_fg_ready_msg)
	lister["model_fg_huanzhuo_response"] = basefunc.handler(self, self.model_fg_huanzhuo_response)
	lister["model_fg_ready_response"] = basefunc.handler(self, self.model_fg_ready_response)

	lister["model_nor_gobang_nor_begin_msg"] = basefunc.handler(self, self.nor_gobang_nor_begin_msg)
	lister["model_nor_gobang_nor_action_msg"] = basefunc.handler(self, self.nor_gobang_nor_action_msg)
	lister["model_nor_gobang_nor_permit_msg"] = basefunc.handler(self, self.nor_gobang_nor_permit_msg)
	lister["model_nor_gobang_nor_new_game_msg"] = basefunc.handler(self, self.nor_gobang_nor_new_game_msg)
	lister["model_nor_gobang_nor_start_again_msg"] = basefunc.handler(self, self.nor_gobang_nor_start_again_msg)
	lister["model_nor_gobang_nor_settlement_msg"] = basefunc.handler(self, self.nor_gobang_nor_settlement_msg)
	lister["model_nor_gobang_nor_score_change_msg"] = basefunc.handler(self, self.model_nor_gobang_nor_score_change_msg)

	lister["model_nor_gobang_nor_xhz_msg"] = basefunc.handler(self, self.nor_gobang_nor_xhz_msg)
	lister["model_wzq_place_chess"] = basefunc.handler(self, self.handle_wzq_place_chess)
	lister["model_fg_signup_fail_response"] = basefunc.handler(self, self.model_fg_signup_fail_response)  --报名失败
end

function GobangGamePanel.Create()
	if not instance then
		instance = GobangGamePanel.New()
	end
	return instance
end

function GobangGamePanel:ctor()
	local parent = GameObject.Find("Canvas/LayerLv1").transform
	local obj = newObject(GobangGamePanel.name, parent)
	self.transform = obj.transform
	LuaHelper.GeneratingVar(self.transform, self)

	self:MakeLister()
	GobangLogic.setViewMsgRegister(lister, GobangGamePanel.name)

	self.cx = -1
	self.cy = -1
	self:InitRect()
	DOTweenManager.OpenPopupUIAnim(self.transform)

	self:Refresh()
	HandleLoadChannelLua("GobangGamePanel",self)
end

function GobangGamePanel:Awake()
	ExtendSoundManager.PlaySceneBGM(audio_config.wzq.bgm_wuziqi_game.audio_name)
end

function GobangGamePanel.Close()
	if instance then
		GobangLogic.clearViewMsgRegister(GobangGamePanel.name)
		instance:ClearAll()
		--GameObject.Destroy(instance.transform.gameObject)
		instance = nil
		if SysInteractiveChatManager then
			SysInteractiveChatManager.Hide()
		end
		if SysInteractivePlayerManager then
			SysInteractivePlayerManager.Close()
		end
		GobangClearingPanel.Close()

		ExtendSoundManager.PlaySceneBGM(audio_config.game.bgm_main_hall.audio_name)
	end
end

function GobangGamePanel:InitRect()
	local transform = self.transform

	self:SetupInfo()
	self:SetupChessboard()
	self:SetupButtons()
	self:SetupPlayers()
	self:SetupTimer()
	self:SetupWaitBeginUI()

	self.chess_set = {}
	self.segment_set = {}

	self.wait_ui = transform:Find("wait_pairdesk_ui")
	self.wait_ui.gameObject:SetActive(false)
end

function GobangGamePanel:CreateChess(x, y, c)
	local tmpl = self.chess_tmpl[c]
	if not tmpl then
		print(string.format("[WZQ] CreateChess (%d, %d) color(%d) is invalid", x, y, c))
		return
	end

	local chess_set_node = self.chess_set_node
	local wx = GetUIOffset(x)
	local wy = GetUIOffset(y)

	local chess = GameObject.Instantiate(tmpl, chess_set_node)
	chess.transform.localPosition = Vector3.New(wx, wy)

	self.chess_set[x * VOFFSET + y] = chess

	return chess
end

function GobangGamePanel:ClearList(list)
	for k, v in pairs(list) do
		GameObject.Destroy(v.gameObject)
	end
	list = {}
end

function GobangGamePanel:ClearAll()
	self.cx = -1
	self.cy = -1

	if self.updateTimer then
		self.updateTimer:Stop()
		self.updateTimer = nil
	end
	self.updateTimerParams = {}

	self.chess_tmpl = {}
	self.players = {}

	self:ClearList(self.chess_set)
	self.chess_set = {}
	self.last_mark = nil

	self:ClearList(self.segment_set)
	self.segment_set = {}

	self.chess_set_node = nil
	self.segment_set_node = nil

	self.segment = nil
	self.line_x = nil
	self.line_y = nil
	self.chessboard = nil
	self.wait_ui = nil
end

function GobangGamePanel:RefreshWaitUI(cooldown)
	self:SetWaitUITime(cooldown)

	for _, v in pairs(self.players) do
		v.transform.gameObject:SetActive(false)
	end
	self.last_mark.gameObject:SetActive(false)
end

function GobangGamePanel:RefreshWaitBeginUI(cooldown)
	self:SetWaitBeginUITime(cooldown)
	self.last_mark.gameObject:SetActive(false)

	for seatno = 1, 2 do
		self:RefreshPlayerBaseInfo(seatno)
	end
end



function GobangGamePanel:RefreshGameing()
	local data = GobangModel.data
	if not data then
		print("[WZQ] GobangGamePanel RefreshGameing model data invalid")
		return
	end

	if data.model_status == GobangModel.Model_Status.gaming then
		self.chat_btn.gameObject:SetActive(true)
		self.op_transform.gameObject:SetActive(false)
	else
		self.chat_btn.gameObject:SetActive(false)
		self.op_transform.gameObject:SetActive(false)
	end
end

function GobangGamePanel:Refresh()
	local transform = self.transform
	if not IsEquals(transform) then return end

	local data = GobangModel.data
	if not data then
		print("[WZQ] GobangGamePanel refresh model data invalid")
		return
	end

	self:ClearList(self.chess_set)
	self.chess_set = {}

	self:ClearList(self.segment_set)
	self.segment_set = {}

	self:RefreshInfo()
	self:RefreshGameing()

	if data.model_status == GobangModel.Model_Status.wait_table then
		self:RefreshWaitUI(data.countdown)
		return
	elseif data.model_status == GobangModel.Model_Status.wait_begin then
		self:RefreshWaitBeginUI(data.countdown)
		return
	else
		self.wait_ui.gameObject:SetActive(false)
		self.wait_begin_ui.gameObject:SetActive(false)
	end

	local chessboard = GobangModel.GetChessboard()
	for i = 1, MAX_GRID do
		for j = 1, MAX_GRID do
			local color = chessboard[i][j]
			if color == CHESS_WHITE or color == CHESS_BLACK then
				self:CreateChess(i, j, color)
			end
		end
	end

	if self:IsSettlement() then
		self:RefreshChessLine()
		self:RefreshClearing()
	end
	self:RefreshPlayerTimes()

	for seatno = 1, 2 do
		self:RefreshPlayerBaseInfo(seatno)
		self:RefreshPlayerChess(seatno)
	end
	--for _, v in pairs(self.players) do
	--	v.transform.gameObject:SetActive(true)
	--end
end

function GobangGamePanel:MyRefresh()
	self:Refresh()
end

function GobangGamePanel:MyClose()
	GobangGamePanel.Close()
end

function GobangGamePanel:MyExit()
	GobangGamePanel.Close()
end

function GobangGamePanel:SetupInfo()
	local transform = self.transform
	self.game_title = transform:Find("info/title"):GetComponent("Text")
	self.game_score = transform:Find("info/score"):GetComponent("Text")
end

function GobangGamePanel:RefreshInfo()
	local data = GobangModel.data
	if not data then return end

	self.game_title.text = "小赢生金"

	local score = data.init_stake or 0
	self.game_score.text = "底分:" .. score

	local gameCfg = GameFreeModel.GetGameIDToConfig(GobangModel.baseData.game_id)
	if gameCfg then
		local gameTypeCfg = GameFreeModel.GetGameTypeToConfig(gameCfg.game_type)
		self.game_title.text = gameTypeCfg.name
	end
end

function GobangGamePanel:SetupChessboard()
	local transform = self.transform

	--self.chess_tmpl = { GetPrefab("chess_black"), GetPrefab("chess_white") }
	self.chess_tmpl = { GetPrefab("ChessBlack"), GetPrefab("ChessWhite") }

	local chessboard = transform:Find("chessboard")

	self.segment = chessboard:Find("segment")
	self.segment.gameObject:SetActive(false)
	self.segment_set_node = chessboard:Find("segment_set_node")

	self.line_x = chessboard:Find("line_x")
	self.line_y = chessboard:Find("line_y")
	self:SetLineVisible(false)

	self.chess_set_node = chessboard:Find("chess_set_node")

	local zero = chessboard:Find("zero")
	self.zero_position = chessboard:InverseTransformPoint(zero.position)
	self.last_mark = chessboard:Find("last_mark")
	self.last_mark.gameObject:SetActive(false)

	self.place_btn = chessboard:Find("place_btn"):GetComponent("Button")
	self.place_btn.onClick:AddListener(function ()
		self.place_btn.gameObject:SetActive(false)
		self:SetLineVisible(false)

		if self:CanAction() then
			GobangModel.SendPlaceChess(self.cx, self.cy)
		end
	end)
	self.place_btn.gameObject:SetActive(false)

	self.chessboard = chessboard

	PointerEventListener.Get(self.chessboard.gameObject).onDown = function()
		self.place_btn.gameObject:SetActive(false)
		if not self:CanAction() then return end

		local wpos = UnityEngine.Camera.main:ScreenToWorldPoint(UnityEngine.Input.mousePosition)
		local lpos = self.chessboard.transform:InverseTransformPoint(wpos) - self.zero_position

		local cx = GetLOffset(lpos.x)
		local cy = GetLOffset(lpos.y)
		
		local wx = GetUIOffset(cx)
		local wy = GetUIOffset(cy)

		self:SetLineVisible(true)
		self:SetLinePosition(wx, wy)

		self.cx = cx
		self.cy = cy
	end
	PointerEventListener.Get(self.chessboard.gameObject).onUp = function()
		if not self:CanAction() then return end

		local chessboard = GobangModel.GetChessboard()
		if not chessboard[self.cx] or not chessboard[self.cx][self.cy] then return end
		local color = chessboard[self.cx][self.cy]
		if color == CHESS_WHITE or color == CHESS_BLACK then
			self:SetLineVisible(false)
			--LittleTips.Create("此处已有棋子,不能再放棋子")
			return
		end

		local wx = GetUIOffset(self.cx)
		local wy = GetUIOffset(self.cy)
		self.place_btn.transform.localPosition = Vector3.New(wx, wy)
		self.place_btn.gameObject:SetActive(true)
	end
end

function GobangGamePanel:SetupButtons()
	local transform = self.transform

	local menu_btn = transform:Find("menu"):GetComponent("Button")
	local expand = transform:Find("menu/expand")
	local close_btn = expand:Find("close_btn"):GetComponent("Button")
	local help_btn = expand:Find("help_btn"):GetComponent("Button")
	local setup_btn = expand:Find("setup_btn"):GetComponent("Button")

	menu_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		expand.gameObject:SetActive(not expand.gameObject.activeSelf)
	end)

	close_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		Network.SendRequest("fg_quit_game", nil, "返回")
	end)

	help_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)

		GobangHelpPanel.Create()
	end)

	setup_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		GameManager.GotoUI({gotoui = "sys_setting",goto_scene_parm = "panel"})
	end)

	local chat_btn = transform:Find("chat"):GetComponent("Button")
	chat_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		if SysInteractiveChatManager then
			SysInteractiveChatManager.Show()
		end
	end)
	self.chat_btn = chat_btn
	self.chat_btn.gameObject:SetActive(false)

	local op_expand = transform:Find("op/expand")
	local op_open_btn = transform:Find("op/open_btn"):GetComponent("Button")
	op_open_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		op_open_btn.gameObject:SetActive(false)
		op_expand.gameObject:SetActive(true)
	end)
	local op_close_btn = transform:Find("op/expand/close_btn"):GetComponent("Button")
	op_close_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		op_expand.gameObject:SetActive(false)
		op_open_btn.gameObject:SetActive(true)
	end)

	local regret_enable_img = transform:Find("op/expand/regret_enable_img"):GetComponent("Image")
	EventTriggerListener.Get(regret_enable_img.gameObject).onClick = function()
		print("regret_enable_img click")
	end
	local regret_disable_img = transform:Find("op/expand/regret_disable_img"):GetComponent("Image")
	EventTriggerListener.Get(regret_disable_img.gameObject).onClick = function()
		print("regret_disable_img click")
	end
	self.regret_enable_img = regret_enable_img
	self.regret_disable_img = regret_disable_img

	local peace_img = transform:Find("op/expand/peace_img"):GetComponent("Image")
	EventTriggerListener.Get(peace_img.gameObject).onClick = function()
		print("peace_img click")
	end
	local giveup_img = transform:Find("op/expand/giveup_img"):GetComponent("Image")
	EventTriggerListener.Get(giveup_img.gameObject).onClick = function()
		print("giveup_img click")
	end

	self.op_transform = transform:Find("op")
	self.op_transform.gameObject:SetActive(false)

	self.back_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		Network.SendRequest("fg_quit_game", nil, "返回")
	end)
end

function GobangGamePanel:SetupPlayers()
	local transform = self.transform

	self.players = {}

	for i = 1, 2 do
		local player_transform = transform:Find("player" .. i)

		local player = {}
		player.head_img = player_transform:Find("head"):GetComponent("Image")
		player.name_txt = player_transform:Find("name/title"):GetComponent("Text")
		player.gold_txt = player_transform:Find("name/gold_icon/gold"):GetComponent("Text")
		player.chess_img = player_transform:Find("chess"):GetComponent("Image")
		player.chess_img.gameObject:SetActive(false)
		player.chess_cd_img = player_transform:Find("chess/cd"):GetComponent("Image")
		player.chess_cd_img.gameObject:SetActive(false)
		player.chess_cd_txt = player_transform:Find("chess/cd/cd_txt"):GetComponent("Text")
		player.chess_cd_txt.gameObject:SetActive(false)
		player.match_time = player_transform:Find("time/match_time/timer"):GetComponent("Text")
		player.step_time = player_transform:Find("time/step_time/timer"):GetComponent("Text")
		player.transform = player_transform
		player.idx = i
		self.players[i] = player

		local head_frame = player_transform:Find("head/head_frame"):GetComponent("Image")
		EventTriggerListener.Get(head_frame.gameObject).onClick = function()
			local ui_node = player_transform:Find("ui_node")
			self:ShowPlayerInfoPanel(i, ui_node.transform)
		end

		player_transform.gameObject:SetActive(false)
	end
end

function GobangGamePanel:SetupTimer()
	local loop_interval = 0.1
	self.updateTimerParams = {}
	self.updateTimer = Timer.New(function ()
		local transform = self.transform
		if not IsEquals(transform) then return end

		for k, v in pairs(self.updateTimerParams) do
			if not v.pause then
				local interval = v.interval or -1
				if interval >= 0 then
					interval = interval - loop_interval
					v.interval = interval
					v.invoking(interval)
				else
					self.updateTimerParams[k] = nil
				end
			end
		end
	end, loop_interval, -1)
	self.updateTimer:Start()
end

function GobangGamePanel:SetupWaitBeginUI()
	local transform = self.transform
	if not IsEquals(transform) then return end

	self.wait_begin_ui = transform:Find("wait_begin")
	self.wait_begin_ui.gameObject:SetActive(false)
	local change_btn = transform:Find("wait_begin/changedesk_btn"):GetComponent("Button")
	change_btn.onClick:AddListener(function ()
		self.wait_begin_ui.gameObject:SetActive(false)
		GobangModel.HZCheck()
	end)

	self.changedesk_no = transform:Find("wait_begin/changedesk_no")
	self.changedesk_no_txt = transform:Find("wait_begin/changedesk_no/changedesk_hint_txt"):GetComponent("Text")
end



local function_tbl = {
	--["head_img"] = function(player, value) player.head_img.sprite = GetTexture(value) end,
	["head_img"] = function(player, value) URLImageManager.UpdateHeadImage(value, player.head_img) end,
	["name_txt"] = function(player, value) player.name_txt.text = value end,
	["gold_txt"] = function(player, value) player.gold_txt.text = value end,
	["chess_img"] = function(player, value)
				if not value then
					player.chess_img.gameObject:SetActive(false)
					return
				end
				player.chess_img.sprite = GetTexture(value)
				player.chess_img.gameObject:SetActive(true)
			end,
	["chess_cd_img"] = function(player, value)
				player.chess_cd_img.fillAmount = value / (GobangModel.data.countdown_max or 30)
				player.chess_cd_img.gameObject:SetActive(value > 0)

				--print("player idx:" .. player.idx .. " " .. value)

				if value <= 0 or value >= COOLDOWN_TIME then
					player.chess_cd_txt.gameObject:SetActive(false)
					GobangGamePanel.PlayAnimation(nil, player.chess_cd_img, "idle")
				else
					local iv, fv = math.modf(value)
					player.chess_cd_txt.text = iv + 1

					if not player.chess_cd_txt.gameObject.activeSelf then
						player.chess_cd_txt.gameObject:SetActive(true)
						if iv > 0 and fv > 0.85 then
							ExtendSoundManager.PlaySound(audio_config.wzq.bgm_wuziqi_daojishi.audio_name)
						end

						GobangGamePanel.PlayAnimation(nil, player.chess_cd_img, "glow")
					else
						if iv > 0 and math.floor(value * 10) == math.floor(value) * 10 then
							ExtendSoundManager.PlaySound(audio_config.wzq.bgm_wuziqi_daojishi.audio_name)
						end
					end
				end
			end,
	["match_time"] = function(player, value) player.match_time.text = value end,
	["step_time"] = function(player, value) player.step_time.text = value end,
}
function GobangGamePanel:UpdatePlayerInfo(idx, params)
	local transform = self.transform
	if not IsEquals(transform) then return end

	local player = self.players[idx]
	if not player then
		print("[WZQ] UpdatePlayerInfo player invalid:" .. idx)
		return
	end

	for k, v in pairs(params) do
		local invoking = function_tbl[k]
		if invoking then invoking(player, v) end
	end
end

function GobangGamePanel:SetPlayerChessCD(idx, second)
	local key = "player" .. idx .. "_chesscd"
	local params = self.updateTimerParams[key] or {}

	if second > 0 then
		params.interval = second
		params.invoking = function(interval)
			self:UpdatePlayerInfo(idx, {["chess_cd_img"] = interval})
		end
	else
		self:UpdatePlayerInfo(idx, {["chess_cd_img"] = 0})
		params = nil
	end
	self.updateTimerParams[key] = params
end

function GobangGamePanel:SetPlayerMatchTime(idx, match_time, pause)
	local key = "player" .. idx .. "_chess_matchtime"
	local params = self.updateTimerParams[key] or {}

	if match_time > 0 then
		params.interval = match_time
		params.invoking = function(interval)
			self:UpdatePlayerInfo(idx, {["match_time"] = FormatTime(math.ceil(interval))})
		end
	end
	params.pause = pause
	if pause then
		self:UpdatePlayerInfo(idx, {["match_time"] = FormatTime(match_time)})
	end

	self.updateTimerParams[key] = params
end

function GobangGamePanel:SetPlayerStepTime(idx, step_time)
	local key = "player" .. idx .. "_chess_steptime"
	local params = self.updateTimerParams[key] or {}

	if step_time > 0 then
		step_time = step_time - 1
		params.interval = step_time
		params.invoking = function(interval)
			self:UpdatePlayerInfo(idx, {["step_time"] = FormatTime(math.ceil(interval))})
		end
		self:SetPlayerChessCD(idx, step_time)
	else
		self:UpdatePlayerInfo(idx, {["step_time"] = FormatTime(0)})
		self:SetPlayerChessCD(idx, 0)
		params = nil
	end
	self.updateTimerParams[key] = params
end

function GobangGamePanel:RefreshPlayerTimes()
	local function ResetTimes()
		for idx = 1, 2 do
			self:SetPlayerMatchTime(idx, 0, true)
			self:SetPlayerStepTime(idx, 0, true)
		end
	end

	if self:IsSettlement() then
		ResetTimes()
		return
	end

	local data = GobangModel.data
	if not data then
		ResetTimes()
		return
	end

	dump(data, "RefreshPlayerTimes data")

	if data.first_seat == 0 then
		print("[WZQ] RefreshPlayerTimes first_seat invalid:" .. data.first_seat)
		ResetTimes()
		return
	end

	local current = data.cur_p or 0
	if current <= 0 then
		print("[WZQ] RefreshPlayerTimes cur_p invalid:" .. current)
		ResetTimes()
		return
	end

	local other = (2 - current) + 1

	local ui_current = GobangModel.GetSeatnoToPos(current)
	local ui_other = GobangModel.GetSeatnoToPos(other)

	self:SetPlayerMatchTime(ui_current, data.p_race_times[current] or 0, false)
	self:SetPlayerStepTime(ui_current, data.countdown)

	self:SetPlayerMatchTime(ui_other, data.p_race_times[other] or 0, true)
	self:SetPlayerStepTime(ui_other, 0)
end

function GobangGamePanel:SetWaitUITime(second)
	self.wait_ui.gameObject:SetActive(true)

	local key = "waitui_time"
	local params = self.updateTimerParams[key] or {}
	if second > 0 then
		self.offback.gameObject:SetActive(true)
		params.interval = second + 1
		params.invoking = function(interval)
			if interval <= 0 then
				self.offback.gameObject:SetActive(false)
			end
			self.back_time_txt.text = math.ceil(interval) .. "秒后可返回"
		end
	else
		params = nil
		self.offback.gameObject:SetActive(false)
	end
	self.updateTimerParams[key] = params
end

function GobangGamePanel:SetWaitBeginUITime(second)
	self.wait_begin_ui.gameObject:SetActive(true)

	local key = "waitbeginui_time"
	local params = self.updateTimerParams[key] or {}
	if second > 0 then
		self.changedesk_no.gameObject:SetActive(true)
		params.interval = second + 1
		params.invoking = function(interval)
			if interval <= 0 then
				self.changedesk_no.gameObject:SetActive(false)
			end
			self.changedesk_no_txt.text = "换  桌(" .. math.ceil(interval) .. "s)"
		end
	else
		params = nil
		self.changedesk_no.gameObject:SetActive(false)
	end
	self.updateTimerParams[key] = params
end

function GobangGamePanel:ShowPlayerInfoPanel(idx, node)
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)

	local data = GobangModel.GetPosToPlayer(idx)
	if not data then
		print("[WZQ] ShowPlayerInfoPanel GetPosToPlayer is invalid:" .. idx)
		return
	end

	if SysInteractivePlayerManager then
		SysInteractivePlayerManager.Create(data.base, 0, node)
	end
end

function GobangGamePanel:ShowChessLine(chess_lines)
	local chessboard = self.chessboard
	if not IsEquals(chessboard) then return end

	self:ClearList(self.segment_set)
	self.segment_set = {}

	for _, line in pairs(chess_lines) do
		table.sort(line, function(a, b)
			if a[1] == b[1] then return a[2] < b[2] end
			return a[1] < b[1]
		end)

		local segment = GameObject.Instantiate(self.segment, self.segment_set_node)
		segment.gameObject:SetActive(true)
		table.insert(self.segment_set, segment)

		local segment_line = segment.transform:Find("line")

		local angle = GetAngle(line)
		if (angle % 90) == 0 then
			segment_line.gameObject:GetComponent("RectTransform").sizeDelta = Vector2.New((#line - 1) * 70, 30)
		else
			segment_line.gameObject:GetComponent("RectTransform").sizeDelta = Vector2.New((#line - 1) * 99, 30)
		end
		segment_line.localEulerAngles = Vector3.New(0, 0, angle)

		local cx = line[1][1]
		local cy = line[1][2]

		local wx = GetUIOffset(cx)
		local wy = GetUIOffset(cy)

		segment.transform.localPosition = Vector3.New(wx, wy)

		for _, v in pairs(line) do
			local chess = self.chess_set[v[1] * VOFFSET + v[2]]
			if chess then
				local img = chess.transform:Find("Body/circle_img")
				img.gameObject:SetActive(true)
			end
		end
	end
end

function GobangGamePanel:OnExitScene()
	GobangGamePanel.Close()
end

function GobangGamePanel:SetLineVisible(visible)
	if self.line_x then
		self.line_x.gameObject:SetActive(visible)
	end
	if self.line_y then
		self.line_y.gameObject:SetActive(visible)
	end
end

function GobangGamePanel:SetLinePosition(x, y)
	if self.line_x then
		self.line_x.localPosition = Vector3.New(0, y, 0)
	end
	if self.line_y then
		self.line_y.localPosition = Vector3.New(x, 0, 0)
	end
end

function GobangGamePanel:PlayAnimation(object, name)
	if not IsEquals(object) then return end

	local animator = object.transform:GetComponentInChildren(typeof(UnityEngine.Animator))
	if not animator then
		print("[WZQ] PlayAnimation failed, animator is invalid:" .. name)
		return
	end
	animator:Play(name, 0, 0)
	animator:Update(0)
end

function GobangGamePanel:TweenDelay(callbacks, finally_callback)
	local traceTbl = {}

	local seq = DG.Tweening.DOTween.Sequence()
	local tweenKey = DOTweenManager.AddTweenToStop(seq)
	seq:OnKill(function()
		DOTweenManager.RemoveStopTween(tweenKey)

		for k, v in ipairs(traceTbl) do
			if not v then
				if callbacks[k].method then callbacks[k].method() end
			end
		end

		if finally_callback then finally_callback() end
	end)

	for k, v in ipairs(callbacks) do
		traceTbl[k] = false
		seq:AppendInterval(v.stamp):AppendCallback(function()
			traceTbl[k] = true
			if v.method then v.method() end
		end)
	end

	return tweenKey
end
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function GobangGamePanel:RefreshPlayerBaseInfo(seatno)
	local uipos = GobangModel.GetSeatnoToPos(seatno)
	local data = GobangModel.GetSeatnoToPlayer(seatno)

	dump(data, "RefreshPlayerBaseInfo data")

	if not data then
		self.players[uipos].transform.gameObject:SetActive(false)
		print("[WZQ] RefreshPlayerBaseInfo data invalid:" .. seatno .. ", " .. uipos)
		return
	end

	local baseData = data.base
	if not baseData then
		self.players[uipos].transform.gameObject:SetActive(false)
		print("[WZQ] RefreshPlayerBaseInfo baseData invalid:" .. seatno .. ", " .. uipos)
		return
	end

	self.players[uipos].transform.gameObject:SetActive(true)

	print(baseData.head_link)

	local params = {}
	params["head_img"] = baseData.head_link or ""
	params["name_txt"] = baseData.name or ""
	params["gold_txt"] = StringHelper.ToCash(baseData.score)

	self:UpdatePlayerInfo(uipos, params)
end

function GobangGamePanel:RefreshPlayerChess(seatno)
	local transform = self.transform
	if not IsEquals(transform) then return end

	self.last_mark.gameObject:SetActive(false)

	local data = GobangModel.data
	if data then
		local params = {}
		if data.first_seat == 0 then
			params["chess_img"] = nil
		else
			if GobangModel.IsBlackBySeatno(seatno) then
				params["chess_img"] = "wzq_icon_hq"
			else
				params["chess_img"] = "wzq_icon_bq"
			end

			local xq_action = self:GetLastAction(GobangModel.Status.xq)
			if xq_action then
				local chess = gobang_algorithm.parse_pos(xq_action.pos)
				local ui_chess = self.chess_set[chess.x * VOFFSET + chess.y]
				if ui_chess then
					self.last_mark.transform.localPosition = ui_chess.transform.localPosition
					self.last_mark.gameObject:SetActive(true)
				end
			end
		end
		self:UpdatePlayerInfo(GobangModel.GetSeatnoToPos(seatno), params)
	else
		for i = 1, 2 do
			self.players[i].chess_img.gameObject:SetActive(false)
		end
	end
end

function GobangGamePanel:GetLastAction(op_type)
	local data = GobangModel.data
	if not data then return nil end

	local adapt_action = nil

	local action_list = data.actionList or {}
	local count = #action_list
	for idx = count, 1, -1 do
		local action = action_list[idx]
		if action.type == op_type then
			adapt_action = action
			break
		end
	end

	return adapt_action
end

function GobangGamePanel:CanAction()
	local data = GobangModel.data
	if not data then return false end

	if self:IsSettlement() then return false end

	local current = data.cur_p or -1
	return current == data.seat_num
end

function GobangGamePanel:RefreshChessLine()
	local xq_action = self:GetLastAction(GobangModel.Status.xq)
	if not xq_action then return false end

	local chess = gobang_algorithm.parse_pos(xq_action.pos)
	local ret, chess_lines = GobangModel.CheckWin(chess.x, chess.y)
	if not ret then return false end

	self:ShowChessLine(chess_lines)
	ExtendSoundManager.PlaySound(audio_config.wzq.bgm_wuziqi_lianzhu.audio_name)
	return ret, chess_lines
end

function GobangGamePanel:IsSettlement()
	local data = GobangModel.data
	if not data then return false end

	if data.status == GobangModel.Status.settlement or data.status == GobangModel.Status.gameover then
		return true
	else
		return false
	end
end

function GobangGamePanel:RefreshClearing()
	if self:IsSettlement() then
		GobangClearingPanel.Create()
	else
		GobangClearingPanel.Close()
	end
end

function GobangGamePanel:fg_all_info()
	self:Refresh()
end

function GobangGamePanel:fg_enter_room_msg()
	self:Refresh()
end

-- 玩家进入
function GobangGamePanel:fg_join_msg(seat_num)
	self:RefreshPlayerBaseInfo(seat_num)
end

-- 玩家离开
function GobangGamePanel:fg_leave_msg(seat_num)
	self:RefreshPlayerBaseInfo(seat_num)
end

function GobangGamePanel:fg_score_change_msg()
	self:RefreshPlayerBaseInfo(GobangModel.data.seat_num)
end

function GobangGamePanel:model_fg_ready_msg(seat_num)
	local transform = self.transform
	if not IsEquals(transform) then return end

	self:RefreshPlayerBaseInfo(seat_num)

	for idx = 1, 2 do
		local player = self.players[idx]
		if player then
			player.match_time.text = "00 : 00"
			player.step_time.text = "00 : 00"
			player.chess_img.gameObject:SetActive(false)
		end
	end
end

function GobangGamePanel:model_fg_huanzhuo_response()
	self:Refresh()
end

function GobangGamePanel:model_fg_ready_response()
	self:Refresh()
end

function GobangGamePanel:nor_gobang_nor_begin_msg()
	self:RefreshPlayerTimes()
end

function GobangGamePanel:nor_gobang_nor_action_msg(action)
	local transform = self.transform
	if not IsEquals(transform) then return end

	self:RefreshPlayerTimes()
	self.place_btn.gameObject:SetActive(false)
	self:SetLineVisible(false)
end

function GobangGamePanel:nor_gobang_nor_permit_msg(data)
	local transform = self.transform
	if not IsEquals(transform) then return end

	self:RefreshPlayerTimes()
	self.place_btn.gameObject:SetActive(false)
	self:SetLineVisible(false)
end

function GobangGamePanel:nor_gobang_nor_new_game_msg()
	--[[self:MyRefresh()

	self:ShowOrHideWarningView(false)
	self.cardsRemainUI[2].gameObject:SetActive(false)
	self.cardsRemainUI[3].gameObject:SetActive(false)
	--新的局数
	if DdzFreeModel.data then
		local curRace = DdzFreeModel.data.race
		if curRace then
			DDZAnimation.CurRace(curRace, self.start_again_cards_pos)
		end
	end]]--
end

function GobangGamePanel:nor_gobang_nor_start_again_msg()
	--self:MyRefresh()
	--DDZAnimation.StartAgainCard(self.start_again_cards_pos)
end

-- 分数改变动画
function GobangGamePanel:model_nor_gobang_nor_score_change_msg(data)
	for seatno = 1, 2 do
		self:RefreshPlayerBaseInfo(seatno)
	end	
end

function GobangGamePanel:nor_gobang_nor_settlement_msg()
	local transform = self.transform
	if not IsEquals(transform) then return end

	self.place_btn.gameObject:SetActive(false)
	self:SetLineVisible(false)

	local ret, chess_lines = self:RefreshChessLine()
	if ret then
		for _, line in pairs(chess_lines) do
			for _, v in pairs(line) do
				local chess = self.chess_set[v[1] * VOFFSET + v[2]]
				self:PlayAnimation(chess.transform:Find("Body/circle_img"), "twinkle")
			end
		end
	end

	self:RefreshPlayerTimes()
	self:RefreshGameing()

	for seatno = 1, 2 do
		self:RefreshPlayerBaseInfo(seatno)
	end

	local data = GobangModel.data
	if not data then return end

	local settlement_info = data.settlement_info
	if not settlement_info then return end

	local function callback()
		self:RefreshClearing()
	end

	if settlement_info.win_seat and settlement_info.win_seat == 0 then
		ParticleManager.PlayNormal("WZQ_PingJu", audio_config.wzq.bgm_wuziqi_pingju.audio_name, 2, callback)
	else
		if settlement_info.type == "renshu" then
			--todo
		elseif settlement_info.type == "timeout_ju" then
			local particle = ParticleManager.PlayNormal("WZQ_jiesuan_Animation", audio_config.wzq.bgm_wuziqi_dingju.audio_name, 2, callback)
			if particle then
				local TBL = {
					"wzq_dj_imgf_18", "wzq_dj_imgf_19", "wzq_dj_imgf_20", "wzq_dj_imgf_19"
				}
				for idx = 1, 4 do
					local img = particle.transform:Find("Body/" .. idx):GetComponent("Image")
					img.sprite = GetTexture(TBL[idx])
				end
			end
		elseif settlement_info.type == "timeout_bu" then
			local particle = ParticleManager.PlayNormal("WZQ_jiesuan_Animation", audio_config.wzq.bgm_wuziqi_dingju.audio_name, 2, callback)
			if particle then
				local TBL = {
					"wzq_dj_imgf_17", "wzq_dj_imgf_19", "wzq_dj_imgf_20", "wzq_dj_imgf_19"
				}
				for idx = 1, 4 do
					local img = particle.transform:Find("Body/" .. idx):GetComponent("Image")
					img.sprite = GetTexture(TBL[idx])
				end
			end
		else
			local show_chess_callback = {
				{
					stamp = 2,
					mathod = function()
						--delay
					end
				}
			}
			self:TweenDelay(show_chess_callback, function()
				local particle = ParticleManager.PlayNormal("WZQ_jiesuan_Animation", audio_config.wzq.bgm_wuziqi_dingju.audio_name, 2, callback)
				if particle then
					local img = particle.transform:Find("Body/1"):GetComponent("Image")
					img.sprite = GetTexture("wzq_dj_imgf_1")
				end
			end)
		end
	end
end

function GobangGamePanel:nor_gobang_nor_xhz_msg()
	local function callback()
		local transform = self.transform
		if not IsEquals(transform) then return end
		for seatno = 1, 2 do
			self:RefreshPlayerBaseInfo(seatno)
			self:RefreshPlayerChess(seatno)
		end
	end
	--playparticle
	ParticleManager.PlayNormal("WZQ_kaishi", audio_config.wzq.bgm_wuziqi_kaiju.audio_name, 2, callback)
end

function GobangGamePanel:handle_wzq_place_chess(data)
	local chess_set_node = self.chess_set_node
	if not IsEquals(chess_set_node) then return end

	local x = data.x
	local y = data.y
	local c = data.c
	local chess = self:CreateChess(x, y, c)
	--self:PlayAnimation(chess, "twinkle")
	ExtendSoundManager.PlaySound(audio_config.wzq.bgm_wuziqi_xiaqi.audio_name)

	self.last_mark.transform.localPosition = chess.transform.localPosition
	self.last_mark.gameObject:SetActive(true)
end

function GobangGamePanel:model_fg_signup_fail_response()
	if self.wait_start_ui and not self.wait_start_ui.gameObject.activeSelf then
		self.wait_start_ui.gameObject:SetActive(true)
		GobangModel.ChangeWaitStart(true)
	end
end
