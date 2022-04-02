-- 创建时间:2020-09-25
-- Panel:LWZBCSDJEnterPrefab
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

LWZBCSDJEnterPrefab = basefunc.class()
local C = LWZBCSDJEnterPrefab
C.name = "LWZBCSDJEnterPrefab"
local M = LWZBModel

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
    self.lister["ExitScene"] = basefunc.handler(self,self.MyExit)
    self.lister["lwzb_refresh_qlcf_enter_and_panel_msg"] = basefunc.handler(self,self.on_lwzb_refresh_qlcf_enter_and_panel_msg)
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

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(parent)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.enter_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnEnterClick()
	end)
	
end

function C:QLCFEterRefreshUI(num)
	local str = LWZBManager.PoolFormat(num)
	self.award_txt.text = str
end

function C:OnEnterClick()
	LWZBCSDJPanel.Create(self.cur_num)
end

function C:on_lwzb_refresh_qlcf_enter_and_panel_msg()
	local all_info = M.GetAllInfo()
	local qlcf_award_pool = all_info.status_data.qlcf_award_pool
	if not self.cur_num then
		self.cur_num = math.floor(tonumber(qlcf_award_pool)*0.4)
	end
	self.award_pool = qlcf_award_pool
	self:RunChange()
	--self:QLCFEterRefreshUI(qlcf_award_pool)
end

function C:RunChange()
	if self.is_animing then
		return
	end
	self.mb_num = self.award_pool
	GameComAnimTool.stop_number_change_anim(self.anim_tab)
	if not self.cur_num or not self.mb_num or self.cur_num == self.mb_num then
		return
	end
	self.is_animing = true
	self.anim_tab = GameComAnimTool.play_number_change_anim(self.award_txt, tonumber(self.cur_num), tonumber(self.mb_num), 40, function ()
		self.cur_num = self.mb_num
		self.is_animing = false
		self:RunChange()
	end)
end