-- 创建时间:2019-09-25
-- Panel:XRHBEnterPrefab
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

XRHBEnterPrefab = basefunc.class()
local C = XRHBEnterPrefab
C.name = "XRHBEnterPrefab"

function C.Create(parent, cfg)
	return C.New(parent, cfg)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["seven_day_task_over"] = basefunc.handler(self, self.handle_seven_day_task_over)
    self.lister["HallModelBBSCTaskRedHint"] = basefunc.handler(self, self.HandleBBSCTaskRedHint)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if IsEquals(self.gameObject) then
		RedHintManager.RemoveRed(RedHintManager.RedHintKey.RHK_BBSC_Task, self.bbsc_red.gameObject)
	end

	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor(parent, cfg)
	self.config = cfg

	local obj = newObject("BBSC_btn", parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()

	self.transform.localPosition = Vector3.zero

	self:InitUI()
end

function C:InitUI()
	print("<color=red>XXXXXXX11111</color>")
	self.enter_btn = self.transform:GetComponent("Button")
	self.enter_btn.onClick:AddListener(function ()
    	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnEnterClick()
	end)
	RedHintManager.AddRed(RedHintManager.RedHintKey.RHK_BBSC_Task, self.bbsc_red.gameObject)
	ActivitySevenDayModel.ChangeTaskCanGetRedHint()
	
	self:MyRefresh()
end

function C:MyRefresh()
end

function C:OnEnterClick()
	Event.Brocast("open_activity_seven_day", true)
end

function C:OnDestroy()
	self:MyExit()
end

function C:handle_seven_day_task_over()
    Event.Brocast("ui_button_state_change_msg")
	print("<color=red>XXXXXXX33333</color>")
    self:OnDestroy()
end
function C:HandleBBSCTaskRedHint(isRed)
	local animator = self.transform:GetComponent("Animator")
	if not animator then return end

	if isRed then
		animator:Play("xrhb", 0, 0)
	else
		animator:Play("idle", 0, 0)
	end
end
