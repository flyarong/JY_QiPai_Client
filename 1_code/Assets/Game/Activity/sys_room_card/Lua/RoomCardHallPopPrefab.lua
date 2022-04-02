-- 创建时间:2018-07-14

local basefunc = require "Game.Common.basefunc"

RoomCardHallPopPrefab = basefunc.class()

RoomCardHallPopPrefab.name = "RoomCardHallPopPrefab"


local instance = nil

function RoomCardHallPopPrefab.Show()
	return RoomCardHallPopPrefab.Create()
end

function RoomCardHallPopPrefab.Close()
	if instance then
		instance:OnBackClick()
	end
end

function RoomCardHallPopPrefab.Create()
	instance = RoomCardHallPopPrefab.New()
	return instance
end
function RoomCardHallPopPrefab:ctor()
	local parent = GameObject.Find("Canvas/LayerLv3").transform

	local obj = newObject(RoomCardHallPopPrefab.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)

	self.back_btn.onClick:AddListener(function (val)
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnBackClick()
	end)

	self.AssetChange = function ()
		self:RefreshAssets()
	end
	self.ExitScene = function ()
		RoomCardHallPopPrefab.Close()
	end
    Event.AddListener("ExitScene",self.ExitScene)
    Event.AddListener("AssetChange",self.AssetChange)
	self:RefreshAssets()

	self.room_card_btn.onClick:AddListener(function (val)
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnRoomCardGold()
	end)

	self.pos_btn.onClick:AddListener(function (val)
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnChangePos()
	end)
	self.pos_btn.gameObject:SetActive(false)

	self.create_room_btn.onClick:AddListener(function (val)
		self:CreateRoom()
	end)

	self.join_room_btn.onClick:AddListener(function (val)
		self:JoinRoom()
	end)

	self.bill_btn.onClick:AddListener(function (val)
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:ViewBill()
	end)

	self:OpenUIAnim()
end
-- 界面打开的动画
function RoomCardHallPopPrefab:OpenUIAnim()
	local tt = 0.25

	self.RectTop.transform.localPosition = Vector3.New(0, 118, 0)
	self.create_room_btn.transform.localPosition = Vector3.New(-1296, 0, 0)
	self.join_room_btn.transform.localPosition = Vector3.New(1306, 0, 0)

	local seq = DG.Tweening.DOTween.Sequence()
	local tweenKey = DOTweenManager.AddTweenToStop(seq)
	seq:Join(self.RectTop.transform:DOLocalMoveY(-86, tt))
	seq:Join(self.create_room_btn.transform:DOLocalMoveX(-296, tt))
	seq:Join(self.join_room_btn.transform:DOLocalMoveX(306, tt))
	seq:OnComplete(function ()
	end)
	seq:OnKill(function ()
		DOTweenManager.RemoveStopTween(tweenKey)
		self:OpenUIAnimFinish()
	end)
end
function RoomCardHallPopPrefab:OpenUIAnimFinish()
	self.RectTop.transform.localPosition = Vector3.New(0, -86, 0)
	self.create_room_btn.transform.localPosition = Vector3.New(-296, 0, 0)
	self.join_room_btn.transform.localPosition = Vector3.New(306, 0, 0)
end

function RoomCardHallPopPrefab:OnRoomCardGold()
	PayPanel.Create(GOODS_TYPE.item, "normal")
end

function RoomCardHallPopPrefab:OnChangePos()
	if GameGlobalOnOff.ChangeCity then
		HintPanel.Create(1,"敬请期待")
	else
		HintPanel.Create(1,"目前只支持成都地区")
	end
end

function RoomCardHallPopPrefab:OnBackClick()
	GameObject.Destroy(self.gameObject)
	Event.RemoveListener("AssetChange",self.AssetChange)
	instance = nil
end

--[[创建房间]]
function RoomCardHallPopPrefab:CreateRoom()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
	RoomCardCreate.Create(self.transform)
end

--[[加入房间]]
function RoomCardHallPopPrefab:JoinRoom()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)

	RoomCardJoin.Create(RoomCardJoin.FunType.FT_RoomCard)
end

--[[查看账单]]
function RoomCardHallPopPrefab:ViewBill()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
	RoomCardBillPanel.Show()
end

function RoomCardHallPopPrefab:RefreshAssets()
	if MainModel.UserInfo.room_card then
		self.room_card_txt.text =  StringHelper.ToCash(MainModel.UserInfo.room_card)
	else
		self.room_card_txt.text = "0"
	end
end