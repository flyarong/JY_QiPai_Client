-- 创建时间:2018-08-15

local basefunc = require "Game.Common.basefunc"

GameVoicePanel = basefunc.class()

-- 语音最大秒数
local VoiceMaxSecond = 5
local duration = 0.0333

local VoiceStatus = 
{
	Record_Nil="Record_Nil",-- 空闲
	Record_Ing="Record_Ing",-- 录音中
	Record_Cancel="Record_Cancel",-- 录音取消
}

local status = VoiceStatus.Record_Nil

function GameVoicePanel.GetVoicePermission()
	local permission = sdkMgr:GetCanVoice()
	if permission == 2 then
		local PREF_KEY = "VoicePermission"
		local PlayerPrefs = UnityEngine.PlayerPrefs
		if not PlayerPrefs.HasKey(PREF_KEY) then
			PlayerPrefs.SetInt(PREF_KEY, 1)
			permission = 1
		end
	end
	return permission
end

-- 录制声音
function GameVoicePanel.RecordVoice()
	local permission = GameVoicePanel.GetVoicePermission()
	print("[SetupVoice] permission: " .. permission)
	if permission ~= 0 then
		if permission == 1 then
			sdkMgr:OpenVoice()
		else
			sdkMgr:GotoSetScene("Voice")
		end
		return
	end

	if status == VoiceStatus.Record_Nil or status == VoiceStatus.Record_Cancel then
		print("<color=red>XXXXXXXXX 录制声音</color>")
		status = VoiceStatus.Record_Ing
		GameVoicePanel.instance:CreateVoice()
	end
end
function GameVoicePanel.FinishVoice()
	if status == VoiceStatus.Record_Ing then
		sdkMgr:StopRecord(true)
	end
end
-- 发送声音
function GameVoicePanel.SendVoice()
	if status == VoiceStatus.Record_Ing then
		if GameVoicePanel.instance then
			print("<color=red>XXXXXXXXX 发送声音</color>")
			status = VoiceStatus.Record_Nil
			GameVoicePanel.instance:onSendVoice()
		end
	end
end
-- 取消声音
function GameVoicePanel.CancelVoice()
	if status == VoiceStatus.Record_Ing then
		if GameVoicePanel.instance then
			print("<color=red>XXXXXXXXX 取消声音</color>")
			status = VoiceStatus.Record_Cancel
			sdkMgr:StopRecord(false)
			GameVoicePanel.instance:onCancelVoice()
		end
	end
end


GameVoicePanel.instance = nil
function GameVoicePanel.Create()
	if not GameVoicePanel.instance then
		GameVoicePanel.instance = GameVoicePanel.New()
	end
	return GameVoicePanel.instance
end
function GameVoicePanel.Exit()
	if GameVoicePanel.instance then
		GameVoicePanel.instance:ExitUI()
	end
	GameVoicePanel.instance = nil
end

function GameVoicePanel:ctor()

	ExtPanel.ExtMsg(self)

	local parent = GameObject.Find("Canvas/LayerLv4").transform
    self.gameObject = newObject("GameVoicePanel", parent)
    self.transform = self.gameObject.transform
    local tran = self.transform

    self.voicePath = AppDefine.LOCAL_DATA_PATH .. "/" .. "player_voice.amr"

    self.VoiceNode = tran:Find("VoiceNode")
    self.cell = GetPrefab("VoicePrefab")
    self.ChatRect = tran:Find("ChatRect")
    self.HintRect = tran:Find("HintRect"):GetComponent("CanvasGroup")
    self.TimeText = tran:Find("ChatRect/TimeText"):GetComponent("Text")
	self.ChatRect.gameObject:SetActive(false)
	self.HintRect.gameObject:SetActive(false)
end
function GameVoicePanel:CreateVoice()
	self:StopUI()
	self.ChatRect.gameObject:SetActive(true)
	self.HintRect.gameObject:SetActive(false)
	
	self.voiceSize = 0
	self.UpdateTime = Timer.New(basefunc.handler(self, self.Update), duration, -1)
	self.UpdateTime:Start()
	self.TimeText.text = "(" .. VoiceMaxSecond .. "s)"

	local result = sdkMgr:StartRecord(self.voicePath, function(n)
		if n == "" then
			status = VoiceStatus.Record_Nil
			self:ShortHint()
		else
			GameVoicePanel.SendVoice()
		end
	end)
	if result == -1 then
		LittleTips.Create("没有录音设备")
		status = VoiceStatus.Record_Nil
		self:onCancelVoice()
	end

