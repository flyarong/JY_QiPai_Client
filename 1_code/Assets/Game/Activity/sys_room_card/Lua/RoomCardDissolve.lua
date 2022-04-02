-- 创建时间:2018-08-08

local basefunc = require "Game.Common.basefunc"

RoomCardDissolve = basefunc.class()

RoomCardDissolve.name = "RoomCardDissolve"

local dotweenLayerKey = "RoomCardDissolve"
local instance

--自己关心的事件
local lister

-- parm={time剩余时间 maxnum 参与投票总人数 data 已投票的结果={{id,val},{id,val},...}}
function RoomCardDissolve.Create(cur_race, room_rent, begin_player_id, parm)
	instance = RoomCardDissolve.New(cur_race, room_rent, begin_player_id, parm)
	return instance
end

--构建斗地主正常逻辑的消息事件（断线重连部分不在这里绑定）
function RoomCardDissolve:MakeLister()
    lister = {}
    --response
	lister["model_friendgame_player_vote_cancel_room_msg"] = basefunc.handler(self, self.model_friendgame_player_vote_cancel_room_msg)
end

function RoomCardDissolve:AddMsgListener(lister)
    for proto_name,func in pairs(lister) do
        Event.AddListener(proto_name, func)
    end
end

function RoomCardDissolve:RemoveMsgListener(lister)
    for proto_name,func in pairs(lister) do
        Event.RemoveListener(proto_name, func)
    end
end

function RoomCardDissolve.MyExit()
	if instance then
		instance:CloseUI()
		instance = nil
	end
end
function RoomCardDissolve:CloseUI()
	DOTweenManager.KillLayerKeyTween(dotweenLayerKey)
	self:RemoveMsgListener(lister)
	instance:CloseUpdate()
	GameObject.Destroy(self.gameObject)
end

