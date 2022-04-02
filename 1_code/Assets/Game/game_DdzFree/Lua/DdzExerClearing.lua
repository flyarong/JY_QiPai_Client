-- 创建时间:2018-06-06

local basefunc = require "Game.Common.basefunc"

DdzExerClearing = basefunc.class()

DdzExerClearing.name = "DdzExerClearing"

local colorTS = "<color=#FFFA60>"
local colorXZ = "<color=#00FF00>"
local colorEnd = "</color>"

local instance
function DdzExerClearing.Create(parent)
    SysInteractivePlayerManager.Close()
    SysInteractiveChatManager.Hide()

	if not instance then
		instance = DdzExerClearing.New(parent)
	end
	return instance
end
-- 关闭
function DdzExerClearing.Close()
	if instance then
		instance:RemoveListener()
		GameObject.Destroy(instance.transform.gameObject)
		instance = nil
	end
end
function DdzExerClearing:MakeLister()
    self.lister = {}

end
function DdzExerClearing:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
end
function DdzExerClearing:ctor(parent)
	parent = parent or GameObject.Find("Canvas/LayerLv3").transform
	self:MakeLister()
	local obj = newObject(DdzExerClearing.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.CellPrefab = tran:Find("CellPrefab")
	self.BackButton = tran:Find("BackButton"):GetComponent("Button")
	self.BackButton.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnBackClick()
	end)
	self.RoomRentText = tran:Find("RoomRentText"):GetComponent("Text")
	self.TopHintText = tran:Find("CenterNode/TopHintText"):GetComponent("Text")
	self.WinNumText = tran:Find("CenterNode/WinNumText"):GetComponent("Text")
	self.GameNumText = tran:Find("CenterNode/GameNumText"):GetComponent("Text")
	self.AwardNode = tran:Find("CenterNode/ScrollView/Viewport/Content")
	self.LoseNode = tran:Find("LoseNode").gameObject
	self.WinNode = tran:Find("WinNode").gameObject
	self.ConfirmButton = tran:Find("ConfirmButton"):GetComponent("Button")
	self.ConfirmImage = tran:Find("ConfirmButton"):GetComponent("Image")
	self.ConfirmText = tran:Find("ConfirmButton/Text"):GetComponent("Text")
	self.ConfirmButton.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnConfirmClick()
	end)
	self.ShareButton = tran:Find("ShareButton"):GetComponent("Button")
	self.ShareButton.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnShareClick()
	end)

	self.GotoMatchButton = tran:Find("GotoMatchButton"):GetComponent("Button")
	self.GotoMatchButton.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		local state = gameMgr:CheckUpdate("game_MatchHall")
		if state == "Install" or state == "Update" then
			HintPanel.Create(1, "请返回大厅更新游戏")
		else
			if Network.SendRequest("dfg_quit_game") then
				MainLogic.ExitGame()
		        MainLogic.GotoScene("game_MatchHall")
		    end
	    end
	end)
	self.AwardCell = {}

	-- 游戏胜利
	self.isWin = DdzFreeModel.IsMyWin()
	self.winNum = DdzFreeModel.data.settlement_info.win_count
	self.gameNum = DdzFreeModel.data.settlement_info.all_win_count
	self.nextAward,self.currAwardIndex = DdzFreeModel.getNextAward(DdzFreeModel.data.settlement_info.win_count)
	self:InitRect()

	DOTweenManager.OpenClearUIAnim(self.transform)
end

