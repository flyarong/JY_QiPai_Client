-- 创建时间:2018-12-20

local basefunc = require "Game.Common.basefunc"

GameMoneyCenterWYHBPanel = basefunc.class()

local C = GameMoneyCenterWYHBPanel

C.name = "GameMoneyCenterWYHBPanel"

function C.Create(parent)
	return C.New(parent)
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

function C:MyClose()
	self:ClearCellList()
	self:MyExit()
end

function C:MyExit()
	destroy(self.gameObject)
	self:RemoveListener()
end

function C:ctor(parent)

	ExtPanel.ExtMsg(self)

	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj

	self:MakeLister()
	self:AddMsgListener()
    LuaHelper.GeneratingVar(self.transform, self)

    self.DH_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        self:OnDHClick()
    end)

    self:InitUI()
end

function C:InitUI()
    self.redpacket_txt.text = StringHelper.ToRedNum(MainModel.GetHBValue())
    self:UpdateUI()
end

function C:UpdateUI()
	self:ClearCellList()
	self.data = GameMoneyCenterModel.GetWyhbData()
	for k,v in ipairs(self.data) do
		local pre = MoneyCenterWYHBPrefab.Create(self.Content.transform, v)
		self.CellList[#self.CellList + 1] = pre
	end
end

function C:ClearCellList()
	if self.CellList then
		for k,v in ipairs(self.CellList) do
			v:OnDestroy()
		end
	end
	self.CellList = {}
end

function C:MyRefresh()
	self:UpdateUI()
end

function C:OnDHClick()
	MainModel.OpenDH()
end
