-- 创建时间:2019-10-23
-- Panel:SYSXY_JYFLEnterPrefab
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

SYSXY_JYFLEnterPrefab = basefunc.class()
local C = SYSXY_JYFLEnterPrefab

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
	self.title_img.sprite = GetTexture("hall_btn_gift35")

	self:MyRefresh()
end

function C:MyRefresh()
	self.title_txt.text = "许愿池"
	self.info_txt.text = "最高可免费领取100万鲸币"
	if SYSXYManager.m_data then
		if SYSXYManager.m_data.is_vow == 0 then
		    self.get_txt.text = "许  愿"
		    self.get_img.sprite = GetTexture("com_btn_5")
		else
			if SYSXYManager.GetHintState() == ACTIVITY_HINT_STATUS_ENUM.AT_Get then
			    self.get_txt.text = "免费领取"
			    self.get_img.sprite = GetTexture("com_btn_5")
			else
			    self.get_txt.text = "免费领取"
			    self.get_img.sprite = GetTexture("com_btn_8")
			end
		end
	end
end

function C:OnEnterClick()
	GameManager.GotoUI({gotoui=SYSXYManager.key, goto_scene_parm="panel"})
end
function C:OnGetClick()
	GameManager.GotoUI({gotoui=SYSXYManager.key, goto_scene_parm="panel"})	
end

function C:OnDestroy()
	self:MyExit()
end

function C:on_global_hint_state_change_msg(parm)
	if parm.gotoui == SYSXYManager.key then
		self:MyRefresh()
	end
end