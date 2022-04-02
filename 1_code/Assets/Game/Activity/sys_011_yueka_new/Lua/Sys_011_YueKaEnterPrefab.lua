-- 创建时间:2019-09-25
-- Panel:JYFLEnterPrefab
--[[ *      ┌─┐       ┌─┐
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

Sys_011_YueKaEnterPrefab = basefunc.class()
local C = Sys_011_YueKaEnterPrefab
C.name = "Sys_011_YueKaEnterPrefab"

function C.Create(parent, cfg)
	return C.New(parent, cfg)
end

function C:AddMsgListener()
	for proto_name, func in pairs(self.lister) do
		Event.AddListener(proto_name, func)
	end
end

function C:MakeLister()
	self.lister = {}
	self.lister["YueKa_Got_New_Info"] = basefunc.handler(self, self.RefreshStatus)
end

function C:RemoveListener()
	for proto_name, func in pairs(self.lister) do
		Event.RemoveListener(proto_name, func)
	end
	self.lister = {}
end

function C:MyExit()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor(parent, cfg)
	self.config = cfg
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)

	self:MakeLister()
	self:AddMsgListener()
	--self.transform.localPosition = Vector3.zero
	self:InitUI()
end

function C:InitUI()
	self.enter_btn = self.transform:GetComponent("Button")
	self.enter_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnEnterClick()
	end)

	self:MyRefresh()
end

function C:MyRefresh()
	self:RefreshStatus()
end

function C:OnEnterClick()
	Event.Brocast("global_hint_state_set_msg", {gotoui = Sys_011_YuekaManager.key})
	self:RefreshStatus()
	Sys_011_YueKaPanel.Create(nil,true)
end

function C:OnDestroy()
	self:MyExit()
end

function C:RefreshStatus()
	local parm = {gotoui = Sys_011_YuekaManager.key}
	local st = Sys_011_YuekaManager.GetHintState(parm)
	self.get_img.gameObject:SetActive(false)
	self.red_img.gameObject:SetActive(false)
	if st == ACTIVITY_HINT_STATUS_ENUM.AT_Red then
		self.red_img.gameObject:SetActive(true)
	elseif st == ACTIVITY_HINT_STATUS_ENUM.AT_Get then
		self.get_img.gameObject:SetActive(true)
	end
end