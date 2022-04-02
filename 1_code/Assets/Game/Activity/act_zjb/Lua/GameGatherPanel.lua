-- 创建时间:2018-08-13
local basefunc = require "Game.Common.basefunc"
local UIConfig = require "Game.game_Hall.Lua.game_gather_config"

GameGatherPanel = basefunc.class()

GameGatherPanel.name = "GameGatherPanel"

local instance
function GameGatherPanel.Create()
	instance=GameGatherPanel.New()
	return instance
end
function GameGatherPanel:ctor()

	ExtPanel.ExtMsg(self)

	local parent = GameObject.Find("Canvas/LayerLv4").transform
	local obj = newObject(GameGatherPanel.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj

	self.GoldText = tran:Find("GoldNode/GoldText"):GetComponent("Text")
	self.BackButton = tran:Find("BackButton")
	self.cell = tran:Find("Cell")
	self.Content = tran:Find("ScrollView/Viewport/Content")
	EventTriggerListener.Get(self.BackButton.gameObject).onClick = basefunc.handler(self, self.OnBackClick)

	self.listData = UIConfig.config
	self.listData = MathExtend.SortList(self.listData, "order", true)
	self:InitRect()
	DOTweenManager.OpenPopupUIAnim(self.transform)
end
function GameGatherPanel:InitRect()
	self.GoldText.text = StringHelper.ToCash(MainModel.UserInfo.jing_bi)
	for k,v in ipairs(self.listData) do
		self:CreateItem(k)
	end
end
function GameGatherPanel:CreateItem(id)
	local config = self.listData[id]
	local obj = GameObject.Instantiate(self.cell, self.Content)
	obj.gameObject:SetActive(true)
	obj:Find("IconNode/IconImage"):GetComponent("Image").sprite = GetTexture(config.icon)
	obj:Find("TitleText"):GetComponent("Text").text = config.title
	obj:Find("DescText"):GetComponent("Text").text = config.desc
	local GoButton = obj:Find("GoButton")
	GoButton.name = "" .. id
	EventTriggerListener.Get(GoButton.gameObject).onClick = basefunc.handler(self, self.OnGOClick)

	return obj
end

function GameGatherPanel:MyExit()
	destroy(self.gameObject)
end

function GameGatherPanel:CloseUI()
	self:MyExit()
end

function GameGatherPanel:OnGOClick(obj)
	ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
	local id = tonumber(obj.transform.name)
	if id == 1 then
		GameManager.GotoUI({gotoui = "share_hall"})
	elseif id == 2 then
		local parm = {
            gotoui = GameConfigToSceneCfg.game_DdzMatch.SceneName,
        }
        GameManager.GotoUI(parm)
	else
		print("<color=red>配置未找到 Id = ".. id .. "</color>")
	end
	self:CloseUI()
end

function GameGatherPanel:OnBackClick()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
	self:CloseUI()
end
