-- 创建时间:2019-12-13
-- Panel:DuihuanButton
--[[
 *      ┌─┐       ┌─┐
 *   ┌──┘ ┴───────┘ ┴──┐
 *   │                 │
 *   │       ───       │
 *   │  ─┬┘       └┬─  │
 *   │                 │
 *   │       ─┴─       │
 *   │                 │
 *   └───┐         ┌───┘
 *       │         │
 *       │         │
 *       │         │
 *       │         └──────────────┐
 *       │                        │
 *       │                        ├─┐
 *       │                        ┌─┘
 *       │                        │
 *       └─┐  ┐  ┌───────┬──┐  ┌──┘
 *         │ ─┤ ─┤       │ ─┤ ─┤
 *         └──┴──┘       └──┴──┘
 *                神兽保佑
 *               代码无BUG!
 --]]

local basefunc = require "Game/Common/basefunc"

DuihuanButton = basefunc.class()
local C = DuihuanButton
C.name = "DuihuanButton"

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
    self.lister["AssetChange"] = basefunc.handler(self, self.UpdateAssetInfo)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor(parent)
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.transform.localPosition = Vector3.zero

	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	EventTriggerListener.Get(self.gameObject).onClick = basefunc.handler(self, self.OnDHClicked)
	self:MyRefresh()
end

function C:MyRefresh()
	self:UpdateAssetInfo()
end

function C:OnDHClicked()	
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	MainModel.OpenDH()
end

function C:UpdateAssetInfo()
	if IsEquals(self.red_txt) then
		self.red_txt.text = StringHelper.ToRedNum(MainModel.GetHBValue())
	end
end

function C:SetPos(pos)
	self.transform.localPosition = pos
end

