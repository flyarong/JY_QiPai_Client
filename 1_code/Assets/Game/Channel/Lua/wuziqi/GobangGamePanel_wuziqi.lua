local basefunc = require "Game.Common.basefunc"

GobangGamePanel_wuziqi = basefunc.class()
local C = GobangGamePanel_wuziqi
C.name = "GobangGamePanel_wuziqi"

function C.HandleInit(base_self)
	if not base_self then return end
	local _ui
    local ui = base_self.game_title
	if IsEquals(ui) then
		ui.gameObject:SetActive(false)
		_ui = GameObject.Instantiate(ui.gameObject,ui.transform.parent)
		_ui.transform:GetComponent("Text").text = "五子棋"
		_ui.gameObject:SetActive(true)
    end
    ui = base_self.game_score
	if IsEquals(ui) then
		ui.gameObject:SetActive(false)
		_ui = GameObject.Instantiate(ui.gameObject,ui.transform.parent)
		_ui.transform:GetComponent("Text").text = "游戏没有金币输赢"
		_ui.gameObject:SetActive(true)
	end
	ui = base_self.transform:Find("player1/name/gold_icon")
	if IsEquals(ui) then
		ui.gameObject:SetActive(false)
	end
	ui = base_self.transform:Find("player2/name/gold_icon")
	if IsEquals(ui) then
		ui.gameObject:SetActive(false)
	end
	ui = base_self.transform:Find("chat")
	if IsEquals(ui) then
		ui.gameObject:SetActive(false)
		_ui = ui:GetComponent("Image")
		_ui.enabled = false
	end
	ui = base_self.transform:Find("chat/Text")
	if IsEquals(ui) then
		ui.gameObject:SetActive(false)
		_ui = ui:GetComponent("Image")
		_ui.enabled = false
	end
	ui = nil
	_ui = nil

	GobangModel.ChangeWaitStart(true)

	local transform = base_self.transform
	if not IsEquals(transform) then return end
	base_self.wait_start_ui = transform:Find("wait_start")
	base_self.wait_start_ui.gameObject:SetActive(true)
	base_self.wait_start_ui.transform:GetComponent("Button").onClick:AddListener(function ()
		local game_id = 44 --五子棋固定id
		GobangModel.ChangeWaitStart(false)
		Network.SendRequest("fg_signup", {id = game_id}, "正在报名")
		base_self.wait_start_ui.gameObject:SetActive(false)
	end)

	local expand = base_self.transform:Find("menu/expand")
	local close_btn = expand:Find("close_btn"):GetComponent("Button")
	close_btn.onClick:RemoveAllListeners()
	close_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		if GobangModel.isWaitStart then
			MainLogic.ExitGame()
			GobangLogic.change_panel(GobangLogic.panelNameMap.hall)
		else
			Network.SendRequest("fg_quit_game", nil, "返回")
		end
	end)
end

return C.HandleInit