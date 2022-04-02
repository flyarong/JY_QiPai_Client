-- 创建时间:2019-04-16

HintYBPrefab = {}
local basefunc = require "Game.Common.basefunc"

HintYBPrefab = basefunc.class()

local C = HintYBPrefab

C.name = "HintYBPrefab"

function C.Create(panelSelf)
	return C.New(panelSelf)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.yb_seq then
        self.yb_seq:Kill()
    end
    CachePrefabManager.Back(self.prefab)
    self:RemoveListener()
end

function C:ctor(panelSelf)
	self.panelSelf = panelSelf

	local parent = GameObject.Find("Canvas/LayerLv3").transform
    self.prefab = CachePrefabManager.Take("HintYBPrefab")
    self.prefab.prefab:SetParent(parent)
    local tran = self.prefab.prefab.prefabObj.transform
    self.transform = tran
    self.gameObject = tran.gameObject

    self:MakeLister()
    self:AddMsgListener()

    self.DBButton = tran:Find("DBButton"):GetComponent("Button")
    self.CenterRect = tran:Find("CenterRect")
    self.MoneyText = tran:Find("CenterRect/BG/MoneyText"):GetComponent("Text")
    self.DBButton.gameObject:SetActive(true)

	self.DBButton.onClick:AddListener(function ()
        self:OnDBClick()
    end)

    self.userdata = FishingModel.GetPlayerData()
    self.MoneyText.text = StringHelper.ToCash(self.userdata.base.fish_coin)
end

function C:OnDBClick()
	print("<color=red>OnDBClick</color>")
    self.DBButton.gameObject:SetActive(false)
    local uipos = FishingModel.GetSeatnoToPos(self.userdata.base.seat_num)
    local pos = self.panelSelf.PlayerClass[uipos]:GetMBPos()

    if self.yb_seq then
        self.yb_seq:Kill()
    end
    self.yb_seq = DoTweenSequence.Create()
    self.yb_seq:Append(self.CenterRect.transform:DOMove(pos, 0.5))
    self.yb_seq:Join(self.CenterRect.transform:DOScale(Vector3.New(0.3, 0.3, 0.3), 0.5))
    self.yb_seq:OnKill(function ()
        self.pc_seq = nil
        self:MyExit()
    end)
end

