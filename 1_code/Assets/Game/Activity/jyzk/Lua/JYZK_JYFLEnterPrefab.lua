-- 创建时间:2019-10-23
-- Panel:JYZK_JYFLEnterPrefab
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

JYZK_JYFLEnterPrefab = basefunc.class()
local C = JYZK_JYFLEnterPrefab

function C.CheckIsShow(cfg)
	if not cfg.is_on_off or cfg.is_on_off == 0 then
		return
	end

	return true
end

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
	self.title_img.sprite = GetTexture("hall_btn_gift11")
	if self.parm.parm == "qys" then
		self.title_txt.text = "千元赛周卡"
		self.info_txt.text = "千元赛当天可领一张千元赛门票"
	else
		self.title_img.sprite = GetTexture("hall_btn_gift13")
		self.title_txt.text = "鲸币周卡"
		self.info_txt.text = "每天可领5万金币"
	end
	self:MyRefresh()
end

function C:MyRefresh()
	local task_data
	local m_data
	if self.parm.parm == "qys" then
		task_data = GameTaskModel.GetTaskDataByID(JYZKManager.QYS_TASK_ID)
		m_data = JYZKManager.m_data.qys_data
	else
		task_data = GameTaskModel.GetTaskDataByID(JYZKManager.JB_TASK_ID)
		m_data = JYZKManager.m_data.jb_data
	end
	dump(task_data, "<color=red>task_data</color>")
	dump(m_data, "<color=red>m_data</color>")

    if not task_data or not m_data or m_data.remain_num <= 0 then
        self.get_txt.text = "去 购 买"
        self.get_img.sprite = GetTexture("com_btn_5")
    else
		local next_get_day = m_data.next_get_day or 0
		local has_award
		if self.parm.parm == "qys" then
			has_award = ActivityShop20Panel.CheckTaskActivity(JYZKManager.QYS_TASK_ID)
		else
			has_award = ActivityShop20Panel.CheckTaskActivity(JYZKManager.JB_TASK_ID)
		end

		if has_award and next_get_day == 0 then
	        self.get_txt.text = "领   取"
	        self.get_img.sprite = GetTexture("com_btn_5")
		else	
	        self.get_txt.text = "领   取"
	        self.get_img.sprite = GetTexture("com_btn_8")
		end
    end
end

function C:OnEnterClick()
	GameManager.GotoUI({gotoui=JYZKManager.key, goto_scene_parm="panel"})
end
function C:OnGetClick()
	GameManager.GotoUI({gotoui=JYZKManager.key, goto_scene_parm="panel"})	
end

function C:OnDestroy()
	self:MyExit()
end

function C:on_global_hint_state_change_msg(parm)
	if parm.gotoui == JYZKManager.key then
		self:MyRefresh()
	end
end