end
function GameVoicePanel:Update()
	self.voiceSize = self.voiceSize + duration
	if self.voiceSize > VoiceMaxSecond then
		GameVoicePanel.SendVoice()
	else
		local tt = math.floor(VoiceMaxSecond - self.voiceSize + 1)
		self.TimeText.text = "(" .. tt .. "s)"
	end
end
function GameVoicePanel:StopUI()
	if self.shortSeq then
		self.shortSeq:Kill()
		self.shortSeq = nil
	end
	if self.UpdateTime then
		self.UpdateTime:Stop()
	end
end
function GameVoicePanel:onCancelVoice()
	self:StopUI()
	self:Close()
end
function GameVoicePanel:onSendVoice()
	self:StopUI()
	if AppDefine.IsEDITOR() then
		print("<color=red>编辑器下不支持语音聊天</color>")
		self:Close()
		return
	end
	if self.voiceSize < 1 then
		
	else
		local byte = File.ReadAllBytes(self.voicePath)

		local tt = {}
		for i = 0, byte.Length-1 do
			tt[#tt + 1] = string.char(byte[i])
		end
		local ss = table.concat(tt)
		print("<color=red>语音大小 size= " .. string.len(ss)/1024 .. "Kb</color>")
		local data = {}
		data.data = ss
		Network.SendRequest("send_voice_chat", data)
		self:Close()
	end
end
function GameVoicePanel:ShortHint()
	self:StopUI()
	self.ChatRect.gameObject:SetActive(false)
	self.HintRect.gameObject:SetActive(true)
	self.HintRect.alpha = 1
	self.shortSeq = DG.Tweening.DOTween.Sequence()
	local tweenKey = DOTweenManager.AddTweenToStop(self.shortSeq)
	self.shortSeq:AppendInterval(1)
	self.shortSeq:Append(self.HintRect:DOFade(0, 0.5))
	self.shortSeq:OnKill(function ()
		DOTweenManager.RemoveStopTween(tweenKey)
		self.HintRect.gameObject:SetActive(false)
	end)
end

function GameVoicePanel:Close()
	self.ChatRect.gameObject:SetActive(false)
	self.HintRect.gameObject:SetActive(false)
end

function GameVoicePanel:MyExit()
	self:StopUI()
	self.cell = nil
	destroy(self.gameObject)
end

function GameVoicePanel:ExitUI()
	self:MyExit()
end

function GameVoicePanel:ClosePlayVoice()
	if self.VoicePrefab then
		GameObject.Destroy(self.VoicePrefab.gameObject)
		self.VoicePrefab = nil
	end	
	if self.playSeq then
		self.playSeq:Kill()
	end
end
function GameVoicePanel:PlayVoice(data)
	self:ClosePlayVoice()
	if 	GameVoiceLogic.gameModel then
		self:ClosePlayVoice()

		local path = AppDefine.LOCAL_DATA_PATH .. "/" .. "pay_player_voice.amr"
		basefunc.path.write(path, data.data)

		sdkMgr:PlayRecord(path, function ()
			self:ClosePlayVoice()
			GameVoiceModel.PlayFinish()
			print("play record finish")
		end)
		local uiPos = GameVoiceLogic.gameModel.GetIdToVoiceShowPos(data.player_id)
		self.VoicePrefab = GameObject.Instantiate(self.cell, self.VoiceNode)
		self.VoicePrefab.transform.localPosition = uiPos.pos
		self.VoicePrefab.transform.rotation = Quaternion:SetEuler(uiPos.rota.x, uiPos.rota.y, uiPos.rota.z)

		self.playSeq = DG.Tweening.DOTween.Sequence()
		local tweenKey = DOTweenManager.AddTweenToStop(self.playSeq)
		self.playSeq:AppendInterval(VoiceMaxSecond + 0.2)
		self.playSeq:Append(self.HintRect:DOFade(0, 0.5))
		self.playSeq:OnComplete(function ()
			self:ClosePlayVoice()
			GameVoiceModel.PlayFinish()
			print("max time play record finish")
		end)
		self.playSeq:OnKill(function ()
			DOTweenManager.RemoveStopTween(tweenKey)
		end)		
	end
end


