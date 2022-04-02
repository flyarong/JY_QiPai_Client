-- 创建时间:2019-10-23
-- Panel:SYSQD_JYFLEnterPrefab
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

SYSQD_JYFLEnterPrefab = basefunc.class()
local C = SYSQD_JYFLEnterPrefab

function C.Create(parent, parm)
	return C.New(parent, parm)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["global_hint_state_change_msg"] = basefunc.handler(self, self.on_global_hint_state_change_msg)
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

function C:ctor(parent, parm)
	self.parm = parm
	ExtPanel.ExtMsg(self)
	local obj = newObject("JYFLCellPrefab", parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.get_img = self.get_btn.transform:GetComponent("Image")

	self:MakeLister()
	self:AddMsgListener()

	self:InitUI()
end

function C:InitUI()
	self.BG_btn.onClick:AddListener(function ()
    	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnEnterClick()
	end)
	self.get_btn.onClick:AddListener(function ()
    	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnGetClick()
	end)
	self.title_img.sprite = GetTexture("qrqd_icon_1")
	self.title_img:GetComponent("RectTransform").sizeDelta= { x = 148 ,y = 140}
	self:MyRefresh()
end

function C:MyRefresh()
	self.title_txt.text = "签到有礼"
	self.info_txt.text = "每日登录签到可领取奖励"
	if SYSQDManager.GetHintState() == ACTIVITY_HINT_STATUS_ENUM.AT_Get then
		self.gameObject:SetActive(true)
	    self.get_txt.text = "去 签 到"
	    self.get_img.sprite = GetTexture("com_btn_5")
	else
	    --self.gameObject:SetActive(false)
	    self.get_img.sprite = GetTexture("com_btn_8")
		self.get_txt.text = "明日领取"
	end
end

function C:OnEnterClick()
	GameManager.GotoUI({gotoui=SYSQDManager.key, goto_scene_parm="panel"})
end
function C:OnGetClick()
	GameManager.GotoUI({gotoui=SYSQDManager.key, goto_scene_parm="panel"})	
end

function C:OnDestroy()
	self:MyExit()
end

function C:on_global_hint_state_change_msg(parm)
	if parm.gotoui == SYSQDManager.key then
		self:MyRefresh()
	end
end