function RoomCardDissolve:ctor(cur_race, room_rent, begin_player_id, parm)
	self:MakeLister()
	self:AddMsgListener(lister)

	local parent = GameObject.Find("Canvas/LayerLv4").transform
	local obj = newObject(RoomCardDissolve.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.parm = parm
	self.begin_player_id = begin_player_id
	self.cur_race = cur_race
	self.room_rent = room_rent

	self.hintText = tran:Find("CenterRect/HintText"):GetComponent("Text")
	self.TimeImage1 = tran:Find("CenterRect/TimeImage1"):GetComponent("Image")
	self.TimeImage2 = tran:Find("CenterRect/TimeImage2"):GetComponent("Image")
	self.TimeOneRect1 = tran:Find("CenterRect/TimeImage1/Rect1")
	self.TimeOneRect2 = tran:Find("CenterRect/TimeImage1/Rect2")
	self.TimeOneText1 = tran:Find("CenterRect/TimeImage1/Rect1/Text"):GetComponent("Text")
	self.TimeOneText2 = tran:Find("CenterRect/TimeImage1/Rect2/Text"):GetComponent("Text")

	self.TimeTwoRect1 = tran:Find("CenterRect/TimeImage2/Rect1")
	self.TimeTwoRect2 = tran:Find("CenterRect/TimeImage2/Rect2")
	self.TimeTwoText1 = tran:Find("CenterRect/TimeImage2/Rect1/Text"):GetComponent("Text")
	self.TimeTwoText2 = tran:Find("CenterRect/TimeImage2/Rect2/Text"):GetComponent("Text")

	self.RejectButton = tran:Find("CenterRect/RejectButton")
	self.AgreeButton = tran:Find("CenterRect/AgreeButton")
	EventTriggerListener.Get(self.RejectButton.gameObject).onClick = basefunc.handler(self, self.OnRejectClick)
	EventTriggerListener.Get(self.AgreeButton.gameObject).onClick = basefunc.handler(self, self.OnAgreeClick)

	self.StateRect = tran:Find("CenterRect/StateRect")
	self.CellState = tran:Find("CenterRect/CellState")
	self.StateList = {}
	for i = 1, self.parm.maxnum do
		local obj = GameObject.Instantiate(self.CellState, self.StateRect)
		obj.gameObject:SetActive(true)
		self.StateList[#self.StateList + 1] = obj
	end
	-- 投票进程
	self.currIndex = 0
	self:InitUI()
	self:SetHintUI()
end

function  RoomCardDissolve:SetHintUI()
	if self.cur_race and self.room_rent then
		if self.cur_race > 1  then
			self.hintText.text = "提示：解散房间所有玩家将均摊" .. self.room_rent .. "房费"
		else
			self.hintText.text = "提示：没有打完一局，本次解散房间不会产生房费"
		end
	else
		self.hintText.text = "提示：数据异常"
	end
end

function RoomCardDissolve:InitUI()
	if self.parm.data then
		for i=1, #self.parm.data do
			self:SetStateUI(self.parm.data[i])
		end
	end
	if self.parm.time and self.parm.time > 0 then
		self.dissolveTime = Timer.New(basefunc.handler(self, self.Update), 1, -1, false)
		self.dissolveTime:Start()
		self:UpdateTime()
	end

	local user_id = MainModel.UserInfo.user_id
	self.RejectButton.gameObject:SetActive(user_id ~= self.begin_player_id)
	self.AgreeButton.gameObject:SetActive(user_id ~= self.begin_player_id) 
end
function RoomCardDissolve:CloseUpdate()
	if self.dissolveTime then
		self.dissolveTime:Stop()
		self.dissolveTime = nil
	end
end
function RoomCardDissolve:Update()
	local t1 = math.floor(self.parm.time / 10)
    local t2 = self.parm.time % 10
	self.parm.time = self.parm.time - 1
	local t3 = math.floor(self.parm.time / 10)
    local t4 = self.parm.time % 10

    local pp = 1/30
    if t1 ~= t3 then
		local seq = DG.Tweening.DOTween.Sequence()
		local tweenKey = DOTweenManager.AddTweenToLayer(seq, dotweenLayerKey)
		seq:AppendCallback(function ()
			self.TimeImage1.sprite = GetTexture("rc_game_icon_time4")
		end)
		seq:AppendInterval(pp)
		seq:AppendCallback(function ()
			self.TimeImage1.sprite = GetTexture("rc_game_icon_time3")
		end)
		seq:AppendInterval(pp)
		seq:AppendCallback(function ()
			self.TimeImage1.sprite = GetTexture("rc_game_icon_time2")
		end)
		seq:AppendInterval(pp)
		seq:AppendCallback(function ()
			self.TimeImage1.sprite = GetTexture("rc_game_icon_time1")
		end)
		seq:OnKill(function ()
			DOTweenManager.RemoveLayerTween(tweenKey)
			if IsEquals(self.TimeImage1) then
				self.TimeImage1.sprite = GetTexture("rc_game_icon_time1")
			end
		end)
    end

    if t2 ~= t4 then
		local seq = DG.Tweening.DOTween.Sequence()
		local tweenKey = DOTweenManager.AddTweenToLayer(seq, dotweenLayerKey)
		seq:AppendCallback(function ()
			self.TimeImage2.sprite = GetTexture("rc_game_icon_time4")
		end)
		seq:AppendInterval(pp)
		seq:AppendCallback(function ()
			self.TimeImage2.sprite = GetTexture("rc_game_icon_time3")
		end)
		seq:AppendInterval(pp)
		seq:AppendCallback(function ()
			self.TimeImage2.sprite = GetTexture("rc_game_icon_time2")
		end)
		seq:AppendInterval(pp)
		seq:OnKill(function ()
			DOTweenManager.RemoveLayerTween(tweenKey)
			if IsEquals(self.TimeImage2) then
				self.TimeImage2.sprite = GetTexture("rc_game_icon_time1")
			end
		end)
    end

	local sequp = DG.Tweening.DOTween.Sequence()
	local tweenKey1 = DOTweenManager.AddTweenToLayer(sequp, dotweenLayerKey)
	sequp:AppendInterval(2*pp)
	sequp:OnKill(function ()
		self:UpdateTime()
		DOTweenManager.RemoveLayerTween(tweenKey1)
	end)

    if self.parm.time <= 0 then
    	self:CloseUpdate()
	end
end

function RoomCardDissolve:UpdateTime()
    local t1 = math.floor(self.parm.time / 10)
    local t2 = self.parm.time % 10
    self.TimeOneText1.text = t1
    self.TimeOneText2.text = t1
    self.TimeTwoText1.text = t2
    self.TimeTwoText2.text = t2
end
function RoomCardDissolve:SetStateUI(data)
	if self.currIndex >= self.parm.maxnum then
		print("<color=red>投票人数超过最大参与人数</color>")
		return
	end
	local img
	if data.val == 0 then
		img = "rc_game_icon_dissent"
	else
		img = "rc_game_icon_consent"
	end
	if not self.parm.data then
		self.parm.data = {}
	end
	self.currIndex = self.currIndex + 1
	self.parm.data[#self.parm.data + 1] = data
	self.StateList[self.currIndex].transform:GetComponent("Image").sprite = GetTexture(img)
end

-- 拒绝
function RoomCardDissolve:OnRejectClick()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	if Network.SendRequest("player_vote_cancel_room",{opt = 0},"投票") then
		self.AgreeButton.gameObject:SetActive(false)
		self.RejectButton.gameObject:SetActive(false)
	else
		MJAnimation.Hint(2,Vector3.New(0,-350,0),Vector3.New(0,0,0))
	end
end
-- 同意
function RoomCardDissolve:OnAgreeClick()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	if Network.SendRequest("player_vote_cancel_room",{opt = 1},"投票") then
		self.AgreeButton.gameObject:SetActive(false)
		self.RejectButton.gameObject:SetActive(false)
	else
		MJAnimation.Hint(2,Vector3.New(0,-350,0),Vector3.New(0,0,0))
	end
end

-- 投票玩家投票
function RoomCardDissolve:model_friendgame_player_vote_cancel_room_msg(data)
	self:RefreshVoteStatus(data)
end

function RoomCardDissolve:RefreshVoteStatus(data)
	if data then
		local p_id = data.id
		local p_opt = data.opt
		if p_id and p_opt then
			self:SetStateUI({id = p_id, val = p_opt})
			local user_id = MainModel.UserInfo.user_id
			self.RejectButton.gameObject:SetActive(true)
			self.AgreeButton.gameObject:SetActive(true)
			for k,v in ipairs(self.parm.data) do
				if tostring(user_id) == tostring(v.id) then
					self.RejectButton.gameObject:SetActive(false)
					self.AgreeButton.gameObject:SetActive(false)
					break
				end
			end
		end
	end
end

--[[
	GetTexture("rc_game_icon_consent")
	GetTexture("rc_game_icon_dissent")
]]