function DdzExerClearing:InitRect()
	local asset_count = 0
	if DdzFreeModel.data.settlement_info.room_rent then
		asset_count = DdzFreeModel.data.settlement_info.room_rent.asset_count
	end
	self.RoomRentText.text = "本场房费：" .. asset_count
	for i,v in ipairs(DdzFreeModel.UIConfig.award) do
		self:CreateItem(v, i)
	end

	local panyi = self.currAwardIndex - 2.5
	if panyi < 0 then
		panyi = 0
	end
	self.AwardNode.transform.localPosition = Vector3.New(-1 * panyi * 300, 0, 0)

	-- 下一级奖励剩余局数
	if self.isWin then
		ExtendSoundManager.PlaySound(audio_config.game.sod_game_win.audio_name)
		self.LoseNode:SetActive(false)
		self.WinNode:SetActive(true)
		if self.nextAward > 0 then
			self.TopHintText.text = colorTS .. "您再获得" .. colorXZ .. self.nextAward .. colorEnd .. "局就可以解锁下一级奖励啦！" .. colorEnd
		else
			self.TopHintText.text = ""
		end
	else
		ExtendSoundManager.PlaySound(audio_config.game.sod_game_lose.audio_name)
		self.LoseNode:SetActive(true)
		self.WinNode:SetActive(false)
		if self.nextAward > 0 then
			self.TopHintText.text = colorTS .. "加油您再胜利" .. colorXZ .. self.nextAward .. colorEnd .. "局就可以解锁下一级奖励啦！" .. colorEnd
		else
			self.TopHintText.text = ""
		end
	end

	self.WinNumText.text = "" .. self.winNum
	self.GameNumText.text = "" .. self.gameNum

	self:OnOff()
end

function DdzExerClearing:OnOff ()
	if not GameGlobalOnOff.Diversion then
		self.GotoMatchButton.gameObject:SetActive(false)
	else
		self.GotoMatchButton.gameObject:SetActive(true)
	end
	
	if not GameGlobalOnOff.ShowOff then
		self.ShareButton.gameObject:SetActive(false)
		-- local pos = self.ConfirmButton.transform.localPosition
		-- self.ConfirmButton.transform.localPosition = Vector3.New(0,pos.y,pos.z)
	else
		self.ShareButton.gameObject:SetActive(true)
	end

end

-- 创建Itme
function DdzExerClearing:CreateItem(data, i)
	local obj = GameObject.Instantiate(self.CellPrefab)
	local tran = obj.transform
	tran:SetParent(self.AwardNode)
	self.AwardCell[#self.AwardCell + 1] = obj
	tran.localScale = Vector3.one
	obj.gameObject:SetActive(true)

	local left = tran:Find("LeftImage"):GetComponent("Image")
	local right = tran:Find("RightImage"):GetComponent("Image")
	tran:Find("DBImage/DescText"):GetComponent("Text").text = data.win_count .. "胜"
	tran:Find("DBImage/NumText"):GetComponent("Text").text = "x" .. data.count
	local awardImage = tran:Find("DBImage/TypeImage"):GetComponent("Image")
	local tt = AwardManager.GetAwardImage(data.award)
	GetTextureExtend(awardImage, tt.image, tt.is_local_icon)

	local get = tran:Find("DBImage/GetImage")
	local mark = tran:Find("MarkImage")
	if data.id == 1 then
		left.gameObject:SetActive(false)
		right.gameObject:SetActive(true)
	elseif data.id == #DdzFreeModel.UIConfig.award then
		left.gameObject:SetActive(true)
		right.gameObject:SetActive(false)
	else
		left.gameObject:SetActive(true)
		right.gameObject:SetActive(true)
	end
	if self.winNum >= data.win_count then
		left.sprite = GetTexture("freetable_bg_bar_2")
		right.sprite = GetTexture("freetable_bg_bar_2")
		get.gameObject:SetActive(true)
		mark.gameObject:SetActive(false)
	else
		left.sprite = GetTexture("freetable_bg_bar_1")
		right.sprite = GetTexture("freetable_bg_bar_1")
		get.gameObject:SetActive(false)
		mark.gameObject:SetActive(true)
	end
end

--[[
Botton
--]]
-- 继续游戏
function DdzExerClearing:OnConfirmClick()
	if Network.SendRequest("dfg_replay_game", {id=DdzFreeModel.baseData.game_id}) then
		DdzFreeModel.ClearMatchData(DdzFreeModel.baseData.game_id)
		self.ConfirmButton.enabled = false
    else
        DDZAnimation.Hint(2,Vector3.New(0,-350,0),Vector3.New(0,0,0))
    end
end

-- 分享战绩
function DdzExerClearing:OnShareClick()
end

-- 返回
function DdzExerClearing:OnBackClick()
	if Network.SendRequest("dfg_quit_game") then
		DdzExerClearing.Close()
    else
        DDZAnimation.Hint(2,Vector3.New(0,-350,0),Vector3.New(0,0,0))
    end
end

